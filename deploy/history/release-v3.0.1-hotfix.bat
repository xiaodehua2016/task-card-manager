@echo off
chcp 65001 >nul
echo.
echo ================================
echo 任务卡片管理系统 v3.0.1 热修复发布
echo ================================
echo.

echo 🔧 发布v3.0.1热修复版本...
echo.
echo 📋 修复内容：
echo    ✅ 修复Supabase配置文件缺失问题
echo    ✅ 修复.gitignore错误配置
echo    ✅ 添加缺失的图标文件
echo    ✅ 修复资源加载404错误
echo.

REM 检查Git状态
git status >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：当前目录不是Git仓库
    pause
    exit /b 1
)

echo 📤 提交修复文件...
git add .
git commit -m "热修复 v3.0.1 - 修复配置文件缺失和资源加载问题

修复内容：
- 修复 .gitignore 错误排除 config/supabase.js
- 添加正确的 Supabase 配置文件
- 创建 SVG 图标文件替代缺失的 PNG
- 更新 HTML 文件中的图标引用
- 确保所有资源文件正确部署"

echo 🏷️  创建热修复标签...
git tag -a v3.0.1 -m "热修复版本 v3.0.1

修复问题：
- Supabase配置文件缺失导致云端同步无法工作
- 图标文件404错误
- .gitignore配置错误

现在v3.0的所有功能应该正常工作：
- 多设备云端同步 ✅
- 离线使用支持 ✅
- 实时数据同步 ✅"

echo 📤 推送修复到远程仓库...
git push origin main
git push origin v3.0.1

echo.
echo 🎉 热修复版本v3.0.1发布完成！
echo.
echo 📊 修复信息：
echo    版本号: v3.0.1
echo    修复时间: %date% %time%
echo    修复类型: 关键功能修复
echo.
echo 🔗 验证链接：
echo    项目地址: https://xiaodehua2016.github.io/task-card-manager/
echo    配置文件: https://xiaodehua2016.github.io/task-card-manager/config/supabase.js
echo    图标文件: https://xiaodehua2016.github.io/task-card-manager/icon-192.svg
echo.
echo 🔍 验证步骤：
echo    1. 等待GitHub Actions部署完成（2-3分钟）
echo    2. 访问项目网址，按F12打开控制台
echo    3. 应该看到 "✅ Supabase配置已加载"
echo    4. 测试多设备同步功能
echo.
echo ✅ 热修复发布完成！现在v3.0的所有功能应该正常工作了。
echo.
pause