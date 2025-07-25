/**
 * 简化存储系统 - 纯本地存储
 * 移除所有云端依赖，专注于本地功能
 */
class SimpleTaskStorage {
    constructor() {
        this.storageKey = 'taskManagerData';
        this.syncCallbacks = new Set();
        this.initializeData();
        this.setupStorageSync();
    }

    // 初始化数据
    initializeData() {
        const data = this.getData();
        let needsSave = false;
        
        if (!data.username) {
            data.username = '小久';
            needsSave = true;
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
            needsSave = true;
        }
        
        // 初始化今日任务
        if (!data.dailyTasks) {
            data.dailyTasks = {};
            needsSave = true;
        }
        
        // 初始化一次性任务
        if (!data.oneTimeTasks) {
            data.oneTimeTasks = [];
            needsSave = true;
        }
        
        // 初始化例行任务
        if (!data.routineTasks) {
            data.routineTasks = [];
            needsSave = true;
        }
        
        // 兼容旧版本数据
        if (!data.tasks || data.tasks.length === 0) {
            data.tasks = data.taskTemplates.daily.map(task => task.name);
            needsSave = true;
        }
        
        if (!data.completionHistory) {
            data.completionHistory = {};
            needsSave = true;
        }

        if (!data.taskTimes) {
            data.taskTimes = {};
            needsSave = true;
        }

        if (!data.focusRecords) {
            data.focusRecords = {};
            needsSave = true;
        }

        // 添加最后更新时间
        if (!data.lastUpdateTime) {
            data.lastUpdateTime = Date.now();
            needsSave = true;
        }
        
        if (needsSave) {
            this.saveData(data);
            console.log('📋 初始化数据已保存');
        }
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

        // 监听页面可见性变化
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden) {
                this.checkForUpdates();
            }
        });
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

    // 保存数据
    saveData(data) {
        try {
            data.lastUpdateTime = Date.now();
            localStorage.setItem(this.storageKey, JSON.stringify(data));
            
            // 触发更新事件
            window.dispatchEvent(new CustomEvent('taskDataUpdated', {
                detail: { timestamp: data.lastUpdateTime }
            }));
            
            return true;
        } catch (error) {
            console.error('保存数据失败:', error);
            return false;
        }
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
        // 简单的本地更新检查
        this.notifySyncCallbacks();
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

    // 获取任务时间记录
    getTaskTime(taskIndex) {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (!data.taskTimes[today]) {
            return 0;
        }
        
        return data.taskTimes[today][taskIndex] || 0;
    }

    // 设置任务时间记录
    setTaskTime(taskIndex, seconds) {
        const today = this.getTodayString();
        const data = this.getData();
        
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
        
        if (!data.taskTimes[today]) {
            data.taskTimes[today] = {};
        }
        
        const currentTime = data.taskTimes[today][taskIndex] || 0;
        data.taskTimes[today][taskIndex] = currentTime + seconds;
        
        return this.saveData(data);
    }

    // 获取今日任务列表
    getTodayTasks() {
        const today = this.getTodayString();
        const data = this.getData();
        
        if (data.dailyTasks && data.dailyTasks[today]) {
            return data.dailyTasks[today];
        }
        
        // 基于模板创建今日任务
        const dailyTemplate = data.taskTemplates?.daily || [];
        const todayTasks = dailyTemplate.map((task, index) => ({
            ...task,
            id: this.generateTaskId(),
            enabled: true,
            originalIndex: index
        }));
        
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
        data.tasks = tasks.filter(task => task.enabled).map(task => task.name);
        
        return this.saveData(data);
    }

    // 生成任务ID
    generateTaskId() {
        return 'task_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
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

    // 获取所有数据（用于导出）
    getAllData() {
        return this.getData();
    }

    // 从数据对象加载数据
    loadFromData(data) {
        try {
            localStorage.setItem(this.storageKey, JSON.stringify(data));
            console.log('✅ 数据已加载');
            this.notifySyncCallbacks();
        } catch (error) {
            console.error('加载数据失败:', error);
        }
    }
}

// 创建全局存储实例
window.taskStorage = new SimpleTaskStorage();