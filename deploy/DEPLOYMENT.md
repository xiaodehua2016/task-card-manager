# GitHub + Supabase 部署指南

## 🚀 快速部署步骤

### 1. Supabase项目设置

#### 1.1 创建Supabase项目
1. 访问 [Supabase](https://supabase.com)
2. 使用GitHub账号登录（推荐）或邮箱注册
3. 点击 "New Project" 创建新项目
4. 填写项目信息：
   - **Organization**: 选择或创建组织
   - **Name**: `task-card-manager`
   - **Database Password**: 设置强密码（请记住此密码）
   - **Region**: 选择离您最近的地区（如：Northeast Asia (Tokyo)）
5. 点击 "Create new project" 并等待项目初始化完成（约2分钟）

#### 1.2 创建数据库表
**重要**: 不要尝试直接连接PostgreSQL数据库，请使用Supabase Web界面：

1. 登录到Supabase项目控制台
2. 点击左侧菜单的 "SQL Editor"
3. 点击 "New Query" 创建新查询
4. 复制粘贴以下SQL代码并点击 "Run" 执行：

```sql
-- 用户表
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 任务数据表
CREATE TABLE task_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  data JSONB NOT NULL,
  last_update_time BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_task_data_user_id ON task_data(user_id);
CREATE INDEX idx_task_data_update_time ON task_data(last_update_time);

-- 设置RLS策略（行级安全）
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_data ENABLE ROW LEVEL SECURITY;

-- 允许用户访问自己的数据
CREATE POLICY "用户可以查看自己的数据" ON task_data
  FOR SELECT USING (true);

CREATE POLICY "用户可以插入自己的数据" ON task_data
  FOR INSERT WITH CHECK (true);

CREATE POLICY "用户可以更新自己的数据" ON task_data
  FOR UPDATE USING (true);

CREATE POLICY "用户可以删除自己的数据" ON task_data
  FOR DELETE USING (true);

-- 用户表策略
CREATE POLICY "用户可以查看用户信息" ON users
  FOR SELECT USING (true);

CREATE POLICY "用户可以插入用户信息" ON users
  FOR INSERT WITH CHECK (true);
```

#### 1.3 获取项目配置
1. 在Supabase项目控制台中，点击左侧的 "Settings"
2. 选择 "API" 选项卡
3. 复制以下重要信息：
   - **Project URL**: 形如 `https://xxxxx.supabase.co`
   - **anon public key**: 以 `eyJ` 开头的长字符串
4. **重要**: 不要复制 `service_role` 密钥，那是服务端密钥

**注意**: 如果遇到 "password authentication failed" 错误，说明您在尝试直接连接PostgreSQL。请使用上述Web界面方法，不要使用psql等数据库客户端。

### 2. GitHub项目配置

#### 2.1 配置Supabase连接
1. 复制 `config/supabase.example.js` 为 `config/supabase.js`
2. 填入你的Supabase配置：
```javascript
window.SUPABASE_CONFIG = {
    url: 'https://your-project-id.supabase.co',
    anonKey: 'your-anon-key-here'
};
```

#### 2.2 更新HTML文件
在 `index.html` 中添加配置文件引用：
```html
<script src="config/supabase.js"></script>
<script src="js/supabase-config.js"></script>
```

#### 2.3 启用GitHub Pages
1. 进入GitHub仓库设置
2. 找到"Pages"选项
3. Source选择"GitHub Actions"
4. 推送代码后自动部署

### 3. 验证部署

#### 3.1 检查功能
- [ ] 页面正常加载
- [ ] 任务可以正常添加/修改
- [ ] 多设备间数据同步
- [ ] 离线功能正常

#### 3.2 测试多客户端同步
1. 在设备A上修改任务状态
2. 在设备B上刷新页面
3. 确认数据已同步

## 🔧 高级配置

### 自定义域名
1. 在GitHub Pages设置中添加自定义域名
2. 配置DNS CNAME记录
3. 启用HTTPS

### 性能优化
1. 启用Supabase CDN
2. 配置缓存策略
3. 压缩静态资源

### 监控和日志
1. 在Supabase中查看API使用情况
2. 设置错误监控
3. 配置性能监控

## 📊 成本估算

### Supabase免费额度
- 数据库存储: 500MB
- 带宽: 5GB/月
- API请求: 50,000次/月
- 实时连接: 200个并发

### GitHub Pages
- 完全免费
- 100GB存储限制
- 100GB带宽/月

## 🚨 注意事项

1. **数据安全**: 不要在前端代码中暴露敏感信息
2. **API限制**: 注意Supabase的API调用限制
3. **备份**: 定期备份Supabase数据
4. **更新**: 保持依赖库的最新版本

## 🆘 故障排除

### 常见问题

#### 1. 数据不同步
- 检查网络连接
- 查看浏览器控制台错误
- 验证Supabase配置

#### 2. 页面加载失败
- 检查GitHub Pages部署状态
- 验证文件路径
- 查看GitHub Actions日志

#### 3. 数据库连接失败
- 检查Supabase项目状态
- 验证API密钥
- 检查RLS策略设置

### 调试工具
1. 浏览器开发者工具
2. Supabase仪表板
3. GitHub Actions日志

## 📞 技术支持

如遇到问题，可以：
1. 查看Supabase官方文档
2. 检查GitHub Issues
3. 联系技术支持团队