@echo off
chcp 65001 >nul
echo ========================================
echo 任务管理系统 v4.4.1 部署脚本
echo ========================================
echo.

set VERSION=4.4.1
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set DEPLOY_DIR=task-manager-v%VERSION%
set ZIP_FILE=task-manager-v%VERSION%-%TIMESTAMP%.zip
set LOG_FILE=deploy-log-%TIMESTAMP%.txt

echo [%time%] 开始创建部署包... | tee %LOG_FILE%
echo 版本: %VERSION% | tee -a %LOG_FILE%
echo 时间戳: %TIMESTAMP% | tee -a %LOG_FILE%
echo.

:: 创建临时部署目录
if exist %DEPLOY_DIR% (
    echo [%time%] 清理旧的部署目录... | tee -a %LOG_FILE%
    rmdir /s /q %DEPLOY_DIR%
)
mkdir %DEPLOY_DIR%

:: 复制核心文件
echo [%time%] 复制核心文件... | tee -a %LOG_FILE%
copy ..\index.html %DEPLOY_DIR%\ | tee -a %LOG_FILE%
copy ..\manifest.json %DEPLOY_DIR%\ | tee -a %LOG_FILE%
copy ..\edit-tasks.html %DEPLOY_DIR%\ | tee -a %LOG_FILE%
copy ..\focus-challenge.html %DEPLOY_DIR%\ | tee -a %LOG_FILE%
copy ..\statistics.html %DEPLOY_DIR%\ | tee -a %LOG_FILE%
copy ..\today-tasks.html %DEPLOY_DIR%\ | tee -a %LOG_FILE%
copy ..\vercel.json %DEPLOY_DIR%\ | tee -a %LOG_FILE%
copy ..\icon-192.svg %DEPLOY_DIR%\ | tee -a %LOG_FILE%

:: 复制CSS文件
echo [%time%] 复制CSS文件... | tee -a %LOG_FILE%
if not exist %DEPLOY_DIR%\css mkdir %DEPLOY_DIR%\css
copy ..\css\*.css %DEPLOY_DIR%\css\ | tee -a %LOG_FILE%

:: 复制JavaScript文件（只复制必要的）
echo [%time%] 复制JavaScript文件... | tee -a %LOG_FILE%
if not exist %DEPLOY_DIR%\js mkdir %DEPLOY_DIR%\js
copy ..\js\main.js %DEPLOY_DIR%\js\ | tee -a %LOG_FILE%
copy ..\js\edit.js %DEPLOY_DIR%\js\ | tee -a %LOG_FILE%
copy ..\js\focus.js %DEPLOY_DIR%\js\ | tee -a %LOG_FILE%
copy ..\js\statistics.js %DEPLOY_DIR%\js\ | tee -a %LOG_FILE%
copy ..\js\today-tasks.js %DEPLOY_DIR%\js\ | tee -a %LOG_FILE%

:: 复制API文件
echo [%time%] 复制API文件... | tee -a %LOG_FILE%
if not exist %DEPLOY_DIR%\api mkdir %DEPLOY_DIR%\api
copy ..\api\serial-update.php %DEPLOY_DIR%\api\ | tee -a %LOG_FILE%

:: 创建数据目录
echo [%time%] 创建数据目录... | tee -a %LOG_FILE%
if not exist %DEPLOY_DIR%\data mkdir %DEPLOY_DIR%\data
echo. > %DEPLOY_DIR%\data\.gitkeep

:: 创建日志目录
if not exist %DEPLOY_DIR%\logs mkdir %DEPLOY_DIR%\logs
echo. > %DEPLOY_DIR%\logs\.gitkeep

:: 创建版本信息文件
echo [%time%] 创建版本信息... | tee -a %LOG_FILE%
echo 任务管理系统 v%VERSION% > %DEPLOY_DIR%\VERSION.txt
echo 构建时间: %TIMESTAMP% >> %DEPLOY_DIR%\VERSION.txt
echo 构建类型: 生产版本 >> %DEPLOY_DIR%\VERSION.txt

:: 创建ZIP压缩包
echo [%time%] 创建压缩包... | tee -a %LOG_FILE%
if exist "%ZIP_FILE%" del "%ZIP_FILE%"
powershell -command "Compress-Archive -Path '%DEPLOY_DIR%\*' -DestinationPath '%ZIP_FILE%'" | tee -a %LOG_FILE%

:: 清理临时目录
echo [%time%] 清理临时文件... | tee -a %LOG_FILE%
rmdir /s /q %DEPLOY_DIR%

:: 显示结果
echo.
echo ========================================
echo 部署包创建完成！
echo 文件名: %ZIP_FILE%
echo 日志文件: %LOG_FILE%
echo ========================================
echo.

:: 显示文件大小
for %%A in ("%ZIP_FILE%") do echo 文件大小: %%~zA 字节

echo [%time%] 部署脚本执行完成 | tee -a %LOG_FILE%
pause