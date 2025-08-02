# 小久任务管理系统 v4.2.2.1 部署目录整理脚本
# 作者: CodeBuddy
# 版本: v4.2.2.1
# 描述: 此脚本用于整理部署目录，将历史文件移动到history子目录

# 显示标题
Write-Host ""
Write-Host "========================================"
Write-Host "   整理部署目录 - 移动历史文件到history"
Write-Host "========================================"
Write-Host ""

# 确保history目录存在
$historyDir = "history"
if (-not (Test-Path $historyDir)) {
    New-Item -ItemType Directory -Path $historyDir | Out-Null
    Write-Host "✅ 创建history目录" -ForegroundColor Green
}

Write-Host "正在移动历史文件到history目录..." -ForegroundColor Cyan

# 需要保留的文件列表
$keepFiles = @(
    "deploy-v4.2.2.1.ps1",
    "部署到服务器-v4.2.2.1.bat",
    "一键部署-v4.2.2.1.bat",
    "快速部署-v4.2.2.1.bat",
    "Git部署-v4.2.2.1.bat",
    "git-deploy-v4.2.2.1.ps1",
    "部署指南-v4.2.2.1.md",
    "README.md",
    "整理部署目录-v4.2.2.1.ps1",
    "整理部署目录-v4.2.2.1.bat",
    "history"
)

# 获取当前目录中的所有文件和目录
$allItems = Get-ChildItem -Path "." -Force

# 移动不在保留列表中的文件到history目录
foreach ($item in $allItems) {
    if ($keepFiles -notcontains $item.Name) {
        try {
            # 如果是目录且不是history目录，则递归移动其内容
            if ($item.PSIsContainer -and $item.Name -ne "history") {
                $targetDir = Join-Path -Path $historyDir -ChildPath $item.Name
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir | Out-Null
                }
                
                # 复制目录内容
                Copy-Item -Path "$($item.FullName)\*" -Destination $targetDir -Recurse -Force
                
                # 删除原目录
                Remove-Item -Path $item.FullName -Recurse -Force
                
                Write-Host "  - 已移动目录: $($item.Name)" -ForegroundColor Gray
            }
            # 如果是文件，直接移动
            else {
                Move-Item -Path $item.FullName -Destination $historyDir -Force
                Write-Host "  - 已移动文件: $($item.Name)" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  - 移动失败: $($item.Name) - $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "保留以下必要文件:" -ForegroundColor Yellow
foreach ($file in $keepFiles) {
    Write-Host "- $file" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ 整理完成！" -ForegroundColor Green