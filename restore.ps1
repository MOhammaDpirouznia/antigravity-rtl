[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity Restore Original"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "      بازگردانی Antigravity به حالت اولیه (پیش‌فرض)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$targetDir = "$env:LOCALAPPDATA\Programs\antigravity\resources"
$appExe = "$env:LOCALAPPDATA\Programs\antigravity\Antigravity.exe"
$targetAsar = Join-Path $targetDir "app.asar"
$backupAsar = Join-Path $targetDir "app.asar.backup"

if (-not (Test-Path $backupAsar)) {
    Write-Host "[خطا] فایل بکاپ پیدا نشد: $backupAsar" -ForegroundColor Red
    Read-Host "برای خروج Enter را بزنید..."
    exit 1
}

Write-Host "[1/3] بستن پردازه‌های Antigravity..." -ForegroundColor Yellow
Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "[2/3] بازگردانی فایل اصلی برنامه از نسخه پشتیبان..." -ForegroundColor Yellow
try {
    Copy-Item -Path $backupAsar -Destination $targetAsar -Force
    Write-Host "      فایل اصلی بازگردانده شد." -ForegroundColor Green
} catch {
    Write-Host "[خطا] بازگردانی ناموفق بود: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "برای خروج Enter را بزنید..."
    exit 1
}

Write-Host "[3/3] راه‌اندازی مجدد Antigravity..." -ForegroundColor Cyan
Start-Process -FilePath $appExe

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "   ✓ برنامه با موفقیت به حالت اولیه بازگردانده شد." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "این پنجره تا ۵ ثانیه دیگر به صورت خودکار بسته می‌شود..." -ForegroundColor Gray
Start-Sleep -Seconds 5