#!/bin/bash

# 小久任务管理系统 - 一键部署脚本
# 服务器：115.159.5.111
# 端口：80

set -e

echo "🚀 开始部署小久任务管理系统..."
echo "📍 目标服务器：115.159.5.111"
echo "🌐 访问端口：80"
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用root用户运行此脚本"
    exit 1
fi

# 1. 更新系统
echo "📦 更新系统包..."
apt update && apt upgrade -y

# 2. 安装必需软件
echo "🔧 安装必需软件..."
apt install -y nginx git curl htop

# 3. 创建网站目录
echo "📁 创建网站目录..."
mkdir -p /var/www/task-manager
cd /var/www/task-manager

# 4. 下载项目代码
echo "📥 下载项目代码..."
if [ -d ".git" ]; then
    echo "🔄 项目已存在，更新代码..."
    git pull origin main
else
    echo "📦 克隆新项目..."
    git clone https://github.com/xiaodehua2016/task-card-manager.git .
fi

# 5. 设置文件权限
echo "🔐 设置文件权限..."
chown -R www-data:www-data /var/www/task-manager
chmod -R 755 /var/www/task-manager

# 6. 配置Nginx
echo "⚙️ 配置Nginx..."
cat > /etc/nginx/sites-available/task-manager << 'EOF'
server {
    listen 80;
    server_name 115.159.5.111;
    root /var/www/task-manager;
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

# 7. 启用网站
echo "🔗 启用网站配置..."
ln -sf /etc/nginx/sites-available/task-manager /etc/nginx/sites-enabled/

# 8. 测试Nginx配置
echo "🧪 测试Nginx配置..."
nginx -t

if [ $? -ne 0 ]; then
    echo "❌ Nginx配置测试失败！"
    exit 1
fi

# 9. 启动服务
echo "🚀 启动服务..."
systemctl start nginx
systemctl enable nginx
systemctl reload nginx

# 10. 配置防火墙
echo "🔒 配置防火墙..."
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw --force enable

# 11. 创建更新脚本
echo "📝 创建更新脚本..."
cat > /root/update-task-manager.sh << 'EOF'
#!/bin/bash
echo "🔄 开始更新小久任务管理系统..."

cd /var/www/task-manager
git pull origin main

if [ $? -eq 0 ]; then
    chown -R www-data:www-data /var/www/task-manager
    chmod -R 755 /var/www/task-manager
    systemctl reload nginx
    echo "✅ 更新完成！"
    echo "🌐 访问地址：http://115.159.5.111"
else
    echo "❌ 更新失败！"
    exit 1
fi
EOF

chmod +x /root/update-task-manager.sh

# 12. 创建备份脚本
echo "💾 创建备份脚本..."
mkdir -p /backup/task-manager

cat > /root/backup-task-manager.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/task-manager"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 备份网站文件
tar -czf $BACKUP_DIR/website_$DATE.tar.gz /var/www/task-manager/

# 备份Nginx配置
cp /etc/nginx/sites-available/task-manager $BACKUP_DIR/nginx_config_$DATE

# 清理7天前的备份
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "✅ 备份完成: $BACKUP_DIR/website_$DATE.tar.gz"
EOF

chmod +x /root/backup-task-manager.sh

# 13. 验证部署
echo "🧪 验证部署..."
sleep 2

# 检查Nginx状态
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx服务运行正常"
else
    echo "❌ Nginx服务异常"
    exit 1
fi

# 检查端口监听
if netstat -tlnp | grep -q ":80 "; then
    echo "✅ 80端口正常监听"
else
    echo "❌ 80端口未监听"
    exit 1
fi

# 测试网站访问
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 | grep -q "200"; then
    echo "✅ 网站访问正常"
else
    echo "⚠️ 网站访问可能有问题，请手动检查"
fi

# 14. 显示部署结果
echo ""
echo "🎉 部署完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 服务器地址：115.159.5.111"
echo "🌐 访问地址：http://115.159.5.111"
echo "📁 项目目录：/var/www/task-manager"
echo "⚙️ Nginx配置：/etc/nginx/sites-available/task-manager"
echo ""
echo "🔧 管理命令："
echo "  更新项目：/root/update-task-manager.sh"
echo "  备份数据：/root/backup-task-manager.sh"
echo "  重启服务：systemctl restart nginx"
echo "  查看日志：tail -f /var/log/nginx/access.log"
echo ""
echo "📊 系统状态："
echo "  Nginx状态：$(systemctl is-active nginx)"
echo "  磁盘使用：$(df -h / | awk 'NR==2{print $5}')"
echo "  内存使用：$(free -h | awk 'NR==2{print $3"/"$2}')"
echo ""
echo "✅ 小久任务管理系统已成功部署到服务器！"
echo "🎯 现在可以通过 http://115.159.5.111 访问您的任务管理系统"