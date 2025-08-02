@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2 快速部署

echo.
echo ========================================
echo    小久任务管理系统 v4.2.2 快速部署
echo ========================================
echo.

REM 创建部署包
echo 📦 正在创建部署包...

if exist task-manager-v4.2.2-complete.zip del /f task-manager-v4.2.2-complete.zip

REM 创建临时目录
if exist temp_deploy rmdir /s /q temp_deploy
mkdir temp_deploy

REM 复制核心文件
echo 📁 复制核心文件...
copy index.html temp_deploy\ 2>nul
copy edit-tasks.html temp_deploy\ 2>nul
copy focus-challenge.html temp_deploy\ 2>nul
copy statistics.html temp_deploy\ 2>nul
copy today-tasks.html temp_deploy\ 2>nul
copy sync-test.html temp_deploy\ 2>nul
copy manifest.json temp_deploy\ 2>nul
copy icon-192.svg temp_deploy\ 2>nul
copy favicon.ico temp_deploy\ 2>nul

REM 复制CSS目录
if exist css (
    mkdir temp_deploy\css
    xcopy css\*.css temp_deploy\css\ /Y /Q
    echo ✅ CSS文件已复制
)

REM 复制JS目录
if exist js (
    mkdir temp_deploy\js
    xcopy js\*.js temp_deploy\js\ /Y /Q
    echo ✅ JS文件已复制
)

REM 复制API目录
if exist api (
    mkdir temp_deploy\api
    xcopy api\*.php temp_deploy\api\ /Y /Q
    xcopy api\*.js temp_deploy\api\ /Y /Q
    echo ✅ API文件已复制
)

REM 复制数据目录
if exist data (
    mkdir temp_deploy\data
    copy data\shared-tasks.json temp_deploy\data\ 2>nul
    copy data\README.md temp_deploy\data\ 2>nul
    echo ✅ 数据文件已复制
)

REM 创建ZIP文件
powershell -Command "Compress-Archive -Path temp_deploy\* -DestinationPath task-manager-v4.2.2-complete.zip -Force"

REM 清理临时目录
rmdir /s /q temp_deploy

echo ✅ 部署包创建完成: task-manager-v4.2.2-complete.zip

echo.
echo 🚀 部署选项:
echo.
echo 1. 手动部署到服务器 (推荐)
echo 2. 退出
echo.

set /p choice="请选择 (1-2): "

if "%choice%"=="1" goto manual_deploy
goto end

:manual_deploy
echo.
echo 🔧 手动部署指南:
echo.
echo 📋 部署步骤:
echo 1. 上传文件:
echo    - 将 task-manager-v4.2.2-complete.zip 上传到服务器
echo    - 可使用宝塔面板文件管理器或FTP工具
echo.
echo 2. 服务器操作 (通过宝塔面板终端或SSH):
echo    cd /www/wwwroot/
echo    unzip -o task-manager-v4.2.2-complete.zip -d task-manager/
echo    chown -R www:www task-manager/
echo    chmod -R 755 task-manager/
echo.
echo 3. 验证部署:
echo    访问: http://115.159.5.111/
echo    测试: http://115.159.5.111/sync-test.html
echo.
echo 💡 宝塔面板操作:
echo    - 登录: http://115.159.5.111:8888
echo    - 文件管理 → 上传 task-manager-v4.2.2-complete.zip
echo    - 解压到 /www/wwwroot/task-manager/
echo    - 设置权限: 所有者 www, 权限 755
echo.

:end
echo.
echo 🎉 操作完成！
pause