@echo off
chcp 65001 > nul
setlocal

:: ==================================================
:: Git 发布脚本 (v5.0.0)
:: 功能: 自动化 add, commit, push 流程
:: ==================================================

echo.
echo =======================================
echo   Git 快速发布脚本
echo =======================================
echo.

:: 检查是否在 Git 仓库的根目录
if not exist ".git" (
    echo [错误] 未找到 .git 目录。请在项目根目录下运行此脚本。
    pause
    exit /b
)

:: 获取提交信息
set "commit_message="
set /p "commit_message=请输入本次提交的信息 (例如: '修复了UI显示bug'): "

if not defined commit_message (
    echo [警告] 未输入提交信息，将使用默认信息。
    set "commit_message=Update: 常规更新"
)

echo.
echo [1/3] 正在将所有更改添加到暂存区...
git add .
echo   - 完成: `git add .`
echo.

echo [2/3] 正在提交更改...
git commit -m "%commit_message%"
echo   - 完成: `git commit -m "%commit_message%"`
echo.

echo [3/3] 正在推送到远程仓库 (origin main)...
git push origin main

echo.
echo =======================================
echo   🎉 发布成功!
echo =======================================
echo.
echo   所有更改已成功推送到远程仓库。
echo.
pause