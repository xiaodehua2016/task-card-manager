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
echo [%date% %time%] 开始Git发布 v%VERSION% >> %LOG_FILE%

echo [1/4] 检查Git状态...
git status
if %errorlevel% neq 0 (
    echo ❌ Git仓库状态检查失败
    echo Git状态检查失败 >> %LOG_FILE%
    pause
    exit /b 1
)

echo [2/4] 添加所有更改到暂存区...
git add .
if %errorlevel% neq 0 (
    echo ❌ 添加文件到暂存区失败
    echo 添加文件失败 >> %LOG_FILE%
    pause
    exit /b 1
)

echo 文件添加成功 >> %LOG_FILE%

echo [3/4] 提交更改...
git commit -m "发布 v%VERSION%: 恢复任务计时功能 + 跨浏览器数据同步

主要更新:
✅ 恢复任务计时功能 - 每个任务卡片显示累计用时
✅ 跨浏览器数据同步 - 基于服务器文件的数据同步机制
✅ 完整的API支持 - data-sync.php提供数据同步服务
✅ 智能数据合并 - 自动处理数据冲突和时间戳比较
✅ 优化用户体验 - 实时计时显示和状态更新

修复问题:
🔧 任务计时功能被移除的问题
🔧 同一台电脑两个浏览器数据不同步的问题
🔧 功能模块间调用冲突的问题

技术改进:
🚀 独立的JavaScript架构，无外部依赖
🚀 每5秒自动数据同步
🚀 完善的错误处理和日志记录
🚀 支持数据版本控制和冲突解决"

if %errorlevel% neq 0 (
    echo ❌ 提交失败
    echo 提交失败 >> %LOG_FILE%
    pause
    exit /b 1
)

echo 提交成功 >> %LOG_FILE%

echo [4/4] 推送到远程仓库...
git push origin main
if %errorlevel% neq 0 (
    echo ❌ 推送失败，请检查网络连接或运行 diagnose-git-connection.bat
    echo 推送失败 >> %LOG_FILE%
    echo.
    echo 💡 故障排除建议:
    echo   1. 检查网络连接
    echo   2. 运行 deploy\diagnose-git-connection.bat 诊断问题
    echo   3. 查看 deploy\GIT_TROUBLESHOOTING.md 获取解决方案
    echo.
    pause
    exit /b 1
)

echo 推送成功 >> %LOG_FILE%

echo.
echo ========================================
echo 🎉 v%VERSION% 已成功发布到Git仓库！
echo ========================================
echo.
echo 📝 提交信息: 恢复任务计时功能 + 跨浏览器数据同步
echo 📅 发布时间: %date% %time%
echo 📋 日志文件: %LOG_FILE%
echo.
echo 🔗 GitHub仓库: https://github.com/xiaodehua2016/task-card-manager
echo.
echo ✅ 主要功能:
echo   • 任务计时功能完全恢复
echo   • 跨浏览器数据实时同步
echo   • 智能数据冲突解决
echo   • 完整的API支持
echo.

echo [%date% %time%] Git发布完成 >> %LOG_FILE%

echo 💡 下一步操作:
echo   运行 server-deploy-v%VERSION%.bat 部署到115服务器
echo.
pause