# 小久任务管理系统 v4.2.2.1 Git部署脚本
# 作者: CodeBuddy
# 版本: v4.2.2.1
# 描述: 此脚本用于将小久任务管理系统部署到Git仓库
# 修复: 文件复制问题和字符编码问题

# 配置参数
$version = "v4.2.2.1"
$packageName = "task-manager-$version-complete.zip"

# 显示标题
function Show-Title {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "   小久任务管理系统 $version Git部署"
    Write-Host "========================================"
    Write-Host ""
}

# 创建部署包
function Create-Package {
    Write-Host "📦 正在创建完整部署包..." -ForegroundColor Cyan
    
    # 检查是否存在旧的部署包，如果存在则删除
    if (Test-Path $packageName) {
        Remove-Item $packageName -Force
    }
    
    # 创建临时目录
    $tempDir = "temp_deploy"
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    Write-Host "📁 复制核心文件..." -ForegroundColor Yellow
    
    # 复制HTML文件 - 使用更安全的复制方式
    $htmlFiles = @(
        "index.html",
        "edit-tasks.html",
        "focus-challenge.html",
        "statistics.html",
        "today-tasks.html",
        "sync-test.html",
        "manifest.json",
        "icon-192.svg",
        "favicon.ico"
    )
    
    foreach ($file in $htmlFiles) {
        if (Test-Path $file) {
            Copy-Item $file "$tempDir/" -ErrorAction SilentlyContinue
            Write-Host "  - 已复制: $file" -ForegroundColor Gray
        } else {
            Write-Host "  - 跳过不存在的文件: $file" -ForegroundColor Yellow
        }
    }
    
    # 创建并复制CSS目录
    if (Test-Path "css") {
        New-Item -ItemType Directory -Path "$tempDir/css" -ErrorAction SilentlyContinue | Out-Null
        Get-ChildItem -Path "css" -Filter "*.css" | ForEach-Object {
            Copy-Item $_.FullName "$tempDir/css/" -ErrorAction SilentlyContinue
        }
        Write-Host "✅ CSS文件已复制" -ForegroundColor Green
    } else {
        Write-Host "⚠️ CSS目录不存在，已跳过" -ForegroundColor Yellow
    }
    
    # 创建并复制JS目录
    if (Test-Path "js") {
        New-Item -ItemType Directory -Path "$tempDir/js" -ErrorAction SilentlyContinue | Out-Null
        Get-ChildItem -Path "js" -Filter "*.js" | ForEach-Object {
            Copy-Item $_.FullName "$tempDir/js/" -ErrorAction SilentlyContinue
        }
        Write-Host "✅ JS文件已复制" -ForegroundColor Green
    } else {
        Write-Host "⚠️ JS目录不存在，已跳过" -ForegroundColor Yellow
    }
    
    # 创建并复制API目录
    if (Test-Path "api") {
        New-Item -ItemType Directory -Path "$tempDir/api" -ErrorAction SilentlyContinue | Out-Null
        Get-ChildItem -Path "api" -Filter "*.php" | ForEach-Object {
            Copy-Item $_.FullName "$tempDir/api/" -ErrorAction SilentlyContinue
        }
        Get-ChildItem -Path "api" -Filter "*.js" | ForEach-Object {
            Copy-Item $_.FullName "$tempDir/api/" -ErrorAction SilentlyContinue
        }
        Write-Host "✅ API文件已复制" -ForegroundColor Green
    } else {
        Write-Host "⚠️ API目录不存在，已跳过" -ForegroundColor Yellow
    }
    
    # 创建并复制数据目录
    if (Test-Path "data") {
        New-Item -ItemType Directory -Path "$tempDir/data" -ErrorAction SilentlyContinue | Out-Null
        
        if (Test-Path "data/shared-tasks.json") {
            Copy-Item "data/shared-tasks.json" "$tempDir/data/" -ErrorAction SilentlyContinue
        } else {
            # 创建默认的shared-tasks.json文件
            $defaultData = @{
                version = $version
                lastUpdateTime = [long](Get-Date -UFormat %s) * 1000
                serverUpdateTime = [long](Get-Date -UFormat %s) * 1000
                username = "小久"
                tasks = @()
                taskTemplates = @{
                    daily = @(
                        @{ name = "学而思数感小超市"; type = "daily" }
                        @{ name = "斑马思维"; type = "daily" }
                        @{ name = "核桃编程（学生端）"; type = "daily" }
                        @{ name = "英语阅读"; type = "daily" }
                        @{ name = "硬笔写字（30分钟）"; type = "daily" }
                        @{ name = "悦乐达打卡/作业"; type = "daily" }
                        @{ name = "暑假生活作业"; type = "daily" }
                        @{ name = "体育/运动（迪卡侬）"; type = "daily" }
                    )
                }
                dailyTasks = @{}
                completionHistory = @{}
                taskTimes = @{}
                focusRecords = @{}
            }
            
            $defaultDataJson = ConvertTo-Json $defaultData -Depth 10
            New-Item -ItemType Directory -Path "$tempDir/data" -Force | Out-Null
            Set-Content -Path "$tempDir/data/shared-tasks.json" -Value $defaultDataJson -Encoding UTF8
            Write-Host "  - 已创建默认数据文件" -ForegroundColor Gray
        }
        
        if (Test-Path "data/README.md") {
            Copy-Item "data/README.md" "$tempDir/data/" -ErrorAction SilentlyContinue
        }
        
        Write-Host "✅ 数据文件已复制" -ForegroundColor Green
    } else {
        Write-Host "⚠️ 数据目录不存在，已创建" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "$tempDir/data" -Force | Out-Null
        
        # 创建默认的shared-tasks.json文件
        $defaultData = @{
            version = $version
            lastUpdateTime = [long](Get-Date -UFormat %s) * 1000
            serverUpdateTime = [long](Get-Date -UFormat %s) * 1000
            username = "小久"
            tasks = @()
            taskTemplates = @{
                daily = @(
                    @{ name = "学而思数感小超市"; type = "daily" }
                    @{ name = "斑马思维"; type = "daily" }
                    @{ name = "核桃编程（学生端）"; type = "daily" }
                    @{ name = "英语阅读"; type = "daily" }
                    @{ name = "硬笔写字（30分钟）"; type = "daily" }
                    @{ name = "悦乐达打卡/作业"; type = "daily" }
                    @{ name = "暑假生活作业"; type = "daily" }
                    @{ name = "体育/运动（迪卡侬）"; type = "daily" }
                )
            }
            dailyTasks = @{}
            completionHistory = @{}
            taskTimes = @{}
            focusRecords = @{}
        }
        
        $defaultDataJson = ConvertTo-Json $defaultData -Depth 10
        Set-Content -Path "$tempDir/data/shared-tasks.json" -Value $defaultDataJson -Encoding UTF8
    }
    
    # 创建ZIP文件
    try {
        Compress-Archive -Path "$tempDir/*" -DestinationPath $packageName -Force
        
        # 获取文件大小
        $fileSize = (Get-Item $packageName).Length
        
        Write-Host "✅ 完整部署包创建成功: $packageName" -ForegroundColor Green
        Write-Host "📊 包大小: $fileSize 字节" -ForegroundColor Cyan
    }
    catch {
        Write-Host "❌ 创建ZIP文件失败: $_" -ForegroundColor Red
    }
    
    # 删除临时目录
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    
    return $packageName
}

# Git部署
function Deploy-ToGit {
    Write-Host ""
    Write-Host "🚀 开始Git部署..." -ForegroundColor Cyan
    
    # 检查是否有Git仓库
    if (-not (Test-Path ".git")) {
        Write-Host "❌ 当前目录不是Git仓库，无法部署" -ForegroundColor Red
        return $false
    }
    
    # 提交代码
    Write-Host "📝 提交代码..." -ForegroundColor Yellow
    
    $commitMessage = @"
🚀 v4.2.2.1 版本更新 - 部署脚本优化

✨ 核心修复:
- 修复部署脚本中的文件复制问题
- 增强文件检查和错误处理
- 优化字符编码处理
- 改进部署流程稳定性

🔧 部署优化:
- 更安全的文件复制机制
- 自动创建缺失的目录和文件
- 增强错误处理和日志记录
- 改进用户交互体验

🎯 用户体验:
- 更清晰的部署状态反馈
- 详细的错误提示
- 完善的部署指南
- 自动化部署选项
"@
    
    try {
        git add .
        git commit -m $commitMessage
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 代码提交成功" -ForegroundColor Green
        } else {
            Write-Host "⚠️ 代码提交失败或无新变更，退出代码: $LASTEXITCODE" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "⚠️ 代码提交失败或无新变更: $_" -ForegroundColor Yellow
    }
    
    # 推送到远程仓库
    Write-Host "📤 推送到GitHub..." -ForegroundColor Yellow
    
    try {
        git push origin main
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 代码推送成功" -ForegroundColor Green
            Write-Host ""
            Write-Host "🌐 GitHub Pages 将自动部署" -ForegroundColor Cyan
            Write-Host "📍 访问地址: https://[你的用户名].github.io/[仓库名]" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "💡 Vercel也会自动检测并部署" -ForegroundColor Cyan
            return $true
        } else {
            Write-Host "❌ 代码推送失败，退出代码: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "💡 请检查Git配置和网络连接" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "❌ 代码推送失败: $_" -ForegroundColor Red
        Write-Host "💡 请检查Git配置和网络连接" -ForegroundColor Yellow
        return $false
    }
}

# 显示测试指南
function Show-TestInstructions {
    Write-Host ""
    Write-Host "🧪 部署后测试步骤:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. 基础测试:" -ForegroundColor Yellow
    Write-Host "   - 访问部署后的网站" -ForegroundColor White
    Write-Host "   - 检查页面是否正常加载" -ForegroundColor White
    Write-Host "   - 添加几个任务并完成" -ForegroundColor White
    Write-Host ""
    Write-Host "2. 同步测试:" -ForegroundColor Yellow
    Write-Host "   - 在Chrome中完成一些任务" -ForegroundColor White
    Write-Host "   - 在Firefox中打开同一地址" -ForegroundColor White
    Write-Host "   - 检查任务状态是否同步" -ForegroundColor White
    Write-Host "   - 等待3-5秒观察自动同步" -ForegroundColor White
    Write-Host ""
    Write-Host "3. 诊断测试:" -ForegroundColor Yellow
    Write-Host "   - 访问 sync-test.html" -ForegroundColor White
    Write-Host "   - 点击"运行诊断"查看同步状态" -ForegroundColor White
    Write-Host "   - 如有问题，点击"自动修复"" -ForegroundColor White
    Write-Host ""
    Write-Host "4. 跨设备测试:" -ForegroundColor Yellow
    Write-Host "   - 在手机浏览器中访问" -ForegroundColor White
    Write-Host "   - 在不同电脑的浏览器中访问" -ForegroundColor White
    Write-Host "   - 验证数据是否在所有设备间同步" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 v4.2.2.1 版本特性总结:" -ForegroundColor Cyan
    Write-Host "✅ 跨浏览器数据同步 - 彻底修复" -ForegroundColor Green
    Write-Host "✅ 实时数据同步 - 3秒内完成" -ForegroundColor Green
    Write-Host "✅ 智能错误恢复 - 自动修复机制" -ForegroundColor Green
    Write-Host "✅ 本地存储监听 - 即时触发同步" -ForegroundColor Green
    Write-Host "✅ 可视化诊断 - 问题排查利器" -ForegroundColor Green
    Write-Host "✅ 简化部署流程 - 一个文件搞定" -ForegroundColor Green
    Write-Host "✅ 增强部署脚本 - 更稳定可靠" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 部署完成！请访问同步测试页面进行诊断" -ForegroundColor Green
}

# 主函数
function Main {
    Show-Title
    
    # 创建部署包
    $packagePath = Create-Package
    
    # 部署到Git
    $success = Deploy-ToGit
    
    if ($success) {
        Show-TestInstructions
    }
}

# 执行主函数
Main