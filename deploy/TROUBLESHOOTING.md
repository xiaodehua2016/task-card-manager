# 故障排除指南

## 🚨 常见问题解决方案

### 1. SQL执行错误：password authentication failed

**错误信息**: `FATAL: 28P01: password authentication failed for user "postgres"`

**原因**: 您尝试直接连接PostgreSQL数据库，但这不是正确的方法。

**解决方案**:
1. **不要使用psql或其他PostgreSQL客户端直接连接**
2. **使用Supabase Web界面**:
   ```
   步骤1: 登录 https://supabase.com
   步骤2: 选择您的项目
   步骤3: 点击左侧 "SQL Editor"
   步骤4: 点击 "New Query"
   步骤5: 粘贴SQL代码并点击 "Run"
   ```

### 2. 正确的数据库表创建步骤

#### 方法一：使用Supabase SQL编辑器（推荐）

1. **访问SQL编辑器**
   - 登录Supabase控制台
   - 点击项目名称进入项目
   - 左侧菜单选择 "SQL Editor"

2. **创建用户表**
   ```sql
   -- 创建用户表
   CREATE TABLE IF NOT EXISTS users (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     username VARCHAR(50) NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

3. **创建任务数据表**
   ```sql
   -- 创建任务数据表
   CREATE TABLE IF NOT EXISTS task_data (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id UUID REFERENCES users(id) ON DELETE CASCADE,
     data JSONB NOT NULL,
     last_update_time BIGINT NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

4. **创建索引**
   ```sql
   -- 创建索引提高查询性能
   CREATE INDEX IF NOT EXISTS idx_task_data_user_id ON task_data(user_id);
   CREATE INDEX IF NOT EXISTS idx_task_data_update_time ON task_data(last_update_time);
   ```

5. **设置行级安全策略（RLS）**
   ```sql
   -- 启用行级安全
   ALTER TABLE users ENABLE ROW LEVEL SECURITY;
   ALTER TABLE task_data ENABLE ROW LEVEL SECURITY;

   -- 创建安全策略
   CREATE POLICY "允许所有用户访问" ON users FOR ALL USING (true);
   CREATE POLICY "允许所有用户访问任务数据" ON task_data FOR ALL USING (true);
   ```

#### 方法二：使用Supabase Table Editor（图形界面）

1. **创建users表**
   - 点击 "Table Editor"
   - 点击 "Create a new table"
   - 表名: `users`
   - 添加列:
     - `id`: uuid, primary key, default: gen_random_uuid()
     - `username`: varchar(50), not null
     - `created_at`: timestamptz, default: now()

2. **创建task_data表**
   - 表名: `task_data`
   - 添加列:
     - `id`: uuid, primary key, default: gen_random_uuid()
     - `user_id`: uuid, foreign key to users.id
     - `data`: jsonb, not null
     - `last_update_time`: int8, not null
     - `created_at`: timestamptz, default: now()
     - `updated_at`: timestamptz, default: now()

### 3. 验证表创建成功

在SQL编辑器中运行以下查询验证：
```sql
-- 检查表是否创建成功
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'task_data');

-- 检查表结构
\d users
\d task_data
```

### 4. 其他常见问题

#### 问题：无法连接到Supabase
**解决方案**:
- 检查网络连接
- 确认Supabase项目状态正常
- 验证API密钥是否正确

#### 问题：数据不同步
**解决方案**:
1. 检查浏览器控制台是否有错误
2. 验证Supabase配置文件
3. 确认RLS策略设置正确

#### 问题：GitHub Pages部署失败
**解决方案**:
1. 检查GitHub Actions日志
2. 确认所有文件路径正确
3. 验证配置文件格式

### 5. 调试工具

#### 浏览器开发者工具
```javascript
// 在控制台中检查Supabase连接
console.log('Supabase配置:', window.SUPABASE_CONFIG);
console.log('Supabase客户端:', window.supabaseConfig);

// 测试数据库连接
window.supabaseConfig.supabase
  .from('users')
  .select('*')
  .limit(1)
  .then(result => console.log('数据库连接测试:', result));
```

#### Supabase日志
- 在Supabase控制台查看 "Logs" 部分
- 监控API请求和错误信息

### 6. 联系支持

如果问题仍然存在：
1. 查看Supabase官方文档: https://supabase.com/docs
2. 访问Supabase社区: https://github.com/supabase/supabase/discussions
3. 提交GitHub Issue并附上详细错误信息

## 📋 检查清单

部署前请确认：
- [ ] Supabase项目已创建
- [ ] 数据库表已正确创建
- [ ] RLS策略已设置
- [ ] API密钥已正确配置
- [ ] 配置文件已创建且格式正确
- [ ] GitHub Pages已启用
- [ ] 网络连接正常

## 🔍 快速诊断

运行以下命令进行快速诊断：
```bash
# 检查配置文件
node deploy-setup.js check

# 验证项目结构
ls -la config/
ls -la js/