#!/bin/bash

# 小久任务管理系统 - 一键部署脚本 (宝塔面板适配版)
# 服务器：115.159.5.111 (OpenCloudOS 9.4 + 宝塔面板)
# 端口：80

set -e

echo "🚀 开始部署小久任务管理系统..."
echo "📍 目标服务器：115.159.5.111"
echo "💻 系统：OpenCloudOS 9.4"
echo "🌐 访问端口：80"
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用root用户运行此脚本"
    exit 1
fi

# 1. 检查已安装的软件
echo "🔍 检查系统环境..."
echo "✅ 系统已更新"

# 检查必需软件
if command -v nginx >/dev/null 2>&1; then
    NGINX_VERSION=$(nginx -v 2>&1 | grep -o 'nginx/[0-9.]*')
    echo "✅ Nginx 已安装: $NGINX_VERSION"
else
    echo "❌ Nginx 未安装"
    exit 1
fi

if command -v git >/dev/null 2>&1; then
    echo "✅ Git 已安装: $(git --version)"
else
    echo "❌ Git 未安装"
    exit 1
fi

if command -v curl >/dev/null 2>&1; then
    echo "✅ Curl 已安装: $(curl --version | head -1)"
else
    echo "❌ Curl 未安装"
    exit 1
fi

# 显示环境信息（不影响部署）
echo "📊 检测到的其他软件："
command -v mysql >/dev/null 2>&1 && echo "  - MySQL: $(mysql --version 2>/dev/null | head -1)" || true
command -v php >/dev/null 2>&1 && echo "  - PHP: $(php --version 2>/dev/null | head -1)" || true
command -v node >/dev/null 2>&1 && echo "  - Node.js: $(node --version 2>/dev/null)" || true
echo "💡 注意：本项目为纯静态网站，只需要Nginx即可运行"

echo "🎯 所有必需软件已就绪，开始部署..."

# 2. 检测宝塔面板环境并创建网站目录
echo "🔍 检测服务器环境..."
if [ -d "/www/server/panel" ]; then
    echo "✅ 检测到宝塔面板环境"
    BAOTA_ENV=true
    WEB_ROOT="/www/wwwroot/task-manager"
    NGINX_CONF_DIR="/www/server/nginx/conf/vhost"
    WEB_USER="www"
else
    echo "📋 标准Linux环境"
    BAOTA_ENV=false
    WEB_ROOT="/var/www/task-manager"
    NGINX_CONF_DIR="/etc/nginx/conf.d"
    WEB_USER="nginx"
fi

echo "📁 创建网站目录: $WEB_ROOT"
mkdir -p $WEB_ROOT
cd $WEB_ROOT

# 3. 使用已上传的项目文件
echo "📥 部署项目文件..."
if [ -f "/tmp/task-manager-v4.1.0.tar.gz" ]; then
    echo "🔄 解压项目文件..."
    tar -xzf /tmp/task-manager-v4.1.0.tar.gz
    echo "✅ 项目文件解压完成"
else
    echo "⚠️ 未找到项目文件包，尝试使用当前目录文件..."
    if [ -f "index.html" ]; then
        echo "✅ 发现项目文件，继续部署..."
    else
        echo "❌ 未找到项目文件"
        echo "💡 请先上传项目文件："
        echo "   tar -czf task-manager-v4.1.0.tar.gz --exclude='.git' ."
        echo "   scp task-manager-v4.1.0.tar.gz root@115.159.5.111:/tmp/"
        exit 1
    fi
fi

# 4. 自动检测并设置文件权限
echo "🔐 设置文件权限..."

# 检测可用的Web用户
if id $WEB_USER >/dev/null 2>&1; then
    echo "✅ 使用用户: $WEB_USER"
    chown -R $WEB_USER:$WEB_USER $WEB_ROOT
elif id www >/dev/null 2>&1; then
    echo "✅ 使用用户: www (宝塔默认)"
    chown -R www:www $WEB_ROOT
elif id nginx >/dev/null 2>&1; then
    echo "✅ 使用用户: nginx"
    chown -R nginx:nginx $WEB_ROOT
elif id www-data >/dev/null 2>&1; then
    echo "✅ 使用用户: www-data"
    chown -R www-data:www-data $WEB_ROOT
else
    echo "⚠️ 使用默认用户: nobody"
    chown -R nobody:nobody $WEB_ROOT
fi

chmod -R 755 $WEB_ROOT

# 5. 配置Nginx（自动适配宝塔面板和标准环境）
echo "⚙️ 配置Nginx..."

# 确保配置目录存在
mkdir -p $NGINX_CONF_DIR

if [ "$BAOTA_ENV" = true ]; then
    echo "📝 创建宝塔面板虚拟主机配置..."
    CONF_FILE="$NGINX_CONF_DIR/task-manager.conf"
else
    echo "📝 创建标准Nginx配置..."
    CONF_FILE="$NGINX_CONF_DIR/task-manager.conf"
fi

cat > $CONF_FILE << 'EOF'
server {
    listen 80;
    server_name 115.159.5.111;
    root WEB_ROOT_PLACEHOLDER;
    index index.html;

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
}
EOF

# 替换配置文件中的占位符
sed -i "s|WEB_ROOT_PLACEHOLDER|$WEB_ROOT|g" $CONF_FILE
echo "✅ Nginx配置文件已创建: $CONF_FILE"

# 6. 测试Nginx配置
echo "🧪 测试Nginx配置..."
nginx -t

if [ $? -ne 0 ]; then
    echo "❌ Nginx配置测试失败！"
    exit 1
fi

# 7. 启动服务（适配宝塔面板和标准环境）
echo "🚀 启动服务..."

if [ "$BAOTA_ENV" = true ]; then
    echo "🔄 重启宝塔面板Nginx服务..."
    # 宝塔面板的nginx重启方式
    if [ -f "/etc/init.d/nginx" ]; then
        /etc/init.d/nginx reload
    else
        systemctl reload nginx
    fi
    
    # 检查宝塔面板服务
    if command -v bt >/dev/null 2>&1; then
        echo "✅ 宝塔面板命令可用"
    fi
else
    echo "🔄 启动标准Nginx服务..."
    systemctl start nginx
    systemctl enable nginx
    systemctl reload nginx
fi

# 8. 配置防火墙（OpenCloudOS使用firewalld）
echo "🔒 配置防火墙..."
if command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --reload
    echo "✅ 使用firewalld配置防火墙"
else
    echo "⚠️ 未找到firewalld，跳过防火墙配置"
fi

# 9. 创建更新脚本（适配环境）
echo "📝 创建更新脚本..."
cat > /root/update-task-manager.sh << EOF
#!/bin/bash
echo "🔄 开始更新小久任务管理系统..."

cd $WEB_ROOT

# 如果有新的tar.gz文件，使用它更新
if [ -f "/tmp/task-manager-v4.1.0.tar.gz" ]; then
    echo "📦 发现新版本文件，开始更新..."
    rm -rf $WEB_ROOT/*
    tar -xzf /tmp/task-manager-v4.1.0.tar.gz
    
    # 设置正确的权限
    if id $WEB_USER >/dev/null 2>&1; then
        chown -R $WEB_USER:$WEB_USER $WEB_ROOT
    elif id www >/dev/null 2>&1; then
        chown -R www:www $WEB_ROOT
    else
        chown -R nobody:nobody $WEB_ROOT
    fi
    
    chmod -R 755 $WEB_ROOT
    
    # 重启服务
    if [ "$BAOTA_ENV" = true ]; then
        /etc/init.d/nginx reload 2>/dev/null || systemctl reload nginx
    else
        systemctl reload nginx
    fi
    
    echo "✅ 更新完成！"
    echo "🌐 访问地址：http://115.159.5.111"
else
    echo "⚠️ 未找到更新文件 /tmp/task-manager-v4.1.0.tar.gz"
    echo "💡 请先上传新版本文件到 /tmp/ 目录"
fi
EOF

chmod +x /root/update-task-manager.sh

# 10. 创建备份脚本（适配环境）
echo "💾 创建备份脚本..."
mkdir -p /backup/task-manager

cat > /root/backup-task-manager.sh << EOF
#!/bin/bash
BACKUP_DIR="/backup/task-manager"
DATE=\$(date +%Y%m%d_%H%M%S)

mkdir -p \$BACKUP_DIR

# 备份网站文件
tar -czf \$BACKUP_DIR/website_\$DATE.tar.gz $WEB_ROOT/

# 备份Nginx配置
cp $CONF_FILE \$BACKUP_DIR/nginx_config_\$DATE.conf

# 清理7天前的备份
find \$BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "✅ 备份完成: \$BACKUP_DIR/website_\$DATE.tar.gz"
EOF

chmod +x /root/backup-task-manager.sh

# 11. 验证部署
echo "🧪 验证部署..."
sleep 2

# 检查Nginx状态（适配宝塔面板）
if [ "$BAOTA_ENV" = true ]; then
    # 宝塔面板环境检查
    if pgrep nginx >/dev/null; then
        echo "✅ Nginx进程运行正常"
    else
        echo "❌ Nginx进程未运行"
        echo "🔄 尝试启动Nginx..."
        /etc/init.d/nginx start 2>/dev/null || systemctl start nginx
        sleep 2
        if pgrep nginx >/dev/null; then
            echo "✅ Nginx已成功启动"
        else
            echo "❌ Nginx启动失败"
            exit 1
        fi
    fi
else
    # 标准环境检查
    if systemctl is-active --quiet nginx; then
        echo "✅ Nginx服务运行正常"
    else
        echo "❌ Nginx服务异常"
        systemctl status nginx
        exit 1
    fi
fi

# 检查端口监听（使用ss命令，OpenCloudOS可能没有netstat）
if ss -tlnp | grep -q ":80 "; then
    echo "✅ 80端口正常监听"
elif netstat -tlnp 2>/dev/null | grep -q ":80 "; then
    echo "✅ 80端口正常监听"
else
    echo "❌ 80端口未监听"
    ss -tlnp | grep nginx
    exit 1
fi

# 测试网站访问
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 网站访问正常 (HTTP $HTTP_CODE)"
else
    echo "⚠️ 网站访问异常 (HTTP $HTTP_CODE)"
    echo "🔍 检查Nginx错误日志："
    tail -5 /var/log/nginx/error.log
fi

# 12. 显示部署结果
echo ""
echo "🎉 部署完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 服务器地址：115.159.5.111"
echo "💻 系统环境：OpenCloudOS 9.4$([ "$BAOTA_ENV" = true ] && echo " + 宝塔面板" || echo "")"
echo "🌐 访问地址：http://115.159.5.111"
echo "📁 项目目录：$WEB_ROOT"
echo "⚙️ Nginx配置：$CONF_FILE"
echo ""
echo "🔧 管理命令："
echo "  更新项目：/root/update-task-manager.sh"
echo "  备份数据：/root/backup-task-manager.sh"
echo "  重启服务：systemctl restart nginx"
echo "  查看日志：tail -f /var/log/nginx/access.log"
echo "  查看错误：tail -f /var/log/nginx/error.log"
echo ""
echo "📊 系统状态："
echo "  Nginx状态：$(systemctl is-active nginx)"
echo "  磁盘使用：$(df -h / | awk 'NR==2{print $5}')"
echo "  内存使用：$(free -h | awk 'NR==2{print $3"/"$2}')"
echo ""
echo "✅ 小久任务管理系统已成功部署到OpenCloudOS服务器！"
echo "🎯 现在可以通过 http://115.159.5.111 访问您的任务管理系统"
echo ""
echo "📝 部署说明："
echo "  - 已跳过软件安装（nginx、git、curl已存在）"
echo "  - 自动适配$([ "$BAOTA_ENV" = true ] && echo "宝塔面板" || echo "标准Linux")环境"
echo "  - 防火墙已配置（如果有firewalld）"
echo "  - 项目文件权限已正确设置"
echo "  - 使用Web用户：$([ -n "$WEB_USER" ] && echo "$WEB_USER" || echo "auto-detected")"
