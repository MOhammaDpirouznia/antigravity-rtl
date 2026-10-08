# ==============================================================
#  Antigravity RTL & BiDi Patcher v1.2.0
#  https://github.com/MOhammaDpirouznia/antigravity-rtl
# ==============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity RTL Patcher v1.2.0"

Clear-Host
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "            ANTIGRAVITY RTL & BIDI PATCHER v1.2.0             " -ForegroundColor Cyan
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
Write-Host "  [1] Vazirmatn       " -NoNewline -ForegroundColor Green
Write-Host "(Persian/Arabic Modern UI - Clean & Balanced) [DEFAULT]" -ForegroundColor Gray
Write-Host "  [2] Cairo           " -NoNewline -ForegroundColor Green
Write-Host "(#1 Modern Arabic & Persian UI Font - Google Fonts)" -ForegroundColor Gray
Write-Host "  [3] Sahel           " -NoNewline -ForegroundColor Green
Write-Host "(Soft, Elegant & High Readability)" -ForegroundColor Gray
Write-Host "  [4] Shabnam         " -NoNewline -ForegroundColor Green
Write-Host "(Crisp Geometric Reading Font)" -ForegroundColor Gray
Write-Host "  [5] Windows Default " -NoNewline -ForegroundColor Green
Write-Host "(Segoe UI / Tahoma / Arial)" -ForegroundColor Gray
Write-Host "  [6] Custom Font     " -NoNewline -ForegroundColor Green
Write-Host "(Specify any font already installed in Windows)" -ForegroundColor Gray
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray

$choice = Read-Host "Select font option [1-6] (Press Enter for Vazirmatn)"

$fontName = "Vazirmatn"
$cssContent = ""

switch ($choice) {
    "2" {
        $fontName = "Cairo (Modern Arabic & Persian)"
        $fontPath = Join-Path $fontsDir "Cairo.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = @"
@font-face {
    font-family: 'Cairo';
    src: url('data:font/truetype;charset=utf-8;base64,$b64') format('truetype');
    font-weight: normal;
    font-style: normal;
}
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: 'Cairo', 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif !important;
}
"@
    }
    "3" {
        $fontName = "Sahel (Smooth & High Readability)"
        $fontPath = Join-Path $fontsDir "Sahel.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = @"
@font-face {
    font-family: 'Sahel';
    src: url('data:font/truetype;charset=utf-8;base64,$b64') format('truetype');
    font-weight: normal;
    font-style: normal;
}
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: 'Sahel', 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif !important;
}
"@
    }
    "4" {
        $fontName = "Shabnam (Crisp Geometric)"
        $fontPath = Join-Path $fontsDir "Shabnam.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = @"
@font-face {
    font-family: 'Shabnam';
    src: url('data:font/truetype;charset=utf-8;base64,$b64') format('truetype');
    font-weight: normal;
    font-style: normal;
}
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: 'Shabnam', 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif !important;
}
"@
    }
    "5" {
        $fontName = "Windows System Default (Segoe UI / Tahoma)"
        $cssContent = @"
/* Antigravity RTL - Windows System Default Font */
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, Arial, sans-serif !important;
}
"@
    }
    "6" {
        Write-Host ""
        $userFont = Read-Host "Enter your installed font name (e.g., IRANSans, Dana, B Nazanin)"
        if ([string]::IsNullOrWhiteSpace($userFont)) {
            $userFont = "Vazirmatn"
        }
        $fontName = "Custom: $userFont"
        $cssContent = @"
/* Antigravity RTL - Custom Font: $userFont */
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: '$userFont', 'Vazirmatn', 'Segoe UI', Tahoma, sans-serif !important;
}
"@
    }
    Default {
        $fontName = "Vazirmatn (Modern UI - Default)"
        $fontPath = Join-Path $fontsDir "Vazirmatn.ttf"
        $b64 = Get-FontBase64 $fontPath
        $cssContent = @"
@font-face {
    font-family: 'Vazirmatn';
    src: url('data:font/truetype;charset=utf-8;base64,$b64') format('truetype');
    font-weight: normal;
    font-style: normal;
}
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif !important;
}
"@
    }
}

Write-Host ""
Write-Host "[CONFIG] Active Font: " -NoNewline -ForegroundColor Cyan
Write-Host "$fontName" -ForegroundColor Yellow
Write-Host ""

# --- Step 2: Stop Running Instances ---
Write-Host "[1/4] Closing running Antigravity processes..." -ForegroundColor DarkYellow
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