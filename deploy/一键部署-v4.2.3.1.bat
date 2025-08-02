@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.3 一键部署

REM 设置日志文件
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_DIR=%~dp0logs
set LOG_FILE=%LOG_DIR%\deploy_log_%TIMESTAMP%.txt

REM 创建日志目录
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM 开始记录日志
echo ======================================== > "%LOG_FILE%"
echo    小久任务管理系统 v4.2.3 一键部署    >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 部署开始时间: %date% %time% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo ========================================
echo    小久任务管理系统 v4.2.3 一键部署
echo ========================================
echo.
echo 📝 日志将保存到: %LOG_FILE%
echo.

REM 检查PowerShell是否可用
echo 检查PowerShell是否可用... >> "%LOG_FILE%"
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未检测到PowerShell，无法继续部署
    echo 请安装PowerShell后重试
    echo ❌ 未检测到PowerShell，无法继续部署 >> "%LOG_FILE%"
    echo 错误代码: %errorlevel% >> "%LOG_FILE%"
    echo 部署失败时间: %date% %time% >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo ✅ PowerShell检测成功 >> "%LOG_FILE%"

echo 🚀 部署选项:
echo.
echo 1. 自动部署到服务器
echo 2. 手动部署到服务器 (推荐)
echo 3. Git部署
echo 4. 仅创建部署包
echo.

echo 显示部署选项... >> "%LOG_FILE%"
echo 1. 自动部署到服务器 >> "%LOG_FILE%"
echo 2. 手动部署到服务器 (推荐) >> "%LOG_FILE%"
echo 3. Git部署 >> "%LOG_FILE%"
echo 4. 仅创建部署包 >> "%LOG_FILE%"

set /p choice="请选择部署方式 (1-4): "
echo 用户选择: %choice% >> "%LOG_FILE%"

if "%choice%"=="1" goto auto_deploy
if "%choice%"=="2" goto manual_deploy
if "%choice%"=="3" goto git_deploy
if "%choice%"=="4" goto package_only
echo ❌ 无效选择: %choice% >> "%LOG_FILE%"
goto invalid_choice

:auto_deploy
echo.
echo 🚀 开始自动部署到服务器...
echo 开始自动部署到服务器... >> "%LOG_FILE%"
echo 执行命令: powershell -ExecutionPolicy Bypass -File "%~dp0deploy-v4.2.3.1-en.ps1" >> "%LOG_FILE%"
powershell -ExecutionPolicy Bypass -File "%~dp0deploy-v4.2.3.1-en.ps1" >> "%LOG_FILE%" 2>&1
set DEPLOY_STATUS=%errorlevel%
echo 部署完成，状态码: %DEPLOY_STATUS% >> "%LOG_FILE%"
if %DEPLOY_STATUS% neq 0 (
    echo ❌ 部署过程中出现错误，请查看日志文件: %LOG_FILE%
    echo 错误代码: %DEPLOY_STATUS% >> "%LOG_FILE%"
)
goto end

:manual_deploy
echo.
echo 🚀 开始手动部署准备...
echo 开始手动部署准备... >> "%LOG_FILE%"
echo 执行命令: call "%~dp0部署到服务器-v4.2.3.1.bat" >> "%LOG_FILE%"
call "%~dp0部署到服务器-v4.2.3.1.bat" >> "%LOG_FILE%" 2>&1
set DEPLOY_STATUS=%errorlevel%
echo 部署完成，状态码: %DEPLOY_STATUS% >> "%LOG_FILE%"
if %DEPLOY_STATUS% neq 0 (
    echo ❌ 部署过程中出现错误，请查看日志文件: %LOG_FILE%
    echo 错误代码: %DEPLOY_STATUS% >> "%LOG_FILE%"
)
goto end

:git_deploy
echo.
echo 🚀 开始Git部署...
echo 开始Git部署... >> "%LOG_FILE%"
echo 执行命令: call "%~dp0Git部署-v4.2.3.1.bat" >> "%LOG_FILE%"
call "%~dp0Git部署-v4.2.3.1.bat" >> "%LOG_FILE%" 2>&1
set DEPLOY_STATUS=%errorlevel%
echo 部署完成，状态码: %DEPLOY_STATUS% >> "%LOG_FILE%"
if %DEPLOY_STATUS% neq 0 (
    echo ❌ 部署过程中出现错误，请查看日志文件: %LOG_FILE%
    echo 错误代码: %DEPLOY_STATUS% >> "%LOG_FILE%"
)
goto end

:package_only
echo.
echo 📦 仅创建部署包...
echo 仅创建部署包... >> "%LOG_FILE%"
echo 执行命令: powershell -ExecutionPolicy Bypass -Command "& { . '%~dp0deploy-v4.2.3.1-en.ps1'; Create-Package }" >> "%LOG_FILE%"
powershell -ExecutionPolicy Bypass -Command "& { . '%~dp0deploy-v4.2.3.1-en.ps1'; Create-Package }" >> "%LOG_FILE%" 2>&1
set DEPLOY_STATUS=%errorlevel%
echo 部署包创建完成，状态码: %DEPLOY_STATUS% >> "%LOG_FILE%"
if %DEPLOY_STATUS% neq 0 (
    echo ❌ 创建部署包过程中出现错误，请查看日志文件: %LOG_FILE%
    echo 错误代码: %DEPLOY_STATUS% >> "%LOG_FILE%"
)
goto end

:invalid_choice
echo ❌ 无效选择，请重新运行脚本
echo ❌ 无效选择，请重新运行脚本 >> "%LOG_FILE%"
goto end

:end
echo.
echo 部署结束时间: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 🎉 操作完成！
echo.
echo 📝 完整日志已保存到: %LOG_FILE%
pause