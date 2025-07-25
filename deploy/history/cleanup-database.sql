-- 数据库清理脚本 - 清理冗余用户记录
-- 执行前请备份数据！

-- 1. 查看当前用户数量
SELECT COUNT(*) as total_users FROM users;

-- 2. 查看所有用户信息
SELECT id, username, created_at FROM users ORDER BY created_at;

-- 3. 保留最早创建的用户，删除其他重复用户
-- 注意：这会保留第一个创建的用户记录

-- 首先，找到要保留的用户ID（最早创建的）
WITH first_user AS (
    SELECT id 
    FROM users 
    ORDER BY created_at ASC 
    LIMIT 1
)

-- 删除除第一个用户外的所有用户记录
DELETE FROM users 
WHERE id NOT IN (SELECT id FROM first_user);

-- 4. 清理孤立的任务数据（如果有用户被删除）
-- 删除没有对应用户的任务数据
DELETE FROM task_data 
WHERE user_id NOT IN (SELECT id FROM users);

-- 5. 更新保留用户的用户名为"小久"
UPDATE users 
SET username = '小久' 
WHERE id = (SELECT id FROM users ORDER BY created_at ASC LIMIT 1);

-- 6. 验证清理结果
SELECT 'Users after cleanup:' as info;
SELECT id, username, created_at FROM users;

SELECT 'Task data after cleanup:' as info;
SELECT user_id, COUNT(*) as data_count FROM task_data GROUP BY user_id;

-- 7. 重置序列（如果使用自增ID）
-- SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));