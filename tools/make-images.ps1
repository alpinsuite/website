# Generates the raster assets the site needs: the Open Graph cards, the
# apple-touch-icon and the legacy favicon.ico. brand/logo/ is the source of
# truth for the shape; this redraws the same circles at raster sizes, because
# there is no SVG rasteriser on the machines this runs on.
#
# Run it when the mark changes or a card's wording does. The output is
# committed; nothing on the site fetches it at runtime.

Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $PSScriptRoot
$Out = Join-Path $Root 'site'
$Img = Join-Path $Out 'assets\img'

# Inter is loaded from tools/fonts rather than from the system: it is not
# installed on Windows, and a card silently set in Segoe UI is a card that does
# not carry the brand. The static faces are used, not InterVariable.ttf,
# because GDI+ cannot select a weight along a variable axis.
$Fonts = New-Object System.Drawing.Text.PrivateFontCollection
foreach ($f in @('Inter-Regular.ttf', 'Inter-SemiBold.ttf')) {
    $Fonts.AddFontFile((Join-Path $PSScriptRoot "fonts\$f"))
}
$InterFamily = $Fonts.Families[0]

function New-Inter {
    param([single]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular)
    New-Object System.Drawing.Font($InterFamily, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

# The cards are the site's dark theme; the icons are its light one. Both sets
# of amber come from the brand: the bright value on dark, the dark value on
# light. They are never mixed in one composition.
$CardBg     = [System.Drawing.ColorTranslator]::FromHtml('#141613')
$CardBorder = [System.Drawing.ColorTranslator]::FromHtml('#2C302D')
$CardInk    = [System.Drawing.ColorTranslator]::FromHtml('#F1F2EF')
$CardDim    = [System.Drawing.ColorTranslator]::FromHtml('#969C97')
$CardAmber  = [System.Drawing.ColorTranslator]::FromHtml('#E8901F')

$IconBg     = [System.Drawing.ColorTranslator]::FromHtml('#F1F2EF')
$IconInk    = [System.Drawing.ColorTranslator]::FromHtml('#1A1D1B')
$IconAmber  = [System.Drawing.ColorTranslator]::FromHtml('#C77410')

# The mark: a 3x3 grid of dots whose mass grows across the diagonal, with the
# largest carrying the accent. Centres and radii are the brand's, on its own
# 100-unit grid, scaled to whatever size is asked for.
#
# $small picks the eight-dot variant, which the brand specifies below about
# 24px: the nine-dot original turns to mush at favicon sizes.
function Draw-Mark {
    param($g, [single]$x, [single]$y, [single]$size, $dots, $accent, [switch]$small)

    if ($small) {
        $c = @(24, 52, 80)
        $r = @(@(7, 10, 14), @(10, 14, 18), @(14, 18, 20))
    } else {
        $c = @(22, 50, 78)
        $r = @(@(4, 7.2, 10.4), @(7.2, 10.4, 13.6), @(10.4, 13.6, 16.8))
    }

    $u = $size / 100.0
    $bDots = New-Object System.Drawing.SolidBrush($dots)
    $bAcc = New-Object System.Drawing.SolidBrush($accent)

    for ($row = 0; $row -lt 3; $row++) {
        for ($col = 0; $col -lt 3; $col++) {
            $rad = [single]$r[$row][$col] * $u
            $cx = $x + [single]$c[$col] * $u
            $cy = $y + [single]$c[$row] * $u
            # Bottom-right only: the accent dot, the one thing that is not ink.
            $brush = if ($row -eq 2 -and $col -eq 2) { $bAcc } else { $bDots }
            $g.FillEllipse($brush, ($cx - $rad), ($cy - $rad), (2 * $rad), (2 * $rad))
        }
    }

    $bDots.Dispose(); $bAcc.Dispose()
}

function New-Canvas {
    param([int]$w, [int]$h)
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    return @($bmp, $g)
}

# --- Open Graph cards -------------------------------------------------------
# 1200x630, the size every consumer crops to. Flat, hairline, one accent, the
# same as the page it stands for.
function New-Card {
    param([string]$file, [string]$title, [string]$subtitle)

    $c = New-Canvas 1200 630
    $bmp = $c[0]; $g = $c[1]

    $g.Clear($CardBg)

    $pen = New-Object System.Drawing.Pen($CardBorder, 1)
    $g.DrawLine($pen, 80, 168, 1120, 168)
    $g.DrawLine($pen, 80, 516, 1120, 516)
    $pen.Dispose()

    Draw-Mark $g 80 76 64 $CardInk $CardAmber

    $fName = New-Inter 30 ([System.Drawing.FontStyle]::Bold)
    $fSub = New-Inter 13
    $fTitle = New-Inter 84 ([System.Drawing.FontStyle]::Bold)
    $fBody = New-Inter 32
    $fUrl = New-Object System.Drawing.Font('Consolas', 24, [System.Drawing.GraphicsUnit]::Pixel)

    $bInk = New-Object System.Drawing.SolidBrush($CardInk)
    $bDim = New-Object System.Drawing.SolidBrush($CardDim)
    $bAcc = New-Object System.Drawing.SolidBrush($CardAmber)

    # The lockup: mark, name, and `systems` set beneath it in amber. The
    # sub-line is the one place the mono face would be used, but only Inter is
    # loaded here, so it is set in Inter and tracked out instead.
    $g.DrawString('buache', $fName, $bInk, 158, 80)
    $tracked = New-Object System.Drawing.StringFormat
    $g.DrawString('S Y S T E M S', $fSub, $bAcc, 162, 116)
    $tracked.Dispose()

    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Trimming = [System.Drawing.StringTrimming]::Word

    $g.DrawString($title, $fTitle, $bInk, (New-Object System.Drawing.RectangleF(78, 212, 1044, 120)), $fmt)
    $g.DrawString($subtitle, $fBody, $bDim, (New-Object System.Drawing.RectangleF(80, 350, 980, 140)), $fmt)
    $g.DrawString('buache.systems', $fUrl, $bAcc, 80, 546)

    $g.Dispose()
    $bmp.Save((Join-Path $Img $file), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()

    foreach ($d in @($fName, $fSub, $fTitle, $fBody, $fUrl, $bInk, $bDim, $bAcc, $fmt)) { $d.Dispose() }
    Write-Output "wrote $file"
}

New-Card 'og-home.png'     'Buache Systems' 'European software, on machines you own. Desktop applications for Linux that keep your documents on your own disk.'
New-Card 'og-paint.png'    'Paint'    'A simple, easy-to-use image editor. Open a picture, draw on it, save it, get on with your day.'
New-Card 'og-snipper.png'  'Snipper'  'Screen capture and annotation. Draw a rectangle around what matters, mark it up, and send it.'
New-Card 'og-shrink.png'   'Shrink'   'A batch image resizer that takes the constraint you actually have, and measures the result.'
New-Card 'og-download.png' 'Download' 'One .deb per app, for x86-64 Linux. No installer, no account, nothing to activate.'

# --- apple-touch-icon -------------------------------------------------------
# iOS composites a transparent icon onto white, so this one is opaque, on the
# brand's paper. The full nine-dot mark: 180px is well above the threshold.
$c = New-Canvas 180 180
$bmp = $c[0]; $g = $c[1]
$g.Clear($IconBg)
Draw-Mark $g 18 18 144 $IconInk $IconAmber
$g.Dispose()
$bmp.Save((Join-Path $Out 'apple-touch-icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output 'wrote apple-touch-icon.png'

# --- favicon.ico ------------------------------------------------------------
# The legacy fallback; favicon.svg is what modern browsers use, and it is the
# only one of the two that can follow the theme. This one is drawn on paper,
# because an ICO has no media query and a transparent mark disappears against
# a dark browser chrome.
#
# Built by hand as an ICO container holding PNG images, which every browser
# since IE11 reads, because System.Drawing cannot write a multi-size icon.
$sizes = @(16, 32, 48)
$payloads = @()
foreach ($s in $sizes) {
    $c = New-Canvas $s $s
    $bmp = $c[0]; $g = $c[1]
    $g.Clear($IconBg)
    # The eight-dot variant at every size here: 48px is still under the 24px
    # threshold once the mark is inset, and one shape across the three sizes
    # beats a set that changes drawing halfway up.
    Draw-Mark $g 0 0 $s $IconInk $IconAmber -small
    $g.Dispose()
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $payloads += , $ms.ToArray()
    $ms.Dispose()
}

$fs = [System.IO.File]::Create((Join-Path $Out 'favicon.ico'))
$bw = New-Object System.IO.BinaryWriter($fs)
$bw.Write([uint16]0)                  # reserved
$bw.Write([uint16]1)                  # type: icon
$bw.Write([uint16]$sizes.Count)

$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $bw.Write([byte]$sizes[$i])       # width  (0 would mean 256)
    $bw.Write([byte]$sizes[$i])       # height
    $bw.Write([byte]0)                # palette size
    $bw.Write([byte]0)                # reserved
    $bw.Write([uint16]1)              # colour planes
    $bw.Write([uint16]32)             # bits per pixel
    $bw.Write([uint32]$payloads[$i].Length)
    $bw.Write([uint32]$offset)
    $offset += $payloads[$i].Length
}
foreach ($p in $payloads) { $bw.Write($p) }
$bw.Flush(); $bw.Close(); $fs.Close()
Write-Output 'wrote favicon.ico'

$Fonts.Dispose()
