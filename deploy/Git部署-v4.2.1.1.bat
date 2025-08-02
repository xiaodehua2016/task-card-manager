@echo off
chcp 65001 >nul
echo ========================================
echo 小久任务管理系统 v4.2.1 Git部署
echo 脚本版本: v4.2.1.1
echo ========================================
echo.
echo 此版本包含以下功能:
echo - 详细的Git状态检查
echo - 智能文件暂存
echo - 自动生成提交信息
echo - 完整的推送验证
echo - 详细的日志记录
echo - 正确的版本号管理
echo.
pause
echo.
echo 正在启动Git部署脚本...
powershell -ExecutionPolicy Bypass -File "%~dp0git-deploy-final-v4.2.1.1.ps1"
echo.
echo 部署完成！请检查上方的输出信息。
pause