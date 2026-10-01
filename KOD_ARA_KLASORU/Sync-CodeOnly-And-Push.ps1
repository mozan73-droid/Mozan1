#Requires -Version 5.1
<#
.SYNOPSIS
  C:\KOD_ARA_KLASÖRÜ içinden sadece makro/kod dosyalarını alıp
  1) repo\KOD_ARA_KLASORU\ altına kopyalar
  2) isteğe bağlı küçük ZIP üretir (sohbet 10MB limiti için)

.EXAMPLE
  # Repo kökünde, branch checkout iken:
  powershell -ExecutionPolicy Bypass -File .\KOD_ARA_KLASORU\Sync-CodeOnly-And-Push.ps1

.EXAMPLE
  # Sadece küçük ZIP üret (sohbete yüklemek için):
  .\KOD_ARA_KLASORU\Sync-CodeOnly-And-Push.ps1 -ZipOnly -ZipOut "$env:USERPROFILE\Desktop\KOD_ARA_kod.zip"
#>
[CmdletBinding()]
param(
  [string]$Source = "C:\KOD_ARA_KLASÖRÜ",
  [string]$Dest = $PSScriptRoot,
  [string]$ZipOut = "",
  [switch]$ZipOnly,
  [switch]$NoGit
)

$ErrorActionPreference = "Stop"

# Sohbet/repo için anlamlı uzantılar (ağır binary hariç)
$includeExt = @(
  ".txt", ".vbs", ".bas", ".cls", ".frm", ".xml", ".sql",
  ".md", ".csv", ".ini", ".cfg", ".json", ".htm", ".html"
)

# Büyük / gereksiz
$excludeName = @("*.exe", "*.dll", "*.pdb", "*.zip", "*.rar", "*.7z",
  "*.pdf", "*.doc", "*.docx", "*.xls", "*.xlsx", "*.ppt", "*.pptx",
  "*.png", "*.jpg", "*.jpeg", "*.gif", "*.bmp", "*.tif", "*.mp4", "*.avi",
  "*.iso", "*.msi", "*.bak", "*.tmp")

if (-not (Test-Path -LiteralPath $Source)) {
  throw "Kaynak yok: $Source"
}

$staging = Join-Path $env:TEMP ("kod_ara_code_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $staging -Force | Out-Null

Write-Host "Kaynak taraniyor (sadece kod uzantilari)..." -ForegroundColor Cyan
$copied = 0
Get-ChildItem -LiteralPath $Source -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
  $ext = $_.Extension.ToLowerInvariant()
  if ($includeExt -notcontains $ext) { return }
  foreach ($pat in $excludeName) {
    if ($_.Name -like $pat) { return }
  }
  # 2MB ustu tek dosya atla (nadir buyuk dump)
  if ($_.Length -gt 2MB) {
    Write-Host "  atla (buyuk): $($_.FullName)" -ForegroundColor DarkYellow
    return
  }
  $rel = $_.FullName.Substring($Source.Length).TrimStart('\', '/')
  $target = Join-Path $staging $rel
  $tdir = Split-Path $target -Parent
  if (-not (Test-Path $tdir)) { New-Item -ItemType Directory -Path $tdir -Force | Out-Null }
  Copy-Item -LiteralPath $_.FullName -Destination $target -Force
  $copied++
}

Write-Host "Kopyalanan kod dosyasi: $copied" -ForegroundColor Green
if ($copied -eq 0) { throw "Hic kod dosyasi bulunamadi." }

if ($ZipOut -eq "") {
  $ZipOut = Join-Path $env:USERPROFILE "Desktop\KOD_ARA_kod.zip"
}

if (Test-Path -LiteralPath $ZipOut) { Remove-Item -LiteralPath $ZipOut -Force }
Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $ZipOut -CompressionLevel Optimal
$zipSize = (Get-Item -LiteralPath $ZipOut).Length
Write-Host "ZIP: $ZipOut  ($([math]::Round($zipSize/1MB, 2)) MB)" -ForegroundColor Cyan

if ($zipSize -gt 9.5MB) {
  Write-Host "UYARI: ZIP hala ~10MB ustu. Sohbete yuklemeyin; asagidaki git push kullanin." -ForegroundColor Yellow
} else {
  Write-Host "ZIP 10MB altinda — isterseniz sohbete Attach edebilirsiniz." -ForegroundColor Green
}

if ($ZipOnly) {
  Remove-Item -LiteralPath $staging -Recurse -Force
  return
}

# Repo hedefine kopyala (README/script koru)
$keep = @("README.md", "Sync-From-Local.ps1", "Sync-CodeOnly-And-Push.ps1", ".gitkeep")
Get-ChildItem -LiteralPath $Dest -Force | Where-Object { $keep -notcontains $_.Name } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -Path (Join-Path $staging "*") -Destination $Dest -Recurse -Force
Remove-Item -LiteralPath $staging -Recurse -Force

Write-Host "Repo klasoru guncellendi: $Dest" -ForegroundColor Green

if ($NoGit) { return }

$repoRoot = Split-Path $Dest -Parent
Push-Location $repoRoot
try {
  git add KOD_ARA_KLASORU
  $status = git status --porcelain KOD_ARA_KLASORU
  if (-not $status) {
    Write-Host "Git: degisiklik yok." -ForegroundColor DarkYellow
    return
  }
  git commit -m "Sync KOD_ARA_KLASORU code samples from local (filtered)"
  git push
  Write-Host "Push tamam. Cloud agent pull ile alabilir." -ForegroundColor Green
} finally {
  Pop-Location
}
