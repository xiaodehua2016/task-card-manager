@echo off
chcp 65001 > nul
echo 正在启动PowerShell上传部署脚本...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0upload-and-deploy.ps1"
echo.
echo 按任意键退出...
pause > nul