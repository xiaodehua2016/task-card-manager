#!/bin/bash

# 快速诊断脚本
echo "🔍 宝塔面板部署问题快速诊断..."
echo "=================================="

# 1. 检查Nginx进程
echo "1️⃣ 检查Nginx进程状态："
if pgrep nginx >/dev/null; then
    echo "   ✅ Nginx进程正在运行"
    echo "   📊 进程信息: $(pgrep nginx | wc -l) 个进程"
else
    echo "   ❌ Nginx进程未运行"
    echo "   🔧 建议: 执行 /etc/init.d/nginx start"
fi

echo ""

# 2. 检查端口监听
echo "2️⃣ 检查端口监听状态："
if ss -tlnp | grep -q ":80 "; then
    echo "   ✅ 80端口正在监听"
    echo "   📊 监听详情:"
    ss -tlnp | grep ":80 "
else
    echo "   ❌ 80端口未监听"
    echo "   🔧 建议: 检查Nginx配置和服务状态"
fi

echo ""

# 3. 检查配置文件
echo "3️⃣ 检查配置文件："
VHOST_FILE="/www/server/nginx/conf/vhost/task-manager.conf"
if [ -f "$VHOST_FILE" ]; then
    echo "   ✅ 虚拟主机配置存在"
    echo "   📄 配置摘要:"
    grep -E "(server_name|root|listen)" "$VHOST_FILE" | sed 's/^/      /'
else
    echo "   ❌ 虚拟主机配置不存在"
    echo "   🔧 建议: 重新创建配置文件"
fi

echo ""

# 4. 检查网站文件
echo "4️⃣ 检查网站文件："
WEB_ROOT="/www/wwwroot/task-manager"
if [ -d "$WEB_ROOT" ]; then
    echo "   ✅ 网站目录存在: $WEB_ROOT"
    
    if [ -f "$WEB_ROOT/index.html" ]; then
        echo "   ✅ 主页文件存在"
        echo "   📊 文件大小: $(du -h "$WEB_ROOT/index.html" | cut -f1)"
    else
        echo "   ❌ 主页文件不存在"
        echo "   🔧 建议: 重新解压项目文件"
    fi
    
    echo "   📁 目录内容:"
    ls -la "$WEB_ROOT/" 2>/dev/null | head -5 | sed 's/^/      /'
else
    echo "   ❌ 网站目录不存在"
    echo "   🔧 建议: 创建目录并解压项目文件"
fi

echo ""

# 5. 检查权限
echo "5️⃣ 检查文件权限："
if [ -d "$WEB_ROOT" ]; then
    OWNER=$(ls -ld "$WEB_ROOT" | awk '{print $3":"$4}')
    echo "   📊 目录所有者: $OWNER"
    
    if [ "$OWNER" = "www:www" ]; then
        echo "   ✅ 权限设置正确"
    else
        echo "   ⚠️ 权限可能需要调整"
        echo "   🔧 建议: chown -R www:www $WEB_ROOT"
    fi
else
    echo "   ❌ 无法检查权限（目录不存在）"
fi

echo ""

# 6. 测试本地访问
echo "6️⃣ 测试本地访问："
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ 本地访问正常 (HTTP $HTTP_CODE)"
elif [ "$HTTP_CODE" = "404" ]; then
    echo "   ⚠️ 页面未找到 (HTTP $HTTP_CODE)"
    echo "   🔧 建议: 检查网站文件和配置"
else
    echo "   ❌ 访问异常 (HTTP $HTTP_CODE)"
    echo "   🔧 建议: 检查Nginx配置和服务状态"
fi

echo ""

# 7. 检查日志
echo "7️⃣ 检查最近的错误日志："
if [ -f "/var/log/nginx/error.log" ]; then
    echo "   📄 最近的错误信息:"
    tail -3 /var/log/nginx/error.log 2>/dev/null | sed 's/^/      /' || echo "      无错误信息"
else
    echo "   ℹ️ 错误日志文件不存在"
fi

echo ""
echo "=================================="
echo "🎯 诊断总结："

# 生成建议
ISSUES=0

if ! pgrep nginx >/dev/null; then
    echo "❌ Nginx服务未运行"
    ((ISSUES++))
fi

if ! ss -tlnp | grep -q ":80 "; then
    echo "❌ 80端口未监听"
    ((ISSUES++))
fi

if [ ! -f "$VHOST_FILE" ]; then
    echo "❌ 虚拟主机配置缺失"
    ((ISSUES++))
fi

if [ ! -f "$WEB_ROOT/index.html" ]; then
    echo "❌ 网站文件缺失"
    ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo "✅ 所有检查项目正常"
    echo "🎉 如果仍无法访问，请检查防火墙和安全组设置"
else
    echo "⚠️ 发现 $ISSUES 个问题需要修复"
    echo "🔧 建议执行: /tmp/fix-site-not-found.sh"
fi

echo ""
echo "📞 如需帮助，请提供此诊断报告"