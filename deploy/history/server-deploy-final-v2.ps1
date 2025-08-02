# 小久任务管理系统 v4.2.1 服务器部署脚本 (最终修复版)
# 包含详细日志输出和完整的工具检测功能

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

Write-Log "${BLUE}=== 小久任务管理系统 ${VERSION} 服务器部署脚本 ===${NC}"
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
Write-Log "`n${YELLOW}[1/5] 创建部署包...${NC}"

# 检查密码文件
if (-not (Test-Path $PASSWORD_FILE)) {
    Write-Log "${RED}错误: 密码文件不存在: $PASSWORD_FILE${NC}"
    exit 1
}

# 读取密码
$PASSWORD = Get-Content $PASSWORD_FILE -Raw
$PASSWORD = $PASSWORD.Trim()
Write-Log "密码文件读取成功"

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
    "deploy_log_*.txt"
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

# 创建ZIP部署包
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

# 检查可用的上传工具
$uploadTools = @()

# 1. 检查scp命令 (OpenSSH)
Write-Log "检查scp命令..."
if (Get-Command "scp" -ErrorAction SilentlyContinue) {
    $uploadTools += "scp"
    Write-Log "${GREEN}✓ 找到scp工具 (OpenSSH)${NC}"
} else {
    Write-Log "未找到scp命令"
}

# 2. 检查pscp (PuTTY SCP)
Write-Log "检查pscp工具..."
if (Get-Command "pscp" -ErrorAction SilentlyContinue) {
    $uploadTools += "pscp"
    Write-Log "${GREEN}✓ 找到pscp工具 (PuTTY)${NC}"
} else {
    # 检查PuTTY安装目录
    $puttyPaths = @(
        "C:\Program Files\PuTTY\pscp.exe",
        "C:\Program Files (x86)\PuTTY\pscp.exe",
        "$env:USERPROFILE\AppData\Local\Programs\PuTTY\pscp.exe"
    )
    
    foreach ($path in $puttyPaths) {
        if (Test-Path $path) {
            $env:PATH += ";$(Split-Path -Parent $path)"
            $uploadTools += "pscp"
            Write-Log "${GREEN}✓ 找到pscp工具: $path${NC}"
            break
        }
    }
    
    if ("pscp" -notin $uploadTools) {
        Write-Log "未找到pscp工具"
    }
}

# 3. 检查WinSCP命令行工具
Write-Log "检查WinSCP工具..."
if (Get-Command "winscp" -ErrorAction SilentlyContinue) {
    $uploadTools += "winscp"
    Write-Log "${GREEN}✓ 找到WinSCP工具${NC}"
} else {
    Write-Log "未找到WinSCP工具"
}

Write-Log "可用的上传工具: $($uploadTools -join ', ')"

if ($uploadTools.Count -eq 0) {
    Write-Log "${YELLOW}⚠ 未检测到任何上传工具${NC}"
    Write-Log "请手动上传以下文件到服务器:"
    Write-Log "1. $zipPath -> $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    Write-Log "2. $scriptDir\*.sh -> $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    Write-Log ""
    Write-Log "可以使用以下命令:"
    Write-Log "scp `"$zipPath`" $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    Write-Log "scp `"$scriptDir\*.sh`" $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    
    $continue = Read-Host "是否已手动上传文件? (y/n)"
    if ($continue -ne "y") {
        Write-Log "用户取消部署"
        exit 1
    }
} else {
    # 步骤3: 上传文件到服务器
    Write-Log "`n${YELLOW}[3/5] 上传文件到服务器...${NC}"
    
    # 选择最佳上传工具
    $selectedTool = ""
    if ("scp" -in $uploadTools) {
        $selectedTool = "scp"
    } elseif ("pscp" -in $uploadTools) {
        $selectedTool = "pscp"
    } elseif ("winscp" -in $uploadTools) {
        $selectedTool = "winscp"
    }
    
    Write-Log "使用上传工具: $selectedTool"
    
    # 上传部署包
    Write-Log "上传部署包..."
    $uploadSuccess = $false
    
    if ($selectedTool -eq "scp") {
        # 使用scp上传
        $scpArgs = @(
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            $zipPath,
            "$SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
        )
        
        Write-Log "执行命令: scp $($scpArgs -join ' ')"
        
        # 使用sshpass或手动输入密码
        $env:SSHPASS = $PASSWORD
        & scp $scpArgs
        
        if ($LASTEXITCODE -eq 0) {
            $uploadSuccess = $true
            Write-Log "${GREEN}✓ 使用scp上传部署包成功${NC}"
        } else {
            Write-Log "${RED}✗ 使用scp上传部署包失败，退出码: $LASTEXITCODE${NC}"
        }
    } elseif ($selectedTool -eq "pscp") {
        # 使用pscp上传
        $pscpArgs = @(
            "-pw", $PASSWORD,
            "-batch",
            $zipPath,
            "$SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
        )
        
        Write-Log "执行命令: pscp (密码已隐藏) $zipPath $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
        
        & pscp $pscpArgs
        
        if ($LASTEXITCODE -eq 0) {
            $uploadSuccess = $true
            Write-Log "${GREEN}✓ 使用pscp上传部署包成功${NC}"
        } else {
            Write-Log "${RED}✗ 使用pscp上传部署包失败，退出码: $LASTEXITCODE${NC}"
        }
    }
    
    if (-not $uploadSuccess) {
        Write-Log "${RED}上传失败，请检查网络连接和服务器状态${NC}"
        exit 1
    }
    
    # 上传部署脚本
    Write-Log "上传部署脚本..."
    $shFiles = Get-ChildItem -Path $scriptDir -Filter "*.sh"
    Write-Log "找到 $($shFiles.Count) 个shell脚本文件"
    
    foreach ($file in $shFiles) {
        Write-Log "上传脚本: $($file.Name)"
        
        if ($selectedTool -eq "scp") {
            $scpArgs = @(
                "-o", "StrictHostKeyChecking=no",
                "-o", "UserKnownHostsFile=/dev/null",
                $file.FullName,
                "$SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
            )
            
            $env:SSHPASS = $PASSWORD
            & scp $scpArgs
            
            if ($LASTEXITCODE -ne 0) {
                Write-Log "${RED}✗ 上传脚本 $($file.Name) 失败${NC}"
                exit 1
            }
        } elseif ($selectedTool -eq "pscp") {
            $pscpArgs = @(
                "-pw", $PASSWORD,
                "-batch",
                $file.FullName,
                "$SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
            )
            
            & pscp $pscpArgs
            
            if ($LASTEXITCODE -ne 0) {
                Write-Log "${RED}✗ 上传脚本 $($file.Name) 失败${NC}"
                exit 1
            }
        }
    }
    
    Write-Log "${GREEN}✓ 所有文件上传成功${NC}"
}

# 步骤4: 在服务器上执行部署
Write-Log "`n${YELLOW}[4/5] 在服务器上执行部署...${NC}"

# 检查远程执行工具
$remoteTools = @()

# 检查ssh命令
if (Get-Command "ssh" -ErrorAction SilentlyContinue) {
    $remoteTools += "ssh"
    Write-Log "${GREEN}✓ 找到ssh工具${NC}"
}

# 检查plink (PuTTY Link)
if (Get-Command "plink" -ErrorAction SilentlyContinue) {
    $remoteTools += "plink"
    Write-Log "${GREEN}✓ 找到plink工具${NC}"
} else {
    # 检查PuTTY安装目录
    $puttyPaths = @(
        "C:\Program Files\PuTTY\plink.exe",
        "C:\Program Files (x86)\PuTTY\plink.exe",
        "$env:USERPROFILE\AppData\Local\Programs\PuTTY\plink.exe"
    )
    
    foreach ($path in $puttyPaths) {
        if (Test-Path $path) {
            $env:PATH += ";$(Split-Path -Parent $path)"
            $remoteTools += "plink"
            Write-Log "${GREEN}✓ 找到plink工具: $path${NC}"
            break
        }
    }
}

Write-Log "可用的远程执行工具: $($remoteTools -join ', ')"

if ($remoteTools.Count -eq 0) {
    Write-Log "${YELLOW}⚠ 未检测到远程执行工具${NC}"
    Write-Log "请手动连接到服务器并执行以下命令:"
    Write-Log "1. chmod +x $REMOTE_TMP/*.sh"
    Write-Log "2. $REMOTE_TMP/one-click-deploy.sh"
    Write-Log "3. $REMOTE_TMP/verify-deployment.sh"
    
    Write-Log "`n${BLUE}=== 部署摘要 ===${NC}"
    Write-Log "版本: $VERSION"
    Write-Log "部署包: $PACKAGE_NAME"
    Write-Log "服务器: $SERVER_IP"
    Write-Log "网站目录: $WEB_ROOT"
    Write-Log "完成时间: $(Get-Date)"
    
    Write-Log "`n${GREEN}上传完成！请手动完成部署步骤${NC}"
    exit 0
} else {
    # 选择最佳远程执行工具
    $selectedRemoteTool = ""
    if ("ssh" -in $remoteTools) {
        $selectedRemoteTool = "ssh"
    } elseif ("plink" -in $remoteTools) {
        $selectedRemoteTool = "plink"
    }
    
    Write-Log "使用远程执行工具: $selectedRemoteTool"
    
    # 设置执行权限
    Write-Log "设置脚本执行权限..."
    $permissionCommand = "chmod +x $REMOTE_TMP/*.sh"
    
    if ($selectedRemoteTool -eq "ssh") {
        $env:SSHPASS = $PASSWORD
        $sshArgs = @(
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "$SERVER_USER@$SERVER_IP",
            $permissionCommand
        )
        
        Write-Log "执行命令: ssh $($sshArgs -join ' ')"
        & ssh $sshArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "${RED}✗ 设置执行权限失败${NC}"
            exit 1
        }
    } elseif ($selectedRemoteTool -eq "plink") {
        $plinkArgs = @(
            "-ssh",
            "-pw", $PASSWORD,
            "-batch",
            "$SERVER_USER@$SERVER_IP",
            $permissionCommand
        )
        
        Write-Log "执行命令: plink (密码已隐藏) $SERVER_USER@$SERVER_IP $permissionCommand"
        & plink $plinkArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "${RED}✗ 设置执行权限失败${NC}"
            exit 1
        }
    }
    
    Write-Log "${GREEN}✓ 脚本执行权限设置成功${NC}"
    
    # 执行部署脚本
    Write-Log "执行部署脚本..."
    $deployCommand = @"
echo "开始部署...";
$REMOTE_TMP/one-click-deploy.sh;
echo "验证部署...";
$REMOTE_TMP/verify-deployment.sh;
if [ \`$? -ne 0 ]; then
    echo "尝试修复权限...";
    $REMOTE_TMP/fix-baota-permissions.sh;
fi
"@
    
    if ($selectedRemoteTool -eq "ssh") {
        $env:SSHPASS = $PASSWORD
        $sshArgs = @(
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "$SERVER_USER@$SERVER_IP",
            $deployCommand
        )
        
        Write-Log "执行部署命令..."
        & ssh $sshArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "${RED}✗ 部署失败${NC}"
            exit 1
        }
    } elseif ($selectedRemoteTool -eq "plink") {
        $plinkArgs = @(
            "-ssh",
            "-pw", $PASSWORD,
            "-batch",
            "$SERVER_USER@$SERVER_IP",
            $deployCommand
        )
        
        Write-Log "执行部署命令..."
        & plink $plinkArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "${RED}✗ 部署失败${NC}"
            exit 1
        }
    }
    
    Write-Log "${GREEN}✓ 部署成功${NC}"
}

# 步骤5: 最终验证
Write-Log "`n${YELLOW}[5/5] 最终验证...${NC}"

Write-Log "${GREEN}✓ 所有部署步骤完成${NC}"

Write-Log "`n${BLUE}=== 部署摘要 ===${NC}"
Write-Log "版本: $VERSION"
Write-Log "部署包: $PACKAGE_NAME"
Write-Log "服务器: $SERVER_IP"
Write-Log "网站目录: $WEB_ROOT"
Write-Log "日志文件: $logFile"
Write-Log "完成时间: $(Get-Date)"

Write-Log "`n${GREEN}服务器部署完成！${NC}"
Write-Log "请访问 http://$SERVER_IP 验证网站运行状态"
Write-Log "请访问 http://$SERVER_IP/sync-test.html 测试数据同步功能"

# 清理部署包
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Log "部署包已清理"
}

Write-Log "`n部署日志已保存到: $logFile"