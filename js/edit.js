// 编辑任务页面功能模块
class TaskEditor {
    constructor() {
        this.storage = window.taskStorage;
        this.draggedElement = null;
        this.currentEditIndex = null;
        this.init();
    }

    // 初始化
    init() {
        this.initializeDefaultTasks();
        this.loadUsername();
        this.renderTasksList();
        this.updateStats();
        this.setupEventListeners();
    }

    // 初始化默认任务
    initializeDefaultTasks() {
        const tasks = this.storage.getTasks();
        if (tasks.length === 0) {
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
            // 初始化今日任务完成状态
            const completion = new Array(defaultTasks.length).fill(false);
            this.storage.setTodayCompletion(completion);
        }
    }

    // 设置事件监听器
    setupEventListeners() {
        // 模态框点击外部关闭
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.hideAddTaskModal();
                this.hideEditTaskModal();
            }
        });

        // 键盘事件
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.hideAddTaskModal();
                this.hideEditTaskModal();
            }
        });
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
        const tasksList = document.getElementById('tasksContainer');
        if (!tasksList) return;

        const tasks = this.storage.getTasks();
        this.updateStats(); // 更新统计信息
        
        if (tasks.length === 0) {
            tasksList.innerHTML = `
                <div class="empty-state">
                    <div class="empty-icon">📝</div>
                    <p>还没有任务，点击"添加新任务"开始创建吧！</p>
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

    // 更新统计信息
    updateStats() {
        const tasks = this.storage.getTasks();
        
        // 更新总任务数
        const totalTasksEl = document.getElementById('totalTasks');
        if (totalTasksEl) totalTasksEl.textContent = tasks.length;
        
        // 更新每日任务数（这里简化为总任务数，因为大部分是每日任务）
        const dailyTasksEl = document.getElementById('dailyTasks');
        if (dailyTasksEl) dailyTasksEl.textContent = tasks.length;
        
        // 更新活跃任务数
        const activeTasksEl = document.getElementById('activeTasks');
        if (activeTasksEl) activeTasksEl.textContent = tasks.length;
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
        this.storage.updateDailyTemplate(tasks);
        data.completionHistory = history;
        this.storage.saveData(data);
        
        // 重新渲染
        this.renderTasksList();
        this.showToast('任务顺序已更新！', 'success');
    }

    // 编辑任务
    editTask(index) {
        this.currentEditIndex = index;
        const tasks = this.storage.getTasks();
        const taskName = tasks[index];
        
        // 解析任务名称和图标
        const iconMatch = taskName.match(/^(\S+)\s+(.+)$/);
        const icon = iconMatch ? iconMatch[1] : '📚';
        const name = iconMatch ? iconMatch[2] : taskName;
        
        // 填充编辑表单
        document.getElementById('editTaskName').value = name;
        document.getElementById('editTaskIcon').value = icon;
        
        // 更新图标选择器
        document.querySelectorAll('#editTaskModal .icon-option').forEach(btn => {
            btn.classList.remove('selected');
            if (btn.getAttribute('data-icon') === icon) {
                btn.classList.add('selected');
            }
        });
        
        // 显示编辑模态框
        this.showEditTaskModal();
    }

    // 显示编辑任务模态框
    showEditTaskModal() {
        const modal = document.getElementById('editTaskModal');
        if (modal) {
            modal.style.display = 'flex';
            const input = document.getElementById('editTaskName');
            if (input) input.focus();
        }
    }

    // 隐藏编辑任务模态框
    hideEditTaskModal() {
        const modal = document.getElementById('editTaskModal');
        if (modal) {
            modal.style.display = 'none';
            this.clearEditTaskForm();
        }
    }

    // 清空编辑任务表单
    clearEditTaskForm() {
        const elements = ['editTaskName', 'editTaskType', 'editTaskDescription', 'editTaskIcon'];
        elements.forEach(id => {
            const element = document.getElementById(id);
            if (element) {
                if (id === 'editTaskType') {
                    element.value = 'daily';
                } else if (id === 'editTaskIcon') {
                    element.value = '📚';
                } else {
                    element.value = '';
                }
            }
        });

        // 重置图标选择
        document.querySelectorAll('#editTaskModal .icon-option').forEach(btn => {
            btn.classList.remove('selected');
        });
        document.querySelector('#editTaskModal .icon-option[data-icon="📚"]')?.classList.add('selected');
    }

    // 保存编辑的任务
    saveEditTask() {
        const taskName = document.getElementById('editTaskName')?.value.trim();
        const taskIcon = document.getElementById('editTaskIcon')?.value || '📚';

        if (!taskName) {
            this.showToast('请输入任务名称', 'error');
            return;
        }

        if (this.currentEditIndex === null) {
            this.showToast('编辑任务失败', 'error');
            return;
        }

        try {
            const tasks = this.storage.getTasks();
            const newTaskName = `${taskIcon} ${taskName}`;
            tasks[this.currentEditIndex] = newTaskName;
            this.storage.setTasks(tasks);
            this.storage.updateDailyTemplate(tasks);
            
            this.hideEditTaskModal();
            this.renderTasksList();
            this.showToast('任务已更新！', 'success');
        } catch (error) {
            this.showToast('更新任务失败：' + error.message, 'error');
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
            
            this.storage.saveData(data);
            this.renderTasksList();
            this.showToast('任务已删除！', 'success');
        }
    }

    // 显示添加任务模态框
    showAddTaskModal() {
        const modal = document.getElementById('addTaskModal');
        if (modal) {
            modal.style.display = 'flex';
            const input = document.getElementById('taskName');
            if (input) input.focus();
        }
    }

    // 隐藏添加任务模态框
    hideAddTaskModal() {
        const modal = document.getElementById('addTaskModal');
        if (modal) {
            modal.style.display = 'none';
            this.clearAddTaskForm();
        }
    }

    // 清空添加任务表单
    clearAddTaskForm() {
        const elements = ['taskName', 'taskType', 'taskDescription', 'taskIcon'];
        elements.forEach(id => {
            const element = document.getElementById(id);
            if (element) {
                if (id === 'taskType') {
                    element.value = 'daily';
                } else if (id === 'taskIcon') {
                    element.value = '📚';
                } else {
                    element.value = '';
                }
            }
        });

        // 重置图标选择
        document.querySelectorAll('#addTaskModal .icon-option').forEach(btn => {
            btn.classList.remove('selected');
        });
        document.querySelector('#addTaskModal .icon-option[data-icon="📚"]')?.classList.add('selected');
    }

    // 添加新任务
    addNewTask() {
        const taskName = document.getElementById('taskName')?.value.trim();
        const taskIcon = document.getElementById('taskIcon')?.value || '📚';

        if (!taskName) {
            this.showToast('请输入任务名称', 'error');
            return;
        }

        try {
            const tasks = this.storage.getTasks();
            const newTaskName = `${taskIcon} ${taskName}`;
            tasks.push(newTaskName);
            this.storage.setTasks(tasks);
            this.storage.updateDailyTemplate(tasks);
            
            this.hideAddTaskModal();
            this.renderTasksList();
            this.showToast('任务添加成功！', 'success');
        } catch (error) {
            this.showToast('添加任务失败：' + error.message, 'error');
        }
    }

    // 导出数据
    exportTasks() {
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
    importTasks() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.json';
        input.onchange = (e) => {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    try {
                        const success = this.storage.importData(e.target.result);
                        if (success) {
                            this.renderTasksList();
                            this.loadUsername();
                            this.showToast('数据导入成功！', 'success');
                        } else {
                            this.showToast('导入失败，请检查数据格式', 'error');
                        }
                    } catch (error) {
                        this.showToast('导入失败：' + error.message, 'error');
                    }
                };
                reader.readAsText(file);
            }
        };
        input.click();
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
            this.showToast('默认任务已恢复！', 'success');
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
// 返回上一页
function goBack() {
    // 优先返回首页，确保导航正确
    if (document.referrer && document.referrer.includes('index.html')) {
        window.history.back();
    } else {
        window.location.href = 'index.html';
    }
}

function showAddTaskModal() {
    taskEditor.showAddTaskModal();
}

function hideAddTaskModal() {
    taskEditor.hideAddTaskModal();
}

function addNewTask() {
    taskEditor.addNewTask();
}

function importTasks() {
    taskEditor.importTasks();
}

function exportTasks() {
    taskEditor.exportTasks();
}

function resetAllTasks() {
    taskEditor.resetAllTasks();
}

function restoreDefaultTasks() {
    taskEditor.restoreDefaultTasks();
}

function hideEditTaskModal() {
    taskEditor.hideEditTaskModal();
}

function saveEditTask() {
    taskEditor.saveEditTask();
}

// 图标选择功能
document.addEventListener('DOMContentLoaded', function() {
    // 图标选择器事件
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('icon-option')) {
            // 获取当前模态框
            const modal = e.target.closest('.modal');
            if (modal) {
                // 移除同一模态框内其他选中状态
                modal.querySelectorAll('.icon-option').forEach(btn => {
                    btn.classList.remove('selected');
                });
                
                // 添加选中状态
                e.target.classList.add('selected');
                
                // 更新对应的隐藏输入框的值
                const icon = e.target.getAttribute('data-icon');
                const iconInput = modal.querySelector('input[type="hidden"]');
                if (iconInput) {
                    iconInput.value = icon;
                }
            }
        }
    });
});

// 创建全局实例
const taskEditor = new TaskEditor();