# 小久任务管理系统 v4.2.1 超简易部署脚本
# 用于部署到115.159.5.111服务器

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

Write-Host "${BLUE}=== 小久任务管理系统 ${VERSION} 超简易部署脚本 ===${NC}"
Write-Host "开始时间: $(Get-Date)"
Write-Host ""

# 检查密码文件
if (-not (Test-Path $PASSWORD_FILE)) {
    Write-Host "${RED}错误: 密码文件不存在: $PASSWORD_FILE${NC}"
    exit 1
}

# 读取密码
$PASSWORD = Get-Content $PASSWORD_FILE -Raw
$PASSWORD = $PASSWORD.Trim()

# 步骤1: 直接使用已存在的ZIP文件
Write-Host "${YELLOW}[1/3] 准备部署包...${NC}"

# 确保我们在项目根目录
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$zipPath = Join-Path -Path $scriptDir -ChildPath $PACKAGE_NAME

# 检查ZIP文件是否存在
if (-not (Test-Path $zipPath)) {
    Write-Host "${RED}错误: 部署包不存在: $zipPath${NC}"
    Write-Host "请先创建部署包，或者使用其他部署脚本"
    exit 1
}

Write-Host "${GREEN}✓ 部署包已准备就绪: $PACKAGE_NAME${NC}"

# 步骤2: 上传文件到服务器
Write-Host "`n${YELLOW}[2/3] 上传文件到服务器...${NC}"

# 检查是否安装了PuTTY工具
$hasPscp = $null -ne (Get-Command "pscp" -ErrorAction SilentlyContinue)
$hasPlink = $null -ne (Get-Command "plink" -ErrorAction SilentlyContinue)

if ($hasPscp) {
    Write-Host "使用PSCP上传文件..."
    
    # 上传部署包
    Write-Host "上传部署包: $PACKAGE_NAME"
    $pscpCmd = "echo y | pscp -pw `"$PASSWORD`" `"$zipPath`" ${SERVER_USER}@${SERVER_IP}:${REMOTE_TMP}/"
    Invoke-Expression $pscpCmd
    
    # 上传部署脚本
    Write-Host "上传部署脚本..."
    $deployScripts = @("one-click-deploy.sh", "fix-baota-permissions.sh", "verify-deployment.sh")
    foreach ($script in $deployScripts) {
        $scriptPath = Join-Path -Path $scriptDir -ChildPath $script
        if (Test-Path $scriptPath) {
            $pscpCmd = "echo y | pscp -pw `"$PASSWORD`" `"$scriptPath`" ${SERVER_USER}@${SERVER_IP}:${REMOTE_TMP}/"
            Invoke-Expression $pscpCmd
        } else {
            Write-Host "${YELLOW}警告: 脚本文件不存在: $script${NC}"
        }
    }
    
    Write-Host "${GREEN}✓ 文件上传成功${NC}"
} else {
    Write-Host "${YELLOW}未检测到PSCP工具，请手动上传以下文件:${NC}"
    Write-Host "1. $zipPath -> ${SERVER_USER}@${SERVER_IP}:${REMOTE_TMP}/"
    Write-Host "2. $scriptDir\*.sh -> ${SERVER_USER}@${SERVER_IP}:${REMOTE_TMP}/"
    
    $confirmation = Read-Host "文件上传完成后，按Enter键继续..."
}

# 步骤3: 在服务器上执行部署
Write-Host "`n${YELLOW}[3/3] 在服务器上执行部署...${NC}"

if ($hasPlink) {
    Write-Host "使用PLINK执行远程命令..."
    
    # 创建部署命令
    $deployCmd = @"
echo y | plink -pw "$PASSWORD" ${SERVER_USER}@${SERVER_IP} "
    echo '连接到服务器成功，开始部署...'
    
    # 设置执行权限
    chmod +x ${REMOTE_TMP}/one-click-deploy.sh
    chmod +x ${REMOTE_TMP}/fix-baota-permissions.sh
    chmod +x ${REMOTE_TMP}/verify-deployment.sh
    
    # 备份当前网站
    echo '备份当前网站...'
    if [ -d '${WEB_ROOT}' ]; then
        tar -czf ${REMOTE_TMP}/task-manager-backup-\$(date +%Y%m%d%H%M%S).tar.gz -C ${WEB_ROOT} .
        echo '网站已备份'
    fi
    
    # 解压部署包
    echo '解压部署包...'
    mkdir -p ${WEB_ROOT}
    unzip -o ${REMOTE_TMP}/${PACKAGE_NAME} -d ${WEB_ROOT}
    
    # 设置权限
    echo '设置文件权限...'
    chown -R www:www ${WEB_ROOT}
    find ${WEB_ROOT} -type d -exec chmod 755 {} \;
    find ${WEB_ROOT} -type f -exec chmod 644 {} \;
    
    # 创建数据目录
    echo '确保数据目录存在...'
    mkdir -p ${WEB_ROOT}/data
    chown -R www:www ${WEB_ROOT}/data
    chmod 755 ${WEB_ROOT}/data
    
    # 处理宝塔面板特殊文件
    if [ -f '${WEB_ROOT}/.user.ini' ]; then
        echo '处理宝塔面板.user.ini文件...'
        chattr -i ${WEB_ROOT}/.user.ini
        chown www:www ${WEB_ROOT}/.user.ini
        chattr +i ${WEB_ROOT}/.user.ini
    fi
    
    # 验证部署
    ${REMOTE_TMP}/verify-deployment.sh
    
    echo '部署完成！'
"
"@
    
    # 执行部署命令
    Invoke-Expression $deployCmd
    
    Write-Host "${GREEN}✓ 服务器部署成功${NC}"
} else {
    Write-Host "${YELLOW}未检测到PLINK工具，请手动执行以下命令:${NC}"
    Write-Host "1. SSH连接到服务器: ssh ${SERVER_USER}@${SERVER_IP}"
    Write-Host "2. 执行以下命令:"
    Write-Host "   chmod +x ${REMOTE_TMP}/one-click-deploy.sh"
    Write-Host "   chmod +x ${REMOTE_TMP}/fix-baota-permissions.sh"
    Write-Host "   chmod +x ${REMOTE_TMP}/verify-deployment.sh"
    Write-Host "   ${REMOTE_TMP}/one-click-deploy.sh"
    Write-Host "   ${REMOTE_TMP}/verify-deployment.sh"
    
    $confirmation = Read-Host "部署完成后，按Enter键继续..."
}

Write-Host "`n${BLUE}=== 部署摘要 ===${NC}"
Write-Host "部署版本: $VERSION"
Write-Host "部署包: $PACKAGE_NAME"
Write-Host "服务器: $SERVER_IP"
Write-Host "网站目录: $WEB_ROOT"
Write-Host "完成时间: $(Get-Date)"

Write-Host "`n${GREEN}部署脚本执行完毕！${NC}"
Write-Host "请访问 http://${SERVER_IP} 验证网站是否正常运行"
Write-Host "请访问 http://${SERVER_IP}/sync-test.html 测试数据同步功能"