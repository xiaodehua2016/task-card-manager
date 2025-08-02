@echo off
chcp 65001 >nul
echo 🔍 开始验证数据同步修复...
echo.

set SERVER_IP=115.159.5.111
set API_ENDPOINT=http://%SERVER_IP%/api/data-sync.php

echo 📋 验证清单:
echo 1. 测试API连接
echo 2. 验证数据读写功能
echo 3. 检查跨浏览器同步
echo.

echo 🔍 1. 测试API连接...
curl -s -w "HTTP状态码: %%{http_code}\n" -o api_test.json "%API_ENDPOINT%"
if %errorlevel% equ 0 (
    echo ✅ API连接成功
    type api_test.json
) else (
    echo ❌ API连接失败
    goto :error
)
echo.

echo 🔍 2. 测试数据保存...
echo {"version":"4.2.1","lastUpdateTime":1234567890000,"username":"测试用户","tasks":[],"taskTemplates":{"daily":[]},"dailyTasks":{},"completionHistory":{}} > test_data.json

curl -s -w "HTTP状态码: %%{http_code}\n" -X POST -H "Content-Type: application/json" -d @test_data.json -o post_result.json "%API_ENDPOINT%"
if %errorlevel% equ 0 (
    echo ✅ 数据保存测试完成
    type post_result.json
) else (
    echo ❌ 数据保存失败
)
echo.

echo 🔍 3. 测试数据读取...
timeout /t 2 /nobreak >nul
curl -s -w "HTTP状态码: %%{http_code}\n" -o get_result.json "%API_ENDPOINT%?t=%random%"
if %errorlevel% equ 0 (
    echo ✅ 数据读取测试完成
    type get_result.json
) else (
    echo ❌ 数据读取失败
)
echo.

echo 📊 验证报告:
echo ==================
findstr /C:"测试用户" get_result.json >nul
if %errorlevel% equ 0 (
    echo ✅ 数据同步验证成功
) else (
    echo ⚠️ 数据同步可能有问题
)
echo.

echo 🔗 测试链接:
echo 主页面: http://%SERVER_IP%/
echo 同步测试: http://%SERVER_IP%/sync-test.html
echo API测试: %API_ENDPOINT%
echo.

echo 🌐 浏览器测试步骤:
echo 1. 在Chrome中打开: http://%SERVER_IP%/
echo 2. 添加一些任务并完成
echo 3. 在Firefox/Edge中打开同一地址
echo 4. 检查任务是否同步显示
echo 5. 在不同浏览器中交替操作，验证实时同步
echo.

echo ✅ 验证脚本执行完成
echo 💡 如果数据能在不同浏览器间同步，说明问题已修复
echo.

pause
goto :end

:error
echo ❌ 验证过程中出现错误
pause

:end
del /f /q api_test.json test_data.json post_result.json get_result.json 2>nul