@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.4 手动部署

REM 设置日志文件
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_DIR=%~dp0logs
set LOG_FILE=%LOG_DIR%\manual_deploy_log_%TIMESTAMP%.txt

REM 创建日志目录
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM 开始记录日志
echo ======================================== > "%LOG_FILE%"
echo    小久任务管理系统 v4.2.4 手动部署    >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 部署开始时间: %date% %time% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo ========================================
echo    小久任务管理系统 v4.2.4 手动部署
echo ========================================
echo.
echo 📝 日志将保存到: %LOG_FILE%
echo.

REM 切换到项目根目录
cd /d %~dp0..
echo 当前工作目录: %CD% >> "%LOG_FILE%"

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
echo.
echo 📦 正在创建部署包...
echo 创建部署包... >> "%LOG_FILE%"

REM 检查是否已存在部署包
set ZIP_FILE=task-manager-v4.2.4-complete.zip
if exist "%ZIP_FILE%" (
    echo 部署包已存在: %ZIP_FILE% >> "%LOG_FILE%"
    echo 部署包已存在: %ZIP_FILE%
) else (
    echo 创建新的部署包... >> "%LOG_FILE%"
    echo 创建新的部署包...
    
    REM 使用PowerShell脚本创建部署包
    powershell -ExecutionPolicy Bypass -Command "& {. '%~dp0deploy-v4.2.4.1-simple.ps1' -PackageOnly}" >> "%LOG_FILE%" 2>&1
    
    if %errorlevel% neq 0 (
        echo ❌ 创建部署包失败 >> "%LOG_FILE%"
        echo ❌ 创建部署包失败，请查看日志文件: %LOG_FILE%
        pause
        exit /b 1
    )
)

REM 获取ZIP包大小
for %%A in ("%ZIP_FILE%") do set ZIP_SIZE=%%~zA
echo ✅ 部署包已就绪: %ZIP_FILE% >> "%LOG_FILE%"
echo 📊 包大小: %ZIP_SIZE% 字节 >> "%LOG_FILE%"

echo ✅ 部署包已就绪: %ZIP_FILE%
echo 📊 包大小: %ZIP_SIZE% 字节

echo.
echo 🚀 部署选项:
echo.
echo 1. 使用SCP命令上传 (推荐)
echo 2. 手动上传指南
echo.

set /p choice="请选择部署方式 (1-2): "
echo 用户选择: %choice% >> "%LOG_FILE%"

if "%choice%"=="1" goto scp_upload
if "%choice%"=="2" goto manual_guide
echo ❌ 无效选择: %choice% >> "%LOG_FILE%"
goto invalid_choice

:scp_upload
echo.
echo 📤 使用SCP上传文件...
echo 使用SCP上传文件... >> "%LOG_FILE%"

echo.
echo 📋 SCP命令:
echo.
echo   scp "%CD%\%ZIP_FILE%" root@115.159.5.111:/tmp/
echo.
echo 请复制上述命令并在终端中执行，或者手动上传文件。
echo 上传完成后按任意键继续...
pause > nul

echo.
echo 📋 服务器操作命令:
echo.
echo   cd /www/wwwroot/
echo   unzip -o /tmp/%ZIP_FILE% -d task-manager/
echo   chown -R www:www task-manager/
echo   chmod -R 755 task-manager/
echo.
echo 请复制上述命令并在服务器终端中执行。
echo 操作完成后按任意键继续...
pause > nul
goto deployment_complete

:manual_guide
echo.
echo 📋 手动上传指南:
echo 显示手动上传指南... >> "%LOG_FILE%"

echo.
echo 1. 使用FTP工具上传以下文件到服务器:
echo    - 本地文件: %CD%\%ZIP_FILE%
echo    - 上传到: /tmp/%ZIP_FILE%
echo.
echo 2. 可使用以下工具:
echo    - FileZilla
echo    - WinSCP
echo    - 宝塔面板文件管理器
echo.
echo 上传完成后按任意键继续...
pause > nul

echo.
echo 📋 手动解压指南:
echo.
echo 请在服务器上执行以下命令:
echo.
echo cd /www/wwwroot/
echo unzip -o /tmp/%ZIP_FILE% -d task-manager/
echo chown -R www:www task-manager/
echo chmod -R 755 task-manager/
echo.
echo 💡 宝塔面板操作:
echo    - 登录: http://115.159.5.111:8888
echo    - 文件管理 → 上传 %ZIP_FILE%
echo    - 解压到 /www/wwwroot/task-manager/
echo    - 设置权限: 所有者 www 权限 755
echo.
echo 操作完成后按任意键继续...
pause > nul
goto deployment_complete

:invalid_choice
echo.
echo ❌ 无效的选择: %choice%
echo 请重新运行脚本并选择有效的选项 (1-2)
goto end

:deployment_complete
echo.
echo 🎉 部署完成!
echo 部署完成 >> "%LOG_FILE%"

echo.
echo 🧪 部署后测试步骤:
echo.
echo 1. 基础测试:
echo    - 访问 http://115.159.5.111/
echo    - 检查页面是否正常加载
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
echo    - 在电脑浏览器中访问
echo    - 验证数据是否在所有设备间同步
echo.

echo 📊 v4.2.4 版本特性总结:
echo ✅ 跨浏览器数据同步 - 彻底修复
echo ✅ 实时数据同步 - 2秒内完成
echo ✅ 智能错误恢复 - 自动修复机制
echo ✅ 本地存储监听 - 即时触发同步
echo ✅ 可视化诊断 - 问题排查利器
echo ✅ 简化部署流程 - 多种部署方式

:end
echo.
echo 部署结束时间: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"

echo.
echo 📝 完整日志已保存到: %LOG_FILE%
echo.
pause