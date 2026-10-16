# ==============================================================
#  Antigravity RTL & Proxy Patcher v1.4.0
#  https://github.com/MOhammaDpirouznia/antigravity-rtl
# ==============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity RTL & Proxy Patcher v1.4.0"

Clear-Host
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "         ANTIGRAVITY RTL & PROXY PATCHER v1.4.0               " -ForegroundColor Cyan
Write-Host "   RTL Layout, Persian Typography & Smart Proxy Manager       " -ForegroundColor DarkCyan
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

# --- Step 3: Interactive Proxy Configuration (Smart Auto-Detection) ---
Write-Host "==============================================================" -ForegroundColor DarkGray
Write-Host "             PROXY CONFIGURATION (SMART DETECTION)            " -ForegroundColor White
Write-Host "==============================================================" -ForegroundColor DarkGray

# Fast scanning of listening proxy ports
$candidatePorts = @(10808, 10809, 7890, 7897, 2080, 2081, 1080)
$detectedPort = $null
$detectedProcess = $null

try {
    $connections = Get-NetTCPConnection -State Listen -LocalAddress 127.0.0.1 -ErrorAction SilentlyContinue |
                   Where-Object { $_.LocalPort -in $candidatePorts }
    if ($connections) {
        $firstConn = $connections[0]
        $detectedPort = $firstConn.LocalPort
        $proc = Get-Process -Id $firstConn.OwningProcess -ErrorAction SilentlyContinue
        if ($proc) { $detectedProcess = $proc.ProcessName }
    }
} catch {}

if ($detectedPort) {
    Write-Host "  [AUTO-DETECTED] Active local proxy found on port " -NoNewline -ForegroundColor Green
    Write-Host "$detectedPort" -NoNewline -ForegroundColor Yellow
    if ($detectedProcess) {
        Write-Host " ($detectedProcess)" -ForegroundColor DarkCyan
    } else {
        Write-Host ""
    }
} else {
    Write-Host "  [NOTICE] No active local proxy detected on standard ports." -ForegroundColor DarkGray
}

Write-Host "  [1] Antigravity Only (Isolated)" -NoNewline -ForegroundColor Green
Write-Host " - Only Antigravity uses proxy; Windows stays direct [DEFAULT]" -ForegroundColor Gray
Write-Host "  [2] Full Dev Mode (CLI & System)" -NoNewline -ForegroundColor Green
Write-Host " - Antigravity + Git, Python, Pip, Curl, Npm" -ForegroundColor Gray
Write-Host "  [3] Direct Connection (No Proxy)" -NoNewline -ForegroundColor Green
Write-Host " - Disable proxy completely" -ForegroundColor Gray
Write-Host "  [4] Custom Port & Mode" -NoNewline -ForegroundColor Green
Write-Host " - Specify custom port manually" -ForegroundColor Gray
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray

$proxyChoice = Read-Host "Select proxy option [1-4] (Press Enter for Antigravity Only with detected/default port)"

$proxyPort = if ($detectedPort) { $detectedPort } else { 10808 }
$proxyMode = "app_only"
$proxyEnabled = $true
$proxyLabel = "Antigravity Only (Port $proxyPort)"

switch ($proxyChoice) {
    "2" {
        $proxyMode = "full_dev"
        $proxyLabel = "Full Dev Mode (Antigravity + CLI & Tools on Port $proxyPort)"
        try {
            [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://127.0.0.1:$proxyPort", "User")
            [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "http://127.0.0.1:$proxyPort", "User")
        } catch {}
    }
    "3" {
        $proxyMode = "disabled"
        $proxyEnabled = $false
        $proxyLabel = "Direct Connection (Proxy Disabled)"
        try {
            [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $null, "User")
            [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $null, "User")
        } catch {}
    }
    "4" {
        Write-Host ""
        $userPortInput = Read-Host "Enter your proxy port (e.g. 10808, 7890, 2080)"
        if ($userPortInput -match '^\d+$') {
            $proxyPort = [int]$userPortInput
        }
        $modeChoice = Read-Host "Select mode: [1] Antigravity Only (Default), [2] Full Dev (System/CLI)"
        if ($modeChoice -eq "2") {
            $proxyMode = "full_dev"
            $proxyLabel = "Full Dev Mode (Antigravity + CLI on Port $proxyPort)"
            try {
                [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://127.0.0.1:$proxyPort", "User")
                [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "http://127.0.0.1:$proxyPort", "User")
            } catch {}
        } else {
            $proxyMode = "app_only"
            $proxyLabel = "Antigravity Only (Port $proxyPort)"
            try {
                [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $null, "User")
                [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $null, "User")
            } catch {}
        }
    }
    Default {
        $proxyMode = "app_only"
        $proxyLabel = "Antigravity Only (Isolated on Port $proxyPort)"
        try {
            [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", $null, "User")
            [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", $null, "User")
        } catch {}
    }
}

$proxyConfigJson = @"
{
  "enabled": $($proxyEnabled.ToString().ToLower()),
  "mode": "$proxyMode",
  "port": $proxyPort,
  "host": "127.0.0.1"
}
"@

Write-Host ""
Write-Host "[CONFIG] Active Proxy : " -NoNewline -ForegroundColor Cyan
Write-Host "$proxyLabel" -ForegroundColor Yellow
Write-Host ""

# --- Step 4: Stop Running Instances & Purge Stale Auto-Updates ---
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

# --- Step 5: Apply Patched Package & Write Configurations ---
Write-Host "[3/4] Installing RTL patch, embedding font & writing proxy config..." -ForegroundColor DarkCyan
try {
    # 5a. Copy patched app.asar
    Copy-Item -Path $sourceAsar -Destination $targetAsar -Force

    # 5b. Write dynamic custom-rtl.css with embedded font
    [System.IO.File]::WriteAllText($customCss, $cssContent, [System.Text.Encoding]::UTF8)

    # 5c. Write proxy-config.json
    $targetProxyConfig = Join-Path $targetDir "proxy-config.json"
    [System.IO.File]::WriteAllText($targetProxyConfig, $proxyConfigJson, [System.Text.Encoding]::UTF8)

    # 5d. Copy fonts directory for reference
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

# --- Step 6: Launch Antigravity 100% Detached (No Console Hijack) ---
Write-Host "[4/4] Launching Antigravity in detached background mode..." -ForegroundColor DarkCyan

# Launching via 'cmd /c start' completely decouples Antigravity from this console window
Start-Process -FilePath "cmd.exe" -ArgumentList "/c start `"`" `"$appExe`"" -WindowStyle Hidden

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "   [SUCCESS] Antigravity RTL & Proxy Patch applied!           " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "  * Active Font       : " -NoNewline -ForegroundColor Gray
Write-Host "$fontName (Embedded)" -ForegroundColor Cyan
Write-Host "  * IDE Layout        : " -NoNewline -ForegroundColor Gray
Write-Host "$layoutName" -ForegroundColor Cyan
Write-Host "  * Proxy Mode        : " -NoNewline -ForegroundColor Gray
Write-Host "$proxyLabel" -ForegroundColor Cyan
Write-Host "  * In-App Proxy Menu : " -NoNewline -ForegroundColor Gray
Write-Host "Top-Bar Menu > Proxy 🌐 (Switch modes anytime!)" -ForegroundColor Yellow
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