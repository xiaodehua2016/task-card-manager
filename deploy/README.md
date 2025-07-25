# 部署文件说明
## 小久任务管理系统 v4.1.0

---

## 📁 当前部署文件结构

### 🚀 主要部署文件
- **`SERVER_DEPLOYMENT_MANUAL.md`** - 完整的服务器部署操作手册（推荐阅读）
- **`one-click-deploy.sh`** - 一键部署脚本（推荐使用）
- **`simple-deployment.sh`** - 简化部署脚本
- **`QUICK_START.md`** - 快速开始指南

### 🔧 辅助工具
- **`setup.sh`** - Linux环境设置脚本
- **`setup.bat`** - Windows环境设置脚本
- **`deploy.bat`** - Windows部署脚本
- **`deploy-setup.js`** - 部署配置脚本

### 📖 文档
- **`DEPLOYMENT.md`** - 通用部署说明
- **`TROUBLESHOOTING.md`** - 故障排查指南
- **`CODEBUDDY_NPM_FIX.md`** - NPM问题修复指南
- **`simple-setup.html`** - 可视化设置页面

### 📚 历史文档
- **`history/`** - 历史版本的部署文档和脚本

---

## 🎯 推荐部署方式

### 方式一：一键部署（最简单）
```bash
# 1. 连接服务器
ssh root@115.159.5.111

# 2. 下载并执行一键部署脚本
wget -O deploy.sh https://raw.githubusercontent.com/xiaodehua2016/task-card-manager/main/deploy/one-click-deploy.sh
chmod +x deploy.sh
./deploy.sh
```

### 方式二：手动部署（详细控制）
```bash
# 参考 SERVER_DEPLOYMENT_MANUAL.md 文档
# 按步骤手动执行每个部署环节
```

### 方式三：Git部署（开发者推荐）
```bash
# 参考 SERVER_DEPLOYMENT_MANUAL.md 中的 Git部署方式
# 支持版本控制和自动更新
```

---

## 📋 部署前检查清单

### ✅ 服务器要求
- [ ] Ubuntu 20.04 LTS 或 CentOS 7.9
- [ ] 4核CPU，4GB内存（您的服务器满足）
- [ ] 20GB以上存储空间
- [ ] 公网IP：115.159.5.111

### ✅ 网络要求
- [ ] SSH端口22开放
- [ ] HTTP端口80开放
- [ ] 可以访问GitHub（用于下载代码）

### ✅ 权限要求
- [ ] root用户权限
- [ ] sudo权限（如果不是root用户）

---

## 🔧 部署后验证

### 基础验证
```bash
# 检查服务状态
systemctl status nginx

# 测试网站访问
curl -I http://115.159.5.111

# 查看端口监听
netstat -tlnp | grep :80
```

### 功能验证
- [ ] 访问 http://115.159.5.111 显示任务管理界面
- [ ] 可以添加和完成任务
- [ ] 数据在浏览器中正常保存
- [ ] 移动端访问正常

---

## 🆘 遇到问题？

1. **查看故障排查指南**：`TROUBLESHOOTING.md`
2. **检查部署日志**：部署脚本会显示详细的执行日志
3. **查看系统日志**：`tail -f /var/log/nginx/error.log`
4. **联系技术支持**：GitHub Issues

---

## 📞 技术支持

- **项目仓库**：https://github.com/xiaodehua2016/task-card-manager
- **部署文档**：deploy/SERVER_DEPLOYMENT_MANUAL.md
- **问题反馈**：GitHub Issues
- **更新命令**：`/root/update-task-manager.sh`（部署后自动创建）

---

**选择适合您的部署方式，开始部署您的小久任务管理系统！**