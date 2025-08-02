@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.2.2 手动部署

REM 设置日志文件
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_DIR=%~dp0logs
set LOG_FILE=%LOG_DIR%\manual_deploy_log_%TIMESTAMP%.txt

REM 创建日志目录
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM 开始记录日志
echo ======================================== > "%LOG_FILE%"
echo    小久任务管理系统 v4.2.2.2 手动部署    >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 部署开始时间: %date% %time% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo ========================================
echo    小久任务管理系统 v4.2.2.2 手动部署
echo ========================================
echo.
echo 📝 日志将保存到: %LOG_FILE%
echo.

REM 检查PowerShell是否可用
echo 检查PowerShell是否可用... >> "%LOG_FILE%"
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未检测到PowerShell，无法继续部署
    echo 请安装PowerShell后重试
    echo ❌ 未检测到PowerShell，无法继续部署 >> "%LOG_FILE%"
    echo 错误代码: %errorlevel% >> "%LOG_FILE%"
    echo 部署失败时间: %date% %time% >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo ✅ PowerShell检测成功 >> "%LOG_FILE%"

REM 创建部署包
echo 📦 正在创建完整部署包...
echo 创建部署包... >> "%LOG_FILE%"
echo 执行命令: powershell -ExecutionPolicy Bypass -Command "& { . '%~dp0deploy-v4.2.2.2.ps1'; Create-Package }" >> "%LOG_FILE%"
powershell -ExecutionPolicy Bypass -Command "& { . '%~dp0deploy-v4.2.2.2.ps1'; Create-Package }" >> "%LOG_FILE%" 2>&1
set DEPLOY_STATUS=%errorlevel%

if %DEPLOY_STATUS% neq 0 (
    echo ❌ 创建部署包过程中出现错误，请查看日志文件: %LOG_FILE%
    echo 错误代码: %DEPLOY_STATUS% >> "%LOG_FILE%"
    goto end
)

echo.
echo 🔧 手动部署指南:
echo.
echo 📋 部署步骤:
echo 1. 上传文件:
echo    - 将 task-manager-v4.2.2.2-complete.zip 上传到服务器
echo    - 可使用宝塔面板文件管理器或FTP工具
echo.
echo 2. 服务器操作 (通过宝塔面板终端或SSH):
echo    cd /www/wwwroot/
echo    unzip -o task-manager-v4.2.2.2-complete.zip -d task-manager/
echo    chown -R www:www task-manager/
echo    chmod -R 755 task-manager/
echo.
echo 3. 验证部署:
echo    访问: http://115.159.5.111/
echo    测试: http://115.159.5.111/sync-test.html
echo.
echo 💡 宝塔面板操作:
echo    - 登录: http://115.159.5.111:8888
echo    - 文件管理 → 上传 task-manager-v4.2.2.2-complete.zip
echo    - 解压到 /www/wwwroot/task-manager/
echo    - 设置权限: 所有者 www, 权限 755
echo.
echo.
echo 🧪 部署后测试步骤:
echo.
echo 1. 基础测试:
echo    - 访问 http://115.159.5.111/
echo    - 检查页面是否正常加载
echo    - 创建一个任务并完成
echo.
echo 2. 同步测试:
echo    - 在Chrome中完成一些任务
echo    - 在Firefox中打开同一地址
echo    - 等待5秒观察自动同步
echo.
echo 3. 诊断测试:
echo    - 访问 http://115.159.5.111/sync-test.html
echo    - 点击"运行诊断"查看同步状态
echo    - 如有问题，点击"自动修复"
echo.
echo 4. 跨设备测试:
echo    - 在手机浏览器中访问
echo    - 在其他的浏览器中访问
echo    - 验证数据是否在所有设备间同步
echo.
echo.
echo 📊 v4.2.2.2 版本特性总结:
echo ✅ 跨浏览器数据同步 - 彻底修复
echo ✅ 实时数据同步 - 3秒内完成
echo ✅ 智能错误恢复 - 自动修复机制
echo ✅ 本地存储监听 - 即时触发同步
echo ✅ 可视化诊断 - 问题排查利器
echo ✅ 简化部署流程 - 一个文件搞定
echo ✅ 自动化部署 - Git集成支持
echo.
echo 🎉 部署准备完成！
echo 请按照上述步骤完成部署，并使用测试页面进行诊断

REM 记录手动部署指南到日志
echo 手动部署指南已显示给用户 >> "%LOG_FILE%"

:end
echo.
echo 部署结束时间: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo.
echo 📝 完整日志已保存到: %LOG_FILE%
pause