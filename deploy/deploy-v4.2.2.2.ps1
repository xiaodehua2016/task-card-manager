# 小久任务管理系统 v4.2.2.2 部署脚本
# 更新日期: 2025-08-02

# 设置错误操作首选项
$ErrorActionPreference = "Stop"

# 定义日志函数
function Write-Log {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    Write-Host $logMessage
    
    # 如果是从一键部署脚本调用，日志已经被重定向到文件
}

# 创建部署包函数
function Create-Package {
    Write-Log "开始创建部署包..." "INFO"
    
    # 创建临时目录
    $tempDir = ".\temp_deploy"
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # 复制核心文件
    Write-Log "复制核心文件..." "INFO"
    
    # 复制HTML文件
    $htmlFiles = @("index.html", "edit-tasks.html", "focus-challenge.html", "statistics.html", "today-tasks.html", "sync-test.html")
    foreach ($file in $htmlFiles) {
        if (Test-Path $file) {
            Copy-Item $file -Destination $tempDir
            Write-Log "- 已复制: $file" "INFO"
        } else {
            Write-Log "- 跳过不存在的文件: $file" "WARN"
        }
    }
    
    # 复制配置文件
    $configFiles = @("manifest.json", "icon-192.svg", "favicon.ico")
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            Copy-Item $file -Destination $tempDir
            Write-Log "- 已复制: $file" "INFO"
        } else {
            Write-Log "- 跳过不存在的文件: $file" "WARN"
        }
    }
    
    # 复制CSS目录
    if (Test-Path "css") {
        Copy-Item -Path "css" -Destination "$tempDir\css" -Recurse
        Write-Log "✅ CSS文件已复制" "INFO"
    } else {
        Write-Log "CSS目录不存在，已跳过" "WARN"
        New-Item -ItemType Directory -Path "$tempDir\css" -Force | Out-Null
    }
    
    # 复制JS目录
    if (Test-Path "js") {
        Copy-Item -Path "js" -Destination "$tempDir\js" -Recurse
        Write-Log "✅ JS文件已复制" "INFO"
    } else {
        Write-Log "JS目录不存在，已跳过" "WARN"
        New-Item -ItemType Directory -Path "$tempDir\js" -Force | Out-Null
    }
    
    # 复制API目录
    if (Test-Path "api") {
        Copy-Item -Path "api" -Destination "$tempDir\api" -Recurse
        Write-Log "✅ API文件已复制" "INFO"
    } else {
        Write-Log "API目录不存在，已跳过" "WARN"
        New-Item -ItemType Directory -Path "$tempDir\api" -Force | Out-Null
    }
    
    # 创建数据目录和默认数据
    if (Test-Path "data") {
        Copy-Item -Path "data" -Destination "$tempDir\data" -Recurse
        Write-Log "✅ 数据文件已复制" "INFO"
    } else {
        Write-Log "数据目录不存在，已创建" "WARN"
        New-Item -ItemType Directory -Path "$tempDir\data" -Force | Out-Null
        
        # 创建默认数据文件
        $defaultData = @{
            tasks = @{
                templates = @(
                    @{ name = "学习任务"; type = "daily" },
                    @{ name = "工作任务"; type = "daily" },
                    @{ name = "阅读30分钟"; type = "daily" },
                    @{ name = "锻炼30分钟"; type = "daily" },
                    @{ name = "写作练习"; type = "daily" }
                )
            }
            dailyTasks = @{}
            completionHistory = @{}
            taskTimes = @{}
            focusRecords = @{}
        }
        
        $defaultDataJson = ConvertTo-Json $defaultData -Depth 10
        Set-Content -Path "$tempDir\data\shared-tasks.json" -Value $defaultDataJson -Encoding UTF8
        Write-Log "✅ 已创建默认数据文件" "INFO"
    }
    
    # 创建README文件
    if (Test-Path "data\README.md") {
        Copy-Item "data\README.md" -Destination "$tempDir\data\"
    } else {
        $readmeContent = @"
# 小久任务管理系统 v4.2.2.2

## 数据目录说明

此目录存放系统运行所需的数据文件:

- shared-tasks.json: 共享任务数据，包含任务模板和完成记录
- 其他JSON文件: 系统自动生成的数据文件

请勿手动修改这些文件，以免导致数据损坏。
"@
        Set-Content -Path "$tempDir\data\README.md" -Value $readmeContent -Encoding UTF8
        Write-Log "✅ 已创建README文件" "INFO"
    }
    
    # 创建ZIP包
    $zipFileName = "task-manager-v4.2.2.2-complete.zip"
    if (Test-Path $zipFileName) {
        Remove-Item $zipFileName -Force
    }
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFileName)
    
    # 获取ZIP包大小
    $fileInfo = Get-Item $zipFileName
    $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
    
    # 清理临时目录
    Remove-Item -Path $tempDir -Recurse -Force
    
    Write-Log "✅ 完整部署包创建成功: $zipFileName" "INFO"
    Write-Log "📊 包大小: $($fileInfo.Length) 字节" "INFO"
    
    return $zipFileName
}

# 部署到服务器函数
function Deploy-ToServer {
    param (
        [string]$ZipFile,
        [string]$ServerIP = "115.159.5.111",
        [string]$Username = "root",
        [string]$Password,
        [string]$RemotePath = "/www/wwwroot/task-manager/"
    )
    
    Write-Log "开始部署到服务器 $ServerIP..." "INFO"
    
    # 检查ZIP文件是否存在
    if (-not (Test-Path $ZipFile)) {
        Write-Log "错误: 部署包 $ZipFile 不存在" "ERROR"
        return $false
    }
    
    # 提示输入密码
    if (-not $Password) {
        $securePassword = Read-Host "请输入服务器密码" -AsSecureString
        $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
    }
    
    try {
        # 创建SFTP会话
        Write-Log "正在连接到服务器..." "INFO"
        
        # 这里需要使用实际的SFTP库，例如Posh-SSH
        # 由于PowerShell Core不自带SFTP功能，这里提供一个示例实现
        # 实际部署时需要安装Posh-SSH模块
        
        Write-Log "检查是否安装了Posh-SSH模块..." "INFO"
        if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
            Write-Log "Posh-SSH模块未安装，尝试安装..." "WARN"
            try {
                Install-Module -Name Posh-SSH -Force -Scope CurrentUser
                Write-Log "✅ Posh-SSH模块安装成功" "INFO"
            }
            catch {
                Write-Log "❌ 无法安装Posh-SSH模块: $_" "ERROR"
                Write-Log "请手动安装Posh-SSH模块后重试，或使用手动部署方式" "ERROR"
                return $false
            }
        }
        
        # 导入Posh-SSH模块
        Import-Module Posh-SSH
        
        # 创建凭据
        $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)
        
        # 创建SFTP会话
        $session = New-SSHSession -ComputerName $ServerIP -Credential $credentials -AcceptKey
        
        if ($session) {
            Write-Log "✅ 成功连接到服务器" "INFO"
            
            # 创建SFTP会话
            $sftpSession = New-SFTPSession -ComputerName $ServerIP -Credential $credentials
            
            # 上传ZIP文件
            Write-Log "正在上传部署包..." "INFO"
            $remoteZipPath = "/tmp/$ZipFile"
            Set-SFTPItem -SFTPSession $sftpSession -Path $ZipFile -Destination "/tmp/" -Force
            
            Write-Log "✅ 部署包上传成功" "INFO"
            
            # 执行远程命令解压文件
            Write-Log "正在解压部署包..." "INFO"
            $command = "mkdir -p $RemotePath && unzip -o $remoteZipPath -d $RemotePath && chown -R www:www $RemotePath && chmod -R 755 $RemotePath"
            $result = Invoke-SSHCommand -SSHSession $session -Command $command
            
            if ($result.ExitStatus -eq 0) {
                Write-Log "✅ 部署包解压成功" "INFO"
                
                # 清理远程临时文件
                Invoke-SSHCommand -SSHSession $session -Command "rm -f $remoteZipPath"
                
                Write-Log "✅ 部署完成" "INFO"
                Write-Log "🌐 网站地址: http://$ServerIP/" "INFO"
                Write-Log "🧪 测试地址: http://$ServerIP/sync-test.html" "INFO"
            }
            else {
                Write-Log "❌ 部署包解压失败: $($result.Output)" "ERROR"
                return $false
            }
            
            # 关闭会话
            Remove-SSHSession -SSHSession $session | Out-Null
            Remove-SFTPSession -SFTPSession $sftpSession | Out-Null
            
            return $true
        }
        else {
            Write-Log "❌ 无法连接到服务器" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "❌ 部署过程中出现错误: $_" "ERROR"
        return $false
    }
}

# 主函数
function Main {
    Write-Log "小久任务管理系统 v4.2.2.2 自动部署开始" "INFO"
    
    # 创建部署包
    $zipFile = Create-Package
    
    # 部署到服务器
    $deployResult = Deploy-ToServer -ZipFile $zipFile
    
    if ($deployResult) {
        Write-Log "🎉 部署成功完成！" "INFO"
        return 0
    }
    else {
        Write-Log "❌ 部署失败，请查看上方错误信息" "ERROR"
        return 1
    }
}

# 如果直接运行脚本，则执行Main函数
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Main
    exit $LASTEXITCODE
}