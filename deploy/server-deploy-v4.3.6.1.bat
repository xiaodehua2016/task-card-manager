@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ====================================================
:: 服务器部署脚本 v4.3.6.1
:: 功能：生成部署包并提供115服务器部署命令
:: ====================================================

set "VERSION=4.3.6.1"
set "LOG_FILE=deploy\server-deploy-v%VERSION%.log"
set "DEPLOY_PACKAGE=task-manager-v%VERSION%.zip"

:: 创建日志目录
if not exist "deploy" mkdir "deploy"

:: 开始记录日志
echo [%date% %time%] 开始服务器部署 v%VERSION% > "%LOG_FILE%"

cls
echo.
echo =======================================
echo   服务器部署脚本 v%VERSION%
echo =======================================
echo.
echo 修复内容：
echo ✅ 修复今日任务未显示问题
echo ✅ 修复底部按钮无法点击问题
echo ✅ 优化数据初始化逻辑
echo ✅ 增强错误处理机制
echo.

echo [1/4] 清理旧的部署包...
echo [%date% %time%] 清理旧部署包 >> "%LOG_FILE%"

if exist "%DEPLOY_PACKAGE%" (
    del "%DEPLOY_PACKAGE%"
    echo ✅ 已删除旧的部署包
    echo [%date% %time%] 删除旧部署包成功 >> "%LOG_FILE%"
)

echo.
echo [2/4] 创建部署包...
echo [%date% %time%] 开始创建部署包 >> "%LOG_FILE%"

:: 检查PowerShell是否可用
powershell -Command "Get-Command Compress-Archive" >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：PowerShell Compress-Archive 不可用
    echo [%date% %time%] 错误：PowerShell不可用 >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: 创建部署包
powershell -Command "Compress-Archive -Path 'index.html','manifest.json','css','js','api','data','images' -DestinationPath '%DEPLOY_PACKAGE%' -Force"
if errorlevel 1 (
    echo ❌ 错误：创建部署包失败
    echo [%date% %time%] 错误：创建部署包失败 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo ✅ 部署包创建成功：%DEPLOY_PACKAGE%
echo [%date% %time%] 部署包创建成功 >> "%LOG_FILE%"

echo.
echo [3/4] 生成部署信息文件...
echo [%date% %time%] 生成部署信息 >> "%LOG_FILE%"

:: 创建部署信息文件
echo 任务管理系统 v%VERSION% 部署信息 > DEPLOY_INFO_v%VERSION%.txt
echo ================================== >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt
echo 版本：v%VERSION% >> DEPLOY_INFO_v%VERSION%.txt
echo 构建时间：%date% %time% >> DEPLOY_INFO_v%VERSION%.txt
echo 部署包：%DEPLOY_PACKAGE% >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt
echo 修复内容： >> DEPLOY_INFO_v%VERSION%.txt
echo - 修复今日任务未显示问题 >> DEPLOY_INFO_v%VERSION%.txt
echo - 修复底部按钮无法点击问题 >> DEPLOY_INFO_v%VERSION%.txt
echo - 优化数据初始化逻辑 >> DEPLOY_INFO_v%VERSION%.txt
echo - 增强错误处理机制 >> DEPLOY_INFO_v%VERSION%.txt
echo - 完善TaskManager类 >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt
echo 部署目标：115.159.5.111 >> DEPLOY_INFO_v%VERSION%.txt
echo 部署路径：/www/wwwroot/task-manager/ >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt

echo ✅ 部署信息文件创建成功
echo [%date% %time%] 部署信息文件创建成功 >> "%LOG_FILE%"

echo.
echo [4/4] 生成115服务器部署命令...
echo [%date% %time%] 生成服务器部署命令 >> "%LOG_FILE%"

:: 创建服务器部署命令文件
echo :: 115服务器部署命令 v%VERSION% > server_commands_v%VERSION%.bat
echo :: 请复制以下命令到本地终端执行 >> server_commands_v%VERSION%.bat
echo. >> server_commands_v%VERSION%.bat
echo :: 1. 上传部署包到服务器 >> server_commands_v%VERSION%.bat
echo scp %DEPLOY_PACKAGE% root@115.159.5.111:/www/wwwroot/ >> server_commands_v%VERSION%.bat
echo. >> server_commands_v%VERSION%.bat
echo :: 2. SSH登录服务器 >> server_commands_v%VERSION%.bat
echo ssh root@115.159.5.111 >> server_commands_v%VERSION%.bat
echo. >> server_commands_v%VERSION%.bat
echo :: 3. 在服务器上执行以下命令： >> server_commands_v%VERSION%.bat
echo :: cd /www/wwwroot/ >> server_commands_v%VERSION%.bat
echo :: unzip -o %DEPLOY_PACKAGE% -d task-manager/ >> server_commands_v%VERSION%.bat
echo :: chown -R www:www task-manager/ >> server_commands_v%VERSION%.bat
echo :: chmod -R 755 task-manager/ >> server_commands_v%VERSION%.bat
echo :: chmod -R 644 task-manager/data/ >> server_commands_v%VERSION%.bat
echo :: systemctl restart nginx >> server_commands_v%VERSION%.bat
echo :: systemctl restart php-fpm >> server_commands_v%VERSION%.bat
echo :: echo "部署完成！访问: http://115.159.5.111/" >> server_commands_v%VERSION%.bat

echo ✅ 服务器部署命令文件创建成功
echo [%date% %time%] 服务器部署命令创建成功 >> "%LOG_FILE%"

echo.
echo ✅ 服务器部署准备完成！
echo [%date% %time%] 服务器部署准备完成 >> "%LOG_FILE%"

echo.
echo 📦 生成的文件：
echo ✅ %DEPLOY_PACKAGE% - 部署包
echo ✅ DEPLOY_INFO_v%VERSION%.txt - 部署信息
echo ✅ server_commands_v%VERSION%.bat - 服务器命令
echo ✅ %LOG_FILE% - 操作日志
echo.

echo 🚀 115服务器部署步骤：
echo.
echo 1. 上传部署包：
echo    scp %DEPLOY_PACKAGE% root@115.159.5.111:/www/wwwroot/
echo.
echo 2. SSH登录服务器：
echo    ssh root@115.159.5.111
echo.
echo 3. 在服务器执行：
echo    cd /www/wwwroot/
echo    unzip -o %DEPLOY_PACKAGE% -d task-manager/
echo    chown -R www:www task-manager/
echo    chmod -R 755 task-manager/
echo    chmod -R 644 task-manager/data/
echo    systemctl restart nginx
echo    systemctl restart php-fpm
echo.
echo 4. 验证部署：
echo    访问: http://115.159.5.111/
echo    测试: 任务显示和按钮点击功能
echo.

echo 📝 验证清单：
echo □ 主页正常显示8个默认任务
echo □ 底部5个按钮都能正常点击
echo □ 任务卡片上的按钮能正常响应
echo □ 清除缓存后仍能正常显示任务
echo □ Chrome和Edge浏览器都能正常使用
echo □ 手机端触摸操作正常
echo.

echo 💡 如果遇到问题：
echo 1. 检查服务器日志：tail -f /var/log/nginx/error.log
echo 2. 检查PHP错误：tail -f /var/log/php-fpm/error.log
echo 3. 验证文件权限：ls -la /www/wwwroot/task-manager/
echo 4. 测试API接口：curl http://115.159.5.111/api/data-sync.php
echo.

pause