@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo 任务管理系统 v4.4.4 部署脚本
echo ========================================
echo.

:: 设置版本信息
set VERSION=4.4.4
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%
set TIMESTAMP=%TIMESTAMP: =0%

echo [%time%] 开始创建部署包...
echo 版本: %VERSION%
echo 时间戳: %TIMESTAMP%

:: 创建临时目录
set TEMP_DIR=temp_v%VERSION%
if exist %TEMP_DIR% rmdir /s /q %TEMP_DIR%
mkdir %TEMP_DIR%

echo [%time%] 复制核心文件...
copy ..\index.html %TEMP_DIR%\
copy ..\favicon.ico %TEMP_DIR%\ 2>nul
copy ..\package.json %TEMP_DIR%\ 2>nul
copy ..\README.md %TEMP_DIR%\

echo [%time%] 复制CSS文件...
mkdir %TEMP_DIR%\css
xcopy ..\css\*.css %TEMP_DIR%\css\ /s

echo [%time%] 复制JavaScript文件...
mkdir %TEMP_DIR%\js
xcopy ..\js\*.js %TEMP_DIR%\js\ /s

echo [%time%] 复制API文件...
mkdir %TEMP_DIR%\api
xcopy ..\api\*.php %TEMP_DIR%\api\ /s

echo [%time%] 创建数据目录...
mkdir %TEMP_DIR%\data

echo [%time%] 创建版本信息...
echo 任务管理系统 v%VERSION% > %TEMP_DIR%\VERSION.txt
echo 构建时间: %date% %time% >> %TEMP_DIR%\VERSION.txt
echo 构建环境: Windows >> %TEMP_DIR%\VERSION.txt
echo. >> %TEMP_DIR%\VERSION.txt
echo 更新内容: >> %TEMP_DIR%\VERSION.txt
echo - 完全恢复原始页面显示方式 >> %TEMP_DIR%\VERSION.txt
echo - 修复任务卡片结构，显示完整的任务信息 >> %TEMP_DIR%\VERSION.txt
echo - 修复底部导航为水平排列 >> %TEMP_DIR%\VERSION.txt
echo - 恢复原始任务列表和计时功能 >> %TEMP_DIR%\VERSION.txt
echo - 完善静态版本的所有功能 >> %TEMP_DIR%\VERSION.txt

echo [%time%] 创建部署包...
set DEPLOY_FILE=task-manager-v%VERSION%-%TIMESTAMP%.zip
powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%DEPLOY_FILE%' -Force"

echo [%time%] 清理临时文件...
rmdir /s /q %TEMP_DIR%

echo.
echo ========================================
echo 部署包创建完成！
echo 文件名: %DEPLOY_FILE%
echo 日志文件: deploy-log-%TIMESTAMP%.txt
echo ========================================

:: 显示文件大小
for %%A in (%DEPLOY_FILE%) do echo 文件大小: %%~zA 字节

:: 创建部署日志
echo 任务管理系统 v%VERSION% 部署日志 > deploy-log-%TIMESTAMP%.txt
echo 创建时间: %date% %time% >> deploy-log-%TIMESTAMP%.txt
echo 部署包: %DEPLOY_FILE% >> deploy-log-%TIMESTAMP%.txt
echo. >> deploy-log-%TIMESTAMP%.txt
echo 版本更新内容: >> deploy-log-%TIMESTAMP%.txt
echo - 完全恢复原始页面显示方式 >> deploy-log-%TIMESTAMP%.txt
echo - 修复任务卡片结构，显示完整的任务信息 >> deploy-log-%TIMESTAMP%.txt
echo - 修复底部导航为水平排列 >> deploy-log-%TIMESTAMP%.txt
echo - 恢复原始任务列表和计时功能 >> deploy-log-%TIMESTAMP%.txt
echo - 完善静态版本的所有功能 >> deploy-log-%TIMESTAMP%.txt
echo. >> deploy-log-%TIMESTAMP%.txt
echo 技术改进: >> deploy-log-%TIMESTAMP%.txt
echo - 使用正确的CSS类名(.footer而不是.bottom-nav) >> deploy-log-%TIMESTAMP%.txt
echo - 恢复完整的任务卡片HTML结构 >> deploy-log-%TIMESTAMP%.txt
echo - 修复任务图标和按钮显示 >> deploy-log-%TIMESTAMP%.txt
echo - 完善计时功能和数据持久化 >> deploy-log-%TIMESTAMP%.txt
echo - 优化用户体验和交互反馈 >> deploy-log-%TIMESTAMP%.txt

echo [%time%] 部署脚本执行完成
pause