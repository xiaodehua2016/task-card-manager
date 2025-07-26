@echo off
chcp 65001 >nul
echo 正在启动Git部署脚本 (终极修复版)...
powershell -ExecutionPolicy Bypass -File "%~dp0git-deploy-final-v3.ps1"
pause