@echo off
chcp 65001 > nul
setlocal

:: ==================================================
:: 发布到 115 服务器脚本 (v5.0.0)
:: 功能: 打包生产文件并提供部署命令
:: ==================================================

set "VERSION=5.0.0"
set "DEPLOY_PACKAGE=task-manager-v!VERSION!.zip"
set "TEMP_DIR=temp_deploy_v!VERSION!"
set "SERVER_USER=root"
set "SERVER_IP=115.159.5.111"
set "SERVER_PATH=/www/wwwroot/"

cls
echo.
echo =======================================
echo   发布到 115 服务器脚本
echo =======================================
echo.

echo [1/3] 正在创建生产环境部署包...

:: 删除旧的部署包和临时目录
if exist "%DEPLOY_PACKAGE%" del "%DEPLOY_PACKAGE%"
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

:: 复制生产文件
copy "..\index.html" "%TEMP_DIR%\" > nul
copy "..\manifest.json" "%TEMP_DIR%\" > nul
copy "..\favicon.ico" "%TEMP_DIR%\" > nul 2>nul
mkdir "%TEMP_DIR%\css"
copy "..\css\*.css" "%TEMP_DIR%\css\" > nul
mkdir "%TEMP_DIR%\js"
copy "..\js\main.js" "%TEMP_DIR%\js\" > nul
copy "..\js\sync.js" "%TEMP_DIR%\js\" > nul
mkdir "%TEMP_DIR%\api"
copy "..\api\*.php" "%TEMP_DIR%\api\" > nul
mkdir "%TEMP_DIR%\data"
echo. > "%TEMP_DIR%\data\.gitkeep"

echo   - 生产文件已复制。

:: 创建 ZIP 包
powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%DEPLOY_PACKAGE%' -Force" > nul

:: 清理临时目录
rmdir /s /q "%TEMP_DIR%"

echo   - 部署包 `%DEPLOY_PACKAGE%` 创建成功。
echo.

echo [2/3] 请手动执行以下命令进行上传和部署。
echo.
echo =================================================================
echo   请复制并执行以下命令
echo =================================================================
echo.
echo (1) 上传部署包到服务器 (在您本地电脑的终端中运行):
echo.
echo   scp "%~dp0%DEPLOY_PACKAGE%" %SERVER_USER%@%SERVER_IP%:%SERVER_PATH%
echo.
echo -----------------------------------------------------------------
echo.
echo (2) 登录服务器并解压部署 (在您本地电脑的终端中运行):
echo.
echo   ssh %SERVER_USER%@%SERVER_IP% "cd %SERVER_PATH% && unzip -o %DEPLOY_PACKAGE% -d task-manager/ && chown -R www:www task-manager/ && chmod -R 755 task-manager/ && systemctl restart nginx && echo '-----> 115 服务器部署成功! <-----'"
echo.
echo =================================================================
echo.

echo [3/3] 部署流程已生成。
echo.
echo   请按顺序执行上述两个步骤中的命令。
echo.
pause