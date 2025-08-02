@echo off
chcp 65001 > nul
title 整理部署目录 v4.2.2.1

echo.
echo ========================================
echo    整理部署目录 - 移动历史文件到history
echo ========================================
echo.

REM 创建临时目录
mkdir temp_deploy 2>nul

REM 复制必要文件到临时目录
echo 复制必要文件到临时目录...
copy "deploy-v4.2.2.1.ps1" "temp_deploy\" 2>nul
copy "部署到服务器-v4.2.2.1.bat" "temp_deploy\" 2>nul
copy "一键部署-v4.2.2.1.bat" "temp_deploy\" 2>nul
copy "快速部署-v4.2.2.1.bat" "temp_deploy\" 2>nul
copy "Git部署-v4.2.2.1.bat" "temp_deploy\" 2>nul
copy "git-deploy-v4.2.2.1.ps1" "temp_deploy\" 2>nul
copy "部署指南-v4.2.2.1.md" "temp_deploy\" 2>nul
copy "README.md" "temp_deploy\" 2>nul

REM 创建history目录
mkdir history 2>nul

REM 移动所有文件到history目录
echo 移动历史文件到history目录...
for %%f in (*) do (
    if not "%%f"=="temp_deploy" if not "%%f"=="history" if not "%%f"=="整理部署目录.bat" (
        move "%%f" "history\" 2>nul
    )
)

REM 从临时目录复制回必要文件
echo 从临时目录复制回必要文件...
copy "temp_deploy\*" "." 2>nul

REM 删除临时目录
rmdir /s /q temp_deploy 2>nul

echo.
echo 保留以下必要文件:
echo - deploy-v4.2.2.1.ps1
echo - 部署到服务器-v4.2.2.1.bat
echo - 一键部署-v4.2.2.1.bat
echo - 快速部署-v4.2.2.1.bat
echo - Git部署-v4.2.2.1.bat
echo - git-deploy-v4.2.2.1.ps1
echo - 部署指南-v4.2.2.1.md
echo - README.md (如果存在)
echo.

echo 整理完成！
echo.
pause