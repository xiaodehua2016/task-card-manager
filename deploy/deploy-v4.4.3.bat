@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo 任务管理系统 v4.4.3 部署脚本
echo ========================================
echo.

:: 设置版本和时间戳
set VERSION=4.4.3
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
    set DATE=%%d%%b%%c
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set TIME=%%a%%b
)
set TIMESTAMP=%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%-%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%

echo [%time%] 开始创建部署包...
echo 版本: %VERSION%
echo 时间戳: %TIMESTAMP%
echo.

:: 创建临时目录
set TEMP_DIR=temp-deploy-%TIMESTAMP%
set DEPLOY_NAME=task-manager-v%VERSION%-%TIMESTAMP%

if exist %TEMP_DIR% rmdir /s /q %TEMP_DIR%
mkdir %TEMP_DIR%

echo [%time%] 复制核心文件...
copy ..\index.html %TEMP_DIR%\
copy ..\index-static.html %TEMP_DIR%\
copy ..\test-github-pages.html %TEMP_DIR%\
copy ..\test-debug.html %TEMP_DIR%\
copy ..\favicon.ico %TEMP_DIR%\

echo [%time%] 复制CSS文件...
mkdir %TEMP_DIR%\css
copy ..\css\*.css %TEMP_DIR%\css\

echo [%time%] 复制JavaScript文件...
mkdir %TEMP_DIR%\js
copy ..\js\*.js %TEMP_DIR%\js\

echo [%time%] 复制API文件...
mkdir %TEMP_DIR%\api
copy ..\api\*.php %TEMP_DIR%\api\

echo [%time%] 创建数据目录...
mkdir %TEMP_DIR%\data

echo [%time%] 创建版本信息...
echo 任务管理系统 v%VERSION% > %TEMP_DIR%\VERSION.txt
echo 构建时间: %date% %time% >> %TEMP_DIR%\VERSION.txt
echo 构建标识: %TIMESTAMP% >> %TEMP_DIR%\VERSION.txt
echo GitHub Pages静态版本支持: 是 >> %TEMP_DIR%\VERSION.txt
echo 服务器版本支持: 是 >> %TEMP_DIR%\VERSION.txt
echo 环境自动检测: 是 >> %TEMP_DIR%\VERSION.txt
echo 修复问题: HTML结构重复、任务显示、状态切换、底部导航功能 >> %TEMP_DIR%\VERSION.txt

:: 创建部署包
echo [%time%] 创建压缩包...
powershell -command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%DEPLOY_NAME%.zip' -Force"

echo [%time%] 清理临时文件...
rmdir /s /q %TEMP_DIR%

echo.
echo ========================================
echo 部署包创建完成！
echo 文件名: %DEPLOY_NAME%.zip
echo 日志文件: deploy-log-%TIMESTAMP%.txt
echo ========================================
echo.

:: 显示文件大小
for %%A in (%DEPLOY_NAME%.zip) do echo 文件大小: %%~zA 字节

echo [%time%] 部署脚本执行完成

:: 创建日志文件
echo 任务管理系统 v%VERSION% 部署日志 > deploy-log-%TIMESTAMP%.txt
echo 部署时间: %date% %time% >> deploy-log-%TIMESTAMP%.txt
echo 部署包: %DEPLOY_NAME%.zip >> deploy-log-%TIMESTAMP%.txt
echo 版本特性: >> deploy-log-%TIMESTAMP%.txt
echo - 修复HTML结构重复问题 >> deploy-log-%TIMESTAMP%.txt
echo - 修复任务显示和状态切换功能 >> deploy-log-%TIMESTAMP%.txt
echo - 修复底部导航功能完整实现 >> deploy-log-%TIMESTAMP%.txt
echo - GitHub Pages完美支持 >> deploy-log-%TIMESTAMP%.txt
echo - 环境自动检测和脚本选择 >> deploy-log-%TIMESTAMP%.txt
echo - 数据本地存储持久化 >> deploy-log-%TIMESTAMP%.txt

pause