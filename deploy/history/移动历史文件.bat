@echo off
chcp 65001 >nul
echo 正在移动历史部署文件到history目录...

REM 移动所有历史版本的PowerShell脚本
if exist "deploy-to-111.ps1" move "deploy-to-111.ps1" "history\" >nul 2>&1
if exist "simple-deploy-to-111.ps1" move "simple-deploy-to-111.ps1" "history\" >nul 2>&1
if exist "create-package.ps1" move "create-package.ps1" "history\" >nul 2>&1
if exist "upload-and-deploy.ps1" move "upload-and-deploy.ps1" "history\" >nul 2>&1
if exist "git-deploy-final.ps1" move "git-deploy-final.ps1" "history\" >nul 2>&1
if exist "server-deploy-final.ps1" move "server-deploy-final.ps1" "history\" >nul 2>&1
if exist "server-deploy-final-v2.ps1" move "server-deploy-final-v2.ps1" "history\" >nul 2>&1
if exist "git-deploy-final-v2.ps1" move "git-deploy-final-v2.ps1" "history\" >nul 2>&1
if exist "super-simple-deploy.ps1" move "super-simple-deploy.ps1" "history\" >nul 2>&1
if exist "deploy-to-git.ps1" move "deploy-to-git.ps1" "history\" >nul 2>&1

REM 移动所有历史版本的批处理文件
if exist "简易部署到111服务器.bat" move "简易部署到111服务器.bat" "history\" >nul 2>&1
if exist "创建部署包.bat" move "创建部署包.bat" "history\" >nul 2>&1
if exist "上传并部署.bat" move "上传并部署.bat" "history\" >nul 2>&1
if exist "超简易部署到111服务器.bat" move "超简易部署到111服务器.bat" "history\" >nul 2>&1
if exist "部署到Git.bat" move "部署到Git.bat" "history\" >nul 2>&1
if exist "部署到111服务器.bat" move "部署到111服务器.bat" "history\" >nul 2>&1
if exist "服务器部署-最终修复版.bat" move "服务器部署-最终修复版.bat" "history\" >nul 2>&1
if exist "Git部署-最终修复版.bat" move "Git部署-最终修复版.bat" "history\" >nul 2>&1
if exist "Git部署-最终版.bat" move "Git部署-最终版.bat" "history\" >nul 2>&1
if exist "服务器部署-最终版.bat" move "服务器部署-最终版.bat" "history\" >nul 2>&1
if exist "Git部署-终极修复版.bat" move "Git部署-终极修复版.bat" "history\" >nul 2>&1
if exist "服务器部署-终极修复版v2.1.bat" move "服务器部署-终极修复版v2.1.bat" "history\" >nul 2>&1

REM 移动历史文档
if exist "部署指南.md" move "部署指南.md" "history\" >nul 2>&1
if exist "部署指南-最终版.md" move "部署指南-最终版.md" "history\" >nul 2>&1
if exist "使用说明-最新版.md" move "使用说明-最新版.md" "history\" >nul 2>&1
if exist "终极修复确认.md" move "终极修复确认.md" "history\" >nul 2>&1
if exist "问题修复总结.md" move "问题修复总结.md" "history\" >nul 2>&1

echo 历史文件移动完成！
echo 当前可用的最新脚本：
echo   - Git部署: git-deploy-final-v3.ps1
echo   - 服务器部署: server-deploy-final-v2.2.ps1
echo   - 对应批处理: 服务器部署-最新版v2.2.bat
pause