# ==============================================================
#  Antigravity RTL & BiDi Patcher v1.3.1
#  https://github.com/MOhammaDpirouznia/antigravity-rtl
# ==============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity RTL Patcher v1.3.1"

Clear-Host
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "            ANTIGRAVITY RTL & BIDI PATCHER v1.3.1             " -ForegroundColor Cyan
Write-Host "  Automatic Right-to-Left Layout & Persian/Arabic Typography  " -ForegroundColor DarkCyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$targetDir  = "$env:LOCALAPPDATA\Programs\antigravity\resources"
$appExe     = "$env:LOCALAPPDATA\Programs\antigravity\Antigravity.exe"
$sourceAsar = Join-Path $PSScriptRoot "app.asar"
$fontsDir   = Join-Path $PSScriptRoot "fonts"
$targetAsar = Join-Path $targetDir "app.asar"
$backupAsar = Join-Path $targetDir "app.asar.backup"
$customCss  = Join-Path $targetDir "custom-rtl.css"

# Validation
if (-not (Test-Path $targetAsar)) {
    Write-Host "[ERROR] Antigravity installation not found at:" -ForegroundColor Red
    Write-Host "        $targetDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please ensure Google Antigravity is installed on this PC." -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

if (-not (Test-Path $sourceAsar)) {
    Write-Host "[ERROR] Patched 'app.asar' package not found in script folder!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Helper to read font and convert to base64 for self-contained embedding
function Get-FontBase64 ($fontFile) {
    if (Test-Path $fontFile) {
        $bytes = [System.IO.File]::ReadAllBytes($fontFile)
        return [System.Convert]::ToBase64String($bytes)
    }
    return $null
}

# --- Step 1: Interactive Font Selection ---
Write-Host "==============================================================" -ForegroundColor DarkGray
Write-Host "          SELECT YOUR PREFERRED FONT (EMBEDDED OFFLINE)       " -ForegroundColor White
Write-Host "==============================================================" -ForegroundColor DarkGray
Write-Host "  [0] Stock Font      " -NoNewline -ForegroundColor Green
Write-Host "(Skip / Keep original Antigravity font - RTL only)" -ForegroundColor Gray
Write-Host "  [1] Vazirmatn       " -NoNewline -ForegroundColor Green
Write-Host "(Persian/Arabic Modern UI - Clean & Balanced) [DEFAULT]" -ForegroundColor Gray
Write-Host "  [2] Lalezar         " -NoNewline -ForegroundColor Green
Write-Host "(Bold, Distinct Retro Display Font - Highly Visible!)" -ForegroundColor Yellow
Write-Host "  [3] Cairo           " -NoNewline -ForegroundColor Green
Write-Host "(#1 Modern Arabic & Persian UI Font - Google Fonts)" -ForegroundColor Gray
Write-Host "  [4] Sahel           " -NoNewline -ForegroundColor Green
Write-Host "(Soft, Elegant & High Readability)" -ForegroundColor Gray
Write-Host "  [5] Shabnam         " -NoNewline -ForegroundColor Green
Write-Host "(Crisp Geometric Reading Font)" -ForegroundColor Gray
Write-Host "  [6] Windows Default " -NoNewline -ForegroundColor Green
Write-Host "(Segoe UI / Tahoma / Arial)" -ForegroundColor Gray
Write-Host "  [7] Custom Font     " -NoNewline -ForegroundColor Green
Write-Host "(Specify any font already installed in Windows)" -ForegroundColor Gray
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray

$choice = Read-Host "Select font option [0-7] (Press Enter for Vazirmatn, 2 for Lalezar)"

$fontName = "Vazirmatn"
$cssContent = ""

# Helper to generate font CSS with Tailwind custom properties & element rules
function Generate-FontCss ($family, $b64, $fallback) {
    $fontFaceBlock = ""
    if ($b64) {
        $fontFaceBlock = @"
@font-face {
    font-family: '$family';
    src: url('data:font/truetype;base64,$b64') format('truetype');
    font-weight: normal;
    font-style: normal;
    font-display: swap;
}
"@
    }
    return @"
$fontFaceBlock
:root, :host, html, body {
    --vscode-font-family: '$family', $fallback !important;
    --font-sans: '$family', $fallback !important;
    --default-font-family: '$family', $fallback !important;
    font-family: '$family', $fallback !important;
}
body, p, li, blockquote, span, div, a, label, button, input, textarea,
[class*="message"], [class*="content"], [class*="prose"], [class*="bubble"], [class*="text"],
h1, h2, h3, h4, h5, h6 {
    font-family: '$family', $fallback !important;
}
pre, code, kbd, samp,
pre *, code *,
[class*="code"], [class*="terminal"], [class*="syntax"],
[class*="monaco"], [class*="xterm"] {
    font-family: var(--font-mono, ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace) !important;
}
"@
}

switch ($choice) {
    "0" {
        $fontName = "Stock Antigravity Font (Original Unchanged)"
        $cssContent = @"
/* Antigravity RTL - Stock Font Preserved (No font-family override) */
"@
    }
    "2" {
        $fontName = "Lalezar (Bold, Distinct Retro Display)"
        $fontPath = Join-Path $fontsDir "Lalezar.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = Generate-FontCss "Lalezar" $b64 "'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif"
    }
    "3" {
        $fontName = "Cairo (Modern Arabic & Persian)"
        $fontPath = Join-Path $fontsDir "Cairo.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = Generate-FontCss "Cairo" $b64 "'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif"
    }
    "4" {
        $fontName = "Sahel (Smooth & High Readability)"
        $fontPath = Join-Path $fontsDir "Sahel.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = Generate-FontCss "Sahel" $b64 "'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif"
    }
    "5" {
        $fontName = "Shabnam (Crisp Geometric)"
        $fontPath = Join-Path $fontsDir "Shabnam.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = Generate-FontCss "Shabnam" $b64 "'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif"
    }
    "6" {
        $fontName = "Windows System Default (Segoe UI / Tahoma)"
        $cssContent = Generate-FontCss "Segoe UI" "" "Tahoma, Arial, sans-serif"
    }
    "7" {
        Write-Host ""
        $userFont = Read-Host "Enter your installed font name (e.g., IRANSans, Dana, B Nazanin)"
        if ([string]::IsNullOrWhiteSpace($userFont)) {
            $userFont = "Vazirmatn"
        }
        $fontName = "Custom: $userFont"
        $cssContent = Generate-FontCss $userFont "" "'Segoe UI', Tahoma, sans-serif"
    }
    Default {
        $fontName = "Vazirmatn (Modern UI - Default)"
        $fontPath = Join-Path $fontsDir "Vazirmatn.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = Generate-FontCss "Vazirmatn" $b64 "-apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif"
    }
}

Write-Host ""
Write-Host "[CONFIG] Active Font: " -NoNewline -ForegroundColor Cyan
Write-Host "$fontName" -ForegroundColor Yellow
Write-Host ""

# --- Step 2: Interactive Layout Selection (Sidebars Mirroring) ---
Write-Host "==============================================================" -ForegroundColor DarkGray
Write-Host "                LAYOUT & SIDEBAR POSITIONING                  " -ForegroundColor White
Write-Host "==============================================================" -ForegroundColor DarkGray
Write-Host "  [1] Standard Layout " -NoNewline -ForegroundColor Green
Write-Host "(Projects on Left, Console/Files on Right) [DEFAULT]" -ForegroundColor Gray
Write-Host "  [2] Mirrored RTL Layout " -NoNewline -ForegroundColor Green
Write-Host "(Projects on Right, Console/Files on Left - Full RTL IDE)" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray

$layoutChoice = Read-Host "Select layout option [1-2] (Press Enter for Standard, 2 for Mirrored)"
$layoutName = "Standard (Projects Left, Console Right)"

if ($layoutChoice -eq "2") {
    $layoutName = "Mirrored RTL (Projects Right, Console Left)"
    $cssContent += @"

/* ============================================================== */
/*  Mirrored RTL Layout: Projects Sidebar on Right, Console Left  */
/* ============================================================== */
.flex-1.flex.min-h-0.relative > .relative.flex.w-full.h-full.outline-none {
    flex-direction: row-reverse !important;
}
.relative.z-0.flex-1.flex.min-h-0.h-full > .relative.flex.w-full.h-full.outline-none {
    flex-direction: row-reverse !important;
}
.flex-1.flex.min-h-0.relative > .absolute.left-0.top-0 {
    left: auto !important;
    right: 0 !important;
}
.flex-1.flex.min-h-0.relative > .absolute.right-0.top-0 {
    right: auto !important;
    left: 0 !important;
}

/* Fix overlaps for auxiliary pane tabs & chat header */
div[class*="pr-[72px]"], [class*="pl-1.5"][class*="pr-"] {
    padding-left: 72px !important;
    padding-right: 8px !important;
}
.flex.items-center.gap-1.min-w-0.text-secondary-foreground {
    padding-left: 42px !important;
}
"@
}

Write-Host ""
Write-Host "[CONFIG] Active Layout: " -NoNewline -ForegroundColor Cyan
Write-Host "$layoutName" -ForegroundColor Yellow
Write-Host ""

# --- Step 3: Stop Running Instances & Purge Stale Auto-Updates ---
Write-Host "[1/4] Closing running Antigravity processes & clearing updater cache..." -ForegroundColor DarkYellow
$updaterDir = "$env:LOCALAPPDATA\antigravity-updater"
if (Test-Path $updaterDir) {
    try {
        Remove-Item -Path "$updaterDir\pending\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$updaterDir\installer.exe" -Force -ErrorAction SilentlyContinue
    } catch {}
}
$running = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue
if ($running) {
    $running | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "      Processes terminated successfully." -ForegroundColor Gray
} else {
    Write-Host "      No active Antigravity process found." -ForegroundColor Gray
}

# --- Step 3: Backup Original ---
if (-not (Test-Path $backupAsar)) {
    Write-Host "[2/4] Creating secure factory backup (app.asar.backup)..." -ForegroundColor DarkCyan
    Copy-Item -Path $targetAsar -Destination $backupAsar -Force
    Write-Host "      Backup stored successfully." -ForegroundColor Green
} else {
    Write-Host "[2/4] Backup already exists (app.asar.backup). Preserving original." -ForegroundColor Gray
}

# --- Step 4: Apply Patched Package & Write Font Configuration ---
Write-Host "[3/4] Installing RTL patch & embedding selected font..." -ForegroundColor DarkCyan
try {
    # 4a. Copy patched app.asar
    Copy-Item -Path $sourceAsar -Destination $targetAsar -Force

    # 4b. Write dynamic custom-rtl.css with embedded font
    [System.IO.File]::WriteAllText($customCss, $cssContent, [System.Text.Encoding]::UTF8)

    # 4c. Copy fonts directory for reference
    $targetFonts = Join-Path $targetDir "fonts"
    if (Test-Path $fontsDir) {
        Copy-Item -Path $fontsDir -Destination $targetDir -Recurse -Force
    }

    Write-Host "      Files written successfully." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to write files: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# --- Step 5: Launch Antigravity 100% Detached (No Console Hijack) ---
Write-Host "[4/4] Launching Antigravity in detached background mode..." -ForegroundColor DarkCyan

# Launching via 'cmd /c start' completely decouples Antigravity from this console window
Start-Process -FilePath "cmd.exe" -ArgumentList "/c start `"`" `"$appExe`"" -WindowStyle Hidden

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "   [SUCCESS] Antigravity RTL Patch applied successfully!      " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "  * Active Font       : " -NoNewline -ForegroundColor Gray
Write-Host "$fontName (Embedded)" -ForegroundColor Cyan
Write-Host "  * IDE Layout        : " -NoNewline -ForegroundColor Gray
Write-Host "$layoutName" -ForegroundColor Cyan
Write-Host "  * Text Alignment    : " -NoNewline -ForegroundColor Gray
Write-Host "Real-Time Auto RTL (unicode-bidi: plaintext)" -ForegroundColor White
Write-Host "  * Code Blocks       : " -NoNewline -ForegroundColor Gray
Write-Host "Protected Left-to-Right (LTR)" -ForegroundColor White
Write-Host "  * DevTools Shortcut : " -NoNewline -ForegroundColor Gray
Write-Host "Ctrl + Shift + I" -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Note: Antigravity is running independently." -ForegroundColor DarkGray
Write-Host "Closing this window will NOT affect the application." -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")