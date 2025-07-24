// 数据存储管理模块
class TaskStorage {
    constructor() {
        this.storageKey = 'taskManagerData';
        this.initializeData();
    }

    // 初始化数据
    initializeData() {
        const data = this.getData();
        if (!data.username) {
            data.username = '小久';
        }
        if (!data.tasks || data.tasks.length === 0) {
            data.tasks = [
                '学而思数感小超市',
                '斑马思维',
                '核桃编程（学生端）',
                '英语阅读',
                '硬笔写字（30分钟）',
                '悦乐达打卡/作业',
                '暑假生活作业',
                '体育/运动（迪卡侬）'
            ];
        }
        if (!data.completionHistory) {
            data.completionHistory = {};
        }
        this.saveData(data);
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
            localStorage.setItem(this.storageKey, JSON.stringify(data));
            return true;
        } catch (error) {
            console.error('保存数据失败:', error);
            return false;
        }
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
}

// 创建全局存储实例
window.taskStorage = new TaskStorage();