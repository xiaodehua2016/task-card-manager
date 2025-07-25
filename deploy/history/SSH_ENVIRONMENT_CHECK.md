# SSH服务器环境检查指南
## 服务器信息：115.159.5.111 (4核4GB)

## 🔐 SSH连接步骤

### 1. 连接服务器
```bash
# Windows PowerShell 或 CMD
ssh root@115.159.5.111

# 如果是第一次连接，会提示确认指纹，输入 yes
# 然后输入服务器密码
```

### 2. 连接成功后的基础检查

#### 系统信息检查
```bash
# 查看系统版本
cat /etc/os-release
uname -a

# 查看系统资源
free -h          # 内存使用情况
df -h            # 磁盘使用情况
lscpu            # CPU信息
top              # 实时系统状态
```

#### 网络连接检查
```bash
# 检查网络连接
ping -c 4 baidu.com
ping -c 4 github.com

# 查看开放端口
netstat -tlnp
ss -tlnp

# 查看防火墙状态
ufw status
iptables -L
```

## 🔧 环境检查清单

### 1. 基础软件检查
```bash
# 检查是否已安装基础软件
which wget
which curl
which git

# 检查文本编辑器（选择其一即可）
which nano    # 简单易用的编辑器
which vim     # 功能强大的编辑器
which vi      # 系统自带的基础编辑器

# 安装必需软件
apt update
apt install -y wget curl git htop

# 可选：安装文本编辑器（选择其一）
# apt install -y nano     # 推荐新手使用
# apt install -y vim      # 推荐有经验用户
```
# SSH服务器环境检查指南
## 服务器信息：115.159.5.111 (4核4GB)

## 🔐 SSH连接步骤

### 1. 连接服务器
```bash
# Windows PowerShell 或 CMD
ssh root@115.159.5.111

# 如果是第一次连接，会提示确认指纹，输入 yes
# 然后输入服务器密码
```

### 2. 连接成功后的基础检查

#### 系统信息检查
```bash
# 查看系统版本
cat /etc/os-release
uname -a

# 查看系统资源
free -h          # 内存使用情况
df -h            # 磁盘使用情况
lscpu            # CPU信息
top              # 实时系统状态
```

#### 网络连接检查
```bash
# 检查网络连接
ping -c 4 baidu.com
ping -c 4 github.com

# 查看开放端口
netstat -tlnp
ss -tlnp

# 查看防火墙状态
ufw status
iptables -L
```

## 🔧 环境检查清单


### 2. Web服务器检查
```bash
# 检查Nginx是否安装（推荐使用）
nginx -v
systemctl status nginx

# 查看Nginx配置目录
ls -la /etc/nginx/
ls -la /var/www/

# 注意：项目不需要Apache2，只需要Nginx即可
# 如果同时安装了Apache2和Nginx，可能会产生端口冲突
```
# SSH服务器环境检查指南
## 服务器信息：115.159.5.111 (4核4GB)

## 🔐 SSH连接步骤

### 1. 连接服务器
```bash
# Windows PowerShell 或 CMD
ssh root@115.159.5.111

# 如果是第一次连接，会提示确认指纹，输入 yes
# 然后输入服务器密码
```

### 2. 连接成功后的基础检查

#### 系统信息检查
```bash
# 查看系统版本
cat /etc/os-release
uname -a

# 查看系统资源
free -h          # 内存使用情况
df -h            # 磁盘使用情况
lscpu            # CPU信息
top              # 实时系统状态
```

#### 网络连接检查
```bash
# 检查网络连接
ping -c 4 baidu.com
ping -c 4 github.com

# 查看开放端口
netstat -tlnp
ss -tlnp

# 查看防火墙状态
ufw status
iptables -L
```

## 🔧 环境检查清单

### 1. 基础软件检查
```bash
# 检查是否已安装基础软件
which wget
which curl
which git

# 检查文本编辑器（选择其一即可）
which nano    # 简单易用的编辑器
which vim     # 功能强大的编辑器
which vi      # 系统自带的基础编辑器

# 安装必需软件
apt update
apt install -y wget curl git htop

# 可选：安装文本编辑器（选择其一）
# apt install -y nano     # 推荐新手使用
# apt install -y vim      # 推荐有经验用户
```
# SSH服务器环境检查指南
## 服务器信息：115.159.5.111 (4核4GB)

## 🔐 SSH连接步骤

### 1. 连接服务器
```bash
# Windows PowerShell 或 CMD
ssh root@115.159.5.111

# 如果是第一次连接，会提示确认指纹，输入 yes
# 然后输入服务器密码
```

### 2. 连接成功后的基础检查

#### 系统信息检查
```bash
# 查看系统版本
cat /etc/os-release
uname -a

# 查看系统资源
free -h          # 内存使用情况
df -h            # 磁盘使用情况
lscpu            # CPU信息
top              # 实时系统状态
```

#### 网络连接检查
```bash
# 检查网络连接
ping -c 4 baidu.com
ping -c 4 github.com

# 查看开放端口
netstat -tlnp
ss -tlnp

# 查看防火墙状态
ufw status
iptables -L
```

## 🔧 环境检查清单



### 3. 数据库检查
```bash
# 检查MySQL是否安装
mysql --version
systemctl status mysql

# 检查MySQL配置
cat /etc/mysql/mysql.conf.d/mysqld.cnf

# 测试MySQL连接
mysql -u root -p
```

### 4. Node.js环境检查
```bash
# 检查Node.js是否安装
node --version
npm --version

# 检查Node.js安装路径
which node
which npm

# 查看全局安装的包
npm list -g --depth=0

# 检查PM2是否安装
pm2 --version
pm2 list
```

### 5. 宝塔面板检查
```bash
# 检查宝塔面板是否安装
/etc/init.d/bt status
bt default

# 查看宝塔面板进程
ps aux | grep python | grep panel

# 检查宝塔面板端口
netstat -tlnp | grep 8888
```

## 📁 项目目录检查

### 1. 创建项目目录
```bash
# 创建Web根目录（如果不存在）
mkdir -p /www/wwwroot/task-manager
cd /www/wwwroot/task-manager

# 设置目录权限
chown -R www-data:www-data /www/wwwroot/task-manager
chmod -R 755 /www/wwwroot/task-manager
```

### 2. 检查现有项目文件
```bash
# 查看项目目录内容
ls -la /www/wwwroot/task-manager/

# 如果目录为空，克隆项目
git clone https://github.com/xiaodehua2016/task-card-manager.git .

# 检查项目文件
ls -la
cat package.json
cat index.html
```

### 3. 项目依赖检查
```bash
# 进入项目目录
cd /www/wwwroot/task-manager

# 检查package.json
cat package.json

# 安装依赖
npm install

# 检查安装结果
ls -la node_modules/
```

## 🚀 服务状态检查

### 1. 系统服务状态
```bash
# 检查所有运行的服务
systemctl list-units --type=service --state=running

# 检查关键服务状态
systemctl status nginx
systemctl status mysql
systemctl status ssh
```

### 2. 端口占用检查
```bash
# 查看所有监听端口
netstat -tlnp

# 检查关键端口
netstat -tlnp | grep :80    # HTTP
netstat -tlnp | grep :443   # HTTPS
netstat -tlnp | grep :3306  # MySQL
netstat -tlnp | grep :8888  # 宝塔面板
netstat -tlnp | grep :3000  # Node.js应用
```

### 3. 进程检查
```bash
# 查看所有进程
ps aux

# 查看特定进程
ps aux | grep nginx
ps aux | grep mysql
ps aux | grep node
ps aux | grep pm2
```

## 🔒 安全检查

### 1. 用户和权限检查
```bash
# 查看当前用户
whoami
id

# 查看所有用户
cat /etc/passwd

# 检查sudo权限
sudo -l
```

### 2. 防火墙检查
```bash
# Ubuntu UFW
ufw status verbose
ufw --version

# 查看防火墙规则
iptables -L -n
```

### 3. SSH配置检查
```bash
# 查看SSH配置
cat /etc/ssh/sshd_config

# 检查SSH服务状态
systemctl status sshd
```

## 📊 性能检查

### 1. 系统负载检查
```bash
# 查看系统负载
uptime
w

# 查看CPU使用情况
top
htop

# 查看内存使用
free -h
cat /proc/meminfo
```

### 2. 磁盘检查
```bash
# 查看磁盘使用情况
df -h
du -sh /var/log/*
du -sh /www/wwwroot/*

# 查看磁盘IO
iostat -x 1 5
```

### 3. 网络性能检查
```bash
# 测试网络速度
curl -o /dev/null -s -w "%{time_total}\n" http://baidu.com

# 查看网络连接
ss -tuln
netstat -i
```

## 🔧 环境配置检查

### 1. 环境变量检查
```bash
# 查看环境变量
env
echo $PATH
echo $NODE_ENV
```

### 2. 时区和时间检查
```bash
# 查看系统时间
date
timedatectl status

# 设置时区（如需要）
timedatectl set-timezone Asia/Shanghai
```

### 3. 语言和编码检查
```bash
# 查看语言设置
locale
echo $LANG
```

## 📝 检查结果记录

### 创建检查报告
```bash
# 创建检查报告文件
cat > /tmp/server_check_report.txt << 'EOF'
=== 服务器环境检查报告 ===
检查时间: $(date)
服务器IP: 115.159.5.111

=== 系统信息 ===
$(cat /etc/os-release)
$(uname -a)

=== 资源使用情况 ===
$(free -h)
$(df -h)

=== 网络状态 ===
$(netstat -tlnp)

=== 服务状态 ===
$(systemctl status nginx --no-pager)
$(systemctl status mysql --no-pager)

=== Node.js环境 ===
Node版本: $(node --version 2>/dev/null || echo "未安装")
NPM版本: $(npm --version 2>/dev/null || echo "未安装")
PM2版本: $(pm2 --version 2>/dev/null || echo "未安装")

=== 项目文件 ===
$(ls -la /www/wwwroot/task-manager/ 2>/dev/null || echo "项目目录不存在")

EOF

# 查看报告
cat /tmp/server_check_report.txt
```

## 🎯 常见问题排查

### 1. 如果无法SSH连接
```bash
# 检查服务器是否在线
ping 115.159.5.111

# 检查SSH端口是否开放
telnet 115.159.5.111 22
nmap -p 22 115.159.5.111
```

### 2. 如果宝塔面板无法访问
```bash
# 检查宝塔面板状态
/etc/init.d/bt status

# 重启宝塔面板
/etc/init.d/bt restart

# 查看宝塔面板信息
bt default
```

### 3. 如果Node.js未安装
```bash
# 安装Node.js（Ubuntu）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install -y nodejs

# 验证安装
node --version
npm --version
```

## 📋 检查清单

### 基础环境
- [ ] SSH连接正常
- [ ] 系统信息正确（Ubuntu/CentOS）
- [ ] 内存4GB，CPU4核确认
- [ ] 磁盘空间充足（>10GB可用）
- [ ] 网络连接正常

### Web服务器
- [ ] Nginx已安装并运行
- [ ] 80端口正常监听
- [ ] Web根目录存在
- [ ] 权限配置正确

### 数据库
- [ ] MySQL已安装并运行
- [ ] 3306端口正常监听
- [ ] 可以正常连接
- [ ] 配置文件正确

### Node.js环境
- [ ] Node.js已安装（推荐20.x或22.x）
- [ ] NPM正常工作
- [ ] PM2已安装
- [ ] 全局包路径正确

### 宝塔面板
- [ ] 宝塔面板已安装
- [ ] 8888端口正常访问
- [ ] 面板功能正常
- [ ] 软件商店可用

### 项目部署
- [ ] 项目目录已创建
- [ ] 项目文件已上传
- [ ] 依赖包已安装
- [ ] 配置文件正确

## 🚀 下一步操作建议

根据检查结果，按以下优先级处理：

### 高优先级
1. 确保SSH连接稳定
2. 安装缺失的基础软件
3. 配置Web服务器
4. 安装Node.js环境

### 中优先级
1. 安装和配置宝塔面板
2. 设置数据库
3. 配置防火墙规则
4. 优化系统性能

### 低优先级
1. 配置SSL证书
2. 设置监控报警
3. 优化安全设置
4. 配置自动备份

---

**请按照以上步骤逐一检查，如有问题请记录具体错误信息，我将为您提供针对性的解决方案！**