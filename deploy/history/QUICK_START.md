# 🚀 快速开始指南

## 准备工作：安装Node.js（可选）

**注意**：本项目是纯前端项目，Node.js仅用于配置脚本。如果您不想安装Node.js，可以手动配置。

### 快速安装Node.js
1. 访问 https://nodejs.org/zh-cn/
2. 下载并安装 "LTS版本"
3. 验证安装：在命令行运行 `node --version`

详细安装指南请查看：[Node.js环境安装指南](NODE_SETUP.md)

## 5分钟部署多设备同步版本

### 第1步：创建Supabase项目（2分钟）

1. **注册登录**
   - 访问 https://supabase.com
   - 点击 "Start your project" 
   - 使用GitHub账号登录

2. **创建项目**
   - 点击 "New Project"
   - 项目名称：`task-card-manager`
   - 数据库密码：设置一个强密码
   - 地区：选择 "Northeast Asia (Tokyo)"
   - 点击 "Create new project"

3. **等待初始化**
   - 项目创建需要约2分钟
   - 看到绿色 "Active" 状态即可继续

### 第2步：创建数据表（1分钟）

1. **打开SQL编辑器**
   - 在项目控制台左侧点击 "SQL Editor"
   - 点击 "New Query"

2. **执行建表SQL**
   ```sql
   -- 复制粘贴以下完整SQL代码，然后点击 Run
   
   -- 创建用户表
   CREATE TABLE users (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     username VARCHAR(50) NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- 创建任务数据表
   CREATE TABLE task_data (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id UUID REFERENCES users(id) ON DELETE CASCADE,
     data JSONB NOT NULL,
     last_update_time BIGINT NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- 创建索引
   CREATE INDEX idx_task_data_user_id ON task_data(user_id);
   CREATE INDEX idx_task_data_update_time ON task_data(last_update_time);

   -- 设置安全策略
   ALTER TABLE users ENABLE ROW LEVEL SECURITY;
   ALTER TABLE task_data ENABLE ROW LEVEL SECURITY;

   CREATE POLICY "允许访问用户数据" ON users FOR ALL USING (true);
   CREATE POLICY "允许访问任务数据" ON task_data FOR ALL USING (true);
   ```

3. **验证创建成功**
   - 点击左侧 "Table Editor"
   - 应该看到 `users` 和 `task_data` 两个表

### 第3步：获取配置信息（30秒）

1. **获取API配置**
   - 点击左侧 "Settings" → "API"
   - 复制 "Project URL"（如：`https://abcdefg.supabase.co`）
   - 复制 "anon public" key（很长的字符串）

### 第4步：配置项目（1分钟）

#### 方法A：浏览器配置工具（最简单，无需Node.js）
1. 双击打开 `simple-setup.html` 文件
2. 填写Supabase URL和API密钥
3. 点击"生成配置文件"自动下载
4. 将下载的文件放到 `config` 文件夹中

#### 方法B：一键配置脚本
```bash
# Windows用户：双击运行
setup.bat

# macOS/Linux用户：
./setup.sh
```

#### 方法C：命令行配置（需要Node.js）
```bash
# 在项目根目录运行
node deploy-setup.js setup <你的Project-URL> <你的anon-key>

# 示例
node deploy-setup.js setup https://abcdefg.supabase.co eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 方法D：手动配置
```bash
# 1. 复制配置模板
# Windows:
copy config\supabase.example.js config\supabase.js

# macOS/Linux:
cp config/supabase.example.js config/supabase.js

# 2. 编辑 config/supabase.js 文件
# 将 'your-project-id' 替换为实际的项目ID
# 将 'your-anon-key-here' 替换为实际的API密钥
```

### 第5步：部署到GitHub Pages（30秒）

1. **推送代码**
   ```bash
   git add .
   git commit -m "添加Supabase多设备同步功能"
   git push origin main
   ```

2. **启用GitHub Pages**
   - 进入GitHub仓库设置
   - 找到 "Pages" 选项
   - Source 选择 "GitHub Actions"
   - 等待自动部署完成

### 🎉 完成！

现在您可以：
- 在手机上访问GitHub Pages链接
- 修改任务状态
- 在电脑上刷新页面，看到同步的数据

## ⚠️ 常见问题

**Q: 出现 "password authentication failed" 错误**
A: 不要使用psql等工具直接连接数据库，请使用Supabase Web界面的SQL编辑器

**Q: 数据不同步**
A: 检查浏览器控制台是否有错误，确认配置文件中的URL和Key正确

**Q: GitHub Pages访问404**
A: 确认GitHub Actions部署成功，检查仓库设置中的Pages配置

## 📞 需要帮助？

查看详细文档：
- [完整部署指南](DEPLOYMENT.md)
- [故障排除](TROUBLESHOOTING.md)
- [项目说明](README.md)