#Requires -Version 5.1
<#
.SYNOPSIS
  Dinamo/Freedom kod kalıplarını yerel OneNote (masaüstü) defterine aktarır.

.DESCRIPTION
  OneNote COM API kullanır. Windows + yüklü OneNote masaüstü (OneNote 2016 / Microsoft 365 OneNote)
  gerekir. "OneNote for Windows 10" (UWP) COM desteklemez.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Import-To-Local-OneNote.ps1
#>
[CmdletBinding()]
param(
  [string]$NotebookName = "Dinamo Freedom Kod Kaliplari",
  [string]$NotebookPath = $(Join-Path $env:USERPROFILE "Documents\OneNote Notebooks"),
  [string]$SectionName = "Kod Kaliplari",
  [string]$ContentRoot = $PSScriptRoot
)

$ErrorActionPreference = "Stop"
$oneNs = "http://schemas.microsoft.com/office/onenote/2013/onenote"

function Get-OneNoteApp {
  try {
    return New-Object -ComObject OneNote.Application
  } catch {
    throw @"
OneNote COM baslatilamadi: $($_.Exception.Message)

Kontrol listesi:
  1) OneNote masaüstü (2016 / Microsoft 365) kurulu mu?
  2) UWP 'OneNote for Windows 10' COM desteklemez — masaüstü OneNote kullanin.
  3) OneNote'u bir kez acip Microsoft hesabina giris yapin, sonra scripti tekrar calistirin.
"@
  }
}

function Convert-MarkdownToPlain([string]$md) {
  $lines = $md -split "`r?`n"
  $out = New-Object System.Collections.Generic.List[string]
  $inCode = $false
  foreach ($line in $lines) {
    if ($line -match '^```') {
      $inCode = -not $inCode
      if ($inCode) { [void]$out.Add("----- kod -----") } else { [void]$out.Add("--------------") }
      continue
    }
    if ($inCode) {
      [void]$out.Add($line)
      continue
    }
    $t = $line
    $t = $t -replace '^#+\s*', ''
    $t = $t -replace '\*\*(.+?)\*\*', '$1'
    $t = $t -replace '`([^`]+)`', '$1'
    [void]$out.Add($t)
  }
  return ($out -join "`n")
}

function New-PageXml([string]$pageId, [string]$title, [string]$body) {
  $oeBlocks = New-Object System.Collections.Generic.List[string]
  foreach ($line in ($body -split "`n")) {
    # CDATA icinde ]]> kirilmasin
    $safeLine = $line -replace ']]>', ']]]]><![CDATA[>'
    [void]$oeBlocks.Add("<one:OE><one:T><![CDATA[$safeLine]]></one:T></one:OE>")
  }
  $children = $oeBlocks -join "`n"
  $safeTitle = $title -replace ']]>', ']]]]><![CDATA[>'
  return @"
<?xml version="1.0"?>
<one:Page xmlns:one="$oneNs" ID="$pageId">
  <one:Title>
    <one:OE>
      <one:T><![CDATA[$safeTitle]]></one:T>
    </one:OE>
  </one:Title>
  <one:Outline>
    <one:OEChildren>
$children
    </one:OEChildren>
  </one:Outline>
</one:Page>
"@
}

function Get-Attr([System.Xml.XmlNode]$node, [string]$name) {
  return $node.Attributes[$name].Value
}

function Get-SectionId([object]$onenote, [string]$notebookId, [string]$sectionName, [string]$ns) {
  $hier = ""
  $onenote.GetHierarchy($notebookId, 3, [ref]$hier) # hsSections = 3
  [xml]$hx = $hier
  $nsMgr = New-Object System.Xml.XmlNamespaceManager($hx.NameTable)
  $nsMgr.AddNamespace("one", $ns)
  $sectionNode = $hx.SelectSingleNode("//one:Section[@name=`"$sectionName`"]", $nsMgr)
  if ($null -ne $sectionNode) {
    return (Get-Attr $sectionNode "ID")
  }
  return $null
}

Write-Host "=== Dinamo/Freedom -> OneNote aktarim ===" -ForegroundColor Cyan
Write-Host "Icerik: $ContentRoot"

$sayfalar = Join-Path $ContentRoot "sayfalar"
if (-not (Test-Path $sayfalar)) {
  throw "sayfalar klasoru bulunamadi: $sayfalar`nScripti docs\Dinamo_Freedom_Kod_Kaliplari_OneNote klasorunden calistirin."
}

$files = @()
$readme = Join-Path $ContentRoot "00_README_ONENOTE.md"
if (Test-Path $readme) { $files += Get-Item $readme }
$files += @(Get-ChildItem -Path $sayfalar -Filter "*.md" | Sort-Object Name)
if ($files.Count -eq 0) { throw "Aktarilacak .md dosyasi yok." }

$onenote = Get-OneNoteApp
Write-Host "OneNote COM baglandi."

if (-not (Test-Path $NotebookPath)) {
  New-Item -ItemType Directory -Path $NotebookPath -Force | Out-Null
}

$nbFolder = Join-Path $NotebookPath $NotebookName
$notebookId = ""
Write-Host "Defter aciliyor/olusturuluyor: $nbFolder"
# cftNotebook = 1
$onenote.OpenHierarchy($nbFolder, "", [ref]$notebookId, 1)
if ([string]::IsNullOrWhiteSpace($notebookId)) {
  throw "Notebook olusturulamadi. OneNote'u acip Documents\OneNote Notebooks yazma iznini kontrol edin."
}

$sectionId = Get-SectionId $onenote $notebookId $SectionName $oneNs
if ([string]::IsNullOrWhiteSpace($sectionId)) {
  Write-Host "Bolum olusturuluyor: $SectionName"
  $sectionXml = @"
<?xml version="1.0"?>
<one:Notebook xmlns:one="$oneNs" ID="$notebookId">
  <one:Section name="$SectionName" />
</one:Notebook>
"@
  $onenote.UpdateHierarchy($sectionXml)
  Start-Sleep -Milliseconds 400
  $sectionId = Get-SectionId $onenote $notebookId $SectionName $oneNs
}
if ([string]::IsNullOrWhiteSpace($sectionId)) {
  throw "Bolum olusturulamadi: $SectionName"
}
Write-Host "Bolum ID alindi."

$ph = ""
$onenote.GetHierarchy($sectionId, 4, [ref]$ph) # hsPages = 4
[xml]$px = $ph
$nsMgr2 = New-Object System.Xml.XmlNamespaceManager($px.NameTable)
$nsMgr2.AddNamespace("one", $oneNs)
$existing = @{}
foreach ($p in $px.SelectNodes("//one:Page", $nsMgr2)) {
  $existing[(Get-Attr $p "name")] = $true
}

$created = 0
$skipped = 0
foreach ($f in $files) {
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $titleLine = ($raw -split "`r?`n" | Where-Object { $_ -match '^#\s+' } | Select-Object -First 1)
  if ($titleLine) {
    $title = ($titleLine -replace '^#\s+', '').Trim()
  } else {
    $title = [IO.Path]::GetFileNameWithoutExtension($f.Name)
  }

  if ($existing.ContainsKey($title)) {
    Write-Host "  atla (var): $title" -ForegroundColor DarkYellow
    $skipped++
    continue
  }

  $pageId = ""
  $onenote.CreateNewPage($sectionId, [ref]$pageId)
  $body = Convert-MarkdownToPlain $raw
  $xml = New-PageXml -pageId $pageId -title $title -body $body
  # dateExpectedLastModified bos = zorla yaz
  $onenote.UpdatePageContent($xml, [System.DateTime]::MinValue)
  Write-Host "  sayfa: $title" -ForegroundColor Green
  $created++
  Start-Sleep -Milliseconds 120
}

Write-Host ""
Write-Host "Tamam. Yeni sayfa: $created  Atlanan: $skipped" -ForegroundColor Cyan
Write-Host "OneNote'ta acin: $NotebookName / $SectionName"
Write-Host ""
Write-Host "Alternatif: Dinamo_Freedom_Kod_Kaliplari.docx -> Word -> Dosya > Gonder > OneNote"
