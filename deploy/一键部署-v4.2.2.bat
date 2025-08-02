@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2 一键部署

echo.
echo ========================================
echo    小久任务管理系统 v4.2.2 一键部署
echo ========================================
echo.

REM 检查PowerShell是否可用
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未检测到PowerShell，无法继续部署
    echo 请安装PowerShell后重试
    pause
    exit /b 1
)

echo 🚀 部署选项:
echo.
echo 1. 自动部署到服务器
echo 2. 手动部署到服务器 (推荐)
echo 3. Git部署
echo 4. 仅创建部署包
echo.

set /p choice="请选择部署方式 (1-4): "

if "%choice%"=="1" goto auto_deploy
if "%choice%"=="2" goto manual_deploy
if "%choice%"=="3" goto git_deploy
if "%choice%"=="4" goto package_only
goto invalid_choice

:auto_deploy
echo.
echo 🚀 开始自动部署到服务器...
powershell -ExecutionPolicy Bypass -File "%~dp0deploy-v4.2.2.ps1"
goto end

:manual_deploy
echo.
echo 🚀 开始手动部署准备...
call "%~dp0部署到服务器-v4.2.2.bat"
goto end

:git_deploy
echo.
echo 🚀 开始Git部署...
call "%~dp0Git部署-v4.2.2.bat"
goto end

:package_only
echo.
echo 📦 仅创建部署包...
powershell -ExecutionPolicy Bypass -Command "& { . '%~dp0deploy-v4.2.2.ps1'; Create-Package }"
goto end

:invalid_choice
echo ❌ 无效选择，请重新运行脚本
goto end

:end
echo.
echo 🎉 操作完成！
pause