# Node.js 环境安装指南

## 📋 概述

本项目是**纯前端项目**，主要使用HTML、CSS、JavaScript。Node.js仅用于：
- 运行部署配置脚本 `deploy-setup.js`
- 本地开发服务器（可选）
- 自动化部署工具（可选）

## 🚀 Node.js 安装方法

### 方法一：官方安装包（推荐新手）

#### Windows系统
1. **下载Node.js**
   - 访问 https://nodejs.org/zh-cn/
   - 下载 "LTS版本"（长期支持版）
   - 选择 "Windows Installer (.msi)" 64位版本

2. **安装步骤**
   - 双击下载的 `.msi` 文件
   - 点击 "下一步" 接受默认设置
   - 勾选 "Add to PATH" 选项
   - 完成安装

3. **验证安装**
   ```cmd
   # 打开命令提示符（Win+R，输入cmd）
   node --version
   npm --version
   ```

#### macOS系统
1. **下载安装**
   - 访问 https://nodejs.org/zh-cn/
   - 下载 "LTS版本"
   - 选择 "macOS Installer (.pkg)"
   - 双击安装包，按提示安装

2. **验证安装**
   ```bash
   # 打开终端
   node --version
   npm --version
   ```

#### Linux系统（Ubuntu/Debian）
```bash
# 更新包管理器
sudo apt update

# 安装Node.js和npm
sudo apt install nodejs npm

# 验证安装
node --version
npm --version
```

### 方法二：使用包管理器

#### Windows - 使用Chocolatey
```powershell
# 安装Chocolatey（如果没有）
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 安装Node.js
choco install nodejs
```

#### macOS - 使用Homebrew
```bash
# 安装Homebrew（如果没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装Node.js
brew install node
```

### 方法三：使用NVM（推荐开发者）

NVM可以管理多个Node.js版本，适合开发者使用。

#### Windows - 使用nvm-windows
1. **下载nvm-windows**
   - 访问 https://github.com/coreybutler/nvm-windows/releases
   - 下载 `nvm-setup.zip`
   - 解压并运行安装程序

2. **安装Node.js**
   ```cmd
   # 查看可用版本
   nvm list available
   
   # 安装最新LTS版本
   nvm install lts
   
   # 使用指定版本
   nvm use lts
   ```

#### macOS/Linux - 使用nvm
```bash
# 安装nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 重启终端或执行
source ~/.bashrc

# 安装Node.js最新LTS版本
nvm install --lts
nvm use --lts
```

## 🔧 项目配置使用

安装Node.js后，您可以使用以下功能：

### 1. 快速配置Supabase
```bash
# 在项目根目录运行
node deploy-setup.js setup <Supabase-URL> <API-Key>

# 示例
node deploy-setup.js setup https://abcdefg.supabase.co eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2. 验证配置
```bash
# 检查配置是否正确
node deploy-setup.js check
```

### 3. 本地开发服务器
```bash
# 方法1：使用Node.js内置服务器
npx serve . -p 8000

# 方法2：使用live-server（支持热重载）
npm install -g live-server
live-server --port=8000

# 方法3：使用http-server
npm install -g http-server
http-server -p 8000
```

## 🎯 无Node.js的替代方案

如果您不想安装Node.js，也可以手动配置：

### 手动配置Supabase
1. **复制配置文件**
   ```bash
   # Windows
   copy config\supabase.example.js config\supabase.js
   
   # macOS/Linux
   cp config/supabase.example.js config/supabase.js
   ```

2. **编辑配置文件**
   用文本编辑器打开 `config/supabase.js`，修改：
   ```javascript
   window.SUPABASE_CONFIG = {
       url: 'https://你的项目ID.supabase.co',
       anonKey: '你的API密钥',
       // ... 其他配置保持不变
   };
   ```

### 本地运行替代方案
```bash
# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000

# PHP
php -S localhost:8000

# 或直接双击 index.html 文件
```

## 📱 移动端测试

### 在手机上测试同步功能
1. **获取本地IP地址**
   ```bash
   # Windows
   ipconfig
   
   # macOS/Linux
   ifconfig
   ```

2. **启动服务器**
   ```bash
   # 使用本地IP启动
   npx serve . -p 8000
   ```

3. **手机访问**
   - 确保手机和电脑在同一WiFi网络
   - 在手机浏览器访问：`http://你的IP地址:8000`
   - 例如：`http://192.168.1.100:8000`

## 🔍 常见问题解决

### 问题1：node命令不存在
**解决方案**：
- 重启命令行工具
- 检查PATH环境变量
- 重新安装Node.js并确保勾选"Add to PATH"

### 问题2：npm权限错误（macOS/Linux）
```bash
# 修复npm权限
sudo chown -R $(whoami) ~/.npm
```

### 问题3：网络问题导致安装失败
```bash
# 使用国内镜像
npm config set registry https://registry.npmmirror.com/

# 或使用cnpm
npm install -g cnpm --registry=https://registry.npmmirror.com/
cnpm install
```

### 问题4：端口被占用
```bash
# 查看端口占用
netstat -ano | findstr :8000

# 使用其他端口
npx serve . -p 3000
```

## 📋 版本要求

- **Node.js**: 14.0.0 或更高版本
- **npm**: 6.0.0 或更高版本

检查版本：
```bash
node --version  # 应显示 v14.0.0 或更高
npm --version   # 应显示 6.0.0 或更高
```

## 🎉 安装完成检查清单

- [ ] Node.js安装成功（`node --version`）
- [ ] npm安装成功（`npm --version`）
- [ ] 可以运行部署脚本（`node deploy-setup.js`）
- [ ] 可以启动本地服务器（`npx serve .`）
- [ ] 配置文件创建成功（`config/supabase.js`）

## 💡 小贴士

1. **LTS版本**：建议使用LTS（长期支持）版本，更稳定
2. **全局安装**：常用工具可以全局安装，如 `npm install -g live-server`
3. **项目依赖**：本项目无需安装依赖，是纯静态项目
4. **版本管理**：开发者建议使用nvm管理多个Node.js版本

安装完成后，您就可以使用 `node deploy-setup.js` 命令快速配置Supabase连接了！