// 数据存储管理模块
class TaskStorage {
    constructor() {
        this.storageKey = 'taskManagerData';
        this.syncCallbacks = new Set();
        this.cloudSyncEnabled = false;
        this.syncInProgress = false;
        this.initializeData();
        this.setupStorageSync();
        this.setupCloudSync();
    }

    // 设置云端同步
    // 设置云端同步（单用户系统）
    async setupCloudSync() {
        try {
            // 等待Supabase配置初始化
            if (window.supabaseConfig) {
                const initResult = await window.supabaseConfig.init();
                this.cloudSyncEnabled = initResult && window.supabaseConfig.isConfigured;
                
                if (this.cloudSyncEnabled) {
                    // 确保使用单用户系统
                    const user = await window.supabaseConfig.checkUser();
                    if (user) {
                        this.currentUserId = user.id;
                        console.log('✅ 单用户系统已启用，用户ID:', this.currentUserId);
                        
                        // 订阅实时数据变化
                        window.supabaseConfig.subscribeToChanges((payload) => {
                            this.handleCloudDataChange(payload);
                        });
                        
                        // 启动时同步一次数据
                        setTimeout(() => {
                            this.syncWithCloud();
                        }, 2000);
                        
                        console.log('✅ 云端同步已启用（单用户模式）');
                    } else {
                        console.warn('用户初始化失败，禁用云端同步');
                        this.cloudSyncEnabled = false;
                    }
                } else {
                    console.log('Supabase未配置，仅使用本地存储');
                }
            }
        } catch (error) {
            console.error('云端同步设置失败:', error);
            this.cloudSyncEnabled = false;
        }
    }

    // 处理云端数据变化
    // 处理云端数据变化
    handleCloudDataChange(cloudData) {
        if (!cloudData) return;
        
        const localData = this.getData();
        
        // 避免循环同步 - 检查是否是自己的更新
        if (cloudData.lastModifiedBy === this.getClientId()) {
            console.log('跳过自己的更新');
            return;
        }
        
        // 避免循环同步 - 检查时间戳
        if (cloudData.lastUpdateTime > (localData.lastUpdateTime || 0)) {
            console.log('🔄 检测到云端数据更新，正在同步到本地...');
            this.mergeCloudData(cloudData);
            
            // 显示同步通知
            this.showSyncNotification('数据已从其他设备同步');
            
            // 刷新页面显示
            this.refreshPageDisplay();
        }
    }

    // 与云端同步数据
    async syncWithCloud() {
        if (!this.cloudSyncEnabled || this.syncInProgress) {
            return;
        }

        this.syncInProgress = true;
        
        try {
            const localData = this.getData();
            const cloudData = await window.supabaseConfig.downloadData();
            
            if (!cloudData) {
                // 云端没有数据，上传本地数据
                await window.supabaseConfig.uploadData(localData);
                console.log('本地数据已上传到云端');
            } else if (cloudData.lastUpdateTime > (localData.lastUpdateTime || 0)) {
                // 云端数据更新，下载到本地
                this.mergeCloudData(cloudData);
                console.log('云端数据已同步到本地');
            } else if ((localData.lastUpdateTime || 0) > cloudData.lastUpdateTime) {
                // 本地数据更新，上传到云端
                await window.supabaseConfig.uploadData(localData);
                console.log('本地数据已上传到云端');
            }
            
            this.showSyncStatus('success', '数据同步成功');
        } catch (error) {
            console.error('云端同步失败:', error);
            this.showSyncStatus('error', '同步失败: ' + error.message);
        } finally {
            this.syncInProgress = false;
        }
    }

    // 合并云端数据到本地
    mergeCloudData(cloudData) {
        const localData = this.getData();
        
        // 智能合并数据
        const mergedData = {
            ...localData,
            ...cloudData,
            // 合并历史记录
            completionHistory: {
                ...localData.completionHistory,
                ...cloudData.completionHistory
            },
            // 合并任务时间记录
            taskTimes: {
                ...localData.taskTimes,
                ...cloudData.taskTimes
            },
            // 合并专注记录
            focusRecords: {
                ...localData.focusRecords,
                ...cloudData.focusRecords
            }
        };
        
        // 保存合并后的数据（不触发云端同步）
        this.saveDataLocal(mergedData);
        
        // 通知界面更新
        this.notifySyncCallbacks();
    }

    // 显示同步状态
    // 显示同步状态
    showSyncStatus(type, message) {
        const event = new CustomEvent('syncStatusUpdate', {
            detail: { type, message }
        });
        window.dispatchEvent(event);
    }

    // 显示同步通知
    showSyncNotification(message) {
        // 创建或更新通知元素
        let notification = document.getElementById('sync-notification');
        if (!notification) {
            notification = document.createElement('div');
            notification.id = 'sync-notification';
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: #4CAF50;
                color: white;
                padding: 12px 20px;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                z-index: 10000;
                font-size: 14px;
                transform: translateX(100%);
                transition: transform 0.3s ease;
            `;
            document.body.appendChild(notification);
        }

        notification.textContent = message;
        notification.style.transform = 'translateX(0)';

        // 3秒后隐藏
        setTimeout(() => {
            notification.style.transform = 'translateX(100%)';
        }, 3000);
    }

    // 刷新页面显示
    refreshPageDisplay() {
        // 触发页面刷新事件
        window.dispatchEvent(new CustomEvent('dataRefreshRequired'));
        
        // 如果存在全局刷新函数，调用它
        if (typeof window.refreshDisplay === 'function') {
            window.refreshDisplay();
        }
        
        // 如果存在主页面刷新函数，调用它
        if (typeof window.refreshMainPage === 'function') {
            window.refreshMainPage();
        }
        
        // 通知所有同步回调
        this.notifySyncCallbacks();
    }

    // 设置存储同步监听
    setupStorageSync() {
        // 监听storage事件，实现多标签页同步
        window.addEventListener('storage', (e) => {
            if (e.key === this.storageKey && e.newValue !== e.oldValue) {
                console.log('检测到其他标签页数据更新，正在同步...');
                this.notifySyncCallbacks();
            }
        });

        // 监听页面可见性变化，当页面重新可见时检查数据更新
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden) {
                this.checkForUpdates();
            }
        });

        // 定期检查数据更新（每30秒）
        setInterval(() => {
            this.checkForUpdates();
        }, 30000);
    }

    // 注册同步回调
    onSync(callback) {
        this.syncCallbacks.add(callback);
    }

    // 移除同步回调
    offSync(callback) {
        this.syncCallbacks.delete(callback);
    }

    // 通知所有同步回调
    notifySyncCallbacks() {
        this.syncCallbacks.forEach(callback => {
            try {
                callback();
            } catch (error) {
                console.error('同步回调执行失败:', error);
            }
        });
    }

    // 检查数据更新
    checkForUpdates() {
        const currentData = this.getData();
        const lastUpdateTime = currentData.lastUpdateTime || 0;
        const localLastUpdateTime = this.lastKnownUpdateTime || 0;

        if (lastUpdateTime > localLastUpdateTime) {
            console.log('发现数据更新，正在同步...');
            this.lastKnownUpdateTime = lastUpdateTime;
            this.notifySyncCallbacks();
        }
    }

    // 初始化数据
    initializeData() {
        const data = this.getData();
        if (!data.username) {
            data.username = '小久';
        }
        
        // 初始化任务模板
        if (!data.taskTemplates) {
            data.taskTemplates = {
                daily: [
                    { name: '学而思数感小超市', type: 'daily' },
                    { name: '斑马思维', type: 'daily' },
                    { name: '核桃编程（学生端）', type: 'daily' },
                    { name: '英语阅读', type: 'daily' },
                    { name: '硬笔写字（30分钟）', type: 'daily' },
                    { name: '悦乐达打卡/作业', type: 'daily' },
                    { name: '暑假生活作业', type: 'daily' },
                    { name: '体育/运动（迪卡侬）', type: 'daily' }
                ]
            };
        }
        
        // 初始化今日任务（如果不存在）
        if (!data.dailyTasks) {
            data.dailyTasks = {};
        }
        
        // 初始化一次性任务
        if (!data.oneTimeTasks) {
            data.oneTimeTasks = [];
        }
        
        // 初始化例行任务
        if (!data.routineTasks) {
            data.routineTasks = [];
        }
        
        // 兼容旧版本数据
        if (!data.tasks || data.tasks.length === 0) {
            data.tasks = data.taskTemplates.daily.map(task => task.name);
        }
        
        if (!data.completionHistory) {
            data.completionHistory = {};
        }

        // 添加最后更新时间
        if (!data.lastUpdateTime) {
            data.lastUpdateTime = Date.now();
        }
        
        this.saveData(data);
        this.lastKnownUpdateTime = data.lastUpdateTime;
    }

    // 获取所有数据
    getData() {
        try {
            const data = localStorage.getItem(this.storageKey);
            return data ? JSON.parse(data) : {};
        } catch (error) {
            console.error('读取数据失败:', error);
            return {};
        }
    }

    // 保存数据（添加时间戳）
    saveData(data) {
        try {
            // 更新时间戳
            data.lastUpdateTime = Date.now();
            data.lastModifiedBy = this.getClientId();
            
            localStorage.setItem(this.storageKey, JSON.stringify(data));
            this.lastKnownUpdateTime = data.lastUpdateTime;
            
            // 触发自定义事件，通知当前页面的其他组件
            window.dispatchEvent(new CustomEvent('taskDataUpdated', {
                detail: { timestamp: data.lastUpdateTime }
            }));
            
            // 如果启用了云端同步，上传到云端
            if (this.cloudSyncEnabled && !this.syncInProgress) {
                this.uploadToCloud(data);
            }
            
            return true;
        } catch (error) {
            console.error('保存数据失败:', error);
            return false;
        }
    }

    // 仅保存到本地（不触发云端同步）
    saveDataLocal(data) {
        try {
            localStorage.setItem(this.storageKey, JSON.stringify(data));
            this.lastKnownUpdateTime = data.lastUpdateTime;
            
            window.dispatchEvent(new CustomEvent('taskDataUpdated', {
                detail: { timestamp: data.lastUpdateTime }
            }));
            
            return true;
        } catch (error) {
            console.error('本地保存数据失败:', error);
            return false;
        }
    }

    // 上传数据到云端
    async uploadToCloud(data) {
        if (!this.cloudSyncEnabled || !window.supabaseConfig?.isConfigured) {
            return;
        }
        
        try {
            const result = await window.supabaseConfig.uploadData(data);
            if (result) {
                console.log('数据已成功上传到云端');
            }
        } catch (error) {
            console.error('上传到云端失败:', error);
            // 显示用户友好的错误提示
            this.showSyncStatus('error', '云端同步失败，数据已保存到本地');
        }
    }

    // 获取客户端ID
    getClientId() {
        if (!this.clientId) {
            this.clientId = 'client_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        }
        return this.clientId;
    }

    // 获取用户名
    getUsername() {
        return this.getData().username || '小久';
    }

    // 设置用户名
    setUsername(username) {
        const data = this.getData();
        data.username = username;
        return this.saveData(data);
    }

    // 获取任务列表
    getTasks() {
        return this.getData().tasks || [];
    }

    // 设置任务列表
    setTasks(tasks) {
        const data = this.getData();
        data.tasks = tasks;
        return this.saveData(data);
    }

    // 获取今日完成状态
    getTodayCompletion() {
        const today = this.getTodayString();
        const data = this.getData();
        const tasks = this.getTasks();
        
        if (!data.completionHistory[today]) {
            data.completionHistory[today] = new Array(tasks.length).fill(false);
            this.saveData(data);
        }
        
        return data.completionHistory[today] || [];
    }

    // 设置今日完成状态
    setTodayCompletion(completionArray) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.completionHistory) {
            data.completionHistory = {};
        }
        
        data.completionHistory[today] = completionArray;
        return this.saveData(data);
    }

    // 切换任务完成状态
    toggleTaskCompletion(taskIndex) {
        const completion = this.getTodayCompletion();
        if (taskIndex >= 0 && taskIndex < completion.length) {
            completion[taskIndex] = !completion[taskIndex];
            return this.setTodayCompletion(completion);
        }
        return false;
    }

    // 重置今日任务
    resetTodayTasks() {
        const tasks = this.getTasks();
        const resetCompletion = new Array(tasks.length).fill(false);
        return this.setTodayCompletion(resetCompletion);
    }

    // 获取历史完成数据
    getHistoryData(days = 30) {
        const data = this.getData();
        const history = data.completionHistory || {};
        const result = [];
        
        for (let i = days - 1; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const dateString = this.formatDate(date);
            
            const dayData = history[dateString] || [];
            const completedCount = dayData.filter(Boolean).length;
            const totalCount = dayData.length || this.getTasks().length;
            
            result.push({
                date: dateString,
                completed: completedCount,
                total: totalCount,
                percentage: totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0
            });
        }
        
        return result;
    }

    // 获取今日日期字符串
    getTodayString() {
        return this.formatDate(new Date());
    }

    // 格式化日期
    formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    // 获取中文日期格式
    getChineseDateString(date = new Date()) {
        const year = date.getFullYear();
        const month = date.getMonth() + 1;
        const day = date.getDate();
        const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
        const weekday = weekdays[date.getDay()];
        
        return `${year}年${month}月${day}日 ${weekday}`;
    }

    // 清除所有数据
    clearAllData() {
        try {
            localStorage.removeItem(this.storageKey);
            this.initializeData();
            return true;
        } catch (error) {
            console.error('清除数据失败:', error);
            return false;
        }
    }

    // 导出数据
    exportData() {
        return JSON.stringify(this.getData(), null, 2);
    }

    // 导入数据
    importData(jsonString) {
        try {
            const data = JSON.parse(jsonString);
            return this.saveData(data);
        } catch (error) {
            console.error('导入数据失败:', error);
            return false;
        }
    }

    // 获取任务时间记录
    getTaskTime(taskIndex) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.taskTimes) {
            data.taskTimes = {};
        }
        
        if (!data.taskTimes[today]) {
            data.taskTimes[today] = {};
        }
        
        return data.taskTimes[today][taskIndex] || 0;
    }

    // 设置任务时间记录（累计模式）
    setTaskTime(taskIndex, seconds) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.taskTimes) {
            data.taskTimes = {};
        }
        
        if (!data.taskTimes[today]) {
            data.taskTimes[today] = {};
        }
        
        data.taskTimes[today][taskIndex] = seconds;
        return this.saveData(data);
    }

    // 累加任务时间记录
    addTaskTime(taskIndex, seconds) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.taskTimes) {
            data.taskTimes = {};
        }
        
        if (!data.taskTimes[today]) {
            data.taskTimes[today] = {};
        }
        
        // 累加时间
        const currentTime = data.taskTimes[today][taskIndex] || 0;
        data.taskTimes[today][taskIndex] = currentTime + seconds;
        
        return this.saveData(data);
    }

    // 获取任务的所有执行记录
    getTaskExecutionRecords(taskIndex) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.taskExecutions) {
            data.taskExecutions = {};
        }
        
        if (!data.taskExecutions[today]) {
            data.taskExecutions[today] = {};
        }
        
        if (!data.taskExecutions[today][taskIndex]) {
            data.taskExecutions[today][taskIndex] = [];
        }
        
        return data.taskExecutions[today][taskIndex];
    }

    // 添加任务执行记录
    addTaskExecutionRecord(taskIndex, duration, startTime, endTime) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.taskExecutions) {
            data.taskExecutions = {};
        }
        
        if (!data.taskExecutions[today]) {
            data.taskExecutions[today] = {};
        }
        
        if (!data.taskExecutions[today][taskIndex]) {
            data.taskExecutions[today][taskIndex] = [];
        }
        
        const record = {
            duration: duration,
            startTime: startTime,
            endTime: endTime,
            timestamp: Date.now()
        };
        
        data.taskExecutions[today][taskIndex].push(record);
        
        // 同时累加总时间
        this.addTaskTime(taskIndex, duration);
        
        return this.saveData(data);
    }

    // 获取今日所有任务时间统计
    getTodayTaskTimes() {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.taskTimes || !data.taskTimes[today]) {
            return {};
        }
        
        return data.taskTimes[today];
    }

    // 获取任务时间历史记录
    getTaskTimeHistory(days = 7) {
        const data = this.getData();
        const taskTimes = data.taskTimes || {};
        const result = [];
        
        for (let i = days - 1; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const dateString = this.formatDate(date);
            
            const dayTimes = taskTimes[dateString] || {};
            const totalTime = Object.values(dayTimes).reduce((sum, time) => sum + time, 0);
            
            result.push({
                date: dateString,
                times: dayTimes,
                totalTime: totalTime
            });
        }
        
        return result;
    }

    // 获取今日任务列表（包含所有类型的任务）
    getTodayTasks() {
        const today = this.getTodayString();
        const data = this.getData();
        
        // 如果今日任务已存在，直接返回
        if (data.dailyTasks && data.dailyTasks[today]) {
            return data.dailyTasks[today];
        }
        
        // 否则基于模板创建今日任务
        const dailyTemplate = data.taskTemplates?.daily || [];
        const todayTasks = dailyTemplate.map((task, index) => ({
            ...task,
            id: this.generateTaskId(),
            enabled: true,
            originalIndex: index // 保持原始顺序
        }));
        
        // 添加一次性任务（今日到期的）
        const oneTimeTasks = this.getTodayOneTimeTasks();
        todayTasks.push(...oneTimeTasks);
        
        // 添加例行任务（今日应执行的）
        const routineTasks = this.getTodayRoutineTasks();
        todayTasks.push(...routineTasks);
        
        // 保存今日任务
        this.setTodayTasks(todayTasks);
        
        return todayTasks;
    }
    
    // 设置今日任务列表
    setTodayTasks(tasks) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.dailyTasks) {
            data.dailyTasks = {};
        }
        
        data.dailyTasks[today] = tasks;
        
        // 同时更新兼容性的tasks数组
        data.tasks = tasks.filter(task => task.enabled).map(task => task.name);
        
        return this.saveData(data);
    }
    
    // 获取今日的一次性任务
    getTodayOneTimeTasks() {
        const today = this.getTodayString();
        const data = this.getData();
        const oneTimeTasks = data.oneTimeTasks || [];
        
        return oneTimeTasks.filter(task => 
            task.dueDate === today && !task.completed
        ).map(task => ({
            ...task,
            type: 'oneTime',
            enabled: true
        }));
    }
    
    // 获取今日的例行任务
    getTodayRoutineTasks() {
        const today = new Date();
        const data = this.getData();
        const routineTasks = data.routineTasks || [];
        
        return routineTasks.filter(task => {
            return this.shouldExecuteRoutineTask(task, today);
        }).map(task => ({
            ...task,
            type: 'routine',
            enabled: true
        }));
    }
    
    // 判断例行任务是否应在今日执行
    shouldExecuteRoutineTask(task, date) {
        const dayOfWeek = date.getDay(); // 0=周日, 1=周一, ..., 6=周六
        const dayOfMonth = date.getDate();
        
        switch (task.frequency) {
            case 'weekly':
                return task.weekdays && task.weekdays.includes(dayOfWeek);
            case 'monthly':
                return task.monthDays && task.monthDays.includes(dayOfMonth);
            case 'interval':
                // 按间隔天数执行
                const startDate = new Date(task.startDate);
                const diffDays = Math.floor((date - startDate) / (1000 * 60 * 60 * 24));
                return diffDays >= 0 && diffDays % task.intervalDays === 0;
            default:
                return false;
        }
    }
    
    // 生成任务ID
    generateTaskId() {
        return 'task_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // 添加一次性任务
    addOneTimeTask(name, dueDate, description = '') {
        const data = this.getData();
        if (!data.oneTimeTasks) {
            data.oneTimeTasks = [];
        }
        
        const task = {
            id: this.generateTaskId(),
            name: name,
            description: description,
            dueDate: dueDate,
            completed: false,
            createdAt: new Date().toISOString(),
            type: 'oneTime'
        };
        
        data.oneTimeTasks.push(task);
        this.saveData(data);
        
        // 如果是今日任务，更新今日任务列表
        if (dueDate === this.getTodayString()) {
            this.refreshTodayTasks();
        }
        
        return task;
    }
    
    // 添加例行任务
    addRoutineTask(name, frequency, config, description = '') {
        const data = this.getData();
        if (!data.routineTasks) {
            data.routineTasks = [];
        }
        
        const task = {
            id: this.generateTaskId(),
            name: name,
            description: description,
            frequency: frequency, // 'weekly', 'monthly', 'interval'
            ...config, // weekdays, monthDays, intervalDays, startDate等
            createdAt: new Date().toISOString(),
            type: 'routine'
        };
        
        data.routineTasks.push(task);
        this.saveData(data);
        
        // 刷新今日任务
        this.refreshTodayTasks();
        
        return task;
    }
    
    // 刷新今日任务列表
    refreshTodayTasks() {
        const today = this.getTodayString();
        const data = this.getData();
        
        // 删除今日任务缓存，强制重新生成
        if (data.dailyTasks && data.dailyTasks[today]) {
            delete data.dailyTasks[today];
            this.saveData(data);
        }
        
        // 重新获取今日任务
        return this.getTodayTasks();
    }
    
    // 切换今日任务的启用状态
    toggleTodayTaskEnabled(taskId) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.dailyTasks || !data.dailyTasks[today]) {
            return false;
        }
        
        const tasks = data.dailyTasks[today];
        const taskIndex = tasks.findIndex(task => task.id === taskId);
        
        if (taskIndex !== -1) {
            tasks[taskIndex].enabled = !tasks[taskIndex].enabled;
            this.setTodayTasks(tasks);
            return true;
        }
        
        return false;
    }
    
    // 删除今日任务（仅对当天有效）
    removeTodayTask(taskId) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.dailyTasks || !data.dailyTasks[today]) {
            return false;
        }
        
        const tasks = data.dailyTasks[today];
        const filteredTasks = tasks.filter(task => task.id !== taskId);
        
        if (filteredTasks.length !== tasks.length) {
            this.setTodayTasks(filteredTasks);
            return true;
        }
        
        return false;
    }
    
    // 获取任务模板
    getTaskTemplates() {
        const data = this.getData();
        return data.taskTemplates || { daily: [] };
    }
    
    // 更新每日任务模板
    updateDailyTemplate(tasks) {
        const data = this.getData();
        if (!data.taskTemplates) {
            data.taskTemplates = {};
        }
        
        data.taskTemplates.daily = tasks.map(task => ({
            name: typeof task === 'string' ? task : task.name,
            type: 'daily'
        }));
        
        return this.saveData(data);
    }
    
    // 获取所有一次性任务
    getAllOneTimeTasks() {
        const data = this.getData();
        return data.oneTimeTasks || [];
    }
    
    // 获取所有例行任务
    getAllRoutineTasks() {
        const data = this.getData();
        return data.routineTasks || [];
    }
    
    // 删除一次性任务
    deleteOneTimeTask(taskId) {
        const data = this.getData();
        if (!data.oneTimeTasks) {
            return false;
        }
        
        const originalLength = data.oneTimeTasks.length;
        data.oneTimeTasks = data.oneTimeTasks.filter(task => task.id !== taskId);
        
        if (data.oneTimeTasks.length !== originalLength) {
            this.saveData(data);
            this.refreshTodayTasks();
            return true;
        }
        
        return false;
    }
    
    // 删除例行任务
    deleteRoutineTask(taskId) {
        const data = this.getData();
        if (!data.routineTasks) {
            return false;
        }
        
        const originalLength = data.routineTasks.length;
        data.routineTasks = data.routineTasks.filter(task => task.id !== taskId);
        
        if (data.routineTasks.length !== originalLength) {
            this.saveData(data);
            this.refreshTodayTasks();
            return true;
        }
        
        return false;
    }
}

// 创建全局存储实例
window.taskStorage = new TaskStorage();