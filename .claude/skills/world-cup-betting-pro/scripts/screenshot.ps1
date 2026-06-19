# PowerShell: HTML → Lossless PNG via Microsoft Edge Headless
# Mobile-optimized: 750px width × 2x DPI → crisp on 375-430px phone screens
# Full-page: tall window (8000px) captures entire scrolling page
# Usage: .\screenshot.ps1 -HtmlPath "analysis\report.html" [-PngPath "analysis\report.png"] [-Width 750]

param(
    [Parameter(Mandatory=$true)]
    [string]$HtmlPath,
    [string]$PngPath,
    [int]$Width = 750
)

if (-not $PngPath) {
    $PngPath = [System.IO.Path]::ChangeExtension($HtmlPath, ".png")
}

# Locate msedge.exe
$edgePath = (Get-Command msedge -ErrorAction SilentlyContinue).Source
if (-not $edgePath) {
    $candidates = @(
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $edgePath = $c; break }
    }
}

if (-not $edgePath -or -not (Test-Path $edgePath)) {
    Write-Error "msedge.exe not found. Install Microsoft Edge."
    exit 1
}

$htmlAbs = (Resolve-Path $HtmlPath).Path
$pngAbs  = (Resolve-Path (Split-Path $PngPath -Parent) -ErrorAction SilentlyContinue).Path
if (-not $pngAbs) {
    New-Item -ItemType Directory -Force (Split-Path $PngPath -Parent) | Out-Null
    $pngAbs = (Resolve-Path (Split-Path $PngPath -Parent)).Path
}
$pngFull = Join-Path $pngAbs (Split-Path $PngPath -Leaf)

# Convert file:// URL
$fileUrl = "file:///" + ($htmlAbs -replace '\\', '/')

Write-Host "Capturing: $htmlAbs"
Write-Host "Output:    $pngFull"
Write-Host "Width:     $Width px (mobile-optimized, full-page via tall window)"

& $edgePath --headless `
    --screenshot="$pngFull" `
    --window-size=$Width,8000 `
    --disable-gpu `
    --default-background-color=060D1A `
    --hide-scrollbars `
    $fileUrl

if ($LASTEXITCODE -eq 0) {
    Write-Host "PNG saved successfully: $pngFull"
} else {
    Write-Error "Screenshot failed (exit code: $LASTEXITCODE)"
}
