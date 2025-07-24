// 编辑任务页面功能模块
class TaskEditor {
    constructor() {
        this.storage = window.taskStorage;
        this.draggedElement = null;
        this.init();
    }

    // 初始化
    init() {
        this.loadUsername();
        this.renderTasksList();
        this.renderTodayTasks();
        this.setupEventListeners();
        this.initDateInputs();
    }

    // 初始化日期输入框
    initDateInputs() {
        const today = new Date().toISOString().split('T')[0];
        const dueDateInput = document.getElementById('due-date');
        const startDateInput = document.getElementById('start-date');
        
        if (dueDateInput) {
            dueDateInput.min = today;
            dueDateInput.value = today;
        }
        
        if (startDateInput) {
            startDateInput.value = today;
        }
    }

    // 设置事件监听器
    setupEventListeners() {
        // 任务输入框回车事件
        const taskInput = document.getElementById('new-task-input');
        if (taskInput) {
            taskInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    this.confirmAddTask();
                } else if (e.key === 'Escape') {
                    this.cancelAddTask();
                }
            });
        }
    }

    // 加载用户名
    loadUsername() {
        const usernameInput = document.getElementById('username-input');
        if (usernameInput) {
            usernameInput.value = this.storage.getUsername();
        }
    }

    // 渲染任务列表
    renderTasksList() {
        const tasksList = document.getElementById('tasks-list');
        if (!tasksList) return;

        const tasks = this.storage.getTasks();
        
        if (tasks.length === 0) {
            tasksList.innerHTML = `
                <div class="empty-state">
                    <p>还没有任务，点击"添加任务"开始创建吧！</p>
                </div>
            `;
            return;
        }

        tasksList.innerHTML = tasks.map((task, index) => `
            <div class="task-item" draggable="true" data-index="${index}">
                <div class="drag-handle">⋮⋮</div>
                <div class="task-content">
                    <span class="task-name">${task}</span>
                </div>
                <div class="task-actions">
                    <button class="edit-btn" onclick="taskEditor.editTask(${index})">
                        <span class="icon">✏️</span>
                    </button>
                    <button class="delete-btn" onclick="taskEditor.deleteTask(${index})">
                        <span class="icon">🗑️</span>
                    </button>
                </div>
            </div>
        `).join('');

        // 添加拖拽事件
        this.addDragEvents();
    }

    // 渲染今日任务列表
    renderTodayTasks() {
        const todayTasksList = document.getElementById('today-tasks-list');
        if (!todayTasksList) return;

        const todayTasks = this.storage.getTodayTasks();
        
        if (todayTasks.length === 0) {
            todayTasksList.innerHTML = `
                <div class="empty-state">
                    <p>今日没有任务</p>
                </div>
            `;
            return;
        }

        todayTasksList.innerHTML = todayTasks.map((task, index) => `
            <div class="today-task-item ${task.enabled ? '' : 'disabled'}">
                <div class="today-task-info">
                    <span class="task-type-badge ${task.type}">${this.getTaskTypeLabel(task.type)}</span>
                    <span class="task-name">${task.name}</span>
                    ${task.dueDate ? `<small>截止：${task.dueDate}</small>` : ''}
                </div>
                <div class="today-task-actions">
                    <button class="toggle-btn ${task.enabled ? '' : 'disabled'}" 
                            onclick="taskEditor.toggleTodayTask('${task.id}')">
                        ${task.enabled ? '禁用' : '启用'}
                    </button>
                    ${task.type !== 'daily' ? `
                        <button class="remove-btn" onclick="taskEditor.removeTodayTask('${task.id}')">
                            删除
                        </button>
                    ` : ''}
                </div>
            </div>
        `).join('');
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

    // 添加拖拽事件
    addDragEvents() {
        const taskItems = document.querySelectorAll('.task-item');
        
        taskItems.forEach(item => {
            item.addEventListener('dragstart', (e) => {
                this.draggedElement = item;
                item.classList.add('dragging');
                e.dataTransfer.effectAllowed = 'move';
            });

            item.addEventListener('dragend', () => {
                item.classList.remove('dragging');
                this.draggedElement = null;
            });

            item.addEventListener('dragover', (e) => {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'move';
            });

            item.addEventListener('dragenter', (e) => {
                e.preventDefault();
                if (item !== this.draggedElement) {
                    item.classList.add('drag-over');
                }
            });

            item.addEventListener('dragleave', () => {
                item.classList.remove('drag-over');
            });

            item.addEventListener('drop', (e) => {
                e.preventDefault();
                item.classList.remove('drag-over');
                
                if (this.draggedElement && item !== this.draggedElement) {
                    const fromIndex = parseInt(this.draggedElement.getAttribute('data-index'));
                    const toIndex = parseInt(item.getAttribute('data-index'));
                    this.reorderTasks(fromIndex, toIndex);
                }
            });
        });
    }

    // 重新排序任务
    reorderTasks(fromIndex, toIndex) {
        const tasks = this.storage.getTasks();
        const completion = this.storage.getTodayCompletion();
        
        // 移动任务
        const movedTask = tasks.splice(fromIndex, 1)[0];
        tasks.splice(toIndex, 0, movedTask);
        
        // 移动完成状态
        if (completion.length > Math.max(fromIndex, toIndex)) {
            const movedCompletion = completion.splice(fromIndex, 1)[0];
            completion.splice(toIndex, 0, movedCompletion);
            this.storage.setTodayCompletion(completion);
        }
        
        // 更新所有历史记录
        const data = this.storage.getData();
        const history = data.completionHistory || {};
        
        Object.keys(history).forEach(date => {
            if (history[date] && history[date].length > Math.max(fromIndex, toIndex)) {
                const movedStatus = history[date].splice(fromIndex, 1)[0];
                history[date].splice(toIndex, 0, movedStatus);
            }
        });
        
        // 保存更新
        this.storage.setTasks(tasks);
        data.completionHistory = history;
        this.storage.saveData(data);
        
        // 重新渲染
        this.renderTasksList();
        this.showToast('任务顺序已更新！', 'success');
    }

    // 任务类型改变事件
    onTaskTypeChange() {
        const taskType = document.getElementById('task-type-select').value;
        const onetimeConfig = document.getElementById('onetime-config');
        const routineConfig = document.getElementById('routine-config');
        
        // 隐藏所有配置
        if (onetimeConfig) onetimeConfig.style.display = 'none';
        if (routineConfig) routineConfig.style.display = 'none';
        
        // 显示对应配置
        if (taskType === 'oneTime' && onetimeConfig) {
            onetimeConfig.style.display = 'block';
        } else if (taskType === 'routine' && routineConfig) {
            routineConfig.style.display = 'block';
        }
    }

    // 频率改变事件
    onFrequencyChange() {
        const frequency = document.getElementById('frequency-select').value;
        const weeklyConfig = document.getElementById('weekly-config');
        const monthlyConfig = document.getElementById('monthly-config');
        const intervalConfig = document.getElementById('interval-config');
        
        // 隐藏所有配置
        if (weeklyConfig) weeklyConfig.style.display = 'none';
        if (monthlyConfig) monthlyConfig.style.display = 'none';
        if (intervalConfig) intervalConfig.style.display = 'none';
        
        // 显示对应配置
        if (frequency === 'weekly' && weeklyConfig) {
            weeklyConfig.style.display = 'block';
        } else if (frequency === 'monthly' && monthlyConfig) {
            monthlyConfig.style.display = 'block';
        } else if (frequency === 'interval' && intervalConfig) {
            intervalConfig.style.display = 'block';
        }
    }

    // 显示添加任务表单
    showAddTaskForm() {
        const form = document.getElementById('add-task-form');
        if (form) {
            form.style.display = 'block';
            const input = document.getElementById('new-task-input');
            if (input) input.focus();
        }
    }

    // 隐藏添加任务表单
    hideAddTaskForm() {
        const form = document.getElementById('add-task-form');
        if (form) {
            form.style.display = 'none';
            this.clearAddTaskForm();
        }
    }

    // 清空添加任务表单
    clearAddTaskForm() {
        const elements = {
            'new-task-input': '',
            'task-type-select': 'daily',
            'due-date': new Date().toISOString().split('T')[0],
            'task-description': '',
            'frequency-select': 'weekly',
            'month-days': '',
            'interval-days': '',
            'start-date': new Date().toISOString().split('T')[0],
            'routine-description': ''
        };
        
        Object.keys(elements).forEach(id => {
            const element = document.getElementById(id);
            if (element) element.value = elements[id];
        });
        
        // 清空周选择
        document.querySelectorAll('.weekdays-selector input[type="checkbox"]').forEach(cb => {
            cb.checked = false;
        });
        
        // 重置配置显示
        this.onTaskTypeChange();
    }

    // 确认添加任务
    confirmAddTask() {
        const taskNameInput = document.getElementById('new-task-input');
        const taskTypeSelect = document.getElementById('task-type-select');
        
        if (!taskNameInput || !taskTypeSelect) return;
        
        const taskName = taskNameInput.value.trim();
        const taskType = taskTypeSelect.value;
        
        if (!taskName) {
            this.showToast('请输入任务名称', 'error');
            return;
        }

        try {
            if (taskType === 'daily') {
                this.addDailyTask(taskName);
            } else if (taskType === 'oneTime') {
                this.addOneTimeTask(taskName);
            } else if (taskType === 'routine') {
                this.addRoutineTask(taskName);
            }
            
            this.hideAddTaskForm();
            this.renderTasksList();
            this.renderTodayTasks();
            this.showToast('任务添加成功！', 'success');
        } catch (error) {
            this.showToast('添加任务失败：' + error.message, 'error');
        }
    }

    // 添加每日任务
    addDailyTask(taskName) {
        const tasks = this.storage.getTasks();
        tasks.push(taskName);
        this.storage.setTasks(tasks);
        
        // 更新每日任务模板
        this.storage.updateDailyTemplate(tasks);
    }

    // 添加一次性任务
    addOneTimeTask(taskName) {
        const dueDateInput = document.getElementById('due-date');
        const descriptionInput = document.getElementById('task-description');
        
        const dueDate = dueDateInput ? dueDateInput.value : '';
        const description = descriptionInput ? descriptionInput.value.trim() : '';
        
        if (!dueDate) {
            throw new Error('请选择截止日期');
        }
        
        this.storage.addOneTimeTask(taskName, dueDate, description);
    }

    // 添加例行任务
    addRoutineTask(taskName) {
        const frequencySelect = document.getElementById('frequency-select');
        const descriptionInput = document.getElementById('routine-description');
        
        if (!frequencySelect) {
            throw new Error('请选择执行频率');
        }
        
        const frequency = frequencySelect.value;
        const description = descriptionInput ? descriptionInput.value.trim() : '';
        
        let config = {};
        
        if (frequency === 'weekly') {
            const weekdays = Array.from(document.querySelectorAll('.weekdays-selector input[type="checkbox"]:checked'))
                .map(cb => parseInt(cb.value));
            
            if (weekdays.length === 0) {
                throw new Error('请选择执行日期');
            }
            
            config.weekdays = weekdays;
        } else if (frequency === 'monthly') {
            const monthDaysInput = document.getElementById('month-days');
            const monthDaysStr = monthDaysInput ? monthDaysInput.value.trim() : '';
            
            if (!monthDaysStr) {
                throw new Error('请输入执行日期');
            }
            
            const monthDays = monthDaysStr.split(',').map(d => parseInt(d.trim())).filter(d => d >= 1 && d <= 31);
            if (monthDays.length === 0) {
                throw new Error('请输入有效的日期（1-31）');
            }
            
            config.monthDays = monthDays;
        } else if (frequency === 'interval') {
            const intervalDaysInput = document.getElementById('interval-days');
            const startDateInput = document.getElementById('start-date');
            
            const intervalDays = intervalDaysInput ? parseInt(intervalDaysInput.value) : 0;
            const startDate = startDateInput ? startDateInput.value : '';
            
            if (!intervalDays || intervalDays < 1) {
                throw new Error('请输入有效的间隔天数');
            }
            
            if (!startDate) {
                throw new Error('请选择开始日期');
            }
            
            config.intervalDays = intervalDays;
            config.startDate = startDate;
        }
        
        this.storage.addRoutineTask(taskName, frequency, config, description);
    }

    // 取消添加任务
    cancelAddTask() {
        this.hideAddTaskForm();
    }

    // 编辑任务
    editTask(index) {
        const tasks = this.storage.getTasks();
        const currentName = tasks[index];
        const newName = prompt('编辑任务名称:', currentName);
        
        if (newName && newName.trim() && newName.trim() !== currentName) {
            tasks[index] = newName.trim();
            this.storage.setTasks(tasks);
            this.storage.updateDailyTemplate(tasks);
            this.renderTasksList();
            this.renderTodayTasks();
            this.showToast('任务已更新！', 'success');
        }
    }

    // 删除任务
    deleteTask(index) {
        const tasks = this.storage.getTasks();
        const taskName = tasks[index];
        
        if (confirm(`确定要删除任务"${taskName}"吗？\n这将删除所有相关的历史记录。`)) {
            tasks.splice(index, 1);
            this.storage.setTasks(tasks);
            this.storage.updateDailyTemplate(tasks);
            
            // 删除对应的完成记录
            const data = this.storage.getData();
            Object.keys(data.completionHistory || {}).forEach(date => {
                if (data.completionHistory[date] && data.completionHistory[date].length > index) {
                    data.completionHistory[date].splice(index, 1);
                }
            });
            
            // 删除对应的时间记录
            Object.keys(data.taskTimes || {}).forEach(date => {
                if (data.taskTimes[date] && data.taskTimes[date][index] !== undefined) {
                    delete data.taskTimes[date][index];
                    // 重新索引
                    const newTimes = {};
                    Object.keys(data.taskTimes[date]).forEach(oldIndex => {
                        const idx = parseInt(oldIndex);
                        if (idx > index) {
                            newTimes[idx - 1] = data.taskTimes[date][oldIndex];
                        } else if (idx < index) {
                            newTimes[idx] = data.taskTimes[date][oldIndex];
                        }
                    });
                    data.taskTimes[date] = newTimes;
                }
            });
            
            // 删除对应的执行记录
            Object.keys(data.taskExecutions || {}).forEach(date => {
                if (data.taskExecutions[date] && data.taskExecutions[date][index] !== undefined) {
                    delete data.taskExecutions[date][index];
                    // 重新索引
                    const newExecutions = {};
                    Object.keys(data.taskExecutions[date]).forEach(oldIndex => {
                        const idx = parseInt(oldIndex);
                        if (idx > index) {
                            newExecutions[idx - 1] = data.taskExecutions[date][oldIndex];
                        } else if (idx < index) {
                            newExecutions[idx] = data.taskExecutions[date][oldIndex];
                        }
                    });
                    data.taskExecutions[date] = newExecutions;
                }
            });
            
            this.storage.saveData(data);
            this.renderTasksList();
            this.renderTodayTasks();
            this.showToast('任务已删除！', 'success');
        }
    }

    // 切换今日任务启用状态
    toggleTodayTask(taskId) {
        this.storage.toggleTodayTaskEnabled(taskId);
        this.renderTodayTasks();
        this.showToast('任务状态已更新', 'success');
    }

    // 删除今日任务
    removeTodayTask(taskId) {
        if (confirm('确定要删除这个今日任务吗？')) {
            this.storage.removeTodayTask(taskId);
            this.renderTodayTasks();
            this.showToast('任务删除成功！', 'success');
        }
    }

    // 刷新今日任务
    refreshTodayTasks() {
        this.storage.refreshTodayTasks();
        this.renderTodayTasks();
        this.showToast('今日任务已刷新！', 'success');
    }

    // 重置所有任务
    resetAllTasks() {
        if (confirm('确定要重置今日所有任务的完成状态吗？')) {
            this.storage.resetTodayTasks();
            this.showToast('今日任务已重置！', 'success');
        }
    }

    // 恢复默认任务
    restoreDefaultTasks() {
        if (confirm('确定要恢复默认任务列表吗？这将覆盖当前的任务列表。')) {
            const defaultTasks = [
                '学而思数感小超市',
                '斑马思维',
                '核桃编程（学生端）',
                '英语阅读',
                '硬笔写字（30分钟）',
                '悦乐达打卡/作业',
                '暑假生活作业',
                '体育/运动（迪卡侬）'
            ];
            
            this.storage.setTasks(defaultTasks);
            this.storage.updateDailyTemplate(defaultTasks);
            this.renderTasksList();
            this.renderTodayTasks();
            this.showToast('默认任务已恢复！', 'success');
        }
    }

    // 导出数据
    exportData() {
        try {
            const data = this.storage.exportData();
            const blob = new Blob([data], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `任务数据_${new Date().toISOString().split('T')[0]}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            this.showToast('数据导出成功！', 'success');
        } catch (error) {
            this.showToast('导出失败：' + error.message, 'error');
        }
    }

    // 导入数据
    importData() {
        const modal = document.getElementById('import-modal');
        if (modal) {
            modal.style.display = 'flex';
            const textarea = document.getElementById('import-textarea');
            if (textarea) textarea.focus();
        }
    }

    // 确认导入
    confirmImport() {
        const textarea = document.getElementById('import-textarea');
        const jsonData = textarea ? textarea.value.trim() : '';
        
        if (!jsonData) {
            this.showToast('请输入要导入的数据', 'error');
            return;
        }
        
        try {
            const success = this.storage.importData(jsonData);
            if (success) {
                this.closeImportModal();
                this.renderTasksList();
                this.renderTodayTasks();
                this.loadUsername();
                this.showToast('数据导入成功！', 'success');
            } else {
                this.showToast('导入失败，请检查数据格式', 'error');
            }
        } catch (error) {
            this.showToast('导入失败：' + error.message, 'error');
        }
    }

    // 关闭导入模态框
    closeImportModal() {
        const modal = document.getElementById('import-modal');
        if (modal) {
            modal.style.display = 'none';
            const textarea = document.getElementById('import-textarea');
            if (textarea) textarea.value = '';
        }
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
            animation: slideInRight 0.3s ease;
        `;

        document.body.appendChild(toast);

        setTimeout(() => {
            toast.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                if (document.body.contains(toast)) {
                    document.body.removeChild(toast);
                }
            }, 300);
        }, duration);
    }
}

// 全局函数
function goBack() {
    window.location.href = 'index.html';
}

function saveUsername() {
    const username = document.getElementById('username-input').value.trim();
    if (username) {
        taskEditor.storage.setUsername(username);
        taskEditor.showToast('用户名已保存！', 'success');
    } else {
        taskEditor.showToast('请输入用户名', 'error');
    }
}

function addNewTask() {
    taskEditor.showAddTaskForm();
}

function confirmAddTask() {
    taskEditor.confirmAddTask();
}

function cancelAddTask() {
    taskEditor.cancelAddTask();
}

function onTaskTypeChange() {
    taskEditor.onTaskTypeChange();
}

function onFrequencyChange() {
    taskEditor.onFrequencyChange();
}

function refreshTodayTasks() {
    taskEditor.refreshTodayTasks();
}

function resetAllTasks() {
    taskEditor.resetAllTasks();
}

function restoreDefaultTasks() {
    taskEditor.restoreDefaultTasks();
}

function exportData() {
    taskEditor.exportData();
}

function importData() {
    taskEditor.importData();
}

function confirmImport() {
    taskEditor.confirmImport();
}

function closeImportModal() {
    taskEditor.closeImportModal();
}

// 创建全局实例
const taskEditor = new TaskEditor();