/**
 * 纯文件存储版本的任务管理器
 * 移除所有云端依赖，仅使用本地文件存储
 */
class TaskManagerFileOnly {
    constructor() {
        this.fileStorage = new FileStorage();
        this.tasks = [];
        this.completionStatus = [];
        this.currentDate = new Date();
        
        // 等待DOM加载完成后初始化
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.init());
        } else {
            this.init();
        }
    }
    
    async init() {
        try {
            console.log('🚀 初始化纯文件存储任务管理器...');
            
            // 初始化文件存储
            await this.fileStorage.init();
            
            // 加载数据
            await this.loadData();
            
            // 设置事件监听
            this.setupEventListeners();
            
            // 更新显示
            this.updateDisplay();
            
            // 初始化导入导出管理器
            if (typeof ImportExportManager !== 'undefined') {
                this.importExportManager = new ImportExportManager();
            }
            
            console.log('✅ 任务管理器初始化完成');
            
        } catch (error) {
            console.error('❌ 初始化失败:', error);
            this.showMessage('初始化失败，请刷新页面重试', 'error');
        }
    }
    
    // 加载数据
    async loadData() {
        try {
            // 加载任务列表
            this.tasks = await this.fileStorage.loadTasks();
            
            // 如果没有任务，使用默认任务
            if (!this.tasks || this.tasks.length === 0) {
                this.tasks = this.getDefaultTasks();
                await this.fileStorage.saveTasks(this.tasks);
            }
            
            // 加载今日完成状态
            this.completionStatus = await this.loadTodayCompletion();
            
            console.log(`📋 已加载 ${this.tasks.length} 个任务`);
            
        } catch (error) {
            console.error('加载数据失败:', error);
            this.tasks = this.getDefaultTasks();
            this.completionStatus = new Array(this.tasks.length).fill(false);
        }
    }
    
    // 获取默认任务列表
    getDefaultTasks() {
        return [
            { id: 'task_1', title: '学而思数感小超市', category: '学习', priority: 'high' },
            { id: 'task_2', title: '斑马思维', category: '学习', priority: 'high' },
            { id: 'task_3', title: '核桃编程（学生端）', category: '学习', priority: 'medium' },
            { id: 'task_4', title: '英语阅读', category: '学习', priority: 'medium' },
            { id: 'task_5', title: '硬笔写字（30分钟）', category: '练习', priority: 'medium' },
            { id: 'task_6', title: '悦乐达打卡/作业', category: '作业', priority: 'high' },
            { id: 'task_7', title: '暑假生活作业', category: '作业', priority: 'medium' },
            { id: 'task_8', title: '体育/运动（迪卡侬）', category: '运动', priority: 'low' }
        ];
    }
    
    // 加载今日完成状态
    async loadTodayCompletion() {
        try {
            const statistics = await this.fileStorage.loadStatistics();
            const today = this.getTodayString();
            
            // 查找今日统计记录
            const todayStats = statistics.find(stat => stat.date === today);
            if (todayStats && todayStats.completionStatus) {
                return todayStats.completionStatus;
            }
            
            // 如果没有今日记录，返回全部未完成
            return new Array(this.tasks.length).fill(false);
            
        } catch (error) {
            console.error('加载今日完成状态失败:', error);
            return new Array(this.tasks.length).fill(false);
        }
    }
    
    // 保存今日完成状态
    async saveTodayCompletion() {
        try {
            const statistics = await this.fileStorage.loadStatistics();
            const today = this.getTodayString();
            
            // 查找或创建今日统计记录
            let todayStats = statistics.find(stat => stat.date === today);
            if (!todayStats) {
                todayStats = {
                    date: today,
                    completedTasks: 0,
                    totalTasks: this.tasks.length,
                    completionStatus: [],
                    createdAt: new Date().toISOString()
                };
                statistics.push(todayStats);
            }
            
            // 更新完成状态
            todayStats.completionStatus = [...this.completionStatus];
            todayStats.completedTasks = this.completionStatus.filter(Boolean).length;
            todayStats.totalTasks = this.tasks.length;
            todayStats.updatedAt = new Date().toISOString();
            
            // 保存统计数据
            await this.fileStorage.saveStatistics(statistics);
            
        } catch (error) {
            console.error('保存今日完成状态失败:', error);
        }
    }
    
    // 设置事件监听
    setupEventListeners() {
        // 监听数据更新事件
        window.addEventListener('taskDataUpdated', () => {
            this.updateDisplay();
        });
        
        // 监听页面可见性变化
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden) {
                this.updateDisplay();
            }
        });
        
        // 监听存储变化（多标签页同步）
        window.addEventListener('storage', (e) => {
            if (e.key && e.key.includes('TaskManagerDB')) {
                this.loadData().then(() => this.updateDisplay());
            }
        });
    }
    
    // 更新显示
    updateDisplay() {
        this.updateDateDisplay();
        this.updateProgressDisplay();
        this.updateTasksDisplay();
        this.updateUserGreeting();
    }
    
    // 更新日期显示
    updateDateDisplay() {
        const dateElement = document.getElementById('current-date');
        if (dateElement) {
            const options = { 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric',
                weekday: 'long'
            };
            dateElement.textContent = this.currentDate.toLocaleDateString('zh-CN', options);
        }
    }
    
    // 更新进度显示
    updateProgressDisplay() {
        const completedCount = this.completionStatus.filter(Boolean).length;
        const totalCount = this.tasks.length;
        const percentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;
        
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
    
    // 更新进度消息
    updateProgressMessage(completed, total) {
        const messageElement = document.getElementById('progress-message');
        if (!messageElement) return;
        
        let message = '';
        const percentage = total > 0 ? (completed / total) * 100 : 0;
        
        if (percentage === 0) {
            message = '今天你还没开始任务，该加油喽！';
        } else if (percentage < 25) {
            message = '刚刚开始，继续努力！';
        } else if (percentage < 50) {
            message = '进展不错，保持下去！';
        } else if (percentage < 75) {
            message = '已经完成一半以上了，真棒！';
        } else if (percentage < 100) {
            message = '快要全部完成了，最后冲刺！';
        } else {
            message = '🎉 太棒了！今天的任务全部完成！';
            this.showCelebration();
        }
        
        messageElement.textContent = message;
    }
    
    // 更新任务显示
    updateTasksDisplay() {
        const tasksGrid = document.getElementById('tasks-grid');
        if (!tasksGrid) return;
        
        tasksGrid.innerHTML = '';
        
        this.tasks.forEach((task, index) => {
            const taskCard = this.createTaskCard(task, index);
            tasksGrid.appendChild(taskCard);
        });
    }
    
    // 创建任务卡片
    createTaskCard(task, index) {
        const isCompleted = this.completionStatus[index] || false;
        const card = document.createElement('div');
        card.className = `task-card ${isCompleted ? 'completed' : ''}`;
        card.dataset.taskIndex = index;
        
        // 获取优先级颜色
        const priorityColor = this.getPriorityColor(task.priority);
        
        card.innerHTML = `
            <div class="task-header">
                <div class="task-priority" style="background-color: ${priorityColor}"></div>
                <div class="task-category">${task.category || '任务'}</div>
            </div>
            <div class="task-content">
                <h3 class="task-title">${task.title}</h3>
                <div class="task-status">
                    <span class="status-text">${isCompleted ? '已完成' : '待完成'}</span>
                    <div class="status-icon">${isCompleted ? '✅' : '⭕'}</div>
                </div>
            </div>
            <div class="task-actions">
                <button class="task-btn complete-btn" onclick="taskManager.toggleTask(${index})">
                    ${isCompleted ? '取消完成' : '标记完成'}
                </button>
            </div>
        `;
        
        return card;
    }
    
    // 获取优先级颜色
    getPriorityColor(priority) {
        const colors = {
            'high': '#ff4757',
            'medium': '#ffa502',
            'low': '#2ed573'
        };
        return colors[priority] || colors['medium'];
    }
    
    // 切换任务完成状态
    async toggleTask(index) {
        if (index < 0 || index >= this.tasks.length) return;
        
        try {
            // 切换状态
            this.completionStatus[index] = !this.completionStatus[index];
            
            // 保存状态
            await this.saveTodayCompletion();
            
            // 更新显示
            this.updateDisplay();
            
            // 显示反馈
            const task = this.tasks[index];
            const isCompleted = this.completionStatus[index];
            this.showMessage(
                `${task.title} ${isCompleted ? '已完成' : '已取消完成'}`,
                isCompleted ? 'success' : 'info'
            );
            
        } catch (error) {
            console.error('切换任务状态失败:', error);
            this.showMessage('操作失败，请重试', 'error');
        }
    }
    
    // 重置今日任务
    async resetTasks() {
        const confirmed = confirm('确定要重置今日所有任务吗？此操作不可撤销。');
        if (!confirmed) return;
        
        try {
            // 重置完成状态
            this.completionStatus = new Array(this.tasks.length).fill(false);
            
            // 保存状态
            await this.saveTodayCompletion();
            
            // 更新显示
            this.updateDisplay();
            
            this.showMessage('今日任务已重置', 'success');
            
        } catch (error) {
            console.error('重置任务失败:', error);
            this.showMessage('重置失败，请重试', 'error');
        }
    }
    
    // 更新用户问候
    updateUserGreeting() {
        const usernameElement = document.getElementById('username');
        if (usernameElement) {
            // 从设置中获取用户名，默认为"小久"
            this.fileStorage.loadSettings().then(settings => {
                const username = settings.username || '小久';
                usernameElement.textContent = username;
            });
        }
    }
    
    // 显示庆祝动画
    showCelebration() {
        const celebration = document.getElementById('celebration');
        if (celebration) {
            celebration.style.display = 'block';
            celebration.classList.add('show');
            
            setTimeout(() => {
                celebration.classList.remove('show');
                setTimeout(() => {
                    celebration.style.display = 'none';
                }, 500);
            }, 3000);
        }
    }
    
    // 显示消息提示
    showMessage(message, type = 'info') {
        // 创建消息元素
        const messageDiv = document.createElement('div');
        messageDiv.className = `message message-${type}`;
        messageDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 8px;
            color: white;
            font-weight: bold;
            z-index: 10000;
            max-width: 300px;
            word-wrap: break-word;
            transform: translateX(100%);
            transition: transform 0.3s ease;
        `;
        
        // 设置颜色
        const colors = {
            'success': '#28a745',
            'error': '#dc3545',
            'warning': '#ffc107',
            'info': '#17a2b8'
        };
        messageDiv.style.backgroundColor = colors[type] || colors['info'];
        if (type === 'warning') {
            messageDiv.style.color = '#212529';
        }
        
        messageDiv.textContent = message;
        document.body.appendChild(messageDiv);
        
        // 显示动画
        setTimeout(() => {
            messageDiv.style.transform = 'translateX(0)';
        }, 100);
        
        // 3秒后自动移除
        setTimeout(() => {
            messageDiv.style.transform = 'translateX(100%)';
            setTimeout(() => {
                if (messageDiv.parentNode) {
                    messageDiv.parentNode.removeChild(messageDiv);
                }
            }, 300);
        }, 3000);
    }
    
    // 获取今日日期字符串
    getTodayString() {
        const today = new Date();
        return today.toISOString().split('T')[0];
    }
    
    // 导出数据
    async exportData() {
        try {
            const exportData = await this.fileStorage.exportAllData();
            if (exportData) {
                const today = new Date().toISOString().split('T')[0];
                const filename = `小久任务管理_导出数据_${today}.json`;
                
                const blob = new Blob([JSON.stringify(exportData, null, 2)], {
                    type: 'application/json'
                });
                
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = filename;
                a.click();
                URL.revokeObjectURL(url);
                
                this.showMessage('数据导出成功！', 'success');
            }
        } catch (error) {
            console.error('导出数据失败:', error);
            this.showMessage('导出失败，请重试', 'error');
        }
    }
    
    // 获取统计数据
    async getStatistics() {
        try {
            const statistics = await this.fileStorage.loadStatistics();
            return {
                totalDays: statistics.length,
                totalTasks: statistics.reduce((sum, day) => sum + day.totalTasks, 0),
                completedTasks: statistics.reduce((sum, day) => sum + day.completedTasks, 0),
                averageCompletion: statistics.length > 0 ? 
                    statistics.reduce((sum, day) => sum + (day.completedTasks / day.totalTasks), 0) / statistics.length * 100 : 0
            };
        } catch (error) {
            console.error('获取统计数据失败:', error);
            return {
                totalDays: 0,
                totalTasks: 0,
                completedTasks: 0,
                averageCompletion: 0
            };
        }
    }
}

// 全局函数（保持兼容性）
function openFocusChallenge() {
    window.location.href = 'focus-challenge.html';
}

function openEditTasks() {
    window.location.href = 'edit-tasks.html';
}

function openTodayTasksManager() {
    window.location.href = 'today-tasks.html';
}

function openStatistics() {
    window.location.href = 'statistics.html';
}

function resetTasks() {
    if (window.taskManager) {
        window.taskManager.resetTasks();
    }
}

// 初始化应用
window.taskManager = new TaskManagerFileOnly();

// 导出供其他模块使用
if (typeof module !== 'undefined' && module.exports) {
    module.exports = TaskManagerFileOnly;
}