@echo off
chcp 65001 > nul
echo 正在启动PowerShell部署包创建脚本...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0create-package.ps1"
echo.
echo 按任意键退出...
pause > nul