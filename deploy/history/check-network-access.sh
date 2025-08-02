#!/bin/bash

# 网络访问检查脚本
echo "🌐 检查网络访问配置..."
echo "=================================="

# 1. 检查防火墙状态
echo "1️⃣ 检查系统防火墙："
if command -v firewall-cmd >/dev/null 2>&1; then
    echo "   📊 防火墙状态: $(firewall-cmd --state 2>/dev/null || echo '未知')"
    echo "   📋 开放的服务:"
    firewall-cmd --list-services 2>/dev/null | sed 's/^/      /' || echo "      无法获取信息"
    echo "   📋 开放的端口:"
    firewall-cmd --list-ports 2>/dev/null | sed 's/^/      /' || echo "      无端口开放"
    
    # 检查80端口是否开放
    if firewall-cmd --list-services 2>/dev/null | grep -q http; then
        echo "   ✅ HTTP服务已开放"
    else
        echo "   ⚠️ HTTP服务未开放"
        echo "   🔧 执行修复: firewall-cmd --permanent --add-service=http && firewall-cmd --reload"
    fi
else
    echo "   ℹ️ 系统未使用firewalld"
fi

echo ""

# 2. 检查iptables规则
echo "2️⃣ 检查iptables规则："
if command -v iptables >/dev/null 2>&1; then
    echo "   📋 当前规则摘要:"
    iptables -L INPUT -n | grep -E "(80|http)" | sed 's/^/      /' || echo "      无相关规则"
else
    echo "   ℹ️ iptables不可用"
fi

echo ""

# 3. 检查宝塔面板安全设置
echo "3️⃣ 检查宝塔面板安全："
if [ -d "/www/server/panel" ]; then
    echo "   ✅ 宝塔面板已安装"
    
    # 检查宝塔面板端口
    BT_PORT=$(grep -r "SERVER_PORT" /www/server/panel/config/config.json 2>/dev/null | grep -o '[0-9]*' | head -1)
    if [ -n "$BT_PORT" ]; then
        echo "   📊 宝塔面板端口: $BT_PORT"
        echo "   🌐 面板访问: http://115.159.5.111:$BT_PORT"
    fi
    
    # 检查宝塔防火墙
    if [ -f "/www/server/panel/plugin/ufw/ufw_main.py" ]; then
        echo "   📋 宝塔防火墙插件已安装"
    fi
else
    echo "   ❌ 宝塔面板未检测到"
fi

echo ""

# 4. 检查网络连接
echo "4️⃣ 检查网络连接："
echo "   📊 本机IP地址:"
ip addr show | grep -E "inet.*global" | sed 's/^/      /' || echo "      无法获取"

echo "   📊 路由信息:"
ip route | head -3 | sed 's/^/      /' || echo "      无法获取"

echo ""

# 5. 测试外部访问
echo "5️⃣ 测试外部访问模拟："
echo "   🔍 测试不同访问方式:"

# 测试localhost
LOCALHOST_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null)
echo "      localhost: HTTP $LOCALHOST_CODE"

# 测试127.0.0.1
LOCAL_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 2>/dev/null)
echo "      127.0.0.1: HTTP $LOCAL_CODE"

# 测试内网IP
INTERNAL_IP=$(ip addr show | grep -E "inet.*global" | head -1 | awk '{print $2}' | cut -d'/' -f1)
if [ -n "$INTERNAL_IP" ]; then
    INTERNAL_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$INTERNAL_IP 2>/dev/null)
    echo "      $INTERNAL_IP: HTTP $INTERNAL_CODE"
fi

echo ""

# 6. 检查DNS解析
echo "6️⃣ 检查DNS和域名："
echo "   📊 本机hostname: $(hostname)"
echo "   📊 /etc/hosts 相关条目:"
grep -E "(115\.159\.5\.111|localhost)" /etc/hosts 2>/dev/null | sed 's/^/      /' || echo "      无相关条目"

echo ""

# 7. 生成修复建议
echo "=================================="
echo "🎯 网络访问修复建议："

# 检查并给出具体建议
NETWORK_ISSUES=0

# 检查防火墙
if command -v firewall-cmd >/dev/null 2>&1; then
    if ! firewall-cmd --list-services 2>/dev/null | grep -q http; then
        echo "🔧 开放HTTP服务:"
        echo "   firewall-cmd --permanent --add-service=http"
        echo "   firewall-cmd --reload"
        ((NETWORK_ISSUES++))
    fi
fi

# 检查云服务器安全组
echo ""
echo "☁️ 腾讯云安全组检查："
echo "   1. 登录腾讯云控制台"
echo "   2. 进入云服务器 -> 安全组"
echo "   3. 确保入站规则包含："
echo "      - 协议: TCP"
echo "      - 端口: 80"
echo "      - 来源: 0.0.0.0/0"
echo "   4. 应用到服务器 115.159.5.111"

echo ""
echo "🌐 宝塔面板检查："
echo "   1. 访问宝塔面板: http://115.159.5.111:8888"
echo "   2. 检查 安全 -> 防火墙 设置"
echo "   3. 确保80端口已开放"
echo "   4. 检查 网站 -> 站点设置"

if [ $NETWORK_ISSUES -eq 0 ]; then
    echo ""
    echo "✅ 服务器配置正常"
    echo "🎯 问题可能在云服务器安全组或宝塔面板安全设置"
    echo "📞 建议检查腾讯云控制台的安全组配置"
fi

echo ""
echo "🔗 快速测试命令："
echo "   curl -I http://115.159.5.111"
echo "   telnet 115.159.5.111 80"