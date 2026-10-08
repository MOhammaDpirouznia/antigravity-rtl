# ==============================================================
#  Antigravity RTL - Factory Restore v1.1.0
#  https://github.com/MOhammaDpirouznia/antigravity-rtl
# ==============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity RTL - Factory Restore"

Clear-Host
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Yellow
Write-Host "            ANTIGRAVITY RTL - FACTORY RESTORE                 " -ForegroundColor Yellow
Write-Host "         Revert to Stock / Original Antigravity               " -ForegroundColor DarkYellow
Write-Host "==============================================================" -ForegroundColor Yellow
Write-Host ""

$targetDir  = "$env:LOCALAPPDATA\Programs\antigravity\resources"
$appExe     = "$env:LOCALAPPDATA\Programs\antigravity\Antigravity.exe"
$targetAsar = Join-Path $targetDir "app.asar"
$backupAsar = Join-Path $targetDir "app.asar.backup"
$customCss  = Join-Path $targetDir "custom-rtl.css"

# Check backup
if (-not (Test-Path $backupAsar)) {
    Write-Host "[ERROR] Original backup file not found at:" -ForegroundColor Red
    Write-Host "        $backupAsar" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "No backup file is available to restore." -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 1. Close Antigravity
Write-Host "[1/3] Closing running Antigravity processes..." -ForegroundColor DarkYellow
$running = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue
if ($running) {
    $running | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "      Processes closed successfully." -ForegroundColor Gray
} else {
    Write-Host "      No active Antigravity process found." -ForegroundColor Gray
}

# 2. Restore backup
Write-Host "[2/3] Restoring original factory app.asar..." -ForegroundColor DarkCyan
try {
    Copy-Item -Path $backupAsar -Destination $targetAsar -Force
    if (Test-Path $customCss) {
        Remove-Item -Path $customCss -Force -ErrorAction SilentlyContinue
    }
    Write-Host "      Factory files restored successfully." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to restore backup: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 3. Relaunch detached
Write-Host "[3/3] Launching Antigravity in standalone mode..." -ForegroundColor DarkCyan

Start-Process -FilePath "cmd.exe" -ArgumentList "/c start `"`" `"$appExe`"" -WindowStyle Hidden

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "   [SUCCESS] Original factory state restored successfully!    " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Antigravity has been reset to its default unpatched state." -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")