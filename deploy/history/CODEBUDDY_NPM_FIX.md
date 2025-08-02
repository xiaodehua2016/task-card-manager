# CodeBuddy NPM命令修复指南

## 🚨 问题描述
CodeBuddy终端无法执行npm命令，但系统PowerShell可以正常执行。

## 🔍 问题诊断

### 1. 检查Node.js安装路径
在系统PowerShell中执行：
```powershell
where node
where npm
echo $env:PATH
```

### 2. 检查CodeBuddy终端环境
在CodeBuddy终端中执行：
```powershell
$env:PATH
Get-Command node -ErrorAction SilentlyContinue
Get-Command npm -ErrorAction SilentlyContinue
```

## 🛠️ 解决方案

### 方案一：手动添加PATH环境变量

#### 1. 找到Node.js安装路径
通常在以下位置之一：
- `C:\Program Files\nodejs\`
- `C:\Program Files (x86)\nodejs\`
- `%APPDATA%\npm\`

#### 2. 在CodeBuddy中设置环境变量
```powershell
# 临时设置（当前会话有效）
$env:PATH += ";C:\Program Files\nodejs\"
$env:PATH += ";%APPDATA%\npm"

# 验证设置
npm --version
```

#### 3. 永久设置环境变量
```powershell
# 添加到用户环境变量
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\Program Files\nodejs\", "User")
```

### 方案二：使用完整路径执行

#### 直接使用完整路径
```powershell
# 使用完整路径执行npm命令
& "C:\Program Files\nodejs\npm.exe" --version
& "C:\Program Files\nodejs\npm.exe" install -g vercel
```

### 方案三：创建PowerShell配置文件

#### 1. 创建PowerShell配置文件
```powershell
# 检查配置文件是否存在
Test-Path $PROFILE

# 创建配置文件
New-Item -ItemType File -Path $PROFILE -Force

# 编辑配置文件
notepad $PROFILE
```

#### 2. 在配置文件中添加PATH设置
```powershell
# 添加以下内容到配置文件
$env:PATH += ";C:\Program Files\nodejs\"
$env:PATH += ";$env:APPDATA\npm"

# 设置别名（可选）
Set-Alias -Name node -Value "C:\Program Files\nodejs\node.exe"
Set-Alias -Name npm -Value "C:\Program Files\nodejs\npm.exe"
```

### 方案四：使用npx替代

#### 如果npm不可用，尝试npx
```powershell
# 使用npx执行命令
npx vercel --version
npx @cloudbase/cli --version
```

## 🎯 针对您项目的快速解决方案

### 立即可用的部署方法

#### 1. 跳过npm命令，使用Web界面
由于您的项目已经实现了文件存储方案，可以完全避开npm命令：

```bash
# 不需要npm命令的部署流程
git add .
git commit -m "文件存储版本部署"
git push origin main

# 然后通过Web界面部署到各平台
```

#### 2. 使用GitHub Actions自动化
创建自动化部署，避免本地npm依赖：

```yaml
# .github/workflows/auto-deploy.yml
name: 自动部署
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: 部署到多平台
        run: |
          echo "代码已推送，触发自动部署"
          # Vercel和其他平台会自动检测并部署
```

#### 3. 本地PowerShell执行
在您的本地PowerShell中执行npm命令：

```powershell
# 在项目目录下
cd C:\AA\codebuddy\1\task-card-manager

# 执行npm命令
npm install -g vercel
vercel login
vercel deploy
```

## 🔧 CodeBuddy环境优化

### 创建启动脚本
```powershell
# 创建 setup-env.ps1
$nodePath = "C:\Program Files\nodejs\"
$npmPath = "$env:APPDATA\npm"

if (Test-Path $nodePath) {
    $env:PATH += ";$nodePath"
    Write-Host "✅ Node.js路径已添加"
}

if (Test-Path $npmPath) {
    $env:PATH += ";$npmPath"
    Write-Host "✅ NPM路径已添加"
}

# 验证安装
try {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "✅ Node.js: $nodeVersion"
    Write-Host "✅ NPM: $npmVersion"
} catch {
    Write-Host "❌ Node.js或NPM仍无法访问"
    Write-Host "请检查安装路径是否正确"
}
```

### 使用脚本
```powershell
# 在CodeBuddy终端中执行
.\setup-env.ps1
```

## 💡 最佳实践建议

### 1. 环境检查清单
- [ ] Node.js已正确安装
- [ ] PATH环境变量包含Node.js路径
- [ ] npm全局包路径已添加
- [ ] PowerShell执行策略允许脚本运行

### 2. 替代方案
如果npm命令始终无法在CodeBuddy中使用：
- ✅ 使用Web界面部署（推荐）
- ✅ 使用GitHub Actions自动化
- ✅ 在本地PowerShell中执行npm命令
- ✅ 使用文件存储方案避开npm依赖

### 3. 长期解决方案
```powershell
# 创建CodeBuddy专用的环境配置
# 在用户目录创建 .codebuddy-env.ps1
$env:PATH += ";C:\Program Files\nodejs\"
$env:PATH += ";$env:APPDATA\npm"

# 每次启动CodeBuddy时执行
. ~/.codebuddy-env.ps1
```

## 🎯 针对当前项目的建议

由于您的项目已经实现了文件存储方案，**建议直接跳过npm命令问题**：

1. **立即部署**：使用Git推送到Gitee，通过Web界面开启Pages
2. **长期使用**：文件存储方案无需任何npm依赖
3. **备用方案**：保持Vercel部署作为国际访问备份

这样既解决了当前的部署需求，又避开了CodeBuddy的npm命令限制。