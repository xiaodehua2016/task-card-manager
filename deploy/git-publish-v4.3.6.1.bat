@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ====================================================
:: Git发布脚本 v4.3.6.1
:: 功能：自动提交并推送到Git仓库，修复任务显示和按钮响应问题
:: ====================================================

set "VERSION=4.3.6.1"
set "LOG_FILE=deploy\git-publish-v%VERSION%.log"

:: 创建日志目录
if not exist "deploy" mkdir "deploy"

:: 开始记录日志
echo [%date% %time%] 开始Git发布 v%VERSION% > "%LOG_FILE%"

cls
echo.
echo =======================================
echo   Git发布脚本 v%VERSION%
echo =======================================
echo.
echo 修复内容：
echo ✅ 修复今日任务未显示问题
echo ✅ 修复底部按钮无法点击问题
echo ✅ 优化数据初始化逻辑
echo ✅ 增强错误处理机制
echo.

echo [1/5] 检查Git状态...
echo [%date% %time%] 检查Git状态 >> "%LOG_FILE%"

:: 检查是否在Git仓库中
git status >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：当前目录不是Git仓库
    echo [%date% %time%] 错误：不是Git仓库 >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: 显示当前状态
echo 当前Git状态：
git status --short
echo [%date% %time%] Git状态检查完成 >> "%LOG_FILE%"

echo.
echo [2/5] 添加所有更改到暂存区...
echo [%date% %time%] 添加文件到暂存区 >> "%LOG_FILE%"

git add .
if errorlevel 1 (
    echo ❌ 错误：添加文件到暂存区失败
    echo [%date% %time%] 错误：git add失败 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo ✅ 所有更改已添加到暂存区
echo [%date% %time%] 文件添加成功 >> "%LOG_FILE%"

echo.
echo [3/5] 提交更改...
echo [%date% %time%] 开始提交 >> "%LOG_FILE%"

set "COMMIT_MESSAGE=fix: 修复v%VERSION% - 任务显示和按钮响应问题"
set "COMMIT_DESCRIPTION=- 修复今日任务未显示的问题，确保8个默认任务正确显示^

- 修复底部按钮无法点击的问题，重新绑定全局函数^

- 优化数据初始化逻辑，确保数据结构完整性^

- 增强错误处理机制，提高系统稳定性^

- 完善TaskManager类，采用更可靠的事件绑定方式^

- 更新版本号为v%VERSION%，同步更新所有相关脚本"

git commit -m "%COMMIT_MESSAGE%" -m "%COMMIT_DESCRIPTION%"
if errorlevel 1 (
    echo ❌ 错误：提交失败
    echo [%date% %time%] 错误：git commit失败 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo ✅ 提交成功
echo [%date% %time%] 提交成功 >> "%LOG_FILE%"

echo.
echo [4/5] 创建版本标签...
echo [%date% %time%] 创建版本标签 >> "%LOG_FILE%"

git tag -a "v%VERSION%" -m "任务管理系统 v%VERSION% - 修复任务显示和按钮响应问题"
if errorlevel 1 (
    echo ⚠️ 警告：创建标签失败（可能已存在）
    echo [%date% %time%] 警告：创建标签失败 >> "%LOG_FILE%"
) else (
    echo ✅ 版本标签 v%VERSION% 创建成功
    echo [%date% %time%] 版本标签创建成功 >> "%LOG_FILE%"
)

echo.
echo [5/5] 推送到远程仓库...
echo [%date% %time%] 开始推送到远程仓库 >> "%LOG_FILE%"

:: 推送代码
git push origin main
if errorlevel 1 (
    echo ❌ 错误：推送代码失败
    echo [%date% %time%] 错误：git push失败 >> "%LOG_FILE%"
    echo.
    echo 可能的解决方案：
    echo 1. 检查网络连接
    echo 2. 检查Git凭据
    echo 3. 尝试使用SSH而不是HTTPS
    echo 4. 查看详细错误信息
    pause
    exit /b 1
)

:: 推送标签
git push origin "v%VERSION%"
if errorlevel 1 (
    echo ⚠️ 警告：推送标签失败
    echo [%date% %time%] 警告：推送标签失败 >> "%LOG_FILE%"
) else (
    echo ✅ 标签推送成功
    echo [%date% %time%] 标签推送成功 >> "%LOG_FILE%"
)

echo.
echo ✅ Git发布完成！
echo [%date% %time%] Git发布完成 >> "%LOG_FILE%"

echo.
echo 📊 发布摘要：
echo ✅ 版本：v%VERSION%
echo ✅ 提交：%COMMIT_MESSAGE%
echo ✅ 标签：v%VERSION%
echo ✅ 日志：%LOG_FILE%
echo.

echo 🌐 验证发布：
echo 1. 访问Git仓库查看最新提交
echo 2. 检查版本标签是否正确
echo 3. 确认所有文件都已推送
echo.

echo 📝 下一步：
echo 1. 运行 deploy-v%VERSION%.bat 创建部署包
echo 2. 部署到115服务器进行测试
echo 3. 验证任务显示和按钮点击功能
echo.

pause