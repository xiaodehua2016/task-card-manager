# 宝塔面板部署故障排查指南

## 🚨 **当前问题：Nginx服务异常**

### **问题现象**
```
❌ Nginx服务异常
○ nginx.service - LSB: starts the nginx web server
     Active: inactive (dead)
```

### **问题原因**
宝塔面板使用自己的Nginx服务管理方式，不是标准的systemctl服务。

---

## 🔧 **立即修复方案**

### **方案1：修复"没有找到站点"问题（当前问题）**
```bash
# 上传并执行站点修复脚本
scp deploy/fix-site-not-found.sh root@115.159.5.111:/tmp/
ssh root@115.159.5.111
chmod +x /tmp/fix-site-not-found.sh
/tmp/fix-site-not-found.sh
```

### **方案2：使用Nginx服务修复脚本**
```bash
# 上传并执行Nginx服务修复脚本
scp deploy/fix-nginx-service.sh root@115.159.5.111:/tmp/
ssh root@115.159.5.111
chmod +x /tmp/fix-nginx-service.sh
/tmp/fix-nginx-service.sh
```

### **方案3：手动修复站点配置**
```bash
# SSH连接服务器
ssh root@115.159.5.111

# 检查虚拟主机配置
cat /www/server/nginx/conf/vhost/task-manager.conf

# 重新创建配置文件
cat > /www/server/nginx/conf/vhost/task-manager.conf << 'EOF'
server {
    listen 80;
    server_name 115.159.5.111 _;
    root /www/wwwroot/task-manager;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# 测试配置并重启
nginx -t
/etc/init.d/nginx restart

# 测试访问
curl -I http://127.0.0.1
```

---

## 🎯 **宝塔面板Nginx管理命令**

### **服务控制**
```bash
/etc/init.d/nginx start    # 启动
/etc/init.d/nginx stop     # 停止
/etc/init.d/nginx restart  # 重启
/etc/init.d/nginx reload   # 重载配置
/etc/init.d/nginx status   # 查看状态
```

### **进程检查**
```bash
pgrep nginx               # 检查进程
ps aux | grep nginx       # 详细进程信息
netstat -tlnp | grep :80  # 检查端口
```

---

## 🔍 **配置文件检查**

### **主配置文件**
```bash
# 宝塔面板Nginx主配置
/www/server/nginx/conf/nginx.conf

# 虚拟主机配置
/www/server/nginx/conf/vhost/task-manager.conf
```

### **配置验证**
```bash
# 测试配置语法
nginx -t

# 查看配置内容
cat /www/server/nginx/conf/vhost/task-manager.conf
```

---

## 📊 **日志文件位置**

### **Nginx日志**
```bash
# 访问日志
/www/wwwlogs/access.log

# 错误日志
/var/log/nginx/error.log
/www/server/nginx/logs/error.log

# 宝塔面板日志
/www/server/panel/logs/panel.log
```

### **查看日志**
```bash
# 实时查看访问日志
tail -f /www/wwwlogs/access.log

# 查看错误日志
tail -20 /var/log/nginx/error.log
```

---

## 🚀 **完整验证步骤**

### **第1步：启动服务**
```bash
/etc/init.d/nginx start
```

### **第2步：检查进程**
```bash
pgrep nginx
# 应该显示进程ID
```

### **第3步：检查端口**
```bash
ss -tlnp | grep :80
# 应该显示nginx监听80端口
```

### **第4步：测试访问**
```bash
curl -I http://127.0.0.1
# 应该返回HTTP/1.1 200 OK
```

### **第5步：外部访问**
```bash
# 在浏览器中访问
http://115.159.5.111
```

---

## 🎉 **修复完成确认**

### **成功标志**
- ✅ `pgrep nginx` 显示进程ID
- ✅ `ss -tlnp | grep :80` 显示nginx监听
- ✅ `curl -I http://127.0.0.1` 返回200状态
- ✅ 浏览器能正常访问 http://115.159.5.111

### **项目功能测试**
- ✅ 页面正常加载
- ✅ 任务卡片显示正常
- ✅ 点击任务能正常完成
- ✅ 底部导航功能正常

---

## 💡 **预防措施**

### **使用正确的管理命令**
```bash
# 宝塔面板环境使用
/etc/init.d/nginx [start|stop|restart|reload]

# 不要使用
systemctl [start|stop|restart] nginx
```

### **定期检查**
```bash
# 添加到定时任务
echo "0 */6 * * * pgrep nginx || /etc/init.d/nginx start" | crontab -
```

---

## 🔧 **如果仍有问题**

### **重新部署**
```bash
# 清理并重新部署
rm -rf /www/wwwroot/task-manager/*
cd /www/wwwroot/task-manager
tar -xzf /tmp/task-manager-v4.1.0.tar.gz
chown -R www:www /www/wwwroot/task-manager
/etc/init.d/nginx restart
```

### **联系支持**
如果问题仍然存在，请提供：
- Nginx错误日志内容
- 配置文件内容
- 系统环境信息

**现在请执行修复脚本，应该能立即解决问题！**