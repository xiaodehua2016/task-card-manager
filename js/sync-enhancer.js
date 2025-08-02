/**
 * 数据同步增强器
 * 专门解决跨浏览器数据同步问题
 */

class SyncEnhancer {
    constructor() {
        this.syncEndpoint = '/api/data-sync.php';
        this.storageKey = 'taskManagerData';
        this.syncInterval = 2000; // 2秒同步一次
        this.isActive = true;
        this.lastSyncTime = 0;
        this.syncTimer = null;
        
        this.init();
    }

    init() {
        console.log('🚀 数据同步增强器启动');
        
        // 立即启动同步
        this.startContinuousSync();
        
        // 监听页面事件
        this.setupEventListeners();
        
        // 监听数据变化
        this.setupDataChangeListener();
        
        // 页面卸载时保存数据
        this.setupUnloadHandler();
    }

    // 启动持续同步
    startContinuousSync() {
        if (this.syncTimer) {
            clearInterval(this.syncTimer);
        }
        
        this.syncTimer = setInterval(() => {
            if (this.isActive) {
                this.performSync();
            }
        }, this.syncInterval);
        
        // 立即执行一次
        setTimeout(() => this.performSync(), 500);
    }

    // 执行同步
    async performSync() {
        try {
            const localData = this.getLocalData();
            const serverData = await this.getServerData();
            
            if (this.needsSync(localData, serverData)) {
                const mergedData = this.mergeData(localData, serverData);
                
                // 保存到服务器
                const serverSaved = await this.saveToServer(mergedData);
                
                if (serverSaved) {
                    // 更新本地数据
                    this.saveToLocal(mergedData);
                    
                    // 通知其他组件
                    this.notifyDataUpdate(mergedData);
                    
                    console.log('🔄 数据同步完成');
                }
            }
        } catch (error) {
            console.warn('同步过程中出现错误:', error.message);
        }
    }

    // 获取本地数据
    getLocalData() {
        try {
            const data = localStorage.getItem(this.storageKey);
            return data ? JSON.parse(data) : null;
        } catch (error) {
            console.error('读取本地数据失败:', error);
            return null;
        }
    }

    // 获取服务器数据
    async getServerData() {
        try {
            const response = await fetch(this.syncEndpoint + '?t=' + Date.now(), {
                method: 'GET',
                cache: 'no-cache',
                headers: {
                    'Content-Type': 'application/json'
                }
            });

            if (response.ok) {
                const result = await response.json();
                return result.success ? result.data : null;
            }
            return null;
        } catch (error) {
            console.warn('获取服务器数据失败:', error.message);
            return null;
        }
    }

    // 判断是否需要同步
    needsSync(localData, serverData) {
        if (!localData && !serverData) return false;
        if (!localData || !serverData) return true;
        
        const localTime = localData.lastUpdateTime || 0;
        const serverTime = Math.max(
            serverData.lastUpdateTime || 0,
            serverData.serverUpdateTime || 0
        );
        
        return Math.abs(localTime - serverTime) > 1000; // 1秒差异就同步
    }

    // 合并数据
    mergeData(localData, serverData) {
        if (!localData) return serverData;
        if (!serverData) return localData;

        const localTime = localData.lastUpdateTime || 0;
        const serverTime = Math.max(
            serverData.lastUpdateTime || 0,
            serverData.serverUpdateTime || 0
        );

        let mergedData;
        
        if (serverTime > localTime) {
            // 服务器数据更新
            mergedData = { ...serverData };
            console.log('📥 使用服务器数据');
        } else if (localTime > serverTime) {
            // 本地数据更新
            mergedData = { ...localData };
            console.log('📤 使用本地数据');
        } else {
            // 时间相同，智能合并
            mergedData = this.intelligentMerge(localData, serverData);
            console.log('🔄 智能合并数据');
        }

        // 更新时间戳
        mergedData.lastUpdateTime = Date.now();
        mergedData.serverUpdateTime = Date.now();
        
        return mergedData;
    }

    // 智能合并数据
    intelligentMerge(localData, serverData) {
        const merged = { ...serverData };
        
        // 合并任务完成状态
        if (localData.completionHistory && serverData.completionHistory) {
            const today = this.getTodayString();
            const localCompletion = localData.completionHistory[today] || [];
            const serverCompletion = serverData.completionHistory[today] || [];
            
            // 取两者的并集（任何一边完成的任务都算完成）
            const mergedCompletion = localCompletion.map((local, index) => 
                local || (serverCompletion[index] || false)
            );
            
            merged.completionHistory[today] = mergedCompletion;
        }
        
        // 合并任务时间记录
        if (localData.taskTimes && serverData.taskTimes) {
            merged.taskTimes = { ...serverData.taskTimes, ...localData.taskTimes };
        }
        
        // 合并专注记录
        if (localData.focusRecords && serverData.focusRecords) {
            merged.focusRecords = { ...serverData.focusRecords, ...localData.focusRecords };
        }
        
        return merged;
    }

    // 保存到服务器
    async saveToServer(data) {
        try {
            const response = await fetch(this.syncEndpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                const result = await response.json();
                return result.success;
            }
            return false;
        } catch (error) {
            console.error('保存到服务器失败:', error);
            return false;
        }
    }

    // 保存到本地
    saveToLocal(data) {
        try {
            localStorage.setItem(this.storageKey, JSON.stringify(data));
            this.lastSyncTime = Date.now();
        } catch (error) {
            console.error('保存到本地失败:', error);
        }
    }

    // 通知数据更新
    notifyDataUpdate(data) {
        window.dispatchEvent(new CustomEvent('syncEnhancerUpdate', {
            detail: { 
                data: data,
                timestamp: Date.now() 
            }
        }));
    }

    // 设置事件监听器
    setupEventListeners() {
        // 页面可见性变化
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden) {
                console.log('🔄 页面变为可见，立即同步');
                this.performSync();
            }
        });

        // 页面获得焦点
        window.addEventListener('focus', () => {
            console.log('🔄 页面获得焦点，立即同步');
            this.performSync();
        });

        // 网络状态变化
        window.addEventListener('online', () => {
            console.log('🌐 网络恢复，恢复同步');
            this.isActive = true;
            this.startContinuousSync();
        });

        window.addEventListener('offline', () => {
            console.log('📴 网络断开，暂停同步');
            this.isActive = false;
        });
    }

    // 设置数据变化监听器
    setupDataChangeListener() {
        // 重写localStorage.setItem
        const originalSetItem = localStorage.setItem;
        const self = this;
        
        localStorage.setItem = function(key, value) {
            originalSetItem.apply(this, arguments);
            
            if (key === self.storageKey) {
                console.log('📝 检测到本地数据变化');
                setTimeout(() => {
                    self.performSync();
                }, 100);
            }
        };
    }

    // 设置页面卸载处理器
    setupUnloadHandler() {
        window.addEventListener('beforeunload', () => {
            // 页面卸载前强制同步一次
            const localData = this.getLocalData();
            if (localData) {
                // 使用同步请求确保数据保存
                navigator.sendBeacon(this.syncEndpoint, JSON.stringify(localData));
            }
        });
    }

    // 获取今日日期字符串
    getTodayString() {
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    // 强制立即同步
    async forceSync() {
        console.log('🔄 强制立即同步');
        return await this.performSync();
    }

    // 停止同步
    stop() {
        this.isActive = false;
        if (this.syncTimer) {
            clearInterval(this.syncTimer);
            this.syncTimer = null;
        }
        console.log('⏹️ 数据同步已停止');
    }

    // 重启同步
    restart() {
        this.isActive = true;
        this.startContinuousSync();
        console.log('▶️ 数据同步已重启');
    }
}

// 创建全局同步增强器实例
window.syncEnhancer = new SyncEnhancer();

// 监听同步增强器更新事件
window.addEventListener('syncEnhancerUpdate', (event) => {
    console.log('🔄 同步增强器数据更新:', event.detail);
    
    // 通知任务管理器刷新
    if (window.taskManager && typeof window.taskManager.refreshAllData === 'function') {
        window.taskManager.refreshAllData();
    }
});

// 提供全局控制函数
window.forceSyncNow = () => window.syncEnhancer.forceSync();
window.stopSync = () => window.syncEnhancer.stop();
window.startSync = () => window.syncEnhancer.restart();

console.log('🚀 数据同步增强器已加载');