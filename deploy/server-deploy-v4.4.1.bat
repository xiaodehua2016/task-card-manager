@echo off
chcp 65001 >nul
echo ========================================
echo 任务管理系统 v4.4.1 服务器部署脚本
echo ========================================
echo.

set VERSION=4.4.1
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_FILE=server-deploy-log-%TIMESTAMP%.txt
set SERVER_IP=115.159.5.111
set SERVER_USER=root
set SERVER_PATH=/www/wwwroot/task-manager
set ZIP_FILE=task-manager-v%VERSION%-%TIMESTAMP%.zip

echo [%time%] 开始服务器部署流程... | tee %LOG_FILE%
echo 版本: %VERSION% | tee -a %LOG_FILE%
echo 服务器: %SERVER_IP% | tee -a %LOG_FILE%
echo 部署路径: %SERVER_PATH% | tee -a %LOG_FILE%
echo.

:: 检查部署包是否存在
if not exist "%ZIP_FILE%" (
    echo [%time%] 错误: 找不到部署包 %ZIP_FILE% | tee -a %LOG_FILE%
    echo 请先运行 deploy-v%VERSION%.bat 创建部署包
    pause
    exit /b 1
)

:: 上传部署包到服务器
echo [%time%] 上传部署包到服务器... | tee -a %LOG_FILE%
scp "%ZIP_FILE%" %SERVER_USER%@%SERVER_IP%:/tmp/ | tee -a %LOG_FILE%

if %errorlevel% neq 0 (
    echo [%time%] 错误: 上传失败 | tee -a %LOG_FILE%
    pause
    exit /b 1
)

:: 创建服务器部署脚本
echo [%time%] 创建服务器端部署脚本... | tee -a %LOG_FILE%
echo #!/bin/bash > server_deploy_script.sh
echo echo "========================================" >> server_deploy_script.sh
echo echo "服务器端部署开始 - v%VERSION%" >> server_deploy_script.sh
echo echo "========================================" >> server_deploy_script.sh
echo echo >> server_deploy_script.sh
echo # 备份现有文件 >> server_deploy_script.sh
echo if [ -d "%SERVER_PATH%" ]; then >> server_deploy_script.sh
echo   echo "备份现有文件..." >> server_deploy_script.sh
echo   cp -r %SERVER_PATH% %SERVER_PATH%_backup_$(date +%%Y%%m%%d_%%H%%M%%S) >> server_deploy_script.sh
echo fi >> server_deploy_script.sh
echo echo >> server_deploy_script.sh
echo # 创建部署目录 >> server_deploy_script.sh
echo echo "创建部署目录..." >> server_deploy_script.sh
echo mkdir -p %SERVER_PATH% >> server_deploy_script.sh
echo echo >> server_deploy_script.sh
echo # 解压部署包 >> server_deploy_script.sh
echo echo "解压部署包..." >> server_deploy_script.sh
echo cd %SERVER_PATH% >> server_deploy_script.sh
echo unzip -o /tmp/%ZIP_FILE% >> server_deploy_script.sh
echo echo >> server_deploy_script.sh
echo # 设置文件权限 >> server_deploy_script.sh
echo echo "设置文件权限..." >> server_deploy_script.sh
echo chown -R www:www %SERVER_PATH% >> server_deploy_script.sh
echo chmod -R 755 %SERVER_PATH% >> server_deploy_script.sh
echo chmod -R 777 %SERVER_PATH%/data >> server_deploy_script.sh
echo chmod -R 777 %SERVER_PATH%/logs >> server_deploy_script.sh
echo echo >> server_deploy_script.sh
echo # 重启Web服务 >> server_deploy_script.sh
echo echo "重启Web服务..." >> server_deploy_script.sh
echo systemctl reload nginx >> server_deploy_script.sh
echo echo >> server_deploy_script.sh
echo # 清理临时文件 >> server_deploy_script.sh
echo echo "清理临时文件..." >> server_deploy_script.sh
echo rm -f /tmp/%ZIP_FILE% >> server_deploy_script.sh
echo echo >> server_deploy_script.sh
echo echo "========================================" >> server_deploy_script.sh
echo echo "部署完成！版本: v%VERSION%" >> server_deploy_script.sh
echo echo "部署路径: %SERVER_PATH%" >> server_deploy_script.sh
echo echo "========================================" >> server_deploy_script.sh

:: 上传并执行部署脚本
echo [%time%] 上传部署脚本... | tee -a %LOG_FILE%
scp server_deploy_script.sh %SERVER_USER%@%SERVER_IP%:/tmp/ | tee -a %LOG_FILE%

echo [%time%] 执行服务器端部署... | tee -a %LOG_FILE%
ssh %SERVER_USER%@%SERVER_IP% "chmod +x /tmp/server_deploy_script.sh && /tmp/server_deploy_script.sh" | tee -a %LOG_FILE%

if %errorlevel% neq 0 (
    echo [%time%] 警告: 服务器端部署可能出现问题 | tee -a %LOG_FILE%
) else (
    echo [%time%] 服务器端部署成功 | tee -a %LOG_FILE%
)

:: 验证部署结果
echo [%time%] 验证部署结果... | tee -a %LOG_FILE%
ssh %SERVER_USER%@%SERVER_IP% "ls -la %SERVER_PATH%/ && cat %SERVER_PATH%/VERSION.txt" | tee -a %LOG_FILE%

:: 清理本地临时文件
echo [%time%] 清理本地临时文件... | tee -a %LOG_FILE%
del server_deploy_script.sh

echo.
echo ========================================
echo 服务器部署完成！
echo 版本: v%VERSION%
echo 服务器: %SERVER_IP%
echo 访问地址: http://%SERVER_IP%/task-manager/
echo 日志文件: %LOG_FILE%
echo ========================================
echo.

echo [%time%] 服务器部署脚本执行完成 | tee -a %LOG_FILE%
pause