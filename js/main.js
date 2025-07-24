// 主要功能模块
class TaskManager {
    constructor() {
        this.storage = window.taskStorage;
        this.init();
    }

    // 初始化应用
    init() {
        this.updateDateDisplay();
        this.updateUserGreeting();
        this.renderTasks();
        this.updateProgress();
        
        // 每分钟更新一次日期显示
        setInterval(() => {
            this.updateDateDisplay();
        }, 60000);
    }

    // 更新日期显示
    updateDateDisplay() {
        const dateElement = document.getElementById('current-date');
        if (dateElement) {
            dateElement.textContent = this.storage.getChineseDateString();
        }
    }

    // 更新用户问候
    updateUserGreeting() {
        const usernameElement = document.getElementById('username');
        if (usernameElement) {
            usernameElement.textContent = this.storage.getUsername();
        }
    }

    // 渲染任务卡片
    renderTasks() {
        const tasksGrid = document.getElementById('tasks-grid');
        if (!tasksGrid) return;

        const tasks = this.storage.getTasks();
        const completion = this.storage.getTodayCompletion();
        
        tasksGrid.innerHTML = '';

        tasks.forEach((task, index) => {
            const isCompleted = completion[index] || false;
            const taskCard = this.createTaskCard(task, index, isCompleted);
            tasksGrid.appendChild(taskCard);
        });
    }

    // 创建任务卡片
    createTaskCard(taskName, index, isCompleted) {
        const card = document.createElement('div');
        card.className = `task-card ${isCompleted ? 'completed' : ''}`;
        card.setAttribute('data-task', taskName);
        
        card.innerHTML = `
            <div class="task-icon"></div>
            <div class="task-title">${taskName}</div>
            <button class="complete-btn ${isCompleted ? 'completed' : ''}" 
                    onclick="taskManager.toggleTask(${index})">
                <span class="btn-text">
                    ${isCompleted ? '✅ 已完成' : '⭕ 点击完成'}
                </span>
            </button>
        `;

        return card;
    }

    // 切换任务完成状态
    toggleTask(taskIndex) {
        const button = event.target.closest('.complete-btn');
        const card = event.target.closest('.task-card');
        
        // 添加点击动画
        button.classList.add('clicked');
        setTimeout(() => button.classList.remove('clicked'), 300);

        // 切换完成状态
        this.storage.toggleTaskCompletion(taskIndex);
        
        // 获取新的完成状态
        const completion = this.storage.getTodayCompletion();
        const isCompleted = completion[taskIndex];

        // 更新卡片样式
        if (isCompleted) {
            card.classList.add('completing');
            setTimeout(() => {
                card.classList.add('completed');
                card.classList.remove('completing');
                button.classList.add('completed');
                button.querySelector('.btn-text').innerHTML = '✅ 已完成';
            }, 300);
            
            // 显示庆祝动画
            this.showCelebration();
        } else {
            card.classList.remove('completed');
            button.classList.remove('completed');
            button.querySelector('.btn-text').innerHTML = '⭕ 点击完成';
        }

        // 更新进度
        setTimeout(() => {
            this.updateProgress();
        }, 400);
    }

    // 更新进度显示
    updateProgress() {
        const completion = this.storage.getTodayCompletion();
        const completedCount = completion.filter(Boolean).length;
        const totalCount = completion.length;
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

        // 更新提示消息
        this.updateProgressMessage(completedCount, totalCount);
        
        // 更新徽章显示
        this.updateBadgesDisplay();
    }

    // 更新进度提示消息
    updateProgressMessage(completed, total) {
        const messageElement = document.getElementById('progress-message');
        if (!messageElement) return;

        let message = '';
        const remaining = total - completed;

        if (completed === 0) {
            const greetings = [
                '今天你还没开始任务，该加油喽！',
                '新的一天开始了，让我们一起努力吧！',
                '今天的任务等着你呢，加油！'
            ];
            message = greetings[Math.floor(Math.random() * greetings.length)];
        } else if (completed === total) {
            const celebrations = [
                '真厉害，你完成了全部任务！🎉',
                '太棒了！今天的任务全部完成！👏',
                '你真是太优秀了！所有任务都完成了！🌟'
            ];
            message = celebrations[Math.floor(Math.random() * celebrations.length)];
        } else {
            const encouragements = [
                `真棒，你已经完成了${completed}个任务，还剩${remaining}个就完成了！`,
                `继续加油！已经完成${completed}个，还有${remaining}个任务等着你！`,
                `做得很好！完成了${completed}个任务，再坚持一下就全部完成了！`
            ];
            message = encouragements[Math.floor(Math.random() * encouragements.length)];
        }

        messageElement.textContent = message;
        
        // 添加动画效果
        messageElement.style.animation = 'none';
        setTimeout(() => {
            messageElement.style.animation = 'pulse 0.5s ease';
        }, 10);
    }

    // 显示庆祝动画
    showCelebration() {
        const completion = this.storage.getTodayCompletion();
        const completedCount = completion.filter(Boolean).length;
        const totalCount = completion.length;

        // 只有在完成所有任务时才显示庆祝动画
        if (completedCount === totalCount && totalCount > 0) {
            const celebration = document.getElementById('celebration');
            if (celebration) {
                celebration.classList.add('show');
                
                // 3秒后自动隐藏
                setTimeout(() => {
                    celebration.classList.remove('show');
                }, 3000);
                
                // 点击隐藏
                celebration.onclick = () => {
                    celebration.classList.remove('show');
                };
            }
        }
    }

    // 重置今日任务
    resetTodayTasks() {
        if (confirm('确定要重置今天的所有任务吗？这将清除今天的完成记录。')) {
            this.storage.resetTodayTasks();
            this.renderTasks();
            this.updateProgress();
            
            // 显示重置成功提示
            this.showToast('今日任务已重置！');
        }
    }

    // 更新徽章显示
    updateBadgesDisplay() {
        const achievements = this.calculateTodayAchievements();
        const earnedBadges = achievements.filter(badge => badge.earned);
        
        const badgesSection = document.getElementById('badges-section');
        const badgesContainer = document.getElementById('badges-container');
        
        if (!badgesSection || !badgesContainer) return;
        
        if (earnedBadges.length > 0) {
            badgesSection.style.display = 'block';
            badgesContainer.innerHTML = earnedBadges.map(badge => `
                <div class="badge-item">
                    <span class="badge-icon">${badge.icon}</span>
                    <span class="badge-title">${badge.title}</span>
                </div>
            `).join('');
        } else {
            badgesSection.style.display = 'none';
        }
    }

    // 计算今日成就
    calculateTodayAchievements() {
        const completion = this.storage.getTodayCompletion();
        const completedCount = completion.filter(Boolean).length;
        const totalCount = completion.length;
        const percentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;
        
        // 获取历史数据用于连续天数计算
        const weekData = this.storage.getHistoryData(7);
        let consecutiveDays = 0;
        for (let i = weekData.length - 1; i >= 0; i--) {
            if (weekData[i].percentage === 100) {
                consecutiveDays++;
            } else {
                break;
            }
        }

        return [
            {
                title: '今日之星',
                icon: '⭐',
                earned: percentage === 100
            },
            {
                title: '半程英雄',
                icon: '🎯',
                earned: percentage >= 50 && percentage < 100
            },
            {
                title: '起步达人',
                icon: '🚀',
                earned: completedCount >= 1 && percentage < 50
            },
            {
                title: '坚持不懈',
                icon: '🔥',
                earned: consecutiveDays >= 2
            },
            {
                title: '勤奋小蜜蜂',
                icon: '🐝',
                earned: completedCount >= Math.ceil(totalCount * 0.8)
            }
        ];
    }

    // 显示提示消息
    showToast(message, duration = 2000) {
        // 创建提示元素
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.textContent = message;
        toast.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 15px 25px;
            border-radius: 10px;
            font-size: 1rem;
            z-index: 1001;
            animation: fadeInOut ${duration}ms ease;
        `;

        // 添加CSS动画
        if (!document.querySelector('#toast-style')) {
            const style = document.createElement('style');
            style.id = 'toast-style';
            style.textContent = `
                @keyframes fadeInOut {
                    0% { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
                    20% { opacity: 1; transform: translate(-50%, -50%) scale(1); }
                    80% { opacity: 1; transform: translate(-50%, -50%) scale(1); }
                    100% { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
                }
            `;
            document.head.appendChild(style);
        }

        document.body.appendChild(toast);
        
        // 自动移除
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, duration);
    }
}

// 全局函数
function openEditTasks() {
    window.location.href = 'edit-tasks.html';
}

function openFocusChallenge() {
    window.location.href = 'focus-challenge.html';
}

function openStatistics() {
    window.location.href = 'statistics.html';
}

function resetTasks() {
    if (window.taskManager) {
        window.taskManager.resetTodayTasks();
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    window.taskManager = new TaskManager();
});

// 处理页面可见性变化，当页面重新可见时更新数据
document.addEventListener('visibilitychange', function() {
    if (!document.hidden && window.taskManager) {
        window.taskManager.updateDateDisplay();
        window.taskManager.renderTasks();
        window.taskManager.updateProgress();
    }
});