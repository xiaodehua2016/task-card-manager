@echo off
chcp 65001 >nul
echo 正在启动Git部署脚本...
powershell -ExecutionPolicy Bypass -File "%~dp0git-deploy-final.ps1"
pause