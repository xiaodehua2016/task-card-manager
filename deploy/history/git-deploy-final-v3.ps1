# Task Manager v4.2.1 Git Deployment Script (Final Fixed Version)
# With detailed logging and all encoding issues resolved

# If execution policy error occurs, run as administrator:
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Color definitions
$RED = "$([char]0x1b)[31m"
$GREEN = "$([char]0x1b)[32m"
$YELLOW = "$([char]0x1b)[33m"
$BLUE = "$([char]0x1b)[34m"
$NC = "$([char]0x1b)[0m" # No color

# Configuration
$VERSION = "v4.2.1"
$BRANCH = "main"

# Create log file with timestamp
$logTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "git_deploy_log_${logTimestamp}.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage -Encoding UTF8
}

Write-Log "${BLUE}=== Task Manager ${VERSION} Git Deployment Script ===${NC}"
Write-Log "Start time: $(Get-Date)"
Write-Log "Log file: $logFile"
Write-Log ""

# Ensure we are in project root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $scriptDir

Set-Location $projectRoot
Write-Log "Working directory: $(Get-Location)"

# Step 1: Check Git status
Write-Log "${YELLOW}[1/4] Checking Git status...${NC}"

# Check if Git is installed
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Log "${RED}Error: Git is not installed or not in PATH${NC}"
    Write-Log "Please install Git and try again"
    exit 1
}

Write-Log "Git version: $(git --version)"

# Check if this is a Git repository
if (-not (Test-Path ".git")) {
    Write-Log "${RED}Error: This is not a Git repository${NC}"
    Write-Log "Please initialize Git repository first:"
    Write-Log "  git init"
    Write-Log "  git remote add origin [repository-url]"
    exit 1
}

# Check Git status
$gitStatus = git status --porcelain 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}Error: Failed to get Git status${NC}"
    exit 1
}

Write-Log "${GREEN}✓ Git repository status checked${NC}"

# Check remote repository
$remoteUrl = git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Log "Remote repository: $remoteUrl"
} else {
    Write-Log "${YELLOW}Warning: No remote repository configured${NC}"
}

# Step 2: Add files to staging area
Write-Log "`n${YELLOW}[2/4] Adding files to staging area...${NC}"

# Show current status
$statusOutput = git status --short
if ($statusOutput) {
    Write-Log "Current file status:"
    $statusOutput | ForEach-Object { Write-Log "  $_" }
} else {
    Write-Log "No file changes detected"
}

# Add all files
git add . 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}Error: Failed to add files to staging area${NC}"
    exit 1
}

# Check staged files
$stagedFiles = git diff --cached --name-only
$fileCount = ($stagedFiles | Measure-Object).Count

if ($fileCount -eq 0) {
    Write-Log "${YELLOW}No changes to commit${NC}"
    Write-Log "All files are up to date"
    exit 0
}

Write-Log "${GREEN}✓ Added $fileCount files to staging area${NC}"
Write-Log "Staged files:"
$stagedFiles | ForEach-Object { Write-Log "  $_" }

# Step 3: Create commit
Write-Log "`n${YELLOW}[3/4] Creating commit...${NC}"

# Generate commit message (using English to avoid encoding issues)
$commitMessage = @"
Release ${VERSION} - Data Consistency Enhanced Version

New Features:
- Cross-browser data synchronization
- Automatic data consistency repair
- Sync testing tools
- Deployment verification tools

Optimizations:
- Deployment scripts fully optimized
- Permission handling intelligentized
- Error handling enhanced
- Detailed logging output

Bug Fixes:
- Cross-browser task count inconsistency
- .user.ini permission issues
- Deployment script compatibility issues
- PowerShell encoding issues

Deployment:
- One-click deployment scripts
- Multi-environment support
- Automatic verification and repair
- Complete logging functionality
"@

Write-Log "Commit message:"
$commitMessage.Split("`n") | ForEach-Object { Write-Log "  $_" }

# Create commit
git commit -m $commitMessage 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}Error: Failed to create commit${NC}"
    Write-Log "Please check Git configuration:"
    Write-Log "  git config --global user.name 'Your Name'"
    Write-Log "  git config --global user.email 'your.email@example.com'"
    exit 1
}

Write-Log "${GREEN}✓ Commit created successfully${NC}"

# Get commit information
$commitHash = git rev-parse HEAD
$commitShort = $commitHash.Substring(0, 7)
Write-Log "Commit hash: $commitShort"

# Step 4: Push to remote repository
Write-Log "`n${YELLOW}[4/4] Pushing to remote repository...${NC}"

# Check remote repository
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}Error: No remote repository configured${NC}"
    Write-Log "Please add remote repository:"
    Write-Log "  git remote add origin [repository-url]"
    exit 1
}

Write-Log "Pushing to branch: $BRANCH"
Write-Log "Remote repository: $remoteUrl"

# Push to remote
git push origin $BRANCH 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}Error: Failed to push to remote repository${NC}"
    Write-Log "Possible causes:"
    Write-Log "1. Network connection issues"
    Write-Log "2. Authentication problems"
    Write-Log "3. Remote repository conflicts"
    Write-Log ""
    Write-Log "Try manual push:"
    Write-Log "  git push origin $BRANCH"
    
    # Try to get more error information
    Write-Log "`nTrying to get detailed error information..."
    $pushResult = git push origin $BRANCH 2>&1
    Write-Log "Push output: $pushResult"
    
    exit 1
}

Write-Log "${GREEN}✓ Successfully pushed to remote repository${NC}"

# Deployment summary
Write-Log "`n${BLUE}=== Deployment Summary ===${NC}"
Write-Log "Version: $VERSION"
Write-Log "Branch: $BRANCH"
Write-Log "Files committed: $fileCount"
Write-Log "Commit hash: $commitShort"
Write-Log "Remote repository: $remoteUrl"
Write-Log "Log file: $logFile"
Write-Log "Completion time: $(Get-Date)"

Write-Log "`n${GREEN}Git deployment completed successfully!${NC}"
Write-Log "Code has been successfully pushed to remote repository"

# Check GitHub Pages or other deployment services
Write-Log "`n${YELLOW}Next steps:${NC}"
Write-Log "1. Check if GitHub Pages is enabled in repository settings"
Write-Log "2. Wait for automatic deployment to complete (if configured)"
Write-Log "3. Verify deployment at your GitHub Pages URL"
Write-Log "4. Test cross-browser data synchronization functionality"

Write-Log "`nDeployment log saved to: $logFile"