// 任务管理系统静态版本 v4.4.4 - 完全恢复原始卡片显示
// 专为GitHub Pages环境设计，完全恢复原始页面显示方式

class TaskManager {
    constructor() {
        this.version = 'v4.4.4';
        this.isInitialized = false;
        this.tasks = [];
        this.currentTaskIndex = -1;
        this.startTime = null;
        this.timerInterval = null;
        
        console.log('[TaskManager] 初始化静态版本', this.version);
        this.initialize();
    }

    // 初始化系统
    async initialize() {
        try {
            console.log('[TaskManager] 开始初始化...');
            
            // 初始化默认任务
            this.initializeDefaultTasks();
            
            // 从本地存储加载数据
            this.loadFromStorage();
            
            // 渲染界面
            this.renderTasks();
            this.updateProgress();
            this.updateGreeting();
            
            // 设置全局变量
            window.taskManager = this;
            this.isInitialized = true;
            
            console.log('[TaskManager] 初始化完成，版本:', this.version);
            console.log('[TaskManager] 任务数量:', this.tasks.length);
            console.log('[TaskManager] 全局变量设置完成');
            
        } catch (error) {
            console.error('[TaskManager] 初始化失败:', error);
            // 即使初始化失败，也要设置基本功能
            window.taskManager = this;
            this.isInitialized = true;
        }
    }

    // 初始化默认任务
    initializeDefaultTasks() {
        this.tasks = [
            {
                id: 1,
                title: '学而思数感小超市',
                completed: false,
                totalTime: 0,
                todayTime: 0,
                category: '数学',
                icon: '🧮'
            },
            {
                id: 2,
                title: '斑马思维',
                completed: false,
                totalTime: 0,
                todayTime: 0,
                category: '思维',
                icon: '🦓'
            },
            {
                id: 3,
                title: '核桃编程',
                completed: false,
                totalTime: 0,
                todayTime: 0,
                category: '编程',
                icon: '💻'
            },
            {
                id: 4,
                title: '英语学习',
                completed: false,
                totalTime: 0,
                todayTime: 0,
                category: '英语',
                icon: '📚'
            },
            {
                id: 5,
                title: '写字练习',
                completed: false,
                totalTime: 0,
                todayTime: 0,
                category: '语文',
                icon: '✏️'
            },
            {
                id: 6,
                title: '悦乐达作业',
                completed: false,
                totalTime: 0,
                todayTime: 0,
                category: '作业',
                icon: '📝'
            },
            {
                id: 7,
                title: '暑假作业',
                completed: false,
                totalTime: 0,
                todayTime: 0,
                category: '作业',
                icon: '📖'
            },
            {
                id: 8,
                title: '体育运动',
                completed: false,
                totalTime: 0,
                todayTime: 0,
                category: '体育',
                icon: '⚽'
            }
        ];
        
        console.log('[TaskManager] 默认任务初始化完成，共', this.tasks.length, '个任务');
    }

    // 渲染任务卡片 - 使用正确的task-card类名
    renderTasks() {
        console.log('[TaskManager] 开始渲染任务卡片');
        const tasksGrid = document.getElementById('tasks-grid');
        if (!tasksGrid) {
            console.error('[TaskManager] 找不到tasks-grid容器');
            return;
        }

        tasksGrid.innerHTML = '';
        
        this.tasks.forEach((task, index) => {
            const taskElement = document.createElement('div');
            taskElement.className = `task-card ${task.completed ? 'completed' : ''}`;
            taskElement.setAttribute('data-task', task.title);
            
            taskElement.innerHTML = `
                <div class="task-icon">${task.completed ? '✅' : task.icon}</div>
                <div class="task-title">${task.title}</div>
                <div class="task-buttons">
                    <button class="task-btn start-btn" onclick="window.taskManager.startTask(${index})">
                        <span class="btn-icon">▶️</span>
                        <span>开始任务</span>
                    </button>
                    <button class="task-btn complete-btn ${task.completed ? 'completed' : ''}" 
                            onclick="window.taskManager.toggleTask(${index})">
                        <span class="btn-icon">${task.completed ? '✅' : '⭕'}</span>
                        <span>${task.completed ? '已完成' : '完成任务'}</span>
                    </button>
                </div>
                <div class="task-time-info ${task.totalTime > 0 ? 'has-time' : ''}">
                    ${task.totalTime > 0 ? `累计用时: ${this.formatTime(task.totalTime)}` : ''}
                </div>
            `;
            
            tasksGrid.appendChild(taskElement);
        });
        
        console.log('[TaskManager] 任务卡片渲染完成，共', this.tasks.length, '个任务');
    }

    // 切换任务状态
    toggleTask(index) {
        console.log('[TaskManager] 切换任务状态，索引:', index);
        
        if (index < 0 || index >= this.tasks.length) {
            console.error('[TaskManager] 无效的任务索引:', index);
            return;
        }

        const task = this.tasks[index];
        task.completed = !task.completed;
        
        console.log('[TaskManager] 任务', task.title, '状态已切换为:', task.completed ? '已完成' : '未完成');
        
        // 保存到本地存储
        this.saveToStorage();
        
        // 重新渲染
        this.renderTasks();
        this.updateProgress();
        this.updateGreeting();
    }

    // 开始任务
    startTask(index) {
        console.log('[TaskManager] 开始任务，索引:', index);
        
        if (index < 0 || index >= this.tasks.length) {
            console.error('[TaskManager] 无效的任务索引:', index);
            return;
        }

        // 停止当前任务
        if (this.currentTaskIndex !== -1) {
            this.stopCurrentTask();
        }

        const task = this.tasks[index];
        this.currentTaskIndex = index;
        this.startTime = Date.now();
        
        // 开始计时
        this.timerInterval = setInterval(() => {
            const elapsed = Date.now() - this.startTime;
            task.todayTime = elapsed;
            this.updateTaskTime(index);
        }, 1000);
        
        console.log('[TaskManager] 任务', task.title, '开始计时');
        alert(`开始任务: ${task.title}`);
    }

    // 停止当前任务
    stopCurrentTask() {
        if (this.currentTaskIndex !== -1 && this.startTime) {
            const elapsed = Date.now() - this.startTime;
            const task = this.tasks[this.currentTaskIndex];
            task.totalTime += elapsed;
            task.todayTime = 0;
            
            console.log('[TaskManager] 任务', task.title, '停止计时，本次用时:', this.formatTime(elapsed));
        }
        
        if (this.timerInterval) {
            clearInterval(this.timerInterval);
            this.timerInterval = null;
        }
        
        this.currentTaskIndex = -1;
        this.startTime = null;
        this.saveToStorage();
    }

    // 更新任务时间显示
    updateTaskTime(index) {
        const task = this.tasks[index];
        const timeInfo = document.querySelector(`[data-task="${task.title}"] .task-time-info`);
        if (timeInfo) {
            const totalTime = task.totalTime + (task.todayTime || 0);
            timeInfo.textContent = `累计用时: ${this.formatTime(totalTime)}`;
            timeInfo.className = 'task-time-info has-time';
        }
    }

    // 格式化时间
    formatTime(milliseconds) {
        const seconds = Math.floor(milliseconds / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        
        if (hours > 0) {
            return `${hours}小时${minutes % 60}分钟`;
        } else if (minutes > 0) {
            return `${minutes}分钟${seconds % 60}秒`;
        } else {
            return `${seconds}秒`;
        }
    }

    // 更新进度条
    updateProgress() {
        const completedTasks = this.tasks.filter(task => task.completed).length;
        const totalTasks = this.tasks.length;
        const percentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
        
        const progressBar = document.querySelector('.progress-bar');
        const progressText = document.querySelector('.progress-text');
        
        if (progressBar) {
            progressBar.style.width = `${percentage}%`;
        }
        
        if (progressText) {
            progressText.textContent = `${completedTasks}/${totalTasks} 已完成`;
        }
        
        console.log('[TaskManager] 进度更新:', `${completedTasks}/${totalTasks} (${percentage.toFixed(1)}%)`);
    }

    // 更新问候语
    updateGreeting() {
        const completedTasks = this.tasks.filter(task => task.completed).length;
        const totalTasks = this.tasks.length;
        
        const greetingElement = document.querySelector('.greeting-text');
        if (greetingElement) {
            if (completedTasks === 0) {
                greetingElement.textContent = '今天还没开始任务，该加油喽！';
            } else if (completedTasks === totalTasks) {
                greetingElement.textContent = '太棒了！今天的所有任务都完成了！🎉';
            } else {
                greetingElement.textContent = `今天已完成 ${completedTasks} 个任务，继续加油！`;
            }
        }
    }

    // 保存到本地存储
    saveToStorage() {
        try {
            const data = {
                tasks: this.tasks,
                version: this.version,
                lastUpdate: new Date().toISOString()
            };
            localStorage.setItem('taskManager', JSON.stringify(data));
            console.log('[TaskManager] 数据已保存到本地存储');
        } catch (error) {
            console.error('[TaskManager] 保存数据失败:', error);
        }
    }

    // 从本地存储加载
    loadFromStorage() {
        try {
            const data = localStorage.getItem('taskManager');
            if (data) {
                const parsed = JSON.parse(data);
                if (parsed.tasks && Array.isArray(parsed.tasks)) {
                    // 合并保存的状态和默认任务
                    parsed.tasks.forEach((savedTask, index) => {
                        if (index < this.tasks.length) {
                            this.tasks[index].completed = savedTask.completed || false;
                            this.tasks[index].totalTime = savedTask.totalTime || 0;
                        }
                    });
                    console.log('[TaskManager] 从本地存储加载数据成功');
                }
            }
        } catch (error) {
            console.error('[TaskManager] 加载数据失败:', error);
        }
    }

    // 重置所有任务
    resetTasks() {
        if (confirm('确定要重置所有任务状态吗？这将清除今天的完成记录。')) {
            this.tasks.forEach(task => {
                task.completed = false;
                task.todayTime = 0;
            });
            
            this.stopCurrentTask();
            this.saveToStorage();
            this.renderTasks();
            this.updateProgress();
            this.updateGreeting();
            
            console.log('[TaskManager] 所有任务已重置');
            alert('所有任务已重置！');
        }
    }

    // 获取统计信息
    getStatistics() {
        const completed = this.tasks.filter(task => task.completed).length;
        const total = this.tasks.length;
        const totalTime = this.tasks.reduce((sum, task) => sum + task.totalTime, 0);
        
        return {
            completed,
            total,
            percentage: total > 0 ? (completed / total) * 100 : 0,
            totalTime,
            tasks: this.tasks.map(task => ({
                title: task.title,
                completed: task.completed,
                totalTime: task.totalTime,
                category: task.category
            }))
        };
    }
}

// 底部导航功能
function openFocusChallenge() {
    console.log('[Navigation] 打开专注力大挑战');
    
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统正在初始化，请稍后再试...');
        return;
    }
    
    const stats = window.taskManager.getStatistics();
    const message = `🎯 专注力大挑战\n\n当前进度: ${stats.completed}/${stats.total} 任务完成\n完成率: ${stats.percentage.toFixed(1)}%\n总用时: ${window.taskManager.formatTime(stats.totalTime)}\n\n继续保持专注，完成更多任务！`;
    
    alert(message);
}

function openEditTasks() {
    console.log('[Navigation] 打开任务编辑');
    
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统正在初始化，请稍后再试...');
        return;
    }
    
    const stats = window.taskManager.getStatistics();
    let message = '✏️ 任务编辑\n\n当前任务列表:\n';
    
    stats.tasks.forEach((task, index) => {
        const status = task.completed ? '✅' : '⭕';
        const time = task.totalTime > 0 ? ` (${window.taskManager.formatTime(task.totalTime)})` : '';
        message += `${index + 1}. ${status} ${task.title}${time}\n`;
    });
    
    message += `\n总计: ${stats.total} 个任务\n已完成: ${stats.completed} 个任务`;
    
    alert(message);
}

function openTodayTasksManager() {
    console.log('[Navigation] 打开今日任务管理');
    
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统正在初始化，请稍后再试...');
        return;
    }
    
    const stats = window.taskManager.getStatistics();
    const completedTasks = stats.tasks.filter(task => task.completed);
    const pendingTasks = stats.tasks.filter(task => !task.completed);
    
    let message = '📋 今日任务管理\n\n';
    
    if (completedTasks.length > 0) {
        message += '✅ 已完成任务:\n';
        completedTasks.forEach((task, index) => {
            const time = task.totalTime > 0 ? ` (${window.taskManager.formatTime(task.totalTime)})` : '';
            message += `${index + 1}. ${task.title}${time}\n`;
        });
        message += '\n';
    }
    
    if (pendingTasks.length > 0) {
        message += '⭕ 待完成任务:\n';
        pendingTasks.forEach((task, index) => {
            message += `${index + 1}. ${task.title}\n`;
        });
        message += '\n';
    }
    
    message += `进度: ${stats.completed}/${stats.total} (${stats.percentage.toFixed(1)}%)`;
    
    alert(message);
}

function openStatistics() {
    console.log('[Navigation] 打开任务统计');
    
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统正在初始化，请稍后再试...');
        return;
    }
    
    const stats = window.taskManager.getStatistics();
    
    // 按分类统计
    const categories = {};
    stats.tasks.forEach(task => {
        if (!categories[task.category]) {
            categories[task.category] = { total: 0, completed: 0, totalTime: 0 };
        }
        categories[task.category].total++;
        if (task.completed) {
            categories[task.category].completed++;
        }
        categories[task.category].totalTime += task.totalTime;
    });
    
    let message = '📊 任务统计\n\n';
    message += `总体进度: ${stats.completed}/${stats.total} (${stats.percentage.toFixed(1)}%)\n`;
    message += `总用时: ${window.taskManager.formatTime(stats.totalTime)}\n\n`;
    
    message += '分类统计:\n';
    Object.entries(categories).forEach(([category, data]) => {
        const percentage = data.total > 0 ? (data.completed / data.total) * 100 : 0;
        const time = data.totalTime > 0 ? ` - ${window.taskManager.formatTime(data.totalTime)}` : '';
        message += `${category}: ${data.completed}/${data.total} (${percentage.toFixed(1)}%)${time}\n`;
    });
    
    alert(message);
}

function resetTasks() {
    console.log('[Navigation] 重置任务');
    
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统正在初始化，请稍后再试...');
        return;
    }
    
    window.taskManager.resetTasks();
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    console.log('[Static] 页面加载完成，初始化TaskManager');
    
    // 显示版本信息
    const versionElement = document.querySelector('.version-info');
    if (versionElement) {
        versionElement.textContent = 'v4.4.4 - GitHub Pages静态版本 - 数据保存在浏览器本地存储中';
    }
    
    // 初始化TaskManager
    new TaskManager();
});

console.log('[Static] 任务管理系统静态版本 v4.4.4 加载完成');