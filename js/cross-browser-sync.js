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

// 简化版本：基于文件的数据共享（不需要复杂的服务器API）
class SimpleFileSync {
    constructor() {
        this.dataFile = '/data/shared-tasks.json';
        this.checkInterval = 3000; // 3秒检查一次
        this.lastCheckTime = 0;
        this.isChecking = false;
        this.retryCount = 0;
        this.maxRetries = 3;
        
        this.init();
    }

    init() {
        // 页面可见时检查数据
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden) {
                this.checkForUpdates();
            }
        });

        // 定期检查
        setInterval(() => {
            this.checkForUpdates();
        }, this.checkInterval);

        // 立即检查一次
        this.checkForUpdates();
    }

    // 检查数据更新
    async checkForUpdates() {
        if (this.isChecking) return;
        this.isChecking = true;

        try {
            const response = await fetch(this.dataFile + '?t=' + Date.now(), {
                method: 'GET',
                cache: 'no-cache'
            });

            if (response.ok) {
                const responseData = await response.json();
                // 检查响应数据结构
                const serverData = responseData.data || responseData;
                const localData = this.getLocalData();
                
                if (this.shouldUpdate(localData, serverData)) {
                    this.updateLocalData(serverData);
                    this.notifyUpdate();
                    console.log('✅ 从服务器更新了数据');
                    this.retryCount = 0; // 重置重试计数
                }
            } else {
                console.warn(`服务器响应错误: ${response.status}`);
                this.handleSyncError();
            }
        } catch (error) {
            // 文件不存在或网络错误，使用本地数据
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
            const data = localStorage.getItem('taskManagerData');
            return data ? JSON.parse(data) : null;
        } catch (error) {
            return null;
        }
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
    updateLocalData(serverData) {
        try {
            localStorage.setItem('taskManagerData', JSON.stringify(serverData));
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
            if (!data.lastUpdateTime) {
                data.lastUpdateTime = Date.now();
            }
            
            const response = await fetch('/api/data-sync.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            
            if (response.ok) {
                const result = await response.json();
                console.log('✅ 数据已保存到服务器:', result.message);
                return true;
            } else {
                console.warn(`保存到服务器失败: ${response.status}`);
                return false;
            }
        } catch (error) {
            console.error('保存到服务器失败:', error);
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

console.log('跨浏览器数据同步已启动');