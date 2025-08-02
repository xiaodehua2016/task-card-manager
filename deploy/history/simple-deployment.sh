#!/bin/bash
# 小访问量项目超简单部署脚本

echo "🚀 开始部署小久任务管理系统（简化版）..."

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs git

# 克隆项目
cd /home/ubuntu
git clone https://github.com/xiaodehua2016/task-card-manager.git
cd task-card-manager

# 创建简单的Express服务器
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

// 健康检查
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 80;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ 小久任务管理系统运行在端口 ${PORT}`);
    console.log(`🌐 访问地址: http://$(curl -s ifconfig.me)`);
});
EOF

# 安装依赖
npm init -y
npm install express --save

# 创建系统服务
sudo tee /etc/systemd/system/task-manager.service > /dev/null << 'EOF'
[Unit]
Description=Task Manager Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/task-card-manager
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
sudo systemctl daemon-reload
sudo systemctl enable task-manager
sudo systemctl start task-manager

# 配置防火墙
sudo ufw allow 80
sudo ufw --force enable

echo "✅ 部署完成！"
echo "🌐 访问地址：http://$(curl -s ifconfig.me)"
echo "📊 服务状态：sudo systemctl status task-manager"
echo "📝 查看日志：sudo journalctl -u task-manager -f"