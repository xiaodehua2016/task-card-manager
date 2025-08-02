# 小久任务管理系统 v4.2.4 部署脚本
# 简化版本，专注于创建部署包和提供部署指南
# 版本：v4.2.4.1

param (
    [switch]$PackageOnly = $false
)

# 设置日志
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDir = Join-Path $PSScriptRoot "logs"
$logFile = Join-Path $logDir "ps_deploy_log_$timestamp.txt"

# 创建日志目录
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# 开始记录日志
"========================================" | Out-File -FilePath $logFile
"    小久任务管理系统 v4.2.4 部署脚本    " | Out-File -FilePath $logFile -Append
"========================================" | Out-File -FilePath $logFile -Append
"部署开始时间: $(Get-Date)" | Out-File -FilePath $logFile -Append
"" | Out-File -FilePath $logFile -Append

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    $logMessage | Out-File -FilePath $logFile -Append
    
    # 根据日志级别设置颜色
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Create-DeploymentPackage {
    Write-Log "开始创建部署包..."
    
    # 设置路径
    $rootDir = Split-Path -Parent $PSScriptRoot
    $tempDir = Join-Path $rootDir "temp_deploy"
    $zipFile = Join-Path $rootDir "task-manager-v4.2.4-complete.zip"
    
    # 清理临时目录
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
    
    # 创建临时目录
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    # 复制HTML文件
    Write-Log "复制核心文件..."
    $htmlFiles = @("index.html", "edit-tasks.html", "focus-challenge.html", "statistics.html", "today-tasks.html", "sync-test.html")
    foreach ($file in $htmlFiles) {
        $sourcePath = Join-Path $rootDir $file
        if (Test-Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $tempDir
            Write-Log "  - 已复制: $file"
        } else {
            Write-Log "  - 跳过不存在的文件: $file" -Level "WARNING"
        }
    }
    
    # 复制配置文件
    $configFiles = @("manifest.json", "icon-192.svg", "favicon.ico")
    foreach ($file in $configFiles) {
        $sourcePath = Join-Path $rootDir $file
        if (Test-Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $tempDir
            Write-Log "  - 已复制: $file"
        } else {
            Write-Log "  - 跳过不存在的文件: $file" -Level "WARNING"
        }
    }
    
    # 复制CSS目录
    $cssDir = Join-Path $rootDir "css"
    if (Test-Path $cssDir) {
        $destCssDir = Join-Path $tempDir "css"
        New-Item -ItemType Directory -Path $destCssDir | Out-Null
        Copy-Item -Path "$cssDir\*" -Destination $destCssDir -Recurse
        Write-Log "✅ CSS文件已复制" -Level "SUCCESS"
    } else {
        Write-Log "CSS目录不存在，已跳过" -Level "WARNING"
        New-Item -ItemType Directory -Path (Join-Path $tempDir "css") | Out-Null
    }
    
    # 复制JS目录
    $jsDir = Join-Path $rootDir "js"
    if (Test-Path $jsDir) {
        $destJsDir = Join-Path $tempDir "js"
        New-Item -ItemType Directory -Path $destJsDir | Out-Null
        Copy-Item -Path "$jsDir\*" -Destination $destJsDir -Recurse
        Write-Log "✅ JS文件已复制" -Level "SUCCESS"
    } else {
        Write-Log "JS目录不存在，已跳过" -Level "WARNING"
        New-Item -ItemType Directory -Path (Join-Path $tempDir "js") | Out-Null
    }
    
    # 复制API目录
    $apiDir = Join-Path $rootDir "api"
    if (Test-Path $apiDir) {
        $destApiDir = Join-Path $tempDir "api"
        New-Item -ItemType Directory -Path $destApiDir | Out-Null
        Copy-Item -Path "$apiDir\*" -Destination $destApiDir -Recurse
        Write-Log "✅ API文件已复制" -Level "SUCCESS"
    } else {
        Write-Log "API目录不存在，已跳过" -Level "WARNING"
        New-Item -ItemType Directory -Path (Join-Path $tempDir "api") | Out-Null
    }
    
    # 复制数据目录
    $dataDir = Join-Path $rootDir "data"
    if (Test-Path $dataDir) {
        $destDataDir = Join-Path $tempDir "data"
        New-Item -ItemType Directory -Path $destDataDir | Out-Null
        Copy-Item -Path "$dataDir\*" -Destination $destDataDir -Recurse
        Write-Log "✅ 数据文件已复制" -Level "SUCCESS"
    } else {
        Write-Log "数据目录不存在，已创建" -Level "WARNING"
        New-Item -ItemType Directory -Path (Join-Path $tempDir "data") | Out-Null
    }
    
    # 创建ZIP包
    if (Test-Path $zipFile) {
        Remove-Item -Path $zipFile -Force
    }
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFile)
    
    # 获取ZIP包大小
    $zipSize = (Get-Item $zipFile).Length
    Write-Log "✅ 部署包创建成功: $zipFile" -Level "SUCCESS"
    Write-Log "📊 包大小: $zipSize 字节"
    
    # 清理临时目录
    Remove-Item -Path $tempDir -Recurse -Force
    
    return $zipFile
}

function Show-DeploymentGuide {
    param (
        [string]$ZipFile
    )
    
    Write-Log "显示部署指南..."
    
    Write-Host ""
    Write-Host "🔧 部署指南:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 使用SCP上传文件:" -ForegroundColor Yellow
    Write-Host "   scp `"$ZipFile`" root@115.159.5.111:/tmp/"
    Write-Host ""
    Write-Host "📋 服务器操作:" -ForegroundColor Yellow
    Write-Host "   cd /www/wwwroot/"
    Write-Host "   unzip -o /tmp/task-manager-v4.2.4-complete.zip -d task-manager/"
    Write-Host "   chown -R www:www task-manager/"
    Write-Host "   chmod -R 755 task-manager/"
    Write-Host ""
    Write-Host "💡 宝塔面板操作:" -ForegroundColor Yellow
    Write-Host "   - 登录: http://115.159.5.111:8888"
    Write-Host "   - 文件管理 → 上传 task-manager-v4.2.4-complete.zip"
    Write-Host "   - 解压到 /www/wwwroot/task-manager/"
    Write-Host "   - 设置权限: 所有者 www, 权限 755"
    Write-Host ""
    Write-Host "🧪 部署后测试步骤:" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. 基础测试:" -ForegroundColor Cyan
    Write-Host "   - 访问 http://115.159.5.111/"
    Write-Host "   - 检查页面是否正常加载"
    Write-Host ""
    Write-Host "2. 同步测试:" -ForegroundColor Cyan
    Write-Host "   - 在Chrome中完成一些任务"
    Write-Host "   - 在Firefox中打开同一地址"
    Write-Host "   - 等待5秒观察自动同步"
    Write-Host ""
    Write-Host "3. 诊断测试:" -ForegroundColor Cyan
    Write-Host "   - 访问 http://115.159.5.111/sync-test.html"
    Write-Host "   - 点击"运行诊断"查看同步状态"
    Write-Host "   - 如有问题，点击"自动修复""
    Write-Host ""
    Write-Host "4. 跨设备测试:" -ForegroundColor Cyan
    Write-Host "   - 在手机浏览器中访问"
    Write-Host "   - 在电脑浏览器中访问"
    Write-Host "   - 验证数据是否在所有设备间同步"
    Write-Host ""
    
    Write-Log "部署指南显示完成"
}

# 主流程
try {
    # 创建部署包
    $zipFile = Create-DeploymentPackage
    
    # 如果只是创建部署包，则结束
    if ($PackageOnly) {
        Write-Host ""
        Write-Host "✅ 部署包已创建: $zipFile" -ForegroundColor Green
        Write-Log "仅创建部署包模式，部署包已创建" -Level "SUCCESS"
    } else {
        # 显示部署指南
        Show-DeploymentGuide -ZipFile $zipFile
    }
    
    # 记录成功
    Write-Log "部署脚本执行成功" -Level "SUCCESS"
} catch {
    Write-Log "部署脚本执行失败: $_" -Level "ERROR"
    Write-Host "❌ 部署失败: $_" -ForegroundColor Red
    exit 1
}

# 结束日志
"" | Out-File -FilePath $logFile -Append
"部署结束时间: $(Get-Date)" | Out-File -FilePath $logFile -Append
"========================================" | Out-File -FilePath $logFile -Append

exit 0