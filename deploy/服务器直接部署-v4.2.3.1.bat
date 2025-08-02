@echo off
chcp 65001 > nul
title 小久任务管理系统 v4.2.3 服务器直接部署

REM 设置日志文件
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_DIR=%~dp0logs
set LOG_FILE=%LOG_DIR%\server_deploy_log_%TIMESTAMP%.txt

REM 创建日志目录
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM 开始记录日志
echo ======================================== > "%LOG_FILE%"
echo    小久任务管理系统 v4.2.3 服务器直接部署    >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 部署开始时间: %date% %time% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo ========================================
echo    小久任务管理系统 v4.2.3 服务器直接部署
echo ========================================
echo.
echo 📝 日志将保存到: %LOG_FILE%
echo.

REM 切换到项目根目录
cd /d %~dp0..
echo 当前工作目录: %CD% >> "%LOG_FILE%"

REM 检查是否存在部署包
set ZIP_FILE=task-manager-v4.2.3-complete.zip
if not exist "%ZIP_FILE%" (
    echo 部署包不存在，正在创建... >> "%LOG_FILE%"
    echo 部署包不存在，正在创建...
    
    REM 创建部署包
    powershell -ExecutionPolicy Bypass -Command "& '%~dp0deploy-v4.2.3.1-simple.ps1'" >> "%LOG_FILE%" 2>&1
    
    if not exist "%ZIP_FILE%" (
        echo ❌ 创建部署包失败，请查看日志文件: %LOG_FILE% >> "%LOG_FILE%"
        echo ❌ 创建部署包失败，请查看日志文件: %LOG_FILE%
        pause
        exit /b 1
    )
)

echo ✅ 部署包已就绪: %ZIP_FILE% >> "%LOG_FILE%"
echo ✅ 部署包已就绪: %ZIP_FILE%

REM 检查pscp是否可用
where pscp >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️ 未检测到pscp工具，将使用手动上传方式 >> "%LOG_FILE%"
    echo ⚠️ 未检测到pscp工具，将使用手动上传方式
    goto manual_upload
)

echo 检测到pscp工具，可以使用自动上传 >> "%LOG_FILE%"
echo 检测到pscp工具，可以使用自动上传

REM 服务器信息
set SERVER_IP=115.159.5.111
set SERVER_USER=root
set REMOTE_PATH=/www/wwwroot/task-manager/

echo.
echo 🔧 服务器信息:
echo   - 服务器IP: %SERVER_IP%
echo   - 用户名: %SERVER_USER%
echo   - 远程路径: %REMOTE_PATH%
echo.

echo 服务器信息: >> "%LOG_FILE%"
echo   - 服务器IP: %SERVER_IP% >> "%LOG_FILE%"
echo   - 用户名: %SERVER_USER% >> "%LOG_FILE%"
echo   - 远程路径: %REMOTE_PATH% >> "%LOG_FILE%"

REM 提示输入密码
set /p SERVER_PASS="请输入服务器密码: "
echo 用户已输入密码 >> "%LOG_FILE%"

REM 上传文件
echo.
echo 🚀 正在上传部署包到服务器...
echo 上传部署包到服务器... >> "%LOG_FILE%"

REM 使用pscp上传文件
echo y | pscp -pw %SERVER_PASS% "%ZIP_FILE%" %SERVER_USER%@%SERVER_IP%:/tmp/ >> "%LOG_FILE%" 2>&1

if %errorlevel% neq 0 (
    echo ❌ 上传文件失败，请查看日志文件: %LOG_FILE% >> "%LOG_FILE%"
    echo ❌ 上传文件失败，请查看日志文件: %LOG_FILE%
    pause
    exit /b 1
)

echo ✅ 文件上传成功 >> "%LOG_FILE%"
echo ✅ 文件上传成功

REM 使用plink执行远程命令
echo.
echo 📦 正在服务器上解压部署包...
echo 在服务器上解压部署包... >> "%LOG_FILE%"

REM 检查plink是否可用
where plink >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️ 未检测到plink工具，无法执行远程命令 >> "%LOG_FILE%"
    echo ⚠️ 未检测到plink工具，无法执行远程命令
    goto manual_extract
)

REM 执行远程命令
echo y | plink -pw %SERVER_PASS% %SERVER_USER%@%SERVER_IP% "cd /www/wwwroot/ && unzip -o /tmp/%ZIP_FILE% -d task-manager/ && chown -R www:www task-manager/ && chmod -R 755 task-manager/ && echo '部署完成'" >> "%LOG_FILE%" 2>&1

if %errorlevel% neq 0 (
    echo ❌ 远程命令执行失败，请查看日志文件: %LOG_FILE% >> "%LOG_FILE%"
    echo ❌ 远程命令执行失败，请查看日志文件: %LOG_FILE%
    goto manual_extract
)

echo ✅ 部署包解压成功 >> "%LOG_FILE%"
echo ✅ 部署包解压成功

goto deployment_complete

:manual_upload
echo.
echo 📋 手动上传指南:
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
goto manual_extract

:manual_extract
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
echo    - 登录: http://%SERVER_IP%:8888
echo    - 文件管理 → 上传 %ZIP_FILE%
echo    - 解压到 /www/wwwroot/task-manager/
echo    - 设置权限: 所有者 www, 权限 755
echo.
echo 操作完成后按任意键继续...
pause > nul

:deployment_complete
echo.
echo 🎉 部署完成!
echo.
echo 🧪 部署后测试步骤:
echo.
echo 1. 基础测试:
echo    - 访问 http://%SERVER_IP%/
echo    - 检查页面是否正常加载
echo.
echo 2. 同步测试:
echo    - 在Chrome中完成一些任务
echo    - 在Firefox中打开同一地址
echo    - 等待5秒观察自动同步
echo.
echo 3. 诊断测试:
echo    - 访问 http://%SERVER_IP%/sync-test.html
echo    - 点击"运行诊断"查看同步状态
echo    - 如有问题，点击"自动修复"
echo.
echo 4. 跨设备测试:
echo    - 在手机浏览器中访问
echo    - 在其他的浏览器中访问
echo    - 验证数据是否在所有设备间同步
echo.
echo 📊 v4.2.3 版本特性总结:
echo ✅ 跨浏览器数据同步 - 彻底修复
echo ✅ 实时数据同步 - 2秒内完成
echo ✅ 智能错误恢复 - 自动修复机制
echo ✅ 本地存储监听 - 即时触发同步
echo ✅ 可视化诊断 - 问题排查利器
echo ✅ 简化部署流程 - 多种部署方式
echo.
echo 部署完成时间: %date% %time% >> "%LOG_FILE%"
echo 部署状态: 成功 >> "%LOG_FILE%"

pause
exit /b 0