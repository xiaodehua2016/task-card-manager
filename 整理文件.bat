@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2.1 文件整理

echo.
echo ========================================
echo    整理项目文件 - 移动不必要文件到deploy\history
echo ========================================
echo.

echo 正在移动不必要的文件到deploy\history目录...

REM 确保目标目录存在
mkdir deploy\history 2>nul

REM 移动不必要的文档文件
move 项目状态总结-v4.2.2.md deploy\history\ 2>nul
move CHANGELOG.md deploy\history\ 2>nul
move CODE_REVIEW_FINAL.md deploy\history\ 2>nul
move CODE_REVIEW_v4.2.0.md deploy\history\ 2>nul
move PROJECT_STATUS.md deploy\history\ 2>nul
move PROJECT_SUMMARY.md deploy\history\ 2>nul
move RELEASE_STATUS_FINAL.md deploy\history\ 2>nul
move task-manager-v4.1.0.tar.gz deploy\history\ 2>nul
move task-manager-v4.2.2-complete.zip deploy\history\ 2>nul

REM 移动不必要的目录
if exist config (
  mkdir deploy\history\config 2>nul
  xcopy config\* deploy\history\config\ /E /I /Y
  rmdir /s /q config
  echo 已移动: config 目录
)

if exist docs (
  mkdir deploy\history\docs 2>nul
  xcopy docs\* deploy\history\docs\ /E /I /Y
  rmdir /s /q docs
  echo 已移动: docs 目录
)

if exist installenv (
  mkdir deploy\history\installenv 2>nul
  xcopy installenv\* deploy\history\installenv\ /E /I /Y
  rmdir /s /q installenv
  echo 已移动: installenv 目录
)

REM 整理deploy目录
mkdir deploy\history 2>nul

REM 移动旧版本文件到history子目录
move deploy\版本管理说明.md deploy\history\ 2>nul
move deploy\部署到111服务器.bat deploy\history\ 2>nul
move deploy\部署到服务器-v4.2.2.bat deploy\history\ 2>nul
move deploy\部署到Git.bat deploy\history\ 2>nul
move deploy\部署检查清单-v4.2.2.md deploy\history\ 2>nul
move deploy\部署指南-最终版.md deploy\history\ 2>nul
move deploy\部署指南-v4.2.2.md deploy\history\ 2>nul
move deploy\部署指南.md deploy\history\ 2>nul
move deploy\部署状态总结.md deploy\history\ 2>nul
move deploy\超简易部署到111服务器.bat deploy\history\ 2>nul
move deploy\创建部署包.bat deploy\history\ 2>nul
move deploy\服务器部署-终极修复版v2.1.bat deploy\history\ 2>nul
move deploy\服务器部署-最新版v2.2.bat deploy\history\ 2>nul
move deploy\服务器部署-最终版.bat deploy\history\ 2>nul
move deploy\服务器部署-最终修复版.bat deploy\history\ 2>nul
move deploy\服务器部署-v4.2.1.1.bat deploy\history\ 2>nul
move deploy\服务器部署-v4.2.1.2.bat deploy\history\ 2>nul
move deploy\快速部署-v4.2.2.bat deploy\history\ 2>nul
move deploy\立即使用指南-v4.2.2.md deploy\history\ 2>nul
move deploy\上传并部署.bat deploy\history\ 2>nul
move deploy\使用说明-最新版.md deploy\history\ 2>nul
move deploy\数据同步修复完成确认-v4.2.1.md deploy\history\ 2>nul
move deploy\问题修复总结.md deploy\history\ 2>nul
move deploy\验证部署-v4.2.2.bat deploy\history\ 2>nul
move deploy\验证部署-v4.2.2.ps1 deploy\history\ 2>nul
move deploy\验证同步修复.bat deploy\history\ 2>nul
move deploy\一键部署-v4.2.2.bat deploy\history\ 2>nul
move deploy\一键部署v4.2.2.bat deploy\history\ 2>nul
move deploy\移动历史文件.bat deploy\history\ 2>nul
move deploy\终极简化部署v4.2.2.bat deploy\history\ 2>nul
move deploy\终极修复确认.md deploy\history\ 2>nul
move deploy\最终解决方案-v4.2.2.md deploy\history\ 2>nul
move deploy\最终使用指南.md deploy\history\ 2>nul
move deploy\最终修复确认.md deploy\history\ 2>nul
move deploy\add-site-to-baota.sh deploy\history\ 2>nul
move deploy\BAOTA_DEPLOYMENT_GUIDE.md deploy\history\ 2>nul
move deploy\BAOTA_MANUAL_ADD_SITE.md deploy\history\ 2>nul
move deploy\check-network-access.sh deploy\history\ 2>nul
move deploy\CODEBUDDY_NPM_FIX.md deploy\history\ 2>nul
move deploy\DATA_CONSISTENCY_SOLUTION.md deploy\history\ 2>nul
move deploy\deploy_log_*.txt deploy\history\ 2>nul
move deploy\deploy-setup.js deploy\history\ 2>nul
move deploy\deploy-v4.2.2.ps1 deploy\history\ 2>nul
move deploy\deploy.bat deploy\history\ 2>nul
move deploy\DEPLOYMENT_MANUAL_v4.2.0.md deploy\history\ 2>nul
move deploy\DEPLOYMENT_SUCCESS_CONFIRMATION.md deploy\history\ 2>nul
move deploy\DEPLOYMENT.md deploy\history\ 2>nul
move deploy\FINAL_DEPLOYMENT_CONFIRMATION.md deploy\history\ 2>nul
move deploy\FINAL_DEPLOYMENT_READY_v4.2.0.md deploy\history\ 2>nul
move deploy\FINAL_RELEASE_v4.2.2.md deploy\history\ 2>nul
move deploy\fix-baota-permissions.sh deploy\history\ 2>nul
move deploy\fix-nginx-service.sh deploy\history\ 2>nul
move deploy\fix-site-not-found.sh deploy\history\ 2>nul
move deploy\git_deploy_log_*.txt deploy\history\ 2>nul
move deploy\git-deploy-final-v4.2.1.1.ps1 deploy\history\ 2>nul
move deploy\git-deploy-v4.2.2.ps1 deploy\history\ 2>nul
move deploy\Git部署-终极修复版.bat deploy\history\ 2>nul
move deploy\Git部署-最终版.bat deploy\history\ 2>nul
move deploy\Git部署-最终修复版.bat deploy\history\ 2>nul
move deploy\Git部署-v4.2.1.1.bat deploy\history\ 2>nul
move deploy\Git部署-v4.2.2.bat deploy\history\ 2>nul
move deploy\one-click-deploy.sh deploy\history\ 2>nul
move deploy\QUICK_START.md deploy\history\ 2>nul
move deploy\quick-diagnosis.sh deploy\history\ 2>nul
move deploy\SERVER_DEPLOYMENT_MANUAL.md deploy\history\ 2>nul
move deploy\server-deploy-final-v2.1.ps1 deploy\history\ 2>nul
move deploy\server-deploy-final-v2.2.ps1 deploy\history\ 2>nul
move deploy\server-deploy-final-v4.2.1.1.ps1 deploy\history\ 2>nul
move deploy\server-deploy-final-v4.2.1.2.ps1 deploy\history\ 2>nul
move deploy\server-deploy-final-v4.2.1.3.ps1 deploy\history\ 2>nul
move deploy\setup.bat deploy\history\ 2>nul
move deploy\setup.sh deploy\history\ 2>nul
move deploy\simple-deployment.sh deploy\history\ 2>nul
move deploy\simple-setup.html deploy\history\ 2>nul
move deploy\TROUBLESHOOTING_BAOTA.md deploy\history\ 2>nul
move deploy\TROUBLESHOOTING.md deploy\history\ 2>nul
move deploy\v4.2.1-部署检查清单.md deploy\history\ 2>nul
move deploy\verify-deployment.sh deploy\history\ 2>nul
move deploy\verify-sync-fix.sh deploy\history\ 2>nul

echo.
echo 保留以下核心文件和目录:
echo - HTML文件: index.html, edit-tasks.html, focus-challenge.html, statistics.html, today-tasks.html, sync-test.html
echo - 配置文件: manifest.json, icon-192.svg, .gitignore, package.json, vercel.json
echo - 文档文件: README.md
echo - 核心目录: css/, js/, api/, data/, deploy/ (已整理)
echo - 系统目录: .git/, .github/, .vercel/, .codebuddy/
echo.

echo 整理完成！

pause