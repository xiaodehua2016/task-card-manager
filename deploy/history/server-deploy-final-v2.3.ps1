# 小久任务管理系统 v4.2.1 服务器部署脚本 (最终修复版 v2.3)
# 包含自动密码输入和增强的错误处理功能

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
$PASSWORD_FILE = "C:\AA\codebuddy\1\123.txt"  # 密码文件路径
$REMOTE_TMP = "/tmp"
$WEB_ROOT = "/www/wwwroot/task-manager"
$VERSION = "v4.2.1"
$PACKAGE_NAME = "task-manager-${VERSION}.zip"

# 创建带时间戳的日志文件
$logTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "deploy_log_${logTimestamp}.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage -Encoding UTF8
}

function Execute-SSHCommand {
    param(
        [string]$Command,
        [string]$Description
    )
    
    Write-Log "执行操作: $Description"
    Write-Log "命令: $Command"
    
    try {
        # 使用环境变量传递密码
        $env:SSHPASS = $PASSWORD
        
        # 尝试使用sshpass (如果可用)
        if (Get-Command "sshpass" -ErrorAction SilentlyContinue) {
            & sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SERVER_USER@$SERVER_IP $Command
            $exitCode = $LASTEXITCODE
        } else {
            # 回退到标准ssh (需要手动输入密码或使用密钥)
            & ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SERVER_USER@$SERVER_IP $Command
            $exitCode = $LASTEXITCODE
        }
        
        if ($exitCode -eq 0) {
            Write-Log "${GREEN}✓ $Description 执行成功${NC}"
            return $true
        } else {
            Write-Log "${RED}✗ $Description 执行失败，退出代码: $exitCode${NC}"
            return $false
        }
    } catch {
        Write-Log "${RED}✗ $Description 执行失败，错误: $($_.Exception.Message)${NC}"
        return $false
    }
}

function Execute-SCPUpload {
    param(
        [string]$LocalPath,
        [string]$RemotePath,
        [string]$Description
    )
    
    Write-Log "上传文件: $Description"
    Write-Log "本地路径: $LocalPath"
    Write-Log "远程路径: $SERVER_USER@${SERVER_IP}:$RemotePath"
    
    try {
        # 使用环境变量传递密码
        $env:SSHPASS = $PASSWORD
        
        # 尝试使用sshpass (如果可用)
        if (Get-Command "sshpass" -ErrorAction SilentlyContinue) {
            & sshpass -p $PASSWORD scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $LocalPath "$SERVER_USER@${SERVER_IP}:$RemotePath"
            $exitCode = $LASTEXITCODE
        } else {
            # 回退到标准scp
            & scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $LocalPath "$SERVER_USER@${SERVER_IP}:$RemotePath"
            $exitCode = $LASTEXITCODE
        }
        
        if ($exitCode -eq 0) {
            Write-Log "${GREEN}✓ $Description 上传成功${NC}"
            return $true
        } else {
            Write-Log "${RED}✗ $Description 上传失败，退出代码: $exitCode${NC}"
            return $false
        }
    } catch {
        Write-Log "${RED}✗ $Description 上传失败，错误: $($_.Exception.Message)${NC}"
        return $false
    }
}

Write-Log "${BLUE}=== 小久任务管理系统 ${VERSION} 服务器部署脚本 v2.3 ===${NC}"
Write-Log "开始时间: $(Get-Date)"
Write-Log "日志文件: $logFile"
Write-Log ""

# 确保我们在项目根目录
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $scriptDir

Set-Location $projectRoot
Write-Log "工作目录: $(Get-Location)"

# 步骤1: 创建部署包
Write-Log "${YELLOW}[1/5] 创建部署包...${NC}"

# 检查密码文件
if (-not (Test-Path $PASSWORD_FILE)) {
    Write-Log "${RED}错误: 密码文件未找到: $PASSWORD_FILE${NC}"
    Write-Log "请创建密码文件并写入服务器密码"
    Write-Log "示例: echo 'your_password' > '$PASSWORD_FILE'"
    exit 1
}

# 读取密码
try {
    $PASSWORD = Get-Content $PASSWORD_FILE -Raw -ErrorAction Stop
    $PASSWORD = $PASSWORD.Trim()
    if ([string]::IsNullOrEmpty($PASSWORD)) {
        Write-Log "${RED}错误: 密码文件为空${NC}"
        exit 1
    }
    Write-Log "密码文件读取成功"
} catch {
    Write-Log "${RED}错误: 无法读取密码文件: $($_.Exception.Message)${NC}"
    exit 1
}

# 创建临时目录
$tempDir = Join-Path -Path $scriptDir -ChildPath "temp_deploy_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Log "创建临时目录: $tempDir"

# 定义要排除的文件
$excludePatterns = @(
    ".git",
    "node_modules",
    ".codebuddy",
    "temp_deploy*",
    "*.zip",
    "*.tar.gz",
    ".DS_Store",
    "Thumbs.db",
    "*.log",
    ".env",
    ".vscode",
    ".idea",
    "deploy_log_*.txt",
    "history"
)

Write-Log "开始复制项目文件..."
$filesToCopy = Get-ChildItem -Path $projectRoot -Recurse | Where-Object {
    $relativePath = $_.FullName.Substring($projectRoot.Length + 1)
    $shouldExclude = $false
    
    foreach ($pattern in $excludePatterns) {
        if ($relativePath -like "*$pattern*") {
            $shouldExclude = $true
            break
        }
    }
    
    -not $shouldExclude
}

$fileCount = 0
foreach ($file in $filesToCopy) {
    if (-not $file.PSIsContainer) {
        $relativePath = $file.FullName.Substring($projectRoot.Length + 1)
        $destPath = Join-Path -Path $tempDir -ChildPath $relativePath
        $destDir = Split-Path -Parent $destPath
        
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        Copy-Item -Path $file.FullName -Destination $destPath -Force
        $fileCount++
    }
}

Write-Log "复制了 $fileCount 个文件"

# 创建ZIP包
$zipPath = Join-Path -Path $scriptDir -ChildPath $PACKAGE_NAME

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Log "删除旧的部署包"
}

try {
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force
    Write-Log "${GREEN}✓ 部署包创建成功: $PACKAGE_NAME${NC}"
} catch {
    Write-Log "${RED}错误: 创建ZIP包失败${NC}"
    Write-Log "错误信息: $($_.Exception.Message)"
    exit 1
} finally {
    # 清理临时目录
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
        Write-Log "清理临时目录"
    }
}

# 步骤2: 检查上传工具
Write-Log "`n${YELLOW}[2/5] 检查上传工具...${NC}"

# 检查必需的工具
$hasSSH = Get-Command "ssh" -ErrorAction SilentlyContinue
$hasSCP = Get-Command "scp" -ErrorAction SilentlyContinue
$hasSSHPASS = Get-Command "sshpass" -ErrorAction SilentlyContinue

Write-Log "工具可用性检查:"
Write-Log "  SSH: $(if ($hasSSH) { '可用' } else { '未找到' })"
Write-Log "  SCP: $(if ($hasSCP) { '可用' } else { '未找到' })"
Write-Log "  SSHPASS: $(if ($hasSSHPASS) { '可用' } else { '未找到' })"

if (-not $hasSSH -or -not $hasSCP) {
    Write-Log "${RED}错误: 需要SSH和SCP工具${NC}"
    Write-Log "请安装OpenSSH或使用Windows子系统Linux (WSL)"
    Write-Log "或者安装Git for Windows (包含SSH工具)"
    exit 1
}

if (-not $hasSSHPASS) {
    Write-Log "${YELLOW}警告: 未找到sshpass工具，可能需要手动输入密码${NC}"
    Write-Log "建议安装sshpass或配置SSH密钥认证"
}

# 步骤3: 上传文件到服务器
Write-Log "`n${YELLOW}[3/5] 上传文件到服务器...${NC}"

# 上传部署包
if (-not (Execute-SCPUpload -LocalPath $zipPath -RemotePath "$REMOTE_TMP/" -Description "部署包")) {
    Write-Log "${RED}部署包上传失败${NC}"
    exit 1
}

# 上传部署脚本
Write-Log "上传部署脚本..."
$shFiles = Get-ChildItem -Path $scriptDir -Filter "*.sh"
Write-Log "找到 $($shFiles.Count) 个shell脚本文件"

foreach ($file in $shFiles) {
    if (-not (Execute-SCPUpload -LocalPath $file.FullName -RemotePath "$REMOTE_TMP/" -Description "脚本: $($file.Name)")) {
        Write-Log "${RED}脚本上传失败: $($file.Name)${NC}"
        exit 1
    }
}

Write-Log "${GREEN}✓ 所有文件上传成功${NC}"

# 步骤4: 在服务器上执行部署
Write-Log "`n${YELLOW}[4/5] 在服务器上执行部署...${NC}"

# 设置执行权限
if (-not (Execute-SSHCommand -Command "chmod +x $REMOTE_TMP/*.sh" -Description "设置脚本执行权限")) {
    Write-Log "${RED}设置执行权限失败${NC}"
    exit 1
}

# 执行部署脚本并获取详细输出
$deployCommand = @"
echo "=== 开始部署过程 ===";
echo "时间戳: \$(date)";
echo "工作目录: \$(pwd)";
echo "可用脚本:";
ls -la $REMOTE_TMP/*.sh;
echo "";
echo "=== 执行 one-click-deploy.sh ===";
$REMOTE_TMP/one-click-deploy.sh 2>&1;
DEPLOY_EXIT_CODE=\$?;
echo "";
echo "=== 部署脚本退出代码: \$DEPLOY_EXIT_CODE ===";
if [ \$DEPLOY_EXIT_CODE -ne 0 ]; then
    echo "=== 部署失败，尝试获取更多信息 ===";
    echo "检查部署包是否存在:";
    ls -la $REMOTE_TMP/task-manager-*.zip;
    echo "检查web根目录:";
    ls -la $WEB_ROOT/ 2>/dev/null || echo "Web根目录不存在";
    echo "检查nginx状态:";
    systemctl status nginx --no-pager || echo "Nginx状态检查失败";
    echo "=== 尝试权限修复 ===";
    $REMOTE_TMP/fix-baota-permissions.sh 2>&1;
    echo "=== 运行验证 ===";
    $REMOTE_TMP/verify-deployment.sh 2>&1;
else
    echo "=== 部署成功，运行验证 ===";
    $REMOTE_TMP/verify-deployment.sh 2>&1;
fi;
echo "=== 部署过程完成 ===";
"@

if (-not (Execute-SSHCommand -Command $deployCommand -Description "执行部署过程")) {
    Write-Log "${RED}部署过程失败${NC}"
    
    # 尝试获取更多诊断信息
    Write-Log "`n${YELLOW}尝试收集诊断信息...${NC}"
    $diagCommand = @"
echo "=== 系统信息 ===";
uname -a;
echo "=== 磁盘空间 ===";
df -h;
echo "=== 内存使用 ===";
free -h;
echo "=== 网络连接 ===";
ping -c 3 8.8.8.8;
echo "=== Web服务器状态 ===";
systemctl status nginx --no-pager 2>/dev/null || systemctl status apache2 --no-pager 2>/dev/null || echo "未找到web服务器";
echo "=== 文件权限 ===";
ls -la $WEB_ROOT/ 2>/dev/null || echo "Web根目录不可访问";
"@
    
    Execute-SSHCommand -Command $diagCommand -Description "收集诊断信息"
    exit 1
}

# 步骤5: 最终验证
Write-Log "`n${YELLOW}[5/5] 最终验证...${NC}"

# 测试网站可访问性
Write-Log "测试网站可访问性..."
$testCommand = @"
echo "=== 网站可访问性测试 ===";
curl -I http://localhost 2>/dev/null || echo "本地HTTP测试失败";
curl -I http://$SERVER_IP 2>/dev/null || echo "外部HTTP测试失败";
echo "=== 文件结构检查 ===";
find $WEB_ROOT -name "*.html" -o -name "*.js" -o -name "*.css" | head -10;
echo "=== 版本检查 ===";
grep -r "v4.2.1" $WEB_ROOT/ | head -5 || echo "未找到版本字符串";
"@

Execute-SSHCommand -Command $testCommand -Description "最终验证测试"

Write-Log "${GREEN}✓ 所有部署步骤完成${NC}"

Write-Log "`n${BLUE}=== 部署摘要 ===${NC}"
Write-Log "版本: $VERSION"
Write-Log "部署包: $PACKAGE_NAME"
Write-Log "服务器: $SERVER_IP"
Write-Log "Web根目录: $WEB_ROOT"
Write-Log "日志文件: $logFile"
Write-Log "完成时间: $(Get-Date)"

Write-Log "`n${GREEN}服务器部署完成！${NC}"
Write-Log "请访问 http://$SERVER_IP 验证网站是否正常运行"
Write-Log "请访问 http://$SERVER_IP/sync-test.html 测试数据同步功能"

# 清理部署包
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Log "部署包已清理"
}

Write-Log "`n部署日志已保存到: $logFile"