# 小久任务管理系统 v4.2.1 部署包创建脚本

# 如果遇到执行策略限制，请以管理员身份运行：
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 颜色定义
$RED = "$([char]0x1b)[31m"
$GREEN = "$([char]0x1b)[32m"
$YELLOW = "$([char]0x1b)[33m"
$BLUE = "$([char]0x1b)[34m"
$NC = "$([char]0x1b)[0m" # 无颜色

# 配置信息
$VERSION = "v4.2.1"
$PACKAGE_NAME = "task-manager-${VERSION}.zip"

Write-Host "${BLUE}=== 小久任务管理系统 ${VERSION} 部署包创建脚本 ===${NC}"
Write-Host "开始时间: $(Get-Date)"
Write-Host ""

# 确保我们在项目根目录
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $scriptDir
$zipPath = Join-Path -Path $scriptDir -ChildPath $PACKAGE_NAME

# 切换到项目根目录
Push-Location $projectRoot

try {
    # 删除已存在的ZIP文件
    if (Test-Path $zipPath) {
        Remove-Item -Path $zipPath -Force
        Write-Host "已删除旧的部署包"
    }
    
    # 检查是否安装了7-Zip
    $has7z = Test-Path "C:\Program Files\7-Zip\7z.exe"
    
    if ($has7z) {
        # 使用7-Zip创建ZIP文件
        Write-Host "${YELLOW}使用7-Zip创建部署包...${NC}"
        & "C:\Program Files\7-Zip\7z.exe" a -tzip $zipPath * -xr!.git -xr!node_modules -xr!.codebuddy -xr!task-manager-*.zip
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "${GREEN}✓ 部署包创建成功: $PACKAGE_NAME${NC}"
        } else {
            Write-Host "${RED}✗ 部署包创建失败${NC}"
            exit 1
        }
    } else {
        # 使用PowerShell内置命令创建ZIP文件
        Write-Host "${YELLOW}使用PowerShell创建部署包...${NC}"
        
        # 创建临时目录
        $tempDir = Join-Path -Path $env:TEMP -ChildPath "task-manager-temp"
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        # 复制文件到临时目录
        Write-Host "复制文件到临时目录..."
        Get-ChildItem -Path $projectRoot -Exclude .git, node_modules, .codebuddy, "task-manager-*.zip" | 
            ForEach-Object {
                if ($_.PSIsContainer) {
                    Copy-Item -Path $_.FullName -Destination $tempDir -Recurse -Force
                } else {
                    Copy-Item -Path $_.FullName -Destination $tempDir -Force
                }
            }
        
        # 创建ZIP文件
        Write-Host "创建ZIP文件..."
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)
        
        # 清理临时目录
        Remove-Item -Path $tempDir -Recurse -Force
        
        Write-Host "${GREEN}✓ 部署包创建成功: $PACKAGE_NAME${NC}"
    }
} catch {
    Write-Host "${RED}✗ 部署包创建失败: $_${NC}"
    exit 1
} finally {
    # 恢复原来的目录
    Pop-Location
}

Write-Host "`n${BLUE}=== 摘要 ===${NC}"
Write-Host "部署包: $zipPath"
Write-Host "大小: $((Get-Item $zipPath).Length / 1MB) MB"
Write-Host "完成时间: $(Get-Date)"

Write-Host "`n${GREEN}部署包创建完成！${NC}"
Write-Host "现在可以使用超简易部署脚本将此包部署到服务器"