# CodeBuddy环境下的部署指南

## 🚨 CodeBuddy终端限制问题

### 问题描述
- CodeBuddy终端无法执行npm命令
- 需要通过其他方式完成腾讯云部署

## 🛠️ 解决方案

### 方案一：Web界面部署（推荐）

#### 1. 腾讯云Web控制台部署
**无需命令行，完全通过Web界面操作**

**步骤：**
1. **注册腾讯云账号**
   - 访问：https://cloud.tencent.com
   - 完成实名认证

2. **开通云开发服务**
   - 进入云开发控制台
   - 创建新环境
   - 选择"按量付费"模式

3. **开通静态网站托管**
   - 在云开发控制台中
   - 点击"静态网站托管"
   - 开通服务

4. **上传项目文件**
   - 点击"文件管理"
   - 直接拖拽上传项目文件
   - 或使用"批量上传"功能

5. **配置环境变量**
   - 进入"环境设置"
   - 添加环境变量：
     - `SUPABASE_URL`: https://zjnjqnftcmxygunzbqch.supabase.co
     - `SUPABASE_ANON_KEY`: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

6. **获取访问域名**
   - 在静态网站托管中查看默认域名
   - 格式：https://your-env-id.tcloudbaseapp.com

### 方案二：GitHub Actions自动部署

#### 1. 创建GitHub Actions工作流
```yaml
# .github/workflows/deploy-tencent.yml
name: 部署到腾讯云

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: 检出代码
      uses: actions/checkout@v3
      
    - name: 设置Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: 安装腾讯云CLI
      run: npm install -g @cloudbase/cli
      
    - name: 部署到腾讯云
      run: |
        tcb login --apiKeyId ${{ secrets.TENCENT_SECRET_ID }} --apiKey ${{ secrets.TENCENT_SECRET_KEY }}
        tcb hosting deploy ./ -e ${{ secrets.TENCENT_ENV_ID }}
      env:
        TENCENT_SECRET_ID: ${{ secrets.TENCENT_SECRET_ID }}
        TENCENT_SECRET_KEY: ${{ secrets.TENCENT_SECRET_KEY }}
        TENCENT_ENV_ID: ${{ secrets.TENCENT_ENV_ID }}
```

#### 2. 配置GitHub Secrets
在GitHub仓库设置中添加：
- `TENCENT_SECRET_ID`: 腾讯云API密钥ID
- `TENCENT_SECRET_KEY`: 腾讯云API密钥
- `TENCENT_ENV_ID`: 云开发环境ID

### 方案三：本地环境部署

#### 1. 在您的本地电脑执行
```bash
# 1. 安装Node.js（如果没有）
# 下载：https://nodejs.org

# 2. 安装腾讯云CLI
npm install -g @cloudbase/cli

# 3. 克隆项目到本地
git clone https://github.com/xiaodehua2016/task-card-manager.git
cd task-card-manager

# 4. 登录腾讯云
tcb login

# 5. 部署项目
tcb hosting deploy ./ -e your-env-id
```

### 方案四：压缩包上传

#### 1. 准备项目文件
```bash
# 在CodeBuddy中创建部署包
# 创建一个包含所有必要文件的压缩包
```

#### 2. 手动上传到腾讯云
- 将项目文件打包成zip
- 通过腾讯云控制台批量上传
- 解压到静态网站托管目录

## 📋 推荐实施步骤

### 立即可行方案：Web界面部署

1. **准备工作**（在CodeBuddy中完成）
   - ✅ 确认所有文件已提交到GitHub
   - ✅ 验证项目文件完整性

2. **腾讯云配置**（在浏览器中完成）
   - 🔄 注册腾讯云账号
   - 🔄 开通云开发服务
   - 🔄 创建静态网站托管

3. **文件上传**（通过Web界面）
   - 🔄 下载GitHub仓库为ZIP
   - 🔄 上传到腾讯云静态托管
   - 🔄 配置环境变量

4. **测试验证**
   - 🔄 访问腾讯云提供的域名
   - 🔄 测试应用功能
   - 🔄 验证数据同步

## 🎯 环境变量配置方案

### 在腾讯云控制台设置
```
变量名: SUPABASE_URL
变量值: https://zjnjqnftcmxygunzbqch.supabase.co

变量名: SUPABASE_ANON_KEY  
变量值: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqbmpxbmZ0Y214eWd1bnpicWNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjEwNTQsImV4cCI6MjA2ODkzNzA1NH0.6BVJF0oOAENTWusDthRj1IHcwzCmlhqvv1xxK5jYA2Q
```

### 代码中的环境变量读取
```javascript
// 腾讯云环境变量读取
const config = {
    supabaseUrl: process.env.SUPABASE_URL || window.SUPABASE_CONFIG?.url,
    supabaseKey: process.env.SUPABASE_ANON_KEY || window.SUPABASE_CONFIG?.anonKey
};
```

## 💡 最佳实践

### 1. 多重部署策略
- GitHub Pages（自动）
- Vercel（自动）  
- 腾讯云（手动/自动）

### 2. 部署验证清单
- [ ] 文件上传完整
- [ ] 环境变量配置正确
- [ ] 域名访问正常
- [ ] 数据库连接成功
- [ ] 功能测试通过

### 3. 监控和维护
- 定期检查部署状态
- 监控访问速度
- 及时同步代码更新

## 🎯 总结

**CodeBuddy环境限制的解决方案：**
1. ✅ **Web界面部署**（最简单，推荐）
2. ✅ **GitHub Actions自动化**（一次配置，长期受益）
3. ✅ **本地环境部署**（需要本地Node.js环境）
4. ✅ **压缩包手动上传**（备用方案）

**推荐顺序：**
1. 先尝试Web界面部署
2. 如果需要自动化，配置GitHub Actions
3. 保持多平台部署作为备份

这样既解决了CodeBuddy的限制，又实现了腾讯云部署的目标。