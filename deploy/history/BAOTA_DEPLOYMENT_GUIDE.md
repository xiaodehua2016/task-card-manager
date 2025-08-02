# 宝塔面板部署指南
## 小久任务管理系统 v4.1.0

---

## 🎯 **适用环境**
- **服务器**：115.159.5.111
- **系统**：OpenCloudOS 9.4
- **面板**：宝塔面板
- **Web服务器**：Nginx

---

## 🚀 **一键部署方案**

### **第1步：准备项目文件**
```bash
# 在本地项目目录执行
tar -czf task-manager-v4.1.0.tar.gz --exclude='.git' --exclude='node_modules' --exclude='.codebuddy' .
```

### **第2步：上传文件到服务器**
```bash
# 上传项目文件
scp task-manager-v4.1.0.tar.gz root@115.159.5.111:/tmp/

# 上传部署脚本
scp deploy/one-click-deploy.sh root@115.159.5.111:/tmp/
```

### **第3步：执行部署**
```bash
# SSH连接服务器
ssh root@115.159.5.111

# 执行部署脚本
chmod +x /tmp/one-click-deploy.sh
/tmp/one-click-deploy.sh
```

---

## 🔧 **脚本自动适配功能**

### ✅ **环境检测**
- 自动检测是否为宝塔面板环境
- 自动选择正确的配置目录
- 自动检测可用的Web用户

### ✅ **目录适配**
```bash
# 宝塔面板环境：
网站目录: /www/wwwroot/task-manager
配置目录: /www/server/nginx/conf/vhost/
Web用户: www

# 标准Linux环境：
网站目录: /var/www/task-manager
配置目录: /etc/nginx/conf.d/
Web用户: nginx
```

### ✅ **权限设置**
- 自动检测系统中存在的Web用户
- 按优先级设置文件权限：www > nginx > www-data > nobody

---

## 📋 **部署后管理**

### **更新项目**
```bash
# 上传新版本文件后执行
/root/update-task-manager.sh
```

### **备份数据**
```bash
# 备份网站文件和配置
/root/backup-task-manager.sh
```

### **查看日志**
```bash
# 查看访问日志
tail -f /www/wwwlogs/access.log

# 查看错误日志
tail -f /var/log/nginx/error.log

# 查看宝塔面板日志
tail -f /www/server/panel/logs/panel.log
```

---

## 🎉 **部署完成**

部署成功后，您可以通过以下地址访问：
- **网站地址**：http://115.159.5.111
- **宝塔面板**：http://115.159.5.111:8888（如果已安装）

---

## 🔍 **故障排查**

### **常见问题**
1. **nginx用户不存在** - 脚本会自动使用www用户
2. **conf.d目录不存在** - 脚本会自动创建或使用vhost目录
3. **权限问题** - 脚本会自动检测并设置正确权限

### **手动检查**
```bash
# 检查网站文件
ls -la /www/wwwroot/task-manager/

# 检查Nginx配置
nginx -t

# 检查服务状态
systemctl status nginx
```

---

## ✅ **优势特点**

- **智能适配** - 自动识别宝塔面板和标准环境
- **容错处理** - 自动处理用户和目录问题
- **一键部署** - 5-10分钟完成全部部署
- **易于维护** - 提供更新和备份脚本

**现在您的部署脚本已完全适配宝塔面板环境！**