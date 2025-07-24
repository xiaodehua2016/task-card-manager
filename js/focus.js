// 专注力挑战功能模块
class FocusChallenge {
    constructor() {
        this.storage = window.taskStorage;
        this.timer = null;
        this.startTime = null;
        this.pausedTime = 0;
        this.isRunning = false;
        this.targetDuration = 15 * 60; // 默认15分钟
        this.currentDuration = 0;
        this.init();
    }

    // 初始化
    init() {
        this.updateDisplay();
        this.loadTodayRecords();
        this.updateSummary();
        this.setupProgressRing();
    }

    // 设置进度环
    setupProgressRing() {
        const circle = document.getElementById('progress-circle');
        if (circle) {
            const radius = circle.r.baseVal.value;
            const circumference = radius * 2 * Math.PI;
            circle.style.strokeDasharray = `${circumference} ${circumference}`;
            circle.style.strokeDashoffset = circumference;
        }
    }

    // 切换计时器状态
    toggleTimer() {
        if (this.isRunning) {
            this.stopTimer();
        } else {
            this.startTimer();
        }
    }

    // 开始计时
    startTimer() {
        this.isRunning = true;
        this.startTime = Date.now() - this.pausedTime;
        
        // 更新按钮状态
        const btn = document.getElementById('start-stop-btn');
        const btnIcon = btn.querySelector('.btn-icon');
        const btnText = btn.querySelector('.btn-text');
        
        btn.classList.add('stop');
        btnIcon.textContent = '⏸️';
        btnText.textContent = '暂停';
        
        // 添加运行动画
        const timerDisplay = document.querySelector('.timer-display');
        const progressRing = document.querySelector('.progress-ring');
        timerDisplay.classList.add('running');
        progressRing.classList.add('active');
        
        // 开始计时循环
        this.timer = setInterval(() => {
            this.updateTimer();
        }, 100);
        
        this.showToast('开始专注！加油！', 'success');
    }

    // 停止计时
    stopTimer() {
        this.isRunning = false;
        this.pausedTime = Date.now() - this.startTime;
        
        if (this.timer) {
            clearInterval(this.timer);
            this.timer = null;
        }
        
        // 更新按钮状态
        const btn = document.getElementById('start-stop-btn');
        const btnIcon = btn.querySelector('.btn-icon');
        const btnText = btn.querySelector('.btn-text');
        
        btn.classList.remove('stop');
        btnIcon.textContent = '▶️';
        btnText.textContent = '继续专注';
        
        // 移除运行动画
        const timerDisplay = document.querySelector('.timer-display');
        const progressRing = document.querySelector('.progress-ring');
        timerDisplay.classList.remove('running');
        progressRing.classList.remove('active');
        
        this.showToast('专注暂停', 'info');
    }

    // 重置计时器
    resetTimer() {
        if (this.timer) {
            clearInterval(this.timer);
            this.timer = null;
        }
        
        this.isRunning = false;
        this.startTime = null;
        this.pausedTime = 0;
        this.currentDuration = 0;
        
        // 重置按钮状态
        const btn = document.getElementById('start-stop-btn');
        const btnIcon = btn.querySelector('.btn-icon');
        const btnText = btn.querySelector('.btn-text');
        
        btn.classList.remove('stop');
        btnIcon.textContent = '▶️';
        btnText.textContent = '开始专注';
        
        // 移除动画
        const timerDisplay = document.querySelector('.timer-display');
        const progressRing = document.querySelector('.progress-ring');
        timerDisplay.classList.remove('running');
        progressRing.classList.remove('active');
        
        // 更新显示
        this.updateDisplay();
        this.updateProgressRing(0);
        
        this.showToast('计时器已重置', 'info');
    }

    // 更新计时器
    updateTimer() {
        if (!this.isRunning || !this.startTime) return;
        
        this.currentDuration = Math.floor((Date.now() - this.startTime) / 1000);
        this.updateDisplay();
        this.updateProgressRing(this.currentDuration / this.targetDuration);
        
        // 检查是否完成
        if (this.currentDuration >= this.targetDuration) {
            this.completeChallenge();
        }
    }

    // 更新显示
    updateDisplay() {
        const timeText = document.getElementById('time-text');
        if (timeText) {
            timeText.textContent = this.formatTime(this.currentDuration);
        }
    }

    // 更新进度环
    updateProgressRing(progress) {
        const circle = document.getElementById('progress-circle');
        if (circle) {
            const radius = circle.r.baseVal.value;
            const circumference = radius * 2 * Math.PI;
            const offset = circumference - (progress * circumference);
            circle.style.strokeDashoffset = offset;
        }
    }

    // 完成挑战
    completeChallenge() {
        this.stopTimer();
        
        // 保存记录
        this.saveRecord(this.currentDuration);
        
        // 显示庆祝动画
        this.showCelebration();
        
        // 重置计时器
        setTimeout(() => {
            this.resetTimer();
        }, 3000);
    }

    // 显示庆祝动画
    showCelebration() {
        const celebration = document.getElementById('celebration');
        const completedTimeSpan = document.getElementById('completed-time');
        
        if (celebration && completedTimeSpan) {
            completedTimeSpan.textContent = this.formatTime(this.currentDuration);
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

    // 设置预设时间
    setPresetTime(minutes) {
        if (this.isRunning) {
            this.showToast('请先停止当前计时', 'error');
            return;
        }
        
        this.targetDuration = minutes * 60;
        this.resetTimer();
        
        // 更新按钮状态
        document.querySelectorAll('.preset-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');
        
        this.showToast(`已设置专注时间为${minutes}分钟`, 'success');
    }

    // 保存专注记录
    saveRecord(duration) {
        const data = this.storage.getData();
        const today = this.storage.getTodayString();
        
        if (!data.focusRecords) {
            data.focusRecords = {};
        }
        
        if (!data.focusRecords[today]) {
            data.focusRecords[today] = [];
        }
        
        const record = {
            startTime: new Date(this.startTime).toLocaleTimeString(),
            duration: duration,
            targetDuration: this.targetDuration,
            completed: duration >= this.targetDuration
        };
        
        data.focusRecords[today].push(record);
        this.storage.saveData(data);
        
        // 更新显示
        this.loadTodayRecords();
        this.updateSummary();
    }

    // 加载今日记录
    loadTodayRecords() {
        const data = this.storage.getData();
        const today = this.storage.getTodayString();
        const records = data.focusRecords?.[today] || [];
        
        const recordsList = document.getElementById('records-list');
        if (!recordsList) return;
        
        if (records.length === 0) {
            recordsList.innerHTML = `
                <div class="empty-state">
                    <p>今天还没有专注记录，开始你的第一次专注挑战吧！</p>
                </div>
            `;
            return;
        }
        
        recordsList.innerHTML = records.map((record, index) => `
            <div class="record-item">
                <div class="record-time">${record.startTime}</div>
                <div class="record-duration">
                    ${this.formatTime(record.duration)}
                    ${record.completed ? '✅' : '⏸️'}
                </div>
            </div>
        `).join('');
    }

    // 更新统计摘要
    updateSummary() {
        const data = this.storage.getData();
        const today = this.storage.getTodayString();
        const records = data.focusRecords?.[today] || [];
        
        const totalTime = records.reduce((sum, record) => sum + record.duration, 0);
        const focusCount = records.length;
        
        const totalTimeElement = document.getElementById('total-time');
        const focusCountElement = document.getElementById('focus-count');
        
        if (totalTimeElement) {
            totalTimeElement.textContent = `${Math.floor(totalTime / 60)}分钟`;
        }
        
        if (focusCountElement) {
            focusCountElement.textContent = `${focusCount}次`;
        }
    }

    // 格式化时间显示
    formatTime(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        
        if (hours > 0) {
            return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
        } else {
            return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
        }
    }

    // 显示提示消息
    showToast(message, type = 'info', duration = 2000) {
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.textContent = message;
        
        const colors = {
            success: '#48bb78',
            error: '#f56565',
            info: '#4299e1'
        };

        toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${colors[type] || colors.info};
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            font-size: 1rem;
            z-index: 1001;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            animation: slideInRight 0.3s ease, slideOutRight 0.3s ease ${duration - 300}ms forwards;
            max-width: 300px;
            word-wrap: break-word;
        `;

        // 添加CSS动画
        if (!document.querySelector('#toast-animations')) {
            const style = document.createElement('style');
            style.id = 'toast-animations';
            style.textContent = `
                @keyframes slideInRight {
                    from { transform: translateX(100%); opacity: 0; }
                    to { transform: translateX(0); opacity: 1; }
                }
                @keyframes slideOutRight {
                    from { transform: translateX(0); opacity: 1; }
                    to { transform: translateX(100%); opacity: 0; }
                }
            `;
            document.head.appendChild(style);
        }

        document.body.appendChild(toast);
        
        // 点击关闭
        toast.onclick = () => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        };

        // 自动移除
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, duration);
    }
}

// 全局函数
function goBack() {
    window.location.href = 'index.html';
}

function toggleTimer() {
    if (window.focusChallenge) {
        window.focusChallenge.toggleTimer();
    }
}

function resetTimer() {
    if (window.focusChallenge) {
        window.focusChallenge.resetTimer();
    }
}

function setPresetTime(minutes) {
    if (window.focusChallenge) {
        window.focusChallenge.setPresetTime(minutes);
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    window.focusChallenge = new FocusChallenge();
});

// 处理页面可见性变化
document.addEventListener('visibilitychange', function() {
    if (!document.hidden && window.focusChallenge) {
        window.focusChallenge.loadTodayRecords();
        window.focusChallenge.updateSummary();
    }
});

// 防止页面刷新时丢失计时状态
window.addEventListener('beforeunload', function(e) {
    if (window.focusChallenge && window.focusChallenge.isRunning) {
        e.preventDefault();
        e.returnValue = '专注计时正在进行中，确定要离开吗？';
        return e.returnValue;
    }
});