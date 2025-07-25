@echo off
chcp 65001 >nul
echo.
echo ================================
echo 任务卡片管理系统 v3.0 发布脚本
echo ================================
echo.

echo 🚀 开始发布任务卡片管理系统 v3.0...

REM 检查Git状态
git status >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：当前目录不是Git仓库
    pause
    exit /b 1
)

REM 检查是否有未提交的更改
git diff-index --quiet HEAD -- >nul 2>&1
if errorlevel 1 (
    echo ⚠️  检测到未提交的更改，正在提交...
    git add .
    git commit -m "准备发布 v3.0 - 多设备云端同步功能"
)

REM 创建版本标签
echo 🏷️  创建版本标签 v3.0.0...
git tag -a v3.0.0 -m "版本 3.0.0 - 多设备云端同步功能"

REM 推送到远程仓库
echo 📤 推送代码和标签到远程仓库...
git push origin main
git push origin v3.0.0

REM 显示部署信息
echo.
echo 🔄 GitHub Actions将自动开始部署...
echo 📋 部署状态检查：
echo    1. 访问GitHub仓库的Actions标签
echo    2. 查看最新的部署工作流状态
echo    3. 等待部署完成（通常需要2-3分钟）
echo.
echo 🎉 版本3.0发布准备完成！
echo.
echo 📊 发布信息：
echo    版本号: v3.0.0
echo    发布时间: %date% %time%
echo    主要功能: 多设备云端同步
echo.
echo 🔗 相关链接：
echo    GitHub仓库: https://github.com/用户名/仓库名
echo    部署状态: https://github.com/用户名/仓库名/actions
echo    项目文档: https://github.com/用户名/仓库名/blob/main/README.md
echo.
echo 📚 部署后验证：
echo    1. 访问GitHub Pages URL
echo    2. 测试多设备同步功能
echo    3. 验证Supabase数据库连接
echo    4. 检查所有功能正常运行
echo.
echo 🆘 如遇问题：
echo    - 查看 deploy/TROUBLESHOOTING.md
echo    - 检查 deploy/RELEASE_v3.0.md
echo    - 查看GitHub Actions日志
echo.
echo ✅ 发布脚本执行完成！
echo.
pause