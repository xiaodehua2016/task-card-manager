@echo off
chcp 65001 >nul
echo 正在启动服务器部署脚本 (最新版v2.2)...
echo 此版本包含自动密码输入和增强的错误处理功能
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0server-deploy-final-v2.2.ps1"
pause