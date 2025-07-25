# 腾讯云服务器部署指南

## 🖥️ 服务器配置推荐

### 小访问量项目配置（推荐）
```
操作系统：Ubuntu 20.04 LTS
CPU：1核
内存：1GB
存储：20GB SSD
带宽：1Mbps
价格：约 ¥15/月
```

### 标准配置（备选）
```
操作系统：Ubuntu 20.04 LTS
CPU：2核
内存：2GB
存储：50GB SSD
带宽：3Mbps
价格：约 ¥24/月
```

### 云服务器CVM（企业级）
```
操作系统：Ubuntu 20.04 LTS / CentOS 7.9
CPU：1核
内存：2GB
存储：50GB 云硬盘
带宽：1Mbps
价格：约 ¥30/月
```

## 🐧 操作系统选择

### Ubuntu 20.04 LTS（强烈推荐）
**优势：**
- 新手友好，文档丰富
- 软件包管理简单（apt-get）
- 社区支持强大
- 长期支持版本（LTS）
- 内存占用低，性能好

**安装命令示例：**
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装必要软件
sudo apt install nginx nodejs npm git -y

# 安装Docker（可选）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### CentOS 7.9（企业级选择）
**优势：**
- 企业级稳定性
- 安全性较高
- 适合生产环境

**安装命令示例：**
```bash
# 更新系统
sudo yum update -y

# 安装必要软件
sudo yum install epel-release -y
sudo yum install nginx nodejs npm git -y
```

## 🚀 部署方案（按访问量选择）

### 🎯 小访问量项目（< 1000次/日）- 推荐方案

#### 方案一：Python简单HTTP服务器（最简单）
```bash
# 1. 上传项目文件
git clone https://github.com/xiaodehua2016/task-card-manager.git
cd task-card-manager

# 2. 启动HTTP服务器
python3 -m http.server 80

# 3. 后台运行（可选）
nohup python3 -m http.server 80 > server.log 2>&1 &
```

**优势：**
- ✅ 无需安装额外软件
- ✅ 配置极简，一条命令搞定
- ✅ 内存占用极低（< 50MB）
- ✅ 完全满足静态文件托管需求

#### 方案二：Node.js + Express服务器（推荐）
# 腾讯云服务器部署指南

## 🖥️ 服务器配置推荐

### 轻量应用服务器（推荐）
```
操作系统：Ubuntu 20.04 LTS
CPU：2核
内存：2GB
存储：50GB SSD
带宽：3Mbps
价格：约 ¥24/月
```

### 云服务器CVM（备选）
```
操作系统：Ubuntu 20.04 LTS / CentOS 7.9
CPU：1核
内存：2GB
存储：50GB 云硬盘
带宽：1Mbps
价格：约 ¥30/月
```

## 🐧 操作系统选择

### Ubuntu 20.04 LTS（强烈推荐）
**优势：**
- 新手友好，文档丰富
- 软件包管理简单（apt-get）
- 社区支持强大
- 长期支持版本（LTS）
- 内存占用低，性能好

**安装命令示例：**
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装必要软件
sudo apt install nginx nodejs npm git -y

# 安装Docker（可选）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### CentOS 7.9（企业级选择）
**优势：**
- 企业级稳定性
- 安全性较高
- 适合生产环境

**安装命令示例：**
```bash
# 更新系统
sudo yum update -y

# 安装必要软件
sudo yum install epel-release -y
sudo yum install nginx nodejs npm git -y
```

```bash
# 1. 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. 创建Express服务器
npm init -y
npm install express --save

# 3. 创建服务器文件
cat > server.js << 'EOF'
const express = require('express');
const path = require('path');
const app = express();

app.use(express.static('.'));
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`服务器运行在端口 ${PORT}`);
});
EOF

# 4. 启动服务
node server.js
```

#### 方案三：Nginx + 静态文件（高性能需求）
```bash
# 1. 安装Nginx
sudo apt install nginx -y

# 2. 上传项目文件
git clone https://github.com/xiaodehua2016/task-card-manager.git
sudo cp -r task-card-manager/* /var/www/html/

# 3. 启动服务
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 🚀 中大访问量项目（> 1000次/日）

#### 方案四：Nginx + 完整配置
```bash
# 完整Nginx配置，包含缓存、压缩等优化
sudo nano /etc/nginx/sites-available/task-manager
```

#### 方案五：Docker容器化部署
```dockerfile
# Dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 🔧 服务器初始化脚本

### Ubuntu 20.04 一键部署脚本
```bash
#!/bin/bash
# 腾讯云Ubuntu服务器一键部署脚本

echo "🚀 开始部署小久任务管理系统..."

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装必要软件
sudo apt install nginx git curl -y

# 安装Node.js（可选）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 克隆项目
cd /tmp
git clone https://github.com/xiaodehua2016/task-card-manager.git

# 部署到Nginx
sudo rm -rf /var/www/html/*
sudo cp -r task-card-manager/* /var/www/html/

# 配置Nginx
sudo tee /etc/nginx/sites-available/default > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # 启用gzip压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF

# 启动服务
sudo systemctl restart nginx
sudo systemctl enable nginx

# 配置防火墙
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

echo "✅ 部署完成！"
echo "🌐 访问地址：http://$(curl -s ifconfig.me)"
```

## 🔒 安全配置

### 1. 防火墙设置
```bash
# Ubuntu UFW
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable

# CentOS Firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### 2. SSL证书配置（可选）
```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx -y

# 申请SSL证书
sudo certbot --nginx -d yourdomain.com

# 自动续期
sudo crontab -e
# 添加：0 12 * * * /usr/bin/certbot renew --quiet
```

### 3. 基础安全加固
```bash
# 禁用root登录
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# 修改SSH端口（可选）
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# 重启SSH服务
sudo systemctl restart sshd

# 安装fail2ban防暴力破解
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
```

## 💰 成本分析

### 月度费用预估
| 配置 | 价格 | 适用场景 |
|------|------|----------|
| 轻量1核1GB | ¥15/月 | 个人测试 |
| 轻量2核2GB | ¥24/月 | 小型应用 |
| CVM1核2GB | ¥30/月 | 生产环境 |
| CVM2核4GB | ¥60/月 | 高性能需求 |

### 年度费用优化
- 购买年付可享受8.5折优惠
- 新用户首年可享受更大折扣
- 建议先购买1个月测试，满意后再购买年付

## 🎯 部署后验证

### 1. 功能测试清单
- [ ] 网站可以正常访问
- [ ] 任务管理功能正常
- [ ] 数据存储功能正常
- [ ] 移动端访问正常
- [ ] 导入导出功能可用

### 2. 性能测试
```bash
# 测试网站响应时间
curl -o /dev/null -s -w "%{time_total}\n" http://your-server-ip

# 测试并发性能
ab -n 100 -c 10 http://your-server-ip/
```

### 3. 监控设置
```bash
# 安装htop监控系统资源
sudo apt install htop -y

# 设置日志监控
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 🔄 维护和更新

### 自动更新脚本
```bash
#!/bin/bash
# 自动更新部署脚本

cd /tmp
git clone https://github.com/xiaodehua2016/task-card-manager.git
sudo cp -r task-card-manager/* /var/www/html/
sudo systemctl reload nginx

echo "✅ 更新完成！"
```

### 备份策略
```bash
# 每日备份脚本
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf /backup/website-$DATE.tar.gz /var/www/html/
find /backup/ -name "website-*.tar.gz" -mtime +7 -delete
```

## 📞 技术支持

如果在部署过程中遇到问题：
1. 查看腾讯云官方文档
2. 检查服务器日志文件
3. 使用腾讯云工单系统
4. 参考项目GitHub Issues

---

**推荐配置总结：Ubuntu 20.04 LTS + 轻量应用服务器 2核2GB，月费约¥24，性价比最高！**