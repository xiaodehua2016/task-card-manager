@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2 部署验证

echo.
echo ========================================
echo    小久任务管理系统 v4.2.2 部署验证
echo ========================================
echo.

REM 检查PowerShell是否可用
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未检测到PowerShell，无法继续验证
    echo 请安装PowerShell后重试
    pause
    exit /b 1
)

REM 执行PowerShell脚本
powershell -ExecutionPolicy Bypass -File "%~dp0验证部署-v4.2.2.ps1"

echo.
if %errorlevel% neq 0 (
    echo ❌ 验证过程中出现错误，请查看上方信息
    pause
    exit /b 1
)

echo ✅ 验证脚本执行完成
pause