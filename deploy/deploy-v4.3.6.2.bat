@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ====================================================
:: 部署脚本 v4.3.6.2
:: 功能：创建完全独立版本的部署包
:: ====================================================

set "VERSION=4.3.6.2"
set "LOG_FILE=deploy\deploy-v%VERSION%.log"
set "DEPLOY_PACKAGE=task-manager-v%VERSION%.zip"

:: 创建日志目录
if not exist "deploy" mkdir "deploy"

:: 开始记录日志
echo [%date% %time%] 开始创建部署包 v%VERSION% > "%LOG_FILE%"

cls
echo.
echo =======================================
echo   部署脚本 v%VERSION%
echo =======================================
echo.
echo 🔧 修复内容：
echo ✅ 完全独立的JavaScript架构
echo ✅ 彻底修复任务显示问题
echo ✅ 彻底修复按钮响应问题
echo ✅ 移除所有依赖冲突
echo ✅ 优化错误处理和调试
echo.

echo [1/5] 清理旧的部署包...
echo [%date% %time%] 清理旧部署包 >> "%LOG_FILE%"

if exist "%DEPLOY_PACKAGE%" (
    del "%DEPLOY_PACKAGE%"
    echo ✅ 已删除旧的部署包
    echo [%date% %time%] 删除旧部署包成功 >> "%LOG_FILE%"
)

echo.
echo [2/5] 验证核心文件...
echo [%date% %time%] 验证核心文件 >> "%LOG_FILE%"

:: 检查必要文件是否存在
set "REQUIRED_FILES=index.html manifest.json css js api data"
set "MISSING_FILES="

for %%f in (%REQUIRED_FILES%) do (
    if not exist "%%f" (
        set "MISSING_FILES=!MISSING_FILES! %%f"
    )
)

if not "!MISSING_FILES!"=="" (
    echo ❌ 错误：缺少必要文件: !MISSING_FILES!
    echo [%date% %time%] 错误：缺少文件 !MISSING_FILES! >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: 特别检查核心JavaScript文件
if not exist "js\main.js" (
    echo ❌ 错误：缺少核心文件 js\main.js
    echo [%date% %time%] 错误：缺少js\main.js >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo ✅ 所有核心文件验证通过
echo [%date% %time%] 核心文件验证通过 >> "%LOG_FILE%"

echo.
echo [3/5] 创建部署包...
echo [%date% %time%] 开始创建部署包 >> "%LOG_FILE%"

:: 检查PowerShell是否可用
powershell -Command "Get-Command Compress-Archive" >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：PowerShell Compress-Archive 不可用
    echo [%date% %time%] 错误：PowerShell不可用 >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: 创建部署包（只包含必要文件）
powershell -Command "Compress-Archive -Path 'index.html','manifest.json','css','js\main.js','js\storage.js','js\simple-storage.js','api','data','images' -DestinationPath '%DEPLOY_PACKAGE%' -Force"
if errorlevel 1 (
    echo ❌ 错误：创建部署包失败
    echo [%date% %time%] 错误：创建部署包失败 >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo ✅ 部署包创建成功：%DEPLOY_PACKAGE%
echo [%date% %time%] 部署包创建成功 >> "%LOG_FILE%"

echo.
echo [4/5] 生成部署信息...
echo [%date% %time%] 生成部署信息 >> "%LOG_FILE%"

:: 创建部署信息文件
echo 任务管理系统 v%VERSION% 部署信息 > DEPLOY_INFO_v%VERSION%.txt
echo ================================== >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt
echo 版本：v%VERSION% >> DEPLOY_INFO_v%VERSION%.txt
echo 构建时间：%date% %time% >> DEPLOY_INFO_v%VERSION%.txt
echo 部署包：%DEPLOY_PACKAGE% >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt
echo 🔧 修复内容： >> DEPLOY_INFO_v%VERSION%.txt
echo - 完全独立的JavaScript架构，无依赖冲突 >> DEPLOY_INFO_v%VERSION%.txt
echo - 彻底修复今日任务未显示问题 >> DEPLOY_INFO_v%VERSION%.txt
echo - 彻底修复底部按钮无法点击问题 >> DEPLOY_INFO_v%VERSION%.txt
echo - 优化数据初始化和错误处理逻辑 >> DEPLOY_INFO_v%VERSION%.txt
echo - 增强调试功能和日志记录 >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt
echo 📦 包含文件： >> DEPLOY_INFO_v%VERSION%.txt
echo - index.html (主页面) >> DEPLOY_INFO_v%VERSION%.txt
echo - js/main.js (核心逻辑，完全独立) >> DEPLOY_INFO_v%VERSION%.txt
echo - css/ (样式文件) >> DEPLOY_INFO_v%VERSION%.txt
echo - api/ (后端接口) >> DEPLOY_INFO_v%VERSION%.txt
echo - data/ (数据目录) >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt
echo 🎯 部署目标：115.159.5.111 >> DEPLOY_INFO_v%VERSION%.txt
echo 📁 部署路径：/www/wwwroot/task-manager/ >> DEPLOY_INFO_v%VERSION%.txt
echo. >> DEPLOY_INFO_v%VERSION%.txt

echo ✅ 部署信息文件创建成功
echo [%date% %time%] 部署信息文件创建成功 >> "%LOG_FILE%"

echo.
echo [5/5] 生成验证脚本...
echo [%date% %time%] 生成验证脚本 >> "%LOG_FILE%"

:: 创建验证脚本
echo @echo off > verify_deployment_v%VERSION%.bat
echo echo 验证部署 v%VERSION% >> verify_deployment_v%VERSION%.bat
echo echo ===================== >> verify_deployment_v%VERSION%.bat
echo echo. >> verify_deployment_v%VERSION%.bat
echo echo 请在浏览器中测试以下功能： >> verify_deployment_v%VERSION%.bat
echo echo. >> verify_deployment_v%VERSION%.bat
echo echo 1. 访问主页：http://115.159.5.111/ >> verify_deployment_v%VERSION%.bat
echo echo 2. 检查是否显示8个默认任务 >> verify_deployment_v%VERSION%.bat
echo echo 3. 测试底部5个按钮是否能点击 >> verify_deployment_v%VERSION%.bat
echo echo 4. 测试任务卡片上的完成按钮 >> verify_deployment_v%VERSION%.bat
echo echo 5. 清除浏览器缓存后重新测试 >> verify_deployment_v%VERSION%.bat
echo echo 6. 在Chrome和Edge浏览器中都测试 >> verify_deployment_v%VERSION%.bat
echo echo 7. 在手机端测试触摸操作 >> verify_deployment_v%VERSION%.bat
echo echo. >> verify_deployment_v%VERSION%.bat
echo echo 如果所有功能都正常，部署成功！ >> verify_deployment_v%VERSION%.bat
echo pause >> verify_deployment_v%VERSION%.bat

echo ✅ 验证脚本创建成功
echo [%date% %time%] 验证脚本创建成功 >> "%LOG_FILE%"

echo.
echo ✅ 部署包创建完成！
echo [%date% %time%] 部署包创建完成 >> "%LOG_FILE%"

echo.
echo 📦 生成的文件：
echo ✅ %DEPLOY_PACKAGE% - 部署包（完全独立版本）
echo ✅ DEPLOY_INFO_v%VERSION%.txt - 部署信息
echo ✅ verify_deployment_v%VERSION%.bat - 验证脚本
echo ✅ %LOG_FILE% - 操作日志
echo.

echo 🚀 下一步操作：
echo.
echo 1. 上传到115服务器：
echo    scp %DEPLOY_PACKAGE% root@115.159.5.111:/www/wwwroot/
echo.
echo 2. SSH登录服务器：
echo    ssh root@115.159.5.111
echo.
echo 3. 在服务器执行：
echo    cd /www/wwwroot/
echo    unzip -o %DEPLOY_PACKAGE% -d task-manager/
echo    chown -R www:www task-manager/
echo    chmod -R 755 task-manager/
echo    systemctl restart nginx
echo.
echo 4. 运行验证脚本：
echo    verify_deployment_v%VERSION%.bat
echo.

echo 💡 v%VERSION% 特点：
echo ✅ 完全独立的JavaScript架构
echo ✅ 无任何外部依赖
echo ✅ 彻底解决任务显示问题
echo ✅ 彻底解决按钮响应问题
echo ✅ 增强的错误处理和调试
echo.

pause