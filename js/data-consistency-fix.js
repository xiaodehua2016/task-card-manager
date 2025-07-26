/**
 * 数据一致性修复工具
 * 解决跨浏览器任务数量不一致问题
 */

class DataConsistencyFixer {
    constructor() {
        this.storageKey = 'taskManagerData';
        this.backupKey = 'taskManagerBackup';
        this.debugMode = true;
        
        // 确保与现有存储系统兼容
        this.storage = window.taskStorage;
    }

    // 诊断数据一致性问题
    diagnoseDataIssues() {
        const data = this.getData();
        const issues = [];

        console.log('🔍 开始诊断数据一致性问题...');
        
        // 检查基本数据结构
        if (!data) {
            issues.push('数据为空或不存在');
            return { issues, data: null };
        }

        // 检查任务数组
        if (!Array.isArray(data.tasks)) {
            issues.push('tasks不是数组类型');
        }

        // 检查今日任务
        const today = this.getTodayString();
        if (!data.dailyTasks || !data.dailyTasks[today]) {
            issues.push('今日任务数据缺失');
        }

        // 检查完成状态
        if (!data.completionHistory || !data.completionHistory[today]) {
            issues.push('今日完成状态缺失');
        }

        // 检查数据一致性
        const todayTasks = data.dailyTasks?.[today] || [];
        const enabledTasks = todayTasks.filter(task => task.enabled);
        const completion = data.completionHistory?.[today] || [];
        
        if (enabledTasks.length !== completion.length) {
            issues.push(`任务数量不匹配: 启用任务${enabledTasks.length}个，完成状态${completion.length}个`);
        }

        // 检查任务模板
        if (!data.taskTemplates || !data.taskTemplates.daily) {
            issues.push('任务模板缺失');
        }

        console.log('📊 诊断结果:', {
            总问题数: issues.length,
            问题列表: issues,
            数据概览: {
                基础任务数: data.tasks?.length || 0,
                今日任务数: todayTasks.length,
                启用任务数: enabledTasks.length,
                完成状态数: completion.length
            }
        });

        return { issues, data };
    }

    // 修复数据一致性问题
    fixDataConsistency() {
        console.log('🔧 开始修复数据一致性问题...');
        
        // 先备份当前数据
        this.backupCurrentData();
        
        const { issues, data } = this.diagnoseDataIssues();
        
        if (issues.length === 0) {
            console.log('✅ 数据一致性正常，无需修复');
            return { success: true, message: '数据一致性正常' };
        }

        let fixedData = data || {};
        let fixCount = 0;

        // 修复基本数据结构
        if (!fixedData.taskTemplates) {
            fixedData.taskTemplates = {
                daily: [
                    { name: '学而思数感小超市', type: 'daily' },
                    { name: '斑马思维', type: 'daily' },
                    { name: '核桃编程（学生端）', type: 'daily' },
                    { name: '英语阅读', type: 'daily' },
                    { name: '硬笔写字（30分钟）', type: 'daily' },
                    { name: '悦乐达打卡/作业', type: 'daily' },
                    { name: '暑假生活作业', type: 'daily' },
                    { name: '体育/运动（迪卡侬）', type: 'daily' }
                ]
            };
            fixCount++;
        }

        // 修复今日任务
        const today = this.getTodayString();
        if (!fixedData.dailyTasks) {
            fixedData.dailyTasks = {};
        }
        
        if (!fixedData.dailyTasks[today]) {
            fixedData.dailyTasks[today] = fixedData.taskTemplates.daily.map((task, index) => ({
                ...task,
                id: this.generateTaskId(),
                enabled: true,
                originalIndex: index
            }));
            fixCount++;
        }

        // 修复基础任务数组
        const todayTasks = fixedData.dailyTasks[today];
        const enabledTasks = todayTasks.filter(task => task.enabled);
        fixedData.tasks = enabledTasks.map(task => task.name);

        // 修复完成状态
        if (!fixedData.completionHistory) {
            fixedData.completionHistory = {};
        }
        
        if (!fixedData.completionHistory[today] || 
            fixedData.completionHistory[today].length !== enabledTasks.length) {
            fixedData.completionHistory[today] = new Array(enabledTasks.length).fill(false);
            fixCount++;
        }

        // 修复其他必要字段
        if (!fixedData.username) {
            fixedData.username = '小久';
            fixCount++;
        }

        if (!fixedData.taskTimes) {
            fixedData.taskTimes = {};
            fixCount++;
        }

        if (!fixedData.focusRecords) {
            fixedData.focusRecords = {};
            fixCount++;
        }

        // 更新时间戳
        fixedData.lastUpdateTime = Date.now();
        fixedData.fixedAt = new Date().toISOString();
        fixedData.fixCount = fixCount;

        // 保存修复后的数据
        const saveResult = this.saveData(fixedData);
        
        if (saveResult) {
            console.log('✅ 数据一致性修复完成:', {
                修复项目数: fixCount,
                修复时间: fixedData.fixedAt,
                当前任务数: enabledTasks.length
            });
            
            return {
                success: true,
                message: `数据一致性修复完成，共修复${fixCount}个问题`,
                fixCount,
                taskCount: enabledTasks.length
            };
        } else {
            console.error('❌ 数据保存失败');
            return {
                success: false,
                message: '数据修复失败，无法保存'
            };
        }
    }

    // 标准化所有浏览器的数据
    standardizeDataAcrossBrowsers() {
        console.log('🔄 开始标准化跨浏览器数据...');
        
        const result = this.fixDataConsistency();
        
        if (result.success) {
            // 触发数据更新事件
            window.dispatchEvent(new CustomEvent('dataStandardized', {
                detail: {
                    timestamp: Date.now(),
                    taskCount: result.taskCount,
                    fixCount: result.fixCount
                }
            }));
            
            // 如果页面有任务管理器，刷新显示
            if (window.taskManager) {
                setTimeout(() => {
                    window.taskManager.refreshAllData();
                }, 100);
            }
            
            // 将修复后的数据同步到服务器
            this.syncFixedDataToServer();
        }
        
        return result;
    }
    
    // 将修复后的数据同步到服务器
    async syncFixedDataToServer() {
        try {
            const fixedData = this.getData();
            
            if (!fixedData) {
                console.warn('没有数据可同步到服务器');
                return false;
            }
            
            // 如果存在dataSyncManager，使用它来同步
            if (window.dataSyncManager && typeof window.dataSyncManager.saveToServer === 'function') {
                console.log('🔄 正在将修复后的数据同步到服务器...');
                const result = await window.dataSyncManager.saveToServer(fixedData);
                
                if (result) {
                    console.log('✅ 修复后的数据已同步到服务器');
                    return true;
                } else {
                    console.warn('⚠️ 修复后的数据同步到服务器失败');
                    return false;
                }
            } else {
                console.warn('⚠️ 数据同步管理器不可用，无法同步到服务器');
                return false;
            }
        } catch (error) {
            console.error('❌ 同步修复数据到服务器失败:', error);
            return false;
        }
    }

    // 备份当前数据
    backupCurrentData() {
        try {
            const currentData = localStorage.getItem(this.storageKey);
            if (currentData) {
                const backup = {
                    data: currentData,
                    timestamp: Date.now(),
                    date: new Date().toISOString()
                };
                localStorage.setItem(this.backupKey, JSON.stringify(backup));
                console.log('💾 数据已备份');
            }
        } catch (error) {
            console.error('备份数据失败:', error);
        }
    }

    // 恢复备份数据
    restoreFromBackup() {
        try {
            const backupData = localStorage.getItem(this.backupKey);
            if (backupData) {
                const backup = JSON.parse(backupData);
                localStorage.setItem(this.storageKey, backup.data);
                console.log('🔄 数据已从备份恢复');
                return true;
            }
            return false;
        } catch (error) {
            console.error('恢复备份失败:', error);
            return false;
        }
    }

    // 获取数据 - 兼容现有存储系统
    getData() {
        try {
            if (this.storage && typeof this.storage.getData === 'function') {
                return this.storage.getData();
            }
            const data = localStorage.getItem(this.storageKey);
            return data ? JSON.parse(data) : null;
        } catch (error) {
            console.error('读取数据失败:', error);
            return null;
        }
    }

    // 保存数据 - 兼容现有存储系统
    saveData(data) {
        try {
            if (this.storage && typeof this.storage.saveData === 'function') {
                return this.storage.saveData(data);
            }
            localStorage.setItem(this.storageKey, JSON.stringify(data));
            return true;
        } catch (error) {
            console.error('保存数据失败:', error);
            return false;
        }
    }

    // 生成任务ID
    generateTaskId() {
        return 'task_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    // 获取今日日期字符串
    getTodayString() {
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    // 显示修复报告
    showFixReport() {
        const { issues, data } = this.diagnoseDataIssues();
        
        const report = {
            检查时间: new Date().toLocaleString(),
            数据状态: issues.length === 0 ? '正常' : '需要修复',
            问题数量: issues.length,
            问题详情: issues,
            数据概览: data ? {
                用户名: data.username || '未设置',
                基础任务数: data.tasks?.length || 0,
                今日任务数: this.getTodayTaskCount(data),
                最后更新: data.lastUpdateTime ? new Date(data.lastUpdateTime).toLocaleString() : '未知'
            } : '数据为空'
        };
        
        console.table(report);
        return report;
    }

    // 获取今日任务数量
    getTodayTaskCount(data) {
        if (!data || !data.dailyTasks) return 0;
        const today = this.getTodayString();
        const todayTasks = data.dailyTasks[today] || [];
        return todayTasks.filter(task => task.enabled).length;
    }

    // 清理和重置数据
    resetAndCleanData() {
        console.log('🧹 开始清理和重置数据...');
        
        // 备份当前数据
        this.backupCurrentData();
        
        // 创建全新的标准数据结构
        const cleanData = {
            username: '小久',
            taskTemplates: {
                daily: [
                    { name: '学而思数感小超市', type: 'daily' },
                    { name: '斑马思维', type: 'daily' },
                    { name: '核桃编程（学生端）', type: 'daily' },
                    { name: '英语阅读', type: 'daily' },
                    { name: '硬笔写字（30分钟）', type: 'daily' },
                    { name: '悦乐达打卡/作业', type: 'daily' },
                    { name: '暑假生活作业', type: 'daily' },
                    { name: '体育/运动（迪卡侬）', type: 'daily' }
                ]
            },
            dailyTasks: {},
            oneTimeTasks: [],
            routineTasks: [],
            tasks: [],
            completionHistory: {},
            taskTimes: {},
            focusRecords: {},
            lastUpdateTime: Date.now(),
            resetAt: new Date().toISOString(),
            version: '4.2.1'
        };
        
        // 初始化今日任务
        const today = this.getTodayString();
        cleanData.dailyTasks[today] = cleanData.taskTemplates.daily.map((task, index) => ({
            ...task,
            id: this.generateTaskId(),
            enabled: true,
            originalIndex: index
        }));
        
        // 设置基础任务数组
        cleanData.tasks = cleanData.dailyTasks[today].map(task => task.name);
        
        // 初始化完成状态
        cleanData.completionHistory[today] = new Array(cleanData.tasks.length).fill(false);
        
        // 保存清理后的数据
        const saveResult = this.saveData(cleanData);
        
        if (saveResult) {
            console.log('✅ 数据清理和重置完成');
            
            // 触发数据重置事件
            window.dispatchEvent(new CustomEvent('dataReset', {
                detail: {
                    timestamp: Date.now(),
                    taskCount: cleanData.tasks.length
                }
            }));
            
            return {
                success: true,
                message: '数据已清理和重置',
                taskCount: cleanData.tasks.length
            };
        } else {
            return {
                success: false,
                message: '数据重置失败'
            };
        }
    }
}

// 创建全局数据一致性修复器
window.dataFixer = new DataConsistencyFixer();

// 页面加载时自动检查和修复数据一致性
document.addEventListener('DOMContentLoaded', function() {
    console.log('🔍 页面加载完成，开始数据一致性检查...');
    
    // 延迟执行，确保其他脚本已加载
    setTimeout(() => {
        const result = window.dataFixer.standardizeDataAcrossBrowsers();
        
        if (result.success && result.fixCount > 0) {
            console.log(`✅ 数据一致性已修复，共修复${result.fixCount}个问题`);
            
            // 显示修复通知
            if (typeof showToast === 'function') {
                showToast(`数据已修复，当前有${result.taskCount}个任务`);
            }
        }
    }, 1000);
});

// 监听数据标准化事件
window.addEventListener('dataStandardized', function(event) {
    console.log('📊 数据标准化完成:', event.detail);
});

// 监听数据重置事件
window.addEventListener('dataReset', function(event) {
    console.log('🔄 数据重置完成:', event.detail);
    
    // 刷新页面显示
    if (window.taskManager) {
        window.taskManager.refreshAllData();
    }
});

// 提供全局修复函数 - 避免冲突
if (!window.fixDataConsistency) {
    window.fixDataConsistency = function() {
        return window.dataFixer.standardizeDataAcrossBrowsers();
    };
}

if (!window.resetAllData) {
    window.resetAllData = function() {
        if (confirm('确定要重置所有数据吗？这将清除所有历史记录。')) {
            return window.dataFixer.resetAndCleanData();
        }
        return { success: false, message: '用户取消操作' };
    };
}

if (!window.showDataReport) {
    window.showDataReport = function() {
        return window.dataFixer.showFixReport();
    };
}

console.log('🔧 数据一致性修复工具已加载');