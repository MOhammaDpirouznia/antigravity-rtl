# ========================================================
# Antigravity RTL Auto-Patcher (PowerShell)
# مناسب برای آپدیت‌های آینده یا شخصی‌سازی بیشتر
# ========================================================

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   اسکریپت خودکار پچ راست‌چین Antigravity (مخصوص آپدیت‌ها)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$appPath = "$env:LOCALAPPDATA\Programs\antigravity"
$resourcesPath = "$appPath\resources"
$asarPath = "$resourcesPath\app.asar"
$backupPath = "$resourcesPath\app.asar.backup"
$tempExtractDir = "$env:TEMP\antigravity_asar_patch"

if (-not (Test-Path $asarPath)) {
    Write-Host "[خطا] برنامه Antigravity در مسیر پیش‌فرض یافت نشد:" -ForegroundColor Red
    Write-Host $asarPath -ForegroundColor Yellow
    Exit 1
}

# 1. Close Antigravity if running
Write-Host "`n[1/5] بستن Antigravity..." -ForegroundColor Yellow
Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# 2. Backup
if (-not (Test-Path $backupPath)) {
    Write-Host "[2/5] ایجاد بکاپ از نسخه فعلی..." -ForegroundColor Green
    Copy-Item $asarPath $backupPath
} else {
    Write-Host "[2/5] فایل بکاپ موجود است." -ForegroundColor Gray
}

# 3. Extract asar
Write-Host "[3/5] استخراج پکیج app.asar..." -ForegroundColor Yellow
if (Test-Path $tempExtractDir) { Remove-Item -Recurse -Force $tempExtractDir }
npx --yes @electron/asar extract $asarPath $tempExtractDir

# 4. Modify preload.js & keybindings.js
Write-Host "[4/5] تزریق کدهای راست‌چین هوشمند..." -ForegroundColor Green
$preloadPath = "$tempExtractDir\dist\preload.js"
$keybindingsPath = "$tempExtractDir\dist\keybindings.js"

$rtlInjection = @"

// ==========================================
// Antigravity RTL & Persian Typography Patch
// ==========================================
(function initAntigravityRtlPatch() {
    try {
        function injectStyles() {
            if (typeof document === 'undefined' || !document.head) return;
            if (document.getElementById('antigravity-rtl-styles')) return;

            const style = document.createElement('style');
            style.id = 'antigravity-rtl-styles';
            style.textContent = ``
                p, li, blockquote, dt, dd,
                h1, h2, h3, h4, h5, h6,
                [class*="message"], [class*="content"], [class*="prose"],
                [class*="bubble"], [class*="text"] {
                    unicode-bidi: plaintext !important;
                    text-align: start !important;
                }
                [dir="rtl"] {
                    text-align: right !important;
                    direction: rtl !important;
                }
                [dir="ltr"] {
                    text-align: left !important;
                    direction: ltr !important;
                }
                li[dir="rtl"]::marker {
                    unicode-bidi: isolate;
                }
                pre, code, kbd, samp,
                pre *, code *,
                [class*="code"], [class*="terminal"], [class*="syntax"],
                [class*="monaco"], [class*="xterm"],
                table, thead, tbody, th, td {
                    direction: ltr !important;
                    text-align: left !important;
                    unicode-bidi: isolate !important;
                }
                textarea, input[type="text"], [contenteditable="true"] {
                    unicode-bidi: plaintext !important;
                    text-align: start !important;
                }
                body, p, li, blockquote, span, div {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Vazirmatn", "IRANSans", Tahoma, Roboto, Helvetica, Arial, sans-serif;
                }
                p, li {
                    line-height: 1.8 !important;
                }
            ``;
            document.head.appendChild(style);
        }

        function autoDir(node) {
            if (!node || node.nodeType !== 1) return;
            const tag = node.tagName ? node.tagName.toLowerCase() : '';
            if (tag === 'p' || tag === 'li' || tag === 'blockquote' || /^h[1-6]$/.test(tag)) {
                if (!node.hasAttribute('dir')) {
                    node.setAttribute('dir', 'auto');
                }
            }
            if (node.children && node.children.length > 0) {
                const targets = node.querySelectorAll('p:not([dir]), li:not([dir]), blockquote:not([dir]), h1:not([dir]), h2:not([dir]), h3:not([dir]), h4:not([dir]), h5:not([dir]), h6:not([dir])');
                for (let i = 0; i < targets.length; i++) {
                    targets[i].setAttribute('dir', 'auto');
                }
            }
        }

        function run() {
            injectStyles();
            if (document.body) autoDir(document.body);
            const observer = new MutationObserver((mutations) => {
                injectStyles();
                for (const mutation of mutations) {
                    for (const added of mutation.addedNodes) {
                        if (added.nodeType === 1) autoDir(added);
                    }
                }
            });
            const target = document.body || document.documentElement;
            if (target) observer.observe(target, { childList: true, subtree: true });
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', run);
        } else {
            run();
        }
    } catch (e) {
        console.error('Antigravity RTL patch error:', e);
    }
})();
"@

if (Test-Path $preloadPath) {
    Add-Content -Path $preloadPath -Value $rtlInjection
}

# 5. Repack asar
Write-Host "[5/5] ساخت مجدد app.asar و جایگزینی..." -ForegroundColor Yellow
npx --yes @electron/asar pack $tempExtractDir $asarPath --unpack-dir "node_modules/chrome-devtools-mcp"

# Cleanup
Remove-Item -Recurse -Force $tempExtractDir

# Relaunch
Start-Process "$appPath\Antigravity.exe"

Write-Host "`n✓ عملیات با موفقیت پایان یافت و برنامه باز شد!" -ForegroundColor Green
