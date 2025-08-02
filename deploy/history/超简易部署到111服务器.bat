@echo off
chcp 65001 > nul
echo 正在启动超简易PowerShell部署脚本...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0super-simple-deploy.ps1"
echo.
echo 按任意键退出...
pause > nul