@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ====================================================
:: 服务器部署脚本 v4.3.6.2
:: 功能：部署完全独立版本到115服务器
:: ====================================================

set "VERSION=4.3.6.2"
set "LOG_FILE=deploy\server-deploy-v%VERSION%.log"
set "DEPLOY_PACKAGE=task-manager-v%VERSION%.zip"

:: 创建日志目录
if not exist "deploy" mkdir "deploy"

:: 开始记录日志
echo [%date% %time%] 开始服务器部署 v%VERSION% > "%LOG_FILE%"

cls
echo.
echo =======================================
echo   服务器部署脚本 v%VERSION%
echo =======================================
echo.
echo 🔧 修复内容：
echo ✅ 完全独立的JavaScript架构
echo ✅ 彻底修复任务显示问题
echo ✅ 彻底修复按钮响应问题
echo ✅ 移除所有依赖冲突
echo ✅ 优化错误处理和调试
echo.

echo [1/6] 检查部署包是否存在...
echo [%date% %time%] 检查部署包 >> "%LOG_FILE%"

if not exist "%DEPLOY_PACKAGE%" (
    echo ❌ 错误：部署包 %DEPLOY_PACKAGE% 不存在
    echo [%date% %time%] 错误：部署包不存在 >> "%LOG_FILE%"
    echo.
    echo 💡 请先运行 deploy-v%VERSION%.bat 创建部署包
    pause
    exit /b 1
)

echo ✅ 部署包存在：%DEPLOY_PACKAGE%
echo [%date% %time%] 部署包检查通过 >> "%LOG_FILE%"

echo.
echo [2/6] 生成服务器部署命令...
echo [%date% %time%] 生成服务器部署命令 >> "%LOG_FILE%"

:: 创建服务器部署命令文件
echo :: 115服务器部署命令 v%VERSION% > server_commands_v%VERSION%.bat
echo :: 完全独立版本 - 彻底修复所有问题 >> server_commands_v%VERSION%.bat
echo. >> server_commands_v%VERSION%.bat
echo :: ============================================ >> server_commands_v%VERSION%.bat
echo :: 第一步：上传部署包到服务器 >> server_commands_v%VERSION%.bat
echo :: ============================================ >> server_commands_v%VERSION%.bat
echo scp %DEPLOY_PACKAGE% root@115.159.5.111:/www/wwwroot/ >> server_commands_v%VERSION%.bat
echo. >> server_commands_v%VERSION%.bat
echo :: ============================================ >> server_commands_v%VERSION%.bat
echo :: 第二步：SSH登录服务器 >> server_commands_v%VERSION%.bat
echo :: ============================================ >> server_commands_v%VERSION%.bat
echo ssh root@115.159.5.111 >> server_commands_v%VERSION%.bat
echo. >> server_commands_v%VERSION%.bat
echo :: ============================================ >> server_commands_v%VERSION%.bat
echo :: 第三步：在服务器上执行以下命令 >> server_commands_v%VERSION%.bat
echo :: ============================================ >> server_commands_v%VERSION%.bat
echo :: >> server_commands_v%VERSION%.bat
echo :: # 进入网站根目录 >> server_commands_v%VERSION%.bat
echo :: cd /www/wwwroot/ >> server_commands_v%VERSION%.bat
echo :: >> server_commands_v%VERSION%.bat
echo :: # 备份现有版本（可选） >> server_commands_v%VERSION%.bat
echo :: mv task-manager task-manager-backup-$(date +%%Y%%m%%d-%%H%%M%%S) >> server_commands_v%VERSION%.bat
echo :: >> server_commands_v%VERSION%.bat
echo :: # 解压新版本 >> server_commands_v%VERSION%.bat
echo :: unzip -o %DEPLOY_PACKAGE% -d task-manager/ >> server_commands_v%VERSION%.bat
echo :: >> server_commands_v%VERSION%.bat
echo :: # 设置文件权限 >> server_commands_v%VERSION%.bat
echo :: chown -R www:www task-manager/ >> server_commands_v%VERSION%.bat
echo :: chmod -R 755 task-manager/ >> server_commands_v%VERSION%.bat
echo :: chmod -R 644 task-manager/data/ >> server_commands_v%VERSION%.bat
echo :: >> server_commands_v%VERSION%.bat
echo :: # 重启服务 >> server_commands_v%VERSION%.bat
echo :: systemctl restart nginx >> server_commands_v%VERSION%.bat
echo :: systemctl restart php-fpm >> server_commands_v%VERSION%.bat
echo :: >> server_commands_v%VERSION%.bat
echo :: # 验证部署 >> server_commands_v%VERSION%.bat
echo :: echo "部署完成！访问: http://115.159.5.111/" >> server_commands_v%VERSION%.bat
echo :: curl -I http://115.159.5.111/ >> server_commands_v%VERSION%.bat

echo ✅ 服务器部署命令文件创建成功
echo [%date% %time%] 服务器部署命令创建成功 >> "%LOG_FILE%"

echo.
echo [3/6] 生成快速部署脚本...
echo [%date% %time%] 生成快速部署脚本 >> "%LOG_FILE%"

:: 创建快速部署脚本（Linux shell脚本）
echo #!/bin/bash > quick_deploy_v%VERSION%.sh
echo # 快速部署脚本 v%VERSION% >> quick_deploy_v%VERSION%.sh
echo # 完全独立版本 - 彻底修复所有问题 >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo echo "开始部署任务管理系统 v%VERSION%..." >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 进入网站根目录 >> quick_deploy_v%VERSION%.sh
echo cd /www/wwwroot/ >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 备份现有版本 >> quick_deploy_v%VERSION%.sh
echo if [ -d "task-manager" ]; then >> quick_deploy_v%VERSION%.sh
echo     echo "备份现有版本..." >> quick_deploy_v%VERSION%.sh
echo     mv task-manager task-manager-backup-$(date +%%Y%%m%%d-%%H%%M%%S) >> quick_deploy_v%VERSION%.sh
echo fi >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 解压新版本 >> quick_deploy_v%VERSION%.sh
echo echo "解压部署包..." >> quick_deploy_v%VERSION%.sh
echo unzip -o %DEPLOY_PACKAGE% -d task-manager/ >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 设置文件权限 >> quick_deploy_v%VERSION%.sh
echo echo "设置文件权限..." >> quick_deploy_v%VERSION%.sh
echo chown -R www:www task-manager/ >> quick_deploy_v%VERSION%.sh
echo chmod -R 755 task-manager/ >> quick_deploy_v%VERSION%.sh
echo chmod -R 644 task-manager/data/ >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 重启服务 >> quick_deploy_v%VERSION%.sh
echo echo "重启服务..." >> quick_deploy_v%VERSION%.sh
echo systemctl restart nginx >> quick_deploy_v%VERSION%.sh
echo systemctl restart php-fpm >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo # 验证部署 >> quick_deploy_v%VERSION%.sh
echo echo "验证部署..." >> quick_deploy_v%VERSION%.sh
echo curl -I http://115.159.5.111/ >> quick_deploy_v%VERSION%.sh
echo. >> quick_deploy_v%VERSION%.sh
echo echo "✅ 部署完成！访问: http://115.159.5.111/" >> quick_deploy_v%VERSION%.sh

echo ✅ 快速部署脚本创建成功
echo [%date% %time%] 快速部署脚本创建成功 >> "%LOG_FILE%"

echo.
echo [4/6] 生成验证测试脚本...
echo [%date% %time%] 生成验证测试脚本 >> "%LOG_FILE%"

:: 创建验证测试脚本
echo @echo off > test_deployment_v%VERSION%.bat
echo echo 部署验证测试 v%VERSION% >> test_deployment_v%VERSION%.bat
echo echo ========================= >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 🧪 请按以下步骤验证部署： >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 1. 基础访问测试： >> test_deployment_v%VERSION%.bat
echo echo    访问: http://115.159.5.111/ >> test_deployment_v%VERSION%.bat
echo echo    ✓ 页面能正常加载 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 显示版本号 v%VERSION% >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 2. 任务显示测试： >> test_deployment_v%VERSION%.bat
echo echo    ✓ 显示8个默认任务 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 任务卡片布局正常 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 进度条显示0/8 >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 3. 按钮响应测试： >> test_deployment_v%VERSION%.bat
echo echo    ✓ 底部5个按钮都能点击 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 任务卡片上的完成按钮能点击 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 点击完成按钮后状态正确切换 >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 4. 浏览器兼容性测试： >> test_deployment_v%VERSION%.bat
echo echo    ✓ Chrome浏览器正常工作 >> test_deployment_v%VERSION%.bat
echo echo    ✓ Edge浏览器正常工作 >> test_deployment_v%VERSION%.bat
echo echo    ✓ Safari浏览器正常工作（如有） >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 5. 缓存清除测试： >> test_deployment_v%VERSION%.bat
echo echo    ✓ 清除浏览器缓存后重新访问 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 仍能正常显示8个默认任务 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 所有功能仍然正常 >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 6. 移动端测试： >> test_deployment_v%VERSION%.bat
echo echo    ✓ 手机浏览器能正常访问 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 触摸操作响应正常 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 界面适配移动端 >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 7. 控制台检查： >> test_deployment_v%VERSION%.bat
echo echo    ✓ 按F12打开开发者工具 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 控制台无JavaScript错误 >> test_deployment_v%VERSION%.bat
echo echo    ✓ 能看到初始化日志信息 >> test_deployment_v%VERSION%.bat
echo echo. >> test_deployment_v%VERSION%.bat
echo echo 如果所有测试都通过，说明v%VERSION%部署成功！ >> test_deployment_v%VERSION%.bat
echo echo 问题已彻底解决！ >> test_deployment_v%VERSION%.bat
echo pause >> test_deployment_v%VERSION%.bat

echo ✅ 验证测试脚本创建成功
echo [%date% %time%] 验证测试脚本创建成功 >> "%LOG_FILE%"

echo.
echo [5/6] 生成故障排除指南...
echo [%date% %time%] 生成故障排除指南 >> "%LOG_FILE%"

:: 创建故障排除指南
echo 故障排除指南 v%VERSION% > troubleshooting_v%VERSION%.txt
echo ======================= >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 如果部署后仍有问题，请按以下步骤排查： >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 1. 检查文件是否正确上传： >> troubleshooting_v%VERSION%.txt
echo    ls -la /www/wwwroot/task-manager/ >> troubleshooting_v%VERSION%.txt
echo    # 应该看到 index.html, js/, css/, api/ 等目录 >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 2. 检查文件权限： >> troubleshooting_v%VERSION%.txt
echo    ls -la /www/wwwroot/task-manager/js/main.js >> troubleshooting_v%VERSION%.txt
echo    # 应该显示 -rw-r--r-- www www >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 3. 检查Nginx配置： >> troubleshooting_v%VERSION%.txt
echo    nginx -t >> troubleshooting_v%VERSION%.txt
echo    # 应该显示 syntax is ok >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 4. 检查Nginx错误日志： >> troubleshooting_v%VERSION%.txt
echo    tail -f /var/log/nginx/error.log >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 5. 检查PHP错误日志： >> troubleshooting_v%VERSION%.txt
echo    tail -f /var/log/php-fpm/error.log >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 6. 测试API接口： >> troubleshooting_v%VERSION%.txt
echo    curl http://115.159.5.111/api/data-sync.php >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 7. 检查JavaScript加载： >> troubleshooting_v%VERSION%.txt
echo    curl http://115.159.5.111/js/main.js >> troubleshooting_v%VERSION%.txt
echo    # 应该返回JavaScript代码内容 >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt
echo 8. 强制刷新浏览器缓存： >> troubleshooting_v%VERSION%.txt
echo    Ctrl+F5 (Windows) 或 Cmd+Shift+R (Mac) >> troubleshooting_v%VERSION%.txt
echo. >> troubleshooting_v%VERSION%.txt

echo ✅ 故障排除指南创建成功
echo [%date% %time%] 故障排除指南创建成功 >> "%LOG_FILE%"

echo.
echo [6/6] 生成部署总结...
echo [%date% %time%] 生成部署总结 >> "%LOG_FILE%"

echo.
echo ✅ 服务器部署准备完成！
echo [%date% %time%] 服务器部署准备完成 >> "%LOG_FILE%"

echo.
echo 📦 生成的文件：
echo ✅ %DEPLOY_PACKAGE% - 部署包
echo ✅ server_commands_v%VERSION%.bat - 服务器命令
echo ✅ quick_deploy_v%VERSION%.sh - 快速部署脚本
echo ✅ test_deployment_v%VERSION%.bat - 验证测试脚本
echo ✅ troubleshooting_v%VERSION%.txt - 故障排除指南
echo ✅ %LOG_FILE% - 操作日志
echo.

echo 🚀 部署步骤：
echo.
echo 1️⃣ 上传部署包：
echo    scp %DEPLOY_PACKAGE% root@115.159.5.111:/www/wwwroot/
echo.
echo 2️⃣ SSH登录服务器：
echo    ssh root@115.159.5.111
echo.
echo 3️⃣ 执行快速部署：
echo    chmod +x quick_deploy_v%VERSION%.sh
echo    ./quick_deploy_v%VERSION%.sh
echo.
echo 4️⃣ 验证部署：
echo    运行 test_deployment_v%VERSION%.bat
echo.

echo 🎯 v%VERSION% 特点：
echo ✅ 完全独立的JavaScript架构
echo ✅ 无任何外部依赖冲突
echo ✅ 彻底解决任务显示问题
echo ✅ 彻底解决按钮响应问题
echo ✅ 增强的错误处理和调试
echo ✅ 支持所有主流浏览器
echo ✅ 完美支持移动端
echo.

echo 💡 如果部署后仍有问题：
echo 1. 查看 troubleshooting_v%VERSION%.txt
echo 2. 检查控制台错误信息
echo 3. 确认所有文件都已正确上传
echo 4. 验证文件权限设置正确
echo.

pause