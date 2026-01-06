## MSSQL tablolar arası kopyalama

Bu repo, MSSQL’de **bir tablodan diğerine veri kopyalamak** için basit bir CLI aracı içerir: `mssql_table_copy.py`.

### Gereksinimler

- **Python 3.9+**
- **ODBC Driver 17/18 for SQL Server** (Linux’ta `msodbcsql17`/`msodbcsql18`)

### Kurulum

```bash
python3 -m pip install -r requirements.txt
```

### ODBC Driver kurulumu (Linux)

`pyodbc` için sistemde **unixODBC** ve **Microsoft ODBC Driver** kurulu olmalı.

- unixODBC (Ubuntu/Debian):

```bash
sudo apt-get update && sudo apt-get install -y unixodbc
```

- Microsoft ODBC Driver 18 kurulum yönergesi: `https://learn.microsoft.com/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server`

Kurulu driver adlarını görmek için:

```bash
python3 -c "import pyodbc; print(pyodbc.drivers())"
```

### Kullanım

Bağlantı string’lerini env ile verebilirsiniz:

```bash
export MSSQL_SRC_CONN="Driver={ODBC Driver 18 for SQL Server};Server=tcp:HOST,1433;Database=DB1;Uid=USER;Pwd=PASS;Encrypt=yes;TrustServerCertificate=yes;"
export MSSQL_DST_CONN="Driver={ODBC Driver 18 for SQL Server};Server=tcp:HOST,1433;Database=DB2;Uid=USER;Pwd=PASS;Encrypt=yes;TrustServerCertificate=yes;"
```

#### Aynı sunucuda (tek SQL ile) kopyalama

`src-conn` ve `dst-conn` **aynıysa** `--mode auto` otomatik olarak `server` modunu seçer:

```bash
python3 mssql_table_copy.py \
  --src-table dbo.SourceTable \
  --dst-table dbo.DestTable \
  --truncate
```

#### Farklı sunucular arasında kopyalama (client mode)

Kaynak ve hedef farklı bağlantıysa otomatik `client` moda geçer (satırları çekip batch ile insert eder):

```bash
python3 mssql_table_copy.py \
  --src-table dbo.SourceTable \
  --dst-table dbo.DestTable \
  --batch-size 5000
```

#### Filtreli kopyalama (WHERE)

```bash
python3 mssql_table_copy.py \
  --src-table dbo.SourceTable \
  --dst-table dbo.DestTable \
  --where "CreateDate >= '2025-01-01'"
```

#### IDENTITY kolonlarını da kopyalamak

Hedef tabloda identity değerlerini aynen basmak istiyorsanız:

```bash
python3 mssql_table_copy.py \
  --src-table dbo.SourceTable \
  --dst-table dbo.DestTable \
  --identity-insert
```

### Notlar

- Script, **kaynak tablodaki computed kolonları** hariç tutarak kolon listesini otomatik çıkarır.
- Hedef tabloda kolonlar/uyumluluk farklıysa (tip/kolon sayısı), SQL Server hata döndürür.
