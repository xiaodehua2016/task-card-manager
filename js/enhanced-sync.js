/**
 * 任务管理系统 - 增强同步系统 v4.3.6
 * 功能：解决设备间和浏览器间数据不同步问题，集成详细日志记录
 */

class EnhancedSync {
    constructor() {
        this.config = {
            apiUrl: 'api/data-sync.php',
            syncInterval: 10000, // 10秒同步间隔
            requestTimeout: 8000,
            maxRetries: 3,
            storageKey: 'taskManagerData_v436'
        };
        
        this.state = {
            isOnline: navigator.onLine,
            isSyncing: false,
            syncTimer: null,
            lastSyncTime: 0,
            retryCount: 0,
            deviceId: this.getDeviceId()
        };
        
        this.logger = window.syncLogger;
        this.init();
    }

    init() {
        this.logger?.log('SYSTEM', 'EnhancedSync v4.3.6 初始化开始', {
            deviceId: this.state.deviceId,
            config: this.config
        });

        // 监听网络状态变化
        window.addEventListener('online', () => this.handleOnlineStatusChange(true));
        window.addEventListener('offline', () => this.handleOnlineStatusChange(false));
        
        // 监听页面可见性变化
        document.addEventListener('visibilitychange', () => this.handleVisibilityChange());
        
        // 监听存储变化（跨标签页同步）
        window.addEventListener('storage', (e) => this.handleStorageChange(e));
        
        // 启动同步
        this.startSync();
        
        this.logger?.log('SYSTEM', 'EnhancedSync 初始化完成');
    }

    getDeviceId() {
        let deviceId = localStorage.getItem('taskManager_deviceId');
        if (!deviceId) {
            deviceId = 'device_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
            localStorage.setItem('taskManager_deviceId', deviceId);
        }
        return deviceId;
    }

    startSync() {
        if (this.state.syncTimer) {
            clearInterval(this.state.syncTimer);
        }
        
        this.state.syncTimer = setInterval(() => {
            this.performSync();
        }, this.config.syncInterval);
        
        // 立即执行一次同步
        setTimeout(() => this.performSync(), 1000);
        
        this.logger?.log('SYNC', '同步服务已启动', {
            interval: this.config.syncInterval,
            deviceId: this.state.deviceId
        });
    }

    stopSync() {
        if (this.state.syncTimer) {
            clearInterval(this.state.syncTimer);
            this.state.syncTimer = null;
        }
        this.logger?.log('SYNC', '同步服务已停止');
    }

    async performSync() {
        if (this.state.isSyncing || !this.state.isOnline) {
            return;
        }

        this.state.isSyncing = true;
        const startTime = Date.now();
        
        try {
            const localData = this.getLocalData();
            const localUpdateTime = localData?.lastUpdateTime || 0;
            
            this.logger?.logSyncRequest(this.config.apiUrl, 'GET', { action: 'get' });
            
            // 获取服务器数据
            const serverResponse = await this.fetchWithTimeout(`${this.config.apiUrl}?action=get&deviceId=${this.state.deviceId}`);
            const serverData = await serverResponse.json();
            
            const duration = Date.now() - startTime;
            this.logger?.logSyncResponse(this.config.apiUrl, serverResponse.status, serverData, duration);
            
            if (serverData.success && serverData.data) {
                const serverUpdateTime = serverData.data.lastUpdateTime || 0;
                
                // 数据同步决策
                if (localUpdateTime > serverUpdateTime) {
                    // 本地数据更新，推送到服务器
                    await this.pushToServer(localData);
                    this.logger?.logDataChange('PUSH_TO_SERVER', null, localData);
                    
                } else if (serverUpdateTime > localUpdateTime) {
                    // 服务器数据更新，拉取到本地
                    this.saveLocalData(serverData.data);
                    this.notifyDataUpdate(serverData.data);
                    this.logger?.logDataChange('PULL_FROM_SERVER', localData, serverData.data);
                    
                } else {
                    // 数据一致
                    this.logger?.log('SYNC', '数据已同步，无需更新', {
                        localTime: localUpdateTime,
                        serverTime: serverUpdateTime
                    });
                }
                
                this.state.lastSyncTime = Date.now();
                this.state.retryCount = 0;
                
            } else {
                throw new Error(serverData.message || '服务器返回数据格式错误');
            }
            
        } catch (error) {
            this.handleSyncError(error);
        } finally {
            this.state.isSyncing = false;
        }
    }

    async pushToServer(data) {
        const startTime = Date.now();
        
        // 添加设备信息
        const dataWithDevice = {
            ...data,
            deviceId: this.state.deviceId,
            syncTime: Date.now(),
            browserInfo: this.logger?.clientInfo?.browser
        };
        
        this.logger?.logSyncRequest(this.config.apiUrl, 'POST', { action: 'update', data: dataWithDevice });
        
        const response = await this.fetchWithTimeout(this.config.apiUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                action: 'update', 
                data: dataWithDevice,
                deviceId: this.state.deviceId
            })
        });
        
        const result = await response.json();
        const duration = Date.now() - startTime;
        
        this.logger?.logSyncResponse(this.config.apiUrl, response.status, result, duration);
        
        if (!result.success) {
            throw new Error(result.message || '推送数据到服务器失败');
        }
        
        return result;
    }

    fetchWithTimeout(resource, options = {}) {
        const { timeout = this.config.requestTimeout } = options;
        const controller = new AbortController();
        const id = setTimeout(() => controller.abort(), timeout);
        
        return fetch(resource, {
            ...options,
            signal: controller.signal
        }).finally(() => {
            clearTimeout(id);
        });
    }

    getLocalData() {
        try {
            const data = localStorage.getItem(this.config.storageKey);
            return data ? JSON.parse(data) : null;
        } catch (error) {
            this.logger?.logSyncError('localStorage', error, { action: 'getLocalData' });
            return null;
        }
    }

    saveLocalData(data) {
        try {
            data.lastUpdateTime = Date.now();
            data.deviceId = this.state.deviceId;
            localStorage.setItem(this.config.storageKey, JSON.stringify(data));
            
            this.logger?.log('SYNC', '本地数据已保存', {
                dataHash: this.logger?.hashData(data),
                timestamp: data.lastUpdateTime
            });
            
        } catch (error) {
            this.logger?.logSyncError('localStorage', error, { action: 'saveLocalData' });
        }
    }

    notifyDataUpdate(newData) {
        // 通知主应用数据已更新
        if (window.TaskManager && typeof window.TaskManager.onDataUpdate === 'function') {
            window.TaskManager.onDataUpdate(newData);
        }
        
        // 发送自定义事件
        window.dispatchEvent(new CustomEvent('taskManagerDataUpdate', { 
            detail: { data: newData, source: 'sync' }
        }));
        
        this.logger?.log('SYNC', '数据更新通知已发送');
    }

    handleSyncError(error) {
        this.state.retryCount++;
        this.logger?.logSyncError(this.config.apiUrl, error, {
            retryCount: this.state.retryCount,
            maxRetries: this.config.maxRetries
        });
        
        if (this.state.retryCount >= this.config.maxRetries) {
            this.logger?.log('ERROR', '同步重试次数已达上限，暂停同步', {
                retryCount: this.state.retryCount
            });
            this.stopSync();
            
            // 5分钟后重新尝试
            setTimeout(() => {
                this.state.retryCount = 0;
                this.startSync();
            }, 300000);
        }
    }

    handleOnlineStatusChange(isOnline) {
        this.state.isOnline = isOnline;
        this.logger?.log('SYSTEM', `网络状态变更: ${isOnline ? '在线' : '离线'}`);
        
        if (isOnline) {
            // 网络恢复，立即同步
            setTimeout(() => this.performSync(), 1000);
        }
    }

    handleVisibilityChange() {
        if (!document.hidden) {
            // 页面变为可见，执行同步
            this.logger?.log('SYSTEM', '页面变为可见，执行同步检查');
            setTimeout(() => this.performSync(), 500);
        }
    }

    handleStorageChange(event) {
        if (event.key === this.config.storageKey && event.newValue) {
            // 其他标签页更新了数据
            this.logger?.log('SYNC', '检测到跨标签页数据变更', {
                oldValue: event.oldValue ? 'exists' : 'null',
                newValue: event.newValue ? 'exists' : 'null'
            });
            
            this.notifyDataUpdate(JSON.parse(event.newValue));
        }
    }

    // 手动触发同步
    forcSync() {
        this.logger?.log('SYNC', '手动触发同步');
        return this.performSync();
    }

    // 获取同步状态
    getSyncStatus() {
        return {
            isOnline: this.state.isOnline,
            isSyncing: this.state.isSyncing,
            lastSyncTime: this.state.lastSyncTime,
            deviceId: this.state.deviceId,
            retryCount: this.state.retryCount
        };
    }
}

// 创建全局同步实例
window.enhancedSync = new EnhancedSync();

// 暴露同步控制函数
window.forceSync = () => window.enhancedSync.forcSync();
window.getSyncStatus = () => window.enhancedSync.getSyncStatus();