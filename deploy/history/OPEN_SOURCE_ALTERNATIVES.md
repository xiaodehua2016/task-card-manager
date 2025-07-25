# 国内开源免费全栈部署方案

## 🆓 完全免费的开源替代方案

### 方案一：自建服务器 + 开源软件栈（推荐）

#### 1. 服务器选择
**国内VPS提供商**：
- **腾讯云轻量应用服务器**：24元/月（学生9.9元/月）
- **阿里云ECS**：30元/月（新用户优惠）
- **华为云**：25元/月
- **UCloud**：20元/月
- **青云QingCloud**：18元/月

**配置推荐**：
- CPU：1核心
- 内存：1GB
- 存储：40GB SSD
- 带宽：1-3Mbps

#### 2. 开源软件栈
```
Nginx + Node.js + MySQL + PM2
    ↓       ↓        ↓      ↓
  反向代理  后端服务  数据库  进程管理
```

#### 3. 详细部署架构
```bash
# 服务器软件安装
sudo apt update
sudo apt install nginx mysql-server nodejs npm

# 安装PM2进程管理器
npm install -g pm2

# 安装SSL证书（Let's Encrypt免费）
sudo apt install certbot python3-certbot-nginx
```

### 方案二：Docker容器化部署

#### 1. Docker Compose配置
```yaml
# docker-compose.yml
version: '3.8'
services:
  # 前端静态文件服务
  frontend:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./dist:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - backend

  # 后端API服务
  backend:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=database
      - DB_USER=root
      - DB_PASSWORD=your_password
      - DB_NAME=task_manager
    depends_on:
      - database

  # MySQL数据库
  database:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=your_password
      - MYSQL_DATABASE=task_manager
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"

  # Redis缓存（可选）
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

volumes:
  mysql_data:
```

#### 2. Nginx配置
```nginx
# nginx.conf
server {
    listen 80;
    server_name your-domain.com;
    
    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    # SSL配置
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # 前端静态文件
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
        
        # 缓存配置
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API代理
    location /api/ {
        proxy_pass http://backend:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 方案三：Serverless + 开源数据库

#### 1. 前端部署：Gitee Pages（免费）
```yaml
# .gitee/workflows/pages.yml
name: Gitee Pages
on:
  push:
    branches: [ main ]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: 检出代码
        uses: actions/checkout@v2
      
      - name: 构建项目
        run: |
          # 如果需要构建步骤
          echo "项目构建完成"
      
      - name: 部署到Gitee Pages
        uses: yanglbme/gitee-pages-action@main
        with:
          gitee-username: ${{ secrets.GITEE_USERNAME }}
          gitee-password: ${{ secrets.GITEE_PASSWORD }}
          gitee-repo: your-repo-name
```

#### 2. 后端API：Railway（免费额度）
```javascript
// 使用Railway部署Node.js后端
// package.json
{
  "name": "task-manager-api",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "mysql2": "^3.0.0",
    "cors": "^2.8.5"
  }
}
```

#### 3. 数据库：PlanetScale（免费）
```javascript
// 数据库连接配置
const mysql = require('mysql2/promise');

const connection = mysql.createConnection({
  host: process.env.DATABASE_HOST,
  username: process.env.DATABASE_USERNAME,
  password: process.env.DATABASE_PASSWORD,
  database: process.env.DATABASE_NAME,
  ssl: {
    rejectUnauthorized: false
  }
});
```

## 🛠️ 完全开源的技术栈

### 技术选型
```
前端：原生HTML/CSS/JavaScript（无框架依赖）
后端：Node.js + Express
数据库：MySQL 8.0 / PostgreSQL
缓存：Redis（可选）
反向代理：Nginx
进程管理：PM2
SSL证书：Let's Encrypt（免费）
监控：Grafana + Prometheus（开源）
```

### 后端API实现
```javascript
// server.js - 简单的Express后端
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());

// 数据库连接
const db = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'task_manager'
});

// API路由
app.get('/api/tasks', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/tasks', async (req, res) => {
  try {
    const { title, description, category, priority } = req.body;
    const [result] = await db.execute(
      'INSERT INTO tasks (id, title, description, category, priority) VALUES (UUID(), ?, ?, ?, ?)',
      [title, description, category, priority]
    );
    res.json({ success: true, id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`服务器运行在端口 ${port}`);
});
```

## 📊 成本对比分析

### 完全免费方案
| 服务 | 提供商 | 费用 | 限制 |
|------|--------|------|------|
| 前端托管 | Gitee Pages | ¥0 | 1GB空间 |
| 后端API | Railway | ¥0 | 500小时/月 |
| 数据库 | PlanetScale | ¥0 | 1GB存储 |
| 域名 | Freenom | ¥0 | .tk/.ml域名 |
| SSL证书 | Let's Encrypt | ¥0 | 90天续期 |
| **总计** | | **¥0** | 适合个人项目 |

### 低成本自建方案
| 服务 | 费用 | 说明 |
|------|------|------|
| VPS服务器 | ¥20-30/月 | 1核1GB配置 |
| 域名 | ¥30-50/年 | .com/.cn域名 |
| **总计** | **¥25-35/月** | 完全自主控制 |

### 与商业方案对比
| 方案 | 月成本 | 控制权 | 扩展性 | 维护难度 |
|------|--------|--------|--------|----------|
| 腾讯云全栈 | ¥50-150 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| 开源自建 | ¥25-35 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 完全免费 | ¥0 | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |

## 🚀 推荐实施方案

### 方案A：学习型项目（完全免费）
```
Gitee Pages + Railway + PlanetScale
适合：个人学习、小型项目
优势：零成本、快速上线
劣势：功能限制、依赖第三方
```

### 方案B：专业项目（低成本自建）
```
VPS + Docker + MySQL + Nginx
适合：商业项目、长期运营
优势：完全控制、性能稳定
劣势：需要运维知识
```

### 方案C：混合方案（推荐）
```
前端：Gitee Pages（免费）
后端：自建VPS（¥25/月）
数据库：自建MySQL
CDN：七牛云（免费额度）
```

## 🛠️ 快速部署脚本

### 一键部署脚本
```bash
#!/bin/bash
# deploy.sh - 一键部署脚本

echo "开始部署任务管理系统..."

# 1. 更新系统
sudo apt update && sudo apt upgrade -y

# 2. 安装必要软件
sudo apt install -y nginx mysql-server nodejs npm git

# 3. 安装PM2
sudo npm install -g pm2

# 4. 克隆项目
git clone https://github.com/xiaodehua2016/task-card-manager.git
cd task-card-manager

# 5. 安装依赖
npm install

# 6. 配置数据库
sudo mysql -e "CREATE DATABASE task_manager;"
sudo mysql -e "CREATE USER 'taskuser'@'localhost' IDENTIFIED BY 'password123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON task_manager.* TO 'taskuser'@'localhost';"
sudo mysql task_manager < init.sql

# 7. 启动服务
pm2 start server.js --name "task-manager"
pm2 startup
pm2 save

# 8. 配置Nginx
sudo cp nginx.conf /etc/nginx/sites-available/task-manager
sudo ln -s /etc/nginx/sites-available/task-manager /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo "部署完成！访问 http://your-server-ip"
```

## 💡 最终推荐

### 立即可行方案：混合部署
1. **前端**：部署到Gitee Pages（免费，国内访问快）
2. **后端**：使用Railway或自建VPS（低成本）
3. **数据库**：PlanetScale免费版或自建MySQL

### 长期发展方案：完全自建
1. **服务器**：国内VPS（¥25/月）
2. **技术栈**：Docker + Nginx + Node.js + MySQL
3. **监控**：Grafana + Prometheus
4. **备份**：定时数据库备份

这样既能解决国内访问问题，又能保持低成本和高度可控性。您希望从哪个方案开始实施？