@echo off
chcp 65001 > nul
title 整理部署目录 v4.2.2.1

echo.
echo ========================================
echo    整理部署目录 - 移动历史文件到history
echo ========================================
echo.

REM 检查PowerShell是否可用
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未检测到PowerShell，无法继续操作
    echo 请安装PowerShell后重试
    pause
    exit /b 1
)

REM 执行PowerShell脚本
powershell -ExecutionPolicy Bypass -File "%~dp0整理部署目录-v4.2.2.1.ps1"

echo.
if %errorlevel% neq 0 (
    echo ❌ 整理过程中出现错误，请查看上方信息
    pause
    exit /b 1
)

echo ✅ 部署目录整理完成
pause