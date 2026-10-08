# ==============================================================
#  Antigravity RTL & BiDi Patcher v1.1.0
#  https://github.com/MOhammaDpirouznia/antigravity-rtl
# ==============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity RTL Patcher v1.1.0"

Clear-Host
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "            ANTIGRAVITY RTL & BIDI PATCHER v1.1.0             " -ForegroundColor Cyan
Write-Host "  Automatic Right-to-Left Layout & Persian/Arabic Typography  " -ForegroundColor DarkCyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$targetDir  = "$env:LOCALAPPDATA\Programs\antigravity\resources"
$appExe     = "$env:LOCALAPPDATA\Programs\antigravity\Antigravity.exe"
$sourceAsar = Join-Path $PSScriptRoot "app.asar"
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

# --- Step 1: Interactive Font Selection ---
Write-Host "==============================================================" -ForegroundColor DarkGray
Write-Host "                  SELECT YOUR PREFERRED FONT                  " -ForegroundColor White
Write-Host "==============================================================" -ForegroundColor DarkGray
Write-Host "  [1] Vazirmatn           " -NoNewline -ForegroundColor Green
Write-Host "(Modern, Clean & Balanced) [RECOMMENDED]" -ForegroundColor Gray
Write-Host "  [2] Sahel / Shabnam     " -NoNewline -ForegroundColor Green
Write-Host "(Smooth, High Readability)" -ForegroundColor Gray
Write-Host "  [3] Windows Default     " -NoNewline -ForegroundColor Green
Write-Host "(Segoe UI / Tahoma / Arial)" -ForegroundColor Gray
Write-Host "  [4] Custom Font         " -NoNewline -ForegroundColor Green
Write-Host "(Enter any font installed on your system)" -ForegroundColor Gray
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray

$choice = Read-Host "Select font option [1-4] (Default: 1)"

$fontName = "Vazirmatn"
$cssContent = ""

switch ($choice) {
    "2" {
        $fontName = "Sahel / Shabnam"
        $cssContent = @"
/* Antigravity RTL - Sahel & Shabnam Font */
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: 'Sahel', 'Shabnam', 'Vazirmatn', 'Segoe UI', Tahoma, sans-serif !important;
}
"@
    }
    "3" {
        $fontName = "Windows System Default (Segoe UI / Tahoma)"
        $cssContent = @"
/* Antigravity RTL - Windows System Default Font */
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, Arial, sans-serif !important;
}
"@
    }
    "4" {
        Write-Host ""
        $userFont = Read-Host "Enter your font name (e.g., IRANSans, Dana, B Nazanin)"
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
        $fontName = "Vazirmatn (Default)"
        $cssContent = @"
/* Antigravity RTL - Vazirmatn Font */
body, p, li, blockquote, span, div, [class*="message"], [class*="content"] {
    font-family: 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Tahoma, sans-serif !important;
}
"@
    }
}

Write-Host ""
Write-Host "[CONFIG] Selected Font: " -NoNewline -ForegroundColor Cyan
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
Write-Host "[3/4] Installing RTL patch & configuring font style..." -ForegroundColor DarkCyan
try {
    # 4a. Copy patched app.asar
    Copy-Item -Path $sourceAsar -Destination $targetAsar -Force

    # 4b. Write dynamic custom-rtl.css
    [System.IO.File]::WriteAllText($customCss, $cssContent, [System.Text.Encoding]::UTF8)

    Write-Host "      Files written successfully." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to write files: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# --- Step 5: Launch Antigravity Completely Detached ---
Write-Host "[4/4] Launching Antigravity in standalone mode..." -ForegroundColor DarkCyan

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $appExe
$psi.UseShellExecute = $true
$psi.WorkingDirectory = (Split-Path $appExe)
[System.Diagnostics.Process]::Start($psi) | Out-Null

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "   [SUCCESS] Antigravity RTL Patch applied successfully!      " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "  * Active Font       : " -NoNewline -ForegroundColor Gray
Write-Host "$fontName" -ForegroundColor Cyan
Write-Host "  * Text Alignment    : " -NoNewline -ForegroundColor Gray
Write-Host "Real-Time Auto RTL (unicode-bidi: plaintext)" -ForegroundColor White
Write-Host "  * Code Blocks       : " -NoNewline -ForegroundColor Gray
Write-Host "Protected Left-to-Right (LTR)" -ForegroundColor White
Write-Host "  * DevTools Shortcut : " -NoNewline -ForegroundColor Gray
Write-Host "Ctrl + Shift + I" -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Note: Antigravity is now running independently." -ForegroundColor DarkGray
Write-Host "Closing this window will NOT affect the application." -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")