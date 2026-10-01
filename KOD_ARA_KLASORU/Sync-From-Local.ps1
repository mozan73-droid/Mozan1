#Requires -Version 5.1
<#
.SYNOPSIS
  C:\KOD_ARA_KLASÖRÜ içeriğini repo içindeki KOD_ARA_KLASORU/ klasörüne kopyalar.

.EXAMPLE
  # Repo kökünden:
  powershell -ExecutionPolicy Bypass -File .\KOD_ARA_KLASORU\Sync-From-Local.ps1

.EXAMPLE
  .\KOD_ARA_KLASORU\Sync-From-Local.ps1 -Source "C:\KOD_ARA_KLASÖRÜ" -Clean
#>
[CmdletBinding()]
param(
  [string]$Source = "C:\KOD_ARA_KLASÖRÜ",
  [string]$Dest = $PSScriptRoot,
  [switch]$Clean
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Source)) {
  throw "Kaynak bulunamadi: $Source"
}

# README ve sync scriptini koru
$keep = @(
  "README.md",
  "Sync-From-Local.ps1",
  ".gitkeep"
)

Write-Host "Kaynak : $Source" -ForegroundColor Cyan
Write-Host "Hedef  : $Dest" -ForegroundColor Cyan

if ($Clean) {
  Get-ChildItem -LiteralPath $Dest -Force | Where-Object {
    $keep -notcontains $_.Name
  } | Remove-Item -Recurse -Force
  Write-Host "Hedef temizlendi (script/README korundu)." -ForegroundColor DarkYellow
}

# robocopy: /E alt klasorler, /XD .git, /XF yok; /NFL /NDL ozet
$excludeDirs = @(".git")
$robolog = Join-Path $env:TEMP "kod_ara_sync.log"
$args = @(
  $Source,
  $Dest,
  "/E",
  "/XO",
  "/R:1",
  "/W:1",
  "/NFL",
  "/NDL",
  "/NP",
  "/XD"
) + $excludeDirs

# README/script uzerine yazilmasin diye once kopyala, sonra keep dosyalarini geri yaz
$backup = Join-Path $env:TEMP ("kod_ara_keep_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
foreach ($k in $keep) {
  $p = Join-Path $Dest $k
  if (Test-Path -LiteralPath $p) {
    Copy-Item -LiteralPath $p -Destination (Join-Path $backup $k) -Force
  }
}

& robocopy @args | Out-Host
$rc = $LASTEXITCODE
# robocopy 0-7 basari sayilir
if ($rc -ge 8) {
  throw "robocopy hata kodu: $rc"
}

foreach ($k in $keep) {
  $b = Join-Path $backup $k
  if (Test-Path -LiteralPath $b) {
    Copy-Item -LiteralPath $b -Destination (Join-Path $Dest $k) -Force
  }
}
Remove-Item -LiteralPath $backup -Recurse -Force -ErrorAction SilentlyContinue

$count = (Get-ChildItem -LiteralPath $Dest -Recurse -File | Measure-Object).Count
Write-Host ""
Write-Host "Tamam. Hedefte dosya sayisi: $count" -ForegroundColor Green
Write-Host "Sonraki adim:"
Write-Host "  git add KOD_ARA_KLASORU"
Write-Host "  git commit -m `"Sync KOD_ARA_KLASORU from local`""
Write-Host "  git push"
