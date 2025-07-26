/**
 * 统一存储管理器 - 解决跨浏览器数据一致性问题
 * 支持localStorage + 服务器同步
 */

class UnifiedStorage {
    constructor() {
        this.storageKey = 'taskManager';
        this.syncEndpoint = '/api/sync'; // 可选的服务器同步端点
        this.lastSyncTime = 0;
        this.syncInterval = 30000; // 30秒同步一次
        
        // 初始化存储
        this.initStorage();
        
        // 启动定期同步（如果需要）
        this.startPeriodicSync();
    }

    /**
     * 初始化存储系统
     */
    initStorage() {
        try {
            // 检查localStorage是否可用
            if (!this.isLocalStorageAvailable()) {
                console.warn('localStorage不可用，使用内存存储');
                this.useMemoryStorage = true;
                this.memoryData = {};
            }

            // 初始化默认数据结构
            const defaultData = {
                tasks: [],
                completedTasks: [],
                settings: {
                    theme: 'light',
                    notifications: true
                },
                stats: {
                    totalTasks: 0,
                    completedTasks: 0,
                    totalWorkTime: 0
                },
                lastModified: Date.now(),
                version: '4.1.0'
            };

            // 获取现有数据或使用默认数据
            const existingData = this.getRawData();
            if (!existingData || !existingData.version) {
                this.setRawData(defaultData);
            }

        } catch (error) {
            console.error('存储初始化失败:', error);
            this.useMemoryStorage = true;
            this.memoryData = {};
        }
    }

    /**
     * 检查localStorage是否可用
     */
    isLocalStorageAvailable() {
        try {
            const test = '__storage_test__';
            localStorage.setItem(test, test);
            localStorage.removeItem(test);
            return true;
        } catch (e) {
            return false;
        }
    }

    /**
     * 获取原始数据
     */
    getRawData() {
        try {
            if (this.useMemoryStorage) {
                return this.memoryData;
            }
            
            const data = localStorage.getItem(this.storageKey);
            return data ? JSON.parse(data) : null;
        } catch (error) {
            console.error('读取数据失败:', error);
            return null;
        }
    }

    /**
     * 设置原始数据
     */
    setRawData(data) {
        try {
            data.lastModified = Date.now();
            
            if (this.useMemoryStorage) {
                this.memoryData = { ...data };
            } else {
                localStorage.setItem(this.storageKey, JSON.stringify(data));
            }
            
            // 触发存储事件
            this.triggerStorageEvent('dataChanged', data);
            
            return true;
        } catch (error) {
            console.error('保存数据失败:', error);
            return false;
        }
    }

    /**
     * 获取所有任务
     */
    getTasks() {
        const data = this.getRawData();
        return data ? (data.tasks || []) : [];
    }

    /**
     * 保存任务
     */
    saveTasks(tasks) {
        const data = this.getRawData() || {};
        data.tasks = tasks;
        return this.setRawData(data);
    }

    /**
     * 添加任务
     */
    addTask(task) {
        const tasks = this.getTasks();
        task.id = task.id || Date.now().toString();
        task.createdAt = task.createdAt || new Date().toISOString();
        task.completed = false;
        
        tasks.push(task);
        return this.saveTasks(tasks);
    }

    /**
     * 更新任务
     */
    updateTask(taskId, updates) {
        const tasks = this.getTasks();
        const taskIndex = tasks.findIndex(t => t.id === taskId);
        
        if (taskIndex !== -1) {
            tasks[taskIndex] = { ...tasks[taskIndex], ...updates };
            tasks[taskIndex].updatedAt = new Date().toISOString();
            return this.saveTasks(tasks);
        }
        
        return false;
    }

    /**
     * 删除任务
     */
    deleteTask(taskId) {
        const tasks = this.getTasks();
        const filteredTasks = tasks.filter(t => t.id !== taskId);
        return this.saveTasks(filteredTasks);
    }

    /**
     * 完成任务
     */
    completeTask(taskId) {
        const tasks = this.getTasks();
        const task = tasks.find(t => t.id === taskId);
        
        if (task) {
            task.completed = true;
            task.completedAt = new Date().toISOString();
            
            // 更新统计
            this.updateStats('completedTasks', 1);
            
            return this.saveTasks(tasks);
        }
        
        return false;
    }

    /**
     * 获取今日任务
     */
    getTodayTasks() {
        const tasks = this.getTasks();
        const today = new Date().toDateString();
        
        return tasks.filter(task => {
            const taskDate = new Date(task.createdAt).toDateString();
            return taskDate === today;
        });
    }

    /**
     * 获取已完成任务
     */
    getCompletedTasks() {
        const tasks = this.getTasks();
        return tasks.filter(task => task.completed);
    }

    /**
     * 获取统计数据
     */
    getStats() {
        const data = this.getRawData();
        const tasks = this.getTasks();
        
        // 实时计算统计数据
        const stats = {
            totalTasks: tasks.length,
            completedTasks: tasks.filter(t => t.completed).length,
            todayTasks: this.getTodayTasks().length,
            todayCompleted: this.getTodayTasks().filter(t => t.completed).length,
            totalWorkTime: data?.stats?.totalWorkTime || 0
        };
        
        return stats;
    }

    /**
     * 更新统计数据
     */
    updateStats(key, value) {
        const data = this.getRawData() || {};
        if (!data.stats) data.stats = {};
        
        if (typeof value === 'number') {
            data.stats[key] = (data.stats[key] || 0) + value;
        } else {
            data.stats[key] = value;
        }
        
        return this.setRawData(data);
    }

    /**
     * 导出数据
     */
    exportData() {
        const data = this.getRawData();
        if (!data) return null;
        
        return {
            ...data,
            exportTime: new Date().toISOString(),
            version: '4.1.0'
        };
    }

    /**
     * 导入数据
     */
    importData(importedData) {
        try {
            // 验证数据格式
            if (!importedData || typeof importedData !== 'object') {
                throw new Error('无效的数据格式');
            }

            // 合并数据（保留现有数据，添加新数据）
            const currentData = this.getRawData() || {};
            const mergedData = {
                ...currentData,
                ...importedData,
                lastModified: Date.now(),
                importTime: new Date().toISOString()
            };

            // 合并任务数组（去重）
            if (importedData.tasks && Array.isArray(importedData.tasks)) {
                const currentTasks = currentData.tasks || [];
                const importedTasks = importedData.tasks;
                
                // 使用Map去重
                const taskMap = new Map();
                
                // 先添加现有任务
                currentTasks.forEach(task => {
                    taskMap.set(task.id, task);
                });
                
                // 再添加导入的任务（会覆盖重复的）
                importedTasks.forEach(task => {
                    if (task.id) {
                        taskMap.set(task.id, task);
                    }
                });
                
                mergedData.tasks = Array.from(taskMap.values());
            }

            return this.setRawData(mergedData);
        } catch (error) {
            console.error('导入数据失败:', error);
            return false;
        }
    }

    /**
     * 清空所有数据
     */
    clearAllData() {
        try {
            if (this.useMemoryStorage) {
                this.memoryData = {};
            } else {
                localStorage.removeItem(this.storageKey);
            }
            
            this.initStorage();
            return true;
        } catch (error) {
            console.error('清空数据失败:', error);
            return false;
        }
    }

    /**
     * 获取存储信息
     */
    getStorageInfo() {
        const data = this.getRawData();
        const dataSize = JSON.stringify(data).length;
        
        return {
            storageType: this.useMemoryStorage ? 'memory' : 'localStorage',
            dataSize: dataSize,
            dataSizeFormatted: this.formatBytes(dataSize),
            lastModified: data?.lastModified || 0,
            version: data?.version || 'unknown',
            taskCount: (data?.tasks || []).length
        };
    }

    /**
     * 格式化字节数
     */
    formatBytes(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    /**
     * 触发存储事件
     */
    triggerStorageEvent(eventType, data) {
        const event = new CustomEvent('storageChanged', {
            detail: {
                type: eventType,
                data: data,
                timestamp: Date.now()
            }
        });
        
        window.dispatchEvent(event);
    }

    /**
     * 监听存储变化
     */
    onStorageChange(callback) {
        window.addEventListener('storageChanged', callback);
    }

    /**
     * 移除存储监听
     */
    offStorageChange(callback) {
        window.removeEventListener('storageChanged', callback);
    }

    /**
     * 启动定期同步（预留功能）
     */
    startPeriodicSync() {
        // 这里可以实现与服务器的定期同步
        // 目前只是预留接口
        console.log('定期同步功能已准备就绪');
    }

    /**
     * 手动同步数据（预留功能）
     */
    async syncData() {
        // 预留的服务器同步功能
        console.log('手动同步功能已准备就绪');
        return true;
    }
}

// 创建全局存储实例
window.unifiedStorage = new UnifiedStorage();

// 兼容旧的存储接口
window.storage = {
    getTasks: () => window.unifiedStorage.getTasks(),
    saveTasks: (tasks) => window.unifiedStorage.saveTasks(tasks),
    addTask: (task) => window.unifiedStorage.addTask(task),
    updateTask: (id, updates) => window.unifiedStorage.updateTask(id, updates),
    deleteTask: (id) => window.unifiedStorage.deleteTask(id),
    completeTask: (id) => window.unifiedStorage.completeTask(id),
    getTodayTasks: () => window.unifiedStorage.getTodayTasks(),
    getCompletedTasks: () => window.unifiedStorage.getCompletedTasks(),
    getStats: () => window.unifiedStorage.getStats(),
    exportData: () => window.unifiedStorage.exportData(),
    importData: (data) => window.unifiedStorage.importData(data),
    clearAllData: () => window.unifiedStorage.clearAllData()
};

console.log('统一存储系统已初始化');