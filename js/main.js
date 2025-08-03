// 任务管理系统核心逻辑 v4.3.6.3
// 修复：恢复任务计时功能 + 实现跨浏览器数据同步

console.log('开始加载任务管理系统 v4.3.6.3...');

// 全局变量
let taskManagerInstance = null;

// 默认任务列表
const DEFAULT_TASKS = [
    '学而思数感小超市',
    '斑马思维', 
    '核桃编程（学生端）',
    '英语阅读',
    '硬笔写字（30分钟）',
    '悦乐达打卡/作业',
    '暑假生活作业',
    '体育/运动（迪卡侬）'
];

// 任务管理器类
class TaskManager {
    constructor() {
        this.version = '4.3.6.4';
        this.defaultTasks = [...DEFAULT_TASKS];
        this.isInitialized = false;
        this.taskTimers = {}; // 任务计时器
        this.syncInterval = null; // 同步定时器
        
        console.log(`TaskManager v${this.version} 构造函数执行`);
        
        // 立即初始化数据
        this.initializeData();
        
        // 启动数据同步
        this.startDataSync();
        
        // 等待DOM加载完成后初始化界面
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.initializeUI());
        } else {
            setTimeout(() => this.initializeUI(), 0);
        }
    }

    // 初始化数据
    initializeData() {
        console.log('初始化数据...');
        
        const today = new Date().toISOString().split('T')[0];
        let data = this.loadData();
        
        // 如果没有数据或数据不完整，创建默认数据
        if (!data || !data.tasks || !Array.isArray(data.tasks) || data.tasks.length === 0) {
            console.log('创建默认数据');
            data = {
                username: '小久',
                tasks: [...this.defaultTasks],
                completionHistory: {},
                taskTimes: {}, // 任务计时记录
                focusRecords: {},
                lastUpdateTime: Date.now(),
                version: this.version
            };
        }

        // 确保今日完成状态存在
        if (!data.completionHistory) {
            data.completionHistory = {};
        }
        
        if (!data.completionHistory[today]) {
            data.completionHistory[today] = new Array(data.tasks.length).fill(false);
        }

        // 确保任务计时记录存在
        if (!data.taskTimes) {
            data.taskTimes = {};
        }

        // 确保数据长度匹配
        if (data.completionHistory[today].length !== data.tasks.length) {
            data.completionHistory[today] = new Array(data.tasks.length).fill(false);
        }

        // 保存数据
        this.saveData(data);
        
        console.log('数据初始化完成:', data);
        return data;
    }

    // 启动数据同步
    startDataSync() {
        console.log('启动跨浏览器数据同步...');
        
        // 每5秒同步一次数据
        this.syncInterval = setInterval(() => {
            this.syncDataWithServer();
        }, 5000);
        
        // 页面关闭时保存数据
        window.addEventListener('beforeunload', () => {
            this.syncDataWithServer();
        });
    }

    // 与服务器同步数据
    async syncDataWithServer() {
        try {
            const localData = this.loadData();
            if (!localData) return;

            // 发送数据到服务器
            const response = await fetch('api/data-sync.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    action: 'sync',
                    data: localData,
                    timestamp: Date.now()
                })
            });

            if (response.ok) {
                const result = await response.json();
                
                if (result.success && result.data) {
                    // 检查服务器数据是否更新
                    if (result.data.lastUpdateTime > localData.lastUpdateTime) {
                        console.log('发现服务器数据更新，同步到本地');
                        
                        // 合并数据（保留本地未完成的任务状态）
                        const mergedData = this.mergeData(localData, result.data);
                        this.saveData(mergedData);
                        
                        // 重新渲染界面
                        if (this.isInitialized) {
                            this.renderTasks();
                            this.updateProgress();
                        }
                    }
                }
            }
        } catch (error) {
            console.warn('数据同步失败:', error);
        }
    }

    // 合并本地和服务器数据
    mergeData(localData, serverData) {
        const today = new Date().toISOString().split('T')[0];
        
        // 以服务器数据为基础
        const mergedData = { ...serverData };
        
        // 保留本地的今日完成状态（如果本地更新时间更新）
        if (localData.completionHistory && localData.completionHistory[today]) {
            if (!mergedData.completionHistory) {
                mergedData.completionHistory = {};
            }
            
            // 如果本地今日数据更新，使用本地数据
            const localTodayTime = localData.lastUpdateTime || 0;
            const serverTodayTime = serverData.lastUpdateTime || 0;
            
            if (localTodayTime > serverTodayTime) {
                mergedData.completionHistory[today] = localData.completionHistory[today];
                mergedData.lastUpdateTime = localTodayTime;
            }
        }
        
        // 合并任务计时数据
        if (localData.taskTimes) {
            mergedData.taskTimes = { ...mergedData.taskTimes, ...localData.taskTimes };
        }
        
        return mergedData;
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

    // 加载数据
    loadData() {
        try {
            const data = localStorage.getItem('taskManagerData');
            return data ? JSON.parse(data) : null;
        } catch (error) {
            console.error('加载数据失败:', error);
            return null;
        }
    }

    // 保存数据
    saveData(data) {
        try {
            data.lastUpdateTime = Date.now();
            data.version = this.version;
            localStorage.setItem('taskManagerData', JSON.stringify(data));
            console.log('数据已保存');
            
            // 立即同步到服务器
            this.syncDataWithServer();
            
            return true;
        } catch (error) {
            console.error('保存数据失败:', error);
            return false;
        }
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
        } else {
            console.warn('找不到日期元素 #current-date');
        }
    }

    // 渲染任务列表
    renderTasks() {
        const tasksGrid = document.getElementById('tasks-grid');
        if (!tasksGrid) {
            console.error('找不到任务网格元素 #tasks-grid');
            return;
        }

        const data = this.loadData();
        if (!data || !data.tasks) {
            console.error('没有任务数据');
            return;
        }

        const today = new Date().toISOString().split('T')[0];
        const todayCompletion = data.completionHistory[today] || [];

        // 清空现有内容
        tasksGrid.innerHTML = '';

        // 创建任务卡片
        data.tasks.forEach((task, index) => {
            const isCompleted = todayCompletion[index] || false;
            const taskCard = this.createTaskCard(task, index, isCompleted, data.taskTimes);
            tasksGrid.appendChild(taskCard);
        });

        console.log(`已渲染 ${data.tasks.length} 个任务`);
    }

    // 创建任务卡片
    createTaskCard(taskName, index, isCompleted, taskTimes) {
        const card = document.createElement('div');
        card.className = `task-card ${isCompleted ? 'completed' : ''}`;
        card.setAttribute('data-task-index', index);
        
        // 获取任务累计时间
        const taskKey = `${taskName}_${index}`;
        const totalTime = taskTimes[taskKey] || 0;
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

    // 开始任务计时
    startTask(index) {
        const data = this.loadData();
        if (!data) return;

        const taskName = data.tasks[index];
        const taskKey = `${taskName}_${index}`;
        
        console.log(`开始任务计时: ${taskName}`);
        
        // 如果已经在计时，先停止
        if (this.taskTimers[taskKey]) {
            this.stopTask(index);
            return;
        }
        
        // 开始计时
        const startTime = Date.now();
        this.taskTimers[taskKey] = {
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
    stopTask(index) {
        const data = this.loadData();
        if (!data) return;

        const taskName = data.tasks[index];
        const taskKey = `${taskName}_${index}`;
        
        if (!this.taskTimers[taskKey]) return;
        
        console.log(`停止任务计时: ${taskName}`);
        
        // 计算用时
        const elapsed = Math.floor((Date.now() - this.taskTimers[taskKey].startTime) / 1000);
        
        // 清除定时器
        clearInterval(this.taskTimers[taskKey].interval);
        delete this.taskTimers[taskKey];
        
        // 保存累计时间
        if (!data.taskTimes) data.taskTimes = {};
        data.taskTimes[taskKey] = (data.taskTimes[taskKey] || 0) + elapsed;
        this.saveData(data);
        
        // 更新按钮状态
        const card = document.querySelector(`[data-task-index="${index}"]`);
        if (card) {
            const startBtn = card.querySelector('.start-btn');
            if (startBtn) {
                startBtn.textContent = '开始任务';
                startBtn.classList.remove('timing');
            }
        }
        
        // 重新渲染任务卡片以显示更新的时间
        this.renderTasks();
    }

    // 更新任务时间显示
    updateTaskTimeDisplay(index, currentElapsed) {
        const card = document.querySelector(`[data-task-index="${index}"]`);
        if (card) {
            const timeInfo = card.querySelector('.task-time-info');
            if (timeInfo) {
                const data = this.loadData();
                const taskName = data.tasks[index];
                const taskKey = `${taskName}_${index}`;
                const totalTime = (data.taskTimes[taskKey] || 0) + currentElapsed;
                timeInfo.textContent = `累计用时：${this.formatTime(totalTime)} (计时中...)`;
            }
        }
    }

    // 切换任务状态
    toggleTask(index) {
        console.log(`切换任务 ${index} 状态`);
        
        try {
            const data = this.loadData();
            if (!data) {
                console.error('无法加载数据');
                return;
            }

            const today = new Date().toISOString().split('T')[0];
            
            // 确保今日完成状态存在
            if (!data.completionHistory[today]) {
                data.completionHistory[today] = new Array(data.tasks.length).fill(false);
            }

            // 如果任务正在计时，先停止计时
            const taskName = data.tasks[index];
            const taskKey = `${taskName}_${index}`;
            if (this.taskTimers[taskKey]) {
                this.stopTask(index);
            }

            // 切换状态
            data.completionHistory[today][index] = !data.completionHistory[today][index];
            
            // 保存数据
            if (this.saveData(data)) {
                // 重新渲染
                this.renderTasks();
                this.updateProgress();
                
                // 如果完成了任务，显示庆祝动画
                if (data.completionHistory[today][index]) {
                    this.showCelebration();
                }
            }
            
        } catch (error) {
            console.error('切换任务状态时出错:', error);
        }
    }

    // 更新进度显示
    updateProgress() {
        try {
            const data = this.loadData();
            if (!data) return;

            const today = new Date().toISOString().split('T')[0];
            const todayCompletion = data.completionHistory[today] || [];
            
            const completed = todayCompletion.filter(Boolean).length;
            const total = data.tasks.length;
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
    resetTodayTasks() {
        console.log('重置今日任务');
        
        if (confirm('确定要重置今天的所有任务吗？这将清除所有完成状态和计时记录。')) {
            try {
                // 停止所有正在进行的计时
                Object.keys(this.taskTimers).forEach(taskKey => {
                    const index = parseInt(taskKey.split('_').pop());
                    this.stopTask(index);
                });
                
                const data = this.loadData();
                if (data) {
                    const today = new Date().toISOString().split('T')[0];
                    data.completionHistory[today] = new Array(data.tasks.length).fill(false);
                    
                    // 清除今日的计时记录
                    Object.keys(data.taskTimes).forEach(key => {
                        if (key.includes('_')) {
                            delete data.taskTimes[key];
                        }
                    });
                    
                    if (this.saveData(data)) {
                        this.renderTasks();
                        this.updateProgress();
                        alert('今日任务已重置！');
                    }
                }
            } catch (error) {
                console.error('重置任务时出错:', error);
                alert('重置失败，请稍后再试');
            }
        }
    }

    // 绑定全局函数
    bindGlobalFunctions() {
        console.log('绑定全局函数...');
        
        // 确保全局函数存在
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
        // 清除同步定时器
        if (this.syncInterval) {
            clearInterval(this.syncInterval);
        }
        
        // 停止所有任务计时
        Object.keys(this.taskTimers).forEach(taskKey => {
            clearInterval(this.taskTimers[taskKey].interval);
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
    console.log('数据:', taskManagerInstance.loadData());
    console.log('版本:', taskManagerInstance.version);
    console.log('计时器:', taskManagerInstance.taskTimers);
};

console.log('任务管理系统 v4.3.6.3 加载完成');