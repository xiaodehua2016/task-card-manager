# 小久任务管理系统 v4.2.2.1 项目文件整理脚本
# 作者: CodeBuddy
# 版本: v4.2.2.1
# 描述: 此脚本用于整理项目文件，将不必要的文件移动到DEPLOY\HISTORY目录

# 显示标题
Write-Host ""
Write-Host "========================================"
Write-Host "   整理项目文件 - 移动不必要文件到DEPLOY\HISTORY"
Write-Host "========================================"
Write-Host ""

# 确保DEPLOY\HISTORY目录存在
$historyDir = "DEPLOY\HISTORY"
if (-not (Test-Path $historyDir)) {
    New-Item -ItemType Directory -Path $historyDir -Force | Out-Null
    Write-Host "✅ 创建DEPLOY\HISTORY目录" -ForegroundColor Green
}

Write-Host "正在移动不必要的文件到DEPLOY\HISTORY目录..." -ForegroundColor Cyan

# 需要保留的核心文件列表
$keepFiles = @(
    "index.html",
    "edit-tasks.html",
    "focus-challenge.html",
    "statistics.html",
    "today-tasks.html",
    "sync-test.html",
    "manifest.json",
    "icon-192.svg",
    ".gitignore",
    "package.json",
    "vercel.json",
    "README.md",
    "整理项目文件.ps1",
    "整理项目文件.bat"
)

# 需要保留的核心目录列表
$keepDirs = @(
    "css",
    "js",
    "api",
    "data",
    "deploy",
    ".git",
    ".github",
    ".vercel",
    "DEPLOY",
    ".codebuddy"
)

# 移动不必要的文件到DEPLOY\HISTORY目录
Get-ChildItem -Path "." -File | ForEach-Object {
    if ($keepFiles -notcontains $_.Name) {
        try {
            Move-Item -Path $_.FullName -Destination $historyDir -Force -ErrorAction SilentlyContinue
            Write-Host "  - 已移动文件: $($_.Name)" -ForegroundColor Gray
        }
        catch {
            Write-Host "  - 移动失败: $($_.Name) - $_" -ForegroundColor Red
        }
    }
}

# 移动不必要的目录到DEPLOY\HISTORY目录
Get-ChildItem -Path "." -Directory | ForEach-Object {
    if ($keepDirs -notcontains $_.Name) {
        try {
            # 创建目标目录
            $targetDir = Join-Path -Path $historyDir -ChildPath $_.Name
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            # 复制目录内容
            Copy-Item -Path "$($_.FullName)\*" -Destination $targetDir -Recurse -Force -ErrorAction SilentlyContinue
            
            # 删除原目录
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            
            Write-Host "  - 已移动目录: $($_.Name)" -ForegroundColor Gray
        }
        catch {
            Write-Host "  - 移动失败: $($_.Name) - $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "保留以下核心文件和目录:" -ForegroundColor Yellow
Write-Host "- HTML文件: index.html, edit-tasks.html, focus-challenge.html, statistics.html, today-tasks.html, sync-test.html" -ForegroundColor White
Write-Host "- 配置文件: manifest.json, icon-192.svg, .gitignore, package.json, vercel.json" -ForegroundColor White
Write-Host "- 文档文件: README.md" -ForegroundColor White
Write-Host "- 核心目录: css/, js/, api/, data/, deploy/ (已整理)" -ForegroundColor White
Write-Host "- 系统目录: .git/, .github/, .vercel/, .codebuddy/" -ForegroundColor White
Write-Host ""

Write-Host "✅ 整理完成！" -ForegroundColor Green