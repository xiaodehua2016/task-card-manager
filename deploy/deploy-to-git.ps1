# PowerShell script for deploying to Git repository
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
$VERSION = "v4.2.1"
$BRANCH = "main"

Write-Host "${BLUE}=== Task Manager System ${VERSION} Git Deployment Script ===${NC}"
Write-Host "Start time: $(Get-Date)"
Write-Host ""

# Step 1: Check Git status
Write-Host "${YELLOW}[1/4] Checking Git status...${NC}"
$status = git status --porcelain
if ($status) {
    Write-Host "Detected uncommitted changes:"
    git status --short
    Write-Host ""
} else {
    Write-Host "Working directory clean, no uncommitted changes."
    Write-Host ""
}

# Step 2: Add all files to staging area
Write-Host "${YELLOW}[2/4] Adding files to Git staging area...${NC}"
git add .
if (-not $?) {
    Write-Host "${RED}✗ Failed to add files${NC}"
    exit 1
}
Write-Host "${GREEN}✓ Files added to staging area${NC}"

# Step 3: Commit changes
Write-Host "`n${YELLOW}[3/4] Committing changes...${NC}"
$commitMessage = @"
Release $VERSION - Data Consistency Enhancement

New Features:
- Cross-browser data synchronization
- Automatic data consistency repair
- Sync testing tools
- Deployment verification tools

Bug Fixes:
- Cross-browser task count inconsistency
- Data structure issues
- BaoTa panel compatibility
- Deployment script issues
"@

git commit -m "$commitMessage"
if (-not $?) {
    Write-Host "${RED}✗ Failed to commit changes${NC}"
    exit 1
}
Write-Host "${GREEN}✓ Changes committed${NC}"

# Step 4: Push to remote repository
Write-Host "`n${YELLOW}[4/4] Pushing to remote repository...${NC}"
git push origin $BRANCH
if (-not $?) {
    Write-Host "${RED}✗ Push failed${NC}"
    Write-Host "${YELLOW}Tip: If this is due to authentication issues, make sure Git credentials are configured${NC}"
    exit 1
}
Write-Host "${GREEN}✓ Successfully pushed to remote repository${NC}"

Write-Host "`n${BLUE}=== Deployment Summary ===${NC}"
Write-Host "Deployment version: $VERSION"
Write-Host "Target branch: $BRANCH"
Write-Host "Commit message: Release $VERSION - Data Consistency Enhancement"
Write-Host "Completion time: $(Get-Date)"

Write-Host "`n${GREEN}Git deployment script completed!${NC}"
Write-Host "Please check the remote repository to confirm changes were pushed successfully"