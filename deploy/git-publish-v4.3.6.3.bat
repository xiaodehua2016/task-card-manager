@echo off
chcp 65001 >nul
echo ========================================
echo 任务管理系统 v4.3.6.3 Git发布脚本
echo 功能：恢复任务计时 + 跨浏览器数据同步
echo ========================================
echo.

set VERSION=4.3.6.3
set LOG_FILE=deploy\logs\git-publish-v%VERSION%-%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%.log

:: 创建日志目录
if not exist "deploy\logs" mkdir "deploy\logs"

:: 开始记录日志
echo [%date% %time%] 开始Git发布 v%VERSION% >> "%LOG_FILE%"

echo [1/4] 检查Git状态...
git status
if %errorlevel% neq 0 (
    echo 错误: Git仓库状态检查失败
    echo Git状态检查失败 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo [2/4] 添加所有更改到暂存区...
git add .
if %errorlevel% neq 0 (
    echo 错误: 添加文件到暂存区失败
    echo 添加文件失败 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo 文件添加成功 >> "%LOG_FILE%"

echo [3/4] 提交更改...
git commit -m "发布 v%VERSION%: 恢复任务计时功能和跨浏览器数据同步"

if %errorlevel% neq 0 (
    echo 错误: 提交失败
    echo 提交失败 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo 提交成功 >> "%LOG_FILE%"

echo [4/4] 推送到远程仓库...
git push origin main
if %errorlevel% neq 0 (
    echo 错误: 推送失败，请检查网络连接
    echo 推送失败 >> "%LOG_FILE%"
    echo.
    echo 故障排除建议:
    echo   1. 检查网络连接
    echo   2. 确认Git凭据是否正确
    echo   3. 尝试手动推送: git push origin main
    echo.
    pause
    exit /b 1
)

echo 推送成功 >> "%LOG_FILE%"

echo.
echo ========================================
echo 成功! v%VERSION% 已发布到Git仓库
echo ========================================
echo.
echo 提交信息: 恢复任务计时功能和跨浏览器数据同步
echo 发布时间: %date% %time%
echo 日志文件: %LOG_FILE%
echo.
echo GitHub仓库: https://github.com/xiaodehua2016/task-card-manager
echo.
echo 主要功能:
echo   - 任务计时功能完全恢复
echo   - 跨浏览器数据实时同步
echo   - 智能数据冲突解决
echo   - 完整的API支持
echo.

echo [%date% %time%] Git发布完成 >> "%LOG_FILE%"

echo 下一步操作:
echo   运行 server-deploy-v%VERSION%.bat 部署到115服务器
echo.
pause