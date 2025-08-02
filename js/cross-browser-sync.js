/**
 * 跨浏览器数据同步解决方案
 * 通过服务器端文件实现数据共享
 */

class CrossBrowserSync {
    constructor() {
        this.syncEndpoint = '/api/data-sync';
        this.syncInterval = 5000; // 5秒同步一次
        this.lastSyncTime = 0;
        this.isOnline = navigator.onLine;
        this.syncTimer = null;
        
        this.init();
    }

    init() {
        // 监听网络状态
        window.addEventListener('online', () => {
            this.isOnline = true;
            this.startSync();
        });
        
        window.addEventListener('offline', () => {
            this.isOnline = false;
            this.stopSync();
        });

        // 页面可见时立即同步
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && this.isOnline) {
                this.syncNow();
            }
        });

        // 启动定期同步
        this.startSync();
    }

    // 启动同步
    startSync() {
        if (this.syncTimer) {
            clearInterval(this.syncTimer);
        }

        this.syncTimer = setInterval(() => {
            this.syncNow();
        }, this.syncInterval);

        // 立即执行一次同步
        this.syncNow();
    }

    // 停止同步
    stopSync() {
        if (this.syncTimer) {
            clearInterval(this.syncTimer);
            this.syncTimer = null;
        }
    }

    // 立即同步
    async syncNow() {
        if (!this.isOnline) return;

        try {
            const localData = this.getLocalData();
            const serverData = await this.fetchServerData();
            
            if (this.needsSync(localData, serverData)) {
                const mergedData = this.mergeData(localData, serverData);
                await this.saveToServer(mergedData);
                this.saveToLocal(mergedData);
                this.notifyDataUpdate();
            }
        } catch (error) {
            console.warn('同步失败，使用本地数据:', error.message);
            // 同步失败时不影响本地功能
        }
    }

    // 获取本地数据
    getLocalData() {
        try {
            const data = localStorage.getItem('taskManagerData');
            return data ? JSON.parse(data) : null;
        } catch (error) {
            console.error('读取本地数据失败:', error);
            return null;
        }
    }

    // 获取服务器数据
    async fetchServerData() {
        const response = await fetch(this.syncEndpoint, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            }
        });

        if (!response.ok) {
            throw new Error(`服务器响应错误: ${response.status}`);
        }

        return await response.json();
    }

    // 判断是否需要同步
    needsSync(localData, serverData) {
        if (!localData && !serverData) return false;
        if (!localData || !serverData) return true;
        
        const localTime = localData.lastUpdateTime || 0;
        const serverTime = serverData.lastUpdateTime || 0;
        
        return Math.abs(localTime - serverTime) > 1000; // 1秒差异就同步
    }

    // 合并数据
    mergeData(localData, serverData) {
        if (!localData) return serverData;
        if (!serverData) return localData;

        const localTime = localData.lastUpdateTime || 0;
        const serverTime = serverData.lastUpdateTime || 0;

        // 使用最新的数据
        if (localTime > serverTime) {
            return { ...localData, lastUpdateTime: Date.now() };
        } else {
            return { ...serverData, lastUpdateTime: Date.now() };
        }
    }

    // 保存到服务器
    async saveToServer(data) {
        const response = await fetch(this.syncEndpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });

        if (!response.ok) {
            throw new Error(`保存到服务器失败: ${response.status}`);
        }

        return await response.json();
    }

    // 保存到本地
    saveToLocal(data) {
        try {
            localStorage.setItem('taskManagerData', JSON.stringify(data));
            this.lastSyncTime = Date.now();
        } catch (error) {
            console.error('保存到本地失败:', error);
        }
    }

    // 通知数据更新
    notifyDataUpdate() {
        window.dispatchEvent(new CustomEvent('crossBrowserDataSync', {
            detail: { timestamp: Date.now() }
        }));
    }

    // 手动触发同步
    forcSync() {
        return this.syncNow();
    }
}

// 简化版本：基于API的数据共享
class SimpleFileSync {
    constructor() {
        this.syncEndpoint = '/api/data-sync.php';
        this.checkInterval = 3000; // 3秒检查一次
        this.lastCheckTime = 0;
        this.isChecking = false;
        this.retryCount = 0;
        this.maxRetries = 3;
        this.storageKey = 'taskManagerData';
        
        this.init();
    }

    init() {
        // 页面可见时检查数据
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden) {
                console.log('🔄 页面变为可见，检查数据同步');
                this.checkForUpdates();
            }
        });

        // 定期检查
        setInterval(() => {
            this.checkForUpdates();
        }, this.checkInterval);

        // 启动存储监听器
        this.startStorageListener();

        // 页面获得焦点时检查
        window.addEventListener('focus', () => {
            console.log('🔄 页面获得焦点，检查数据同步');
            this.checkForUpdates();
        });

        // 立即检查一次
        setTimeout(() => {
            this.checkForUpdates();
        }, 1000);
    }

    // 检查数据更新
    async checkForUpdates() {
        if (this.isChecking) return;
        this.isChecking = true;

        try {
            const response = await fetch(this.syncEndpoint + '?t=' + Date.now(), {
                method: 'GET',
                cache: 'no-cache',
                headers: {
                    'Content-Type': 'application/json'
                }
            });

            if (response.ok) {
                const responseData = await response.json();
                
                if (responseData.success && responseData.data) {
                    const serverData = responseData.data;
                    const localData = this.getLocalData();
                    
                    if (this.shouldUpdate(localData, serverData)) {
                        // 合并数据而不是直接覆盖
                        const mergedData = this.mergeData(localData, serverData);
                        this.updateLocalData(mergedData);
                        this.notifyUpdate();
                        console.log('✅ 从服务器更新了数据');
                        this.retryCount = 0; // 重置重试计数
                    }
                } else if (responseData.success && !responseData.data) {
                    // 服务器没有数据，上传本地数据
                    const localData = this.getLocalData();
                    if (localData) {
                        console.log('📤 服务器无数据，上传本地数据');
                        await this.saveToServer(localData);
                    }
                }
            } else {
                console.warn(`服务器响应错误: ${response.status}`);
                this.handleSyncError();
            }
        } catch (error) {
            console.warn('数据同步失败:', error.message);
            this.handleSyncError();
        } finally {
            this.isChecking = false;
        }
    }
    
    // 处理同步错误
    handleSyncError() {
        this.retryCount++;
        if (this.retryCount <= this.maxRetries) {
            console.log(`使用本地数据模式 (重试 ${this.retryCount}/${this.maxRetries})`);
            // 如果是第一次失败，尝试保存本地数据到服务器
            if (this.retryCount === 1) {
                const localData = this.getLocalData();
                if (localData) {
                    setTimeout(() => {
                        this.saveToServer(localData).catch(err => 
                            console.warn('保存到服务器失败:', err.message)
                        );
                    }, 1000);
                }
            }
        } else {
            console.error('数据同步失败次数过多，请检查网络连接或服务器状态');
        }
    }

    // 获取本地数据
    getLocalData() {
        try {
            // 尝试多个可能的存储键
            const keys = ['taskManagerData', 'xiaojiu_tasks', 'tasks'];
            
            for (const key of keys) {
                const data = localStorage.getItem(key);
                if (data) {
                    const parsed = JSON.parse(data);
                    if (parsed && (parsed.tasks || parsed.dailyTasks || parsed.completionHistory)) {
                        // 标准化数据格式
                        return this.normalizeData(parsed, key);
                    }
                }
            }
            return null;
        } catch (error) {
            console.error('获取本地数据失败:', error);
            return null;
        }
    }

    // 标准化数据格式
    normalizeData(data, sourceKey) {
        const normalized = {
            version: data.version || '4.2.2',
            lastUpdateTime: data.lastUpdateTime || Date.now(),
            serverUpdateTime: data.serverUpdateTime || 0,
            username: data.username || '小久',
            tasks: data.tasks || [],
            taskTemplates: data.taskTemplates || { daily: [] },
            dailyTasks: data.dailyTasks || {},
            completionHistory: data.completionHistory || {},
            taskTimes: data.taskTimes || {},
            focusRecords: data.focusRecords || {},
            sourceKey: sourceKey // 记录数据来源
        };
        
        return normalized;
    }

    // 合并数据
    mergeData(localData, serverData) {
        if (!localData) return serverData;
        if (!serverData) return localData;

        const localTime = localData.lastUpdateTime || 0;
        const serverTime = serverData.serverUpdateTime || serverData.lastUpdateTime || 0;

        // 如果服务器数据更新，使用服务器数据
        if (serverTime > localTime) {
            console.log('🔄 使用服务器数据 (更新)');
            return {
                ...serverData,
                lastUpdateTime: Date.now()
            };
        } 
        // 如果本地数据更新，合并到服务器数据结构
        else if (localTime > serverTime) {
            console.log('🔄 使用本地数据 (更新)');
            return {
                ...localData,
                lastUpdateTime: Date.now()
            };
        }
        
        // 时间相同，合并数据
        console.log('🔄 合并本地和服务器数据');
        return {
            ...serverData,
            ...localData,
            lastUpdateTime: Date.now()
        };
    }

    // 判断是否应该更新
    shouldUpdate(localData, serverData) {
        if (!localData) return !!serverData;
        if (!serverData) return false;
        
        const localTime = localData.lastUpdateTime || 0;
        const serverTime = serverData.lastUpdateTime || 0;
        
        // 如果服务器时间比本地时间新，或者服务器有serverUpdateTime且比本地新
        return serverTime > localTime || 
               (serverData.serverUpdateTime && serverData.serverUpdateTime > localTime);
    }

    // 更新本地数据
    updateLocalData(data) {
        try {
            // 保存到主要存储键
            localStorage.setItem(this.storageKey, JSON.stringify(data));
            
            // 如果数据有来源键，也更新原来的存储位置
            if (data.sourceKey && data.sourceKey !== this.storageKey) {
                localStorage.setItem(data.sourceKey, JSON.stringify(data));
            }
            
            console.log('💾 本地数据已更新');
        } catch (error) {
            console.error('更新本地数据失败:', error);
        }
    }

    // 通知更新
    notifyUpdate() {
        window.dispatchEvent(new CustomEvent('dataUpdatedFromServer', {
            detail: { timestamp: Date.now() }
        }));
    }

    // 保存数据到服务器
    async saveToServer(data) {
        try {
            // 确保数据有最新的时间戳
            data.lastUpdateTime = Date.now();
            data.serverUpdateTime = Date.now();
            
            const response = await fetch(this.syncEndpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            
            if (response.ok) {
                const result = await response.json();
                if (result.success) {
                    console.log('✅ 数据已保存到服务器:', result.message);
                    this.retryCount = 0; // 重置重试计数
                    return true;
                } else {
                    console.warn('保存到服务器失败:', result.message);
                    return false;
                }
            } else {
                console.warn(`保存到服务器失败: HTTP ${response.status}`);
                return false;
            }
        } catch (error) {
            console.error('保存到服务器失败:', error);
            return false;
        }
    }

    // 监听本地存储变化并自动同步
    startStorageListener() {
        // 监听localStorage变化
        const originalSetItem = localStorage.setItem;
        const self = this;
        
        localStorage.setItem = function(key, value) {
            originalSetItem.apply(this, arguments);
            
            // 如果是任务数据变化，触发同步
            if (key === 'taskManagerData' || key === 'xiaojiu_tasks' || key === 'tasks') {
                console.log('🔄 检测到本地数据变化，准备同步');
                setTimeout(() => {
                    self.checkForUpdates();
                }, 500);
            }
        };
    }

    // 强制同步数据
    async forceSync() {
        console.log('🔄 开始强制同步...');
        
        try {
            const localData = this.getLocalData();
            if (!localData) {
                console.log('❌ 没有本地数据可同步');
                return false;
            }

            // 先尝试从服务器获取数据
            const response = await fetch(this.syncEndpoint + '?t=' + Date.now(), {
                method: 'GET',
                cache: 'no-cache'
            });

            if (response.ok) {
                const responseData = await response.json();
                
                if (responseData.success && responseData.data) {
                    // 合并数据
                    const serverData = responseData.data;
                    const mergedData = this.mergeData(localData, serverData);
                    
                    // 保存合并后的数据到服务器
                    const saveSuccess = await this.saveToServer(mergedData);
                    if (saveSuccess) {
                        // 更新本地数据
                        this.updateLocalData(mergedData);
                        this.notifyUpdate();
                        console.log('✅ 强制同步成功');
                        return true;
                    }
                } else {
                    // 服务器没有数据，直接上传本地数据
                    const saveSuccess = await this.saveToServer(localData);
                    if (saveSuccess) {
                        console.log('✅ 本地数据已上传到服务器');
                        return true;
                    }
                }
            }
            
            console.log('❌ 强制同步失败');
            return false;
            
        } catch (error) {
            console.error('强制同步出错:', error);
            return false;
        }
    }
}

// 创建数据同步实例
window.dataSyncManager = new SimpleFileSync();

// 监听数据更新事件
window.addEventListener('dataUpdatedFromServer', () => {
    console.log('🔄 检测到服务器数据更新');
    if (window.taskManager) {
        window.taskManager.refreshAllData();
    }
});

// 监听本地数据变化，自动同步到服务器
window.addEventListener('storage', (e) => {
    if (e.key === 'taskManagerData' && e.newValue) {
        console.log('🔄 检测到本地数据变化，准备同步到服务器');
        setTimeout(() => {
            if (window.dataSyncManager) {
                const localData = window.dataSyncManager.getLocalData();
                if (localData) {
                    window.dataSyncManager.saveToServer(localData);
                }
            }
        }, 1000);
    }
});

// 页面获得焦点时立即检查同步
window.addEventListener('focus', () => {
    if (window.dataSyncManager) {
        console.log('🔄 页面获得焦点，检查数据同步');
        window.dataSyncManager.checkForUpdates();
    }
});

console.log('跨浏览器数据同步已启动');
