@echo off
chcp 65001 >nul
echo ========================================
echo 任务管理系统 v4.3.6.3 服务器部署脚本
echo 功能：恢复任务计时 + 跨浏览器数据同步
echo ========================================
echo.

set VERSION=4.3.6.3
set PACKAGE_NAME=task-manager-v%VERSION%
set SERVER_IP=115.159.5.111
set SERVER_USER=root
set SERVER_PATH=/www/wwwroot/task-manager
set LOG_FILE=deploy\logs\server-deploy-v%VERSION%-%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%.log

:: 创建日志目录
if not exist "deploy\logs" mkdir "deploy\logs"

:: 开始记录日志
echo [%date% %time%] 开始服务器部署 v%VERSION% >> %LOG_FILE%

echo [1/3] 检查部署包...
if not exist "%PACKAGE_NAME%.zip" (
    echo ❌ 部署包不存在，请先运行 deploy-v%VERSION%.bat
    echo 部署包不存在 >> %LOG_FILE%
    pause
    exit /b 1
)

echo ✅ 部署包检查通过: %PACKAGE_NAME%.zip
echo 部署包检查通过 >> %LOG_FILE%

echo [2/3] 生成服务器部署命令...

:: 创建服务器部署脚本
echo #!/bin/bash > quick_deploy_v%VERSION%.sh
echo # 任务管理系统 v%VERSION% 服务器部署脚本 >> quick_deploy_v%VERSION%.sh
echo # 功能：恢复任务计时 + 跨浏览器数据同步 >> quick_deploy_v%VERSION%.sh
echo echo "开始部署任务管理系统 v%VERSION%..." >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 创建备份 >> quick_deploy_v%VERSION%.sh
echo if [ -d "%SERVER_PATH%" ]; then >> quick_deploy_v%VERSION%.sh
echo   echo "创建备份..." >> quick_deploy_v%VERSION%.sh
echo   cp -r %SERVER_PATH% %SERVER_PATH%_backup_$(date +%%Y%%m%%d_%%H%%M%%S) >> quick_deploy_v%VERSION%.sh
echo fi >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 创建目录 >> quick_deploy_v%VERSION%.sh
echo mkdir -p %SERVER_PATH% >> quick_deploy_v%VERSION%.sh
echo cd /www/wwwroot/ >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 解压部署包 >> quick_deploy_v%VERSION%.sh
echo echo "解压部署包..." >> quick_deploy_v%VERSION%.sh
echo unzip -o %PACKAGE_NAME%.zip -d task-manager/ >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 设置权限 >> quick_deploy_v%VERSION%.sh
echo echo "设置文件权限..." >> quick_deploy_v%VERSION%.sh
echo chown -R www:www task-manager/ >> quick_deploy_v%VERSION%.sh
echo chmod -R 755 task-manager/ >> quick_deploy_v%VERSION%.sh
echo chmod -R 777 task-manager/api/data/ >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 重启服务 >> quick_deploy_v%VERSION%.sh
echo echo "重启Web服务..." >> quick_deploy_v%VERSION%.sh
echo systemctl restart nginx >> quick_deploy_v%VERSION%.sh
echo systemctl restart php-fpm >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo echo "✅ 部署完成！" >> quick_deploy_v%VERSION%.sh
echo echo "🌐 访问地址: http://%SERVER_IP%/task-manager/" >> quick_deploy_v%VERSION%.sh
echo echo "📝 版本: v%VERSION%" >> quick_deploy_v%VERSION%.sh
echo echo "🎯 主要功能: 恢复任务计时 + 跨浏览器数据同步" >> quick_deploy_v%VERSION%.sh

echo [3/3] 显示部署命令...
echo.
echo ========================================
echo 🚀 服务器部署命令已生成
echo ========================================
echo.
echo 📋 请按顺序执行以下命令:
echo.
echo 1️⃣ 上传部署包到服务器:
echo scp %PACKAGE_NAME%.zip %SERVER_USER%@%SERVER_IP%:/www/wwwroot/
echo.
echo 2️⃣ 上传部署脚本:
echo scp quick_deploy_v%VERSION%.sh %SERVER_USER%@%SERVER_IP%:/www/wwwroot/
echo.
echo 3️⃣ 连接服务器并执行部署:
echo ssh %SERVER_USER%@%SERVER_IP%
echo cd /www/wwwroot/
echo chmod +x quick_deploy_v%VERSION%.sh
echo ./quick_deploy_v%VERSION%.sh
echo.
echo ========================================
echo 📝 一键复制命令 (依次执行):
echo ========================================
echo.

:: 生成一键复制的命令文件
echo scp %PACKAGE_NAME%.zip %SERVER_USER%@%SERVER_IP%:/www/wwwroot/ > server_commands_v%VERSION%.txt
echo scp quick_deploy_v%VERSION%.sh %SERVER_USER%@%SERVER_IP%:/www/wwwroot/ >> server_commands_v%VERSION%.txt
echo ssh %SERVER_USER%@%SERVER_IP% >> server_commands_v%VERSION%.txt
echo cd /www/wwwroot/ ^&^& chmod +x quick_deploy_v%VERSION%.sh ^&^& ./quick_deploy_v%VERSION%.sh >> server_commands_v%VERSION%.txt

echo 💡 命令已保存到: server_commands_v%VERSION%.txt
echo.
echo 🎯 v%VERSION% 主要功能:
echo   ✅ 恢复任务计时功能 - 每个任务显示累计用时
echo   ✅ 跨浏览器数据同步 - 基于服务器文件同步
echo   ✅ 智能数据合并 - 自动处理冲突
echo   ✅ 完整API支持 - data-sync.php提供同步服务
echo.
echo 🔧 部署后验证:
echo   1. 访问 http://%SERVER_IP%/task-manager/
echo   2. 检查任务计时功能是否正常
echo   3. 在不同浏览器中测试数据同步
echo   4. 确认API接口 /api/data-sync.php 可访问
echo.

echo [%date% %time%] 服务器部署命令生成完成 >> %LOG_FILE%

echo 📋 部署文件清单:
echo   • %PACKAGE_NAME%.zip (部署包)
echo   • quick_deploy_v%VERSION%.sh (部署脚本)
echo   • server_commands_v%VERSION%.txt (命令清单)
echo   • %LOG_FILE% (日志文件)
echo.
pause