@echo off
chcp 65001 >nul
echo 正在启动服务器部署脚本 (终极修复版v2.1)...
powershell -ExecutionPolicy Bypass -File "%~dp0server-deploy-final-v2.1.ps1"
pause