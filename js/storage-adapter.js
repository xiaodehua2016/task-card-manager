/**
 * 存储适配器 - 统一存储接口
 * 支持文件存储和云端存储的无缝切换
 */
class StorageAdapter {
    constructor() {
        this.fileStorage = new FileStorage();
        this.cloudStorage = null;
        this.useFileStorage = true; // 默认使用文件存储
        this.init();
    }
    
    async init() {
        try {
            // 检查是否有云端存储配置
            if (window.supabaseConfig && window.supabaseConfig.isConfigured) {
                this.cloudStorage = window.supabaseConfig;
                console.log('✅ 检测到云端存储配置');
                
                // 可以选择使用云端存储或文件存储
                const useCloud = localStorage.getItem('use_cloud_storage') === 'true';
                this.useFileStorage = !useCloud;
                
                if (useCloud) {
                    console.log('🌐 使用云端存储模式');
                } else {
                    console.log('📁 使用文件存储模式');
                }
            } else {
                console.log('📁 使用文件存储模式（无云端配置）');
            }
            
            // 初始化文件存储
            await this.fileStorage.init();
            
        } catch (error) {
            console.error('存储适配器初始化失败:', error);
            this.useFileStorage = true;
        }
    }
    
    // 切换存储模式
    async switchStorageMode(useCloud = false) {
        this.useFileStorage = !useCloud;
        localStorage.setItem('use_cloud_storage', useCloud.toString());
        
        if (useCloud && this.cloudStorage) {
            console.log('🌐 切换到云端存储模式');
        } else {
            console.log('📁 切换到文件存储模式');
        }
        
        // 可以在这里实现数据迁移逻辑
        return true;
    }
    
    // 统一的任务加载接口
    async loadTasks() {
        try {
            if (this.useFileStorage) {
                return await this.fileStorage.loadTasks();
            } else if (this.cloudStorage) {
                return await this.loadTasksFromCloud();
            }
            return [];
        } catch (error) {
            console.error('加载任务失败:', error);
            // 降级到文件存储
            return await this.fileStorage.loadTasks();
        }
    }
    
    // 统一的任务保存接口
    async saveTasks(tasks) {
        try {
            let success = false;
            
            if (this.useFileStorage) {
                success = await this.fileStorage.saveTasks(tasks);
            } else if (this.cloudStorage) {
                success = await this.saveTasksToCloud(tasks);
            }
            
            // 如果主存储失败，尝试备用存储
            if (!success) {
                console.warn('主存储失败，尝试备用存储');
                success = await this.fileStorage.saveTasks(tasks);
            }
            
            return success;
        } catch (error) {
            console.error('保存任务失败:', error);
            // 降级到文件存储
            return await this.fileStorage.saveTasks(tasks);
        }
    }
    
    // 从云端加载任务
    async loadTasksFromCloud() {
        if (!this.cloudStorage || !this.cloudStorage.supabase) {
            throw new Error('云端存储未配置');
        }
        
        try {
            const { data, error } = await this.cloudStorage.supabase
                .from('tasks')
                .select('*')
                .order('created_at', { ascending: false });
                
            if (error) throw error;
            
            return data || [];
        } catch (error) {
            console.error('从云端加载任务失败:', error);
            throw error;
        }
    }
    
    // 保存任务到云端
    async saveTasksToCloud(tasks) {
        if (!this.cloudStorage || !this.cloudStorage.supabase) {
            throw new Error('云端存储未配置');
        }
        
        try {
            // 先清空现有数据
            await this.cloudStorage.supabase
                .from('tasks')
                .delete()
                .neq('id', '');
            
            // 插入新数据
            if (tasks.length > 0) {
                const { error } = await this.cloudStorage.supabase
                    .from('tasks')
                    .insert(tasks);
                    
                if (error) throw error;
            }
            
            return true;
        } catch (error) {
            console.error('保存任务到云端失败:', error);
            return false;
        }
    }
    
    // 统计数据接口
    async loadStatistics() {
        try {
            if (this.useFileStorage) {
                return await this.fileStorage.loadStatistics();
            } else if (this.cloudStorage) {
                return await this.loadStatisticsFromCloud();
            }
            return [];
        } catch (error) {
            console.error('加载统计数据失败:', error);
            return await this.fileStorage.loadStatistics();
        }
    }
    
    async saveStatistics(statistics) {
        try {
            let success = false;
            
            if (this.useFileStorage) {
                success = await this.fileStorage.saveStatistics(statistics);
            } else if (this.cloudStorage) {
                success = await this.saveStatisticsToCloud(statistics);
            }
            
            if (!success) {
                success = await this.fileStorage.saveStatistics(statistics);
            }
            
            return success;
        } catch (error) {
            console.error('保存统计数据失败:', error);
            return await this.fileStorage.saveStatistics(statistics);
        }
    }
    
    // 设置接口
    async loadSettings() {
        return await this.fileStorage.loadSettings();
    }
    
    async saveSettings(settings) {
        return await this.fileStorage.saveSettings(settings);
    }
    
    // 数据同步
    async syncData() {
        try {
            if (!this.cloudStorage || this.useFileStorage) {
                console.log('文件存储模式，无需同步');
                return true;
            }
            
            // 实现双向同步逻辑
            const localTasks = await this.fileStorage.loadTasks();
            const cloudTasks = await this.loadTasksFromCloud();
            
            // 简单的同步策略：以最新修改时间为准
            const mergedTasks = this.mergeTasks(localTasks, cloudTasks);
            
            // 同步到两端
            await this.fileStorage.saveTasks(mergedTasks);
            await this.saveTasksToCloud(mergedTasks);
            
            console.log('✅ 数据同步完成');
            return true;
            
        } catch (error) {
            console.error('数据同步失败:', error);
            return false;
        }
    }
    
    // 合并任务数据
    mergeTasks(localTasks, cloudTasks) {
        const taskMap = new Map();
        
        // 添加本地任务
        localTasks.forEach(task => {
            taskMap.set(task.id, task);
        });
        
        // 合并云端任务（以最新修改时间为准）
        cloudTasks.forEach(cloudTask => {
            const localTask = taskMap.get(cloudTask.id);
            if (!localTask || new Date(cloudTask.updatedAt) > new Date(localTask.updatedAt)) {
                taskMap.set(cloudTask.id, cloudTask);
            }
        });
        
        return Array.from(taskMap.values());
    }
    
    // 获取存储状态
    async getStorageStatus() {
        const fileInfo = await this.fileStorage.getStorageInfo();
        
        return {
            mode: this.useFileStorage ? 'file' : 'cloud',
            fileStorage: fileInfo,
            cloudStorage: {
                available: !!this.cloudStorage,
                connected: this.cloudStorage ? await this.testCloudConnection() : false
            }
        };
    }
    
    // 测试云端连接
    async testCloudConnection() {
        if (!this.cloudStorage || !this.cloudStorage.supabase) {
            return false;
        }
        
        try {
            const { data, error } = await this.cloudStorage.supabase
                .from('tasks')
                .select('count')
                .limit(1);
                
            return !error;
        } catch (error) {
            return false;
        }
    }
    
    // 导出所有数据
    async exportAllData() {
        return await this.fileStorage.exportAllData();
    }
    
    // 导入数据
    async importData(data) {
        return await this.fileStorage.importData(data);
    }
    
    // 创建备份
    async createBackup() {
        return await this.fileStorage.createBackup();
    }
    
    // 清理数据
    async clearAllData() {
        let success = true;
        
        // 清理文件存储
        const fileSuccess = await this.fileStorage.clearAllData();
        success = success && fileSuccess;
        
        // 清理云端存储
        if (this.cloudStorage) {
            try {
                await this.cloudStorage.supabase
                    .from('tasks')
                    .delete()
                    .neq('id', '');
                    
                await this.cloudStorage.supabase
                    .from('statistics')
                    .delete()
                    .neq('id', '');
                    
            } catch (error) {
                console.error('清理云端数据失败:', error);
                success = false;
            }
        }
        
        return success;
    }
}

// 导出类供其他模块使用
if (typeof module !== 'undefined' && module.exports) {
    module.exports = StorageAdapter;
}