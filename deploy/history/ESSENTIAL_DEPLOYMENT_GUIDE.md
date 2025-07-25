# 项目部署必需环境和操作指南
## 小久任务管理系统 - 服务器部署文档

## 🎯 项目部署必需环境清单

### 📋 基础必需环境

#### 1. 服务器硬件要求
```
✅ CPU：2核以上（推荐4核）
✅ 内存：2GB以上（推荐4GB）
✅ 存储：20GB以上可用空间
✅ 带宽：1Mbps以上
✅ 操作系统：Ubuntu 20.04 LTS 或 CentOS 7.9
```

#### 2. 必需软件环境
```
✅ Nginx - Web服务器（必需）
✅ Node.js 20.x - 应用运行环境（必需）
✅ MySQL 5.7 - 数据库（推荐，可选）
✅ Git - 代码管理（必需）
✅ PM2 - 进程管理器（推荐）
```

#### 3. 网络环境要求
```
✅ 公网IP地址
✅ 开放端口：22(SSH), 80(HTTP), 443(HTTPS), 8888(宝塔面板)
✅ 域名（可选，建议配置）
```

### ❌ 不需要的软件
```
❌ Apache2 - 与Nginx功能重复
❌ PHP - 项目不使用PHP
❌ Redis - 小型项目暂不需要
❌ Docker - 直接部署更简单
```

## 🚀 完整部署操作文档

### 阶段一：服务器基础环境准备

#### 1. 连接服务器
```bash
# SSH连接服务器
ssh root@115.159.5.111

# 首次连接输入yes确认，然后输入密码
```

#### 2. 系统更新和基础软件安装
```bash
# 更新系统包
apt update && apt upgrade -y

# 安装必需的基础软件
apt install -y wget curl git htop

# 验证安装
which wget curl git
```

#### 3. 安装宝塔面板（推荐）
```bash
# Ubuntu系统安装宝塔面板
wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh ed8484bec

# 安装完成后记录面板信息：
# 面板地址：http://115.159.5.111:8888
# 用户名：xxxxxxxx
# 密码：xxxxxxxx
```

### 阶段二：Web服务器环境配置

#### 1. 通过宝塔面板安装Nginx
```
1. 浏览器访问：http://115.159.5.111:8888
2. 使用安装时显示的用户名密码登录
3. 点击"软件商店"
4. 搜索"Nginx"，选择版本1.22
5. 点击"一键安装"，等待完成
```

#### 2. 验证Nginx安装
```bash
# 检查Nginx版本
nginx -v

# 检查Nginx服务状态
systemctl status nginx

# 测试访问
curl http://115.159.5.111
```

### 阶段三：Node.js环境配置

#### 1. 安装Node.js版本管理器
```
宝塔面板 → 软件商店 → 搜索"Node.js版本管理器" → 安装
```

#### 2. 安装Node.js
```
Node.js版本管理器 → 设置 → 选择Node.js 20.x → 安装版本
```

#### 3. 安装PM2进程管理器
```
Node.js版本管理器 → 设置 → 模块管理 → 输入"pm2" → 安装模块
```

#### 4. 验证Node.js环境
```bash
# 检查Node.js版本
node --version

# 检查NPM版本
npm --version

# 检查PM2版本
pm2 --version
```

### 阶段四：数据库环境配置（可选）

#### 1. 安装MySQL数据库
```
宝塔面板 → 软件商店 → 搜索"MySQL" → 选择5.7版本 → 安装
```

#### 2. 创建数据库
```
宝塔面板 → 数据库 → 添加数据库
- 数据库名：task_manager
- 用户名：task_user
- 密码：自动生成（记录下来）
```

#### 3. 验证数据库
```bash
# 测试MySQL连接
mysql -u task_user -p
# 输入密码后应该能成功连接
```

### 阶段五：项目代码部署

#### 1. 创建项目目录
```bash
# 创建Web根目录
mkdir -p /www/wwwroot/task-manager
cd /www/wwwroot/task-manager

# 设置目录权限
chown -R www-data:www-data /www/wwwroot/task-manager
chmod -R 755 /www/wwwroot/task-manager
```

#### 2. 下载项目代码
```bash
# 克隆项目代码
git clone https://github.com/xiaodehua2016/task-card-manager.git .

# 检查项目文件
ls -la
```

#### 3. 安装项目依赖
```bash
# 初始化package.json（如果没有）
npm init -y

# 安装Express依赖
npm install express --save

# 检查安装结果
ls -la node_modules/
```

### 阶段六：应用服务配置

#### 1. 创建Node.js服务器文件
```bash
# 创建server.js文件
cat > server.js << 'EOF'
const express = require('express');
const path = require('path');
const app = express();

// 静态文件托管
app.use(express.static(__dirname));

// 主页路由
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// 健康检查接口
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ 任务管理系统运行在端口 ${PORT}`);
});
EOF
```

#### 2. 配置PM2应用
```
宝塔面板 → Node.js版本管理器 → 项目管理 → 添加Node项目

项目配置：
- 项目名称：task-manager
- 运行目录：/www/wwwroot/task-manager
- 启动文件：server.js
- 端口：3000
- 运行方式：PM2
- Node版本：20.x
```

#### 3. 启动应用
```bash
# 通过PM2启动应用
pm2 start server.js --name task-manager

# 检查应用状态
pm2 list
pm2 logs task-manager
```

### 阶段七：Nginx反向代理配置

#### 1. 创建网站
```
宝塔面板 → 网站 → 添加站点
- 域名：115.159.5.111（或您的域名）
- 根目录：/www/wwwroot/task-manager
```

#### 2. 配置反向代理
```
网站设置 → 反向代理 → 添加反向代理
- 代理名称：task-manager
- 目标URL：http://127.0.0.1:3000
- 发送域名：$host
```

#### 3. 测试访问
```bash
# 测试本地访问
curl http://127.0.0.1:3000

# 测试外网访问
curl http://115.159.5.111
```

### 阶段八：安全和优化配置

#### 1. 防火墙配置
```bash
# 开放必要端口
ufw allow 22      # SSH
ufw allow 80      # HTTP
ufw allow 443     # HTTPS
ufw allow 8888    # 宝塔面板
ufw enable
```

#### 2. 设置开机自启
```bash
# PM2开机自启
pm2 save
pm2 startup

# 按提示执行生成的命令
```

#### 3. 配置SSL证书（可选）
```
网站设置 → SSL → Let's Encrypt → 申请免费证书
```

## 📋 部署验证清单

### 基础环境验证
- [ ] SSH可以正常连接服务器
- [ ] 系统版本正确（Ubuntu 20.04）
- [ ] 内存4GB，CPU4核确认
- [ ] 磁盘空间充足（>10GB可用）

### 软件环境验证
- [ ] 宝塔面板可以正常访问（http://115.159.5.111:8888）
- [ ] Nginx已安装并运行
- [ ] Node.js 20.x已安装
- [ ] PM2已安装并可用
- [ ] MySQL 5.7已安装（如果需要数据库）

### 项目部署验证
- [ ] 项目代码已下载到服务器
- [ ] Node.js依赖已安装
- [ ] PM2应用已启动
- [ ] Nginx反向代理已配置

### 功能验证
- [ ] 网站可以正常访问（http://115.159.5.111）
- [ ] 任务管理功能正常
- [ ] 数据存储功能正常
- [ ] 移动端访问正常

## 🔧 常见问题解决

### 1. 宝塔面板无法访问
```bash
# 检查宝塔面板状态
/etc/init.d/bt status

# 重启宝塔面板
/etc/init.d/bt restart

# 查看面板信息
bt default
```

### 2. Nginx启动失败
```bash
# 检查Nginx配置
nginx -t

# 查看错误日志
tail -f /var/log/nginx/error.log

# 重启Nginx
systemctl restart nginx
```

### 3. Node.js应用无法启动
```bash
# 查看PM2日志
pm2 logs task-manager

# 手动测试启动
cd /www/wwwroot/task-manager
node server.js

# 检查端口占用
netstat -tlnp | grep 3000
```

### 4. 网站无法访问
```bash
# 检查防火墙
ufw status

# 检查端口监听
netstat -tlnp | grep :80

# 测试本地访问
curl http://127.0.0.1
```

## 🎯 部署后的管理

### 日常维护命令
```bash
# 查看应用状态
pm2 list
pm2 monit

# 重启应用
pm2 restart task-manager

# 更新代码
cd /www/wwwroot/task-manager
git pull origin main
pm2 restart task-manager

# 查看系统状态
htop
df -h
```

### 备份策略
```bash
# 备份项目文件
tar -czf /backup/task-manager-$(date +%Y%m%d).tar.gz /www/wwwroot/task-manager/

# 备份数据库（如果使用）
mysqldump -u task_user -p task_manager > /backup/database-$(date +%Y%m%d).sql
```

## 💰 成本分析

### 服务器成本
```
腾讯云轻量应用服务器 4核4GB：约¥60-80/月
域名费用（可选）：约¥50/年
SSL证书：免费（Let's Encrypt）
总成本：约¥60-80/月
```

### 性能预期
```
支持并发用户：200-500人
日访问量：10000-50000次
响应时间：< 200ms
可用性：99.9%+
```

## 🚀 一键部署脚本

```bash
#!/bin/bash
# 一键部署脚本

echo "🚀 开始部署小久任务管理系统..."

# 1. 更新系统
apt update && apt upgrade -y

# 2. 安装基础软件
apt install -y wget curl git htop

# 3. 安装宝塔面板
wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh ed8484bec

echo "✅ 基础环境安装完成！"
echo "📋 下一步请访问宝塔面板完成Web环境配置："
echo "🌐 面板地址：http://115.159.5.111:8888"
echo ""
echo "📝 后续步骤："
echo "1. 登录宝塔面板"
echo "2. 安装 Nginx + Node.js + MySQL"
echo "3. 创建网站和数据库"
echo "4. 部署项目代码"
echo "5. 配置PM2和反向代理"
```

## 📞 技术支持

如果在部署过程中遇到问题：

1. **查看日志文件**
   - Nginx: `/var/log/nginx/error.log`
   - PM2: `pm2 logs task-manager`
   - 系统: `journalctl -xe`

2. **检查服务状态**
   - `systemctl status nginx`
   - `pm2 list`
   - `/etc/init.d/bt status`

3. **网络连接测试**
   - `ping 115.159.5.111`
   - `telnet 115.159.5.111 80`
   - `curl http://115.159.5.111`

---

**按照此文档操作，您可以成功部署小久任务管理系统到您的4核4GB服务器上！**