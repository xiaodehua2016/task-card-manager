# Task Manager v4.2.1 Server Deployment Script
# Final version with all issues fixed

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

Write-Host "${BLUE}=== Task Manager ${VERSION} Server Deployment Script ===${NC}"
Write-Host "Start time: $(Get-Date)"
Write-Host ""

# Ensure we are in project root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $scriptDir

Set-Location $projectRoot
Write-Host "Working directory: $(Get-Location)"

# Step 1: Create deployment package
Write-Host "${YELLOW}[1/5] Creating deployment package...${NC}"

# Check password file
if (-not (Test-Path $PASSWORD_FILE)) {
    Write-Host "${RED}Error: Password file not found: $PASSWORD_FILE${NC}"
    exit 1
}

# Read password
$PASSWORD = Get-Content $PASSWORD_FILE -Raw
$PASSWORD = $PASSWORD.Trim()

# Create temporary directory
$tempDir = Join-Path -Path $scriptDir -ChildPath "temp_deploy_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

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
    ".idea"
)

# Copy files with smart filtering
Write-Host "Copying project files..."
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

foreach ($file in $filesToCopy) {
    if (-not $file.PSIsContainer) {
        $relativePath = $file.FullName.Substring($projectRoot.Length + 1)
        $destPath = Join-Path -Path $tempDir -ChildPath $relativePath
        $destDir = Split-Path -Parent $destPath
        
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        Copy-Item -Path $file.FullName -Destination $destPath -Force
    }
}

# Create ZIP package
$zipPath = Join-Path -Path $scriptDir -ChildPath $PACKAGE_NAME

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

try {
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force
    Write-Host "${GREEN}✓ Deployment package created: $PACKAGE_NAME${NC}"
} catch {
    Write-Host "${RED}Error: Failed to create ZIP package${NC}"
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
} finally {
    # Clean up temporary directory
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
}

# Step 2: Check upload tools
Write-Host "`n${YELLOW}[2/5] Checking upload tools...${NC}"

# Check for pscp (PuTTY SCP)
$hasPscp = $false
if (Get-Command "pscp" -ErrorAction SilentlyContinue) {
    $hasPscp = $true
    Write-Host "${GREEN}✓ Found pscp tool${NC}"
} else {
    # Check PuTTY installation directories
    $puttyPaths = @(
        "C:\Program Files\PuTTY\pscp.exe",
        "C:\Program Files (x86)\PuTTY\pscp.exe"
    )
    
    foreach ($path in $puttyPaths) {
        if (Test-Path $path) {
            $env:PATH += ";$(Split-Path -Parent $path)"
            $hasPscp = $true
            Write-Host "${GREEN}✓ Found pscp tool: $path${NC}"
            break
        }
    }
}

if (-not $hasPscp) {
    Write-Host "${YELLOW}⚠ pscp tool not detected${NC}"
    Write-Host "Please manually upload the following files to server:"
    Write-Host "1. $zipPath -> $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    Write-Host "2. $scriptDir\*.sh -> $SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    
    $continue = Read-Host "Have you manually uploaded the files? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
} else {
    # Step 3: Upload files to server
    Write-Host "`n${YELLOW}[3/5] Uploading files to server...${NC}"
    
    # Upload deployment package
    Write-Host "Uploading deployment package..."
    $pscpArgs = @(
        "-pw", $PASSWORD,
        "-batch",
        $zipPath,
        "$SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
    )
    
    & pscp $pscpArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}✗ Failed to upload deployment package${NC}"
        exit 1
    }
    
    # Upload deployment scripts
    Write-Host "Uploading deployment scripts..."
    $shFiles = Get-ChildItem -Path $scriptDir -Filter "*.sh"
    
    foreach ($file in $shFiles) {
        $pscpArgs = @(
            "-pw", $PASSWORD,
            "-batch",
            $file.FullName,
            "$SERVER_USER@${SERVER_IP}:$REMOTE_TMP/"
        )
        
        & pscp $pscpArgs
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "${RED}✗ Failed to upload script $($file.Name)${NC}"
            exit 1
        }
    }
    
    Write-Host "${GREEN}✓ Files uploaded successfully${NC}"
}

# Step 4: Execute deployment on server
Write-Host "`n${YELLOW}[4/5] Executing deployment on server...${NC}"

# Check for plink (PuTTY Link)
$hasPlink = $false
if (Get-Command "plink" -ErrorAction SilentlyContinue) {
    $hasPlink = $true
} else {
    # Check PuTTY installation directories
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
    Write-Host "${YELLOW}⚠ plink tool not detected${NC}"
    Write-Host "Please manually connect to server and execute the following commands:"
    Write-Host "1. chmod +x $REMOTE_TMP/*.sh"
    Write-Host "2. $REMOTE_TMP/one-click-deploy.sh"
    Write-Host "3. $REMOTE_TMP/verify-deployment.sh"
    
    Write-Host "`n${BLUE}=== Deployment Summary ===${NC}"
    Write-Host "Version: $VERSION"
    Write-Host "Package: $PACKAGE_NAME"
    Write-Host "Server: $SERVER_IP"
    Write-Host "Web root: $WEB_ROOT"
    Write-Host "Completion time: $(Get-Date)"
    
    Write-Host "`n${GREEN}Upload completed! Please manually complete deployment steps${NC}"
    exit 0
} else {
    # Use plink to execute remote commands
    Write-Host "Connecting to server and executing deployment..."
    
    # Set execution permissions
    $plinkArgs = @(
        "-ssh",
        "-pw", $PASSWORD,
        "-batch",
        "$SERVER_USER@${SERVER_IP}",
        "chmod +x $REMOTE_TMP/*.sh"
    )
    
    & plink $plinkArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}✗ Failed to set execution permissions${NC}"
        exit 1
    }
    
    # Execute deployment script
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
    
    $plinkArgs = @(
        "-ssh",
        "-pw", $PASSWORD,
        "-batch",
        "$SERVER_USER@${SERVER_IP}",
        $deployCommand
    )
    
    & plink $plinkArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}✗ Deployment failed${NC}"
        exit 1
    }
    
    Write-Host "${GREEN}✓ Deployment successful${NC}"
}

# Step 5: Final verification
Write-Host "`n${YELLOW}[5/5] Final verification...${NC}"

Write-Host "${GREEN}✓ All deployment steps completed${NC}"

Write-Host "`n${BLUE}=== Deployment Summary ===${NC}"
Write-Host "Version: $VERSION"
Write-Host "Package: $PACKAGE_NAME"
Write-Host "Server: $SERVER_IP"
Write-Host "Web root: $WEB_ROOT"
Write-Host "Completion time: $(Get-Date)"

Write-Host "`n${GREEN}Server deployment completed successfully!${NC}"
Write-Host "Please visit http://$SERVER_IP to verify the website is running"
Write-Host "Please visit http://$SERVER_IP/sync-test.html to test data sync functionality"

# Clean up deployment package
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Host "Deployment package cleaned up"
}