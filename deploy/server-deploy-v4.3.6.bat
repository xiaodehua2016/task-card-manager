@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ====================================================
:: 服务器部署脚本 v4.3.6
:: 功能：部署到115服务器，支持完整日志记录
:: ====================================================

set "VERSION=4.3.6"
set "SERVER_IP=115.159.5.111"
set "SERVER_USER=root"
set "SERVER_PATH=/www/wwwroot/"
set "DEPLOY_PACKAGE=task-manager-v%VERSION%.zip"
set "LOG_FILE=deploy\server-deploy-v%VERSION%.log"

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
echo 目标服务器：%SERVER_IP%
echo 部署路径：%SERVER_PATH%task-manager/
echo 部署包：%DEPLOY_PACKAGE%
echo.

echo [1/6] 检查部署包是否存在...
echo [%date% %time%] 检查部署包 >> "%LOG_FILE%"

if not exist "%DEPLOY_PACKAGE%" (
    echo ❌ 错误：部署包 %DEPLOY_PACKAGE% 不存在
    echo [%date% %time%] 错误：部署包不存在 >> "%LOG_FILE%"
    echo.
    echo 请先运行 deploy-v%VERSION%.bat 创建部署包
    pause
    exit /b 1
)

echo ✅ 部署包存在
echo [%date% %time%] 部署包检查通过 >> "%LOG_FILE%"

echo.
echo [2/6] 测试服务器连接...
echo [%date% %time%] 测试服务器连接 >> "%LOG_FILE%"

ping -n 1 %SERVER_IP% >nul 2>&1
if errorlevel 1 (
    echo ❌ 警告：无法ping通服务器 %SERVER_IP%
    echo [%date% %time%] 警告：服务器ping失败 >> "%LOG_FILE%"
    echo 继续尝试部署...
) else (
    echo ✅ 服务器连接正常
    echo [%date% %time%] 服务器连接正常 >> "%LOG_FILE%"
)

echo.
echo [3/6] 上传部署包到服务器...
echo [%date% %time%] 开始上传部署包 >> "%LOG_FILE%"

echo 执行命令：scp "%DEPLOY_PACKAGE%" %SERVER_USER%@%SERVER_IP%:%SERVER_PATH%
echo.
echo 请在新的命令行窗口中执行以下命令：
echo.
echo scp "%DEPLOY_PACKAGE%" %SERVER_USER%@%SERVER_IP%:%SERVER_PATH%
echo.
echo 上传完成后按任意键继续...
pause >nul

echo [%date% %time%] 部署包上传完成（用户确认） >> "%LOG_FILE%"

echo.
echo [4/6] 生成服务器部署命令...
echo [%date% %time%] 生成服务器部署命令 >> "%LOG_FILE%"

set "DEPLOY_COMMANDS=cd %SERVER_PATH% && echo '开始部署v%VERSION%...' && unzip -o %DEPLOY_PACKAGE% -d task-manager/ && echo '设置文件权限...' && chown -R www:www task-manager/ && chmod -R 755 task-manager/ && chmod -R 644 task-manager/data/ && chmod -R 755 task-manager/logs/ && echo '重启服务...' && systemctl restart nginx && systemctl restart php-fpm && echo '清理部署包...' && rm -f %DEPLOY_PACKAGE% && echo '部署完成！' && ls -la task-manager/ | head -10"

echo.
echo [5/6] 在服务器上执行部署...
echo [%date% %time%] 开始服务器部署 >> "%LOG_FILE%"

echo 请在新的命令行窗口中执行以下命令：
echo.
echo ssh %SERVER_USER%@%SERVER_IP% "%DEPLOY_COMMANDS%"
echo.
echo 或者分步执行：
echo.
echo ssh %SERVER_USER%@%SERVER_IP%
echo cd %SERVER_PATH%
echo unzip -o %DEPLOY_PACKAGE% -d task-manager/
echo chown -R www:www task-manager/
echo chmod -R 755 task-manager/
echo chmod -R 644 task-manager/data/
echo chmod -R 755 task-manager/logs/
echo systemctl restart nginx
echo systemctl restart php-fpm
echo rm -f %DEPLOY_PACKAGE%
echo.
echo 部署完成后按任意键继续...
pause >nul

echo [%date% %time%] 服务器部署完成（用户确认） >> "%LOG_FILE%"

echo.
echo [6/6] 验证部署结果...
echo [%date% %time%] 开始验证部署 >> "%LOG_FILE%"

echo.
echo ✅ 部署完成！
echo [%date% %time%] 部署脚本执行完成 >> "%LOG_FILE%"

echo.
echo 📊 部署摘要：
echo ✅ 版本：v%VERSION%
echo ✅ 服务器：%SERVER_IP%
echo ✅ 部署包：%DEPLOY_PACKAGE%
echo ✅ 日志：%LOG_FILE%
echo.

echo 🌐 验证部署：
echo 1. 访问：http://%SERVER_IP%/
echo 2. 检查版本号是否为 v%VERSION%
echo 3. 测试所有功能是否正常
echo 4. 检查浏览器控制台是否有错误
echo 5. 验证数据同步功能
echo 6. 查看日志记录功能
echo.

echo 🔍 测试清单：
echo □ Chrome浏览器 - 所有按钮响应正常
echo □ Edge浏览器 - 任务显示和编辑正常
echo □ 手机端 - 触摸操作正常
echo □ 数据同步 - 跨浏览器数据一致
echo □ 日志功能 - 记录客户端请求响应
echo □ API接口 - 数据读写正常
echo.

echo 📝 如果发现问题：
echo 1. 检查浏览器控制台错误信息
echo 2. 查看服务器错误日志
echo 3. 验证文件权限设置
echo 4. 检查API接口是否正常
echo 5. 查看同步日志记录
echo.

echo 🎉 v%VERSION% 部署完成！
echo.

pause