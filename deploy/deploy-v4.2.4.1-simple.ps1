# 小久任务管理系统 v4.2.4 部署脚本
# 简化版本，专注于创建部署包
# 版本：v4.2.4.1

param (
    [switch]$PackageOnly = $false
)

# 设置路径
$rootDir = Split-Path -Parent $PSScriptRoot
$tempDir = Join-Path $rootDir "temp_deploy"
$zipFile = Join-Path $rootDir "task-manager-v4.2.4-complete.zip"

# 创建临时目录
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# 复制HTML文件
$htmlFiles = @("index.html", "edit-tasks.html", "focus-challenge.html", "statistics.html", "today-tasks.html", "sync-test.html")
foreach ($file in $htmlFiles) {
    $sourcePath = Join-Path $rootDir $file
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $tempDir
        Write-Host "已复制: $file"
    } else {
        Write-Host "跳过不存在的文件: $file" -ForegroundColor Yellow
    }
}

# 复制配置文件
$configFiles = @("manifest.json", "icon-192.svg", "favicon.ico")
foreach ($file in $configFiles) {
    $sourcePath = Join-Path $rootDir $file
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $tempDir
        Write-Host "已复制: $file"
    } else {
        Write-Host "跳过不存在的文件: $file" -ForegroundColor Yellow
    }
}

# 复制CSS目录
$cssDir = Join-Path $rootDir "css"
if (Test-Path $cssDir) {
    $destCssDir = Join-Path $tempDir "css"
    New-Item -ItemType Directory -Path $destCssDir | Out-Null
    Copy-Item -Path "$cssDir\*" -Destination $destCssDir -Recurse
    Write-Host "CSS文件已复制" -ForegroundColor Green
} else {
    Write-Host "CSS目录不存在，已跳过" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path (Join-Path $tempDir "css") | Out-Null
}

# 复制JS目录
$jsDir = Join-Path $rootDir "js"
if (Test-Path $jsDir) {
    $destJsDir = Join-Path $tempDir "js"
    New-Item -ItemType Directory -Path $destJsDir | Out-Null
    Copy-Item -Path "$jsDir\*" -Destination $destJsDir -Recurse
    Write-Host "JS文件已复制" -ForegroundColor Green
} else {
    Write-Host "JS目录不存在，已跳过" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path (Join-Path $tempDir "js") | Out-Null
}

# 复制API目录
$apiDir = Join-Path $rootDir "api"
if (Test-Path $apiDir) {
    $destApiDir = Join-Path $tempDir "api"
    New-Item -ItemType Directory -Path $destApiDir | Out-Null
    Copy-Item -Path "$apiDir\*" -Destination $destApiDir -Recurse
    Write-Host "API文件已复制" -ForegroundColor Green
} else {
    Write-Host "API目录不存在，已跳过" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path (Join-Path $tempDir "api") | Out-Null
}

# 复制数据目录
$dataDir = Join-Path $rootDir "data"
if (Test-Path $dataDir) {
    $destDataDir = Join-Path $tempDir "data"
    New-Item -ItemType Directory -Path $destDataDir | Out-Null
    Copy-Item -Path "$dataDir\*" -Destination $destDataDir -Recurse
    Write-Host "数据文件已复制" -ForegroundColor Green
} else {
    Write-Host "数据目录不存在，已创建" -ForegroundColor Yellow
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
Write-Host "部署包创建成功: $zipFile" -ForegroundColor Green
Write-Host "包大小: $zipSize 字节"

# 清理临时目录
Remove-Item -Path $tempDir -Recurse -Force

# 显示部署指南
if (-not $PackageOnly) {
    Write-Host ""
    Write-Host "部署指南:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "使用SCP上传文件:" -ForegroundColor Yellow
    Write-Host "   scp `"$zipFile`" root@115.159.5.111:/tmp/"
    Write-Host ""
    Write-Host "服务器操作:" -ForegroundColor Yellow
    Write-Host "   cd /www/wwwroot/"
    Write-Host "   unzip -o /tmp/task-manager-v4.2.4-complete.zip -d task-manager/"
    Write-Host "   chown -R www:www task-manager/"
    Write-Host "   chmod -R 755 task-manager/"
}

exit 0