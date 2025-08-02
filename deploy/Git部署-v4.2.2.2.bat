@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2.2 Git部署

REM 设置日志文件
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_DIR=%~dp0logs
set LOG_FILE=%LOG_DIR%\git_deploy_log_%TIMESTAMP%.txt

REM 创建日志目录
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM 开始记录日志
echo ======================================== > "%LOG_FILE%"
echo    小久任务管理系统 v4.2.2.2 Git部署    >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 部署开始时间: %date% %time% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo ========================================
echo    小久任务管理系统 v4.2.2.2 Git部署
echo ========================================
echo.
echo 📝 日志将保存到: %LOG_FILE%
echo.

REM 切换到项目根目录
cd /d %~dp0..
echo 当前工作目录: %CD% >> "%LOG_FILE%"

REM 检查Git是否可用
echo 检查Git是否可用... >> "%LOG_FILE%"
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未检测到Git，无法继续部署
    echo 请安装Git后重试: https://git-scm.com/downloads
    echo ❌ 未检测到Git，无法继续部署 >> "%LOG_FILE%"
    echo 错误代码: %errorlevel% >> "%LOG_FILE%"
    echo 部署失败时间: %date% %time% >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo ✅ Git检测成功 >> "%LOG_FILE%"

REM 获取Git版本
git --version >> "%LOG_FILE%" 2>&1

REM 检查是否是Git仓库
echo 检查Git仓库状态... >> "%LOG_FILE%"
if not exist ".git" (
    echo 当前目录不是Git仓库，正在初始化... >> "%LOG_FILE%"
    echo 初始化Git仓库...
    git init >> "%LOG_FILE%" 2>&1
    
    REM 检查Git用户配置
    git config --get user.name >> "%LOG_FILE%" 2>&1
    if %errorlevel% neq 0 (
        echo 设置临时Git用户名... >> "%LOG_FILE%"
        git config user.name "TaskManager" >> "%LOG_FILE%" 2>&1
    )
    
    git config --get user.email >> "%LOG_FILE%" 2>&1
    if %errorlevel% neq 0 (
        echo 设置临时Git邮箱... >> "%LOG_FILE%"
        git config user.email "taskmanager@example.com" >> "%LOG_FILE%" 2>&1
    )
    
    echo ✅ Git仓库初始化完成 >> "%LOG_FILE%"
) else (
    echo ✅ 当前目录已是Git仓库 >> "%LOG_FILE%"
)

REM 创建部署包
echo.
echo 📦 正在创建部署包...
echo 创建部署包... >> "%LOG_FILE%"

REM 创建临时目录
set TEMP_DIR=temp_deploy
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%" >> "%LOG_FILE%" 2>&1

echo 复制核心文件... >> "%LOG_FILE%"
echo 复制核心文件...

REM 复制HTML文件
set HTML_FILES=index.html edit-tasks.html focus-challenge.html statistics.html today-tasks.html sync-test.html
for %%F in (%HTML_FILES%) do (
    if exist "%%F" (
        copy "%%F" "%TEMP_DIR%\" >> "%LOG_FILE%" 2>&1
        echo   - 已复制: %%F >> "%LOG_FILE%"
    ) else (
        echo   - 跳过不存在的文件: %%F >> "%LOG_FILE%"
    )
)

REM 复制配置文件
set CONFIG_FILES=manifest.json icon-192.svg favicon.ico
for %%F in (%CONFIG_FILES%) do (
    if exist "%%F" (
        copy "%%F" "%TEMP_DIR%\" >> "%LOG_FILE%" 2>&1
        echo   - 已复制: %%F >> "%LOG_FILE%"
    ) else (
        echo   - 跳过不存在的文件: %%F >> "%LOG_FILE%"
    )
)

REM 复制CSS目录
if exist "css" (
    xcopy "css" "%TEMP_DIR%\css\" /E /I /Y >> "%LOG_FILE%" 2>&1
    echo ✅ CSS文件已复制 >> "%LOG_FILE%"
) else (
    echo CSS目录不存在，已跳过 >> "%LOG_FILE%"
    mkdir "%TEMP_DIR%\css" >> "%LOG_FILE%" 2>&1
)

REM 复制JS目录
if exist "js" (
    xcopy "js" "%TEMP_DIR%\js\" /E /I /Y >> "%LOG_FILE%" 2>&1
    echo ✅ JS文件已复制 >> "%LOG_FILE%"
) else (
    echo JS目录不存在，已跳过 >> "%LOG_FILE%"
    mkdir "%TEMP_DIR%\js" >> "%LOG_FILE%" 2>&1
)

REM 复制API目录
if exist "api" (
    xcopy "api" "%TEMP_DIR%\api\" /E /I /Y >> "%LOG_FILE%" 2>&1
    echo ✅ API文件已复制 >> "%LOG_FILE%"
) else (
    echo API目录不存在，已跳过 >> "%LOG_FILE%"
    mkdir "%TEMP_DIR%\api" >> "%LOG_FILE%" 2>&1
)

REM 复制数据目录
if exist "data" (
    xcopy "data" "%TEMP_DIR%\data\" /E /I /Y >> "%LOG_FILE%" 2>&1
    echo ✅ 数据文件已复制 >> "%LOG_FILE%"
) else (
    echo 数据目录不存在，已创建 >> "%LOG_FILE%"
    mkdir "%TEMP_DIR%\data" >> "%LOG_FILE%" 2>&1
)

REM 创建ZIP包
set ZIP_FILE=task-manager-v4.2.2.2-complete.zip
if exist "%ZIP_FILE%" del /f "%ZIP_FILE%"

powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory('%TEMP_DIR%', '%ZIP_FILE%')" >> "%LOG_FILE%" 2>&1

REM 获取ZIP包大小
for %%A in ("%ZIP_FILE%") do set ZIP_SIZE=%%~zA
echo ✅ 部署包创建成功: %ZIP_FILE% >> "%LOG_FILE%"
echo 📊 包大小: %ZIP_SIZE% 字节 >> "%LOG_FILE%"

REM 清理临时目录
rmdir /s /q "%TEMP_DIR%" >> "%LOG_FILE%" 2>&1

echo.
echo 🚀 开始Git部署...
echo 开始Git部署... >> "%LOG_FILE%"

REM 添加所有文件到Git
git add . >> "%LOG_FILE%" 2>&1

REM 提交更改
echo 提交更改到Git... >> "%LOG_FILE%"
git commit -m "✨ 更新任务管理系统到v4.2.2.2版本

🔄 同步功能增强:
- 修复跨浏览器数据同步问题
- 优化实时数据同步机制
- 添加智能错误恢复功能

🛠️ 部署改进:
- 增强日志记录功能
- 添加Git部署支持
- 简化部署流程

📊 其他改进:
- 优化用户界面
- 提高系统稳定性
- 完善错误处理机制" >> "%LOG_FILE%" 2>&1

REM 检查提交是否成功
if %errorlevel% neq 0 (
    echo ❌ Git提交失败 >> "%LOG_FILE%"
    echo 尝试创建初始提交... >> "%LOG_FILE%"
    
    REM 创建README.md文件
    echo # 小久任务管理系统 v4.2.2.2 > README.md
    git add README.md >> "%LOG_FILE%" 2>&1
    git commit -m "📝 初始提交" >> "%LOG_FILE%" 2>&1
    
    REM 再次添加所有文件
    git add . >> "%LOG_FILE%" 2>&1
    git commit -m "✨ 更新任务管理系统到v4.2.2.2版本" >> "%LOG_FILE%" 2>&1
)

REM 检查当前分支
for /f "tokens=*" %%a in ('git branch --show-current') do set CURRENT_BRANCH=%%a
echo 当前分支: %CURRENT_BRANCH% >> "%LOG_FILE%"

REM 如果不是main分支，创建或切换到main分支
if not "%CURRENT_BRANCH%"=="main" (
    echo 当前不是main分支，切换到main分支... >> "%LOG_FILE%"
    git branch -M main >> "%LOG_FILE%" 2>&1
)

REM 检查是否配置了远程仓库
git remote -v >> "%LOG_FILE%" 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ 未配置远程仓库，跳过推送步骤 >> "%LOG_FILE%"
    echo.
    echo ⚠️ 未配置远程仓库，无法推送代码
    echo 如需配置远程仓库，请执行以下命令:
    echo   git remote add origin 你的仓库URL
    echo   git push -u origin main
    echo.
    echo ✅ 本地Git部署已完成
) else (
    REM 推送到远程仓库
    echo 推送到远程仓库... >> "%LOG_FILE%"
    git push -u origin main >> "%LOG_FILE%" 2>&1
    
    if %errorlevel% neq 0 (
        echo ❌ 推送到远程仓库失败 >> "%LOG_FILE%"
        echo.
        echo ❌ 推送到远程仓库失败，请检查:
        echo   1. 远程仓库URL是否正确
        echo   2. 是否有推送权限
        echo   3. 网络连接是否正常
        echo.
        echo 📋 手动推送代码到远程仓库的命令:
        echo.
        echo   # 推送到GitHub (origin):
        echo   git push -u origin main
        echo.
        echo   # 推送到Gitee:
        echo   git push -u gitee main
        echo.
        echo   # 推送到Coding:
        echo   git push -u coding main
        echo.
        echo   # 强制推送(谨慎使用):
        echo   git push -f 远程仓库名 main
        echo.
        echo ✅ 本地Git部署已完成
    ) else (
        echo ✅ 推送到远程仓库成功 >> "%LOG_FILE%"
        echo.
        echo ✅ Git部署完成！
    )
)

REM 部署结束
echo.
echo 部署结束时间: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo.
echo 📝 完整日志已保存到: %LOG_FILE%
pause