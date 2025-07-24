// 统计页面功能模块
class StatisticsManager {
    constructor() {
        this.storage = window.taskStorage;
        this.currentPeriod = 3;
        this.init();
    }

    // 初始化统计页面
    init() {
        this.updateSummary();
        this.renderCharts();
        this.renderDetailsTable();
        this.renderAchievements();
    }

    // 更新统计摘要
    updateSummary() {
        const todayData = this.getTodayStats();
        const weekData = this.getWeekStats();
        const monthData = this.getMonthStats();

        // 今日完成
        const todayElement = document.getElementById('today-completed');
        if (todayElement) {
            todayElement.textContent = `${todayData.completed}/${todayData.total}`;
        }

        // 本周平均
        const weekElement = document.getElementById('week-average');
        if (weekElement) {
            weekElement.textContent = `${weekData.average}%`;
        }

        // 本月总计
        const monthElement = document.getElementById('month-total');
        if (monthElement) {
            monthElement.textContent = monthData.totalCompleted;
        }
    }

    // 获取今日统计
    getTodayStats() {
        const completion = this.storage.getTodayCompletion();
        const completed = completion.filter(Boolean).length;
        const total = completion.length;
        return { completed, total, percentage: total > 0 ? Math.round((completed / total) * 100) : 0 };
    }

    // 获取本周统计
    getWeekStats() {
        const weekData = this.storage.getHistoryData(7);
        const totalPercentage = weekData.reduce((sum, day) => sum + day.percentage, 0);
        const average = weekData.length > 0 ? Math.round(totalPercentage / weekData.length) : 0;
        return { average, data: weekData };
    }

    // 获取本月统计
    getMonthStats() {
        const monthData = this.storage.getHistoryData(30);
        const totalCompleted = monthData.reduce((sum, day) => sum + day.completed, 0);
        const totalTasks = monthData.reduce((sum, day) => sum + day.total, 0);
        return { totalCompleted, totalTasks, data: monthData };
    }

    // 切换时间段
    changePeriod(period) {
        this.currentPeriod = period;
        
        // 更新按钮状态
        document.querySelectorAll('.time-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-period="${period}"]`).classList.add('active');

        // 重新渲染图表和表格
        this.renderCharts();
        this.renderDetailsTable();
    }

    // 渲染图表
    renderCharts() {
        this.renderCompletionChart();
        this.renderDailyChart();
    }

    // 渲染完成率趋势图
    renderCompletionChart() {
        const chartElement = document.getElementById('completion-chart');
        if (!chartElement) return;

        const data = this.storage.getHistoryData(this.currentPeriod);
        
        if (data.length === 0) {
            chartElement.innerHTML = this.getEmptyChartHTML('暂无数据');
            return;
        }

        const maxPercentage = Math.max(...data.map(d => d.percentage), 100);
        
        chartElement.innerHTML = data.map(day => {
            const height = maxPercentage > 0 ? (day.percentage / maxPercentage) * 100 : 0;
            const date = new Date(day.date);
            const label = `${date.getMonth() + 1}/${date.getDate()}`;
            
            return `
                <div class="chart-bar">
                    <div class="bar" style="height: ${height}%">
                        <div class="bar-value">${day.percentage}%</div>
                    </div>
                    <div class="bar-label">${label}</div>
                </div>
            `;
        }).join('');
    }

    // 渲染每日完成数量图
    renderDailyChart() {
        const chartElement = document.getElementById('daily-chart');
        if (!chartElement) return;

        const data = this.storage.getHistoryData(this.currentPeriod);
        
        if (data.length === 0) {
            chartElement.innerHTML = this.getEmptyChartHTML('暂无数据');
            return;
        }

        const maxCompleted = Math.max(...data.map(d => d.completed), 1);
        
        chartElement.innerHTML = data.map(day => {
            const height = maxCompleted > 0 ? (day.completed / maxCompleted) * 100 : 0;
            const date = new Date(day.date);
            const label = `${date.getMonth() + 1}/${date.getDate()}`;
            
            return `
                <div class="chart-bar">
                    <div class="bar" style="height: ${Math.max(height, 4)}%">
                        <div class="bar-value">${day.completed}</div>
                    </div>
                    <div class="bar-label">${label}</div>
                </div>
            `;
        }).join('');
    }

    // 渲染详细数据表格
    renderDetailsTable() {
        const tableElement = document.getElementById('details-table');
        if (!tableElement) return;

        const data = this.storage.getHistoryData(this.currentPeriod);
        
        if (data.length === 0) {
            tableElement.innerHTML = `
                <div class="empty-state">
                    <div class="empty-state-icon">📊</div>
                    <div class="empty-state-text">暂无统计数据</div>
                    <div class="empty-state-desc">完成一些任务后就能看到详细统计了</div>
                </div>
            `;
            return;
        }

        const tableHTML = `
            <table class="data-table">
                <thead>
                    <tr>
                        <th>日期</th>
                        <th>完成数量</th>
                        <th>总任务数</th>
                        <th>完成率</th>
                        <th>状态</th>
                    </tr>
                </thead>
                <tbody>
                    ${data.map(day => {
                        const date = new Date(day.date);
                        const dateStr = `${date.getMonth() + 1}月${date.getDate()}日`;
                        const weekday = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][date.getDay()];
                        
                        let percentageClass = 'percentage-low';
                        let statusText = '需努力';
                        let statusIcon = '😔';
                        
                        if (day.percentage >= 80) {
                            percentageClass = 'percentage-high';
                            statusText = '优秀';
                            statusIcon = '🎉';
                        } else if (day.percentage >= 60) {
                            percentageClass = 'percentage-medium';
                            statusText = '良好';
                            statusIcon = '😊';
                        } else if (day.percentage >= 40) {
                            percentageClass = 'percentage-medium';
                            statusText = '一般';
                            statusIcon = '😐';
                        }
                        
                        return `
                            <tr>
                                <td>${dateStr} ${weekday}</td>
                                <td>${day.completed}</td>
                                <td>${day.total}</td>
                                <td class="percentage-cell ${percentageClass}">${day.percentage}%</td>
                                <td>${statusIcon} ${statusText}</td>
                            </tr>
                        `;
                    }).join('')}
                </tbody>
            </table>
        `;
        
        tableElement.innerHTML = tableHTML;
    }

    // 渲染成就徽章
    renderAchievements() {
        const achievementsElement = document.getElementById('achievements-grid');
        if (!achievementsElement) return;

        const achievements = this.calculateAchievements();
        
        achievementsElement.innerHTML = achievements.map(achievement => `
            <div class="achievement-card ${achievement.earned ? 'earned' : 'not-earned'}">
                <div class="achievement-icon">${achievement.icon}</div>
                <div class="achievement-info">
                    <div class="achievement-title">${achievement.title}</div>
                    <div class="achievement-desc">${achievement.description}</div>
                </div>
            </div>
        `).join('');
    }

    // 计算成就
    calculateAchievements() {
        const weekData = this.storage.getHistoryData(7);
        const monthData = this.storage.getHistoryData(30);
        const todayStats = this.getTodayStats();
        
        // 计算连续完成天数
        let consecutiveDays = 0;
        for (let i = weekData.length - 1; i >= 0; i--) {
            if (weekData[i].percentage === 100) {
                consecutiveDays++;
            } else {
                break;
            }
        }
        
        // 计算本周完成率
        const weekAverage = weekData.length > 0 ? 
            weekData.reduce((sum, day) => sum + day.percentage, 0) / weekData.length : 0;
        
        // 计算本月总完成任务数
        const monthTotalCompleted = monthData.reduce((sum, day) => sum + day.completed, 0);
        
        // 计算完美天数（100%完成率）
        const perfectDays = monthData.filter(day => day.percentage === 100).length;

        return [
            {
                title: '今日之星',
                description: '今天完成所有任务',
                icon: '⭐',
                earned: todayStats.percentage === 100
            },
            {
                title: '坚持不懈',
                description: '连续3天完成所有任务',
                icon: '🔥',
                earned: consecutiveDays >= 3
            },
            {
                title: '本周英雄',
                description: '本周平均完成率超过80%',
                icon: '🏆',
                earned: weekAverage >= 80
            },
            {
                title: '月度冠军',
                description: '本月完成超过100个任务',
                icon: '👑',
                earned: monthTotalCompleted >= 100
            },
            {
                title: '完美主义者',
                description: '本月有10天达到100%完成率',
                icon: '💎',
                earned: perfectDays >= 10
            },
            {
                title: '勤奋小蜜蜂',
                description: '本周每天都有完成任务',
                icon: '🐝',
                earned: weekData.every(day => day.completed > 0)
            },
            {
                title: '进步之星',
                description: '本周完成率呈上升趋势',
                icon: '📈',
                earned: this.isProgressTrend(weekData)
            },
            {
                title: '全能选手',
                description: '本月完成率从未低于50%',
                icon: '🌟',
                earned: monthData.every(day => day.percentage >= 50 || day.total === 0)
            }
        ];
    }

    // 判断是否为进步趋势
    isProgressTrend(data) {
        if (data.length < 3) return false;
        
        const recent3 = data.slice(-3);
        return recent3[2].percentage > recent3[0].percentage && 
               recent3[1].percentage >= recent3[0].percentage;
    }

    // 获取空图表HTML
    getEmptyChartHTML(message) {
        return `
            <div class="empty-state">
                <div class="empty-state-icon">📊</div>
                <div class="empty-state-text">${message}</div>
                <div class="empty-state-desc">完成一些任务后就能看到图表了</div>
            </div>
        `;
    }

    // 显示提示消息
    showToast(message, type = 'info', duration = 3000) {
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

function changePeriod(period) {
    if (window.statisticsManager) {
        window.statisticsManager.changePeriod(period);
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    window.statisticsManager = new StatisticsManager();
});

// 处理页面可见性变化
document.addEventListener('visibilitychange', function() {
    if (!document.hidden && window.statisticsManager) {
        window.statisticsManager.updateSummary();
        window.statisticsManager.renderCharts();
        window.statisticsManager.renderDetailsTable();
        window.statisticsManager.renderAchievements();
    }
});