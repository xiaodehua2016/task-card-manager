#!/bin/bash

# 修复"没有找到站点"问题
echo "🔧 修复宝塔面板站点配置问题..."

# 检查当前配置状态
echo "📊 检查当前配置状态..."

# 1. 检查虚拟主机配置文件
VHOST_FILE="/www/server/nginx/conf/vhost/task-manager.conf"
if [ -f "$VHOST_FILE" ]; then
    echo "✅ 虚拟主机配置文件存在: $VHOST_FILE"
    echo "📄 配置文件内容："
    cat "$VHOST_FILE"
else
    echo "❌ 虚拟主机配置文件不存在"
fi

echo ""
echo "🔍 检查主配置文件..."

# 2. 检查主配置文件是否包含vhost目录
MAIN_CONF="/www/server/nginx/conf/nginx.conf"
if grep -q "include.*vhost" "$MAIN_CONF"; then
    echo "✅ 主配置文件包含vhost目录"
else
    echo "⚠️ 主配置文件可能未包含vhost目录"
    echo "📝 添加vhost包含指令..."
    
    # 备份原配置
    cp "$MAIN_CONF" "$MAIN_CONF.backup.$(date +%Y%m%d_%H%M%S)"
    
    # 在http块中添加include指令
    sed -i '/http {/a\    include /www/server/nginx/conf/vhost/*.conf;' "$MAIN_CONF"
fi

echo ""
echo "🔧 重新创建虚拟主机配置..."

# 3. 重新创建虚拟主机配置
mkdir -p /www/server/nginx/conf/vhost

cat > "$VHOST_FILE" << 'EOF'
server {
    listen 80;
    server_name 115.159.5.111 _;
    root /www/wwwroot/task-manager;
    index index.html index.htm;

    # 基本配置
    location / {
        try_files $uri $uri/ =404;
    }

    # 静态文件缓存
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 安全配置
    location ~ /\. {
        deny all;
    }

    # 压缩配置
    gzip on;
    gzip_types text/css application/javascript text/javascript application/json;
    gzip_min_length 1000;

    # 错误页面
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
EOF

echo "✅ 虚拟主机配置已重新创建"

# 4. 检查网站目录和文件
echo ""
echo "📁 检查网站目录..."
WEB_ROOT="/www/wwwroot/task-manager"

if [ -d "$WEB_ROOT" ]; then
    echo "✅ 网站目录存在: $WEB_ROOT"
    
    if [ -f "$WEB_ROOT/index.html" ]; then
        echo "✅ 主页文件存在"
        echo "📊 文件列表："
        ls -la "$WEB_ROOT/" | head -10
    else
        echo "❌ 主页文件不存在"
        echo "🔄 重新解压项目文件..."
        
        if [ -f "/tmp/task-manager-v4.1.0.tar.gz" ]; then
            cd "$WEB_ROOT"
            tar -xzf /tmp/task-manager-v4.1.0.tar.gz
            chown -R www:www "$WEB_ROOT"
            chmod -R 755 "$WEB_ROOT"
            echo "✅ 项目文件已重新解压"
        else
            echo "❌ 项目文件包不存在，请重新上传"
            exit 1
        fi
    fi
else
    echo "❌ 网站目录不存在，创建目录..."
    mkdir -p "$WEB_ROOT"
    
    if [ -f "/tmp/task-manager-v4.1.0.tar.gz" ]; then
        cd "$WEB_ROOT"
        tar -xzf /tmp/task-manager-v4.1.0.tar.gz
        chown -R www:www "$WEB_ROOT"
        chmod -R 755 "$WEB_ROOT"
        echo "✅ 网站目录和文件已创建"
    else
        echo "❌ 项目文件包不存在，请重新上传"
        exit 1
    fi
fi

# 5. 测试配置并重启服务
echo ""
echo "🧪 测试Nginx配置..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx配置测试通过"
    
    echo "🔄 重启Nginx服务..."
    /etc/init.d/nginx restart
    
    sleep 3
    
    # 验证服务状态
    if pgrep nginx >/dev/null; then
        echo "✅ Nginx服务运行正常"
        
        # 检查端口监听
        if ss -tlnp | grep -q ":80 "; then
            echo "✅ 80端口正常监听"
            
            # 测试本地访问
            sleep 2
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 2>/dev/null)
            if [ "$HTTP_CODE" = "200" ]; then
                echo "✅ 本地访问测试成功 (HTTP $HTTP_CODE)"
                echo ""
                echo "🎉 修复完成！"
                echo "🌐 现在可以访问: http://115.159.5.111"
                echo ""
                echo "📋 如果仍有问题，请检查："
                echo "  1. 防火墙是否开放80端口"
                echo "  2. 云服务器安全组是否开放80端口"
                echo "  3. 域名解析是否正确"
            else
                echo "⚠️ 本地访问测试失败 (HTTP $HTTP_CODE)"
                echo "🔍 检查错误日志:"
                tail -5 /var/log/nginx/error.log 2>/dev/null || echo "无法读取错误日志"
            fi
        else
            echo "❌ 80端口未监听"
        fi
    else
        echo "❌ Nginx服务启动失败"
    fi
else
    echo "❌ Nginx配置测试失败"
    exit 1
fi

echo ""
echo "📊 最终状态检查："
echo "  Nginx进程: $(pgrep nginx >/dev/null && echo '运行中' || echo '未运行')"
echo "  80端口监听: $(ss -tlnp | grep -q ':80 ' && echo '正常' || echo '异常')"
echo "  配置文件: $([ -f "$VHOST_FILE" ] && echo '存在' || echo '缺失')"
echo "  网站文件: $([ -f "$WEB_ROOT/index.html" ] && echo '存在' || echo '缺失')"