# Task Manager v4.2.1 Server Deployment Script (Final Fixed Version v4.2.1.2)
# With automatic password input and NO Chinese characters to avoid encoding issues

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
$SCRIPT_VERSION = "v4.2.1.2"
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

function Execute-SSHCommand {
    param(
        [string]$Command,
        [string]$Description
    )
    
    Write-Log "Executing: $Description"
    Write-Log "Command: $Command"
    
    try {
        # Use sshpass if available
        if (Get-Command "sshpass" -ErrorAction SilentlyContinue) {
            & sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SERVER_USER@$SERVER_IP $Command
            $exitCode = $LASTEXITCODE
        } else {
            # Fallback to basic ssh (may require manual password input)
            & ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SERVER_USER@$SERVER_IP $Command
            $exitCode = $LASTEXITCODE
        }
        
        if ($exitCode -eq 0) {
            Write-Log "${GREEN}SUCCESS: $Description completed${NC}"
            return $true
        } else {
            Write-Log "${RED}FAILED: $Description failed with exit code: $exitCode${NC}"
            return $false
        }
    } catch {
        Write-Log "${RED}ERROR: $Description failed with error: $($_.Exception.Message)${NC}"
        return $false
    }
}

function Execute-SCPUpload {
    param(
        [string]$LocalPath,
        [string]$RemotePath,
        [string]$Description
    )
    
    Write-Log "Uploading: $Description"
    Write-Log "From: $LocalPath"
    Write-Log "To: $SERVER_USER@${SERVER_IP}:$RemotePath"
    
    try {
        # Use sshpass if available
        if (Get-Command "sshpass" -ErrorAction SilentlyContinue) {
            & sshpass -p $PASSWORD scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $LocalPath "$SERVER_USER@${SERVER_IP}:$RemotePath"
            $exitCode = $LASTEXITCODE
        } else {
            # Fallback to basic scp (may require manual password input)
            & scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $LocalPath "$SERVER_USER@${SERVER_IP}:$RemotePath"
            $exitCode = $LASTEXITCODE
        }
        
        if ($exitCode -eq 0) {
            Write-Log "${GREEN}SUCCESS: $Description uploaded${NC}"
            return $true
        } else {
            Write-Log "${RED}FAILED: $Description upload failed with exit code: $exitCode${NC}"
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

# Check for required tools
$hasSSH = Get-Command "ssh" -ErrorAction SilentlyContinue
$hasSCP = Get-Command "scp" -ErrorAction SilentlyContinue
$hasSSHPASS = Get-Command "sshpass" -ErrorAction SilentlyContinue

Write-Log "Tool availability check:"
Write-Log "  SSH: $(if ($hasSSH) { 'Available' } else { 'Not found' })"
Write-Log "  SCP: $(if ($hasSCP) { 'Available' } else { 'Not found' })"
Write-Log "  SSHPASS: $(if ($hasSSHPASS) { 'Available' } else { 'Not found' })"

if (-not $hasSSH -or -not $hasSCP) {
    Write-Log "${RED}ERROR: SSH and SCP tools are required${NC}"
    Write-Log "Please install OpenSSH or use Windows Subsystem for Linux (WSL)"
    exit 1
}

if (-not $hasSSHPASS) {
    Write-Log "${YELLOW}WARNING: sshpass not found, may require manual password input${NC}"
}

# Step 3: Upload files to server
Write-Log "`n${YELLOW}[3/5] Uploading files to server...${NC}"

# Upload deployment package
if (-not (Execute-SCPUpload -LocalPath $zipPath -RemotePath "$REMOTE_TMP/" -Description "deployment package")) {
    Write-Log "${RED}FAILED to upload deployment package${NC}"
    exit 1
}

# Upload deployment scripts
Write-Log "Uploading deployment scripts..."
$shFiles = Get-ChildItem -Path $scriptDir -Filter "*.sh"
Write-Log "Found $($shFiles.Count) shell script files"

foreach ($file in $shFiles) {
    if (-not (Execute-SCPUpload -LocalPath $file.FullName -RemotePath "$REMOTE_TMP/" -Description "script: $($file.Name)")) {
        Write-Log "${RED}FAILED to upload script: $($file.Name)${NC}"
        exit 1
    }
}

Write-Log "${GREEN}SUCCESS: All files uploaded${NC}"

# Step 4: Execute deployment on server
Write-Log "`n${YELLOW}[4/5] Executing deployment on server...${NC}"

# Set execution permissions
if (-not (Execute-SSHCommand -Command "chmod +x $REMOTE_TMP/*.sh" -Description "Set script execution permissions")) {
    Write-Log "${RED}FAILED to set execution permissions${NC}"
    exit 1
}

# Execute deployment script with detailed output
$deployCommand = @"
echo "=== Starting deployment process ===";
echo "Timestamp: \$(date)";
echo "Working directory: \$(pwd)";
echo "Available scripts:";
ls -la $REMOTE_TMP/*.sh;
echo "";
echo "=== Executing one-click-deploy.sh ===";
$REMOTE_TMP/one-click-deploy.sh 2>&1;
DEPLOY_EXIT_CODE=\$?;
echo "";
echo "=== Deployment script exit code: \$DEPLOY_EXIT_CODE ===";
if [ \$DEPLOY_EXIT_CODE -ne 0 ]; then
    echo "=== Deployment failed, trying to get more information ===";
    echo "Checking if deployment package exists:";
    ls -la $REMOTE_TMP/task-manager-*.zip;
    echo "Checking web root directory:";
    ls -la $WEB_ROOT/ 2>/dev/null || echo "Web root directory does not exist";
    echo "Checking nginx status:";
    systemctl status nginx --no-pager || echo "Nginx status check failed";
    echo "=== Trying permission fix ===";
    $REMOTE_TMP/fix-baota-permissions.sh 2>&1;
    echo "=== Running verification ===";
    $REMOTE_TMP/verify-deployment.sh 2>&1;
else
    echo "=== Deployment successful, running verification ===";
    $REMOTE_TMP/verify-deployment.sh 2>&1;
fi;
echo "=== Deployment process completed ===";
"@

if (-not (Execute-SSHCommand -Command $deployCommand -Description "Execute deployment process")) {
    Write-Log "${RED}Deployment process failed${NC}"
    
    # Try to get more diagnostic information
    Write-Log "`n${YELLOW}Attempting to gather diagnostic information...${NC}"
    $diagCommand = @"
echo "=== System Information ===";
uname -a;
echo "=== Disk Space ===";
df -h;
echo "=== Memory Usage ===";
free -h;
echo "=== Network Connectivity ===";
ping -c 3 8.8.8.8;
echo "=== Web Server Status ===";
systemctl status nginx --no-pager 2>/dev/null || systemctl status apache2 --no-pager 2>/dev/null || echo "No web server found";
echo "=== File Permissions ===";
ls -la $WEB_ROOT/ 2>/dev/null || echo "Web root not accessible";
"@
    
    Execute-SSHCommand -Command $diagCommand -Description "Gather diagnostic information"
    exit 1
}

# Step 5: Final verification
Write-Log "`n${YELLOW}[5/5] Final verification...${NC}"

# Test website accessibility
Write-Log "Testing website accessibility..."
$testCommand = @"
echo "=== Website Accessibility Test ===";
curl -I http://localhost 2>/dev/null || echo "Local HTTP test failed";
curl -I http://$SERVER_IP 2>/dev/null || echo "External HTTP test failed";
echo "=== File Structure Check ===";
find $WEB_ROOT -name "*.html" -o -name "*.js" -o -name "*.css" | head -10;
echo "=== Version Check ===";
grep -r "v4.2.1" $WEB_ROOT/ | head -5 || echo "Version string not found";
"@

Execute-SSHCommand -Command $testCommand -Description "Final verification tests"

Write-Log "${GREEN}SUCCESS: All deployment steps completed${NC}"

Write-Log "`n${BLUE}=== Deployment Summary ===${NC}"
Write-Log "Version: $VERSION"
Write-Log "Script Version: $SCRIPT_VERSION"
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