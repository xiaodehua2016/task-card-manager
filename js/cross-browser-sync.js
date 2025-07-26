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
                const serverData = await response.json();
                const localData = this.getLocalData();
                
                if (this.shouldUpdate(localData, serverData)) {
                    this.updateLocalData(serverData);
                    this.notifyUpdate();
                }
            }
        } catch (error) {
            // 文件不存在或网络错误，使用本地数据
            console.log('使用本地数据模式');
        } finally {
            this.isChecking = false;
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
        if (!localData || !serverData) return false;
        
        const localTime = localData.lastUpdateTime || 0;
        const serverTime = serverData.lastUpdateTime || 0;
        
        return serverTime > localTime;
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

    // 保存数据到服务器（通过表单提交）
    async saveToServer(data) {
        try {
            const formData = new FormData();
            formData.append('data', JSON.stringify(data));
            
            const response = await fetch('/api/save-data', {
                method: 'POST',
                body: formData
            });
            
            return response.ok;
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