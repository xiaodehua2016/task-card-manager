@echo off
chcp 65001 > nul
echo 正在启动简化版PowerShell部署脚本...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0simple-deploy-to-111.ps1"
echo.
echo 按任意键退出...
pause > nul