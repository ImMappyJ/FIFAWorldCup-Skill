# PowerShell: HTML → Lossless PNG via Microsoft Edge Headless
# Mobile-optimized: 750px width × 2x DPI → crisp on 375-430px phone screens
# Auto-height: measures actual page content height before screenshot — no blank bottom
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

# ═══════════════════════════════════════════════
# Step 1: Measure actual page content height
# ═══════════════════════════════════════════════
# Create a temporary HTML that loads the target, then sets document.title = scrollHeight
$htmlContent = Get-Content -Path $htmlAbs -Raw -Encoding UTF8
$measureScript = @'
<script>
(function(){
  var check = function() {
    var h = Math.max(
      document.body.scrollHeight || 0,
      document.documentElement.scrollHeight || 0,
      document.body.offsetHeight || 0,
      document.documentElement.offsetHeight || 0
    );
    if (h > 50) {
      document.title = '' + h;
    } else {
      setTimeout(check, 200);
    }
  };
  if (document.readyState === 'complete') { check(); }
  else { window.addEventListener('load', function(){ setTimeout(check, 100); }); }
})();
</script>
'@
# Inject measurement script before </body> or at end of file
if ($htmlContent -match '</body>') {
    $measureHtml = $htmlContent -replace '</body>', ($measureScript + '</body>')
} else {
    $measureHtml = $htmlContent + $measureScript
}
$tempPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "fifa_measure_$([System.IO.Path]::GetRandomFileName()).html")
[System.IO.File]::WriteAllText($tempPath, $measureHtml, [System.Text.UTF8Encoding]::new($false))
$tempUrl = "file:///" + ($tempPath -replace '\\', '/')

Write-Host "Measuring page height..."

$domOutput = & $edgePath --headless --dump-dom --window-size=$Width,1200 --disable-gpu $tempUrl 2>$null
Remove-Item $tempPath -Force -ErrorAction SilentlyContinue

# Parse measured height from <title>
$measuredHeight = 0
if ($domOutput -match '<title[^>]*>(\d+)</title>') {
    $measuredHeight = [int]$Matches[1]
}

# Fallback: if measurement failed, estimate from DOM element count
if ($measuredHeight -lt 100) {
    Write-Host "  Measurement via JS failed, using fallback estimation..."
    # Rough estimate: count major sections
    $sectionCount = ([regex]::Matches($htmlContent, 'class="(?:match-card|ticket-card|section-header|win-bars|goal-cards|htft-grid|odds-table|risk-digest|summary|nav-links|footer|header|group-strip|score-heatmap)"')).Count
    $measuredHeight = [Math]::Max(900, 400 + $sectionCount * 180)
    Write-Host "  Estimated ~${measuredHeight}px based on $sectionCount content sections"
}

# Add safety padding
$measuredHeight = [Math]::Min($measuredHeight + 32, 12000)

Write-Host "  Content height: ${measuredHeight}px"

# ═══════════════════════════════════════════════
# Step 2: Screenshot at exact content height
# ═══════════════════════════════════════════════
Write-Host "Capturing: $htmlAbs"
Write-Host "Output:    $pngFull"

& $edgePath --headless `
    --screenshot="$pngFull" `
    --window-size=$Width,$measuredHeight `
    --disable-gpu `
    --default-background-color=060D1A `
    --hide-scrollbars `
    $fileUrl

if ($LASTEXITCODE -ne 0) {
    Write-Error "Screenshot failed (exit code: $LASTEXITCODE)"
    exit 1
}

# ═══════════════════════════════════════════════
# Step 3: Verify and fine-tune (trim any leftover blank)
# ═══════════════════════════════════════════════
try {
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop

    $img = [System.Drawing.Image]::FromFile($pngFull)
    $imgHeight = $img.Height
    $imgWidth  = $img.Width
    $bmp = New-Object System.Drawing.Bitmap($img)
    $img.Dispose()

    # Sample 5 positions across width
    $sampleX = @(
        [Math]::Floor($imgWidth * 0.15),
        [Math]::Floor($imgWidth * 0.35),
        [Math]::Floor($imgWidth * 0.5),
        [Math]::Floor($imgWidth * 0.65),
        [Math]::Floor($imgWidth * 0.85)
    )

    # Find last non-blank row from bottom
    $contentBottom = $imgHeight - 1
    for ($y = $imgHeight - 1; $y -ge 10; $y -= 6) {
        $allBlank = $true
        foreach ($x in $sampleX) {
            $px = $bmp.GetPixel($x, $y)
            # Blank = very dark, near #060D1A (R≈6, G≈13, B≈26)
            if ($px.R -gt 18 -or $px.G -gt 25 -or $px.B -gt 40) {
                $allBlank = $false
                break
            }
        }
        if (-not $allBlank) {
            $contentBottom = [Math]::Min($imgHeight - 1, $y + 12)
            break
        }
    }

    $bmp.Dispose()
    $blankPx = $imgHeight - $contentBottom - 1

    if ($blankPx -gt 80) {
        Write-Host "Trimming ${blankPx}px residual blank bottom..."
        # Re-load and crop since we disposed the bitmap
        $img2 = [System.Drawing.Image]::FromFile($pngFull)
        $bmp2 = New-Object System.Drawing.Bitmap($img2)
        $img2.Dispose()
        $cropRect = New-Object System.Drawing.Rectangle(0, 0, $imgWidth, $contentBottom + 1)
        $cropped = $bmp2.Clone($cropRect, $bmp2.PixelFormat)
        $bmp2.Dispose()
        $cropped.Save($pngFull, [System.Drawing.Imaging.ImageFormat]::Png)
        $cropped.Dispose()
        Write-Host "Final: ${imgWidth}x${contentBottom}px"
    } else {
        Write-Host "PNG saved: ${imgWidth}x${imgHeight}px — fits content"
    }
} catch {
    Write-Host "PNG saved: $pngFull (fine-tune trim skipped — System.Drawing not available)"
}
