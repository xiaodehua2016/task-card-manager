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

# 移动不必要的文档文件
$filesToMove = @(
    "项目状态总结-v4.2.2.md",
    "CHANGELOG.md",
    "CODE_REVIEW_FINAL.md",
    "CODE_REVIEW_v4.2.0.md",
    "PROJECT_STATUS.md",
    "PROJECT_SUMMARY.md",
    "RELEASE_STATUS_FINAL.md",
    "task-manager-v4.1.0.tar.gz",
    "task-manager-v4.2.2-complete.zip"
)

foreach ($file in $filesToMove) {
    if (Test-Path $file) {
        try {
            Move-Item -Path $file -Destination $historyDir -Force
            Write-Host "  - 已移动文件: $file" -ForegroundColor Gray
        }
        catch {
            Write-Host "  - 移动失败: $file - $_" -ForegroundColor Red
        }
    }
}

# 移动不必要的目录
$dirsToMove = @(
    "config",
    "docs",
    "installenv"
)

foreach ($dir in $dirsToMove) {
    if (Test-Path $dir) {
        try {
            # 创建目标目录
            $targetDir = Join-Path -Path $historyDir -ChildPath $dir
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            # 复制目录内容
            Copy-Item -Path "$dir\*" -Destination $targetDir -Recurse -Force
            
            # 删除原目录
            Remove-Item -Path $dir -Recurse -Force
            
            Write-Host "  - 已移动目录: $dir" -ForegroundColor Gray
        }
        catch {
            Write-Host "  - 移动失败: $dir - $_" -ForegroundColor Red
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