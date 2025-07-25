# 快速部署检查清单
## 小久任务管理系统 - 部署步骤速查

## 🎯 必需环境清单

### ✅ 硬件要求
- [ ] CPU：4核
- [ ] 内存：4GB  
- [ ] 存储：>20GB
- [ ] 公网IP：115.159.5.111

### ✅ 必需软件
- [ ] Ubuntu 20.04 LTS
- [ ] Nginx（Web服务器）
- [ ] Git（代码管理）

### 🔄 可选软件（根据需求选择）
- [ ] MySQL 5.7（如需数据库存储）
- [ ] Node.js 20.x（如需后端API，当前项目不需要）
- [ ] PM2（如使用Node.js时需要）

### ❌ 不需要的软件
- [ ] Apache2（与Nginx冲突）
- [ ] PHP（项目不使用）
- [ ] Docker（直接部署更简单）

## 🚀 部署步骤速查

### 第1步：连接服务器
```bash
ssh root@115.159.5.111
```

### 第2步：安装宝塔面板
```bash
wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh ed8484bec
```

### 第3步：通过宝塔面板安装环境
```
访问：http://115.159.5.111:8888
安装：Nginx（仅需要Web服务器）
```

### 第4步：部署项目代码
```bash
cd /www/wwwroot/task-manager
git clone https://github.com/xiaodehua2016/task-card-manager.git .
```

### 第5步：配置网站
```
宝塔面板 → 网站 → 添加站点
域名：115.159.5.111
根目录：/www/wwwroot/task-manager
```

### 第6步：设置默认首页
```
网站设置 → 默认文档 → 添加 index.html
```

### 第7步：验证部署
```bash
curl http://115.159.5.111
pm2 list
```

## ✅ 验证清单

### 基础验证
- [ ] 宝塔面板可访问
- [ ] Nginx服务运行正常
- [ ] 网站配置正确
- [ ] 静态文件可访问

### 功能验证  
- [ ] 网站可以正常访问
- [ ] 任务管理功能正常
- [ ] 数据存储功能正常

## 🔧 故障排查

### 常用命令
```bash
# 检查服务状态
systemctl status nginx
/etc/init.d/bt status

# 查看日志
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# 重启服务
systemctl restart nginx
```

### 常见问题
1. **宝塔面板无法访问** → 检查8888端口和防火墙
2. **网站无法访问** → 检查Nginx配置和网站设置
3. **静态文件无法加载** → 检查文件权限和路径配置

---

**预计部署时间：30-60分钟**
**成功率：95%+**