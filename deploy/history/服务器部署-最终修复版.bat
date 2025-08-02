@echo off
chcp 65001 >nul
echo 正在启动服务器部署脚本 (最终修复版)...
powershell -ExecutionPolicy Bypass -File "%~dp0server-deploy-final-v2.ps1"
pause