/**
 * 跨浏览器数据同步解决方案 v4.2.3
 * 通过服务器端文件实现数据共享
 * 修复了多设备同步问题
 */

class CrossBrowserSync {
    constructor() {
        this.syncEndpoint = '/api/data-sync';
        this.syncInterval = 3000; // 3秒同步一次，提高同步频率
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
            },
            cache: 'no-cache' // 禁用缓存，确保获取最新数据
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
        
        return Math.abs(localTime - serverTime) > 500; // 0.5秒差异就同步，提高敏感度
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

// 增强版本：基于API的数据共享
class SimpleFileSync {
    constructor() {
        this.syncEndpoint = '/api/data-sync.php';
        this.checkInterval = 2000; // 2秒检查一次，提高同步频率
        this.lastCheckTime = 0;
        this.isChecking = false;
        this.retryCount = 0;
        this.maxRetries = 5; // 增加重试次数
        this.storageKey = 'taskManagerData';
        this.version = '4.2.3'; // 更新版本号
        
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
        }, 500); // 更快地进行初始同步
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
                    } else {
                        // 即使不需要更新，也确保本地数据有最新的时间戳
                        this.updateTimestamp(localData);
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
    
    // 更新时间戳
    updateTimestamp(data) {
        if (!data) return;
        
        try {
            data.lastUpdateTime = Date.now();
            localStorage.setItem(this.storageKey, JSON.stringify(data));
        } catch (error) {
            console.error('更新时间戳失败:', error);
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
            // 重置重试计数，避免永久阻塞
            setTimeout(() => {
                this.retryCount = 0;
            }, 30000); // 30秒后重置
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
                    try {
                        const parsed = JSON.parse(data);
                        if (parsed && (parsed.tasks || parsed.dailyTasks || parsed.completionHistory)) {
                            // 标准化数据格式
                            return this.normalizeData(parsed, key);
                        }
                    } catch (parseError) {
                        console.warn(`解析 ${key} 数据失败:`, parseError);
                        // 继续尝试其他键
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
            version: this.version, // 使用当前版本号
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

    // 合并数据 - 增强版
    mergeData(localData, serverData) {
        if (!localData) return serverData;
        if (!serverData) return localData;

        const localTime = localData.lastUpdateTime || 0;
        const serverTime = serverData.serverUpdateTime || serverData.lastUpdateTime || 0;

        // 创建合并后的数据对象
        const mergedData = {
            version: this.version,
            lastUpdateTime: Date.now(),
            serverUpdateTime: Date.now(),
            username: localData.username || serverData.username || '小久',
            tasks: [],
            taskTemplates: { daily: [] },
            dailyTasks: {},
            completionHistory: {},
            taskTimes: {},
            focusRecords: {}
        };

        // 如果服务器数据更新，优先使用服务器数据
        if (serverTime > localTime) {
            console.log('🔄 优先使用服务器数据 (更新)');
            Object.assign(mergedData, serverData);
        } 
        // 如果本地数据更新，优先使用本地数据
        else if (localTime > serverTime) {
            console.log('🔄 优先使用本地数据 (更新)');
            Object.assign(mergedData, localData);
        }
        // 时间相同，智能合并数据
        else {
            console.log('🔄 智能合并本地和服务器数据');
            
            // 合并任务列表 - 取并集
            mergedData.tasks = this.mergeArrays(localData.tasks, serverData.tasks);
            
            // 合并任务模板
            mergedData.taskTemplates = this.mergeTaskTemplates(localData.taskTemplates, serverData.taskTemplates);
            
            // 合并每日任务 - 按日期取最新
            mergedData.dailyTasks = this.mergeDailyTasks(localData.dailyTasks, serverData.dailyTasks);
            
            // 合并完成历史 - 按日期取并集
            mergedData.completionHistory = this.mergeCompletionHistory(localData.completionHistory, serverData.completionHistory);
            
            // 合并任务时间 - 取最大值
            mergedData.taskTimes = this.mergeTaskTimes(localData.taskTimes, serverData.taskTimes);
            
            // 合并专注记录 - 按ID取并集
            mergedData.focusRecords = this.mergeFocusRecords(localData.focusRecords, serverData.focusRecords);
        }
        
        return mergedData;
    }
    
    // 合并数组，去重
    mergeArrays(arr1 = [], arr2 = []) {
        const set = new Set([...arr1, ...arr2]);
        return Array.from(set);
    }
    
    // 合并任务模板
    mergeTaskTemplates(templates1 = {}, templates2 = {}) {
        const result = { ...templates1 };
        
        // 合并每种类型的模板
        for (const type in templates2) {
            if (result[type]) {
                result[type] = this.mergeArrays(result[type], templates2[type]);
            } else {
                result[type] = [...templates2[type]];
            }
        }
        
        return result;
    }
    
    // 合并每日任务
    mergeDailyTasks(tasks1 = {}, tasks2 = {}) {
        const result = { ...tasks1 };
        
        // 对每个日期，取最新的任务列表
        for (const date in tasks2) {
            if (!result[date] || 
                (tasks2[date].lastUpdated && (!result[date].lastUpdated || tasks2[date].lastUpdated > result[date].lastUpdated))) {
                result[date] = tasks2[date];
            }
        }
        
        return result;
    }
    
    // 合并完成历史
    mergeCompletionHistory(history1 = {}, history2 = {}) {
        const result = { ...history1 };
        
        // 对每个日期，合并完成状态
        for (const date in history2) {
            if (!result[date]) {
                result[date] = history2[date];
            } else {
                // 如果两边都有，取并集（任何一边标记为完成的都算完成）
                for (let i = 0; i < history2[date].length; i++) {
                    if (i < result[date].length) {
                        result[date][i] = result[date][i] || history2[date][i];
                    } else {
                        result[date].push(history2[date][i]);
                    }
                }
            }
        }
        
        return result;
    }
    
    // 合并任务时间
    mergeTaskTimes(times1 = {}, times2 = {}) {
        const result = { ...times1 };
        
        // 对每个任务，取最大时间
        for (const task in times2) {
            if (!result[task] || times2[task] > result[task]) {
                result[task] = times2[task];
            }
        }
        
        return result;
    }
    
    // 合并专注记录
    mergeFocusRecords(records1 = {}, records2 = {}) {
        const result = { ...records1 };
        
        // 合并所有记录
        for (const id in records2) {
            if (!result[id]) {
                result[id] = records2[id];
            }
        }
        
        return result;
    }

    // 判断是否应该更新
    shouldUpdate(localData, serverData) {
        if (!localData) return !!serverData;
        if (!serverData) return false;
        
        const localTime = localData.lastUpdateTime || 0;
        const serverTime = serverData.lastUpdateTime || 0;
        const serverUpdateTime = serverData.serverUpdateTime || 0;
        
        // 如果服务器时间比本地时间新，或者服务器有serverUpdateTime且比本地新
        return serverTime > localTime || serverUpdateTime > localTime;
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
            data.version = this.version; // 确保版本号正确
            
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
                }, 300); // 更快地响应变化
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
        }, 500); // 更快地响应变化
    }
});

// 页面获得焦点时立即检查同步
window.addEventListener('focus', () => {
    if (window.dataSyncManager) {
        console.log('🔄 页面获得焦点，检查数据同步');
        window.dataSyncManager.checkForUpdates();
    }
});

console.log('跨浏览器数据同步 v4.2.3 已启动');