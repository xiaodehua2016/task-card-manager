# Task Manager System v4.2.3 Deployment Script (Simple Version)
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

# Main function
function Main {
    Write-Log "Task Manager System v4.2.3 Simple Deployment Started" "INFO"
    
    # Create deployment package
    $zipFile = Create-Package
    
    Write-Log "Deployment package created: $zipFile" "INFO"
    Write-Log "Please follow these steps to deploy manually:" "INFO"
    Write-Log "" "INFO"
    Write-Log "1. Upload the file to server:" "INFO"
    Write-Log "   - Using SCP: scp $zipFile root@115.159.5.111:/tmp/" "INFO"
    Write-Log "   - Using SFTP tool" "INFO"
    Write-Log "   - Using Baota Panel file manager" "INFO"
    Write-Log "" "INFO"
    Write-Log "2. Extract on server (via SSH or Baota Panel terminal):" "INFO"
    Write-Log "   cd /www/wwwroot/" "INFO"
    Write-Log "   unzip -o /tmp/$zipFile -d task-manager/" "INFO"
    Write-Log "   chown -R www:www task-manager/" "INFO"
    Write-Log "   chmod -R 755 task-manager/" "INFO"
    Write-Log "" "INFO"
    Write-Log "3. Verify deployment:" "INFO"
    Write-Log "   - Visit: http://115.159.5.111/" "INFO"
    Write-Log "   - Test: http://115.159.5.111/sync-test.html" "INFO"
    
    return 0
}

# Execute Main function
Main
exit $LASTEXITCODE