// 任务管理系统核心逻辑 v4.4.3
// 实现服务器主导的串行更新机制

console.log('开始加载任务管理系统 v4.4.3...');

// 全局变量
let taskManagerInstance = null;

// 任务管理器类
class TaskManager {
    constructor() {
        this.version = '4.4.3';
        this.isInitialized = false;
        this.taskTimers = {}; // 任务计时器
        this.clientId = this.generateClientId();
        this.updateQueue = []; // 更新队列
        this.isProcessingQueue = false;
        this.serverData = null; // 服务器数据缓存
        
        console.log(`TaskManager v${this.version} 构造函数执行，客户端ID: ${this.clientId}`);
        
        // 等待DOM加载完成后初始化
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.initialize());
        } else {
            setTimeout(() => this.initialize(), 0);
        }
    }

    // 完整初始化流程
    async initialize() {
        console.log('开始完整初始化流程...');
        
        try {
            // 先初始化数据
            await this.initializeData();
            
            // 再初始化界面
            this.initializeUI();
            
            console.log('完整初始化流程完成');
        } catch (error) {
            console.error('初始化过程中出错:', error);
            // 即使出错也要显示界面，使用默认数据
            this.createDefaultData();
            this.initializeUI();
        }
    }

    // 生成客户端ID
    generateClientId() {
        const browser = this.getBrowserInfo();
        const timestamp = Date.now();
        const random = Math.random().toString(36).substr(2, 6);
        return `${browser}_${timestamp}_${random}`;
    }

    // 获取浏览器信息
    getBrowserInfo() {
        const ua = navigator.userAgent;
        if (ua.includes('Chrome')) return 'chrome';
        if (ua.includes('Firefox')) return 'firefox';
        if (ua.includes('Safari')) return 'safari';
        if (ua.includes('Edge')) return 'edge';
        return 'unknown';
    }

    // 初始化数据
    async initializeData() {
        console.log('初始化数据...');
        
        // 先创建默认数据，确保界面能正常显示
        this.createDefaultData();
        
        try {
            // 尝试从服务器获取最新数据
            console.log('尝试从服务器获取数据...');
            const response = await this.sendToServer({
                action: 'getData',
                clientId: this.clientId,
                userId: 'xiaojiu'
            });
            
            if (response && response.success && response.data) {
                this.serverData = response.data;
                console.log('从服务器加载数据成功:', response.data);
            } else {
                console.warn('服务器返回数据无效，使用默认数据');
            }
        } catch (error) {
            console.error('从服务器获取数据失败:', error);
            console.log('将使用默认数据继续运行');
        }
        
        console.log('数据初始化完成，当前数据:', this.serverData);
    }

    // 创建默认数据
    createDefaultData() {
        const today = new Date().toISOString().split('T')[0];
        this.serverData = {
            version: this.version,
            lastUpdateTime: Date.now(),
            updateSequence: 0,
            users: {
                xiaojiu: {
                    username: '小久',
                    tasks: [
                        '学而思数感小超市',
                        '斑马思维',
                        '核桃编程（学生端）',
                        '英语阅读',
                        '硬笔写字（30分钟）',
                        '悦乐达打卡/作业',
                        '暑假生活作业',
                        '体育/运动（迪卡侬）'
                    ],
                    dailyCompletion: {
                        [today]: {
                            completion: [false, false, false, false, false, false, false, false],
                            updateTime: Date.now(),
                            updateClient: 'client_init'
                        }
                    },
                    taskTiming: {
                        [today]: {}
                    },
                    focusRecords: []
                }
            }
        };
        console.log('创建默认数据:', this.serverData);
    }

    // 初始化用户界面
    initializeUI() {
        if (this.isInitialized) {
            console.log('UI已经初始化过了');
            return;
        }

        console.log('初始化用户界面...');
        
        try {
            // 设置当前日期
            this.updateCurrentDate();
            
            // 渲染任务
            this.renderTasks();
            
            // 更新进度
            this.updateProgress();
            
            // 绑定全局函数
            this.bindGlobalFunctions();
            
            this.isInitialized = true;
            console.log('用户界面初始化完成');
            
        } catch (error) {
            console.error('初始化UI时出错:', error);
        }
    }

    // 获取用户数据
    getUserData() {
        return this.serverData?.users?.xiaojiu || {};
    }

    // 获取今日完成状态
    getTodayCompletion() {
        const today = new Date().toISOString().split('T')[0];
        const userData = this.getUserData();
        const dailyData = userData.dailyCompletion?.[today];
        
        if (!dailyData) {
            const taskCount = userData.tasks?.length || 8;
            return new Array(taskCount).fill(false);
        }
        
        return dailyData.completion || [];
    }

    // 获取任务计时数据
    getTaskTiming(taskIndex) {
        const today = new Date().toISOString().split('T')[0];
        const userData = this.getUserData();
        return userData.taskTiming?.[today]?.[taskIndex] || 0;
    }

    // 更新当前日期显示
    updateCurrentDate() {
        const dateElement = document.getElementById('current-date');
        if (dateElement) {
            const today = new Date();
            const options = { 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric',
                weekday: 'long'
            };
            dateElement.textContent = today.toLocaleDateString('zh-CN', options);
            console.log('日期已更新');
        }
    }

    // 渲染任务列表
    renderTasks() {
        const tasksGrid = document.getElementById('tasks-grid');
        if (!tasksGrid) {
            console.error('找不到任务网格元素 #tasks-grid');
            return;
        }

        const userData = this.getUserData();
        const tasks = userData.tasks || [];
        const todayCompletion = this.getTodayCompletion();

        // 清空现有内容
        tasksGrid.innerHTML = '';

        // 创建任务卡片
        tasks.forEach((task, index) => {
            const isCompleted = todayCompletion[index] || false;
            const taskCard = this.createTaskCard(task, index, isCompleted);
            tasksGrid.appendChild(taskCard);
        });

        console.log(`已渲染 ${tasks.length} 个任务`);
    }

    // 创建任务卡片
    createTaskCard(taskName, index, isCompleted) {
        const card = document.createElement('div');
        card.className = `task-card ${isCompleted ? 'completed' : ''}`;
        card.setAttribute('data-task-index', index);
        
        // 获取任务累计时间
        const totalTime = this.getTaskTiming(index);
        const timeDisplay = this.formatTime(totalTime);
        
        card.innerHTML = `
            <div class="task-header">
                <div class="task-icon">${isCompleted ? '✅' : '⭕'}</div>
            </div>
            <div class="task-title">${taskName}</div>
            <div class="task-time-info">
                累计用时：${timeDisplay}
            </div>
            <div class="task-buttons">
                <button class="task-btn start-btn" onclick="taskManager.startTask(${index})" 
                        ${isCompleted ? 'style="display:none"' : ''}>
                    开始任务
                </button>
                <button class="task-btn complete-btn" onclick="taskManager.toggleTask(${index})">
                    ${isCompleted ? '取消完成' : '完成任务'}
                </button>
            </div>
        `;

        return card;
    }

    // 格式化时间显示
    formatTime(seconds) {
        if (seconds < 60) {
            return `${seconds}秒`;
        } else if (seconds < 3600) {
            const minutes = Math.floor(seconds / 60);
            const remainingSeconds = seconds % 60;
            return `${minutes}分${remainingSeconds}秒`;
        } else {
            const hours = Math.floor(seconds / 3600);
            const minutes = Math.floor((seconds % 3600) / 60);
            return `${hours}小时${minutes}分钟`;
        }
    }

    // 切换任务状态
    async toggleTask(index) {
        console.log(`切换任务 ${index} 状态`);
        
        try {
            const currentCompletion = this.getTodayCompletion();
            const newStatus = !currentCompletion[index];
            
            // 乐观更新UI
            this.updateTaskUIOptimistically(index, newStatus);
            
            // 如果任务正在计时，先停止计时
            if (this.taskTimers[index]) {
                await this.stopTask(index);
            }
            
            // 发送更新到服务器
            const response = await this.sendToServer({
                action: 'updateTask',
                taskIndex: index,
                completed: newStatus,
                clientId: this.clientId,
                userId: 'xiaojiu',
                timestamp: Date.now()
            });
            
            if (response.success) {
                // 用服务器数据更新本地
                this.serverData = response.data;
                this.renderTasks();
                this.updateProgress();
                
                // 如果完成了任务，显示庆祝动画
                if (newStatus) {
                    this.showCelebration();
                }
                
                console.log('任务状态更新成功');
            } else {
                // 失败时回滚UI
                this.updateTaskUIOptimistically(index, !newStatus);
                alert('更新失败：' + response.message);
            }
            
        } catch (error) {
            console.error('切换任务状态时出错:', error);
            // 回滚UI更新
            const currentCompletion = this.getTodayCompletion();
            this.updateTaskUIOptimistically(index, currentCompletion[index]);
            alert('网络错误，请稍后重试');
        }
    }

    // 乐观更新UI
    updateTaskUIOptimistically(index, completed) {
        const card = document.querySelector(`[data-task-index="${index}"]`);
        if (card) {
            if (completed) {
                card.classList.add('completed');
                card.querySelector('.task-icon').textContent = '✅';
                card.querySelector('.complete-btn').textContent = '取消完成';
                card.querySelector('.start-btn').style.display = 'none';
            } else {
                card.classList.remove('completed');
                card.querySelector('.task-icon').textContent = '⭕';
                card.querySelector('.complete-btn').textContent = '完成任务';
                card.querySelector('.start-btn').style.display = 'inline-block';
            }
        }
    }

    // 开始任务计时
    async startTask(index) {
        const userData = this.getUserData();
        const taskName = userData.tasks[index];
        
        console.log(`开始任务计时: ${taskName}`);
        
        // 如果已经在计时，先停止
        if (this.taskTimers[index]) {
            await this.stopTask(index);
            return;
        }
        
        // 通知服务器开始计时
        try {
            await this.sendToServer({
                action: 'startTimer',
                taskIndex: index,
                clientId: this.clientId,
                userId: 'xiaojiu',
                timestamp: Date.now()
            });
        } catch (error) {
            console.warn('通知服务器开始计时失败:', error);
        }
        
        // 开始本地计时
        const startTime = Date.now();
        this.taskTimers[index] = {
            startTime: startTime,
            interval: setInterval(() => {
                const elapsed = Math.floor((Date.now() - startTime) / 1000);
                this.updateTaskTimeDisplay(index, elapsed);
            }, 1000)
        };
        
        // 更新按钮状态
        const card = document.querySelector(`[data-task-index="${index}"]`);
        if (card) {
            const startBtn = card.querySelector('.start-btn');
            if (startBtn) {
                startBtn.textContent = '停止计时';
                startBtn.classList.add('timing');
            }
        }
    }

    // 停止任务计时
    async stopTask(index) {
        if (!this.taskTimers[index]) return;
        
        const userData = this.getUserData();
        const taskName = userData.tasks[index];
        
        console.log(`停止任务计时: ${taskName}`);
        
        // 计算用时
        const elapsed = Math.floor((Date.now() - this.taskTimers[index].startTime) / 1000);
        
        // 清除定时器
        clearInterval(this.taskTimers[index].interval);
        delete this.taskTimers[index];
        
        // 发送计时数据到服务器
        try {
            const response = await this.sendToServer({
                action: 'stopTimer',
                taskIndex: index,
                elapsedTime: elapsed,
                clientId: this.clientId,
                userId: 'xiaojiu',
                timestamp: Date.now()
            });
            
            if (response.success) {
                this.serverData = response.data;
            }
        } catch (error) {
            console.error('保存计时数据失败:', error);
        }
        
        // 更新按钮状态
        const card = document.querySelector(`[data-task-index="${index}"]`);
        if (card) {
            const startBtn = card.querySelector('.start-btn');
            if (startBtn) {
                startBtn.textContent = '开始任务';
                startBtn.classList.remove('timing');
            }
        }
        
        // 重新渲染任务卡片
        this.renderTasks();
    }

    // 更新任务时间显示
    updateTaskTimeDisplay(index, currentElapsed) {
        const card = document.querySelector(`[data-task-index="${index}"]`);
        if (card) {
            const timeInfo = card.querySelector('.task-time-info');
            if (timeInfo) {
                const totalTime = this.getTaskTiming(index) + currentElapsed;
                timeInfo.textContent = `累计用时：${this.formatTime(totalTime)} (计时中...)`;
            }
        }
    }

    // 发送请求到服务器
    async sendToServer(data) {
        const response = await fetch('api/serial-update.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });

        if (!response.ok) {
            throw new Error(`HTTP错误: ${response.status}`);
        }

        return await response.json();
    }

    // 更新进度显示
    updateProgress() {
        try {
            const todayCompletion = this.getTodayCompletion();
            const completed = todayCompletion.filter(Boolean).length;
            const total = todayCompletion.length;
            const percentage = total > 0 ? (completed / total) * 100 : 0;

            // 更新进度条
            const progressFill = document.getElementById('progress-fill');
            if (progressFill) {
                progressFill.style.width = `${percentage}%`;
            }

            // 更新进度文本
            const progressText = document.getElementById('progress-text');
            if (progressText) {
                progressText.textContent = `${completed}/${total}`;
            }

            // 更新进度消息
            const progressMessage = document.getElementById('progress-message');
            if (progressMessage) {
                if (completed === 0) {
                    progressMessage.textContent = '今天你还没开始任务，该加油喽！';
                } else if (completed === total) {
                    progressMessage.textContent = '太棒了！今天的任务全部完成了！🎉';
                } else {
                    progressMessage.textContent = `已完成 ${completed} 个任务，继续加油！`;
                }
            }

            console.log(`进度更新: ${completed}/${total} (${percentage.toFixed(1)}%)`);
            
        } catch (error) {
            console.error('更新进度时出错:', error);
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
                }, 300);
            }, 2000);
        }
    }

    // 重置今日任务
    async resetTodayTasks() {
        console.log('重置今日任务');
        
        if (confirm('确定要重置今天的所有任务吗？这将清除所有完成状态和计时记录。')) {
            try {
                // 停止所有正在进行的计时
                Object.keys(this.taskTimers).forEach(async (index) => {
                    await this.stopTask(parseInt(index));
                });
                
                // 这里可以添加重置服务器数据的逻辑
                // 暂时通过重新加载数据来实现
                await this.initializeData();
                this.renderTasks();
                this.updateProgress();
                
                alert('今日任务已重置！');
            } catch (error) {
                console.error('重置任务时出错:', error);
                alert('重置失败，请稍后再试');
            }
        }
    }

    // 绑定全局函数
    bindGlobalFunctions() {
        console.log('绑定全局函数...');
        
        window.toggleTaskGlobal = (index) => {
            if (taskManagerInstance) {
                taskManagerInstance.toggleTask(index);
            }
        };

        window.startTaskGlobal = (index) => {
            if (taskManagerInstance) {
                taskManagerInstance.startTask(index);
            }
        };

        window.openFocusChallenge = () => {
            console.log('打开专注力挑战');
            window.location.href = 'focus-challenge.html';
        };

        window.openEditTasks = () => {
            console.log('打开任务编辑');
            window.location.href = 'edit-tasks.html';
        };

        window.openTodayTasksManager = () => {
            console.log('打开今日任务管理');
            window.location.href = 'today-tasks.html';
        };

        window.openStatistics = () => {
            console.log('打开统计页面');
            window.location.href = 'statistics.html';
        };

        window.resetTasks = () => {
            if (taskManagerInstance) {
                taskManagerInstance.resetTodayTasks();
            }
        };

        console.log('全局函数绑定完成');
    }

    // 销毁方法
    destroy() {
        // 停止所有任务计时
        Object.keys(this.taskTimers).forEach(index => {
            clearInterval(this.taskTimers[index].interval);
        });
        
        console.log('TaskManager已销毁');
    }
}

// 创建全局实例
console.log('创建TaskManager实例...');
taskManagerInstance = new TaskManager();

// 确保全局可用
window.taskManager = taskManagerInstance;

// 调试信息
window.debugTaskManager = () => {
    console.log('TaskManager实例:', taskManagerInstance);
    console.log('服务器数据:', taskManagerInstance.serverData);
    console.log('版本:', taskManagerInstance.version);
    console.log('计时器:', taskManagerInstance.taskTimers);
};

console.log('任务管理系统 v4.4.3 加载完成');
