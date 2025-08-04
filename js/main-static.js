/**
 * 任务管理系统 v4.4.2 - GitHub Pages静态版本
 * 适用于纯静态托管环境，不依赖服务器端API
 */

class TaskManager {
    constructor() {
        this.version = 'v4.4.2';
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
        this.updateTaskUI(taskIndex, completed);
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

    updateTaskUI(taskIndex, completed) {
        const taskElement = document.querySelector(`[data-task-index="${taskIndex}"]`);
        if (taskElement) {
            const checkbox = taskElement.querySelector('.task-checkbox');
            const taskContent = taskElement.querySelector('.task-content');
            
            if (checkbox) {
                checkbox.checked = completed;
            }
            
            if (taskContent) {
                if (completed) {
                    taskContent.classList.add('completed');
                } else {
                    taskContent.classList.remove('completed');
                }
            }
        }
    }

    updateProgress() {
        const completion = this.getTodayCompletion();
        const completedCount = completion.filter(Boolean).length;
        const totalCount = this.tasks.length;
        const percentage = totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0;
        
        // 更新进度条
        const progressBar = document.querySelector('.progress-bar');
        const progressText = document.querySelector('.progress-text');
        
        if (progressBar) {
            progressBar.style.width = `${percentage}%`;
        }
        
        if (progressText) {
            progressText.textContent = `${completedCount}/${totalCount} (${percentage}%)`;
        }
        
        // 更新祝贺信息
        this.updateCongratulations(completedCount, totalCount);
    }

    updateCongratulations(completedCount, totalCount) {
        const congratsElement = document.querySelector('.congratulations');
        if (!congratsElement) return;
        
        if (completedCount === 0) {
            congratsElement.textContent = '今天还没开始任务，该加油了！';
            congratsElement.className = 'congratulations start';
        } else if (completedCount === totalCount) {
            congratsElement.textContent = '🎉 恭喜！今天的所有任务都完成了！';
            congratsElement.className = 'congratulations complete';
        } else {
            congratsElement.textContent = `很好！已完成 ${completedCount} 个任务，继续加油！`;
            congratsElement.className = 'congratulations progress';
        }
    }

    initializeUI() {
        console.log('[TaskManager] 开始初始化UI...');
        
        const taskList = document.getElementById('task-list');
        if (!taskList) {
            console.error('[TaskManager] 找不到任务列表容器');
            return;
        }

        // 清空现有内容
        taskList.innerHTML = '';
        
        // 获取今日完成状态
        const completion = this.getTodayCompletion();
        
        // 创建任务项
        this.tasks.forEach((task, index) => {
            const taskItem = this.createTaskElement(task, index, completion[index] || false);
            taskList.appendChild(taskItem);
        });
        
        // 更新进度
        this.updateProgress();
        
        // 更新版本信息
        this.updateVersionInfo();
        
        console.log(`[TaskManager] UI初始化完成，显示${this.tasks.length}个任务`);
    }

    createTaskElement(task, index, completed) {
        const taskItem = document.createElement('div');
        taskItem.className = 'task-item';
        taskItem.setAttribute('data-task-index', index);
        
        taskItem.innerHTML = `
            <div class="task-content ${completed ? 'completed' : ''}">
                <input type="checkbox" class="task-checkbox" ${completed ? 'checked' : ''}>
                <span class="task-name">${task.name}</span>
                <span class="task-category">${task.category}</span>
                <span class="task-priority priority-${task.priority}">${this.getPriorityText(task.priority)}</span>
            </div>
        `;
        
        // 添加点击事件
        const checkbox = taskItem.querySelector('.task-checkbox');
        checkbox.addEventListener('change', async (e) => {
            const isCompleted = e.target.checked;
            await this.updateTaskStatus(index, isCompleted);
        });
        
        return taskItem;
    }

    getPriorityText(priority) {
        const priorityMap = {
            'high': '高',
            'medium': '中',
            'low': '低'
        };
        return priorityMap[priority] || priority;
    }

    updateVersionInfo() {
        const versionElement = document.querySelector('.version-info');
        if (versionElement) {
            versionElement.textContent = `${this.version} - GitHub Pages静态版本`;
        }
    }

    async initialize() {
        console.log('[TaskManager] 开始完整初始化流程...');
        
        try {
            // 先初始化数据
            await this.initializeData();
            
            // 再初始化UI
            this.initializeUI();
            
            this.isInitialized = true;
            console.log('[TaskManager] 初始化完成！');
            
        } catch (error) {
            console.error('[TaskManager] 初始化失败:', error);
            
            // 即使出错也要显示基本UI
            this.createDefaultData();
            this.initializeUI();
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
}

// 全局变量
let taskManager;

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', async function() {
    console.log('[App] 页面加载完成，开始初始化任务管理器...');
    
    try {
        taskManager = new TaskManager();
        window.taskManager = taskManager; // 供调试使用
        
        await taskManager.initialize();
        
        console.log('[App] 任务管理器初始化完成');
        
    } catch (error) {
        console.error('[App] 初始化失败:', error);
    }
});