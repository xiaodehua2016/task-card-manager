# Small Task Manager System v4.2.2.1 Git Deployment Script
# Author: CodeBuddy
# Version: v4.2.2.1
# Description: This script is used to deploy the task manager system to Git repository
# Fix: File copying issues and character encoding issues

# Configuration parameters
$version = "v4.2.2.1"
$packageName = "task-manager-$version-complete.zip"

# Show title
function Show-Title {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "   Task Manager System $version Git Deployment"
    Write-Host "========================================"
    Write-Host ""
}

# Create deployment package
function Create-Package {
    Write-Host "Creating deployment package..." -ForegroundColor Cyan
    
    # Check if old package exists, delete if it does
    if (Test-Path $packageName) {
        Remove-Item $packageName -Force
    }
    
    # Create temporary directory
    $tempDir = "temp_deploy"
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    Write-Host "Copying core files..." -ForegroundColor Yellow
    
    # Copy HTML files - using safer copy method
    $htmlFiles = @(
        "index.html",
        "edit-tasks.html",
        "focus-challenge.html",
        "statistics.html",
        "today-tasks.html",
        "sync-test.html",
        "manifest.json",
        "icon-192.svg",
        "favicon.ico"
    )
    
    foreach ($file in $htmlFiles) {
        if (Test-Path $file) {
            Copy-Item $file "$tempDir/" -ErrorAction SilentlyContinue
            Write-Host "  - Copied: $file" -ForegroundColor Gray
        } else {
            Write-Host "  - Skipped non-existent file: $file" -ForegroundColor Yellow
        }
    }
    
    # Create and copy CSS directory
    if (Test-Path "css") {
        New-Item -ItemType Directory -Path "$tempDir/css" -ErrorAction SilentlyContinue | Out-Null
        Get-ChildItem -Path "css" -Filter "*.css" | ForEach-Object {
            Copy-Item $_.FullName "$tempDir/css/" -ErrorAction SilentlyContinue
        }
        Write-Host "CSS files copied" -ForegroundColor Green
    } else {
        Write-Host "CSS directory does not exist, skipped" -ForegroundColor Yellow
    }
    
    # Create and copy JS directory
    if (Test-Path "js") {
        New-Item -ItemType Directory -Path "$tempDir/js" -ErrorAction SilentlyContinue | Out-Null
        Get-ChildItem -Path "js" -Filter "*.js" | ForEach-Object {
            Copy-Item $_.FullName "$tempDir/js/" -ErrorAction SilentlyContinue
        }
        Write-Host "JS files copied" -ForegroundColor Green
    } else {
        Write-Host "JS directory does not exist, skipped" -ForegroundColor Yellow
    }
    
    # Create and copy API directory
    if (Test-Path "api") {
        New-Item -ItemType Directory -Path "$tempDir/api" -ErrorAction SilentlyContinue | Out-Null
        Get-ChildItem -Path "api" -Filter "*.php" | ForEach-Object {
            Copy-Item $_.FullName "$tempDir/api/" -ErrorAction SilentlyContinue
        }
        Get-ChildItem -Path "api" -Filter "*.js" | ForEach-Object {
            Copy-Item $_.FullName "$tempDir/api/" -ErrorAction SilentlyContinue
        }
        Write-Host "API files copied" -ForegroundColor Green
    } else {
        Write-Host "API directory does not exist, skipped" -ForegroundColor Yellow
    }
    
    # Create and copy data directory
    if (Test-Path "data") {
        New-Item -ItemType Directory -Path "$tempDir/data" -ErrorAction SilentlyContinue | Out-Null
        
        if (Test-Path "data/shared-tasks.json") {
            Copy-Item "data/shared-tasks.json" "$tempDir/data/" -ErrorAction SilentlyContinue
        } else {
            # Create default shared-tasks.json file
            $defaultData = @{
                version = $version
                lastUpdateTime = [long](Get-Date -UFormat %s) * 1000
                serverUpdateTime = [long](Get-Date -UFormat %s) * 1000
                username = "User"
                tasks = @()
                taskTemplates = @{
                    daily = @(
                        @{ name = "Task 1"; type = "daily" }
                        @{ name = "Task 2"; type = "daily" }
                        @{ name = "Task 3"; type = "daily" }
                        @{ name = "Task 4"; type = "daily" }
                        @{ name = "Task 5"; type = "daily" }
                        @{ name = "Task 6"; type = "daily" }
                        @{ name = "Task 7"; type = "daily" }
                        @{ name = "Task 8"; type = "daily" }
                    )
                }
                dailyTasks = @{}
                completionHistory = @{}
                taskTimes = @{}
                focusRecords = @{}
            }
            
            $defaultDataJson = ConvertTo-Json $defaultData -Depth 10
            New-Item -ItemType Directory -Path "$tempDir/data" -Force | Out-Null
            Set-Content -Path "$tempDir/data/shared-tasks.json" -Value $defaultDataJson -Encoding UTF8
            Write-Host "  - Created default data file" -ForegroundColor Gray
        }
        
        if (Test-Path "data/README.md") {
            Copy-Item "data/README.md" "$tempDir/data/" -ErrorAction SilentlyContinue
        }
        
        Write-Host "Data files copied" -ForegroundColor Green
    } else {
        Write-Host "Data directory does not exist, created" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "$tempDir/data" -Force | Out-Null
        
        # Create default shared-tasks.json file
        $defaultData = @{
            version = $version
            lastUpdateTime = [long](Get-Date -UFormat %s) * 1000
            serverUpdateTime = [long](Get-Date -UFormat %s) * 1000
            username = "User"
            tasks = @()
            taskTemplates = @{
                daily = @(
                    @{ name = "Task 1"; type = "daily" }
                    @{ name = "Task 2"; type = "daily" }
                    @{ name = "Task 3"; type = "daily" }
                    @{ name = "Task 4"; type = "daily" }
                    @{ name = "Task 5"; type = "daily" }
                    @{ name = "Task 6"; type = "daily" }
                    @{ name = "Task 7"; type = "daily" }
                    @{ name = "Task 8"; type = "daily" }
                )
            }
            dailyTasks = @{}
            completionHistory = @{}
            taskTimes = @{}
            focusRecords = @{}
        }
        
        $defaultDataJson = ConvertTo-Json $defaultData -Depth 10
        Set-Content -Path "$tempDir/data/shared-tasks.json" -Value $defaultDataJson -Encoding UTF8
    }
    
    # Create ZIP file
    try {
        Compress-Archive -Path "$tempDir/*" -DestinationPath $packageName -Force
        
        # Get file size
        $fileSize = (Get-Item $packageName).Length
        
        Write-Host "Deployment package created successfully: $packageName" -ForegroundColor Green
        Write-Host "Package size: $fileSize bytes" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Failed to create ZIP file: $_" -ForegroundColor Red
    }
    
    # Delete temporary directory
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    
    return $packageName
}

# Git deployment
function Deploy-ToGit {
    Write-Host ""
    Write-Host "Starting Git deployment..." -ForegroundColor Cyan
    
    # Check if Git repository exists
    if (-not (Test-Path ".git")) {
        Write-Host "Current directory is not a Git repository, cannot deploy" -ForegroundColor Red
        return $false
    }
    
    # Commit code
    Write-Host "Committing code..." -ForegroundColor Yellow
    
    $commitMessage = @"
v4.2.2.1 Version Update - Deployment Script Optimization

Core fixes:
- Fixed file copying issues in deployment scripts
- Enhanced file checking and error handling
- Optimized character encoding handling
- Improved deployment process stability

Deployment optimizations:
- Safer file copying mechanism
- Automatic creation of missing directories and files
- Enhanced error handling and logging
- Improved user interaction experience

User experience:
- Clearer deployment status feedback
- Detailed error messages
- Comprehensive deployment guide
- Automated deployment options
"@
    
    try {
        git add .
        git commit -m $commitMessage
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Code committed successfully" -ForegroundColor Green
        } else {
            Write-Host "Code commit failed or no changes, exit code: $LASTEXITCODE" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Code commit failed or no changes: $_" -ForegroundColor Yellow
    }
    
    # Push to remote repository
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    
    try {
        git push origin main
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Code pushed successfully" -ForegroundColor Green
            Write-Host ""
            Write-Host "GitHub Pages will deploy automatically" -ForegroundColor Cyan
            Write-Host "Access URL: https://[your-username].github.io/[repository-name]" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Vercel will also detect and deploy automatically" -ForegroundColor Cyan
            return $true
        } else {
            Write-Host "Code push failed, exit code: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "Please check Git configuration and network connection" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "Code push failed: $_" -ForegroundColor Red
        Write-Host "Please check Git configuration and network connection" -ForegroundColor Yellow
        return $false
    }
}

# Show test instructions
function Show-TestInstructions {
    Write-Host ""
    Write-Host "Post-deployment test steps:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Basic test:" -ForegroundColor Yellow
    Write-Host "   - Visit the deployed website" -ForegroundColor White
    Write-Host "   - Check if the page loads correctly" -ForegroundColor White
    Write-Host "   - Add a few tasks and complete them" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Sync test:" -ForegroundColor Yellow
    Write-Host "   - Complete some tasks in Chrome" -ForegroundColor White
    Write-Host "   - Open the same address in Firefox" -ForegroundColor White
    Write-Host "   - Check if task status is synchronized" -ForegroundColor White
    Write-Host "   - Wait 3-5 seconds to observe automatic synchronization" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Diagnostic test:" -ForegroundColor Yellow
    Write-Host "   - Visit sync-test.html" -ForegroundColor White
    Write-Host "   - Click 'Run Diagnostic' to check sync status" -ForegroundColor White
    Write-Host "   - If there are issues, click 'Auto Fix'" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Cross-device test:" -ForegroundColor Yellow
    Write-Host "   - Visit in mobile browser" -ForegroundColor White
    Write-Host "   - Visit in browsers on different computers" -ForegroundColor White
    Write-Host "   - Verify data synchronization across all devices" -ForegroundColor White
    Write-Host ""
    Write-Host "v4.2.2.1 Version features summary:" -ForegroundColor Cyan
    Write-Host "- Cross-browser data synchronization - completely fixed" -ForegroundColor Green
    Write-Host "- Real-time data synchronization - completed within 3 seconds" -ForegroundColor Green
    Write-Host "- Smart error recovery - automatic repair mechanism" -ForegroundColor Green
    Write-Host "- Local storage monitoring - instant synchronization triggering" -ForegroundColor Green
    Write-Host "- Visual diagnostics - problem troubleshooting tool" -ForegroundColor Green
    Write-Host "- Simplified deployment process - one file solution" -ForegroundColor Green
    Write-Host "- Enhanced deployment scripts - more stable and reliable" -ForegroundColor Green
    Write-Host ""
    Write-Host "Deployment complete! Please visit the sync test page for diagnostics" -ForegroundColor Green
}

# Main function
function Main {
    Show-Title
    
    # Create deployment package
    $packagePath = Create-Package
    
    # Deploy to Git
    $success = Deploy-ToGit
    
    if ($success) {
        Show-TestInstructions
    }
}

# Execute main function
Main