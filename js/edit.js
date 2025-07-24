// 编辑页面功能模块
class TaskEditor {
    constructor() {
        this.storage = window.taskStorage;
        this.editingIndex = -1;
        this.init();
    }

    // 初始化编辑页面
    init() {
        this.loadUsername();
        this.renderTasksList();
        this.setupEventListeners();
    }

    // 加载用户名
    loadUsername() {
        const usernameInput = document.getElementById('username-input');
        if (usernameInput) {
            usernameInput.value = this.storage.getUsername();
        }
    }

    // 设置事件监听器
    setupEventListeners() {
        // 用户名输入框回车保存
        const usernameInput = document.getElementById('username-input');
        if (usernameInput) {
            usernameInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    this.saveUsername();
                }
            });
        }

        // 新任务输入框键盘事件
        const newTaskInput = document.getElementById('new-task-input');
        if (newTaskInput) {
            newTaskInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    this.confirmAddTask();
                } else if (e.key === 'Escape') {
                    this.cancelAddTask();
                }
            });
        }

        // 模态框点击外部关闭
        const modal = document.getElementById('import-modal');
        if (modal) {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeImportModal();
                }
            });
        }
    }

    // 渲染任务列表
    renderTasksList() {
        const tasksList = document.getElementById('tasks-list');
        if (!tasksList) return;

        const tasks = this.storage.getTasks();
        tasksList.innerHTML = '';

        if (tasks.length === 0) {
            tasksList.innerHTML = `
                <div class="empty-state">
                    <p>暂无任务，点击上方"添加任务"按钮来添加第一个任务吧！</p>
                </div>
            `;
            return;
        }

        tasks.forEach((task, index) => {
            const taskItem = this.createTaskItem(task, index);
            tasksList.appendChild(taskItem);
        });
    }

    // 创建任务项
    createTaskItem(taskName, index) {
        const item = document.createElement('div');
        item.className = 'task-item';
        item.setAttribute('data-index', index);
        
        item.innerHTML = `
            <div class="task-name">${taskName}</div>
            <textarea class="task-edit-input" maxlength="50" rows="2" placeholder="支持多行输入，按Shift+Enter换行">${taskName}</textarea>
            <div class="task-actions">
                <button class="task-btn edit-btn" onclick="taskEditor.editTask(${index})">编辑</button>
                <button class="task-btn delete-btn" onclick="taskEditor.deleteTask(${index})">删除</button>
                <button class="task-btn save-btn" onclick="taskEditor.saveTask(${index})" style="display: none;">保存</button>
                <button class="task-btn cancel-btn" onclick="taskEditor.cancelEdit(${index})" style="display: none;">取消</button>
            </div>
        `;

        return item;
    }

    // 保存用户名
    saveUsername() {
        const usernameInput = document.getElementById('username-input');
        if (!usernameInput) return;

        const newUsername = usernameInput.value.trim();
        if (!newUsername) {
            this.showToast('用户名不能为空！', 'error');
            return;
        }

        if (newUsername.length > 10) {
            this.showToast('用户名不能超过10个字符！', 'error');
            return;
        }

        this.storage.setUsername(newUsername);
        this.showToast('用户名保存成功！', 'success');
    }

    // 显示添加任务表单
    addNewTask() {
        const form = document.getElementById('add-task-form');
        const input = document.getElementById('new-task-input');
        
        if (form && input) {
            form.style.display = 'block';
            input.value = '';
            input.focus();
        }
    }

    // 确认添加任务
    confirmAddTask() {
        const input = document.getElementById('new-task-input');
        if (!input) return;

        const taskName = input.value.trim();
        if (!taskName) {
            this.showToast('任务名称不能为空！', 'error');
            return;
        }

        if (taskName.length > 50) {
            this.showToast('任务名称不能超过50个字符！', 'error');
            return;
        }

        const tasks = this.storage.getTasks();
        if (tasks.includes(taskName)) {
            this.showToast('任务已存在！', 'error');
            return;
        }

        tasks.push(taskName);
        this.storage.setTasks(tasks);
        
        // 更新今日完成状态数组
        const completion = this.storage.getTodayCompletion();
        completion.push(false);
        this.storage.setTodayCompletion(completion);

        this.renderTasksList();
        this.cancelAddTask();
        this.showToast('任务添加成功！', 'success');
    }

    // 取消添加任务
    cancelAddTask() {
        const form = document.getElementById('add-task-form');
        if (form) {
            form.style.display = 'none';
        }
    }

    // 编辑任务
    editTask(index) {
        // 如果有其他任务正在编辑，先取消
        if (this.editingIndex !== -1 && this.editingIndex !== index) {
            this.cancelEdit(this.editingIndex);
        }

        this.editingIndex = index;
        const taskItem = document.querySelector(`[data-index="${index}"]`);
        if (!taskItem) return;

        const taskName = taskItem.querySelector('.task-name');
        const editInput = taskItem.querySelector('.task-edit-input');
        const editBtn = taskItem.querySelector('.edit-btn');
        const deleteBtn = taskItem.querySelector('.delete-btn');
        const saveBtn = taskItem.querySelector('.save-btn');
        const cancelBtn = taskItem.querySelector('.cancel-btn');

        // 切换显示状态
        taskItem.classList.add('editing');
        taskName.classList.add('editing');
        editInput.classList.add('show');
        editBtn.style.display = 'none';
        deleteBtn.style.display = 'none';
        saveBtn.style.display = 'inline-block';
        cancelBtn.style.display = 'inline-block';

        editInput.focus();
        editInput.select();

        // 添加键盘事件
        editInput.onkeydown = (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.saveTask(index);
            } else if (e.key === 'Escape') {
                this.cancelEdit(index);
            }
        };
    }

    // 保存任务编辑
    saveTask(index) {
        const taskItem = document.querySelector(`[data-index="${index}"]`);
        if (!taskItem) return;

        const editInput = taskItem.querySelector('.task-edit-input');
        const newTaskName = editInput.value.trim();

        if (!newTaskName) {
            this.showToast('任务名称不能为空！', 'error');
            return;
        }

        if (newTaskName.length > 50) {
            this.showToast('任务名称不能超过50个字符！', 'error');
            return;
        }

        const tasks = this.storage.getTasks();
        const oldTaskName = tasks[index];

        // 检查是否与其他任务重名
        if (newTaskName !== oldTaskName && tasks.includes(newTaskName)) {
            this.showToast('任务名称已存在！', 'error');
            return;
        }

        tasks[index] = newTaskName;
        this.storage.setTasks(tasks);
        
        this.editingIndex = -1;
        this.renderTasksList();
        this.showToast('任务修改成功！', 'success');
    }

    // 取消编辑
    cancelEdit(index) {
        this.editingIndex = -1;
        const taskItem = document.querySelector(`[data-index="${index}"]`);
        if (!taskItem) return;

        const tasks = this.storage.getTasks();
        const editInput = taskItem.querySelector('.task-edit-input');
        editInput.value = tasks[index]; // 恢复原值

        this.renderTasksList();
    }

    // 删除任务
    deleteTask(index) {
        const tasks = this.storage.getTasks();
        const taskName = tasks[index];

        if (!confirm(`确定要删除任务"${taskName}"吗？\n删除后该任务的所有历史记录也将被清除。`)) {
            return;
        }

        // 删除任务
        tasks.splice(index, 1);
        this.storage.setTasks(tasks);

        // 更新所有历史记录中的完成状态
        const data = this.storage.getData();
        const history = data.completionHistory || {};
        
        Object.keys(history).forEach(date => {
            if (history[date] && history[date].length > index) {
                history[date].splice(index, 1);
            }
        });

        data.completionHistory = history;
        this.storage.saveData(data);

        this.renderTasksList();
        this.showToast('任务删除成功！', 'success');
    }

    // 重置所有任务
    resetAllTasks() {
        if (!confirm('确定要重置所有任务吗？\n这将清除所有任务的历史完成记录，但不会删除任务列表。')) {
            return;
        }

        const data = this.storage.getData();
        data.completionHistory = {};
        this.storage.saveData(data);

        this.showToast('所有任务记录已重置！', 'success');
    }

    // 恢复默认任务
    restoreDefaultTasks() {
        if (!confirm('确定要恢复默认任务列表吗？\n这将替换当前的任务列表，但保留历史记录。')) {
            return;
        }

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
        
        // 重置今日完成状态
        const completion = new Array(defaultTasks.length).fill(false);
        this.storage.setTodayCompletion(completion);

        this.renderTasksList();
        this.showToast('默认任务列表已恢复！', 'success');
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
            console.error('导出失败:', error);
            this.showToast('数据导出失败！', 'error');
        }
    }

    // 显示导入模态框
    importData() {
        const modal = document.getElementById('import-modal');
        if (modal) {
            modal.classList.add('show');
            const textarea = document.getElementById('import-textarea');
            if (textarea) {
                textarea.focus();
            }
        }
    }

    // 关闭导入模态框
    closeImportModal() {
        const modal = document.getElementById('import-modal');
        if (modal) {
            modal.classList.remove('show');
            const textarea = document.getElementById('import-textarea');
            if (textarea) {
                textarea.value = '';
            }
        }
    }

    // 确认导入
    confirmImport() {
        const textarea = document.getElementById('import-textarea');
        if (!textarea) return;

        const jsonData = textarea.value.trim();
        if (!jsonData) {
            this.showToast('请输入要导入的数据！', 'error');
            return;
        }

        try {
            // 验证JSON格式
            const data = JSON.parse(jsonData);
            
            // 基本数据结构验证
            if (typeof data !== 'object' || data === null) {
                throw new Error('数据格式不正确');
            }

            // 导入数据
            if (this.storage.importData(jsonData)) {
                this.closeImportModal();
                this.loadUsername();
                this.renderTasksList();
                this.showToast('数据导入成功！', 'success');
            } else {
                throw new Error('导入失败');
            }
        } catch (error) {
            console.error('导入失败:', error);
            this.showToast('数据格式错误，导入失败！', 'error');
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

function saveUsername() {
    if (window.taskEditor) {
        window.taskEditor.saveUsername();
    }
}

function addNewTask() {
    if (window.taskEditor) {
        window.taskEditor.addNewTask();
    }
}

function confirmAddTask() {
    if (window.taskEditor) {
        window.taskEditor.confirmAddTask();
    }
}

function cancelAddTask() {
    if (window.taskEditor) {
        window.taskEditor.cancelAddTask();
    }
}

function resetAllTasks() {
    if (window.taskEditor) {
        window.taskEditor.resetAllTasks();
    }
}

function restoreDefaultTasks() {
    if (window.taskEditor) {
        window.taskEditor.restoreDefaultTasks();
    }
}

function exportData() {
    if (window.taskEditor) {
        window.taskEditor.exportData();
    }
}

function importData() {
    if (window.taskEditor) {
        window.taskEditor.importData();
    }
}

function closeImportModal() {
    if (window.taskEditor) {
        window.taskEditor.closeImportModal();
    }
}

function confirmImport() {
    if (window.taskEditor) {
        window.taskEditor.confirmImport();
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    window.taskEditor = new TaskEditor();
});
