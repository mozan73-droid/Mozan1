#!/usr/bin/env python3
"""
Copy data between MSSQL tables.

Supports:
- Same server copy: INSERT INTO dest SELECT ... FROM source (single connection)
- Cross server copy: read from source, bulk insert into dest (two connections)

Requires: pyodbc (ODBC Driver 17/18 for SQL Server installed on the machine).
"""

from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass
from typing import Iterable, List, Optional, Sequence, Tuple

import pyodbc


def _eprint(*args: object) -> None:
    print(*args, file=sys.stderr)


def _split_3part(name: str) -> Tuple[Optional[str], Optional[str], str]:
    """
    Accepts:
      table
      schema.table
      db.schema.table
    Returns: (db, schema, table)
    """
    parts = [p for p in name.split(".") if p]
    if len(parts) == 1:
        return (None, None, parts[0])
    if len(parts) == 2:
        return (None, parts[0], parts[1])
    if len(parts) == 3:
        return (parts[0], parts[1], parts[2])
    raise ValueError(f"Invalid table name '{name}'. Use table, schema.table, or db.schema.table.")


def _bracket(ident: str) -> str:
    # Basic escaping for closing bracket
    return "[" + ident.replace("]", "]]") + "]"


def _full_table_name(db: Optional[str], schema: Optional[str], table: str) -> str:
    if db and schema:
        return f"{_bracket(db)}.{_bracket(schema)}.{_bracket(table)}"
    if schema:
        return f"{_bracket(schema)}.{_bracket(table)}"
    return _bracket(table)


@dataclass(frozen=True)
class TableRef:
    raw: str
    db: Optional[str]
    schema: Optional[str]
    table: str

    @property
    def sql(self) -> str:
        return _full_table_name(self.db, self.schema, self.table)


def parse_table_ref(raw: str, default_schema: str = "dbo") -> TableRef:
    db, schema, table = _split_3part(raw)
    if schema is None:
        schema = default_schema
    return TableRef(raw=raw, db=db, schema=schema, table=table)


def connect(conn_str: str, timeout: int = 30) -> pyodbc.Connection:
    # autocommit off; we manage commits.
    return pyodbc.connect(conn_str, timeout=timeout, autocommit=False)


def fetch_table_columns(
    conn: pyodbc.Connection,
    table: TableRef,
) -> List[str]:
    """
    Returns ordered column names (excluding computed columns).
    """
    # Prefer sys.* metadata; ignore computed columns.
    # If table.db is provided, we must query [db].sys.* (sys catalogs are per-database).
    db_prefix = _bracket(table.db) if table.db else None
    sys_prefix = f"{db_prefix}.sys" if db_prefix else "sys"

    sql = f"""
    SELECT c.name
    FROM {sys_prefix}.columns AS c
    INNER JOIN {sys_prefix}.objects AS o ON o.object_id = c.object_id
    INNER JOIN {sys_prefix}.schemas AS s ON s.schema_id = o.schema_id
    WHERE o.name = ?
      AND s.name = ?
      AND o.[type] IN ('U','V')
      AND c.is_computed = 0
    ORDER BY c.column_id
    """
    cur = conn.cursor()
    rows = cur.execute(sql, (table.table, table.schema)).fetchall()
    cols = [r[0] for r in rows]
    if not cols:
        raise RuntimeError(
            f"Could not read columns for table {table.raw}. "
            f"Check that it exists and you have permissions."
        )
    return cols


def truncate_table(conn: pyodbc.Connection, table: TableRef) -> None:
    conn.cursor().execute(f"TRUNCATE TABLE {table.sql}")


def set_identity_insert(conn: pyodbc.Connection, table: TableRef, on: bool) -> None:
    val = "ON" if on else "OFF"
    conn.cursor().execute(f"SET IDENTITY_INSERT {table.sql} {val}")


def server_side_copy(
    conn: pyodbc.Connection,
    src: TableRef,
    dst: TableRef,
    columns: Sequence[str],
    where: Optional[str],
) -> int:
    cols_sql = ", ".join(_bracket(c) for c in columns)
    where_sql = f" WHERE {where}" if where else ""
    sql = f"INSERT INTO {dst.sql} ({cols_sql}) SELECT {cols_sql} FROM {src.sql}{where_sql}"
    cur = conn.cursor()
    cur.execute(sql)
    # rowcount can be -1 for some drivers; still commit and report best-effort.
    return cur.rowcount


def cross_server_copy(
    src_conn: pyodbc.Connection,
    dst_conn: pyodbc.Connection,
    src: TableRef,
    dst: TableRef,
    columns: Sequence[str],
    where: Optional[str],
    batch_size: int,
    fast_executemany: bool,
) -> int:
    cols_sql = ", ".join(_bracket(c) for c in columns)
    where_sql = f" WHERE {where}" if where else ""
    select_sql = f"SELECT {cols_sql} FROM {src.sql}{where_sql}"

    placeholders = ", ".join("?" for _ in columns)
    insert_sql = f"INSERT INTO {dst.sql} ({cols_sql}) VALUES ({placeholders})"

    src_cur = src_conn.cursor()
    src_cur.arraysize = batch_size
    src_cur.execute(select_sql)

    dst_cur = dst_conn.cursor()
    if fast_executemany:
        try:
            dst_cur.fast_executemany = True
        except Exception:
            # Some drivers may not support it; continue without.
            pass

    total = 0
    while True:
        rows = src_cur.fetchmany(batch_size)
        if not rows:
            break
        dst_cur.executemany(insert_sql, rows)
        total += len(rows)
    return total


def main(argv: Optional[Sequence[str]] = None) -> int:
    p = argparse.ArgumentParser(
        description="Copy data between MSSQL tables (same server or cross server)."
    )
    p.add_argument("--src-conn", default=os.environ.get("MSSQL_SRC_CONN", ""), help="Source ODBC connection string (or env MSSQL_SRC_CONN)")
    p.add_argument("--dst-conn", default=os.environ.get("MSSQL_DST_CONN", ""), help="Destination ODBC connection string (or env MSSQL_DST_CONN)")
    p.add_argument("--src-table", required=True, help="Source table: table | schema.table | db.schema.table")
    p.add_argument("--dst-table", required=True, help="Destination table: table | schema.table | db.schema.table")
    p.add_argument("--default-schema", default="dbo", help="Default schema when not provided (default: dbo)")
    p.add_argument("--where", default=None, help="Optional WHERE clause without the 'WHERE' keyword")
    p.add_argument("--truncate", action="store_true", help="TRUNCATE destination table before copy")
    p.add_argument("--identity-insert", action="store_true", help="Enable IDENTITY_INSERT on destination during copy")
    p.add_argument("--batch-size", type=int, default=5000, help="Batch size for cross-server copy (default: 5000)")
    p.add_argument("--no-fast-executemany", action="store_true", help="Disable pyodbc fast_executemany optimization")
    p.add_argument(
        "--mode",
        choices=["auto", "server", "client"],
        default="auto",
        help="auto: if connections same -> server, else client. server: INSERT..SELECT. client: fetch+insert.",
    )
    args = p.parse_args(argv)

    if not args.src_conn:
        _eprint("Missing --src-conn (or MSSQL_SRC_CONN).")
        return 2
    if not args.dst_conn:
        _eprint("Missing --dst-conn (or MSSQL_DST_CONN).")
        return 2

    src = parse_table_ref(args.src_table, default_schema=args.default_schema)
    dst = parse_table_ref(args.dst_table, default_schema=args.default_schema)

    same_conn = args.src_conn.strip() == args.dst_conn.strip()
    mode = args.mode
    if mode == "auto":
        mode = "server" if same_conn else "client"

    _eprint(f"Mode: {mode} (same_conn={same_conn})")

    if mode == "server" and not same_conn:
        _eprint("Mode 'server' requires src-conn == dst-conn (same server/connection). Use --mode client.")
        return 2

    try:
        if mode == "server":
            with connect(args.src_conn) as conn:
                columns = fetch_table_columns(conn, src)
                if args.truncate:
                    truncate_table(conn, dst)
                if args.identity_insert:
                    set_identity_insert(conn, dst, True)
                rc = server_side_copy(conn, src, dst, columns, args.where)
                if args.identity_insert:
                    set_identity_insert(conn, dst, False)
                conn.commit()
                _eprint(f"Done. rowcount={rc}")
            return 0

        # client mode (two connections even if same_conn; ok)
        with connect(args.src_conn) as src_conn, connect(args.dst_conn) as dst_conn:
            columns = fetch_table_columns(src_conn, src)
            if args.truncate:
                truncate_table(dst_conn, dst)
            if args.identity_insert:
                set_identity_insert(dst_conn, dst, True)
            total = cross_server_copy(
                src_conn=src_conn,
                dst_conn=dst_conn,
                src=src,
                dst=dst,
                columns=columns,
                where=args.where,
                batch_size=args.batch_size,
                fast_executemany=not args.no_fast_executemany,
            )
            if args.identity_insert:
                set_identity_insert(dst_conn, dst, False)
            dst_conn.commit()
            _eprint(f"Done. rows_inserted={total}")
        return 0
    except pyodbc.Error as e:
        _eprint("ODBC error:", e)
        return 1
    except Exception as e:
        _eprint("Error:", e)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

