[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity RTL Patcher"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "       پچ خودکار راست‌چین و فونت فارسی Antigravity" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$targetDir = "$env:LOCALAPPDATA\Programs\antigravity\resources"
$appExe = "$env:LOCALAPPDATA\Programs\antigravity\Antigravity.exe"
$sourceAsar = Join-Path $PSScriptRoot "app.asar"
$targetAsar = Join-Path $targetDir "app.asar"
$backupAsar = Join-Path $targetDir "app.asar.backup"

if (-not (Test-Path $targetAsar)) {
    Write-Host "[خطا] پوشه نصب Antigravity پیدا نشد!" -ForegroundColor Red
    Write-Host "مسیر مورد نظر: $targetDir" -ForegroundColor Yellow
    Read-Host "برای خروج Enter را بزنید..."
    exit 1
}

if (-not (Test-Path $sourceAsar)) {
    Write-Host "[خطا] فایل app.asar پچ شده در کنار اسکریپت پیدا نشد!" -ForegroundColor Red
    Read-Host "برای خروج Enter را بزنید..."
    exit 1
}

# 1. Close Antigravity
Write-Host "[1/4] بستن پردازه‌های Antigravity جهت جایگزینی فایل..." -ForegroundColor Yellow
Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# 2. Backup original
if (-not (Test-Path $backupAsar)) {
    Write-Host "[2/4] ایجاد نسخه پشتیبان امن (app.asar.backup)..." -ForegroundColor Green
    Copy-Item -Path $targetAsar -Destination $backupAsar -Force
} else {
    Write-Host "[2/4] نسخه پشتیبان امن از قبل موجود است." -ForegroundColor Gray
}

# 3. Copy patched file
Write-Host "[3/4] اعمال فایل پچ شده..." -ForegroundColor Yellow
try {
    Copy-Item -Path $sourceAsar -Destination $targetAsar -Force
    Write-Host "      فایل با موفقیت جایگزین شد." -ForegroundColor Green
} catch {
    Write-Host "[خطا] کپی فایل با خطا مواجه شد: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "برای خروج Enter را بزنید..."
    exit 1
}

# 4. Relaunch Antigravity
Write-Host "[4/4] راه‌اندازی مجدد Antigravity با قابلیت جدید..." -ForegroundColor Cyan
Start-Process -FilePath $appExe

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "   ✓ پچ با موفقیت کامل اعمال شد!" -ForegroundColor Green
Write-Host "   - پیام‌های فارسی از این پس خودکار راست‌چین نمایش داده می‌شوند." -ForegroundColor White
Write-Host "   - کدها و متون انگلیسی چپ‌چین باقی می‌مانند." -ForegroundColor White
Write-Host "   - کلید Ctrl+Shift+I برای باز کردن DevTools فعال شد." -ForegroundColor White
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "این پنجره تا ۵ ثانیه دیگر به صورت خودکار بسته می‌شود..." -ForegroundColor Gray
Start-Sleep -Seconds 5