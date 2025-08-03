@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ====================================================
:: 任务管理系统 v4.3.6.1 部署脚本
:: 功能：创建生产环境部署包，修复任务显示和按钮响应问题
:: ====================================================

set "VERSION=4.3.6.1"
set "DEPLOY_PACKAGE=task-manager-v%VERSION%.zip"
set "TEMP_DIR=temp_deploy_v%VERSION%"
set "LOG_FILE=deploy\deploy-v%VERSION%.log"

:: 创建日志目录
if not exist "deploy" mkdir "deploy"

:: 开始记录日志
echo [%date% %time%] 开始创建 v%VERSION% 部署包 > "%LOG_FILE%"

cls
echo.
echo =======================================
echo   任务管理系统 v%VERSION% 部署脚本
echo =======================================
echo.
echo 修复内容：
echo ✅ 修复今日任务未显示问题
echo ✅ 修复底部按钮无法点击问题
echo ✅ 优化数据初始化逻辑
echo ✅ 增强错误处理机制
echo.

echo [1/4] 正在清理旧文件...
echo [%date% %time%] 清理旧文件 >> "%LOG_FILE%"

:: 删除旧的部署包和临时目录
if exist "%DEPLOY_PACKAGE%" (
    del "%DEPLOY_PACKAGE%"
    echo [%date% %time%] 删除旧部署包: %DEPLOY_PACKAGE% >> "%LOG_FILE%"
)
if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%"
    echo [%date% %time%] 删除临时目录: %TEMP_DIR% >> "%LOG_FILE%"
)
mkdir "%TEMP_DIR%"

echo [2/4] 正在复制核心文件...
echo [%date% %time%] 开始复制核心文件 >> "%LOG_FILE%"

:: 复制主要文件
copy "index.html" "%TEMP_DIR%\" > nul
copy "manifest.json" "%TEMP_DIR%\" > nul
copy "favicon.ico" "%TEMP_DIR%\" > nul 2>nul
copy "icon-192.svg" "%TEMP_DIR%\" > nul 2>nul

:: 复制CSS文件
mkdir "%TEMP_DIR%\css"
copy "css\*.css" "%TEMP_DIR%\css\" > nul
echo [%date% %time%] CSS文件已复制 >> "%LOG_FILE%"

:: 复制JS文件 - v4.3.6.1核心文件
mkdir "%TEMP_DIR%\js"
copy "js\main.js" "%TEMP_DIR%\js\" > nul
copy "js\sync-logger.js" "%TEMP_DIR%\js\" > nul
copy "js\enhanced-sync.js" "%TEMP_DIR%\js\" > nul
copy "js\simple-storage.js" "%TEMP_DIR%\js\" > nul 2>nul
copy "js\edit.js" "%TEMP_DIR%\js\" > nul 2>nul
copy "js\focus.js" "%TEMP_DIR%\js\" > nul 2>nul
copy "js\statistics.js" "%TEMP_DIR%\js\" > nul 2>nul
copy "js\today-tasks.js" "%TEMP_DIR%\js\" > nul 2>nul
echo [%date% %time%] JS文件已复制 >> "%LOG_FILE%"

:: 复制API文件
mkdir "%TEMP_DIR%\api"
copy "api\data-sync.php" "%TEMP_DIR%\api\" > nul
echo [%date% %time%] API文件已复制 >> "%LOG_FILE%"

:: 创建数据目录
mkdir "%TEMP_DIR%\data"
echo. > "%TEMP_DIR%\data\.gitkeep"

:: 创建日志目录
mkdir "%TEMP_DIR%\logs"
echo. > "%TEMP_DIR%\logs\.gitkeep"

:: 创建.htaccess文件
echo ^<IfModule mod_headers.c^> > "%TEMP_DIR%\api\.htaccess"
echo Header set Access-Control-Allow-Origin "*" >> "%TEMP_DIR%\api\.htaccess"
echo Header set Access-Control-Allow-Methods "GET, POST, OPTIONS" >> "%TEMP_DIR%\api\.htaccess"
echo Header set Access-Control-Allow-Headers "Content-Type" >> "%TEMP_DIR%\api\.htaccess"
echo ^</IfModule^> >> "%TEMP_DIR%\api\.htaccess"

:: 创建部署信息文件
echo 任务管理系统 v%VERSION% 部署包 > "%TEMP_DIR%\DEPLOY_INFO.txt"
echo. >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo 修复内容: >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo - 修复今日任务未显示问题 >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo - 修复底部按钮无法点击问题 >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo - 优化数据初始化逻辑，确保默认任务正确显示 >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo - 增强错误处理机制，提高系统稳定性 >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo - 完善全局函数绑定，确保所有按钮正常响应 >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo. >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo 部署时间: %date% %time% >> "%TEMP_DIR%\DEPLOY_INFO.txt"
echo 部署版本: v%VERSION% >> "%TEMP_DIR%\DEPLOY_INFO.txt"

echo [3/4] 正在创建ZIP部署包...
echo [%date% %time%] 开始创建ZIP包 >> "%LOG_FILE%"

:: 创建ZIP包
powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%DEPLOY_PACKAGE%' -Force"

:: 清理临时目录
rmdir /s /q "%TEMP_DIR%"

:: 获取文件大小
for %%I in ("%DEPLOY_PACKAGE%") do set "FILESIZE=%%~zI"
set /a FILESIZE_KB=!FILESIZE!/1024

echo [%date% %time%] ZIP包创建完成，大小: !FILESIZE_KB! KB >> "%LOG_FILE%"

echo [4/4] 部署包创建完成！
echo.
echo ✅ 部署包: %DEPLOY_PACKAGE%
echo ✅ 大小: !FILESIZE_KB! KB
echo ✅ 日志: %LOG_FILE%
echo.

echo 🚀 部署到115服务器的命令：
echo.
echo 1. 上传文件：
echo    scp "%DEPLOY_PACKAGE%" root@115.159.5.111:/www/wwwroot/
echo.
echo 2. 服务器部署：
echo    ssh root@115.159.5.111 "cd /www/wwwroot && unzip -o %DEPLOY_PACKAGE% -d task-manager/ && chown -R www:www task-manager/ && chmod -R 755 task-manager/ && systemctl restart nginx"
echo.
echo 3. 验证部署：
echo    访问: http://115.159.5.111/
echo    检查版本: v%VERSION%
echo    测试功能: 任务显示和按钮点击
echo.

echo 🧪 测试清单：
echo □ 页面加载后显示8个默认任务
echo □ 底部5个按钮都能正常点击
echo □ 任务卡片上的完成按钮能正常工作
echo □ 进度条显示正确
echo □ 完成任务后显示庆祝动画
echo.

echo [%date% %time%] 部署脚本执行完成 >> "%LOG_FILE%"

pause