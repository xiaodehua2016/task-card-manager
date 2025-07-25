/**
 * 文件存储管理类
 * 替代Supabase数据库，使用本地文件和IndexedDB存储
 */
class FileStorage {
    constructor() {
        this.version = '1.0';
        this.dbName = 'TaskManagerDB';
        this.dbVersion = 1;
        this.db = null;
        
        // 数据存储键名
        this.storageKeys = {
            tasks: 'tasks_data',
            statistics: 'statistics_data',
            settings: 'app_settings',
            lastSync: 'last_sync_time'
        };
        
        this.init();
    }
    
    async init() {
        try {
            // 初始化IndexedDB
            await this.initIndexedDB();
            console.log('✅ 文件存储系统初始化成功');
        } catch (error) {
            console.warn('IndexedDB初始化失败，使用LocalStorage:', error);
        }
    }
    
    // 初始化IndexedDB
    async initIndexedDB() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, this.dbVersion);
            
            request.onerror = () => reject(request.error);
            
            request.onsuccess = () => {
                this.db = request.result;
                resolve();
            };
            
            request.onupgradeneeded = (event) => {
                const db = event.target.result;
                
                // 创建任务存储
                if (!db.objectStoreNames.contains('tasks')) {
                    const taskStore = db.createObjectStore('tasks', { keyPath: 'id' });
                    taskStore.createIndex('status', 'status', { unique: false });
                    taskStore.createIndex('category', 'category', { unique: false });
                    taskStore.createIndex('dueDate', 'dueDate', { unique: false });
                    taskStore.createIndex('createdAt', 'createdAt', { unique: false });
                }
                
                // 创建统计存储
                if (!db.objectStoreNames.contains('statistics')) {
                    const statsStore = db.createObjectStore('statistics', { keyPath: 'date' });
                }
                
                // 创建设置存储
                if (!db.objectStoreNames.contains('settings')) {
                    db.createObjectStore('settings', { keyPath: 'key' });
                }
            };
        });
    }
    
    // 加载任务数据
    async loadTasks() {
        try {
            // 优先从IndexedDB加载
            if (this.db) {
                const tasks = await this.getFromIndexedDB('tasks');
                if (tasks && tasks.length > 0) {
                    return tasks;
                }
            }
            
            // 降级到LocalStorage
            const tasksData = localStorage.getItem(this.storageKeys.tasks);
            if (tasksData) {
                const parsed = JSON.parse(tasksData);
                return parsed.tasks || [];
            }
            
            // 返回默认数据
            return this.getDefaultTasks();
            
        } catch (error) {
            console.error('加载任务数据失败:', error);
            return this.getDefaultTasks();
        }
    }
    
    // 保存任务数据
    async saveTasks(tasks) {
        try {
            const data = {
                version: this.version,
                lastUpdated: new Date().toISOString(),
                tasks: tasks
            };
            
            // 保存到IndexedDB
            if (this.db) {
                await this.saveToIndexedDB('tasks', tasks);
            }
            
            // 保存到LocalStorage作为备份
            localStorage.setItem(this.storageKeys.tasks, JSON.stringify(data));
            localStorage.setItem(this.storageKeys.lastSync, new Date().toISOString());
            
            console.log(`✅ 任务数据已保存 (${tasks.length}条)`);
            return true;
            
        } catch (error) {
            console.error('保存任务数据失败:', error);
            return false;
        }
    }
    
    // 从IndexedDB获取数据
    async getFromIndexedDB(storeName) {
        if (!this.db) return null;
        
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            const request = store.getAll();
            
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }
    
    // 保存数据到IndexedDB
    async saveToIndexedDB(storeName, data) {
        if (!this.db) return false;
        
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            
            // 清空现有数据
            const clearRequest = store.clear();
            
            clearRequest.onsuccess = () => {
                // 添加新数据
                if (Array.isArray(data)) {
                    data.forEach(item => store.add(item));
                } else {
                    store.add(data);
                }
                resolve(true);
            };
            
            clearRequest.onerror = () => reject(clearRequest.error);
        });
    }
    
    // 加载统计数据
    async loadStatistics() {
        try {
            if (this.db) {
                const stats = await this.getFromIndexedDB('statistics');
                if (stats && stats.length > 0) {
                    return stats;
                }
            }
            
            const statsData = localStorage.getItem(this.storageKeys.statistics);
            if (statsData) {
                const parsed = JSON.parse(statsData);
                return parsed.statistics || [];
            }
            
            return [];
            
        } catch (error) {
            console.error('加载统计数据失败:', error);
            return [];
        }
    }
    
    // 保存统计数据
    async saveStatistics(statistics) {
        try {
            const data = {
                version: this.version,
                lastUpdated: new Date().toISOString(),
                statistics: statistics
            };
            
            if (this.db) {
                await this.saveToIndexedDB('statistics', statistics);
            }
            
            localStorage.setItem(this.storageKeys.statistics, JSON.stringify(data));
            console.log('✅ 统计数据已保存');
            return true;
            
        } catch (error) {
            console.error('保存统计数据失败:', error);
            return false;
        }
    }
    
    // 加载应用设置
    async loadSettings() {
        try {
            const settingsData = localStorage.getItem(this.storageKeys.settings);
            if (settingsData) {
                return JSON.parse(settingsData);
            }
            
            return this.getDefaultSettings();
            
        } catch (error) {
            console.error('加载设置失败:', error);
            return this.getDefaultSettings();
        }
    }
    
    // 保存应用设置
    async saveSettings(settings) {
        try {
            localStorage.setItem(this.storageKeys.settings, JSON.stringify(settings));
            console.log('✅ 应用设置已保存');
            return true;
        } catch (error) {
            console.error('保存设置失败:', error);
            return false;
        }
    }
    
    // 导出所有数据
    async exportAllData() {
        try {
            const tasks = await this.loadTasks();
            const statistics = await this.loadStatistics();
            const settings = await this.loadSettings();
            
            const exportData = {
                version: this.version,
                exportDate: new Date().toISOString(),
                appName: '小久的任务管理系统',
                data: {
                    tasks: tasks,
                    statistics: statistics,
                    settings: settings
                }
            };
            
            return exportData;
            
        } catch (error) {
            console.error('导出数据失败:', error);
            return null;
        }
    }
    
    // 导入数据
    async importData(importData) {
        try {
            if (!importData || !importData.data) {
                throw new Error('导入数据格式不正确');
            }
            
            const { tasks, statistics, settings } = importData.data;
            
            if (tasks) {
                await this.saveTasks(tasks);
            }
            
            if (statistics) {
                await this.saveStatistics(statistics);
            }
            
            if (settings) {
                await this.saveSettings(settings);
            }
            
            console.log('✅ 数据导入成功');
            return true;
            
        } catch (error) {
            console.error('导入数据失败:', error);
            return false;
        }
    }
    
    // 下载数据文件
    downloadData(data, filename) {
        const blob = new Blob([JSON.stringify(data, null, 2)], {
            type: 'application/json'
        });
        
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }
    
    // 创建备份
    async createBackup() {
        try {
            const exportData = await this.exportAllData();
            if (exportData) {
                const today = new Date().toISOString().split('T')[0];
                const filename = `tasks_backup_${today}.json`;
                this.downloadData(exportData, filename);
                return true;
            }
            return false;
        } catch (error) {
            console.error('创建备份失败:', error);
            return false;
        }
    }
    
    // 获取默认任务数据
    getDefaultTasks() {
        return [
            {
                id: 'welcome_task',
                title: '欢迎使用小久的任务管理系统！',
                description: '这是一个示例任务，您可以编辑或删除它。',
                category: '系统',
                priority: 'medium',
                status: 'pending',
                dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            }
        ];
    }
    
    // 获取默认设置
    getDefaultSettings() {
        return {
            theme: 'light',
            language: 'zh-CN',
            autoBackup: true,
            backupInterval: 7, // 天
            notifications: true,
            soundEnabled: true
        };
    }
    
    // 获取存储统计信息
    async getStorageInfo() {
        try {
            const tasks = await this.loadTasks();
            const statistics = await this.loadStatistics();
            
            return {
                tasksCount: tasks.length,
                statisticsCount: statistics.length,
                lastSync: localStorage.getItem(this.storageKeys.lastSync),
                storageUsed: this.calculateStorageUsage(),
                indexedDBSupported: !!this.db
            };
            
        } catch (error) {
            console.error('获取存储信息失败:', error);
            return null;
        }
    }
    
    // 计算存储使用量
    calculateStorageUsage() {
        let totalSize = 0;
        for (let key in localStorage) {
            if (localStorage.hasOwnProperty(key)) {
                totalSize += localStorage[key].length;
            }
        }
        return Math.round(totalSize / 1024 * 100) / 100; // KB
    }
    
    // 清理存储
    async clearAllData() {
        try {
            // 清理IndexedDB
            if (this.db) {
                const stores = ['tasks', 'statistics', 'settings'];
                for (const storeName of stores) {
                    const transaction = this.db.transaction([storeName], 'readwrite');
                    const store = transaction.objectStore(storeName);
                    await store.clear();
                }
            }
            
            // 清理LocalStorage
            Object.values(this.storageKeys).forEach(key => {
                localStorage.removeItem(key);
            });
            
            console.log('✅ 所有数据已清理');
            return true;
            
        } catch (error) {
            console.error('清理数据失败:', error);
            return false;
        }
    }
}

// 导出类供其他模块使用
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FileStorage;
}