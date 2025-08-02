#!/bin/bash

# 宝塔面板Nginx服务修复脚本
echo "🔧 修复宝塔面板Nginx服务..."

# 检查当前Nginx状态
echo "📊 当前Nginx进程状态："
pgrep nginx && echo "✅ Nginx进程正在运行" || echo "❌ Nginx进程未运行"

# 启动Nginx服务
echo "🚀 启动Nginx服务..."
if [ -f "/etc/init.d/nginx" ]; then
    echo "使用宝塔面板方式启动..."
    /etc/init.d/nginx start
else
    echo "使用系统方式启动..."
    systemctl start nginx
fi

# 等待服务启动
sleep 3

# 验证启动结果
echo "🧪 验证服务状态..."
if pgrep nginx >/dev/null; then
    echo "✅ Nginx服务已成功启动"
    
    # 检查端口监听
    if ss -tlnp | grep -q ":80 "; then
        echo "✅ 80端口正常监听"
    else
        echo "⚠️ 80端口未监听，检查配置..."
    fi
    
    # 测试网站访问
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 2>/dev/null)
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ 网站访问正常 (HTTP $HTTP_CODE)"
        echo "🎉 修复完成！可以访问 http://115.159.5.111"
    else
        echo "⚠️ 网站访问异常 (HTTP $HTTP_CODE)"
        echo "🔍 检查配置文件..."
        nginx -t
    fi
else
    echo "❌ Nginx启动失败"
    echo "🔍 查看错误信息..."
    tail -10 /var/log/nginx/error.log 2>/dev/null || echo "无法读取错误日志"
fi

echo ""
echo "📋 管理命令："
echo "  启动: /etc/init.d/nginx start"
echo "  停止: /etc/init.d/nginx stop"
echo "  重启: /etc/init.d/nginx restart"
echo "  重载: /etc/init.d/nginx reload"
echo "  状态: pgrep nginx"