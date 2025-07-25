# PM2在宝塔面板中的安装和配置指南

## 🎯 PM2安装方法

### 方法一：通过Node.js版本管理器（推荐）

#### 1. 安装Node.js版本管理器
```
宝塔面板 → 软件商店 → 搜索"Node.js版本管理器"
点击"安装"（等待3-5分钟）
```

#### 2. 安装Node.js环境
```
软件商店 → Node.js版本管理器 → 设置
可选版本：
- Node.js 18.x（LTS，推荐）
- Node.js 20.x（LTS，最新稳定）
- Node.js 22.x（最新版本）
点击"安装版本"
等待安装完成
```
# PM2在宝塔面板中的安装和配置指南

## 🎯 PM2安装方法

### 方法一：通过Node.js版本管理器（推荐）

#### 1. 安装Node.js版本管理器
```
宝塔面板 → 软件商店 → 搜索"Node.js版本管理器"
点击"安装"（等待3-5分钟）
```


#### 3. 安装PM2模块
```
Node.js版本管理器 → 设置 → 模块管理
在"安装模块"输入框中输入：pm2
点击"安装模块"
等待安装完成
```

### 方法二：SSH命令安装

```bash
# 连接服务器
ssh root@115.159.5.111

# 确认Node.js已安装
node --version
npm --version

# 全局安装PM2
npm install -g pm2

# 验证PM2安装
pm2 --version
pm2 list
```

### 方法三：宝塔终端安装

```
宝塔面板 → 终端
执行以下命令：

# 安装PM2
npm install -g pm2

# 验证安装
pm2 --version
```

## 🚀 PM2项目配置

### 1. 创建Node.js项目

#### 在宝塔面板中配置
```
Node.js版本管理器 → 项目管理 → 添加Node项目

项目配置：
- 项目名称：task-manager
- 运行目录：/www/wwwroot/task-manager
- 启动文件：server.js
- 端口：3000
- 运行方式：PM2
- Node版本：18.x
```

### 2. 创建服务器文件

在项目目录创建 `server.js`：

```javascript
const express = require('express');
const path = require('path');
const app = express();

// 静态文件托管
app.use(express.static(__dirname));

// 主页路由
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// 健康检查
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
```

### 3. 安装项目依赖

```bash
cd /www/wwwroot/task-manager
npm init -y
npm install express --save
```

### 4. PM2配置文件

创建 `ecosystem.config.js`：

```javascript
module.exports = {
  apps: [{
    name: 'task-manager',
    script: 'server.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '300M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
```

## 🔧 PM2管理命令

### 基础命令
```bash
# 启动应用
pm2 start ecosystem.config.js

# 查看所有进程
pm2 list

# 查看详细信息
pm2 show task-manager

# 实时监控
pm2 monit

# 查看日志
pm2 logs task-manager

# 重启应用
pm2 restart task-manager

# 停止应用
pm2 stop task-manager

# 删除应用
pm2 delete task-manager
```

### 高级命令
```bash
# 保存当前进程列表
pm2 save

# 设置开机自启
pm2 startup

# 重载应用（零停机）
pm2 reload task-manager

# 清空日志
pm2 flush
```

## 🌐 Nginx反向代理配置

### 在宝塔面板中配置

```
网站 → 选择您的网站 → 设置 → 反向代理

添加反向代理：
- 代理名称：task-manager
- 目标URL：http://127.0.0.1:3000
- 发送域名：$host
- 内容替换：留空
```

### 手动Nginx配置
```nginx
server {
    listen 80;
    server_name 115.159.5.111;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 📊 监控和日志

### 1. 实时监控
```bash
# 查看实时状态
pm2 monit

# 显示信息：
# ┌─────────────────────────────────────────────────────────────────┐
# │ task-manager                                                    │
# │ status: online                                                  │
# │ cpu: 2%                                                         │
# │ memory: 45MB                                                    │
# │ ├─ pid: 12345                                                   │
# │ └─ uptime: 2h                                                   │
# └─────────────────────────────────────────────────────────────────┘
```

### 2. 日志管理
```bash
# 查看实时日志
pm2 logs task-manager --lines 50

# 查看错误日志
pm2 logs task-manager --err

# 清空日志
pm2 flush task-manager
```

### 3. 宝塔面板监控
```
Node.js版本管理器 → 项目管理 → task-manager → 管理

可以看到：
- 运行状态
- CPU使用率
- 内存使用量
- 启动时间
- 重启次数
```

## 🔧 故障排除

### 常见问题及解决方案

#### 1. PM2命令找不到
```bash
# 检查PM2是否安装
which pm2

# 如果没有，重新安装
npm install -g pm2

# 检查PATH环境变量
echo $PATH
```

#### 2. 应用启动失败
```bash
# 查看错误日志
pm2 logs task-manager --err

# 检查端口是否被占用
netstat -tlnp | grep 3000

# 手动测试启动
node server.js
```

#### 3. 宝塔面板中看不到PM2项目
```bash
# 确认PM2进程
pm2 list

# 重新添加到宝塔面板
# Node.js版本管理器 → 项目管理 → 添加Node项目
```

#### 4. 反向代理不工作
```bash
# 检查Nginx配置
nginx -t

# 重启Nginx
systemctl restart nginx

# 检查端口监听
netstat -tlnp | grep 80
```

## 🎯 最佳实践

### 1. 生产环境配置
```javascript
// ecosystem.config.js 生产环境配置
module.exports = {
  apps: [{
    name: 'task-manager',
    script: 'server.js',
    instances: 1,  // 4GB内存建议1个实例
    autorestart: true,
    watch: false,
    max_memory_restart: '300M',
    min_uptime: '10s',
    max_restarts: 10,
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
```

### 2. 日志轮转配置
```bash
# 安装pm2-logrotate
pm2 install pm2-logrotate

# 配置日志轮转
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true
```

### 3. 监控报警
```bash
# 安装监控模块
pm2 install pm2-server-monit

# 配置报警
pm2 set pm2-server-monit:cpu_threshold 80
pm2 set pm2-server-monit:memory_threshold 80
```

## 📋 部署检查清单

### 安装验证
- [ ] Node.js版本管理器已安装
- [ ] Node.js 18.x已安装
- [ ] PM2模块已安装
- [ ] PM2命令可用

### 项目配置
- [ ] 项目文件已上传
- [ ] server.js文件已创建
- [ ] package.json已配置
- [ ] 依赖包已安装

### PM2配置
- [ ] PM2项目已添加
- [ ] 应用可以启动
- [ ] 反向代理已配置
- [ ] 开机自启已设置

### 功能测试
- [ ] 网站可以访问
- [ ] 应用功能正常
- [ ] 日志记录正常
- [ ] 监控数据正常

## 🎊 总结

通过以上步骤，您可以在宝塔面板中成功安装和配置PM2：

1. **安装简单** - 通过Node.js版本管理器一键安装
2. **管理方便** - 宝塔面板可视化管理
3. **监控完善** - 实时查看应用状态
4. **稳定可靠** - 自动重启和故障恢复

**您的4核4GB服务器配置完全可以支撑PM2 + Node.js应用的稳定运行！**