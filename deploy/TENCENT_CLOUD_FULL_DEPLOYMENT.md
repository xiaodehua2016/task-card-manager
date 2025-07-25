# 腾讯云全栈部署完整方案

## 🎯 整体架构设计

### 完全腾讯云化架构
```
用户访问 → 腾讯云CDN → 腾讯云静态托管 → 腾讯云数据库
    ↓           ↓              ↓              ↓
  国内用户    全球加速      前端应用        数据存储
```

## 🗄️ 数据库迁移方案

### 方案一：腾讯云MySQL（推荐）

#### 1. 数据库选择
- **产品**：腾讯云数据库MySQL 8.0
- **规格**：1核1GB（个人项目足够）
- **存储**：20GB SSD
- **费用**：约15-30元/月

#### 2. 数据库设计
```sql
-- 任务表设计
CREATE TABLE tasks (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    user_id VARCHAR(36),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
);

-- 用户表设计
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    settings JSON
);

-- 统计表设计
CREATE TABLE task_statistics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36),
    date DATE,
    completed_tasks INT DEFAULT 0,
    total_tasks INT DEFAULT 0,
    focus_time INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_date (user_id, date)
);
```

#### 3. 数据迁移脚本
```javascript
// 从Supabase迁移到腾讯云MySQL
class DataMigration {
    constructor() {
        this.supabase = new SupabaseClient(/* 原配置 */);
        this.mysql = new MySQL({
            host: 'your-mysql-host.tencentcdb.com',
            user: 'root',
            password: 'your-password',
            database: 'task_manager'
        });
    }
    
    async migrateAllData() {
        console.log('开始数据迁移...');
        
        // 1. 迁移任务数据
        await this.migrateTasks();
        
        // 2. 迁移用户数据
        await this.migrateUsers();
        
        // 3. 迁移统计数据
        await this.migrateStatistics();
        
        console.log('数据迁移完成！');
    }
    
    async migrateTasks() {
        const { data: tasks } = await this.supabase
            .from('tasks')
            .select('*');
            
        for (const task of tasks) {
            await this.mysql.query(
                'INSERT INTO tasks SET ?',
                this.transformTaskData(task)
            );
        }
    }
}
```

### 方案二：腾讯云PostgreSQL

#### 1. 产品选择
- **产品**：腾讯云数据库PostgreSQL
- **优势**：与Supabase兼容性更好
- **费用**：约20-40元/月

#### 2. 迁移优势
```sql
-- 可以直接使用现有的Supabase SQL结构
-- 迁移更简单，兼容性更好
```

### 方案三：腾讯云云开发数据库

#### 1. 产品特点
- **类型**：NoSQL文档数据库
- **优势**：与云开发深度集成
- **费用**：按量付费，成本更低

#### 2. 数据结构调整
```javascript
// 文档数据库结构
const taskDocument = {
    _id: "task_uuid",
    title: "任务标题",
    description: "任务描述",
    category: "工作",
    priority: "high",
    status: "pending",
    dueDate: "2025-01-30",
    createdAt: new Date(),
    updatedAt: new Date(),
    userId: "user_uuid"
};
```

## 🚀 前端部署优化

### 1. 腾讯云静态网站托管配置

#### cloudbaserc.json配置
```json
{
    "envId": "your-env-id",
    "framework": {
        "name": "task-manager",
        "plugins": {
            "client": {
                "use": "@cloudbase/framework-plugin-website",
                "inputs": {
                    "buildCommand": "",
                    "outputPath": "./",
                    "cloudPath": "/",
                    "ignore": [
                        ".git",
                        "node_modules",
                        "deploy"
                    ]
                }
            }
        }
    }
}
```

#### 2. CDN加速配置
```javascript
// 腾讯云CDN配置
const cdnConfig = {
    domain: "your-domain.com",
    origin: "your-env-id.tcloudbaseapp.com",
    cache: {
        "*.js": "30d",
        "*.css": "30d", 
        "*.html": "1h",
        "*.json": "1h"
    },
    compression: true,
    https: true
};
```

## 🔧 代码适配修改

### 1. 数据库连接层重构

#### 新建数据库适配器
```javascript
// db/TencentCloudAdapter.js
class TencentCloudAdapter {
    constructor() {
        this.initConnection();
    }
    
    async initConnection() {
        // 腾讯云数据库连接
        this.db = new TencentDB({
            host: process.env.TENCENT_DB_HOST,
            user: process.env.TENCENT_DB_USER,
            password: process.env.TENCENT_DB_PASSWORD,
            database: process.env.TENCENT_DB_NAME
        });
    }
    
    // 统一的数据操作接口
    async createTask(taskData) {
        const sql = 'INSERT INTO tasks SET ?';
        return await this.db.query(sql, taskData);
    }
    
    async getTasks(userId) {
        const sql = 'SELECT * FROM tasks WHERE user_id = ? ORDER BY created_at DESC';
        return await this.db.query(sql, [userId]);
    }
    
    async updateTask(taskId, updates) {
        const sql = 'UPDATE tasks SET ? WHERE id = ?';
        return await this.db.query(sql, [updates, taskId]);
    }
    
    async deleteTask(taskId) {
        const sql = 'DELETE FROM tasks WHERE id = ?';
        return await this.db.query(sql, [taskId]);
    }
}
```

#### 2. 存储层统一接口
```javascript
// js/storage-unified.js
class UnifiedStorage {
    constructor() {
        this.adapter = this.selectAdapter();
    }
    
    selectAdapter() {
        // 根据环境选择适配器
        if (process.env.USE_TENCENT_DB) {
            return new TencentCloudAdapter();
        } else {
            return new SupabaseAdapter();
        }
    }
    
    // 统一的接口方法
    async saveTasks(tasks) {
        return await this.adapter.saveTasks(tasks);
    }
    
    async loadTasks() {
        return await this.adapter.loadTasks();
    }
}
```

### 3. 环境变量配置

#### 腾讯云环境变量
```javascript
// 在腾讯云控制台配置
const config = {
    // 数据库配置
    TENCENT_DB_HOST: "your-mysql-host.tencentcdb.com",
    TENCENT_DB_USER: "root",
    TENCENT_DB_PASSWORD: "your-password",
    TENCENT_DB_NAME: "task_manager",
    
    // 应用配置
    USE_TENCENT_DB: "true",
    APP_ENV: "production",
    
    // 备用配置（保持兼容）
    SUPABASE_URL: "https://zjnjqnftcmxygunzbqch.supabase.co",
    SUPABASE_ANON_KEY: "your-key"
};
```

## 📊 成本分析

### 腾讯云完整方案费用
| 服务 | 规格 | 月费用 | 年费用 |
|------|------|--------|--------|
| 静态网站托管 | 基础版 | ¥0-10 | ¥0-120 |
| MySQL数据库 | 1核1GB | ¥15-30 | ¥180-360 |
| CDN加速 | 按量付费 | ¥5-20 | ¥60-240 |
| 域名备案 | 可选 | ¥0-100 | ¥0-100 |
| **总计** | | **¥20-160** | **¥240-820** |

### 与现有方案对比
| 方案 | 月成本 | 国内访问 | 数据安全 | 维护难度 |
|------|--------|----------|----------|----------|
| 现有方案 | ¥0 | ⚠️ 需代理 | ⭐⭐⭐ | ⭐⭐ |
| 腾讯云方案 | ¥20-160 | ✅ 直连 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

## 🛠️ 实施步骤

### 阶段一：数据库迁移（1-2周）
1. **创建腾讯云数据库**
   - 选择MySQL 8.0
   - 配置安全组和访问权限
   - 创建数据库和表结构

2. **数据迁移**
   - 导出Supabase数据
   - 转换数据格式
   - 导入腾讯云数据库

3. **代码适配**
   - 创建数据库适配器
   - 修改数据访问层
   - 测试数据操作

### 阶段二：前端部署（1周）
1. **腾讯云静态托管**
   - 上传项目文件
   - 配置环境变量
   - 测试基本功能

2. **CDN配置**
   - 绑定自定义域名
   - 配置缓存策略
   - 启用HTTPS

### 阶段三：测试和优化（1周）
1. **功能测试**
   - 完整功能测试
   - 性能测试
   - 兼容性测试

2. **监控配置**
   - 设置监控告警
   - 配置日志收集
   - 性能监控

## 💡 推荐实施策略

### 渐进式迁移（推荐）
1. **第一步**：保持现有Supabase，先部署前端到腾讯云
2. **第二步**：创建腾讯云数据库，实现双写模式
3. **第三步**：验证数据一致性后，切换到腾讯云数据库
4. **第四步**：逐步下线Supabase依赖

### 一次性迁移（快速）
1. **准备阶段**：完成所有配置和测试
2. **迁移阶段**：一次性切换所有服务
3. **验证阶段**：全面测试和监控

## 🎯 最终建议

### 推荐方案：腾讯云MySQL + 静态托管
**理由：**
- ✅ 国内访问速度最快
- ✅ 数据安全性最高
- ✅ 成本可控（月费用20-50元）
- ✅ 技术栈成熟稳定
- ✅ 后续扩展性好

### 实施优先级
1. **立即实施**：前端部署到腾讯云静态托管
2. **短期规划**：数据库迁移到腾讯云MySQL
3. **长期优化**：CDN加速和性能监控

这样的完整迁移方案既解决了访问问题，又提升了整体的安全性和可维护性。您希望从哪个阶段开始实施？