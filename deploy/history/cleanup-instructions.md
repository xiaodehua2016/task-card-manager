# 数据库清理执行指南

## ⚠️ 重要提醒
**执行前必须备份数据库！**

## 🔧 执行步骤

### 1. 登录Supabase控制台
- 访问: https://supabase.com/dashboard
- 选择您的项目: `task-card-manager`

### 2. 进入SQL编辑器
- 点击左侧菜单 "SQL Editor"
- 点击 "New query"

### 3. 执行清理脚本
推荐使用 `safe-cleanup.sql`，步骤如下：

```sql
-- 复制 safe-cleanup.sql 的内容到SQL编辑器
-- 点击 "Run" 按钮执行
```

### 4. 验证结果
执行后应该看到：
- Users: 1 (只有一个用户记录)
- Task Data: 保持原有数量
- Final user: id, username='小久', created_at

### 5. 测试应用
- 访问: https://xiaodehua2016.github.io/task-card-manager/
- 检查数据是否正常
- 测试跨浏览器同步功能

## 🎯 预期结果

### 清理前
```
Users: 7 records (多个重复用户)
Task Data: 4 records (分散在不同用户下)
```

### 清理后
```
Users: 1 record (统一用户: 小久)
Task Data: 1 record (合并到统一用户下)
```

## 🔄 如果出现问题

### 数据恢复
如果清理后出现问题，可以：
1. 从备份恢复数据库
2. 或者删除所有数据，让应用重新初始化

### 重新初始化
```sql
-- 清空所有数据，重新开始
DELETE FROM task_data;
DELETE FROM users;
```

应用会自动创建新的用户和默认任务。

## ✅ 验证清理成功

### 检查用户统一
- 不同浏览器访问应用
- 确认使用同一个用户ID
- 任务状态实时同步

### 检查数据完整性
- 历史完成记录保持完整
- 任务时间统计正常
- 专注记录数据完整

清理完成后，系统将真正实现单用户架构！