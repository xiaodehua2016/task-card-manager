@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2.1 Git部署

REM 创建日志目录
if not exist "%~dp0logs" mkdir "%~dp0logs"

REM 生成带时间戳的日志文件名
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_FILE="%~dp0logs\git_deploy_log_%TIMESTAMP%.txt"

echo v4.2.2.1 Git部署 > %LOG_FILE%
echo ======================================== >> %LOG_FILE%
echo 部署开始时间: %date% %time% >> %LOG_FILE%
echo. >> %LOG_FILE%

echo.
echo ========================================
echo    小久任务管理系统 v4.2.2.1 Git部署
echo ========================================
echo.
echo 日志文件: %LOG_FILE%
echo.

REM 检查PowerShell是否可用
echo 检查PowerShell是否可用... >> %LOG_FILE%
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未检测到PowerShell，无法继续部署 >> %LOG_FILE%
    echo ❌ 未检测到PowerShell，无法继续部署
    echo 请安装PowerShell后重试 >> %LOG_FILE%
    echo 请安装PowerShell后重试
    pause
    exit /b 1
) else (
    echo ✅ PowerShell检测成功 >> %LOG_FILE%
)

REM 检查Git是否可用
echo 检查Git是否可用... >> %LOG_FILE%
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未检测到Git，无法继续部署 >> %LOG_FILE%
    echo ❌ 未检测到Git，无法继续部署
    echo 请安装Git后重试 >> %LOG_FILE%
    echo 请安装Git后重试
    pause
    exit /b 1
) else (
    echo ✅ Git检测成功 >> %LOG_FILE%
    git --version >> %LOG_FILE% 2>&1
)

REM 检查Git仓库
echo 检查Git仓库... >> %LOG_FILE%
if not exist ".git" (
    echo ❌ 当前目录不是Git仓库，正在初始化... >> %LOG_FILE%
    echo ❌ 当前目录不是Git仓库，正在初始化...
    git init >> %LOG_FILE% 2>&1
    if %errorlevel% neq 0 (
        echo ❌ Git仓库初始化失败 >> %LOG_FILE%
        echo ❌ Git仓库初始化失败
        pause
        exit /b 1
    ) else (
        echo ✅ Git仓库初始化成功 >> %LOG_FILE%
        echo ✅ Git仓库初始化成功
    )
) else (
    echo ✅ Git仓库检测成功 >> %LOG_FILE%
)

REM 检查Git用户配置
echo 检查Git用户配置... >> %LOG_FILE%
git config --get user.name >> %LOG_FILE% 2>&1
git config --get user.email >> %LOG_FILE% 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ Git用户配置不完整，正在配置临时用户... >> %LOG_FILE%
    echo ⚠️ Git用户配置不完整，正在配置临时用户...
    git config --local user.name "TaskManager" >> %LOG_FILE% 2>&1
    git config --local user.email "taskmanager@example.com" >> %LOG_FILE% 2>&1
    echo ✅ Git临时用户配置完成 >> %LOG_FILE%
)

echo.
echo 🚀 开始Git部署...
echo 🚀 开始Git部署... >> %LOG_FILE%

REM 使用简化版的PowerShell脚本，避免中文字符编码问题
powershell -ExecutionPolicy Bypass -File "%~dp0git-deploy-v4.2.2.1-simple.ps1" >> %LOG_FILE% 2>&1
set DEPLOY_STATUS=%errorlevel%

echo. >> %LOG_FILE%
echo 部署完成，状态码: %DEPLOY_STATUS% >> %LOG_FILE%

if %DEPLOY_STATUS% neq 0 (
    echo ❌ 部署过程中出现错误，请查看日志文件: %LOG_FILE% >> %LOG_FILE%
    echo.
    echo ❌ 部署过程中出现错误，请查看日志文件:
    echo %LOG_FILE%
    
    REM 尝试分析错误原因
    echo.
    echo 正在分析错误原因...
    echo 正在分析错误原因... >> %LOG_FILE%
    
    REM 检查是否有远程仓库配置
    git remote -v >> %LOG_FILE% 2>&1
    if %errorlevel% neq 0 (
        echo ⚠️ 未配置远程仓库，这可能是部署失败的原因 >> %LOG_FILE%
        echo ⚠️ 未配置远程仓库，这可能是部署失败的原因
        echo.
        echo 解决方案: >> %LOG_FILE%
        echo 解决方案:
        echo 1. 使用以下命令添加远程仓库: >> %LOG_FILE%
        echo 1. 使用以下命令添加远程仓库:
        echo    git remote add origin https://github.com/用户名/仓库名.git >> %LOG_FILE%
        echo    git remote add origin https://github.com/用户名/仓库名.git
    )
    
    REM 检查是否有认证问题
    findstr /C:"Authentication failed" %LOG_FILE% >nul
    if not %errorlevel% neq 0 (
        echo ⚠️ Git认证失败，这可能是部署失败的原因 >> %LOG_FILE%
        echo ⚠️ Git认证失败，这可能是部署失败的原因
        echo.
        echo 解决方案: >> %LOG_FILE%
        echo 解决方案:
        echo 1. 检查GitHub用户名和密码 >> %LOG_FILE%
        echo 1. 检查GitHub用户名和密码
        echo 2. 或者配置SSH密钥认证 >> %LOG_FILE%
        echo 2. 或者配置SSH密钥认证
    )
) else (
    echo ✅ Git部署成功完成！ >> %LOG_FILE%
    echo.
    echo ✅ Git部署成功完成！
)

echo. >> %LOG_FILE%
echo 部署结束时间: %date% %time% >> %LOG_FILE%
echo ======================================== >> %LOG_FILE%

echo.
echo 日志文件保存在: %LOG_FILE%
echo.
pause
