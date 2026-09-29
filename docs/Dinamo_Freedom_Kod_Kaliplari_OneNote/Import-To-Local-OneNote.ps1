#Requires -Version 5.1
<#
.SYNOPSIS
  Dinamo/Freedom kod kaliplarini yerel OneNote (masaustu) defterine aktarir.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Import-To-Local-OneNote.ps1 -ContentRoot (Get-Location).Path
#>
[CmdletBinding()]
param(
  [string]$NotebookName = "Dinamo Freedom Kod Kaliplari",
  [string]$NotebookPath = "",
  [string]$SectionName = "Kod Kaliplari",
  [string]$ContentRoot = ""
)

$ErrorActionPreference = "Stop"
$oneNs = "http://schemas.microsoft.com/office/onenote/2013/onenote"

if ([string]::IsNullOrWhiteSpace($ContentRoot)) {
  if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $ContentRoot = $PSScriptRoot
  } elseif ($MyInvocation.MyCommand.Path) {
    $ContentRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
  } else {
    $ContentRoot = (Get-Location).Path
  }
}
$ContentRoot = $ContentRoot.TrimEnd('\', '/')

if ([string]::IsNullOrWhiteSpace($NotebookPath)) {
  $NotebookPath = Join-Path $env:USERPROFILE "Documents\OneNote Notebooks"
}

function Get-OneNoteApp {
  try {
    return New-Object -ComObject OneNote.Application
  } catch {
    throw ("OneNote COM baslatilamadi: " + $_.Exception.Message + "`nOneNote masaustu (2016/365) acik olmali; UWP degil.")
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
    # OneNote XML icin kontrol karakterlerini temizle
    $t = $t -replace "[\x00-\x08\x0B\x0C\x0E-\x1F]", ""
    [void]$out.Add($t)
  }
  return ,$out.ToArray()
}

function Escape-XmlText([string]$s) {
  if ($null -eq $s) { return "" }
  $s = $s -replace '&', '&amp;'
  $s = $s -replace '<', '&lt;'
  $s = $s -replace '>', '&gt;'
  $s = $s -replace '"', '&quot;'
  return $s
}

function Get-Attr([System.Xml.XmlNode]$node, [string]$name) {
  if ($null -eq $node -or $null -eq $node.Attributes -or $null -eq $node.Attributes[$name]) { return $null }
  return $node.Attributes[$name].Value
}

function Get-SectionId([object]$onenote, [string]$notebookId, [string]$sectionName, [string]$ns) {
  $hier = ""
  $onenote.GetHierarchy($notebookId, 3, [ref]$hier)
  [xml]$hx = $hier
  $nsMgr = New-Object System.Xml.XmlNamespaceManager($hx.NameTable)
  $nsMgr.AddNamespace("one", $ns)
  $sectionNode = $hx.SelectSingleNode("//one:Section[@name=`"$sectionName`"]", $nsMgr)
  if ($null -ne $sectionNode) {
    return (Get-Attr $sectionNode "ID")
  }
  return $null
}

function Set-OneNotePageContent {
  param(
    [object]$OneNote,
    [string]$PageId,
    [string]$Title,
    [string[]]$Lines
  )

  # 1) OneNote'un olusturdugu gecerli sayfa XML'ini al
  $pageXml = ""
  $OneNote.GetPageContent($PageId, [ref]$pageXml)

  [xml]$doc = $pageXml
  $nsm = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
  $nsm.AddNamespace("one", $oneNs)

  # 2) Baslik
  $titleNode = $doc.SelectSingleNode("//one:Title/one:OE/one:T", $nsm)
  if ($null -ne $titleNode) {
    $titleNode.InnerText = ""
    $titleNode.InnerXml = "<![CDATA[" + ($Title -replace ']]>', '') + "]]>"
  }

  # 3) Mevcut Outline'i kaldir / yeni Outline ekle (semaya uygun)
  $pageNode = $doc.SelectSingleNode("//one:Page", $nsm)
  if ($null -eq $pageNode) { throw "Page dugumu bulunamadi." }

  $oldOutlines = @($pageNode.SelectNodes("one:Outline", $nsm))
  foreach ($o in $oldOutlines) { [void]$pageNode.RemoveChild($o) }

  $outline = $doc.CreateElement("one", "Outline", $oneNs)
  $oeChildren = $doc.CreateElement("one", "OEChildren", $oneNs)

  # OneNote cok buyuk sayfada zorlanabilir; satir limiti
  $maxLines = [Math]::Min($Lines.Count, 400)
  for ($i = 0; $i -lt $maxLines; $i++) {
    $line = $Lines[$i]
    if ($null -eq $line) { $line = "" }
    if ($line.Length -gt 2000) { $line = $line.Substring(0, 2000) }

    $oe = $doc.CreateElement("one", "OE", $oneNs)
    $t = $doc.CreateElement("one", "T", $oneNs)
    # CDATA yerine escaped text daha guvenli (0x80042009 onlemi)
    $t.InnerText = $line
    [void]$oe.AppendChild($t)
    [void]$oeChildren.AppendChild($oe)
  }

  if ($Lines.Count -gt $maxLines) {
    $oe = $doc.CreateElement("one", "OE", $oneNs)
    $t = $doc.CreateElement("one", "T", $oneNs)
    $t.InnerText = ("... (" + ($Lines.Count - $maxLines) + " satir kisaltildi; tam metin icin .docx kullanin)")
    [void]$oe.AppendChild($t)
    [void]$oeChildren.AppendChild($oe)
  }

  [void]$outline.AppendChild($oeChildren)
  [void]$pageNode.AppendChild($outline)

  # 4) lastModifiedDate uyumsuzlugunu onlemek icin attribute'u kaldir
  if ($null -ne $pageNode.Attributes["lastModifiedTime"]) {
    [void]$pageNode.Attributes.RemoveNamedItem("lastModifiedTime")
  }

  $outXml = $doc.OuterXml
  # 3. arguman: xs2013 = 2 (bazi OneNote surumlerinde gerekli)
  try {
    $OneNote.UpdatePageContent($outXml)
  } catch {
    try {
      $OneNote.UpdatePageContent($outXml, [DateTime]::MinValue)
    } catch {
      $OneNote.UpdatePageContent($outXml, [DateTime]::MinValue, 2)
    }
  }
}

Write-Host "=== Dinamo/Freedom -> OneNote aktarim ===" -ForegroundColor Cyan
Write-Host ("Icerik: " + $ContentRoot)

$sayfalar = Join-Path -Path $ContentRoot -ChildPath "sayfalar"
if (-not (Test-Path -LiteralPath $sayfalar)) {
  throw ("sayfalar klasoru bulunamadi: " + $sayfalar)
}

$files = @()
$readme = Join-Path -Path $ContentRoot -ChildPath "00_README_ONENOTE.md"
if (Test-Path -LiteralPath $readme) { $files += Get-Item -LiteralPath $readme }
$files += @(Get-ChildItem -LiteralPath $sayfalar -Filter "*.md" | Sort-Object Name)
if ($files.Count -eq 0) { throw "Aktarilacak .md dosyasi yok." }

$onenote = Get-OneNoteApp
Write-Host "OneNote COM baglandi."

if (-not (Test-Path -LiteralPath $NotebookPath)) {
  New-Item -ItemType Directory -Path $NotebookPath -Force | Out-Null
}

$nbFolder = Join-Path -Path $NotebookPath -ChildPath $NotebookName
$notebookId = ""
Write-Host ("Defter: " + $nbFolder)
$onenote.OpenHierarchy($nbFolder, "", [ref]$notebookId, 1)
if ([string]::IsNullOrWhiteSpace($notebookId)) {
  throw "Notebook olusturulamadi."
}

$sectionId = Get-SectionId $onenote $notebookId $SectionName $oneNs
if ([string]::IsNullOrWhiteSpace($sectionId)) {
  Write-Host ("Bolum olusturuluyor: " + $SectionName)
  $sectionXml = @"
<?xml version="1.0"?>
<one:Notebook xmlns:one="$oneNs" ID="$notebookId">
  <one:Section name="$SectionName" />
</one:Notebook>
"@
  $onenote.UpdateHierarchy($sectionXml)
  Start-Sleep -Milliseconds 500
  $sectionId = Get-SectionId $onenote $notebookId $SectionName $oneNs
}
if ([string]::IsNullOrWhiteSpace($sectionId)) {
  throw ("Bolum olusturulamadi: " + $SectionName)
}

$ph = ""
$onenote.GetHierarchy($sectionId, 4, [ref]$ph)
[xml]$px = $ph
$nsMgr2 = New-Object System.Xml.XmlNamespaceManager($px.NameTable)
$nsMgr2.AddNamespace("one", $oneNs)
$existing = @{}
foreach ($p in $px.SelectNodes("//one:Page", $nsMgr2)) {
  $nm = Get-Attr $p "name"
  if ($nm) { $existing[$nm] = $true }
}

$created = 0
$skipped = 0
$failed = 0

foreach ($f in $files) {
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $titleLine = ($raw -split "`r?`n" | Where-Object { $_ -match '^#\s+' } | Select-Object -First 1)
  if ($titleLine) {
    $title = ($titleLine -replace '^#\s+', '').Trim()
  } else {
    $title = [IO.Path]::GetFileNameWithoutExtension($f.Name)
  }
  # OneNote sayfa adi cok uzun olmasin
  if ($title.Length -gt 100) { $title = $title.Substring(0, 100) }

  if ($existing.ContainsKey($title)) {
    Write-Host ("  atla (var): " + $title) -ForegroundColor DarkYellow
    $skipped++
    continue
  }

  try {
    $pageId = ""
    $onenote.CreateNewPage($sectionId, [ref]$pageId)
    Start-Sleep -Milliseconds 200
    $lines = Convert-MarkdownToPlain $raw
    Set-OneNotePageContent -OneNote $onenote -PageId $pageId -Title $title -Lines $lines
    Write-Host ("  sayfa: " + $title) -ForegroundColor Green
    $created++
    $existing[$title] = $true
  } catch {
    Write-Host ("  HATA: " + $title + " -> " + $_.Exception.Message) -ForegroundColor Red
    $failed++
  }
  Start-Sleep -Milliseconds 150
}

Write-Host ""
Write-Host ("Tamam. Yeni: " + $created + "  Atlanan: " + $skipped + "  Hata: " + $failed) -ForegroundColor Cyan
Write-Host ("OneNote: " + $NotebookName + " / " + $SectionName)
if ($failed -gt 0 -or $created -eq 0) {
  Write-Host ""
  Write-Host "Alternatif (daha guvenilir): Dinamo_Freedom_Kod_Kaliplari.docx dosyasini Word ile acin," -ForegroundColor Yellow
  Write-Host "  Dosya > Paylas / Gonder > OneNote" -ForegroundColor Yellow
}
