@echo off
chcp 65001 >nul
echo ========================================
echo 任务管理系统 v4.3.6.4 Git发布脚本
echo 功能：修复跨浏览器数据同步问题
echo ========================================
echo.

set VERSION=4.3.6.4

:: 创建日志目录
if not exist "deploy\logs" mkdir "deploy\logs"

echo [1/4] 检查Git状态...
git status
if %errorlevel% neq 0 (
    echo 错误: Git仓库状态检查失败
    pause
    exit /b 1
)

echo [2/4] 添加所有更改到暂存区...
git add .
if %errorlevel% neq 0 (
    echo 错误: 添加文件到暂存区失败
    pause
    exit /b 1
)

echo [3/4] 提交更改...
git commit -m "发布 v%VERSION%: 修复跨浏览器数据同步问题"

if %errorlevel% neq 0 (
    echo 错误: 提交失败
    pause
    exit /b 1
)

echo [4/4] 推送到远程仓库...
git push origin main
if %errorlevel% neq 0 (
    echo 错误: 推送失败，请检查网络连接
    echo.
    echo 故障排除建议:
    echo   1. 检查网络连接
    echo   2. 确认Git凭据是否正确
    echo   3. 尝试手动推送: git push origin main
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo 成功! v%VERSION% 已发布到Git仓库
echo ========================================
echo.
echo 提交信息: 修复跨浏览器数据同步问题
echo GitHub仓库: https://github.com/xiaodehua2016/task-card-manager
echo.
echo 主要修复:
echo   - 使用共享数据文件确保数据一致性
echo   - 优化数据合并算法
echo   - 增强文件锁机制
echo   - 修复同一设备多浏览器数据不同步问题
echo.
echo 下一步操作:
echo   运行 server-deploy-v%VERSION%.bat 部署到115服务器
echo.
pause