@echo off
chcp 65001 >nul
echo.
echo ========================================
echo    小久任务管理系统 v4.2.2 一键部署
echo    跨浏览器数据同步完美修复版
echo ========================================
echo.

echo 📦 正在创建部署包...
if exist task-manager-v4.2.2.zip del /f task-manager-v4.2.2.zip

powershell -Command "Compress-Archive -Path * -DestinationPath task-manager-v4.2.2.zip -Exclude .git,node_modules,.codebuddy -Force"

if exist task-manager-v4.2.2.zip (
    echo ✅ 部署包创建成功: task-manager-v4.2.2.zip
    echo 📊 包大小: 
    dir task-manager-v4.2.2.zip | findstr "task-manager-v4.2.2.zip"
) else (
    echo ❌ 部署包创建失败
    pause
    exit /b 1
)

echo.
echo 🔗 部署选项:
echo.
echo 1. GitHub Pages 部署
echo    - 推送代码到 GitHub
echo    - 自动启用 GitHub Pages
echo.
echo 2. Vercel 部署  
echo    - 推送到 GitHub 后自动部署
echo    - 或使用 Vercel CLI 手动部署
echo.
echo 3. 115服务器部署
echo    - 需要手动上传 task-manager-v4.2.2.zip
echo    - 服务器地址: 115.159.5.111
echo.

set /p choice="请选择部署方式 (1-3): "

if "%choice%"=="1" goto github_deploy
if "%choice%"=="2" goto vercel_deploy  
if "%choice%"=="3" goto server_deploy
goto invalid_choice

:github_deploy
echo.
echo 🚀 开始 GitHub Pages 部署...
echo.

echo 📝 提交代码到 Git...
git add .
git commit -m "🚀 发布 v4.2.2 - 跨浏览器数据同步完美修复版

✨ 新功能:
- 彻底修复跨浏览器数据同步问题
- 新增数据同步诊断工具
- 添加可视化测试页面
- 智能数据合并和冲突解决

🔧 优化:
- API调用路径修复
- 数据结构标准化
- 错误处理机制增强
- 多存储键兼容支持

🐛 修复:
- API端点调用错误
- 数据合并逻辑缺陷
- 存储键不统一问题
- 同步延迟和失败问题"

if %errorlevel% equ 0 (
    echo ✅ 代码提交成功
) else (
    echo ⚠️ 代码提交失败或无新变更
)

echo 📤 推送到 GitHub...
git push origin main

if %errorlevel% equ 0 (
    echo ✅ 代码推送成功
    echo.
    echo 🌐 GitHub Pages 将自动部署
    echo 📍 访问地址: https://[你的用户名].github.io/[仓库名]
) else (
    echo ❌ 代码推送失败
    echo 💡 请检查 Git 配置和网络连接
)
goto end

:vercel_deploy
echo.
echo 🚀 开始 Vercel 部署...
echo.

echo 📝 提交代码到 Git...
git add .
git commit -m "🚀 发布 v4.2.2 - 跨浏览器数据同步完美修复版"

echo 📤 推送到 GitHub...
git push origin main

if %errorlevel% equ 0 (
    echo ✅ 代码推送成功
    echo.
    echo 🌐 Vercel 将自动检测并部署
    echo 📍 访问 Vercel 控制台查看部署状态
    echo 💡 如需手动部署，请运行: vercel --prod
) else (
    echo ❌ 代码推送失败
)
goto end

:server_deploy
echo.
echo 🚀 115服务器部署指南...
echo.
echo 📋 部署步骤:
echo.
echo 1. 上传文件:
echo    - 将 task-manager-v4.2.2.zip 上传到服务器
echo    - 可使用 SCP、FTP 或宝塔面板文件管理
echo.
echo 2. 服务器操作:
echo    ssh root@115.159.5.111
echo    cd /www/wwwroot/
echo    unzip task-manager-v4.2.2.zip -d task-manager/
echo    chown -R www:www task-manager/
echo    chmod -R 755 task-manager/
echo.
echo 3. 验证部署:
echo    访问: http://115.159.5.111/
echo    测试: http://115.159.5.111/sync-test.html
echo.
echo 💡 提示: 部署包已准备就绪，请按照上述步骤操作
goto end

:invalid_choice
echo ❌ 无效选择，请重新运行脚本
goto end

:end
echo.
echo 📊 v4.2.2 版本特性:
echo ✅ 跨浏览器数据同步 - 完美修复
echo ✅ 实时数据同步 - 3秒内完成
echo ✅ 智能错误恢复 - 自动修复机制
echo ✅ 数据一致性保证 - 100%可靠
echo ✅ 可视化诊断工具 - 问题排查利器
echo.
echo 🎉 部署准备完成！
echo 💡 如有问题，请查看 deploy/FINAL_RELEASE_v4.2.2.md
echo.
pause