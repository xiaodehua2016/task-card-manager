// 任务管理系统核心逻辑 v4.3.6.1
// 修复：今日任务显示和底部按钮点击问题

class TaskManager {
    constructor() {
        this.version = '4.3.6.1';
        this.defaultTasks = [
            '学而思数感小超市',
            '斑马思维', 
            '核桃编程（学生端）',
            '英语阅读',
            '硬笔写字（30分钟）',
            '悦乐达打卡/作业',
            '暑假生活作业',
            '体育/运动（迪卡侬）'
        ];
        this.init();
    }

    init() {
        console.log(`任务管理系统 v${this.version} 初始化中...`);
        
        // 确保数据存在
        this.ensureDataExists();
        
        // 等待DOM加载完成
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.initializeApp());
        } else {
            this.initializeApp();
        }
    }

    ensureDataExists() {
        const today = new Date().toISOString().split('T')[0];
        let data = this.loadData();
        
        if (!data || !data.tasks || data.tasks.length === 0) {
            console.log('初始化默认数据...');
            data = {
                username: '小久',
                tasks: [...this.defaultTasks],
                completionHistory: {
                    [today]: new Array(this.defaultTasks.length).fill(false)
                },
                taskTimes: {},
                focusRecords: {},
                lastUpdateTime: Date.now(),
                version: this.version
            };
            this.saveData(data);
        }

        // 确保今日数据存在
        if (!data.completionHistory[today]) {
            data.completionHistory[today] = new Array(data.tasks.length).fill(false);
            this.saveData(data);
        }

        // 确保数据长度匹配
        if (data.completionHistory[today].length !== data.tasks.length) {
            data.completionHistory[today] = new Array(data.tasks.length).fill(false);
            this.saveData(data);
        }

        return data;
    }

    loadData() {
        try {
            const data = localStorage.getItem('taskManagerData');
            return data ? JSON.parse(data) : null;
        } catch (error) {
            console.error('加载数据失败:', error);
            return null;
        }
    }

    saveData(data) {
        try {
            data.lastUpdateTime = Date.now();
            data.version = this.version;
            localStorage.setItem('taskManagerData', JSON.stringify(data));
            console.log('数据已保存');
        } catch (error) {
            console.error('保存数据失败:', error);
        }
    }

    initializeApp() {
        console.log('初始化应用界面...');
        
        // 设置当前日期
        this.updateCurrentDate();
        
        // 渲染任务
        this.renderTasks();
        
        // 更新进度
        this.updateProgress();
        
        // 绑定全局函数
        this.bindGlobalFunctions();
        
        console.log('应用初始化完成');
    }

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
        }
    }

    renderTasks() {
        const tasksGrid = document.getElementById('tasks-grid');
        if (!tasksGrid) {
            console.error('找不到任务网格元素');
            return;
        }

        const data = this.loadData();
        const today = new Date().toISOString().split('T')[0];
        const todayCompletion = data.completionHistory[today] || [];

        tasksGrid.innerHTML = '';

        data.tasks.forEach((task, index) => {
            const isCompleted = todayCompletion[index] || false;
            const taskCard = this.createTaskCard(task, index, isCompleted);
            tasksGrid.appendChild(taskCard);
        });

        console.log(`已渲染 ${data.tasks.length} 个任务`);
    }

    createTaskCard(taskName, index, isCompleted) {
        const card = document.createElement('div');
        card.className = `task-card ${isCompleted ? 'completed' : ''}`;
        card.setAttribute('data-task-index', index);
        
        card.innerHTML = `
            <div class="task-header">
                <div class="task-icon">${isCompleted ? '✅' : '⭕'}</div>
            </div>
            <div class="task-title">${taskName}</div>
            <div class="task-buttons">
                <button class="task-btn complete-btn" onclick="taskManager.toggleTask(${index})">
                    ${isCompleted ? '取消完成' : '完成任务'}
                </button>
            </div>
        `;

        return card;
    }

    toggleTask(index) {
        console.log(`切换任务 ${index} 状态`);
        
        const data = this.loadData();
        const today = new Date().toISOString().split('T')[0];
        
        if (!data.completionHistory[today]) {
            data.completionHistory[today] = new Array(data.tasks.length).fill(false);
        }

        // 切换状态
        data.completionHistory[today][index] = !data.completionHistory[today][index];
        
        // 保存数据
        this.saveData(data);
        
        // 重新渲染
        this.renderTasks();
        this.updateProgress();
        
        // 如果完成了任务，显示庆祝动画
        if (data.completionHistory[today][index]) {
            this.showCelebration();
        }
    }

    updateProgress() {
        const data = this.loadData();
        const today = new Date().toISOString().split('T')[0];
        const todayCompletion = data.completionHistory[today] || [];
        
        const completed = todayCompletion.filter(Boolean).length;
        const total = data.tasks.length;
        const percentage = total > 0 ? (completed / total) * 100 : 0;

        // 更新进度条
        const progressFill = document.getElementById('progress-fill');
        const progressText = document.getElementById('progress-text');
        const progressMessage = document.getElementById('progress-message');

        if (progressFill) {
            progressFill.style.width = `${percentage}%`;
        }

        if (progressText) {
            progressText.textContent = `${completed}/${total}`;
        }

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
    }

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

    bindGlobalFunctions() {
        // 绑定全局函数到window对象
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
            console.log('重置今日任务');
            if (confirm('确定要重置今天的所有任务吗？')) {
                const data = this.loadData();
                const today = new Date().toISOString().split('T')[0];
                data.completionHistory[today] = new Array(data.tasks.length).fill(false);
                this.saveData(data);
                this.renderTasks();
                this.updateProgress();
                alert('今日任务已重置！');
            }
        };

        // 确保taskManager全局可用
        window.taskManager = this;

        console.log('全局函数已绑定');
    }
}

// 创建全局实例
const taskManager = new TaskManager();

// 确保全局可用
window.taskManager = taskManager;

console.log('任务管理系统 v4.3.6.1 加载完成');