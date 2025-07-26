# 小久任务管理系统 v4.2.1 上传部署脚本
# 用于将已创建的部署包上传到115.159.5.111服务器并部署

# 如果遇到执行策略限制，请以管理员身份运行：
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 颜色定义
$RED = "$([char]0x1b)[31m"
$GREEN = "$([char]0x1b)[32m"
$YELLOW = "$([char]0x1b)[33m"
$BLUE = "$([char]0x1b)[34m"
$NC = "$([char]0x1b)[0m" # 无颜色

# 配置信息
$SERVER_IP = "115.159.5.111"
$SERVER_USER = "root"
$PASSWORD_FILE = "C:\AA\codebuddy\1\123.txt"
$REMOTE_TMP = "/tmp"
$WEB_ROOT = "/www/wwwroot/task-manager"
$VERSION = "v4.2.1"
$PACKAGE_NAME = "task-manager-${VERSION}.zip"

Write-Host "${BLUE}=== 小久任务管理系统 ${VERSION} 上传部署脚本 ===${NC}"
Write-Host "开始时间: $(Get-Date)"
Write-Host ""

# 确保我们在项目根目录
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$zipPath = Join-Path -Path $scriptDir -ChildPath $PACKAGE_NAME

# 检查部署包是否存在
if (-not (Test-Path $zipPath)) {
    Write-Host "${RED}错误: 部署包不存在: $zipPath${NC}"
    Write-Host "请先运行 '创建部署包.bat' 创建部署包"
    exit 1
}

# 检查密码文件
if (-not (Test-Path $PASSWORD_FILE)) {
    Write-Host "${RED}错误: 密码文件不存在: $PASSWORD_FILE${NC}"
    exit 1
}

# 读取密码
$PASSWORD = Get-Content $PASSWORD_FILE -Raw
$PASSWORD = $PASSWORD.Trim()

# 步骤1: 检查上传工具
Write-Host "${YELLOW}[1/3] 检查上传工具...${NC}"

# 检查是否安装了pscp (PuTTY SCP)
$hasPscp = $false
if (Get-Command "pscp" -ErrorAction SilentlyContinue) {
    $hasPscp = $true
    Write-Host "${GREEN}✓ 已找到pscp工具${NC}"
} else {
    # 检查PuTTY安装目录
    $puttyPaths = @(
        "C:\Program Files\PuTTY\pscp.exe",
        "C:\Program Files (x86)\PuTTY\pscp.exe"
    )
    
    foreach ($path in $puttyPaths) {
        if (Test-Path $path) {
            $env:PATH += ";$(Split-Path -Parent $path)"
            $hasPscp = $true
            Write-Host "${GREEN}Found pscp tool: $path${NC}"
            break
        }
    }
}

if (-not $hasPscp) {
    Write-Host "${YELLOW}⚠ 未检测到pscp工具${NC}"
    Write-Host "请手动上传以下文件到服务器:"
    Write-Host "1. $zipPath -> $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    Write-Host "2. $scriptDir\*.sh -> $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    
    $continue = Read-Host "是否已手动上传文件? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
} else {
    # 步骤2: 上传文件到服务器
    Write-Host "`n${YELLOW}[2/3] 上传文件到服务器...${NC}"
    
    # 上传部署包
    Write-Host "上传部署包..."
    $pscpArgs = @(
        "-pw", $PASSWORD,
        "-batch",
        $zipPath,
        "$SERVER_USER@$SERVER_IP`:$REMOTE_TMP/"
    )
    
    & pscp $pscpArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}✗ 上传部署包失败${NC}"
        exit 1
    }
    
    # 上传部署脚本
    Write-Host "上传部署脚本..."
    $shFiles = Get-ChildItem -Path $scriptDir -Filter "*.sh"
    
    foreach ($file in $shFiles) {
        $pscpArgs = @(
            "-pw", $PASSWORD,
            "-batch",
            $file.FullName,
            "$SERVER_USER@$SERVER_IP`:$REMOTE_TMP/"
        )
        
        & pscp $pscpArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "${RED}✗ 上传脚本 $($file.Name) 失败${NC}"
            exit 1
        }
    }
    
    Write-Host "${GREEN}✓ 文件上传成功${NC}"
}

# 步骤3: 在服务器上执行部署
Write-Host "`n${YELLOW}[3/3] 在服务器上执行部署...${NC}"

# 检查是否安装了plink (PuTTY Link)
$hasPlink = $false
if (Get-Command "plink" -ErrorAction SilentlyContinue) {
    $hasPlink = $true
} else {
    # 检查PuTTY安装目录
    $puttyPaths = @(
        "C:\Program Files\PuTTY\plink.exe",
        "C:\Program Files (x86)\PuTTY\plink.exe"
    )
    
    foreach ($path in $puttyPaths) {
        if (Test-Path $path) {
            $env:PATH += ";$(Split-Path -Parent $path)"
            $hasPlink = $true
            break
        }
    }
}

if (-not $hasPlink) {
    Write-Host "${YELLOW}⚠ 未检测到plink工具${NC}"
    Write-Host "请手动连接到服务器并执行以下命令:"
    Write-Host "1. chmod +x $REMOTE_TMP/*.sh"
    Write-Host "2. $REMOTE_TMP/one-click-deploy.sh"
    Write-Host "3. $REMOTE_TMP/verify-deployment.sh"
    
    Write-Host "`n${BLUE}=== 部署摘要 ===${NC}"
    Write-Host "部署版本: $VERSION"
    Write-Host "部署包: $PACKAGE_NAME"
    Write-Host "服务器: $SERVER_IP"
    Write-Host "网站目录: $WEB_ROOT"
    Write-Host "完成时间: $(Get-Date)"
    
    Write-Host "`n${GREEN}上传完成！请手动完成部署步骤${NC}"
    exit 0
} else {
    # 使用plink执行远程命令
    Write-Host "连接到服务器并执行部署..."
    
    # 设置执行权限
    $plinkArgs = @(
        "-ssh",
        "-pw", $PASSWORD,
        "-batch",
        "$SERVER_USER@$SERVER_IP",
        "chmod +x $REMOTE_TMP/*.sh"
    )
    
    & plink $plinkArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}✗ 设置执行权限失败${NC}"
        exit 1
    }
    
    # 执行部署脚本
    $deployCommand = @"
echo "Starting deployment...";
$REMOTE_TMP/one-click-deploy.sh;
echo "Verifying deployment...";
$REMOTE_TMP/verify-deployment.sh;
if [ \$? -ne 0 ]; then
    echo "Trying to fix permissions...";
    $REMOTE_TMP/fix-baota-permissions.sh;
fi
"@
    
    $plinkArgs = @(
        "-ssh",
        "-pw", $PASSWORD,
        "-batch",
        "$SERVER_USER@$SERVER_IP",
        $deployCommand
    )
    
    & plink $plinkArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}✗ 部署失败${NC}"
        exit 1
    }
    
    Write-Host "${GREEN}✓ 部署成功${NC}"
}

Write-Host "`n${BLUE}=== 部署摘要 ===${NC}"
Write-Host "部署版本: $VERSION"
Write-Host "部署包: $PACKAGE_NAME"
Write-Host "服务器: $SERVER_IP"
Write-Host "网站目录: $WEB_ROOT"
Write-Host "完成时间: $(Get-Date)"

Write-Host "`n${GREEN}部署脚本执行完毕！${NC}"
Write-Host "请访问 http://$SERVER_IP 验证网站是否正常运行"
Write-Host "请访问 http://$SERVER_IP/sync-test.html 测试数据同步功能"