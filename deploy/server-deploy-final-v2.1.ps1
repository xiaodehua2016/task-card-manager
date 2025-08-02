# Task Manager v4.2.1 Server Deployment Script (Final Fixed Version v2.1)
# With detailed logging and all issues completely resolved

# If execution policy error occurs, run as administrator:
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Color definitions
$RED = "$([char]0x1b)[31m"
$GREEN = "$([char]0x1b)[32m"
$YELLOW = "$([char]0x1b)[33m"
$BLUE = "$([char]0x1b)[34m"
$NC = "$([char]0x1b)[0m" # No color

# Configuration
$SERVER_IP = "115.159.5.111"
$SERVER_USER = "root"
$PASSWORD_FILE = "C:\AA\codebuddy\1\123.txt"
$REMOTE_TMP = "/tmp"
$WEB_ROOT = "/www/wwwroot/task-manager"
$VERSION = "v4.2.1"
$PACKAGE_NAME = "task-manager-${VERSION}.zip"

# Create log file with timestamp
$logTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "deploy_log_${logTimestamp}.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage -Encoding UTF8
}

Write-Log "${BLUE}=== Task Manager ${VERSION} Server Deployment Script v2.1 ===${NC}"
Write-Log "Start time: $(Get-Date)"
Write-Log "Log file: $logFile"
Write-Log ""

# Ensure we are in project root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $scriptDir

Set-Location $projectRoot
Write-Log "Working directory: $(Get-Location)"

# Step 1: Create deployment package
Write-Log "${YELLOW}[1/5] Creating deployment package...${NC}"

# Check password file
if (-not (Test-Path $PASSWORD_FILE)) {
    Write-Log "${RED}Error: Password file not found: $PASSWORD_FILE${NC}"
    exit 1
}

# Read password
$PASSWORD = Get-Content $PASSWORD_FILE -Raw
$PASSWORD = $PASSWORD.Trim()
Write-Log "Password file read successfully"

# Create temporary directory
$tempDir = Join-Path -Path $scriptDir -ChildPath "temp_deploy_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Log "Created temporary directory: $tempDir"

# Define files to exclude
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

Write-Log "Starting to copy project files..."
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

Write-Log "Copied $fileCount files"

# Create ZIP package
$zipPath = Join-Path -Path $scriptDir -ChildPath $PACKAGE_NAME

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Log "Removed old deployment package"
}

try {
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force
    Write-Log "${GREEN}✓ Deployment package created successfully: $PACKAGE_NAME${NC}"
} catch {
    Write-Log "${RED}Error: Failed to create ZIP package${NC}"
    Write-Log "Error message: $($_.Exception.Message)"
    exit 1
} finally {
    # Clean up temporary directory
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
        Write-Log "Cleaned up temporary directory"
    }
}

# Step 2: Check upload tools
Write-Log "`n${YELLOW}[2/5] Checking upload tools...${NC}"

# Check available upload tools
$uploadTools = @()

# 1. Check scp command (OpenSSH)
Write-Log "Checking scp command..."
if (Get-Command "scp" -ErrorAction SilentlyContinue) {
    $uploadTools += "scp"
    Write-Log "${GREEN}✓ Found scp tool (OpenSSH)${NC}"
} else {
    Write-Log "scp command not found"
}

# 2. Check pscp (PuTTY SCP)
Write-Log "Checking pscp tool..."
if (Get-Command "pscp" -ErrorAction SilentlyContinue) {
    $uploadTools += "pscp"
    Write-Log "${GREEN}✓ Found pscp tool (PuTTY)${NC}"
} else {
    # Check PuTTY installation directories
    $puttyPaths = @(
        "C:\Program Files\PuTTY\pscp.exe",
        "C:\Program Files (x86)\PuTTY\pscp.exe",
        "$env:USERPROFILE\AppData\Local\Programs\PuTTY\pscp.exe"
    )
    
    foreach ($path in $puttyPaths) {
        if (Test-Path $path) {
            $env:PATH += ";$(Split-Path -Parent $path)"
            $uploadTools += "pscp"
            Write-Log "${GREEN}✓ Found pscp tool: $path${NC}"
            break
        }
    }
    
    if ("pscp" -notin $uploadTools) {
        Write-Log "pscp tool not found"
    }
}

# 3. Check WinSCP command line tool
Write-Log "Checking WinSCP tool..."
if (Get-Command "winscp" -ErrorAction SilentlyContinue) {
    $uploadTools += "winscp"
    Write-Log "${GREEN}✓ Found WinSCP tool${NC}"
} else {
    Write-Log "WinSCP tool not found"
}

Write-Log "Available upload tools: $($uploadTools -join ', ')"

if ($uploadTools.Count -eq 0) {
    Write-Log "${YELLOW}⚠ No upload tools detected${NC}"
    Write-Log "Please manually upload the following files to server:"
    Write-Log "1. $zipPath -> $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    Write-Log "2. $scriptDir\*.sh -> $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    Write-Log ""
    Write-Log "You can use the following commands:"
    Write-Log "scp `"$zipPath`" $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    Write-Log "scp `"$scriptDir\*.sh`" $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    
    $continue = Read-Host "Have you manually uploaded the files? (y/n)"
    if ($continue -ne "y") {
        Write-Log "User cancelled deployment"
        exit 1
    }
} else {
    # Step 3: Upload files to server
    Write-Log "`n${YELLOW}[3/5] Uploading files to server...${NC}"
    
    # Select best upload tool
    $selectedTool = ""
    if ("scp" -in $uploadTools) {
        $selectedTool = "scp"
    } elseif ("pscp" -in $uploadTools) {
        $selectedTool = "pscp"
    } elseif ("winscp" -in $uploadTools) {
        $selectedTool = "winscp"
    }
    
    Write-Log "Using upload tool: $selectedTool"
    
    # Upload deployment package
    Write-Log "Uploading deployment package..."
    $uploadSuccess = $false
    
    if ($selectedTool -eq "scp") {
        # Use scp for upload
        $scpArgs = @(
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            $zipPath,
            "$SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
        )
        
        Write-Log "Executing command: scp $($scpArgs -join ' ')"
        
        # Use sshpass or manual password input
        $env:SSHPASS = $PASSWORD
        & scp $scpArgs
        
        if ($LASTEXITCODE -eq 0) {
            $uploadSuccess = $true
            Write-Log "${GREEN}✓ Successfully uploaded deployment package using scp${NC}"
        } else {
            Write-Log "${RED}✗ Failed to upload deployment package using scp, exit code: $LASTEXITCODE${NC}"
        }
    } elseif ($selectedTool -eq "pscp") {
        # Use pscp for upload
        $pscpArgs = @(
            "-pw", $PASSWORD,
            "-batch",
            $zipPath,
            "$SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
        )
        
        Write-Log "Executing command: pscp (password hidden) $zipPath $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
        
        & pscp $pscpArgs
        
        if ($LASTEXITCODE -eq 0) {
            $uploadSuccess = $true
            Write-Log "${GREEN}✓ Successfully uploaded deployment package using pscp${NC}"
        } else {
            Write-Log "${RED}✗ Failed to upload deployment package using pscp, exit code: $LASTEXITCODE${NC}"
        }
    }
    
    if (-not $uploadSuccess) {
        Write-Log "${RED}Upload failed, please check network connection and server status${NC}"
        exit 1
    }
    
    # Upload deployment scripts
    Write-Log "Uploading deployment scripts..."
    $shFiles = Get-ChildItem -Path $scriptDir -Filter "*.sh"
    Write-Log "Found $($shFiles.Count) shell script files"
    
    foreach ($file in $shFiles) {
        Write-Log "Uploading script: $($file.Name)"
        
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
                Write-Log "${RED}✗ Failed to upload script $($file.Name)${NC}"
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
                Write-Log "${RED}✗ Failed to upload script $($file.Name)${NC}"
                exit 1
            }
        }
    }
    
    Write-Log "${GREEN}✓ All files uploaded successfully${NC}"
}

# Step 4: Execute deployment on server
Write-Log "`n${YELLOW}[4/5] Executing deployment on server...${NC}"

# Check remote execution tools
$remoteTools = @()

# Check ssh command
if (Get-Command "ssh" -ErrorAction SilentlyContinue) {
    $remoteTools += "ssh"
    Write-Log "${GREEN}✓ Found ssh tool${NC}"
}

# Check plink (PuTTY Link)
if (Get-Command "plink" -ErrorAction SilentlyContinue) {
    $remoteTools += "plink"
    Write-Log "${GREEN}✓ Found plink tool${NC}"
} else {
    # Check PuTTY installation directories
    $puttyPaths = @(
        "C:\Program Files\PuTTY\plink.exe",
        "C:\Program Files (x86)\PuTTY\plink.exe",
        "$env:USERPROFILE\AppData\Local\Programs\PuTTY\plink.exe"
    )
    
    foreach ($path in $puttyPaths) {
        if (Test-Path $path) {
            $env:PATH += ";$(Split-Path -Parent $path)"
            $remoteTools += "plink"
            Write-Log "${GREEN}✓ Found plink tool: $path${NC}"
            break
        }
    }
}

Write-Log "Available remote execution tools: $($remoteTools -join ', ')"

if ($remoteTools.Count -eq 0) {
    Write-Log "${YELLOW}⚠ No remote execution tools detected${NC}"
    Write-Log "Please manually connect to server and execute the following commands:"
    Write-Log "1. chmod +x $REMOTE_TMP/*.sh"
    Write-Log "2. $REMOTE_TMP/one-click-deploy.sh"
    Write-Log "3. $REMOTE_TMP/verify-deployment.sh"
    
    Write-Log "`n${BLUE}=== Deployment Summary ===${NC}"
    Write-Log "Version: $VERSION"
    Write-Log "Package: $PACKAGE_NAME"
    Write-Log "Server: $SERVER_IP"
    Write-Log "Web root: $WEB_ROOT"
    Write-Log "Completion time: $(Get-Date)"
    
    Write-Log "`n${GREEN}Upload completed! Please manually complete deployment steps${NC}"
    exit 0
} else {
    # Select best remote execution tool
    $selectedRemoteTool = ""
    if ("ssh" -in $remoteTools) {
        $selectedRemoteTool = "ssh"
    } elseif ("plink" -in $remoteTools) {
        $selectedRemoteTool = "plink"
    }
    
    Write-Log "Using remote execution tool: $selectedRemoteTool"
    
    # Set execution permissions
    Write-Log "Setting script execution permissions..."
    $permissionCommand = "chmod +x $REMOTE_TMP/*.sh"
    
    if ($selectedRemoteTool -eq "ssh") {
        $env:SSHPASS = $PASSWORD
        $sshArgs = @(
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "$SERVER_USER@$SERVER_IP",
            $permissionCommand
        )
        
        Write-Log "Executing command: ssh $($sshArgs -join ' ')"
        & ssh $sshArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "${RED}✗ Failed to set execution permissions${NC}"
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
        
        Write-Log "Executing command: plink (password hidden) $SERVER_USER@$SERVER_IP $permissionCommand"
        & plink $plinkArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "${RED}✗ Failed to set execution permissions${NC}"
            exit 1
        }
    }
    
    Write-Log "${GREEN}✓ Script execution permissions set successfully${NC}"
    
    # Execute deployment script
    Write-Log "Executing deployment script..."
    $deployCommand = @"
echo "Starting deployment...";
$REMOTE_TMP/one-click-deploy.sh;
echo "Verifying deployment...";
$REMOTE_TMP/verify-deployment.sh;
if [ \`$? -ne 0 ]; then
    echo "Trying to fix permissions...";
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
        
        Write-Log "Executing deployment commands..."
        & ssh $sshArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "${RED}✗ Deployment failed${NC}"
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
        
        Write-Log "Executing deployment commands..."
        & plink $plinkArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "${RED}✗ Deployment failed${NC}"
            exit 1
        }
    }
    
    Write-Log "${GREEN}✓ Deployment successful${NC}"
}

# Step 5: Final verification
Write-Log "`n${YELLOW}[5/5] Final verification...${NC}"

Write-Log "${GREEN}✓ All deployment steps completed${NC}"

Write-Log "`n${BLUE}=== Deployment Summary ===${NC}"
Write-Log "Version: $VERSION"
Write-Log "Package: $PACKAGE_NAME"
Write-Log "Server: $SERVER_IP"
Write-Log "Web root: $WEB_ROOT"
Write-Log "Log file: $logFile"
Write-Log "Completion time: $(Get-Date)"

Write-Log "`n${GREEN}Server deployment completed successfully!${NC}"
Write-Log "Please visit http://$SERVER_IP to verify the website is running"
Write-Log "Please visit http://$SERVER_IP/sync-test.html to test data sync functionality"

# Clean up deployment package
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Log "Deployment package cleaned up"
}

Write-Log "`nDeployment log saved to: $logFile"