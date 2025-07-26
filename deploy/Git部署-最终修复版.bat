@echo off
chcp 65001 >nul
echo 正在启动Git部署脚本 (最终修复版)...
powershell -ExecutionPolicy Bypass -File "%~dp0git-deploy-final-v2.ps1"
pause