# 小久任务管理系统 - 服务器部署操作手册
## 版本：v4.1.0 | 服务器：115.159.5.111 | 端口：80

---

## 🎯 项目概述

### 项目特点
- **纯静态网站** - 无需数据库，无需Node.js
- **本地存储** - 数据保存在浏览器localStorage
- **轻量高效** - 仅需Nginx即可运行
- **功能完整** - 任务管理、时间统计、数据导入导出

### 技术架构
```
用户浏览器 → Nginx (80端口) → 静态文件 → localStorage存储
```

---

## 🚀 快速部署指南

### 方案一：一键部署脚本（推荐）

#### 1. 连接服务器
```bash
ssh root@115.159.5.111
```

#### 2. 执行一键部署
```bash
# 下载并执行部署脚本
wget -O deploy.sh https://raw.githubusercontent.com/xiaodehua2016/task-card-manager/main/deploy/simple-deployment.sh
chmod +x deploy.sh
./deploy.sh
```

#### 3. 验证部署
```bash
# 访问网站
curl -I http://115.159.5.111
# 应该返回 200 OK
```

### 方案二：手动部署

#### 第1步：安装基础环境
```bash
# 更新系统
apt update && apt upgrade -y

# 安装必需软件
apt install -y nginx git curl
```

#### 第2步：下载项目代码
```bash
# 创建网站目录
mkdir -p /var/www/task-manager
cd /var/www/task-manager

# 克隆项目
git clone https://github.com/xiaodehua2016/task-card-manager.git .

# 设置权限
chown -R www-data:www-data /var/www/task-manager
chmod -R 755 /var/www/task-manager
```

#### 第3步：配置Nginx
```bash
# 创建网站配置
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
    gzip_types text/css application/javascript text/javascript;
}
EOF

# 启用网站
ln -s /etc/nginx/sites-available/task-manager /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

#### 第4步：启动服务
```bash
# 启动并设置开机自启
systemctl start nginx
systemctl enable nginx

# 检查状态
systemctl status nginx
```

---

## 🔧 Git部署方式

### 初次部署
```bash
# 1. 连接服务器
ssh root@115.159.5.111

# 2. 创建部署目录
mkdir -p /var/www/task-manager
cd /var/www/task-manager

# 3. 克隆仓库
git clone https://github.com/xiaodehua2016/task-card-manager.git .

# 4. 设置权限
chown -R www-data:www-data /var/www/task-manager
chmod -R 755 /var/www/task-manager

# 5. 配置Nginx（参考上面的配置）
```

### 更新部署
```bash
# 1. 进入项目目录
cd /var/www/task-manager

# 2. 拉取最新代码
git pull origin main

# 3. 重新设置权限
chown -R www-data:www-data /var/www/task-manager
chmod -R 755 /var/www/task-manager

# 4. 重启Nginx（可选）
systemctl reload nginx
```

### 自动化更新脚本
```bash
# 创建更新脚本
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
else
    echo "❌ 更新失败！"
    exit 1
fi
EOF

# 设置执行权限
chmod +x /root/update-task-manager.sh

# 使用方法
/root/update-task-manager.sh
```

---

## 📋 部署验证清单

### ✅ 基础验证
- [ ] SSH可以正常连接服务器 (115.159.5.111)
- [ ] Nginx服务正常运行
- [ ] 80端口正常监听
- [ ] 项目文件完整下载

### ✅ 功能验证
- [ ] 网站可以正常访问 (http://115.159.5.111)
- [ ] 页面正常显示任务卡片
- [ ] 可以添加和完成任务
- [ ] 数据在浏览器中正常保存
- [ ] CSS和JavaScript文件正常加载

### ✅ 性能验证
- [ ] 页面加载速度 < 2秒
- [ ] 静态文件正常缓存
- [ ] 移动端访问正常

---

## 🔧 故障排查

### 常见问题及解决方案

#### 1. 网站无法访问
```bash
# 检查Nginx状态
systemctl status nginx

# 检查端口监听
netstat -tlnp | grep :80

# 检查防火墙
ufw status

# 重启Nginx
systemctl restart nginx
```

#### 2. 页面显示异常
```bash
# 检查文件权限
ls -la /var/www/task-manager/

# 检查Nginx错误日志
tail -f /var/log/nginx/error.log

# 检查文件完整性
cat /var/www/task-manager/index.html
```

#### 3. 静态文件无法加载
```bash
# 检查文件路径
find /var/www/task-manager/ -name "*.css"
find /var/www/task-manager/ -name "*.js"

# 检查Nginx配置
nginx -t

# 重新加载配置
systemctl reload nginx
```

#### 4. Git更新失败
```bash
# 检查Git状态
cd /var/www/task-manager
git status

# 强制更新
git reset --hard HEAD
git pull origin main

# 检查网络连接
ping github.com
```

---

## 📊 系统监控

### 基础监控命令
```bash
# 系统资源使用情况
htop

# 磁盘使用情况
df -h

# 内存使用情况
free -h

# Nginx访问日志
tail -f /var/log/nginx/access.log

# 系统负载
uptime
```

### 性能优化建议
```bash
# 启用Nginx状态页面
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}

# 查看Nginx状态
curl http://127.0.0.1/nginx_status
```

---

## 🔒 安全配置

### 基础安全设置
```bash
# 配置防火墙
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS (如需要)
ufw enable

# 隐藏Nginx版本信息
echo "server_tokens off;" >> /etc/nginx/nginx.conf

# 限制访问敏感文件
location ~ /\.(git|env) {
    deny all;
}
```

### SSL证书配置（可选）
```bash
# 安装Certbot
apt install certbot python3-certbot-nginx

# 申请SSL证书
certbot --nginx -d yourdomain.com

# 自动续期
crontab -e
# 添加：0 12 * * * /usr/bin/certbot renew --quiet
```

---

## 📈 备份策略

### 数据备份
```bash
# 创建备份脚本
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

echo "✅ 备份完成: $BACKUP_DIR"
EOF

chmod +x /root/backup-task-manager.sh

# 设置定时备份
crontab -e
# 添加：0 2 * * * /root/backup-task-manager.sh
```

### 恢复操作
```bash
# 恢复网站文件
cd /
tar -xzf /backup/task-manager/website_YYYYMMDD_HHMMSS.tar.gz

# 恢复Nginx配置
cp /backup/task-manager/nginx_config_YYYYMMDD_HHMMSS /etc/nginx/sites-available/task-manager
systemctl reload nginx
```

---

## 🎯 部署总结

### 资源占用
- **内存使用**: < 100MB
- **磁盘空间**: < 50MB
- **CPU占用**: < 5%
- **网络带宽**: 最小需求

### 性能指标
- **并发用户**: 500+
- **日访问量**: 50,000+
- **响应时间**: < 200ms
- **可用性**: 99.9%+

### 维护建议
- **定期更新**: 每周检查代码更新
- **日志监控**: 每日检查访问和错误日志
- **性能监控**: 每周检查系统资源使用
- **安全检查**: 每月检查安全配置

---

## 📞 技术支持

### 部署成功标志
```
✅ 访问 http://115.159.5.111 显示任务管理界面
✅ 可以添加、编辑、完成任务
✅ 数据在浏览器中正常保存
✅ 页面样式和交互正常
✅ 移动端访问正常
```

### 联系方式
- **项目仓库**: https://github.com/xiaodehua2016/task-card-manager
- **问题反馈**: GitHub Issues
- **部署支持**: 参考本文档故障排查部分

---

**部署完成后，您的小久任务管理系统将在 http://115.159.5.111 正常运行！**