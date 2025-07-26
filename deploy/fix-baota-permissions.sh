#!/bin/bash

# 宝塔面板权限修复脚本
# 专门处理.user.ini文件权限问题

WEB_ROOT="/www/wwwroot/task-manager"
WEB_USER="www"

echo "🔧 宝塔面板权限修复工具"
echo "📁 目标目录: $WEB_ROOT"
echo "👤 目标用户: $WEB_USER"
echo ""

# 检查目录是否存在
if [ ! -d "$WEB_ROOT" ]; then
    echo "❌ 目录不存在: $WEB_ROOT"
    exit 1
fi

# 检查用户是否存在
if ! id $WEB_USER >/dev/null 2>&1; then
    echo "❌ 用户不存在: $WEB_USER"
    echo "💡 尝试使用其他用户..."
    if id nginx >/dev/null 2>&1; then
        WEB_USER="nginx"
    elif id www-data >/dev/null 2>&1; then
        WEB_USER="www-data"
    else
        WEB_USER="nobody"
    fi
    echo "✅ 使用用户: $WEB_USER"
fi

echo "🔍 检查.user.ini文件..."
if [ -f "$WEB_ROOT/.user.ini" ]; then
    echo "✅ 发现.user.ini文件"
    
    # 显示当前属性
    echo "📊 当前文件属性:"
    lsattr "$WEB_ROOT/.user.ini" 2>/dev/null || echo "  无法获取文件属性"
    ls -la "$WEB_ROOT/.user.ini"
    
    echo ""
    echo "🔧 开始修复权限..."
    
    # 步骤1: 解除不可变属性
    echo "1️⃣ 解除.user.ini不可变属性..."
    chattr -i "$WEB_ROOT/.user.ini" 2>/dev/null && echo "  ✅ 不可变属性已解除" || echo "  ℹ️ 文件无不可变属性"
    
    # 步骤2: 修改其他文件权限
    echo "2️⃣ 设置其他文件权限..."
    find "$WEB_ROOT" -type f ! -name '.user.ini' -exec chown $WEB_USER:$WEB_USER {} \; 2>/dev/null
    find "$WEB_ROOT" -type d -exec chown $WEB_USER:$WEB_USER {} \; 2>/dev/null
    echo "  ✅ 其他文件权限设置完成"
    
    # 步骤3: 修改.user.ini权限
    echo "3️⃣ 设置.user.ini文件权限..."
    if chown $WEB_USER:$WEB_USER "$WEB_ROOT/.user.ini" 2>/dev/null; then
        echo "  ✅ .user.ini权限设置成功"
    else
        echo "  ⚠️ .user.ini权限设置失败，但不影响网站运行"
    fi
    
    # 步骤4: 恢复不可变属性（可选）
    echo "4️⃣ 恢复.user.ini不可变属性..."
    if chattr +i "$WEB_ROOT/.user.ini" 2>/dev/null; then
        echo "  ✅ 不可变属性已恢复"
    else
        echo "  ℹ️ 未设置不可变属性"
    fi
    
else
    echo "ℹ️ 未发现.user.ini文件，执行标准权限设置..."
    chown -R $WEB_USER:$WEB_USER $WEB_ROOT
    echo "✅ 标准权限设置完成"
fi

# 设置文件权限
echo ""
echo "📝 设置文件和目录权限..."
find "$WEB_ROOT" -type d -exec chmod 755 {} \; 2>/dev/null
find "$WEB_ROOT" -type f -exec chmod 644 {} \; 2>/dev/null
echo "✅ 文件权限设置完成"

# 显示结果
echo ""
echo "📊 权限修复结果:"
echo "  目录所有者: $(ls -ld $WEB_ROOT | awk '{print $3":"$4}')"
echo "  文件总数: $(find $WEB_ROOT -type f | wc -l)"
echo "  目录总数: $(find $WEB_ROOT -type d | wc -l)"

if [ -f "$WEB_ROOT/.user.ini" ]; then
    echo "  .user.ini状态: $(ls -la $WEB_ROOT/.user.ini | awk '{print $1" "$3":"$4}')"
    echo "  .user.ini属性: $(lsattr $WEB_ROOT/.user.ini 2>/dev/null | awk '{print $1}' || echo '无法获取')"
fi

echo ""
echo "🎉 权限修复完成！"
echo ""
echo "🔧 如果仍有问题，可以尝试："
echo "  1. 重启Nginx: /etc/init.d/nginx restart"
echo "  2. 检查Nginx状态: /etc/init.d/nginx status"
echo "  3. 测试网站访问: curl -I http://127.0.0.1"
echo "  4. 查看错误日志: tail -f /var/log/nginx/error.log"