@echo off
chcp 65001 >nul
echo 正在启动服务器部署脚本...
powershell -ExecutionPolicy Bypass -File "%~dp0server-deploy-final.ps1"
pause