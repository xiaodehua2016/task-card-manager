# 小久的任务卡片管理系统 v3.0 发布部署文档

## 🎉 版本信息

**版本号**: v3.0  
**发布日期**: 2025年7月24日  
**版本类型**: 重大功能更新  
**兼容性**: 向下兼容v2.x版本数据  

## 🚀 v3.0 新功能特性

### 🌟 核心新功能
1. **多设备云端同步**
   - 支持手机、平板、电脑间实时数据同步
   - 基于Supabase云数据库的安全存储
   - 智能冲突解决机制
   - 离线使用支持，联网后自动同步

2. **增强的任务管理系统**
   - 每日任务模板管理
   - 一次性任务支持
   - 例行任务调度
   - 任务类型标签和分类

3. **实时数据同步**
   - WebSocket实时通信
   - 多客户端状态同步
   - 自动数据备份
   - 数据完整性保护

### 🔧 技术升级
- **云数据库集成**: Supabase PostgreSQL
- **实时通信**: 基于WebSocket的实时同步
- **错误处理**: 完善的异常处理和容错机制
- **用户体验**: 同步状态提示和进度反馈

## 📋 部署前准备

### 1. 环境要求
- **Git**: 用于版本控制和部署
- **GitHub账户**: 用于代码托管和Pages部署
- **Supabase账户**: 用于云数据库服务
- **现代浏览器**: Chrome/Firefox/Safari/Edge

### 2. 数据备份（重要）
如果从旧版本升级，请先备份数据：
```javascript
// 在浏览器控制台执行
const backup = localStorage.getItem('taskManagerData');
console.log('备份数据:', backup);
// 复制输出的数据保存到文件
```

### 3. Supabase项目准备
- 创建新的Supabase项目
- 记录项目URL和API密钥
- 准备执行数据库初始化SQL

## 🛠️ 部署步骤

### 第一步：获取v3.0代码
```bash
# 克隆或更新代码仓库
git clone https://github.com/your-username/task-card-manager.git
cd task-card-manager

# 或者更新现有仓库
git pull origin main
git checkout v3.0  # 切换到v3.0标签
```

### 第二步：配置Supabase数据库

#### 2.1 创建数据库表
在Supabase SQL编辑器中执行：
```sql
-- 创建用户表
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建任务数据表
CREATE TABLE task_data (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    data JSONB NOT NULL,
    last_update_time BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id)
);

-- 创建索引
CREATE INDEX idx_task_data_update_time ON task_data(last_update_time);
CREATE INDEX idx_task_data_user_id ON task_data(user_id);

-- 启用实时功能
ALTER PUBLICATION supabase_realtime ADD TABLE task_data;
```

#### 2.2 插入默认数据（可选）
```sql
-- 插入默认用户和任务模板
INSERT INTO users (id, username) 
VALUES ('00000000-0000-0000-0000-000000000001', '小久')
ON CONFLICT (id) DO NOTHING;

INSERT INTO task_data (user_id, data, last_update_time) 
VALUES (
    '00000000-0000-0000-0000-000000000001',
    jsonb_build_object(
        'username', '小久',
        'taskTemplates', jsonb_build_object(
            'daily', jsonb_build_array(
                jsonb_build_object('name', '数学练习', 'enabled', true, 'type', 'daily'),
                jsonb_build_object('name', '编程学习', 'enabled', true, 'type', 'daily'),
                jsonb_build_object('name', '英语阅读', 'enabled', true, 'type', 'daily'),
                jsonb_build_object('name', '体育锻炼', 'enabled', true, 'type', 'daily'),
                jsonb_build_object('name', '阅读时间', 'enabled', true, 'type', 'daily'),
                jsonb_build_object('name', '写作练习', 'enabled', true, 'type', 'daily'),
                jsonb_build_object('name', '艺术创作', 'enabled', true, 'type', 'daily'),
                jsonb_build_object('name', '整理房间', 'enabled', true, 'type', 'daily')
            )
        ),
        'dailyTasks', '{}'::jsonb,
        'completionHistory', '{}'::jsonb,
        'taskTimes', '{}'::jsonb,
        'focusRecords', '{}'::jsonb,
        'lastUpdateTime', (extract(epoch from now()) * 1000)::bigint
    ),
    (extract(epoch from now()) * 1000)::bigint
)
ON CONFLICT (user_id) DO NOTHING;
```

### 第三步：配置项目

#### 3.1 使用浏览器配置工具（推荐）
1. 双击打开 `deploy/simple-setup.html`
2. 输入您的Supabase URL和API密钥
3. 点击"生成配置文件"
4. 下载生成的 `supabase.js` 文件
5. 将文件放置到 `config/` 目录

#### 3.2 使用一键配置脚本
```bash
# Windows
deploy\setup.bat

# macOS/Linux
chmod +x deploy/setup.sh
./deploy/setup.sh
```

#### 3.3 手动配置
编辑 `config/supabase.js` 文件：
```javascript
window.SUPABASE_CONFIG = {
    url: 'https://你的项目ID.supabase.co',
    anonKey: '你的API密钥',
    options: {
        auth: {
            autoRefreshToken: true,
            persistSession: true,
            detectSessionInUrl: true
        }
    }
};
```

### 第四步：部署到GitHub Pages

#### 4.1 推送代码
```bash
git add .
git commit -m "部署v3.0版本 - 添加多设备云端同步功能"
git push origin main
```

#### 4.2 启用GitHub Pages
1. 进入GitHub仓库设置
2. 找到"Pages"选项
3. 选择"GitHub Actions"作为源
4. 等待自动部署完成

#### 4.3 配置GitHub Secrets（可选）
如果需要在GitHub Actions中使用环境变量：
1. 进入仓库设置 → Secrets and variables → Actions
2. 添加以下secrets：
   - `SUPABASE_URL`: 您的Supabase项目URL
   - `SUPABASE_ANON_KEY`: 您的Supabase API密钥

## ✅ 部署验证

### 1. 功能验证清单
- [ ] 网站可以正常访问
- [ ] 任务可以正常添加和完成
- [ ] 数据在多设备间同步
- [ ] 离线使用正常
- [ ] 专注力训练功能正常
- [ ] 统计页面显示正确

### 2. 浏览器控制台检查
打开F12开发者工具，确认看到：
```
✅ Supabase配置已加载
✅ Supabase客户端初始化成功
✅ 用户验证成功
✅ 云端同步已启用
```

### 3. 多设备同步测试
1. 在设备A上完成一个任务
2. 在设备B上刷新页面
3. 确认任务状态已同步

## 🔄 数据迁移（从v2.x升级）

### 自动迁移
v3.0版本会自动检测并迁移v2.x的本地数据：
1. 首次访问时自动读取localStorage数据
2. 将数据上传到云端数据库
3. 保留本地数据作为备份

### 手动迁移
如果自动迁移失败，可以手动操作：
```javascript
// 1. 导出旧版本数据
const oldData = localStorage.getItem('taskManagerData');

// 2. 在新版本中导入
// 进入任务编辑页面，使用"导入数据"功能
```

## 🚨 故障排除

### 常见问题
1. **配置文件未找到**
   - 确认 `config/supabase.js` 文件存在
   - 检查文件路径和权限

2. **数据库连接失败**
   - 验证Supabase URL和API密钥
   - 检查网络连接
   - 确认数据库表已创建

3. **数据不同步**
   - 检查浏览器控制台错误
   - 确认实时功能已启用
   - 验证用户权限设置

### 获取帮助
- 查看 `deploy/TROUBLESHOOTING.md`
- 检查 `PROJECT_STATUS.md`
- 提交GitHub Issues

## 📊 版本对比

| 功能 | v2.x | v3.0 |
|------|------|------|
| 本地存储 | ✅ | ✅ |
| 多设备同步 | ❌ | ✅ |
| 云端备份 | ❌ | ✅ |
| 实时通信 | ❌ | ✅ |
| 离线支持 | ✅ | ✅ |
| 任务类型 | 基础 | 增强 |
| 用户界面 | 静态 | 动态反馈 |

## 🎯 升级建议

### 推荐升级用户
- 需要多设备同步的用户
- 希望数据云端备份的用户
- 家庭多成员使用的用户
- 需要实时协作的用户

### 升级注意事项
- 升级前请备份数据
- 确保网络连接稳定
- 建议在非高峰时间升级
- 准备好Supabase账户

## 🔮 后续版本规划

### v3.1 计划功能
- 任务提醒推送
- 家长监控面板
- 数据导出增强
- 性能优化

### v4.0 展望
- PWA离线应用
- 移动端原生应用
- AI智能推荐
- 多语言支持

---

**部署支持**: 如遇问题请查看故障排除文档或提交Issues  
**技术支持**: 详见项目README和文档目录  
**版本状态**: 生产就绪，推荐升级  

🎉 **欢迎升级到v3.0，享受多设备云端同步的全新体验！**