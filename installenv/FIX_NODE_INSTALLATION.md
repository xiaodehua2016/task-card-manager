# Node.js 安装问题修复指南

## 🚨 当前问题
- `node` 命令无法识别
- `npm` 命令无法识别
- 说明Node.js没有正确安装或环境变量配置有问题

## 🔧 解决方案

### 方案一：重新安装Node.js（推荐）

#### 1. 完全卸载现有Node.js
```powershell
# 在PowerShell中运行（以管理员身份）
# 查找并卸载Node.js
Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*Node*"} | ForEach-Object {$_.Uninstall()}
```

或者通过控制面板：
1. 打开"控制面板" → "程序和功能"
2. 找到"Node.js"并卸载
3. 删除以下文件夹（如果存在）：
   - `C:\Program Files\nodejs`
   - `C:\Program Files (x86)\nodejs`
   - `C:\Users\你的用户名\AppData\Roaming\npm`

#### 2. 下载并安装最新版Node.js
1. **访问官网**：https://nodejs.org/zh-cn/
2. **下载LTS版本**：点击"推荐给大多数用户"的版本
3. **运行安装程序**：
   - 双击下载的 `.msi` 文件
   - 点击"Next"接受默认设置
   - **重要**：确保勾选"Add to PATH"选项
   - 完成安装

#### 3. 重启计算机
安装完成后**必须重启计算机**，这样环境变量才能生效。

#### 4. 验证安装
重启后打开新的PowerShell窗口：
```powershell
node --version
npm --version
```

### 方案二：修复环境变量

如果Node.js已安装但命令无法识别，可能是环境变量问题：

#### 1. 查找Node.js安装路径
常见位置：
- `C:\Program Files\nodejs`
- `C:\Program Files (x86)\nodejs`

#### 2. 手动添加环境变量
1. 右键"此电脑" → "属性"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"系统变量"中找到"Path"
5. 点击"编辑" → "新建"
6. 添加Node.js安装路径（如：`C:\Program Files\nodejs`）
7. 点击"确定"保存

#### 3. 重启PowerShell
关闭所有PowerShell窗口，重新打开测试。

### 方案三：使用Chocolatey安装（高级用户）

#### 1. 安装Chocolatey
```powershell
# 以管理员身份运行PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### 2. 使用Chocolatey安装Node.js
```powershell
choco install nodejs
```

## 🎯 无Node.js的替代方案

如果您不想安装Node.js，可以使用以下方法配置项目：

### 手动配置Supabase
1. **复制配置文件**
   ```cmd
   copy config\supabase.example.js config\supabase.js
   ```

2. **编辑配置文件**
   用记事本打开 `config\supabase.js`，修改：
   ```javascript
   window.SUPABASE_CONFIG = {
       url: 'https://你的项目ID.supabase.co',
       anonKey: '你的API密钥',
       // 其他配置保持不变
   };
   ```

### 本地运行项目
```cmd
# 使用Python（如果已安装）
python -m http.server 8000

# 或直接双击 index.html 文件
```

## 🔍 故障排除

### 问题1：安装后仍然无法识别命令
**解决方案**：
1. 完全重启计算机
2. 打开新的PowerShell窗口
3. 检查环境变量是否正确设置

### 问题2：权限错误
**解决方案**：
```powershell
# 以管理员身份运行PowerShell
# 右键PowerShell图标 → "以管理员身份运行"
```

### 问题3：网络问题导致下载失败
**解决方案**：
1. 使用VPN或更换网络
2. 从镜像站下载：https://npm.taobao.org/mirrors/node/
3. 使用离线安装包

### 问题4：多版本冲突
**解决方案**：
1. 完全卸载所有Node.js版本
2. 清理注册表和文件夹
3. 重新安装单一版本

## 📋 验证清单

安装完成后请检查：
- [ ] `node --version` 显示版本号
- [ ] `npm --version` 显示版本号
- [ ] 可以运行 `npm help`
- [ ] 环境变量PATH包含Node.js路径

## 🎯 推荐的完整安装步骤

1. **卸载旧版本**（如果有）
2. **下载Node.js LTS版本**
3. **运行安装程序**（确保勾选Add to PATH）
4. **重启计算机**
5. **打开新的PowerShell验证**
6. **运行项目配置脚本**

## 💡 小贴士

1. **选择LTS版本**：更稳定，适合生产使用
2. **重启很重要**：环境变量需要重启才能生效
3. **使用新窗口**：旧的命令行窗口不会更新环境变量
4. **管理员权限**：某些操作需要管理员权限

## 📞 需要帮助？

如果问题仍然存在：
1. 截图错误信息
2. 提供系统版本信息
3. 说明已尝试的解决方案
4. 查看Node.js官方文档：https://nodejs.org/zh-cn/docs/