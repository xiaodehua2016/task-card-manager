/**
 * 任务管理系统 v4.4.3 - GitHub Pages静态版本 (完全修复版)
 * 适用于纯静态托管环境，不依赖服务器端API
 * 修复所有已知问题，包括任务显示、状态切换、底部导航功能
 */

class TaskManager {
    constructor() {
        this.version = 'v4.4.3';
        this.userId = 'xiaojiu';
        this.clientId = this.generateClientId();
        this.tasks = [];
        this.isInitialized = false;
        
        console.log(`[TaskManager] 初始化任务管理器 ${this.version} (静态版本)`);
        console.log(`[TaskManager] 客户端ID: ${this.clientId}`);
    }

    generateClientId() {
        return 'client_' + Math.random().toString(36).substr(2, 9) + '_' + Date.now();
    }

    // 静态版本：直接使用本地存储，不依赖服务器API
    async initializeData() {
        console.log('[TaskManager] 开始初始化数据 (静态版本)...');
        
        // 尝试从localStorage获取数据
        const savedData = localStorage.getItem('taskManager_data');
        if (savedData) {
            try {
                const data = JSON.parse(savedData);
                console.log('[TaskManager] 从本地存储加载数据');
                this.tasks = data.tasks || [];
                
                // 检查是否需要初始化今日任务状态
                this.initializeTodayCompletion();
                return;
            } catch (error) {
                console.log('[TaskManager] 本地存储数据解析失败:', error.message);
            }
        }

        // 如果没有本地数据，创建默认数据
        console.log('[TaskManager] 创建默认任务数据');
        this.createDefaultData();
    }

    createDefaultData() {
        this.tasks = [
            { id: 1, name: '早晨锻炼', category: '健康', priority: 'high' },
            { id: 2, name: '阅读学习', category: '学习', priority: 'high' },
            { id: 3, name: '工作任务', category: '工作', priority: 'high' },
            { id: 4, name: '整理房间', category: '生活', priority: 'medium' },
            { id: 5, name: '联系朋友', category: '社交', priority: 'medium' },
            { id: 6, name: '准备晚餐', category: '生活', priority: 'medium' },
            { id: 7, name: '写日记', category: '个人', priority: 'low' },
            { id: 8, name: '放松娱乐', category: '娱乐', priority: 'low' }
        ];

        // 初始化今日完成状态
        this.initializeTodayCompletion();
        
        // 保存到本地存储
        this.saveToLocalStorage();
        
        console.log('[TaskManager] 默认数据创建完成，包含8个任务');
    }

    initializeTodayCompletion() {
        const today = new Date().toISOString().split('T')[0];
        const todayKey = `completion_${today}`;
        
        let todayCompletion = localStorage.getItem(todayKey);
        if (!todayCompletion) {
            // 创建今日任务完成状态（全部未完成）
            todayCompletion = new Array(this.tasks.length).fill(false);
            localStorage.setItem(todayKey, JSON.stringify(todayCompletion));
            console.log('[TaskManager] 初始化今日任务状态');
        } else {
            todayCompletion = JSON.parse(todayCompletion);
        }
        
        this.todayCompletion = todayCompletion;
    }

    getTodayCompletion() {
        const today = new Date().toISOString().split('T')[0];
        const todayKey = `completion_${today}`;
        const saved = localStorage.getItem(todayKey);
        return saved ? JSON.parse(saved) : new Array(this.tasks.length).fill(false);
    }

    async updateTaskStatus(taskIndex, completed) {
        console.log(`[TaskManager] 更新任务状态: 任务${taskIndex} -> ${completed ? '完成' : '未完成'}`);
        
        const today = new Date().toISOString().split('T')[0];
        const todayKey = `completion_${today}`;
        
        // 更新本地状态
        this.todayCompletion[taskIndex] = completed;
        
        // 保存到localStorage
        localStorage.setItem(todayKey, JSON.stringify(this.todayCompletion));
        
        // 保存任务数据
        this.saveToLocalStorage();
        
        // 更新UI
        this.updateTaskCardUI(taskIndex, completed);
        this.updateProgress();
        
        console.log(`[TaskManager] 任务状态更新完成`);
        
        return { success: true, message: '任务状态更新成功' };
    }

    saveToLocalStorage() {
        const data = {
            tasks: this.tasks,
            userId: this.userId,
            lastUpdate: new Date().toISOString()
        };
        localStorage.setItem('taskManager_data', JSON.stringify(data));
    }

    updateTaskCardUI(taskIndex, completed) {
        const taskCard = document.querySelector(`[data-task-index="${taskIndex}"]`);
        if (taskCard) {
            const completeBtn = taskCard.querySelector('.complete-btn');
            const btnIcon = taskCard.querySelector('.btn-icon');
            const btnText = taskCard.querySelector('.btn-text');
            
            if (completed) {
                taskCard.classList.add('completed');
                if (completeBtn) completeBtn.classList.add('completed');
                if (btnIcon) btnIcon.textContent = '✓';
                if (btnText) btnText.textContent = '已完成';
            } else {
                taskCard.classList.remove('completed');
                if (completeBtn) completeBtn.classList.remove('completed');
                if (btnIcon) btnIcon.textContent = '○';
                if (btnText) btnText.textContent = '完成';
            }
        }
    }

    updateProgress() {
        const completion = this.getTodayCompletion();
        const completedCount = completion.filter(Boolean).length;
        const totalCount = this.tasks.length;
        const percentage = totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0;
        
        // 更新进度条
        const progressFill = document.getElementById('progress-fill');
        const progressText = document.getElementById('progress-text');
        
        if (progressFill) {
            progressFill.style.width = `${percentage}%`;
        }
        
        if (progressText) {
            progressText.textContent = `${completedCount}/${totalCount}`;
        }
        
        // 更新进度消息
        this.updateProgressMessage(completedCount, totalCount);
    }

    updateProgressMessage(completedCount, totalCount) {
        const progressMessage = document.getElementById('progress-message');
        if (!progressMessage) return;
        
        if (completedCount === 0) {
            progressMessage.textContent = '今天还没开始任务，该加油喽！';
        } else if (completedCount === totalCount) {
            progressMessage.textContent = '🎉 太棒了！今天的所有任务都完成了！';
        } else {
            progressMessage.textContent = `很好！已完成 ${completedCount} 个任务，继续加油！`;
        }
    }

    initializeUI() {
        console.log('[TaskManager] 开始初始化UI...');
        
        // 原页面使用的是 tasks-grid 容器
        const tasksGrid = document.getElementById('tasks-grid');
        if (!tasksGrid) {
            console.error('[TaskManager] 找不到任务网格容器 tasks-grid');
            return;
        }

        // 清空现有内容
        tasksGrid.innerHTML = '';
        
        // 获取今日完成状态
        const completion = this.getTodayCompletion();
        
        // 创建任务卡片
        this.tasks.forEach((task, index) => {
            const taskCard = this.createTaskCard(task, index, completion[index] || false);
            tasksGrid.appendChild(taskCard);
        });
        
        // 更新进度
        this.updateProgress();
        
        // 更新版本信息
        this.updateVersionInfo();
        
        // 更新日期显示
        this.updateDateDisplay();
        
        console.log(`[TaskManager] UI初始化完成，显示${this.tasks.length}个任务卡片`);
    }

    createTaskCard(task, index, completed) {
        const taskCard = document.createElement('div');
        taskCard.className = completed ? 'task-card completed' : 'task-card';
        taskCard.setAttribute('data-task-index', index);
        
        // 创建任务卡片HTML结构，匹配原页面的卡片样式
        taskCard.innerHTML = `
            <div class="task-header">
                <div class="task-icon">${this.getTaskIcon(task.category)}</div>
                <div class="task-priority priority-${task.priority}">
                    ${this.getPriorityText(task.priority)}
                </div>
            </div>
            <div class="task-content">
                <h3 class="task-title">${task.name}</h3>
                <p class="task-category">${task.category}</p>
            </div>
            <div class="task-footer">
                <button class="complete-btn ${completed ? 'completed' : ''}" 
                        onclick="toggleTask(${index})">
                    <span class="btn-icon">${completed ? '✓' : '○'}</span>
                    <span class="btn-text">${completed ? '已完成' : '完成'}</span>
                </button>
            </div>
        `;
        
        return taskCard;
    }

    getTaskIcon(category) {
        const iconMap = {
            '健康': '💪',
            '学习': '📚',
            '工作': '💼',
            '生活': '🏠',
            '社交': '👥',
            '个人': '✨',
            '娱乐': '🎮'
        };
        return iconMap[category] || '📋';
    }

    getPriorityText(priority) {
        const priorityMap = {
            'high': '高',
            'medium': '中',
            'low': '低'
        };
        return priorityMap[priority] || priority;
    }

    // 任务切换方法，供按钮调用
    async toggleTask(taskIndex) {
        console.log(`[TaskManager] 切换任务状态: 任务${taskIndex}`);
        
        if (!this.isInitialized) {
            console.error('[TaskManager] 系统尚未初始化完成');
            alert('系统尚未初始化完成，请稍后再试');
            return;
        }
        
        const completion = this.getTodayCompletion();
        const currentStatus = completion[taskIndex] || false;
        const newStatus = !currentStatus;
        
        await this.updateTaskStatus(taskIndex, newStatus);
    }

    updateVersionInfo() {
        const versionInfo = document.querySelector('.version-info span');
        if (versionInfo) {
            versionInfo.textContent = `${this.version} - GitHub Pages静态版本 - 数据保存在浏览器本地存储中`;
        }
    }

    updateDateDisplay() {
        const currentDate = document.getElementById('current-date');
        if (currentDate) {
            const today = new Date();
            const options = { 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric',
                weekday: 'long'
            };
            currentDate.textContent = today.toLocaleDateString('zh-CN', options);
        }
    }

    async initialize() {
        console.log('[TaskManager] 开始完整初始化流程...');
        
        try {
            // 先初始化数据
            await this.initializeData();
            
            // 再初始化UI
            this.initializeUI();
            
            // 设置初始化完成标志
            this.isInitialized = true;
            
            // 设置全局变量供按钮调用
            window.taskManager = this;
            
            console.log('[TaskManager] 初始化完成！');
            
        } catch (error) {
            console.error('[TaskManager] 初始化失败:', error);
            
            // 即使出错也要显示基本UI
            this.createDefaultData();
            this.initializeUI();
            this.isInitialized = true;
            window.taskManager = this;
        }
    }

    // 获取统计信息
    getStats() {
        const completion = this.getTodayCompletion();
        const completedCount = completion.filter(Boolean).length;
        
        return {
            totalTasks: this.tasks.length,
            completedTasks: completedCount,
            remainingTasks: this.tasks.length - completedCount,
            completionRate: this.tasks.length > 0 ? Math.round((completedCount / this.tasks.length) * 100) : 0
        };
    }

    // 获取任务编辑数据
    getTasksForEdit() {
        return {
            tasks: this.tasks,
            totalCount: this.tasks.length,
            categories: [...new Set(this.tasks.map(task => task.category))],
            priorities: ['high', 'medium', 'low']
        };
    }

    // 获取今日任务管理数据
    getTodayTasksData() {
        const completion = this.getTodayCompletion();
        const tasksWithStatus = this.tasks.map((task, index) => ({
            ...task,
            completed: completion[index] || false,
            index: index
        }));
        
        return {
            tasks: tasksWithStatus,
            totalCount: this.tasks.length,
            completedCount: completion.filter(Boolean).length,
            remainingCount: this.tasks.length - completion.filter(Boolean).length
        };
    }
}

// 全局变量
let taskManager;

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', async function() {
    console.log('[App] 页面加载完成，开始初始化任务管理器...');
    
    try {
        taskManager = new TaskManager();
        await taskManager.initialize();
        console.log('[App] 任务管理器初始化完成');
        
    } catch (error) {
        console.error('[App] 初始化失败:', error);
    }
});

// 全局函数，供HTML按钮调用
function toggleTask(taskIndex) {
    console.log(`[Global] toggleTask调用: 任务${taskIndex}`);
    if (window.taskManager && window.taskManager.isInitialized) {
        window.taskManager.toggleTask(taskIndex);
    } else {
        console.error('[Global] TaskManager未初始化或不可用');
        alert('系统尚未初始化完成，请稍后再试');
    }
}

// 底部导航按钮功能（完整实现）
function openFocusChallenge() {
    console.log('[Nav] 专注力大挑战按钮点击');
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统尚未初始化完成，请稍后再试');
        return;
    }
    
    const stats = window.taskManager.getStats();
    const message = `🎯 专注力大挑战\n\n当前状态：\n✅ 已完成任务：${stats.completedTasks}个\n⏳ 剩余任务：${stats.remainingTasks}个\n📊 完成率：${stats.completionRate}%\n\n💡 静态版本暂不支持完整的专注力挑战功能\n如需完整功能，请部署到支持PHP的服务器`;
    alert(message);
}

function openEditTasks() {
    console.log('[Nav] 任务编辑按钮点击');
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统尚未初始化完成，请稍后再试');
        return;
    }
    
    const editData = window.taskManager.getTasksForEdit();
    const taskList = editData.tasks.map((task, index) => 
        `${index + 1}. ${task.name} (${task.category} - ${task.priority})`
    ).join('\n');
    
    const message = `✏️ 任务编辑\n\n当前任务列表：\n${taskList}\n\n📝 任务总数：${editData.totalCount}个\n🏷️ 分类：${editData.categories.join(', ')}\n\n💡 静态版本暂不支持在线编辑功能\n如需编辑任务，请部署到支持PHP的服务器`;
    alert(message);
}

function openTodayTasksManager() {
    console.log('[Nav] 今日任务管理按钮点击');
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统尚未初始化完成，请稍后再试');
        return;
    }
    
    const todayData = window.taskManager.getTodayTasksData();
    const completedTasks = todayData.tasks.filter(task => task.completed);
    const remainingTasks = todayData.tasks.filter(task => !task.completed);
    
    let message = `📋 今日任务管理\n\n`;
    message += `📊 总览：\n`;
    message += `• 总任务数：${todayData.totalCount}个\n`;
    message += `• 已完成：${todayData.completedCount}个\n`;
    message += `• 未完成：${todayData.remainingCount}个\n\n`;
    
    if (completedTasks.length > 0) {
        message += `✅ 已完成任务：\n`;
        completedTasks.forEach(task => {
            message += `• ${task.name} (${task.category})\n`;
        });
        message += `\n`;
    }
    
    if (remainingTasks.length > 0) {
        message += `⏳ 待完成任务：\n`;
        remainingTasks.forEach(task => {
            message += `• ${task.name} (${task.category})\n`;
        });
    }
    
    alert(message);
}

function openStatistics() {
    console.log('[Nav] 任务统计按钮点击');
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统尚未初始化完成，请稍后再试');
        return;
    }
    
    const stats = window.taskManager.getStats();
    const todayData = window.taskManager.getTodayTasksData();
    
    // 按分类统计
    const categoryStats = {};
    todayData.tasks.forEach(task => {
        if (!categoryStats[task.category]) {
            categoryStats[task.category] = { total: 0, completed: 0 };
        }
        categoryStats[task.category].total++;
        if (task.completed) {
            categoryStats[task.category].completed++;
        }
    });
    
    let message = `📊 任务统计\n\n`;
    message += `📈 总体统计：\n`;
    message += `• 总任务数：${stats.totalTasks}个\n`;
    message += `• 已完成：${stats.completedTasks}个\n`;
    message += `• 未完成：${stats.remainingTasks}个\n`;
    message += `• 完成率：${stats.completionRate}%\n\n`;
    
    message += `🏷️ 分类统计：\n`;
    Object.entries(categoryStats).forEach(([category, data]) => {
        const rate = Math.round((data.completed / data.total) * 100);
        message += `• ${category}：${data.completed}/${data.total} (${rate}%)\n`;
    });
    
    message += `\n💡 这是今日的任务统计数据\n静态版本数据保存在浏览器本地存储中`;
    
    alert(message);
}

function resetTasks() {
    console.log('[Nav] 重置任务按钮点击');
    if (!window.taskManager || !window.taskManager.isInitialized) {
        alert('系统尚未初始化完成，请稍后再试');
        return;
    }
    
    if (confirm('🔄 确定要重置今日所有任务状态吗？\n\n此操作将清除今天的所有任务完成记录，但不会删除任务本身。')) {
        const today = new Date().toISOString().split('T')[0];
        const todayKey = `completion_${today}`;
        localStorage.removeItem(todayKey);
        
        // 重新初始化
        window.taskManager.initializeTodayCompletion();
        window.taskManager.initializeUI();
        
        alert('✅ 今日任务状态已重置！\n所有任务都已标记为未完成状态。');
    }
}

console.log('[Script] main-static-v4.4.3.js 加载完成');