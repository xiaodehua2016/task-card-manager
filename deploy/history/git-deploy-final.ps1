# Task Manager v4.2.1 Git Deployment Script
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
$VERSION = "v4.2.1"
$BRANCH = "main"

Write-Host "${BLUE}=== Task Manager ${VERSION} Git Deployment Script ===${NC}"
Write-Host "Start time: $(Get-Date)"
Write-Host ""

# Ensure we are in project root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $scriptDir

Set-Location $projectRoot
Write-Host "Working directory: $(Get-Location)"

# Step 1: Check Git status
Write-Host "${YELLOW}[1/4] Checking Git status...${NC}"

# Check if Git is installed
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "${RED}Error: Git is not installed or not in PATH${NC}"
    Write-Host "Please install Git and try again"
    exit 1
}

# Check if this is a Git repository
if (-not (Test-Path ".git")) {
    Write-Host "${RED}Error: This is not a Git repository${NC}"
    Write-Host "Please initialize Git repository first:"
    Write-Host "  git init"
    Write-Host "  git remote add origin <repository-url>"
    exit 1
}

# Check Git status
$gitStatus = git status --porcelain 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Error: Failed to get Git status${NC}"
    exit 1
}

Write-Host "${GREEN}✓ Git repository status checked${NC}"

# Step 2: Add files to staging area
Write-Host "`n${YELLOW}[2/4] Adding files to staging area...${NC}"

# Add all files
git add . 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Error: Failed to add files to staging area${NC}"
    exit 1
}

# Check what files are staged
$stagedFiles = git diff --cached --name-only
$fileCount = ($stagedFiles | Measure-Object).Count

if ($fileCount -eq 0) {
    Write-Host "${YELLOW}No changes to commit${NC}"
    Write-Host "All files are up to date"
    exit 0
}

Write-Host "${GREEN}✓ Added $fileCount files to staging area${NC}"

# Step 3: Create commit
Write-Host "`n${YELLOW}[3/4] Creating commit...${NC}"

# Generate commit message
$commitMessage = @"
🚀 Release ${VERSION} - Data Consistency Enhanced Version

✨ New Features:
- Cross-browser data synchronization
- Automatic data consistency repair
- Sync testing tools
- Deployment verification tools

🔧 Optimizations:
- Deployment scripts fully optimized
- Permission handling intelligentized
- Error handling enhanced

🐛 Bug Fixes:
- Cross-browser task count inconsistency
- .user.ini permission issues
- Deployment script compatibility issues

📦 Deployment:
- One-click deployment scripts
- Multi-environment support
- Automatic verification and repair
"@

# Create commit
git commit -m $commitMessage 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Error: Failed to create commit${NC}"
    Write-Host "Please check Git configuration:"
    Write-Host "  git config --global user.name 'Your Name'"
    Write-Host "  git config --global user.email 'your.email@example.com'"
    exit 1
}

Write-Host "${GREEN}✓ Commit created successfully${NC}"

# Step 4: Push to remote repository
Write-Host "`n${YELLOW}[4/4] Pushing to remote repository...${NC}"

# Check if remote exists
$remoteUrl = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Error: No remote repository configured${NC}"
    Write-Host "Please add remote repository:"
    Write-Host "  git remote add origin <repository-url>"
    exit 1
}

Write-Host "Remote repository: $remoteUrl"

# Push to remote
git push origin $BRANCH 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Error: Failed to push to remote repository${NC}"
    Write-Host "This might be due to:"
    Write-Host "1. Network connection issues"
    Write-Host "2. Authentication problems"
    Write-Host "3. Remote repository conflicts"
    Write-Host ""
    Write-Host "Try manual push:"
    Write-Host "  git push origin $BRANCH"
    exit 1
}

Write-Host "${GREEN}✓ Successfully pushed to remote repository${NC}"

# Deployment summary
Write-Host "`n${BLUE}=== Deployment Summary ===${NC}"
Write-Host "Version: $VERSION"
Write-Host "Branch: $BRANCH"
Write-Host "Files committed: $fileCount"
Write-Host "Remote: $remoteUrl"
Write-Host "Completion time: $(Get-Date)"

Write-Host "`n${GREEN}Git deployment completed successfully!${NC}"
Write-Host "Your code has been pushed to the remote repository"

# Check if GitHub Pages or other deployment services are configured
Write-Host "`n${YELLOW}Next steps:${NC}"
Write-Host "1. Check if GitHub Pages is enabled in repository settings"
Write-Host "2. Wait for automatic deployment (if configured)"
Write-Host "3. Verify deployment at your GitHub Pages URL"
Write-Host "4. Test cross-browser data synchronization functionality"