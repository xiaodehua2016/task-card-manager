@echo off
chcp 65001 > nul
title 整理部署目录 v4.2.2.1

echo.
echo ========================================
echo    整理部署目录 - 移动历史文件到history
echo ========================================
echo.

REM 确保history目录存在
if not exist "deploy\history" mkdir "deploy\history"

echo 正在移动历史文件到history目录...

REM 移动旧版本的部署脚本，保留v4.2.2.1版本的必要文件
move "deploy\版本管理说明.md" "deploy\history\" 2>nul
move "deploy\部署到111服务器.bat" "deploy\history\" 2>nul
move "deploy\部署到服务器-v4.2.2.bat" "deploy\history\" 2>nul
move "deploy\部署到Git.bat" "deploy\history\" 2>nul
move "deploy\部署检查清单-v4.2.2.md" "deploy\history\" 2>nul
move "deploy\部署指南-最终版.md" "deploy\history\" 2>nul
move "deploy\部署指南-v4.2.2.md" "deploy\history\" 2>nul
move "deploy\部署指南.md" "deploy\history\" 2>nul
move "deploy\部署状态总结.md" "deploy\history\" 2>nul
move "deploy\超简易部署到111服务器.bat" "deploy\history\" 2>nul
move "deploy\创建部署包.bat" "deploy\history\" 2>nul
move "deploy\服务器部署-终极修复版v2.1.bat" "deploy\history\" 2>nul
move "deploy\服务器部署-最新版v2.2.bat" "deploy\history\" 2>nul
move "deploy\服务器部署-最终版.bat" "deploy\history\" 2>nul
move "deploy\服务器部署-最终修复版.bat" "deploy\history\" 2>nul
move "deploy\服务器部署-v4.2.1.1.bat" "deploy\history\" 2>nul
move "deploy\服务器部署-v4.2.1.2.bat" "deploy\history\" 2>nul
move "deploy\快速部署-v4.2.2.bat" "deploy\history\" 2>nul
move "deploy\立即使用指南-v4.2.2.md" "deploy\history\" 2>nul
move "deploy\上传并部署.bat" "deploy\history\" 2>nul
move "deploy\使用说明-最新版.md" "deploy\history\" 2>nul
move "deploy\数据同步修复完成确认-v4.2.1.md" "deploy\history\" 2>nul
move "deploy\问题修复总结.md" "deploy\history\" 2>nul
move "deploy\验证部署-v4.2.2.bat" "deploy\history\" 2>nul
move "deploy\验证部署-v4.2.2.ps1" "deploy\history\" 2>nul
move "deploy\验证同步修复.bat" "deploy\history\" 2>nul
move "deploy\一键部署-v4.2.2.bat" "deploy\history\" 2>nul
move "deploy\一键部署v4.2.2.bat" "deploy\history\" 2>nul
move "deploy\移动历史文件.bat" "deploy\history\" 2>nul
move "deploy\终极简化部署v4.2.2.bat" "deploy\history\" 2>nul
move "deploy\终极修复确认.md" "deploy\history\" 2>nul
move "deploy\最终解决方案-v4.2.2.md" "deploy\history\" 2>nul
move "deploy\最终使用指南.md" "deploy\history\" 2>nul
move "deploy\最终修复确认.md" "deploy\history\" 2>nul
move "deploy\add-site-to-baota.sh" "deploy\history\" 2>nul
move "deploy\BAOTA_DEPLOYMENT_GUIDE.md" "deploy\history\" 2>nul
move "deploy\BAOTA_MANUAL_ADD_SITE.md" "deploy\history\" 2>nul
move "deploy\check-network-access.sh" "deploy\history\" 2>nul
move "deploy\CODEBUDDY_NPM_FIX.md" "deploy\history\" 2>nul
move "deploy\DATA_CONSISTENCY_SOLUTION.md" "deploy\history\" 2>nul
move "deploy\deploy_log_*.txt" "deploy\history\" 2>nul
move "deploy\deploy-setup.js" "deploy\history\" 2>nul
move "deploy\deploy-v4.2.2.ps1" "deploy\history\" 2>nul
move "deploy\deploy.bat" "deploy\history\" 2>nul
move "deploy\DEPLOYMENT_MANUAL_v4.2.0.md" "deploy\history\" 2>nul
move "deploy\DEPLOYMENT_SUCCESS_CONFIRMATION.md" "deploy\history\" 2>nul
move "deploy\DEPLOYMENT.md" "deploy\history\" 2>nul
move "deploy\FINAL_DEPLOYMENT_CONFIRMATION.md" "deploy\history\" 2>nul
move "deploy\FINAL_DEPLOYMENT_READY_v4.2.0.md" "deploy\history\" 2>nul
move "deploy\FINAL_RELEASE_v4.2.2.md" "deploy\history\" 2>nul
move "deploy\fix-baota-permissions.sh" "deploy\history\" 2>nul
move "deploy\fix-nginx-service.sh" "deploy\history\" 2>nul
move "deploy\fix-site-not-found.sh" "deploy\history\" 2>nul
move "deploy\git_deploy_log_*.txt" "deploy\history\" 2>nul
move "deploy\git-deploy-final-v4.2.1.1.ps1" "deploy\history\" 2>nul
move "deploy\git-deploy-v4.2.2.ps1" "deploy\history\" 2>nul
move "deploy\Git部署-终极修复版.bat" "deploy\history\" 2>nul
move "deploy\Git部署-最终版.bat" "deploy\history\" 2>nul
move "deploy\Git部署-最终修复版.bat" "deploy\history\" 2>nul
move "deploy\Git部署-v4.2.1.1.bat" "deploy\history\" 2>nul
move "deploy\Git部署-v4.2.2.bat" "deploy\history\" 2>nul
move "deploy\one-click-deploy.sh" "deploy\history\" 2>nul
move "deploy\QUICK_START.md" "deploy\history\" 2>nul
move "deploy\quick-diagnosis.sh" "deploy\history\" 2>nul
move "deploy\SERVER_DEPLOYMENT_MANUAL.md" "deploy\history\" 2>nul
move "deploy\server-deploy-final-v2.1.ps1" "deploy\history\" 2>nul
move "deploy\server-deploy-final-v2.2.ps1" "deploy\history\" 2>nul
move "deploy\server-deploy-final-v4.2.1.1.ps1" "deploy\history\" 2>nul
move "deploy\server-deploy-final-v4.2.1.2.ps1" "deploy\history\" 2>nul
move "deploy\server-deploy-final-v4.2.1.3.ps1" "deploy\history\" 2>nul
move "deploy\setup.bat" "deploy\history\" 2>nul
move "deploy\setup.sh" "deploy\history\" 2>nul
move "deploy\simple-deployment.sh" "deploy\history\" 2>nul
move "deploy\simple-setup.html" "deploy\history\" 2>nul
move "deploy\TROUBLESHOOTING_BAOTA.md" "deploy\history\" 2>nul
move "deploy\TROUBLESHOOTING.md" "deploy\history\" 2>nul
move "deploy\v4.2.1-部署检查清单.md" "deploy\history\" 2>nul
move "deploy\verify-deployment.sh" "deploy\history\" 2>nul
move "deploy\verify-sync-fix.sh" "deploy\history\" 2>nul

echo.
echo 保留以下必要文件:
echo - deploy-v4.2.2.1.ps1
echo - 部署到服务器-v4.2.2.1.bat
echo - 一键部署-v4.2.2.1.bat
echo - 快速部署-v4.2.2.1.bat
echo - Git部署-v4.2.2.1.bat
echo - git-deploy-v4.2.2.1.ps1
echo - 部署指南-v4.2.2.1.md
echo - README.md (如果存在)
echo.

echo 整理完成！
echo.
pause