@echo off
chcp 65001 >nul
echo ========================================
echo    小久的任务卡片管理系统 - 配置工具
echo ========================================
echo.

:: 检查Node.js是否安装
echo 🔍 检查Node.js环境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未检测到Node.js环境
    echo.
    echo 可能的原因：
    echo 1. Node.js未安装
    echo 2. 环境变量配置错误
    echo 3. 需要重启计算机
    echo.
    echo 请选择解决方案：
    echo 1. 查看详细安装指南
    echo 2. 下载安装Node.js
    echo 3. 手动配置项目（无需Node.js）
    echo.
    set /p choice="请输入选择 (1, 2 或 3): "
    
    if "%choice%"=="1" (
        echo.
        echo 📖 正在打开安装指南...
        if exist "FIX_NODE_INSTALLATION.md" (
            start notepad "FIX_NODE_INSTALLATION.md"
        ) else (
            echo 请查看 FIX_NODE_INSTALLATION.md 文件获取详细指南
        )
        echo.
        echo 安装完成后请：
        echo 1. 重启计算机
        echo 2. 打开新的命令提示符
        echo 3. 重新运行此脚本
        pause
        exit /b
    ) else if "%choice%"=="2" (
        echo.
        echo 📥 正在打开Node.js下载页面...
        start https://nodejs.org/zh-cn/
        echo.
        echo ⚠️  重要提示：
        echo 1. 下载LTS版本（推荐给大多数用户）
        echo 2. 安装时确保勾选 "Add to PATH" 选项
        echo 3. 安装完成后必须重启计算机
        echo 4. 重启后重新运行此脚本
        pause
        exit /b
    ) else if "%choice%"=="3" (
        goto manual_setup
    ) else (
        echo 无效选择，退出程序
        pause
        exit /b
    )
)

:: 检查npm是否可用
echo 🔍 检查npm环境...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm命令无法使用
    echo.
    echo 这通常表示Node.js安装不完整，请：
    echo 1. 重新安装Node.js
    echo 2. 确保安装时勾选了 "Add to PATH"
    echo 3. 重启计算机后重试
    echo.
    echo 是否查看详细修复指南？(y/n)
    set /p show_guide=""
    if /i "%show_guide%"=="y" (
        if exist "FIX_NODE_INSTALLATION.md" (
            start notepad "FIX_NODE_INSTALLATION.md"
        )
    )
    echo.
    echo 或者选择手动配置（无需Node.js）
    set /p manual_choice="是否继续手动配置？(y/n): "
    if /i "%manual_choice%"=="y" (
        goto manual_setup
    ) else (
        pause
        exit /b
    )
)

echo ✅ 检测到Node.js环境
node --version
echo.

:: 检查配置文件是否存在
if exist "config\supabase.js" (
    echo ⚠️  配置文件已存在
    set /p overwrite="是否覆盖现有配置？(y/n): "
    if /i not "%overwrite%"=="y" (
        echo 配置已取消
        pause
        exit /b
    )
)

echo.
echo 📋 请输入Supabase配置信息：
echo.
set /p supabase_url="Supabase项目URL (https://xxx.supabase.co): "
set /p supabase_key="Supabase API密钥: "

if "%supabase_url%"=="" (
    echo ❌ URL不能为空
    pause
    exit /b
)

if "%supabase_key%"=="" (
    echo ❌ API密钥不能为空
    pause
    exit /b
)

echo.
echo 🔧 正在配置项目...
node deploy-setup.js setup "%supabase_url%" "%supabase_key%"

if %errorlevel% equ 0 (
    echo.
    echo ✅ 配置完成！
    echo.
    echo 📱 测试步骤：
    echo 1. 运行: npx serve . -p 8000
    echo 2. 浏览器访问: http://localhost:8000
    echo 3. 在不同设备上测试数据同步
    echo.
) else (
    echo ❌ 配置失败，请检查输入信息
)

goto end

:manual_setup
echo.
echo 📝 手动配置步骤：
echo.
echo 1. 复制配置文件模板
if not exist "config" mkdir config
copy "config\supabase.example.js" "config\supabase.js" >nul 2>&1

echo 2. 请手动编辑 config\supabase.js 文件
echo    - 将 'your-project-id' 替换为您的项目ID
echo    - 将 'your-anon-key-here' 替换为您的API密钥
echo.
echo 3. 编辑完成后，双击 index.html 即可使用
echo.

set /p open_config="是否现在打开配置文件进行编辑？(y/n): "
if /i "%open_config%"=="y" (
    notepad "config\supabase.js"
)

:end
echo.
echo 📚 更多帮助：
echo - 快速开始: QUICK_START.md
echo - Node.js安装: NODE_SETUP.md
echo - 故障排除: TROUBLESHOOTING.md
echo.
pause