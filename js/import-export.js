/**
 * 数据导入导出管理器
 * 提供数据备份、恢复、导入导出功能
 */
class ImportExportManager {
    constructor() {
        this.fileStorage = new FileStorage();
        this.setupUI();
        this.bindEvents();
    }
    
    // 设置用户界面
    setupUI() {
        // 检查是否已经添加了导入导出界面
        if (document.querySelector('.data-management')) {
            return;
        }
        
        // 创建数据管理界面
        const dataManagementHTML = `
            <div class="data-management" style="margin-top: 20px; padding: 20px; border: 1px solid #ddd; border-radius: 8px; background: #f9f9f9;">
                <h3 style="margin-top: 0; color: #333;">📁 数据管理</h3>
                
                <div class="management-buttons" style="display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 15px;">
                    <button id="exportData" class="btn btn-primary" style="background: #007bff; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">
                        📤 导出数据
                    </button>
                    
                    <button id="importBtn" class="btn btn-secondary" style="background: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">
                        📥 导入数据
                    </button>
                    
                    <button id="downloadBackup" class="btn btn-info" style="background: #17a2b8; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">
                        💾 下载备份
                    </button>
                    
                    <button id="clearData" class="btn btn-warning" style="background: #ffc107; color: #212529; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">
                        🗑️ 清空数据
                    </button>
                </div>
                
                <div class="storage-info" id="storageInfo" style="font-size: 12px; color: #666; margin-top: 10px;">
                    正在加载存储信息...
                </div>
                
                <input type="file" id="importData" accept=".json" style="display: none;">
            </div>
        `;
        
        // 尝试添加到不同的容器
        const containers = [
            '.settings-container',
            '.container',
            'main',
            'body'
        ];
        
        for (const selector of containers) {
            const container = document.querySelector(selector);
            if (container) {
                container.insertAdjacentHTML('beforeend', dataManagementHTML);
                break;
            }
        }
        
        // 更新存储信息
        this.updateStorageInfo();
    }
    
    // 绑定事件
    bindEvents() {
        // 导出数据
        const exportBtn = document.getElementById('exportData');
        if (exportBtn) {
            exportBtn.onclick = () => this.exportData();
        }
        
        // 导入数据
        const importBtn = document.getElementById('importBtn');
        if (importBtn) {
            importBtn.onclick = () => this.triggerImport();
        }
        
        // 下载备份
        const backupBtn = document.getElementById('downloadBackup');
        if (backupBtn) {
            backupBtn.onclick = () => this.downloadBackup();
        }
        
        // 清空数据
        const clearBtn = document.getElementById('clearData');
        if (clearBtn) {
            clearBtn.onclick = () => this.clearAllData();
        }
        
        // 文件选择
        const fileInput = document.getElementById('importData');
        if (fileInput) {
            fileInput.onchange = (event) => this.handleFileImport(event);
        }
    }
    
    // 导出数据
    async exportData() {
        try {
            const exportData = await this.fileStorage.exportAllData();
            if (exportData) {
                const today = new Date().toISOString().split('T')[0];
                const filename = `小久任务管理_导出数据_${today}.json`;
                this.downloadFile(exportData, filename);
                this.showMessage('数据导出成功！', 'success');
            } else {
                this.showMessage('导出数据失败！', 'error');
            }
        } catch (error) {
            console.error('导出数据失败:', error);
            this.showMessage('导出数据时发生错误！', 'error');
        }
    }
    
    // 触发导入
    triggerImport() {
        const fileInput = document.getElementById('importData');
        if (fileInput) {
            fileInput.click();
        }
    }
    
    // 处理文件导入
    async handleFileImport(event) {
        const file = event.target.files[0];
        if (!file) return;
        
        try {
            const text = await file.text();
            const importData = JSON.parse(text);
            
            // 验证数据格式
            if (this.validateImportData(importData)) {
                const confirmed = confirm(
                    '导入数据将覆盖现有数据，是否继续？\n' +
                    '建议先备份当前数据。'
                );
                
                if (confirmed) {
                    const success = await this.fileStorage.importData(importData);
                    if (success) {
                        this.showMessage('数据导入成功！页面将刷新。', 'success');
                        setTimeout(() => location.reload(), 2000);
                    } else {
                        this.showMessage('数据导入失败！', 'error');
                    }
                }
            } else {
                this.showMessage('导入文件格式不正确！', 'error');
            }
        } catch (error) {
            console.error('导入数据失败:', error);
            this.showMessage('导入数据时发生错误！请检查文件格式。', 'error');
        }
        
        // 清空文件选择
        event.target.value = '';
    }
    
    // 下载备份
    async downloadBackup() {
        try {
            const success = await this.fileStorage.createBackup();
            if (success) {
                this.showMessage('备份下载成功！', 'success');
            } else {
                this.showMessage('备份下载失败！', 'error');
            }
        } catch (error) {
            console.error('下载备份失败:', error);
            this.showMessage('下载备份时发生错误！', 'error');
        }
    }
    
    // 清空所有数据
    async clearAllData() {
        const confirmed = confirm(
            '⚠️ 警告：此操作将删除所有任务和数据！\n' +
            '删除后无法恢复，是否确定继续？\n\n' +
            '建议先导出备份数据。'
        );
        
        if (confirmed) {
            const doubleConfirmed = confirm('请再次确认：真的要删除所有数据吗？');
            
            if (doubleConfirmed) {
                try {
                    const success = await this.fileStorage.clearAllData();
                    if (success) {
                        this.showMessage('所有数据已清空！页面将刷新。', 'success');
                        setTimeout(() => location.reload(), 2000);
                    } else {
                        this.showMessage('清空数据失败！', 'error');
                    }
                } catch (error) {
                    console.error('清空数据失败:', error);
                    this.showMessage('清空数据时发生错误！', 'error');
                }
            }
        }
    }
    
    // 验证导入数据格式
    validateImportData(data) {
        try {
            // 检查基本结构
            if (!data || typeof data !== 'object') {
                return false;
            }
            
            // 检查版本信息
            if (!data.version) {
                return false;
            }
            
            // 检查数据部分
            if (!data.data || typeof data.data !== 'object') {
                return false;
            }
            
            // 检查任务数据
            if (data.data.tasks && !Array.isArray(data.data.tasks)) {
                return false;
            }
            
            // 检查统计数据
            if (data.data.statistics && !Array.isArray(data.data.statistics)) {
                return false;
            }
            
            return true;
            
        } catch (error) {
            console.error('验证导入数据失败:', error);
            return false;
        }
    }
    
    // 下载文件
    downloadFile(data, filename) {
        const blob = new Blob([JSON.stringify(data, null, 2)], {
            type: 'application/json'
        });
        
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.style.display = 'none';
        
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        
        URL.revokeObjectURL(url);
    }
    
    // 更新存储信息
    async updateStorageInfo() {
        try {
            const info = await this.fileStorage.getStorageInfo();
            const infoElement = document.getElementById('storageInfo');
            
            if (info && infoElement) {
                const lastSync = info.lastSync ? 
                    new Date(info.lastSync).toLocaleString('zh-CN') : 
                    '从未同步';
                
                infoElement.innerHTML = `
                    📊 存储信息：任务 ${info.tasksCount} 条 | 
                    统计 ${info.statisticsCount} 条 | 
                    存储占用 ${info.storageUsed} KB | 
                    最后同步：${lastSync} |
                    IndexedDB：${info.indexedDBSupported ? '✅ 支持' : '❌ 不支持'}
                `;
            }
        } catch (error) {
            console.error('更新存储信息失败:', error);
        }
    }
    
    // 显示消息
    showMessage(message, type = 'info') {
        // 创建消息元素
        const messageDiv = document.createElement('div');
        messageDiv.className = `message message-${type}`;
        messageDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 4px;
            color: white;
            font-weight: bold;
            z-index: 10000;
            max-width: 300px;
            word-wrap: break-word;
        `;
        
        // 设置颜色
        switch (type) {
            case 'success':
                messageDiv.style.backgroundColor = '#28a745';
                break;
            case 'error':
                messageDiv.style.backgroundColor = '#dc3545';
                break;
            case 'warning':
                messageDiv.style.backgroundColor = '#ffc107';
                messageDiv.style.color = '#212529';
                break;
            default:
                messageDiv.style.backgroundColor = '#17a2b8';
        }
        
        messageDiv.textContent = message;
        document.body.appendChild(messageDiv);
        
        // 3秒后自动移除
        setTimeout(() => {
            if (messageDiv.parentNode) {
                messageDiv.parentNode.removeChild(messageDiv);
            }
        }, 3000);
    }
    
    // 初始化自动备份
    setupAutoBackup() {
        const settings = this.fileStorage.loadSettings();
        if (settings && settings.autoBackup) {
            const interval = (settings.backupInterval || 7) * 24 * 60 * 60 * 1000; // 转换为毫秒
            
            setInterval(async () => {
                try {
                    await this.fileStorage.createBackup();
                    console.log('✅ 自动备份完成');
                } catch (error) {
                    console.error('自动备份失败:', error);
                }
            }, interval);
        }
    }
    
    // 获取数据统计
    async getDataStatistics() {
        try {
            const tasks = await this.fileStorage.loadTasks();
            const statistics = await this.fileStorage.loadStatistics();
            
            const stats = {
                totalTasks: tasks.length,
                completedTasks: tasks.filter(t => t.status === 'completed').length,
                pendingTasks: tasks.filter(t => t.status === 'pending').length,
                inProgressTasks: tasks.filter(t => t.status === 'in_progress').length,
                categories: [...new Set(tasks.map(t => t.category))].length,
                statisticsRecords: statistics.length
            };
            
            return stats;
            
        } catch (error) {
            console.error('获取数据统计失败:', error);
            return null;
        }
    }
}

// 自动初始化（如果在浏览器环境中）
if (typeof window !== 'undefined') {
    // 等待DOM加载完成后初始化
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            window.importExportManager = new ImportExportManager();
        });
    } else {
        window.importExportManager = new ImportExportManager();
    }
}

// 导出类供其他模块使用
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ImportExportManager;
}