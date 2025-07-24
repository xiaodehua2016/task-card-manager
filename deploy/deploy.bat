@echo off
echo ================================
echo 任务卡片管理系统 - 快速部署脚本
echo ================================
echo.

echo 正在检查项目文件...
if not exist "index.html" (
    echo 错误：未找到 index.html 文件
    pause
    exit /b 1
)

if not exist "css\main.css" (
    echo 错误：未找到主样式文件
    pause
    exit /b 1
)

if not exist "js\main.js" (
    echo 错误：未找到主脚本文件
    pause
    exit /b 1
)

echo ✅ 项目文件检查完成
echo.

echo 准备部署文件列表：
echo - index.html (主页面)
echo - edit-tasks.html (任务编辑)
echo - today-tasks.html (今日任务管理)
echo - statistics.html (统计分析)
echo - focus-challenge.html (专注挑战)
echo - manifest.json (PWA配置)
echo - css/ 目录 (样式文件)
echo - js/ 目录 (脚本文件)
echo - data/ 目录 (数据管理)
echo.

echo 部署方式选择：
echo 1. 手动上传到 GitHub (推荐)
echo 2. 使用 Git 命令行
echo.

set /p choice=请选择部署方式 (1 或 2): 

if "%choice%"=="1" (
    echo.
    echo 📋 手动部署步骤：
    echo 1. 打开 https://github.com/xiaodehua2016/task-card-manager
    echo 2. 点击 "Add file" → "Upload files"
    echo 3. 拖拽上传以下文件：
    echo    - 所有 .html 文件
    echo    - css/ 目录下的所有文件
    echo    - js/ 目录下的所有文件
    echo    - manifest.json
    echo 4. 填写提交信息：发布优化版本 v2.0
    echo 5. 点击 "Commit changes"
    echo 6. 等待 1-5 分钟后访问：
    echo    https://xiaodehua2016.github.io/task-card-manager/
    echo.
    echo 按任意键打开 GitHub 仓库页面...
    pause >nul
    start https://github.com/xiaodehua2016/task-card-manager
) else if "%choice%"=="2" (
    echo.
    echo 🔧 Git 命令行部署：
    echo.
    echo 请确保已安装 Git 并配置好 GitHub 账户
    echo.
    set /p confirm=确认继续？(y/n): 
    if /i "%confirm%"=="y" (
        echo.
        echo 正在执行 Git 部署...
        
        if not exist ".git" (
            echo 初始化 Git 仓库...
            git init
            git remote add origin https://github.com/xiaodehua2016/task-card-manager.git
        )
        
        echo 添加文件到暂存区...
        git add .
        
        echo 提交更改...
        git commit -m "发布优化版本 v2.0 - 新增今日任务管理功能，统一页面设计风格，优化底部导航按钮"
        
        echo 推送到 GitHub...
        git push origin main
        
        if %errorlevel%==0 (
            echo.
            echo ✅ 部署成功！
            echo 🌐 访问地址：https://xiaodehua2016.github.io/task-card-manager/
            echo ⏰ 请等待 1-5 分钟后访问新版本
        ) else (
            echo.
            echo ❌ 部署失败，请检查 Git 配置和网络连接
        )
    )
)

echo.
echo 部署完成！感谢使用任务卡片管理系统。
pause