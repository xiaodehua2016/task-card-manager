@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2.1 部署

echo.
echo ========================================
echo    小久任务管理系统 v4.2.2.1 自动化部署
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

REM 执行PowerShell脚本
powershell -ExecutionPolicy Bypass -File "%~dp0deploy-v4.2.2.1.ps1"

echo.
if %errorlevel% neq 0 (
    echo ❌ 部署过程中出现错误，请查看上方信息
    pause
    exit /b 1
)

echo ✅ 部署脚本执行完成
pause