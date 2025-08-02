#!/bin/bash

# 在宝塔面板中添加网站的脚本
echo "🌐 在宝塔面板中添加task-manager网站..."
echo "=================================="

# 检查宝塔面板
if [ ! -d "/www/server/panel" ]; then
    echo "❌ 宝塔面板未安装"
    exit 1
fi

echo "✅ 检测到宝塔面板环境"

# 1. 确保网站目录存在
SITE_PATH="/www/wwwroot/task-manager"
echo "📁 检查网站目录: $SITE_PATH"

if [ ! -d "$SITE_PATH" ]; then
    echo "📁 创建网站目录..."
    mkdir -p "$SITE_PATH"
fi

# 2. 确保项目文件存在
if [ ! -f "$SITE_PATH/index.html" ]; then
    echo "📥 解压项目文件..."
    if [ -f "/tmp/task-manager-v4.1.0.tar.gz" ]; then
        cd "$SITE_PATH"
        tar -xzf /tmp/task-manager-v4.1.0.tar.gz
        echo "✅ 项目文件解压完成"
    else
        echo "❌ 项目文件不存在，请先上传"
        exit 1
    fi
fi

# 3. 设置正确的权限
echo "🔐 设置文件权限..."
chown -R www:www "$SITE_PATH"
chmod -R 755 "$SITE_PATH"

# 4. 创建Nginx配置文件
VHOST_FILE="/www/server/nginx/conf/vhost/task-manager.conf"
echo "⚙️ 创建Nginx虚拟主机配置..."

cat > "$VHOST_FILE" << 'EOF'
server {
    listen 80;
    server_name 115.159.5.111;
    index index.html index.htm index.php;
    root /www/wwwroot/task-manager;
    
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
    
    # 访问日志
    access_log /www/wwwlogs/task-manager.log;
    error_log /www/wwwlogs/task-manager.error.log;
}
EOF

echo "✅ Nginx配置文件已创建: $VHOST_FILE"

# 5. 测试Nginx配置
echo "🧪 测试Nginx配置..."
nginx -t

if [ $? -ne 0 ]; then
    echo "❌ Nginx配置测试失败！"
    exit 1
fi

# 6. 重载Nginx配置
echo "🔄 重载Nginx配置..."
/etc/init.d/nginx reload

# 7. 尝试通过宝塔面板API添加网站（如果可能）
echo "🌐 尝试在宝塔面板中注册网站..."

# 检查宝塔面板数据库
BT_DB="/www/server/panel/data/default.db"
if [ -f "$BT_DB" ]; then
    echo "📊 宝塔面板数据库存在，尝试添加网站记录..."
    
    # 使用sqlite3添加网站记录
    if command -v sqlite3 >/dev/null 2>&1; then
        # 检查是否已存在
        EXISTING=$(sqlite3 "$BT_DB" "SELECT COUNT(*) FROM sites WHERE name='task-manager';" 2>/dev/null || echo "0")
        
        if [ "$EXISTING" = "0" ]; then
            # 添加网站记录
            CURRENT_TIME=$(date +%s)
            sqlite3 "$BT_DB" "INSERT INTO sites (name, path, status, ps, addtime) VALUES ('task-manager', '/www/wwwroot/task-manager', '1', '任务管理系统', '$CURRENT_TIME');" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo "✅ 网站已添加到宝塔面板数据库"
            else
                echo "⚠️ 无法添加到宝塔面板数据库（这不影响网站运行）"
            fi
        else
            echo "ℹ️ 网站已存在于宝塔面板数据库中"
        fi
    else
        echo "⚠️ sqlite3未安装，无法操作宝塔面板数据库"
    fi
else
    echo "⚠️ 宝塔面板数据库不存在"
fi

# 8. 创建日志文件
echo "📝 创建日志文件..."
touch /www/wwwlogs/task-manager.log
touch /www/wwwlogs/task-manager.error.log
chown www:www /www/wwwlogs/task-manager.*

# 9. 验证部署
echo "🧪 验证部署..."
sleep 2

# 检查文件
if [ -f "$SITE_PATH/index.html" ]; then
    echo "✅ 网站文件存在"
else
    echo "❌ 网站文件缺失"
fi

# 检查配置
if [ -f "$VHOST_FILE" ]; then
    echo "✅ Nginx配置存在"
else
    echo "❌ Nginx配置缺失"
fi

# 测试访问
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 本地访问正常 (HTTP $HTTP_CODE)"
else
    echo "⚠️ 本地访问异常 (HTTP $HTTP_CODE)"
fi

# 10. 显示结果
echo ""
echo "=================================="
echo "🎉 网站添加完成！"
echo ""
echo "📍 网站信息："
echo "   域名: 115.159.5.111"
echo "   目录: /www/wwwroot/task-manager"
echo "   配置: /www/server/nginx/conf/vhost/task-manager.conf"
echo "   日志: /www/wwwlogs/task-manager.log"
echo ""
echo "🌐 访问地址："
echo "   http://115.159.5.111"
echo ""
echo "🔧 管理建议："
echo "   1. 刷新宝塔面板网站页面"
echo "   2. 如果网站仍未显示，请手动在宝塔面板中添加"
echo "   3. 域名: 115.159.5.111"
echo "   4. 目录: /www/wwwroot/task-manager"
echo ""
echo "📊 手动添加步骤（如果需要）："
echo "   1. 打开宝塔面板 -> 网站"
echo "   2. 点击 '添加站点'"
echo "   3. 域名: 115.159.5.111"
echo "   4. 根目录: /www/wwwroot/task-manager"
echo "   5. 不创建数据库"
echo "   6. 不创建FTP"
echo "   7. 提交"
echo ""
echo "✅ 现在应该可以正常访问了！"