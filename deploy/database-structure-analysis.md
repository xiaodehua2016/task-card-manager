# 数据库存储结构分析

## 📋 数据存储位置

### 1. 用户表 (users)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. 任务数据表 (task_data)
```sql
CREATE TABLE task_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    data JSONB NOT NULL,
    last_update_time BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 每日任务完成状态存储

### 存储位置
每日任务完成状态保存在 `task_data` 表的 `data` 字段中（JSONB格式）

### 数据结构
```json
{
  "username": "小久",
  "tasks": ["学而思数感小超市", "斑马思维", "核桃编程（学生端）"],
  "completionHistory": {
    "2025-07-24": [true, false, true],
    "2025-07-25": [false, true, false]
  },
  "taskTimes": {
    "2025-07-24": {
      "0": 1800,  // 任务0用时30分钟
      "1": 900    // 任务1用时15分钟
    }
  },
  "focusRecords": {
    "2025-07-24": [
      {
        "taskIndex": 0,
        "duration": 1800,
        "startTime": "2025-07-24T10:00:00.000Z",
        "endTime": "2025-07-24T10:30:00.000Z"
      }
    ]
  },
  "dailyTasks": {
    "2025-07-24": [
      {
        "id": "task_1721808000000_abc123",
        "name": "学而思数感小超市",
        "type": "daily",
        "enabled": true
      }
    ]
  },
  "lastUpdateTime": 1721808000000,
  "lastModifiedBy": "client_1721808000000_xyz789"
}
```

## 🔄 同步机制

### 本地存储 → 云端同步
1. **localStorage**: 本地存储所有数据
2. **自动上传**: 数据变化时自动上传到Supabase
3. **实时同步**: 监听云端变化，实时下载更新

### 跨设备同步流程
```
设备A修改任务状态 → 上传到云端 → 设备B接收更新 → 自动刷新界面
```

## 📈 数据持久化保证

### 多层保护
1. **本地存储**: localStorage作为主要存储
2. **云端备份**: Supabase作为云端备份和同步
3. **实时同步**: 确保多设备数据一致性
4. **离线支持**: 网络断开时仍可正常使用

### 数据恢复
- 如果本地数据丢失，从云端自动恢复
- 如果云端连接失败，使用本地数据继续工作
- 网络恢复后自动同步最新数据

## 🎯 关键字段说明

### completionHistory
- **格式**: `{"日期": [任务1完成状态, 任务2完成状态, ...]}`
- **类型**: `boolean[]`
- **示例**: `{"2025-07-24": [true, false, true]}`

### taskTimes
- **格式**: `{"日期": {"任务索引": 用时秒数}}`
- **类型**: `{[date]: {[taskIndex]: number}}`
- **示例**: `{"2025-07-24": {"0": 1800}}`

### dailyTasks
- **格式**: `{"日期": [任务对象数组]}`
- **包含**: 任务ID、名称、类型、启用状态
- **支持**: 每日任务、一次性任务、例行任务

## ✅ 结论

**每日任务完成状态完全保存在数据库中**，包括：
- ✅ 每日完成状态记录
- ✅ 任务执行时间统计
- ✅ 专注记录详情
- ✅ 历史数据追踪
- ✅ 跨设备实时同步

数据安全性和可靠性得到充分保障。