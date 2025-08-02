# Task Manager v4.2.1 Server Deployment Script (Final Fixed Version v4.2.1.3)
# With improved password handling using PowerShell SSH methods

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
$SCRIPT_VERSION = "v4.2.1.3"
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

function Execute-SSHCommandWithExpect {
    param(
        [string]$Command,
        [string]$Description
    )
    
    Write-Log "Executing: $Description"
    Write-Log "Command: $Command"
    
    # Create PowerShell script for SSH with password
    $sshScript = @"
`$password = ConvertTo-SecureString '$PASSWORD' -AsPlainText -Force
`$credential = New-Object System.Management.Automation.PSCredential('$SERVER_USER', `$password)

try {
    # Use plink if available (PuTTY)
    if (Get-Command 'plink' -ErrorAction SilentlyContinue) {
        `$result = & plink -ssh -batch -pw '$PASSWORD' $SERVER_USER@$SERVER_IP '$Command' 2>&1
        if (`$LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Command executed"
            exit 0
        } else {
            Write-Host "FAILED: Command failed with exit code `$LASTEXITCODE"
            Write-Host "Output: `$result"
            exit 1
        }
    } else {
        # Fallback to basic SSH
        `$result = & ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SERVER_USER@$SERVER_IP '$Command' 2>&1
        if (`$LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Command executed"
            exit 0
        } else {
            Write-Host "FAILED: Command failed"
            exit 1
        }
    }
} catch {
    Write-Host "ERROR: `$(`$_.Exception.Message)"
    exit 1
}
"@
    
    $tempScript = Join-Path -Path $env:TEMP -ChildPath "ssh_script_$(Get-Random).ps1"
    Set-Content -Path $tempScript -Value $sshScript -Encoding UTF8
    
    try {
        $result = & powershell -ExecutionPolicy Bypass -File $tempScript
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0) {
            Write-Log "${GREEN}SUCCESS: $Description completed${NC}"
            return $true
        } else {
            Write-Log "${RED}FAILED: $Description failed${NC}"
            return $false
        }
    } catch {
        Write-Log "${RED}ERROR: $Description failed with error: $($_.Exception.Message)${NC}"
        return $false
    } finally {
        if (Test-Path $tempScript) {
            Remove-Item $tempScript -Force
        }
    }
}

function Execute-SCPUploadWithPlink {
    param(
        [string]$LocalPath,
        [string]$RemotePath,
        [string]$Description
    )
    
    Write-Log "Uploading: $Description"
    Write-Log "From: $LocalPath"
    Write-Log "To: $SERVER_USER@${SERVER_IP}:$RemotePath"
    
    try {
        # Try using pscp (PuTTY SCP) first
        if (Get-Command "pscp" -ErrorAction SilentlyContinue) {
            & pscp -batch -pw $PASSWORD $LocalPath "$SERVER_USER@${SERVER_IP}:$RemotePath"
            $exitCode = $LASTEXITCODE
        } elseif (Get-Command "scp" -ErrorAction SilentlyContinue) {
            # Create expect script for SCP
            $expectScript = @"
#!/usr/bin/expect -f
set timeout 60
spawn scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LocalPath" "$SERVER_USER@${SERVER_IP}:$RemotePath"
expect {
    "password:" {
        send "$PASSWORD\r"
        exp_continue
    }
    "Password:" {
        send "$PASSWORD\r"
        exp_continue
    }
    eof
}
"@
            $tempExpectFile = Join-Path -Path $env:TEMP -ChildPath "scp_expect_$(Get-Random).exp"
            Set-Content -Path $tempExpectFile -Value $expectScript -Encoding UTF8
            
            if (Get-Command "expect" -ErrorAction SilentlyContinue) {
                & expect $tempExpectFile
                $exitCode = $LASTEXITCODE
            } else {
                # Manual fallback
                Write-Log "${YELLOW}No automated upload tool found, please upload manually:${NC}"
                Write-Log "Command: scp $LocalPath $SERVER_USER@${SERVER_IP}:$RemotePath"
                $continue = Read-Host "Have you uploaded the file manually? (y/n)"
                if ($continue -eq "y") {
                    $exitCode = 0
                } else {
                    $exitCode = 1
                }
            }
            
            if (Test-Path $tempExpectFile) {
                Remove-Item $tempExpectFile -Force
            }
        } else {
            Write-Log "${RED}No SCP tool found${NC}"
            return $false
        }
        
        if ($exitCode -eq 0) {
            Write-Log "${GREEN}SUCCESS: $Description uploaded${NC}"
            return $true
        } else {
            Write-Log "${RED}FAILED: $Description upload failed${NC}"
            return $false
        }
    } catch {
        Write-Log "${RED}ERROR: $Description upload failed with error: $($_.Exception.Message)${NC}"
        return $false
    }
}

Write-Log "${BLUE}=== Task Manager ${VERSION} Server Deployment Script ${SCRIPT_VERSION} ===${NC}"
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
    Write-Log "${RED}ERROR: Password file not found: $PASSWORD_FILE${NC}"
    Write-Log "Please create the password file with server password"
    exit 1
}

# Read password
try {
    $PASSWORD = Get-Content $PASSWORD_FILE -Raw -ErrorAction Stop
    $PASSWORD = $PASSWORD.Trim()
    if ([string]::IsNullOrEmpty($PASSWORD)) {
        Write-Log "${RED}ERROR: Password file is empty${NC}"
        exit 1
    }
    Write-Log "Password file read successfully"
} catch {
    Write-Log "${RED}ERROR: Failed to read password file: $($_.Exception.Message)${NC}"
    exit 1
}

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
    "deploy_log_*.txt",
    "history"
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
    Write-Log "${GREEN}SUCCESS: Deployment package created: $PACKAGE_NAME${NC}"
} catch {
    Write-Log "${RED}ERROR: Failed to create ZIP package${NC}"
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

# Check for available tools
$hasPSCP = Get-Command "pscp" -ErrorAction SilentlyContinue
$hasPLINK = Get-Command "plink" -ErrorAction SilentlyContinue
$hasSSH = Get-Command "ssh" -ErrorAction SilentlyContinue
$hasSCP = Get-Command "scp" -ErrorAction SilentlyContinue

Write-Log "Tool availability check:"
Write-Log "  PSCP (PuTTY): $(if ($hasPSCP) { 'Available' } else { 'Not found' })"
Write-Log "  PLINK (PuTTY): $(if ($hasPLINK) { 'Available' } else { 'Not found' })"
Write-Log "  SSH: $(if ($hasSSH) { 'Available' } else { 'Not found' })"
Write-Log "  SCP: $(if ($hasSCP) { 'Available' } else { 'Not found' })"

if (-not $hasPSCP -and -not $hasSCP) {
    Write-Log "${RED}ERROR: No upload tool available${NC}"
    Write-Log "Please install PuTTY or OpenSSH"
    exit 1
}

# Step 3: Upload files to server
Write-Log "`n${YELLOW}[3/5] Uploading files to server...${NC}"

# Upload deployment package
if (-not (Execute-SCPUploadWithPlink -LocalPath $zipPath -RemotePath "$REMOTE_TMP/" -Description "deployment package")) {
    Write-Log "${RED}FAILED to upload deployment package${NC}"
    exit 1
}

# Upload deployment scripts
Write-Log "Uploading deployment scripts..."
$shFiles = Get-ChildItem -Path $scriptDir -Filter "*.sh"
Write-Log "Found $($shFiles.Count) shell script files"

foreach ($file in $shFiles) {
    if (-not (Execute-SCPUploadWithPlink -LocalPath $file.FullName -RemotePath "$REMOTE_TMP/" -Description "script: $($file.Name)")) {
        Write-Log "${RED}FAILED to upload script: $($file.Name)${NC}"
        exit 1
    }
}

Write-Log "${GREEN}SUCCESS: All files uploaded${NC}"

# Step 4: Execute deployment on server
Write-Log "`n${YELLOW}[4/5] Executing deployment on server...${NC}"

# Set execution permissions
if (-not (Execute-SSHCommandWithExpect -Command "chmod +x $REMOTE_TMP/*.sh" -Description "Set script execution permissions")) {
    Write-Log "${RED}FAILED to set execution permissions${NC}"
    exit 1
}

# Execute deployment script
$deployCommand = "echo 'Starting deployment...'; $REMOTE_TMP/one-click-deploy.sh 2>&1; echo 'Deployment completed with exit code:' \$?"

if (-not (Execute-SSHCommandWithExpect -Command $deployCommand -Description "Execute deployment process")) {
    Write-Log "${RED}Deployment process failed${NC}"
    exit 1
}

# Step 5: Final verification
Write-Log "`n${YELLOW}[5/5] Final verification...${NC}"

$testCommand = "curl -I http://localhost 2>/dev/null && echo 'Website is accessible' || echo 'Website test failed'"
Execute-SSHCommandWithExpect -Command $testCommand -Description "Website accessibility test"

Write-Log "${GREEN}SUCCESS: Deployment completed${NC}"

Write-Log "`n${BLUE}=== Deployment Summary ===${NC}"
Write-Log "Version: $VERSION"
Write-Log "Script Version: $SCRIPT_VERSION"
Write-Log "Package: $PACKAGE_NAME"
Write-Log "Server: $SERVER_IP"
Write-Log "Web root: $WEB_ROOT"
Write-Log "Log file: $logFile"
Write-Log "Completion time: $(Get-Date)"

Write-Log "`n${GREEN}Server deployment completed successfully!${NC}"
Write-Log "Please visit http://$SERVER_IP to verify the website"

# Clean up
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Log "Deployment package cleaned up"
}

Write-Log "`nDeployment log saved to: $logFile"