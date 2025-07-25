# 宝塔Linux面板部署指南

## 🎯 宝塔面板 9.6.0 腾讯云专享版评价

### ✅ **优势分析**
- 🎨 **可视化管理** - 无需记忆复杂命令行
- 🛡️ **安全性高** - 内置防火墙、SSL证书管理
- 📊 **监控完善** - 实时查看CPU、内存、磁盘使用
- 🔧 **一键安装** - Nginx、PHP、MySQL、Node.js等
- 📱 **移动端支持** - 手机APP远程管理
- 🆓 **免费版功能丰富** - 满足个人项目需求
- 🇨🇳 **中文界面** - 对国内用户友好

### ⚠️ **注意事项**
- 💾 **资源占用** - 面板本身占用约200-300MB内存
- 🔒 **安全配置** - 需要修改默认端口和密码
- 💰 **专业版收费** - 高级功能需要付费

## 🚀 宝塔面板部署方案

### 方案一：宝塔面板 + Nginx（推荐）

#### 1. 服务器配置建议
```
腾讯云轻量应用服务器
操作系统：Ubuntu 20.04 LTS 或 CentOS 7.9
CPU：2核（宝塔面板需要更多资源）
内存：2GB（面板 + 应用）
存储：50GB SSD
带宽：3Mbps
价格：约 ¥24/月
```

#### 2. 宝塔面板安装
```bash
# Ubuntu/Debian 安装命令
wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh ed8484bec

# CentOS 安装命令
yum install -y wget && wget -O install.sh https://download.bt.cn/install/install_6.0.sh && sh install.sh ed8484bec
```

#### 3. 通过宝塔面板部署项目

**步骤详解：**

1. **访问宝塔面板**
   - 浏览器打开：`http://服务器IP:8888`
   - 使用安装时显示的用户名密码登录

2. **安装运行环境**
   - 进入"软件商店"
   - 安装：Nginx 1.22、Node.js 18.x、PM2管理器
   - 等待安装完成

3. **创建网站**
   - 点击"网站" → "添加站点"
   - 域名：填写您的域名或服务器IP地址
   - 根目录：`/www/wwwroot/task-manager`
   - 点击"提交"
   
   **域名配置说明：**
   - 🌐 **有域名**：填写 `yourdomain.com`
   - 🔢 **无域名**：直接填写服务器IP地址，如 `123.456.789.123`

4. **上传项目文件**
   - 点击"文件" → 进入 `/www/wwwroot/task-manager`
   - 上传项目文件或使用Git克隆：
   ```bash
   cd /www/wwwroot/task-manager
   git clone https://github.com/xiaodehua2016/task-card-manager.git .
   ```

5. **配置Node.js应用**
   - 进入"软件商店" → "Node.js版本管理"
   - 添加Node项目：
     - 项目名称：task-manager
     - 运行目录：/www/wwwroot/task-manager
     - 启动文件：server.js
     - 端口：3000

6. **创建Express服务器文件**
   ```javascript
   // /www/wwwroot/task-manager/server.js
   const express = require('express');
   const path = require('path');
   const app = express();

   // 静态文件托管
   app.use(express.static(__dirname));

   app.get('/', (req, res) => {
       res.sendFile(path.join(__dirname, 'index.html'));
   });

   const PORT = process.env.PORT || 3000;
   app.listen(PORT, () => {
       console.log(`服务器运行在端口 ${PORT}`);
   });
   ```

7. **配置Nginx反向代理**
   - 点击网站设置 → "反向代理"
   - 添加反向代理：
     - 代理名称：task-manager
     - 目标URL：http://127.0.0.1:3000
     - 发送域名：$host
   - 保存配置

8. **启动应用**
   - 在Node.js管理中启动项目
   - 检查运行状态

### 方案二：宝塔面板 + 纯静态部署（最简单）

#### 适用场景
如果您的项目完全使用本地存储，可以直接部署静态文件：

1. **创建网站**
   - 添加站点，选择"静态网站"
   - 根目录：`/www/wwwroot/task-manager`

2. **上传文件**
   - 直接上传所有HTML、CSS、JS文件
   - 无需Node.js环境

3. **配置完成**
   - 直接访问域名即可使用

## 🔧 宝塔面板优化配置

### 1. 安全设置
```bash
# 修改面板端口（默认8888）
# 在面板设置中修改为其他端口，如：18888

# 绑定域名访问
# 设置 → 面板设置 → 域名绑定

# 开启面板SSL
# 设置 → 面板设置 → 面板SSL
```

### 2. 性能优化
```nginx
# Nginx配置优化（在网站设置中添加）
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# 启用Gzip压缩
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
```

### 3. 监控设置
- 启用"系统监控"
- 设置"监控报警"
- 配置"计划任务"进行自动备份

## 💰 成本对比

### 宝塔面板方案
| 配置 | 价格 | 适用场景 |
|------|------|----------|
| 2核2GB + 宝塔面板 | ¥24/月 | 小型项目 |
| 2核4GB + 宝塔专业版 | ¥60/月 + ¥99/年 | 商业项目 |

### 命令行方案
| 配置 | 价格 | 适用场景 |
|------|------|----------|
| 1核1GB + 命令行 | ¥15/月 | 极简项目 |
| 2核2GB + 命令行 | ¥24/月 | 标准项目 |

## 🎯 推荐选择

### 对于您的项目，推荐：

#### **宝塔面板方案**（如果预算允许）
- ✅ 管理简单，可视化操作
- ✅ 安全性高，自动更新
- ✅ 监控完善，问题及时发现
- ✅ 扩展性好，后续可添加数据库等

#### **配置建议**
```
腾讯云轻量应用服务器
操作系统：Ubuntu 20.04 LTS
CPU：2核
内存：2GB
存储：50GB SSD
带宽：3Mbps
价格：¥24/月
+ 宝塔面板免费版
```

## 🚀 一键部署脚本（宝塔版）

```bash
#!/bin/bash
# 宝塔面板 + 项目一键部署脚本

echo "🚀 开始安装宝塔面板并部署项目..."

# 安装宝塔面板
if [ -f /etc/redhat-release ]; then
    # CentOS
    yum install -y wget && wget -O install.sh https://download.bt.cn/install/install_6.0.sh && sh install.sh ed8484bec
else
    # Ubuntu/Debian
    wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh ed8484bec
fi

echo "✅ 宝塔面板安装完成！"
echo "🌐 面板地址：http://$(curl -s ifconfig.me):8888"
echo "📋 请记录登录信息，然后通过面板完成项目部署"
echo ""
echo "📝 后续步骤："
echo "1. 访问面板地址并登录"
echo "2. 安装Nginx + Node.js环境"
echo "3. 创建网站并上传项目文件"
echo "4. 配置Node.js应用或静态文件托管"
```

## 🌐 域名配置详解

### 🔢 **方案一：直接使用IP访问（无需域名）**

**优势：**
- ✅ **立即可用** - 部署完成后直接访问
- ✅ **零成本** - 无需购买域名
- ✅ **配置简单** - 直接填写IP地址

**访问方式：**
```
http://123.456.789.123
（替换为您的实际服务器IP）
```

**宝塔面板配置：**
1. 创建网站时，域名栏直接填写服务器IP
2. 例如：`123.456.789.123`
3. 部署完成后直接通过IP访问

### 🌐 **方案二：配置域名访问（推荐）**

**优势：**
- ✅ **易于记忆** - 如 `task.yourdomain.com`
- ✅ **专业形象** - 更适合分享给他人
- ✅ **SSL证书** - 可以配置HTTPS加密
- ✅ **SEO友好** - 搜索引擎更容易收录

**域名获取方式：**

#### 1. 购买域名（推荐）
```
腾讯云域名注册：
- .com域名：约 ¥55/年
- .cn域名：约 ¥29/年
- .top域名：约 ¥9/年
```

#### 2. 免费域名（临时使用）
```
免费域名服务：
- Freenom：.tk, .ml, .ga 等
- No-IP：动态DNS服务
- DuckDNS：免费子域名
```

**域名配置步骤：**

1. **购买/获取域名**
   - 在腾讯云或其他服务商注册域名
   - 如：`xiaojiu-task.com`

2. **配置DNS解析**
   - 登录域名管理后台
   - 添加A记录：
     - 主机记录：`@` 或 `www`
     - 记录值：您的服务器IP地址
     - TTL：600

3. **宝塔面板配置**
   - 创建网站时填写域名：`xiaojiu-task.com`
   - 同时添加www版本：`www.xiaojiu-task.com`

4. **SSL证书配置（可选）**
   - 在宝塔面板中申请Let's Encrypt免费证书
   - 开启强制HTTPS

### 📋 **两种方案对比**

| 特性 | IP访问 | 域名访问 |
|------|--------|----------|
| **成本** | 免费 | ¥9-55/年 |
| **配置难度** | ⭐ 极简 | ⭐⭐ 简单 |
| **访问便利性** | ⭐⭐ 需记住IP | ⭐⭐⭐⭐⭐ 易记 |
| **专业性** | ⭐⭐ 一般 | ⭐⭐⭐⭐⭐ 专业 |
| **SSL支持** | ⭐ 困难 | ⭐⭐⭐⭐⭐ 简单 |
| **分享便利性** | ⭐⭐ 一般 | ⭐⭐⭐⭐⭐ 优秀 |

### 🎯 **针对您项目的建议**

#### **阶段一：测试部署（推荐IP访问）**
```
1. 先使用IP访问测试功能
2. 确认项目运行正常
3. 无需额外成本
```

#### **阶段二：正式使用（推荐域名访问）**
```
1. 购买一个便宜的域名（如.top域名 ¥9/年）
2. 配置DNS解析
3. 申请SSL证书，开启HTTPS
4. 获得专业的访问体验
```

### 🔧 **实际操作示例**

#### 无域名部署：
```bash
# 宝塔面板创建网站
域名：123.456.789.123
访问地址：http://123.456.789.123
```

#### 有域名部署：
```bash
# 宝塔面板创建网站
域名：xiaojiu-task.com
访问地址：https://xiaojiu-task.com
```

## 📊 总结建议

**宝塔面板 9.6.0 腾讯云专享版非常适合您的项目！**

### 优势：
1. **降低技术门槛** - 可视化管理，无需命令行
2. **提高安全性** - 内置安全防护
3. **便于维护** - 图形界面，操作直观
4. **功能丰富** - 集成多种工具

### 部署建议：
- 🎯 选择2核2GB配置（¥24/月）
- 🎯 使用免费版宝塔面板
- 🎯 **初期**：直接IP访问，零额外成本
- 🎯 **后期**：购买域名，提升专业性
- 🎯 配置自动备份和监控

**最佳实践：先用IP测试，满意后再配置域名！**

## 💾 数据库存储方案

### 🎯 **重要说明：无需额外购买服务器！**

宝塔面板支持在同一台服务器上安装数据库，有以下选择：

### 方案一：同服务器部署数据库（推荐）

#### **MySQL数据库**
```
安装方式：宝塔面板 → 软件商店 → MySQL 5.7/8.0
资源占用：约300-500MB内存
适用场景：中小型项目
成本：无额外费用
```

#### **PostgreSQL数据库**
```
安装方式：宝塔面板 → 软件商店 → PostgreSQL
资源占用：约200-400MB内存
适用场景：需要高级功能的项目
成本：无额外费用
```

#### **Redis缓存**
```
安装方式：宝塔面板 → 软件商店 → Redis
资源占用：约50-100MB内存
适用场景：缓存和会话存储
成本：无额外费用
```

### 方案二：云数据库服务（高级需求）

#### **腾讯云MySQL**
```
配置：1核1GB，20GB存储
价格：约¥30-50/月
优势：专业运维，自动备份
适用：商业项目，高可用需求
```

#### **腾讯云Redis**
```
配置：1GB内存
价格：约¥20-30/月
优势：高性能，集群支持
适用：高并发缓存需求
```

### 📊 **服务器配置建议**

#### 当前配置（无数据库）
```
CPU：2核
内存：2GB
存储：50GB SSD
用途：Web应用 + 宝塔面板
剩余资源：约1.2GB内存可用
```

#### 添加数据库后配置
```
CPU：2核（够用）
内存：2GB（紧张，建议升级到4GB）
存储：50GB SSD（够用）
用途：Web应用 + 宝塔面板 + MySQL
建议升级：内存升级到4GB（约¥40/月）
```

### 🚀 **宝塔面板数据库安装步骤**

#### 1. 安装MySQL数据库
```
1. 登录宝塔面板
2. 点击"软件商店"
3. 搜索"MySQL"
4. 选择MySQL 5.7或8.0版本
5. 点击"一键安装"
6. 等待安装完成（约5-10分钟）
```

#### 2. 创建数据库
```
1. 点击"数据库"菜单
2. 点击"添加数据库"
3. 填写：
   - 数据库名：task_manager
   - 用户名：task_user
   - 密码：自动生成或自定义
4. 点击"提交"
```

#### 3. 配置项目连接
```javascript
// 数据库连接配置
const mysql = require('mysql2');
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'task_user',
    password: '您的数据库密码',
    database: 'task_manager'
});
```

### 💰 **成本对比分析**

#### 方案一：同服务器部署
```
服务器：2核4GB，50GB SSD = ¥40/月
数据库：MySQL（免费安装）
总成本：¥40/月
优势：成本低，管理简单
劣势：资源共享，性能一般
```

#### 方案二：独立云数据库
```
Web服务器：2核2GB = ¥24/月
云数据库：1核1GB MySQL = ¥35/月
总成本：¥59/月
优势：性能好，专业运维
劣势：成本高，配置复杂
```

### 🎯 **针对您项目的建议**

#### **阶段一：起步阶段（推荐）**
```
✅ 使用同服务器MySQL
✅ 升级服务器到2核4GB（¥40/月）
✅ 通过宝塔面板管理数据库
✅ 总成本：¥40/月
```

#### **阶段二：发展阶段**
```
🔄 根据访问量决定是否分离数据库
🔄 考虑使用云数据库服务
🔄 配置读写分离和备份策略
```

### 🔧 **数据库管理功能**

宝塔面板提供完整的数据库管理：

#### **基础功能**
- ✅ 数据库创建/删除
- ✅ 用户权限管理
- ✅ 数据导入/导出
- ✅ SQL在线执行
- ✅ 数据库备份/恢复

#### **高级功能**
- ✅ 性能监控
- ✅ 慢查询分析
- ✅ 自动备份计划
- ✅ 远程连接管理
- ✅ 数据库优化建议

### 📋 **项目数据库迁移方案**

如果您决定从文件存储迁移到数据库存储：

#### 1. 数据库表结构设计
```sql
-- 任务表
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    priority ENUM('high', 'medium', 'low'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 完成记录表
CREATE TABLE task_completions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT,
    completion_date DATE,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id)
);

-- 用户设置表
CREATE TABLE user_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100),
    setting_value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 2. 数据迁移脚本
```javascript
// 从文件存储迁移到数据库
async function migrateToDatabase() {
    // 读取现有文件数据
    const fileData = await fileStorage.exportAllData();
    
    // 插入到数据库
    for (const task of fileData.tasks) {
        await db.query('INSERT INTO tasks SET ?', task);
    }
    
    for (const completion of fileData.statistics) {
        await db.query('INSERT INTO task_completions SET ?', completion);
    }
}
```

### 🎊 **总结建议**

**对于您的项目，推荐方案：**

1. **当前阶段**：继续使用文件存储，成本最低
2. **需要数据库时**：升级服务器到2核4GB，安装MySQL
3. **无需额外服务器**：宝塔面板一键安装数据库
4. **总成本控制**：¥40/月包含Web应用+数据库

**关键优势：**
- ✅ 无需额外购买服务器
- ✅ 宝塔面板一键安装管理
- ✅ 成本可控，按需升级
- ✅ 完整的数据库管理功能

**这样既满足了数据库需求，又控制了成本！**
