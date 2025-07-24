// 今日任务管理功能模块
class TodayTasksManager {
    constructor() {
        this.storage = window.taskStorage;
        this.init();
    }

    // 初始化
    init() {
        this.loadTasks();
        this.updateOverview();
    }

    // 加载任务列表
    loadTasks() {
        const tasksList = document.getElementById('tasks-list');
        if (!tasksList) return;

        const todayTasks = this.storage.getTodayTasks();
        
        if (todayTasks.length === 0) {
            tasksList.innerHTML = `
                <div class="empty-state">
                    <div class="empty-state-icon">📋</div>
                    <h3>今日暂无任务</h3>
                    <p>请先在编辑任务页面添加任务</p>
                </div>
            `;
            return;
        }

        tasksList.innerHTML = todayTasks.map((task, index) => {
            return this.createTaskItem(task, index);
        }).join('');
    }

    // 创建任务项
    createTaskItem(task, index) {
        const typeLabel = this.getTaskTypeLabel(task.type);
        const metaInfo = this.getTaskMetaInfo(task);
        
        return `
            <div class="task-item ${task.enabled ? '' : 'disabled'}">
                <div class="task-info">
                    <span class="task-type-badge ${task.type}">${typeLabel}</span>
                    <div class="task-details">
                        <div class="task-name">${task.name}</div>
                        <div class="task-meta">${metaInfo}</div>
                    </div>
                </div>
                <div class="task-actions">
                    <button class="toggle-btn ${task.enabled ? '' : 'disabled'}" 
                            onclick="todayTasksManager.toggleTask('${task.id}')">
                        ${task.enabled ? '禁用' : '启用'}
                    </button>
                    ${task.type !== 'daily' ? `
                        <button class="remove-btn" onclick="todayTasksManager.removeTask('${task.id}')">
                            删除
                        </button>
                    ` : ''}
                </div>
            </div>
        `;
    }

    // 获取任务类型标签
    getTaskTypeLabel(type) {
        const labels = {
            daily: '每日',
            oneTime: '一次性',
            routine: '例行'
        };
        return labels[type] || type;
    }

    // 获取任务元信息
    getTaskMetaInfo(task) {
        const metaItems = [];
        
        if (task.description) {
            metaItems.push(`描述: ${task.description}`);
        }
        
        if (task.dueDate) {
            const dueDate = new Date(task.dueDate);
            const today = new Date();
            const diffDays = Math.ceil((dueDate - today) / (1000 * 60 * 60 * 24));
            
            if (diffDays < 0) {
                metaItems.push(`⚠️ 已过期 ${Math.abs(diffDays)} 天`);
            } else if (diffDays === 0) {
                metaItems.push(`⏰ 今日截止`);
            } else if (diffDays <= 3) {
                metaItems.push(`⏳ 还剩 ${diffDays} 天`);
            } else {
                metaItems.push(`📅 截止: ${task.dueDate}`);
            }
        }
        
        if (task.frequency) {
            const frequencyLabels = {
                weekly: '每周',
                monthly: '每月',
                interval: '间隔'
            };
            metaItems.push(`🔄 ${frequencyLabels[task.frequency] || task.frequency}`);
        }
        
        return metaItems.length > 0 ? metaItems.join(' • ') : '无额外信息';
    }

    // 更新概览统计
    updateOverview() {
        const todayTasks = this.storage.getTodayTasks();
        const totalCount = todayTasks.length;
        const enabledCount = todayTasks.filter(task => task.enabled).length;
        const disabledCount = totalCount - enabledCount;

        const totalElement = document.getElementById('total-tasks-count');
        const enabledElement = document.getElementById('enabled-tasks-count');
        const disabledElement = document.getElementById('disabled-tasks-count');

        if (totalElement) totalElement.textContent = totalCount;
        if (enabledElement) enabledElement.textContent = enabledCount;
        if (disabledElement) disabledElement.textContent = disabledCount;
    }

    // 切换任务状态
    toggleTask(taskId) {
        if (this.storage.toggleTodayTaskEnabled(taskId)) {
            this.loadTasks();
            this.updateOverview();
            this.showToast('任务状态已更新', 'success');
        } else {
            this.showToast('操作失败，请重试', 'error');
        }
    }

    // 删除任务
    removeTask(taskId) {
        if (confirm('确定要删除这个任务吗？删除后将不会在今日任务中显示。')) {
            if (this.storage.removeTodayTask(taskId)) {
                this.loadTasks();
                this.updateOverview();
                this.showToast('任务删除成功', 'success');
            } else {
                this.showToast('删除失败，请重试', 'error');
            }
        }
    }

    // 启用所有任务
    enableAllTasks() {
        const todayTasks = this.storage.getTodayTasks();
        let changedCount = 0;
        
        todayTasks.forEach(task => {
            if (!task.enabled) {
                if (this.storage.toggleTodayTaskEnabled(task.id)) {
                    changedCount++;
                }
            }
        });
        
        if (changedCount > 0) {
            this.loadTasks();
            this.updateOverview();
            this.showToast(`已启用 ${changedCount} 个任务`, 'success');
        } else {
            this.showToast('所有任务都已启用', 'warning');
        }
    }

    // 恢复默认任务
    resetToDefault() {
        if (confirm('确定要恢复默认任务设置吗？这将重新生成今日任务列表。')) {
            this.storage.refreshTodayTasks();
            this.loadTasks();
            this.updateOverview();
            this.showToast('已恢复默认任务设置', 'success');
        }
    }

    // 刷新任务列表
    refreshTasks() {
        this.storage.refreshTodayTasks();
        this.loadTasks();
        this.updateOverview();
        this.showToast('任务列表已刷新', 'success');
    }

    // 显示提示消息
    showToast(message, type = 'success', duration = 3000) {
        const toast = document.getElementById('toast');
        if (!toast) return;

        toast.textContent = message;
        toast.className = `toast ${type}`;
        
        // 显示toast
        setTimeout(() => {
            toast.classList.add('show');
        }, 100);

        // 隐藏toast
        setTimeout(() => {
            toast.classList.remove('show');
        }, duration);
    }
}