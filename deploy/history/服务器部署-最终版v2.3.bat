@echo off
chcp 65001 >nul
echo ========================================
echo 小久任务管理系统 v4.2.1 服务器部署
echo 最终版本 v2.3 (已修复密码文件路径)
echo ========================================
echo.
echo 此版本包含以下功能:
echo - 自动密码输入 (支持sshpass)
echo - 增强的错误处理
echo - 详细的日志输出
echo - 完整的部署验证
echo.
echo 密码文件路径: C:\AA\codebuddy\1\123.txt
echo.
pause
echo.
echo 正在启动部署脚本...
powershell -ExecutionPolicy Bypass -File "%~dp0server-deploy-final-v2.3.ps1"
echo.
echo 部署完成！请检查上方的输出信息。
pause