@echo off
chcp 65001 >nul
echo.
echo ========================================
echo    小久任务管理系统 v4.2.2 终极简化部署
echo    解决数据同步问题的最终版本
echo ========================================
echo.

echo 📦 正在创建完整部署包...
if exist task-manager-v4.2.2-complete.zip del /f task-manager-v4.2.2-complete.zip

:: 创建临时目录
if exist temp-deploy rmdir /s /q temp-deploy
mkdir temp-deploy

:: 复制核心文件
echo 📁 复制核心文件...
copy index.html temp-deploy\
copy sync-test.html temp-deploy\
copy manifest.json temp-deploy\ 2>nul
copy favicon.ico temp-deploy\ 2>nul

:: 复制CSS目录
if exist css (
    xcopy css temp-deploy\css\ /E /I /Q
    echo ✅ CSS文件已复制
)

:: 复制JS目录
if exist js (
    xcopy js temp-deploy\js\ /E /I /Q
    echo ✅ JS文件已复制
)

:: 复制API目录
if exist api (
    xcopy api temp-deploy\api\ /E /I /Q
    echo ✅ API文件已复制
)

:: 复制数据目录
if exist data (
    xcopy data temp-deploy\data\ /E /I /Q
    echo ✅ 数据文件已复制
)

:: 创建部署包
powershell -Command "Compress-Archive -Path temp-deploy\* -DestinationPath task-manager-v4.2.2-complete.zip -Force"

:: 清理临时目录
rmdir /s /q temp-deploy

if exist task-manager-v4.2.2-complete.zip (
    echo ✅ 完整部署包创建成功: task-manager-v4.2.2-complete.zip
    for %%I in (task-manager-v4.2.2-complete.zip) do echo 📊 包大小: %%~zI 字节
) else (
    echo ❌ 部署包创建失败
    pause
    exit /b 1
)

echo.
echo 🚀 部署选项:
echo.
echo 1. 手动部署到115服务器 (推荐)
echo 2. Git提交并推送
echo 3. 仅创建部署包
echo.

set /p choice="请选择部署方式 (1-3): "

if "%choice%"=="1" goto manual_deploy
if "%choice%"=="2" goto git_deploy
if "%choice%"=="3" goto package_only
goto invalid_choice

:manual_deploy
echo.
echo 🔧 手动部署指南:
echo.
echo 📋 部署步骤:
echo 1. 上传文件:
echo    - 将 task-manager-v4.2.2-complete.zip 上传到服务器
echo    - 可使用宝塔面板文件管理器或FTP工具
echo.
echo 2. 服务器操作 (通过宝塔面板终端或SSH):
echo    cd /www/wwwroot/
echo    unzip -o task-manager-v4.2.2-complete.zip -d task-manager/
echo    chown -R www:www task-manager/
echo    chmod -R 755 task-manager/
echo.
echo 3. 验证部署:
echo    访问: http://115.159.5.111/
echo    测试: http://115.159.5.111/sync-test.html
echo.
echo 💡 宝塔面板操作:
echo    - 登录: http://115.159.5.111:8888
echo    - 文件管理 → 上传 task-manager-v4.2.2-complete.zip
echo    - 解压到 /www/wwwroot/task-manager/
echo    - 设置权限: 所有者 www, 权限 755
echo.
goto test_instructions

:git_deploy
echo.
echo 🚀 开始Git部署...
echo.

echo 📝 提交代码...
git add .
git commit -m "🚀 v4.2.2 终极修复版 - 彻底解决数据同步问题

✨ 核心修复:
- 修复跨浏览器数据同步逻辑
- 增强本地存储监听机制
- 优化服务器数据合并算法
- 添加强制同步和自动恢复

🔧 部署优化:
- 简化部署流程，减少文件数量
- 创建完整部署包
- 优化密码处理机制

🎯 用户体验:
- 实时数据同步 (3秒内)
- 跨设备无缝切换
- 自动错误恢复
- 可视化诊断工具"

if %errorlevel% equ 0 (
    echo ✅ 代码提交成功
) else (
    echo ⚠️ 代码提交失败或无新变更
)

echo 📤 推送到GitHub...
git push origin main

if %errorlevel% equ 0 (
    echo ✅ 代码推送成功
    echo.
    echo 🌐 GitHub Pages 将自动部署
    echo 📍 访问地址: https://[你的用户名].github.io/[仓库名]
    echo.
    echo 💡 Vercel也会自动检测并部署
) else (
    echo ❌ 代码推送失败
    echo 💡 请检查Git配置和网络连接
)
goto test_instructions

:package_only
echo.
echo ✅ 部署包已创建完成
echo 📦 文件: task-manager-v4.2.2-complete.zip
echo 💡 请手动上传到目标服务器
goto end

:invalid_choice
echo ❌ 无效选择，请重新运行脚本
goto end

:test_instructions
echo.
echo 🧪 部署后测试步骤:
echo.
echo 1. 基础测试:
echo    - 访问 http://115.159.5.111/
echo    - 检查页面是否正常加载
echo    - 添加几个任务并完成
echo.
echo 2. 同步测试:
echo    - 在Chrome中完成一些任务
echo    - 在Firefox中打开同一地址
echo    - 检查任务状态是否同步
echo    - 等待3-5秒观察自动同步
echo.
echo 3. 诊断测试:
echo    - 访问 http://115.159.5.111/sync-test.html
echo    - 点击"运行诊断"查看同步状态
echo    - 如有问题，点击"自动修复"
echo.
echo 4. 跨设备测试:
echo    - 在手机浏览器中访问
echo    - 在不同电脑的浏览器中访问
echo    - 验证数据是否在所有设备间同步
echo.

:end
echo.
echo 📊 v4.2.2 版本特性总结:
echo ✅ 跨浏览器数据同步 - 彻底修复
echo ✅ 实时数据同步 - 3秒内完成  
echo ✅ 智能错误恢复 - 自动修复机制
echo ✅ 本地存储监听 - 即时触发同步
echo ✅ 可视化诊断 - 问题排查利器
echo ✅ 简化部署流程 - 一个文件搞定
echo.
echo 🎉 部署准备完成！
echo 💡 如遇问题，请查看同步测试页面进行诊断
echo.
pause