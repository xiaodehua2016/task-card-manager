-- 安全的数据库清理脚本
-- 这个脚本会保留数据完整性，只清理冗余用户

-- 步骤1: 备份当前数据（建议在执行前手动备份）
-- pg_dump your_database > backup_before_cleanup.sql

-- 步骤2: 查看当前状态
SELECT 
    'Current database status:' as info,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM task_data) as total_task_records;

-- 步骤3: 找到主用户（有任务数据的用户，或最早创建的用户）
WITH main_user AS (
    -- 优先选择有任务数据的用户
    SELECT DISTINCT u.id, u.username, u.created_at
    FROM users u
    INNER JOIN task_data td ON u.id = td.user_id
    ORDER BY u.created_at ASC
    LIMIT 1
),
fallback_user AS (
    -- 如果没有用户有任务数据，选择最早创建的用户
    SELECT id, username, created_at
    FROM users
    ORDER BY created_at ASC
    LIMIT 1
),
target_user AS (
    SELECT * FROM main_user
    UNION ALL
    SELECT * FROM fallback_user
    WHERE NOT EXISTS (SELECT 1 FROM main_user)
    LIMIT 1
)

-- 显示将要保留的用户
SELECT 'User to keep:' as info, id, username, created_at FROM target_user;

-- 步骤4: 安全删除冗余用户
-- 首先删除没有任务数据的用户
DELETE FROM users 
WHERE id NOT IN (
    SELECT DISTINCT user_id FROM task_data
    UNION
    SELECT id FROM (
        SELECT id FROM users ORDER BY created_at ASC LIMIT 1
    ) first_user
);

-- 步骤5: 如果仍有多个用户，保留最早的一个
WITH users_to_keep AS (
    SELECT id FROM users ORDER BY created_at ASC LIMIT 1
)
DELETE FROM users 
WHERE id NOT IN (SELECT id FROM users_to_keep);

-- 步骤6: 更新保留用户的信息
UPDATE users 
SET username = '小久'
WHERE id = (SELECT id FROM users LIMIT 1);

-- 步骤7: 验证清理结果
SELECT 'Cleanup completed. Final status:' as info;
SELECT 
    'Users:' as table_name,
    COUNT(*) as record_count
FROM users
UNION ALL
SELECT 
    'Task Data:' as table_name,
    COUNT(*) as record_count
FROM task_data;

-- 显示最终的用户信息
SELECT 'Final user:' as info, id, username, created_at FROM users;