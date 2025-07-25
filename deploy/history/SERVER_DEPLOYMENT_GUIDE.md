# 云服务器部署操作指南
## 服务器信息：115.159.5.111 (4核4GB)

## 🎯 部署前准备

### 服务器配置确认
```
IP地址：115.159.5.111
CPU：4核
内存：4GB
配置评价：✅ 优秀，完全满足项目需求
```

### 推荐部署方案
基于您的配置，推荐使用 **宝塔面板 + MySQL数据库** 方案

## 🚀 详细部署步骤

### 第一步：连接服务器

#### 方法一：SSH连接（推荐）
```bash
# Windows用户使用PowerShell或CMD
ssh root@115.159.5.111

# 首次连接需要输入密码
# 密码通常在腾讯云控制台可以查看或重置
```

#### 方法二：腾讯云控制台
```
1. 登录腾讯云控制台
2. 找到您的云服务器实例
3. 点击"登录"按钮
4. 选择"标准登录"
```

### 第二步：安装宝塔面板

#### Ubuntu系统安装命令
```bash
# 更新系统
apt update && apt upgrade -y

# 安装宝塔面板
wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh ed8484bec
```

#### CentOS系统安装命令
```bash
# 更新系统
yum update -y

# 安装宝塔面板
yum install -y wget && wget -O install.sh https://download.bt.cn/install/install_6.0.sh && sh install.sh ed8484bec
```

**安装完成后会显示：**
```
面板地址：http://115.159.5.111:8888
用户名：xxxxxxxx
密码：xxxxxxxx
```

### 第三步：配置宝塔面板

#### 1. 访问面板
```
浏览器打开：http://115.159.5.111:8888
输入安装时显示的用户名和密码
```

#### 2. 安装运行环境
在宝塔面板中安装以下软件：
```
✅ Nginx 1.22
✅ MySQL 5.7（推荐，4GB内存最佳选择）
✅ PHP 7.4（可选）
✅ Node.js 18.x
✅ PM2管理器
✅ Redis（可选）
```

**MySQL版本选择建议：**

#### MySQL 5.7（强烈推荐）
```
内存占用：约400-600MB
启动时间：快速（10-15秒）
稳定性：✅ 非常稳定，久经考验
兼容性：✅ 完美兼容所有Node.js库
性能：✅ 4GB内存下性能最佳
维护：✅ 文档丰富，问题解决方案多
```

#### MySQL 8.0（不推荐4GB内存）
```
内存占用：约600-1000MB
启动时间：较慢（20-30秒）
稳定性：✅ 稳定，但相对较新
兼容性：⚠️ 部分老版本Node.js库可能有问题
性能：⚠️ 4GB内存下可能吃紧
新特性：✅ 更多高级功能，但小项目用不到
```

#### 3. 安全设置
```
1. 修改面板端口：8888 → 18888（更安全）
2. 修改面板密码
3. 绑定域名（可选）
4. 开启面板SSL（可选）
```

### 第四步：部署项目

#### 方案一：纯静态部署（最简单）

1. **创建网站**
```
网站 → 添加站点
域名：115.159.5.111 或您的域名
根目录：/www/wwwroot/task-manager
```

2. **上传项目文件**
```bash
# 方法1：通过宝塔面板文件管理器上传
# 方法2：使用Git克隆
cd /www/wwwroot/task-manager
git clone https://github.com/xiaodehua2016/task-card-manager.git .
```

3. **配置完成**
```
访问地址：http://115.159.5.111
项目立即可用！
```

#### 方案二：Node.js + 数据库部署（推荐）

1. **创建网站和数据库**
```
网站 → 添加站点
域名：115.159.5.111
根目录：/www/wwwroot/task-manager

数据库 → 添加数据库
数据库名：task_manager
用户名：task_user
密码：自动生成
```

2. **上传并配置项目**
```bash
cd /www/wwwroot/task-manager
git clone https://github.com/xiaodehua2016/task-card-manager.git .

# 创建Node.js服务器文件
cat > server.js << 'EOF'
const express = require('express');
const mysql = require('mysql2');
const path = require('path');
const app = express();

// 数据库连接
const db = mysql.createConnection({
    host: 'localhost',
    user: 'task_user',
    password: '您的数据库密码',
    database: 'task_manager'
});

// 静态文件托管
app.use(express.static(__dirname));
app.use(express.json());

// 主页路由
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// API路由示例
app.get('/api/tasks', (req, res) => {
    db.query('SELECT * FROM tasks', (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results);
        }
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`服务器运行在端口 ${PORT}`);
});
EOF

# 安装依赖
npm init -y
npm install express mysql2 --save
```

3. **配置Node.js应用**
```
软件商店 → Node.js版本管理 → 添加Node项目
项目名称：task-manager
运行目录：/www/wwwroot/task-manager
启动文件：server.js
端口：3000
```

4. **配置Nginx反向代理**
```
网站设置 → 反向代理 → 添加反向代理
代理名称：task-manager
目标URL：http://127.0.0.1:3000
发送域名：$host
```

### 第五步：安全配置

#### 1. 防火墙设置
```bash
# 开放必要端口
ufw allow 22      # SSH
ufw allow 80      # HTTP
ufw allow 443     # HTTPS
ufw allow 18888   # 宝塔面板（如果修改了端口）
ufw enable
```

#### 2. 腾讯云安全组
```
1. 登录腾讯云控制台
2. 云服务器 → 安全组
3. 配置规则：
   - 入站：22, 80, 443, 18888
   - 出站：全部允许
```

### 第六步：域名配置（可选）

#### 如果您有域名
```
1. 域名DNS解析：
   - A记录：@ → 115.159.5.111
   - A记录：www → 115.159.5.111

2. 宝塔面板修改网站域名：
   - 原：115.159.5.111
   - 改为：yourdomain.com

3. 申请SSL证书：
   - 网站设置 → SSL → Let's Encrypt
   - 一键申请免费证书
```

## 🔧 部署后验证

### 1. 功能测试
```
✅ 访问 http://115.159.5.111
✅ 任务管理功能正常
✅ 数据存储功能正常
✅ 移动端访问正常
```

### 2. 性能测试
```bash
# 测试响应时间
curl -o /dev/null -s -w "%{time_total}\n" http://115.159.5.111

# 测试并发性能
ab -n 100 -c 10 http://115.159.5.111/
```

### 3. 监控设置
```
宝塔面板 → 监控 → 开启系统监控
设置监控报警（CPU、内存、磁盘）
配置自动备份计划
```

## 📊 部署后的管理

### 日常维护命令
```bash
# 查看系统状态
htop

# 查看Nginx日志
tail -f /www/wwwroot/task-manager/logs/access.log

# 重启服务
systemctl restart nginx
systemctl restart mysql

# 更新项目代码
cd /www/wwwroot/task-manager
git pull origin main
```

### 宝塔面板管理
```
系统状态监控：实时查看CPU、内存使用
文件管理：在线编辑项目文件
数据库管理：SQL执行、备份恢复
计划任务：自动备份、日志清理
```

## 💰 成本分析

### 当前配置成本
```
云服务器：4核4GB = 约¥60-80/月
宝塔面板：免费版
数据库：MySQL（免费）
总成本：¥60-80/月
```

### 性能评估
```
✅ CPU：4核 - 优秀，支持高并发
✅ 内存：4GB - 充足，可运行多个服务
✅ 适用访问量：日访问量 < 50000次
✅ 并发用户：< 500人同时在线
```

## 🎯 推荐部署方案

基于您的服务器配置，推荐以下方案：

### 阶段一：快速上线
```
1. 安装宝塔面板
2. 部署静态文件版本
3. 使用IP访问：http://115.159.5.111
4. 验证功能正常
```

### 阶段二：完整功能
```
1. 安装MySQL数据库
2. 部署Node.js版本
3. 配置数据库存储
4. 开启监控和备份
```

### 阶段三：优化提升
```
1. 购买域名并配置SSL
2. 开启CDN加速
3. 配置负载均衡（如需要）
4. 性能调优
```

## 🚀 一键部署脚本

```bash
#!/bin/bash
# 115.159.5.111 服务器一键部署脚本

echo "🚀 开始部署小久任务管理系统到 115.159.5.111..."

# 更新系统
apt update && apt upgrade -y

# 安装宝塔面板
wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh ed8484bec

echo "✅ 宝塔面板安装完成！"
echo "🌐 面板地址：http://115.159.5.111:8888"
echo "📋 请记录登录信息，然后继续以下步骤："
echo ""
echo "📝 后续操作："
echo "1. 访问面板并安装 Nginx + MySQL + Node.js"
echo "2. 创建网站：115.159.5.111"
echo "3. 上传项目文件"
echo "4. 配置数据库连接"
echo "5. 启动Node.js应用"
echo ""
echo "🎉 部署完成后访问：http://115.159.5.111"
```

## 📞 技术支持

如果部署过程中遇到问题：
1. 检查服务器防火墙设置
2. 查看宝塔面板错误日志
3. 确认腾讯云安全组配置
4. 参考项目GitHub文档

---

**您的4核4GB服务器配置非常优秀，完全可以支撑项目的长期发展！**