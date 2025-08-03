@echo off
chcp 65001 >nul
echo ========================================
echo 任务管理系统 v4.3.6.4 部署脚本
echo 功能：修复跨浏览器数据同步问题
echo ========================================
echo.

set VERSION=4.3.6.4
set PACKAGE_NAME=task-manager-v%VERSION%

:: 创建日志目录
if not exist "deploy\logs" mkdir "deploy\logs"

echo [1/5] 创建部署目录...
if exist "%PACKAGE_NAME%" (
    rmdir /s /q "%PACKAGE_NAME%"
    echo 清理旧的部署目录
)
mkdir "%PACKAGE_NAME%"

echo [2/5] 复制核心文件...
:: 复制主要文件
copy "index.html" "%PACKAGE_NAME%\" >nul
copy "manifest.json" "%PACKAGE_NAME%\" >nul 2>nul
copy "favicon.ico" "%PACKAGE_NAME%\" >nul 2>nul
copy "*.svg" "%PACKAGE_NAME%\" >nul 2>nul

:: 复制目录
xcopy "css" "%PACKAGE_NAME%\css\" /E /I /Q >nul
xcopy "js" "%PACKAGE_NAME%\js\" /E /I /Q >nul
xcopy "api" "%PACKAGE_NAME%\api\" /E /I /Q >nul
xcopy "images" "%PACKAGE_NAME%\images\" /E /I /Q >nul 2>nul

echo 核心文件复制完成

echo [3/5] 清理不必要的文件...
:: 删除开发文件和历史版本
del "%PACKAGE_NAME%\js\*.bak" >nul 2>nul
del "%PACKAGE_NAME%\js\*-fix.js" >nul 2>nul
del "%PACKAGE_NAME%\js\*-emergency.js" >nul 2>nul
del "%PACKAGE_NAME%\js\cross-browser-sync.js" >nul 2>nul
del "%PACKAGE_NAME%\js\sync-logger.js" >nul 2>nul
del "%PACKAGE_NAME%\js\enhanced-sync.js" >nul 2>nul
del "%PACKAGE_NAME%\js\sync.js" >nul 2>nul

:: 删除测试API
del "%PACKAGE_NAME%\api\*-simple.php" >nul 2>nul
del "%PACKAGE_NAME%\api\*-emergency.php" >nul 2>nul
del "%PACKAGE_NAME%\api\test-*.php" >nul 2>nul

echo 清理完成

echo [4/5] 创建部署包...
if exist "%PACKAGE_NAME%.zip" del "%PACKAGE_NAME%.zip"

:: 使用PowerShell创建ZIP文件
powershell -Command "Compress-Archive -Path '%PACKAGE_NAME%\*' -DestinationPath '%PACKAGE_NAME%.zip' -Force"

if exist "%PACKAGE_NAME%.zip" (
    echo 成功: 部署包创建成功: %PACKAGE_NAME%.zip
) else (
    echo 错误: 部署包创建失败
    pause
    exit /b 1
)

echo [5/5] 生成部署信息...
echo.
echo ========================================
echo 成功! v%VERSION% 部署包创建完成
echo ========================================
echo.
echo 部署包: %PACKAGE_NAME%.zip
echo.
echo 主要修复:
echo   - 修复跨浏览器数据同步问题
echo   - 使用共享数据文件确保数据一致性
echo   - 优化数据合并算法
echo   - 增强文件锁机制
echo.
echo 包含文件:
dir "%PACKAGE_NAME%" /B
echo.

:: 创建部署信息文件
echo 任务管理系统 v%VERSION% 部署信息 > %PACKAGE_NAME%-info.txt
echo 创建时间: %date% %time% >> %PACKAGE_NAME%-info.txt
echo 版本特性: 修复跨浏览器数据同步问题 >> %PACKAGE_NAME%-info.txt
echo 部署包大小: >> %PACKAGE_NAME%-info.txt
for %%A in ("%PACKAGE_NAME%.zip") do echo   %%~zA 字节 >> %PACKAGE_NAME%-info.txt

echo 下一步操作:
echo   1. 运行 git-publish-v%VERSION%.bat 发布到Git
echo   2. 运行 server-deploy-v%VERSION%.bat 部署到服务器
echo.
pause