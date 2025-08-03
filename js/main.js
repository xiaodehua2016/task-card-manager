/**
 * 小久任务管理系统 - 核心逻辑 (v5.0 重构版)
 * 彻底修复数据初始化、事件绑定和UI渲染问题
 */
document.addEventListener('DOMContentLoaded', () => {
    console.log("DOM fully loaded and parsed. Initializing Task Manager v5.0...");

    const App = {
        // --- 配置 ---
        config: {
            storageKey: 'taskManagerData_v5',
            defaultUsername: '小久',
            defaultTasks: [
                '学而思数感小超市', '斑马思维', '核桃编程（学生端）',
                '英语阅读', '硬笔写字（30分钟）', '悦乐达打卡/作业',
                '暑假生活作业', '体育/运动（迪卡侬）'
            ]
        },

        // --- 状态 ---
        state: {
            data: null,
            today: new Date().toISOString().split('T')[0]
        },

        // --- 初始化 ---
        init() {
            this.loadData();
            this.bindUI();
            this.renderAll();
            console.log("Task Manager Initialized Successfully.");
        },

        // --- 数据处理 ---
        loadData() {
            let data;
            try {
                data = JSON.parse(localStorage.getItem(this.config.storageKey));
            } catch (error) {
                console.error("Failed to parse data from localStorage, creating new data.", error);
                data = null;
            }

            if (!this.isDataValid(data)) {
                console.warn("Data is invalid or missing. Creating default data set.");
                data = this.createDefaultData();
            } else {
                // 数据迁移或检查
                if (!data.completionHistory[this.state.today]) {
                    console.log("New day detected. Initializing today's task status.");
                    data.completionHistory[this.state.today] = new Array(data.tasks.length).fill(false);
                }
                // 修复可能存在的长度不匹配问题
                if (data.completionHistory[this.state.today].length !== data.tasks.length) {
                    console.warn("Task list and completion history mismatch. Resetting today's completion status.");
                    data.completionHistory[this.state.today] = new Array(data.tasks.length).fill(false);
                }
            }
            
            this.state.data = data;
            this.saveData();
        },

        isDataValid(data) {
            return data &&
                   data.username &&
                   Array.isArray(data.tasks) &&
                   data.completionHistory &&
                   typeof data.completionHistory === 'object';
        },

        createDefaultData() {
            const defaultData = {
                username: this.config.defaultUsername,
                tasks: [...this.config.defaultTasks],
                completionHistory: {
                    [this.state.today]: new Array(this.config.defaultTasks.length).fill(false)
                },
                taskTimes: {},
                focusRecords: {},
                lastUpdateTime: Date.now()
            };
            return defaultData;
        },

        saveData() {
            try {
                this.state.data.lastUpdateTime = Date.now();
                localStorage.setItem(this.config.storageKey, JSON.stringify(this.state.data));
            } catch (error) {
                console.error("Failed to save data to localStorage.", error);
                alert("无法保存数据！您的浏览器可能已禁用本地存储。");
            }
        },

        // --- UI渲染 ---
        renderAll() {
            this.renderUsername();
            this.renderTasks();
            this.renderProgressBar();
        },

        renderUsername() {
            const usernameEl = document.getElementById('username');
            if (usernameEl) {
                usernameEl.textContent = this.state.data.username;
            }
        },

        renderTasks() {
            const taskListEl = document.getElementById('task-list');
            if (!taskListEl) return;

            taskListEl.innerHTML = '';
            const todayCompletion = this.state.data.completionHistory[this.state.today] || [];

            if (this.state.data.tasks.length === 0) {
                taskListEl.innerHTML = '<p class="no-tasks">今日无任务，请在“编辑任务”中添加。</p>';
                return;
            }

            this.state.data.tasks.forEach((taskName, index) => {
                const isCompleted = todayCompletion[index] === true;
                const card = this.createTaskCard(taskName, index, isCompleted);
                taskListEl.appendChild(card);
            });
        },

        createTaskCard(taskName, index, isCompleted) {
            const card = document.createElement('div');
            card.className = `task-card ${isCompleted ? 'completed' : ''}`;
            card.dataset.index = index;

            card.innerHTML = `
                <div class="task-icon"></div>
                <div class="task-title">${taskName}</div>
                <div class="task-buttons">
                    <button class="task-btn complete-btn">${isCompleted ? '撤销' : '完成'}</button>
                </div>
            `;
            
            // 使用可靠的事件监听
            card.querySelector('.complete-btn').addEventListener('click', (e) => {
                e.stopPropagation();
                this.toggleTask(index);
            });

            return card;
        },

        renderProgressBar() {
            const progressBarEl = document.getElementById('progress-bar-fill');
            const progressTextEl = document.getElementById('progress-text');
            if (!progressBarEl || !progressTextEl) return;

            const todayCompletion = this.state.data.completionHistory[this.state.today] || [];
            const completedCount = todayCompletion.filter(Boolean).length;
            const totalTasks = this.state.data.tasks.length;
            const percentage = totalTasks > 0 ? (completedCount / totalTasks) * 100 : 0;

            progressBarEl.style.width = `${percentage}%`;
            progressTextEl.textContent = `今日已完成: ${completedCount} / ${totalTasks}`;
        },

        // --- 事件处理 ---
        bindUI() {
            // 底部导航按钮
            document.getElementById('btn-edit-tasks')?.addEventListener('click', () => this.openEditTasks());
            document.getElementById('btn-focus-challenge')?.addEventListener('click', () => this.openFocusChallenge());
            document.getElementById('btn-today-tasks')?.addEventListener('click', () => this.openTodayTasksManager());
            document.getElementById('btn-statistics')?.addEventListener('click', () => this.openStatistics());
            document.getElementById('btn-reset-tasks')?.addEventListener('click', () => this.resetTasks());
        },

        toggleTask(index) {
            const todayCompletion = this.state.data.completionHistory[this.state.today];
            if (todayCompletion) {
                todayCompletion[index] = !todayCompletion[index];
                this.saveData();
                this.renderAll(); // 重新渲染以更新UI
            }
        },

        // --- 页面导航与操作 ---
        openEditTasks() {
            // 在实际应用中，这里可能是弹窗或跳转到新页面
            const newTasksRaw = prompt("编辑任务列表 (用英文逗号分隔):", this.state.data.tasks.join(','));
            if (newTasksRaw !== null) {
                const oldTaskCount = this.state.data.tasks.length;
                this.state.data.tasks = newTasksRaw.split(',').map(t => t.trim()).filter(Boolean);
                const newTaskCount = this.state.data.tasks.length;

                // 如果任务列表变化，需要重置当天的完成状态
                if (oldTaskCount !== newTaskCount || newTasksRaw !== this.state.data.tasks.join(',')) {
                    this.state.data.completionHistory[this.state.today] = new Array(newTaskCount).fill(false);
                }
                
                this.saveData();
                this.renderAll();
                alert("任务列表已更新！");
            }
        },

        openFocusChallenge() {
            alert("专注力挑战功能正在开发中...");
        },

        openTodayTasksManager() {
            alert("今日任务管理功能正在开发中...");
        },

        openStatistics() {
            alert("统计功能正在开发中...");
        },

        resetTasks() {
            if (confirm("确定要重置今天的所有任务状态吗？")) {
                const totalTasks = this.state.data.tasks.length;
                this.state.data.completionHistory[this.state.today] = new Array(totalTasks).fill(false);
                this.saveData();
                this.renderAll();
                alert("今日任务已重置。");
            }
        }
    };

    // 启动应用
    App.init();

    // 将App暴露到全局，以便同步脚本可以访问
    window.TaskManager = App;
});