# PowerShell script for deploying to 115.159.5.111 server
# Version: v4.2.1

# If you encounter execution policy restrictions, run as administrator:
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
$BACKUP_NAME = "task-manager-backup-$(Get-Date -Format 'yyyyMMddHHmmss').tar.gz"
$TEMP_DIR = ".\temp_deploy"

Write-Host "${BLUE}=== Task Manager System ${VERSION} Server Deployment Script ===${NC}"
Write-Host "Start time: $(Get-Date)"
Write-Host ""

# Check necessary tools
$hasBash = $false
$hasGitBash = $false
$hasSshpass = $false

# Check if bash is available
if (Get-Command "bash" -ErrorAction SilentlyContinue) {
    $hasBash = $true
}

# Check if Git Bash is available
if (Test-Path "C:\Program Files\Git\bin\bash.exe") {
    $hasGitBash = $true
}

# Check if sshpass is available (via bash)
if ($hasBash) {
    $sshpassCheck = bash -c "command -v sshpass || echo 'not found'"
    if ($sshpassCheck -ne "not found") {
        $hasSshpass = $true
    }
}

if (-not ($hasBash -or $hasGitBash)) {
    Write-Host "${RED}✗ Bash not found. Please install Git Bash or WSL${NC}"
    exit 1
}

if (-not $hasSshpass) {
    Write-Host "${YELLOW}⚠ Warning: sshpass tool not detected${NC}"
    Write-Host "This may cause automatic password input to fail, you may need to enter passwords manually"
    Write-Host "You can install sshpass via Git Bash, WSL, or Cygwin"
    Write-Host ""
}

# Check password file
if (-not (Test-Path $PASSWORD_FILE)) {
    Write-Host "${RED}✗ Password file not found: $PASSWORD_FILE${NC}"
    exit 1
}

# Read password (more secure way)
$PASSWORD = Get-Content $PASSWORD_FILE -Raw
$PASSWORD = $PASSWORD.Trim()
$securePassword = ConvertTo-SecureString $PASSWORD -AsPlainText -Force

# Step 1: Create temporary directory
Write-Host "${YELLOW}[1/7] Creating temporary deployment directory...${NC}"
if (Test-Path $TEMP_DIR) {
    Remove-Item -Path $TEMP_DIR -Recurse -Force
}
New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null
if (-not $?) {
    Write-Host "${RED}✗ Failed to create temporary directory${NC}"
    exit 1
}
Write-Host "${GREEN}✓ Temporary directory created successfully${NC}"

# Step 2: Copy files to temporary directory
Write-Host "`n${YELLOW}[2/7] Copying files to temporary directory...${NC}"
Get-ChildItem -Path . -Exclude .git, node_modules, .codebuddy, $TEMP_DIR, $PACKAGE_NAME | 
    Copy-Item -Destination $TEMP_DIR -Recurse -Force
if (-not $?) {
    Write-Host "${RED}✗ Failed to copy files${NC}"
    Remove-Item -Path $TEMP_DIR -Recurse -Force
    exit 1
}
Write-Host "${GREEN}✓ Files copied successfully${NC}"

# Step 3: Create ZIP package
Write-Host "`n${YELLOW}[3/7] Creating deployment package...${NC}"
Compress-Archive -Path "$TEMP_DIR\*" -DestinationPath $PACKAGE_NAME -Force
if (-not $?) {
    Write-Host "${RED}✗ Failed to create ZIP package${NC}"
    Remove-Item -Path $TEMP_DIR -Recurse -Force
    exit 1
}
Write-Host "${GREEN}✓ Deployment package created successfully: ${PACKAGE_NAME}${NC}"

# Step 4: Clean up temporary directory
Write-Host "`n${YELLOW}[4/7] Cleaning up temporary directory...${NC}"
Remove-Item -Path $TEMP_DIR -Recurse -Force
Write-Host "${GREEN}✓ Temporary directory cleaned up${NC}"

# Step 5: Upload files to server
Write-Host "`n${YELLOW}[5/7] Uploading files to server...${NC}"
Write-Host "Uploading deployment package..."

# Set environment variable (for sshpass)
$env:SSHPASS = $PASSWORD

# Determine which bash to use
$bashCmd = "bash"
if (-not $hasBash -and $hasGitBash) {
    $bashCmd = "C:\Program Files\Git\bin\bash.exe"
}

# Create upload script
$uploadScript = @"
#!/bin/bash
sshpass -e scp -o StrictHostKeyChecking=no $PACKAGE_NAME $SERVER_USER@$SERVER_IP:$REMOTE_TMP/
sshpass -e scp -o StrictHostKeyChecking=no deploy/one-click-deploy.sh $SERVER_USER@$SERVER_IP:$REMOTE_TMP/
sshpass -e scp -o StrictHostKeyChecking=no deploy/fix-baota-permissions.sh $SERVER_USER@$SERVER_IP:$REMOTE_TMP/
sshpass -e scp -o StrictHostKeyChecking=no deploy/verify-deployment.sh $SERVER_USER@$SERVER_IP:$REMOTE_TMP/
"@

# Save upload script
$uploadScript | Out-File -FilePath "upload.sh" -Encoding ASCII
if (-not $?) {
    Write-Host "${RED}✗ Failed to create upload script${NC}"
    exit 1
}

# Execute upload script
& $bashCmd upload.sh
if (-not $?) {
    Write-Host "${RED}✗ Failed to upload files${NC}"
    Remove-Item -Path "upload.sh" -Force
    exit 1
}

# Clean up upload script
Remove-Item -Path "upload.sh" -Force
Write-Host "${GREEN}✓ Files uploaded successfully${NC}"

# Step 6: Execute deployment on server
Write-Host "`n${YELLOW}[6/7] Executing deployment on server...${NC}"

# Create deployment script
$deployScript = @"
#!/bin/bash
sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << 'EOF'
    echo "Connected to server successfully, starting deployment..."
    
    # Set execution permissions
    chmod +x $REMOTE_TMP/one-click-deploy.sh
    chmod +x $REMOTE_TMP/fix-baota-permissions.sh
    chmod +x $REMOTE_TMP/verify-deployment.sh
    
    # Backup current website
    echo "Backing up current website..."
    if [ -d "$WEB_ROOT" ]; then
        tar -czf $REMOTE_TMP/$BACKUP_NAME -C $WEB_ROOT .
        echo "Website backed up to $REMOTE_TMP/$BACKUP_NAME"
    fi
    
    # Extract deployment package
    echo "Extracting deployment package..."
    mkdir -p $WEB_ROOT
    unzip -o $REMOTE_TMP/$PACKAGE_NAME -d $WEB_ROOT
    
    # Set permissions
    echo "Setting file permissions..."
    chown -R www:www $WEB_ROOT
    find $WEB_ROOT -type d -exec chmod 755 {} \;
    find $WEB_ROOT -type f -exec chmod 644 {} \;
    
    # Create data directory
    echo "Ensuring data directory exists..."
    mkdir -p $WEB_ROOT/data
    chown -R www:www $WEB_ROOT/data
    chmod 755 $WEB_ROOT/data
    
    # Handle BaoTa panel special files
    if [ -f "$WEB_ROOT/.user.ini" ]; then
        echo "Handling BaoTa panel .user.ini file..."
        chattr -i $WEB_ROOT/.user.ini
        chown www:www $WEB_ROOT/.user.ini
        chattr +i $WEB_ROOT/.user.ini
    fi
    
    echo "Deployment complete!"
EOF
"@

# Save deployment script
$deployScript | Out-File -FilePath "deploy.sh" -Encoding ASCII
if (-not $?) {
    Write-Host "${RED}✗ Failed to create deployment script${NC}"
    exit 1
}

# Execute deployment script
& $bashCmd deploy.sh
if (-not $?) {
    Write-Host "${RED}✗ Server deployment failed${NC}"
    Remove-Item -Path "deploy.sh" -Force
    exit 1
}

# Clean up deployment script
Remove-Item -Path "deploy.sh" -Force
Write-Host "${GREEN}✓ Server deployment successful${NC}"

# Step 7: Verify deployment
Write-Host "`n${YELLOW}[7/7] Verifying deployment...${NC}"

# Create verification script
$verifyScript = @"
#!/bin/bash
sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "$REMOTE_TMP/verify-deployment.sh"
"@

# Save verification script
$verifyScript | Out-File -FilePath "verify.sh" -Encoding ASCII
if (-not $?) {
    Write-Host "${RED}✗ Failed to create verification script${NC}"
    exit 1
}

# Execute verification script
& $bashCmd verify.sh
$verifyResult = $?

# Clean up verification script
Remove-Item -Path "verify.sh" -Force

if (-not $verifyResult) {
    Write-Host "${RED}✗ Deployment verification failed, please check manually${NC}"
    Write-Host "${YELLOW}Suggestion: Execute ssh $SERVER_USER@$SERVER_IP '$REMOTE_TMP/fix-baota-permissions.sh'${NC}"
} else {
    Write-Host "${GREEN}✓ Deployment verification successful${NC}"
}

Write-Host "`n${BLUE}=== Deployment Summary ===${NC}"
Write-Host "Deployment version: $VERSION"
Write-Host "Deployment package: $PACKAGE_NAME"
Write-Host "Server: $SERVER_IP"
Write-Host "Website directory: $WEB_ROOT"
Write-Host "Backup file: $REMOTE_TMP/$BACKUP_NAME"
Write-Host "Completion time: $(Get-Date)"

Write-Host "`n${GREEN}Deployment script execution complete!${NC}"
Write-Host "Please visit http://$SERVER_IP to verify the website is running correctly"
Write-Host "Please visit http://$SERVER_IP/sync-test.html to test data synchronization functionality"

# Clean up environment variable
$env:SSHPASS = ""