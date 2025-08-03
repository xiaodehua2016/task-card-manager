@echo off
chcp 65001 > nul
setlocal

:: ==================================================
:: Git 连接诊断脚本
:: 功能: 帮助诊断连接到 GitHub 失败的问题
:: ==================================================

echo.
echo =======================================
echo   Git 连接诊断脚本
echo =======================================
echo.
echo 本脚本将执行一系列网络检查来帮助定位问题。
echo.

echo [1/5] 正在测试与 github.com 的连通性 (ping)...
ping github.com -n 4
echo.

echo [2/5] 正在追踪到 github.com 的网络路径 (tracert)...
echo 这可能需要一些时间...
tracert github.com
echo.

echo [3/5] 正在检查 DNS 解析...
nslookup github.com
echo.

echo [4/5] 正在检查 Git 代理设置...
echo   - 全局代理:
git config --global http.proxy
echo   - 本地代理 (如果设置了):
git config --local http.proxy
echo.

echo [5/5] 正在尝试通过 curl 连接到端口 443...
powershell -Command "Invoke-WebRequest -Uri https://github.com -UseBasicParsing -TimeoutSec 10"
if %errorlevel% equ 0 (
    echo   - 成功连接到 https://github.com
) else (
    echo   - [失败] 无法连接到 https://github.com
)
echo.

echo =======================================
echo   诊断完成
echo =======================================
echo.
echo   请检查以上输出:
echo   - 如果 ping 和 tracert 失败，说明存在网络连接问题 (可能是防火墙或网络中断)。
echo   - 如果 nslookup 失败，说明存在 DNS 解析问题。
echo   - 如果 Git 代理设置有值，请确认代理服务器是否正常工作。
echo   - 如果 curl 连接失败，说明无法访问端口 443。
echo.
echo   解决方案建议:
echo   1. 检查您的网络连接、防火墙和代理设置。
echo   2. 尝试切换网络环境 (例如使用手机热点)。
echo   3. 尝试改用 SSH 协议进行推送 (请参考 deploy/GIT_TROUBLESHOOTING.md)。
echo.
pause