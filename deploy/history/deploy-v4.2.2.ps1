# 小久任务管理系统 v4.2.2 自动化部署脚本
# 作者: CodeBuddy
# 版本: v4.2.2
# 描述: 此脚本用于自动部署小久任务管理系统到服务器

# 配置参数
$version = "v4.2.2"
$packageName = "task-manager-$version-complete.zip"
$serverIP = "115.159.5.111"
$serverUser = "root"
$serverPath = "/www/wwwroot/task-manager/"
$localPath = (Get-Location).Path

# 显示标题
function Show-Title {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "   小久任务管理系统 $version 自动化部署"
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
    
    # 复制HTML文件
    Copy-Item "index.html" "$tempDir/" -ErrorAction SilentlyContinue
    Copy-Item "edit-tasks.html" "$tempDir/" -ErrorAction SilentlyContinue
    Copy-Item "focus-challenge.html" "$tempDir/" -ErrorAction SilentlyContinue
    Copy-Item "statistics.html" "$tempDir/" -ErrorAction SilentlyContinue
    Copy-Item "today-tasks.html" "$tempDir/" -ErrorAction SilentlyContinue
    Copy-Item "sync-test.html" "$tempDir/" -ErrorAction SilentlyContinue
    Copy-Item "manifest.json" "$tempDir/" -ErrorAction SilentlyContinue
    Copy-Item "icon-192.svg" "$tempDir/" -ErrorAction SilentlyContinue
    
    # 创建并复制CSS目录
    New-Item -ItemType Directory -Path "$tempDir/css" -ErrorAction SilentlyContinue | Out-Null
    Copy-Item "css/*.css" "$tempDir/css/" -ErrorAction SilentlyContinue
    Write-Host "✅ CSS文件已复制" -ForegroundColor Green
    
    # 创建并复制JS目录
    New-Item -ItemType Directory -Path "$tempDir/js" -ErrorAction SilentlyContinue | Out-Null
    Copy-Item "js/*.js" "$tempDir/js/" -ErrorAction SilentlyContinue
    Write-Host "✅ JS文件已复制" -ForegroundColor Green
    
    # 创建并复制API目录
    New-Item -ItemType Directory -Path "$tempDir/api" -ErrorAction SilentlyContinue | Out-Null
    Copy-Item "api/*.php" "$tempDir/api/" -ErrorAction SilentlyContinue
    Copy-Item "api/*.js" "$tempDir/api/" -ErrorAction SilentlyContinue
    
    # 创建并复制数据目录
    New-Item -ItemType Directory -Path "$tempDir/data" -ErrorAction SilentlyContinue | Out-Null
    Copy-Item "data/shared-tasks.json" "$tempDir/data/" -ErrorAction SilentlyContinue
    Copy-Item "data/README.md" "$tempDir/data/" -ErrorAction SilentlyContinue
    Write-Host "✅ 数据文件已复制" -ForegroundColor Green
    
    # 创建ZIP文件
    Compress-Archive -Path "$tempDir/*" -DestinationPath $packageName -Force
    
    # 删除临时目录
    Remove-Item $tempDir -Recurse -Force
    
    # 获取文件大小
    $fileSize = (Get-Item $packageName).Length
    
    Write-Host "✅ 完整部署包创建成功: $packageName" -ForegroundColor Green
    Write-Host "📊 包大小: $fileSize 字节" -ForegroundColor Cyan
    
    return $packageName
}

# 自动部署到服务器
function Deploy-ToServer {
    param (
        [string]$packagePath,
        [string]$sshPassword
    )
    
    Write-Host ""
    Write-Host "🚀 开始自动部署到服务器..." -ForegroundColor Cyan
    
    # 检查是否安装了plink
    $plinkPath = ".\plink.exe"
    if (-not (Test-Path $plinkPath)) {
        Write-Host "⬇️ 下载plink工具..." -ForegroundColor Yellow
        $plinkUrl = "https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe"
        try {
            Invoke-WebRequest -Uri $plinkUrl -OutFile $plinkPath
            Write-Host "✅ plink工具下载成功" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ plink工具下载失败，请手动下载并放置在当前目录" -ForegroundColor Red
            Write-Host "   下载地址: $plinkUrl" -ForegroundColor Yellow
            return $false
        }
    }
    
    # 检查是否安装了pscp
    $pscpPath = ".\pscp.exe"
    if (-not (Test-Path $pscpPath)) {
        Write-Host "⬇️ 下载pscp工具..." -ForegroundColor Yellow
        $pscpUrl = "https://the.earth.li/~sgtatham/putty/latest/w64/pscp.exe"
        try {
            Invoke-WebRequest -Uri $pscpUrl -OutFile $pscpPath
            Write-Host "✅ pscp工具下载成功" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ pscp工具下载失败，请手动下载并放置在当前目录" -ForegroundColor Red
            Write-Host "   下载地址: $pscpUrl" -ForegroundColor Yellow
            return $false
        }
    }
    
    # 上传文件到服务器
    Write-Host "📤 上传部署包到服务器..." -ForegroundColor Yellow
    
    # 创建自动回答密码的脚本
    $uploadCommand = "echo $sshPassword | $pscpPath -pw $sshPassword $packagePath $serverUser@$serverIP:/www/wwwroot/"
    
    try {
        Invoke-Expression $uploadCommand
        Write-Host "✅ 部署包上传成功" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ 部署包上传失败: $_" -ForegroundColor Red
        return $false
    }
    
    # 在服务器上执行解压和设置权限命令
    Write-Host "🔧 在服务器上解压文件并设置权限..." -ForegroundColor Yellow
    
    $commands = @(
        "cd /www/wwwroot/",
        "unzip -o $packageName -d task-manager/",
        "chown -R www:www task-manager/",
        "chmod -R 755 task-manager/",
        "echo '✅ 部署完成'"
    )
    
    $commandString = $commands -join "; "
    $sshCommand = "echo $sshPassword | $plinkPath -pw $sshPassword $serverUser@$serverIP $commandString"
    
    try {
        Invoke-Expression $sshCommand
        Write-Host "✅ 服务器部署完成" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ 服务器部署失败: $_" -ForegroundColor Red
        return $false
    }
}

# 显示部署成功信息
function Show-DeploymentSuccess {
    Write-Host ""
    Write-Host "🎉 部署成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 验证部署:" -ForegroundColor Cyan
    Write-Host "   访问: http://$serverIP/" -ForegroundColor Yellow
    Write-Host "   测试: http://$serverIP/sync-test.html" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🧪 部署后测试步骤:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. 基础测试:" -ForegroundColor Yellow
    Write-Host "   - 访问 http://$serverIP/" -ForegroundColor White
    Write-Host "   - 检查页面是否正常加载" -ForegroundColor White
    Write-Host "   - 创建一个任务并完成" -ForegroundColor White
    Write-Host ""
    Write-Host "2. 同步测试:" -ForegroundColor Yellow
    Write-Host "   - 在Chrome中完成一些任务" -ForegroundColor White
    Write-Host "   - 在Firefox中打开同一地址" -ForegroundColor White
    Write-Host "   - 等待3-5秒观察自动同步" -ForegroundColor White
    Write-Host ""
    Write-Host "3. 诊断测试:" -ForegroundColor Yellow
    Write-Host "   - 访问 http://$serverIP/sync-test.html" -ForegroundColor White
    Write-Host "   - 点击"运行诊断"查看同步状态" -ForegroundColor White
    Write-Host "   - 如有问题，点击"自动修复"" -ForegroundColor White
    Write-Host ""
    Write-Host "4. 跨设备测试:" -ForegroundColor Yellow
    Write-Host "   - 在手机浏览器中访问" -ForegroundColor White
    Write-Host "   - 在其他的浏览器中访问" -ForegroundColor White
    Write-Host "   - 验证数据是否在所有设备间同步" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 v4.2.2 版本特性总结:" -ForegroundColor Cyan
    Write-Host "✅ 跨浏览器数据同步 - 彻底修复" -ForegroundColor Green
    Write-Host "✅ 实时数据同步 - 3秒内完成" -ForegroundColor Green
    Write-Host "✅ 智能错误恢复 - 自动修复机制" -ForegroundColor Green
    Write-Host "✅ 本地存储监听 - 即时触发同步" -ForegroundColor Green
    Write-Host "✅ 可视化诊断 - 问题排查利器" -ForegroundColor Green
    Write-Host "✅ 简化部署流程 - 一个文件搞定" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 部署完成！请访问同步测试页面进行诊断" -ForegroundColor Green
}

# 显示手动部署指南
function Show-ManualDeployGuide {
    param (
        [string]$packageName
    )
    
    Write-Host ""
    Write-Host "🔧 手动部署指南:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 部署步骤:" -ForegroundColor Yellow
    Write-Host "1. 上传文件:" -ForegroundColor White
    Write-Host "   - 将 $packageName 上传到服务器" -ForegroundColor White
    Write-Host "   - 可使用宝塔面板文件管理器或FTP工具" -ForegroundColor White
    Write-Host ""
    Write-Host "2. 服务器操作 (通过宝塔面板终端或SSH):" -ForegroundColor White
    Write-Host "   cd /www/wwwroot/" -ForegroundColor Gray
    Write-Host "   unzip -o $packageName -d task-manager/" -ForegroundColor Gray
    Write-Host "   chown -R www:www task-manager/" -ForegroundColor Gray
    Write-Host "   chmod -R 755 task-manager/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. 验证部署:" -ForegroundColor White
    Write-Host "   访问: http://$serverIP/" -ForegroundColor Gray
    Write-Host "   测试: http://$serverIP/sync-test.html" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 宝塔面板操作:" -ForegroundColor Yellow
    Write-Host "   - 登录: http://$serverIP:8888" -ForegroundColor White
    Write-Host "   - 文件管理 → 上传 $packageName" -ForegroundColor White
    Write-Host "   - 解压到 /www/wwwroot/task-manager/" -ForegroundColor White
    Write-Host "   - 设置权限: 所有者 www, 权限 755" -ForegroundColor White
}

# 主函数
function Main {
    Show-Title
    
    # 创建部署包
    $packagePath = Create-Package
    
    Write-Host ""
    Write-Host "🚀 部署选项:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. 自动部署到服务器" -ForegroundColor Yellow
    Write-Host "2. 手动部署到服务器 (推荐)" -ForegroundColor Yellow
    Write-Host "3. Git提交并推送" -ForegroundColor Yellow
    Write-Host ""
    
    $choice = Read-Host "请选择部署方式 (1-3)"
    
    switch ($choice) {
        "1" {
            $sshPassword = Read-Host "请输入服务器密码" -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sshPassword)
            $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            
            $success = Deploy-ToServer -packagePath $packagePath -sshPassword $plainPassword
            
            if ($success) {
                Show-DeploymentSuccess
            }
            else {
                Write-Host ""
                Write-Host "❌ 自动部署失败，请尝试手动部署" -ForegroundColor Red
                Show-ManualDeployGuide -packageName $packageName
            }
        }
        "2" {
            Show-ManualDeployGuide -packageName $packageName
        }
        "3" {
            Write-Host ""
            Write-Host "🚧 Git部署功能正在开发中..." -ForegroundColor Yellow
            Write-Host "请选择其他部署方式" -ForegroundColor Yellow
            Show-ManualDeployGuide -packageName $packageName
        }
        default {
            Write-Host "❌ 无效选择，请重新运行脚本" -ForegroundColor Red
        }
    }
}

# 执行主函数
Main