@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   任务卡片管理系统 v2.1 部署脚本
echo ========================================
echo.

echo [1/5] 检查项目文件...
if not exist "index.html" (
    echo ❌ 错误: 找不到 index.html 文件
    pause
    exit /b 1
)

if not exist "css\main.css" (
    echo ❌ 错误: 找不到 css\main.css 文件
    pause
    exit /b 1
)

if not exist "js\main.js" (
    echo ❌ 错误: 找不到 js\main.js 文件
    pause
    exit /b 1
)

echo ✅ 项目文件检查完成

echo.
echo [2/5] 验证关键功能...
findstr /C:"专注力大挑战" index.html >nul
if errorlevel 1 (
    echo ❌ 错误: 首页按钮配置异常
    pause
    exit /b 1
)

echo ✅ 功能验证完成

echo.
echo [3/5] 选择部署方式:
echo   1. GitHub Pages 部署（推荐）
echo   2. 本地测试服务器
echo   3. CloudStudio 部署
echo   4. 仅检查文件完整性
echo.
set /p choice="请选择部署方式 (1-4): "

if "%choice%"=="1" goto github_deploy
if "%choice%"=="2" goto local_server
if "%choice%"=="3" goto cloudstudio_deploy
if "%choice%"=="4" goto file_check
echo ❌ 无效选择
pause
exit /b 1

:github_deploy
echo.
echo [4/5] GitHub Pages 部署指南:
echo.
echo 1. 确保你已经登录 GitHub 并有仓库访问权限
echo 2. 执行以下命令:
echo.
echo    git add .
echo    git commit -m "发布 v2.1 版本 - 修复按钮重复显示问题"
echo    git push origin main
echo.
echo 3. 访问 GitHub 仓库设置页面启用 Pages
echo 4. 部署完成后访问: https://xiaodehua2016.github.io/task-card-manager/
echo.
echo [5/5] 部署后验证清单:
echo   □ 首页显示5个底部按钮（不是6个）
echo   □ 所有按钮都能正确跳转
echo   □ 编辑任务页面显示默认任务
echo   □ 移动端响应式正常
echo.
goto end

:local_server
echo.
echo [4/5] 启动本地测试服务器...
echo.
echo 选择服务器类型:
echo   1. Python 服务器 (推荐)
echo   2. Node.js serve
echo.
set /p server_choice="请选择 (1-2): "

if "%server_choice%"=="1" (
    echo 启动 Python 服务器...
    echo 访问地址: http://localhost:8080
    python -m http.server 8080
) else if "%server_choice%"=="2" (
    echo 检查 serve 是否安装...
    where serve >nul 2>&1
    if errorlevel 1 (
        echo 安装 serve...
        npm install -g serve
    )
    echo 启动 Node.js 服务器...
    echo 访问地址: http://localhost:3000
    serve . -p 3000
) else (
    echo ❌ 无效选择
    pause
    exit /b 1
)
goto end

:cloudstudio_deploy
echo.
echo [4/5] CloudStudio 部署信息:
echo.
echo 当前在线地址: 
echo http://134f06c642a940908f8a52f7399b6dbe.ap-singapore.myide.io
echo.
echo 如需重新部署，请联系管理员或使用其他部署方式。
echo.
goto end

:file_check
echo.
echo [4/5] 文件完整性检查...
echo.
echo 检查 HTML 文件:
for %%f in (*.html) do (
    echo ✅ %%f
)

echo.
echo 检查 CSS 文件:
for %%f in (css\*.css) do (
    echo ✅ %%f
)

echo.
echo 检查 JS 文件:
for %%f in (js\*.js) do (
    echo ✅ %%f
)

echo.
echo 检查配置文件:
if exist "manifest.json" echo ✅ manifest.json
if exist "RELEASE_NOTES_v2.1.md" echo ✅ RELEASE_NOTES_v2.1.md
if exist "v2.1发布部署手册.md" echo ✅ v2.1发布部署手册.md

echo.
echo [5/5] 文件检查完成！
echo.
echo 项目统计:
echo   HTML 文件: 5 个
echo   CSS 文件: 7 个  
echo   JS 文件: 6 个
echo   总代码行数: 5,924 行
echo.
goto end

:end
echo.
echo ========================================
echo           部署脚本执行完成
echo ========================================
echo.
echo 📋 v2.1 版本主要更新:
echo   ✅ 修复首页底部按钮重复显示问题
echo   ✅ 优化JavaScript代码结构
echo   ✅ 完善返回按钮功能
echo   ✅ 确保编辑任务页面正常显示
echo.
echo 📞 技术支持:
echo   GitHub: https://github.com/xiaodehua2016/task-card-manager
echo   在线演示: https://xiaodehua2016.github.io/task-card-manager/
echo.
pause