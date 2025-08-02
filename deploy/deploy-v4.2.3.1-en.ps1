# Task Manager System v4.2.3 Deployment Script
# Update Date: 2025-08-02

# Set error action preference
$ErrorActionPreference = "Stop"

# Define log function
function Write-Log {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    Write-Host $logMessage
    
    # If called from one-click deployment script, logs are already redirected to file
}

# Create deployment package function
function Create-Package {
    Write-Log "Starting to create deployment package..." "INFO"
    
    # Create temporary directory
    $tempDir = ".\temp_deploy"
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Copy core files
    Write-Log "Copying core files..." "INFO"
    
    # Copy HTML files
    $htmlFiles = @("index.html", "edit-tasks.html", "focus-challenge.html", "statistics.html", "today-tasks.html", "sync-test.html")
    foreach ($file in $htmlFiles) {
        if (Test-Path $file) {
            Copy-Item $file -Destination $tempDir
            Write-Log "- Copied: $file" "INFO"
        } else {
            Write-Log "- Skipped non-existent file: $file" "WARN"
        }
    }
    
    # Copy config files
    $configFiles = @("manifest.json", "icon-192.svg", "favicon.ico")
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            Copy-Item $file -Destination $tempDir
            Write-Log "- Copied: $file" "INFO"
        } else {
            Write-Log "- Skipped non-existent file: $file" "WARN"
        }
    }
    
    # Copy CSS directory
    if (Test-Path "css") {
        Copy-Item -Path "css" -Destination "$tempDir\css" -Recurse
        Write-Log "CSS files copied successfully" "INFO"
    } else {
        Write-Log "CSS directory does not exist, skipped" "WARN"
        New-Item -ItemType Directory -Path "$tempDir\css" -Force | Out-Null
    }
    
    # Copy JS directory
    if (Test-Path "js") {
        Copy-Item -Path "js" -Destination "$tempDir\js" -Recurse
        Write-Log "JS files copied successfully" "INFO"
    } else {
        Write-Log "JS directory does not exist, skipped" "WARN"
        New-Item -ItemType Directory -Path "$tempDir\js" -Force | Out-Null
    }
    
    # Copy API directory
    if (Test-Path "api") {
        Copy-Item -Path "api" -Destination "$tempDir\api" -Recurse
        Write-Log "API files copied successfully" "INFO"
    } else {
        Write-Log "API directory does not exist, skipped" "WARN"
        New-Item -ItemType Directory -Path "$tempDir\api" -Force | Out-Null
    }
    
    # Create data directory and default data
    if (Test-Path "data") {
        Copy-Item -Path "data" -Destination "$tempDir\data" -Recurse
        Write-Log "Data files copied successfully" "INFO"
    } else {
        Write-Log "Data directory does not exist, created" "WARN"
        New-Item -ItemType Directory -Path "$tempDir\data" -Force | Out-Null
        
        # Create default data file
        $defaultData = @{
            version = "4.2.3"
            lastUpdateTime = [long](Get-Date -UFormat %s) * 1000
            tasks = @(
                "学习任务",
                "工作任务",
                "阅读30分钟",
                "锻炼30分钟",
                "写作练习"
            )
            taskTemplates = @{
                daily = @(
                    "学习任务",
                    "工作任务",
                    "阅读30分钟",
                    "锻炼30分钟",
                    "写作练习"
                )
            }
            dailyTasks = @{}
            completionHistory = @{}
            taskTimes = @{}
            focusRecords = @{}
        }
        
        $defaultDataJson = ConvertTo-Json $defaultData -Depth 10
        Set-Content -Path "$tempDir\data\shared-tasks.json" -Value $defaultDataJson -Encoding UTF8
        Write-Log "Default data file created" "INFO"
    }
    
    # Create README file
    if (Test-Path "data\README.md") {
        Copy-Item "data\README.md" -Destination "$tempDir\data\"
    } else {
        $readmeContent = @"
# 小久任务管理系统 v4.2.3

## 数据目录说明

此目录存放系统运行所需的数据文件:

- shared-tasks.json: 共享任务数据，包含任务模板和完成记录
- 其他JSON文件: 系统自动生成的数据文件

请勿手动修改这些文件，以免导致数据损坏。
"@
        Set-Content -Path "$tempDir\data\README.md" -Value $readmeContent -Encoding UTF8
        Write-Log "README file created" "INFO"
    }
    
    # Create ZIP package
    $zipFileName = "task-manager-v4.2.3-complete.zip"
    if (Test-Path $zipFileName) {
        Remove-Item $zipFileName -Force
    }
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFileName)
    
    # Get ZIP package size
    $fileInfo = Get-Item $zipFileName
    $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
    
    # Clean up temporary directory
    Remove-Item -Path $tempDir -Recurse -Force
    
    Write-Log "Deployment package created successfully: $zipFileName" "INFO"
    Write-Log "Package size: $($fileInfo.Length) bytes" "INFO"
    
    return $zipFileName
}

# Deploy to server function
function Deploy-ToServer {
    param (
        [string]$ZipFile,
        [string]$ServerIP = "115.159.5.111",
        [string]$Username = "root",
        [string]$Password,
        [string]$RemotePath = "/www/wwwroot/task-manager/"
    )
    
    Write-Log "Starting deployment to server $ServerIP..." "INFO"
    
    # Check if ZIP file exists
    if (-not (Test-Path $ZipFile)) {
        Write-Log "Error: Deployment package $ZipFile does not exist" "ERROR"
        return $false
    }
    
    # Prompt for password
    if (-not $Password) {
        $securePassword = Read-Host "Please enter server password" -AsSecureString
        $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
    }
    
    try {
        # Create SFTP session
        Write-Log "Connecting to server..." "INFO"
        
        # Need to use actual SFTP library, such as Posh-SSH
        # Since PowerShell Core does not include SFTP functionality, here's a sample implementation
        # For actual deployment, need to install Posh-SSH module
        
        Write-Log "Checking if Posh-SSH module is installed..." "INFO"
        if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
            Write-Log "Posh-SSH module not installed, attempting to install..." "WARN"
            try {
                Install-Module -Name Posh-SSH -Force -Scope CurrentUser
                Write-Log "Posh-SSH module installed successfully" "INFO"
            }
            catch {
                Write-Log "Cannot install Posh-SSH module: $_" "ERROR"
                Write-Log "Please install Posh-SSH module manually and try again, or use manual deployment method" "ERROR"
                return $false
            }
        }
        
        # Import Posh-SSH module
        Import-Module Posh-SSH
        
        # Create credentials
        $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)
        
        # Create SSH session
        $session = New-SSHSession -ComputerName $ServerIP -Credential $credentials -AcceptKey
        
        if ($session) {
            Write-Log "Successfully connected to server" "INFO"
            
            # Create SFTP session
            $sftpSession = New-SFTPSession -ComputerName $ServerIP -Credential $credentials
            
            # Upload ZIP file
            Write-Log "Uploading deployment package..." "INFO"
            $remoteZipPath = "/tmp/$ZipFile"
            Set-SFTPItem -SFTPSession $sftpSession -Path $ZipFile -Destination "/tmp/" -Force
            
            Write-Log "Deployment package uploaded successfully" "INFO"
            
            # Execute remote command to extract file
            Write-Log "Extracting deployment package..." "INFO"
            $command = "mkdir -p $RemotePath && unzip -o $remoteZipPath -d $RemotePath && chown -R www:www $RemotePath && chmod -R 755 $RemotePath"
            $result = Invoke-SSHCommand -SSHSession $session -Command $command
            
            if ($result.ExitStatus -eq 0) {
                Write-Log "Deployment package extracted successfully" "INFO"
                
                # Clean up remote temporary file
                Invoke-SSHCommand -SSHSession $session -Command "rm -f $remoteZipPath"
                
                Write-Log "Deployment completed" "INFO"
                Write-Log "Website URL: http://$ServerIP/" "INFO"
                Write-Log "Test URL: http://$ServerIP/sync-test.html" "INFO"
            }
            else {
                Write-Log "Failed to extract deployment package: $($result.Output)" "ERROR"
                return $false
            }
            
            # Close sessions
            Remove-SSHSession -SSHSession $session | Out-Null
            Remove-SFTPSession -SFTPSession $sftpSession | Out-Null
            
            return $true
        }
        else {
            Write-Log "Cannot connect to server" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Error during deployment: $_" "ERROR"
        return $false
    }
}

# Main function
function Main {
    Write-Log "Task Manager System v4.2.3 Automatic Deployment Started" "INFO"
    
    # Create deployment package
    $zipFile = Create-Package
    
    # Deploy to server
    $deployResult = Deploy-ToServer -ZipFile $zipFile
    
    if ($deployResult) {
        Write-Log "Deployment completed successfully!" "INFO"
        return 0
    }
    else {
        Write-Log "Deployment failed, please check error messages above" "ERROR"
        return 1
    }
}

# If script is run directly, execute Main function
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Main
    exit $LASTEXITCODE
}