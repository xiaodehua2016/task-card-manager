@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2.1.1 Git部署

REM 切换到项目根目录
cd /d %~dp0..

REM 创建日志目录
if not exist "%~dp0logs" mkdir "%~dp0logs"

REM 生成带时间戳的日志文件名
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_FILE="%~dp0logs\git_deploy_log_%TIMESTAMP%.txt"

echo v4.2.2.1.1 Git部署 > %LOG_FILE%
echo ======================================== >> %LOG_FILE%
echo 部署开始时间: %date% %time% >> %LOG_FILE%
echo. >> %LOG_FILE%

echo.
echo ========================================
echo    小久任务管理系统 v4.2.2.1.1 Git部署
echo ========================================
echo.
echo 日志文件: %LOG_FILE%
echo 当前工作目录: %CD% >> %LOG_FILE%
echo 当前工作目录: %CD%
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

REM 检查是否存在deploy/.git目录（错误的Git仓库位置）
if exist "deploy\.git" (
    echo ⚠️ 检测到deploy目录下存在Git仓库，这是不正确的位置 >> %LOG_FILE%
    echo ⚠️ 检测到deploy目录下存在Git仓库，这是不正确的位置
    echo 正在删除deploy/.git目录... >> %LOG_FILE%
    echo 正在删除deploy/.git目录...
    rmdir /s /q "deploy\.git" >> %LOG_FILE% 2>&1
    echo ✅ 已删除错误位置的Git仓库 >> %LOG_FILE%
    echo ✅ 已删除错误位置的Git仓库
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

REM 检查远程仓库配置
echo 检查远程仓库配置... >> %LOG_FILE%
git remote -v >> %LOG_FILE% 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ 未配置远程仓库，跳过推送步骤 >> %LOG_FILE%
    echo ⚠️ 未配置远程仓库，跳过推送步骤
    set SKIP_PUSH=1
) else (
    set SKIP_PUSH=0
)

echo.
echo 🚀 开始Git部署...
echo 🚀 开始Git部署... >> %LOG_FILE%

REM 使用简化版的PowerShell脚本，避免中文字符编码问题
powershell -ExecutionPolicy Bypass -File "%~dp0git-deploy-v4.2.2.1-simple.ps1" >> %LOG_FILE% 2>&1
set DEPLOY_STATUS=%errorlevel%

REM 检查是否有提交
echo 检查是否有提交... >> %LOG_FILE%
git log -n 1 --oneline >> %LOG_FILE% 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ 没有找到任何提交记录，创建首次提交... >> %LOG_FILE%
    echo ⚠️ 没有找到任何提交记录，创建首次提交...
    
    REM 创建README.md文件（如果不存在）
    if not exist "README.md" (
        echo # 小久任务管理系统 v4.2.2.1.1 > README.md
        echo. >> README.md
        echo 这是一个任务管理系统，支持跨浏览器数据同步。 >> README.md
    )
    
    git add . >> %LOG_FILE% 2>&1
    git commit -m "初始提交: v4.2.2.1.1" >> %LOG_FILE% 2>&1
    echo ✅ 首次提交创建成功 >> %LOG_FILE%
    echo ✅ 首次提交创建成功
)

REM 检查当前分支
echo 检查当前分支... >> %LOG_FILE%
for /f "tokens=*" %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i
echo 当前分支: %CURRENT_BRANCH% >> %LOG_FILE%
echo 当前分支: %CURRENT_BRANCH%

REM 如果不是main分支，创建并切换到main分支
if not "%CURRENT_BRANCH%"=="main" (
    echo ⚠️ 当前不在main分支，正在切换... >> %LOG_FILE%
    echo ⚠️ 当前不在main分支，正在切换...
    git branch -m main >> %LOG_FILE% 2>&1
    echo ✅ 已切换到main分支 >> %LOG_FILE%
    echo ✅ 已切换到main分支
)

REM 如果不跳过推送，则推送到远程仓库
if "%SKIP_PUSH%"=="0" (
    echo 推送到远程仓库... >> %LOG_FILE%
    echo 推送到远程仓库...
    git push -u origin main >> %LOG_FILE% 2>&1
    if %errorlevel% neq 0 (
        echo ❌ 推送失败，请检查远程仓库配置和网络连接 >> %LOG_FILE%
        echo ❌ 推送失败，请检查远程仓库配置和网络连接
        echo.
        echo 如需配置远程仓库，请使用以下命令: >> %LOG_FILE%
        echo 如需配置远程仓库，请使用以下命令:
        echo git remote add origin https://github.com/用户名/仓库名.git >> %LOG_FILE%
        echo git remote add origin https://github.com/用户名/仓库名.git
    ) else (
        echo ✅ 推送成功 >> %LOG_FILE%
        echo ✅ 推送成功
    )
) else (
    echo 跳过推送步骤（未配置远程仓库） >> %LOG_FILE%
    echo 跳过推送步骤（未配置远程仓库）
)

echo. >> %LOG_FILE%
echo 部署完成，状态码: %DEPLOY_STATUS% >> %LOG_FILE%

if %DEPLOY_STATUS% neq 0 (
    echo ❌ 部署过程中出现错误，请查看日志文件: %LOG_FILE% >> %LOG_FILE%
    echo.
    echo ❌ 部署过程中出现错误，请查看日志文件:
    echo %LOG_FILE%
) else (
    echo ✅ Git部署成功完成！ >> %LOG_FILE%
    echo.
    echo ✅ Git部署成功完成！
    
    echo.
    echo 📋 后续步骤: >> %LOG_FILE%
    echo 📋 后续步骤:
    echo 1. 如需部署到GitHub Pages，请在GitHub仓库设置中启用GitHub Pages >> %LOG_FILE%
    echo 1. 如需部署到GitHub Pages，请在GitHub仓库设置中启用GitHub Pages
    echo 2. 如需部署到Vercel，请在Vercel中导入GitHub仓库 >> %LOG_FILE%
    echo 2. 如需部署到Vercel，请在Vercel中导入GitHub仓库
)

echo. >> %LOG_FILE%
echo 部署结束时间: %date% %time% >> %LOG_FILE%
echo ======================================== >> %LOG_FILE%

echo.
echo 日志文件保存在: %LOG_FILE%
echo.
pause