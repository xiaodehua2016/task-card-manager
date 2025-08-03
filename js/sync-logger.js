/**
 * 任务管理系统 - 同步日志记录器 v4.3.6
 * 功能：记录客户端IP、浏览器版本、请求响应等信息，便于问题分析
 */

class SyncLogger {
    constructor() {
        this.config = {
            enabled: true, // 日志开关，可通过localStorage控制
            maxLogs: 100,  // 最大日志条数
            storageKey: 'taskManager_syncLogs_v436'
        };
        
        this.clientInfo = this.getClientInfo();
        this.init();
    }

    init() {
        // 检查日志开关
        const logSwitch = localStorage.getItem('taskManager_logEnabled');
        if (logSwitch !== null) {
            this.config.enabled = logSwitch === 'true';
        }
        
        if (this.config.enabled) {
            console.log('[SyncLogger v4.3.6] 日志记录已启用');
            this.log('SYSTEM', 'SyncLogger初始化完成', { clientInfo: this.clientInfo });
        }
    }

    getClientInfo() {
        const nav = navigator;
        return {
            userAgent: nav.userAgent,
            browser: this.getBrowserInfo(),
            platform: nav.platform,
            language: nav.language,
            cookieEnabled: nav.cookieEnabled,
            onLine: nav.onLine,
            timestamp: new Date().toISOString(),
            url: window.location.href,
            referrer: document.referrer
        };
    }

    getBrowserInfo() {
        const ua = navigator.userAgent;
        let browser = 'Unknown';
        let version = 'Unknown';

        if (ua.indexOf('Chrome') > -1 && ua.indexOf('Edge') === -1) {
            browser = 'Chrome';
            version = ua.match(/Chrome\/(\d+)/)?.[1] || 'Unknown';
        } else if (ua.indexOf('Edge') > -1) {
            browser = 'Edge';
            version = ua.match(/Edge\/(\d+)/)?.[1] || 'Unknown';
        } else if (ua.indexOf('Firefox') > -1) {
            browser = 'Firefox';
            version = ua.match(/Firefox\/(\d+)/)?.[1] || 'Unknown';
        } else if (ua.indexOf('Safari') > -1) {
            browser = 'Safari';
            version = ua.match(/Version\/(\d+)/)?.[1] || 'Unknown';
        }

        return { name: browser, version: version };
    }

    async getClientIP() {
        try {
            // 尝试获取客户端IP
            const response = await fetch('https://api.ipify.org?format=json');
            const data = await response.json();
            return data.ip;
        } catch (error) {
            return 'Unknown';
        }
    }

    log(type, message, data = {}) {
        if (!this.config.enabled) return;

        const logEntry = {
            id: Date.now() + Math.random().toString(36).substr(2, 9),
            timestamp: new Date().toISOString(),
            type: type, // SYNC, REQUEST, RESPONSE, ERROR, SYSTEM
            message: message,
            data: data,
            clientInfo: {
                browser: this.clientInfo.browser,
                url: window.location.href,
                userAgent: navigator.userAgent
            }
        };

        // 获取现有日志
        let logs = this.getLogs();
        logs.unshift(logEntry);

        // 限制日志数量
        if (logs.length > this.config.maxLogs) {
            logs = logs.slice(0, this.config.maxLogs);
        }

        // 保存日志
        try {
            localStorage.setItem(this.config.storageKey, JSON.stringify(logs));
        } catch (error) {
            console.error('[SyncLogger] 保存日志失败:', error);
        }

        // 控制台输出
        console.log(`[SyncLogger ${type}] ${message}`, data);
    }

    logSyncRequest(url, method, requestData) {
        this.log('REQUEST', `同步请求: ${method} ${url}`, {
            url: url,
            method: method,
            requestData: requestData,
            timestamp: new Date().toISOString()
        });
    }

    logSyncResponse(url, status, responseData, duration) {
        this.log('RESPONSE', `同步响应: ${status} ${url}`, {
            url: url,
            status: status,
            responseData: responseData,
            duration: duration + 'ms',
            timestamp: new Date().toISOString()
        });
    }

    logSyncError(url, error, context = {}) {
        this.log('ERROR', `同步错误: ${url}`, {
            url: url,
            error: error.message || error,
            stack: error.stack,
            context: context,
            timestamp: new Date().toISOString()
        });
    }

    logDataChange(action, oldData, newData) {
        this.log('SYNC', `数据变更: ${action}`, {
            action: action,
            oldDataHash: this.hashData(oldData),
            newDataHash: this.hashData(newData),
            timestamp: new Date().toISOString()
        });
    }

    hashData(data) {
        if (!data) return 'null';
        const str = JSON.stringify(data);
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32bit integer
        }
        return hash.toString(16);
    }

    getLogs() {
        try {
            const logs = localStorage.getItem(this.config.storageKey);
            return logs ? JSON.parse(logs) : [];
        } catch (error) {
            console.error('[SyncLogger] 读取日志失败:', error);
            return [];
        }
    }

    clearLogs() {
        localStorage.removeItem(this.config.storageKey);
        this.log('SYSTEM', '日志已清空');
    }

    exportLogs() {
        const logs = this.getLogs();
        const dataStr = JSON.stringify(logs, null, 2);
        const dataBlob = new Blob([dataStr], { type: 'application/json' });
        
        const link = document.createElement('a');
        link.href = URL.createObjectURL(dataBlob);
        link.download = `sync-logs-${new Date().toISOString().split('T')[0]}.json`;
        link.click();
        
        this.log('SYSTEM', '日志已导出');
    }

    toggleLogging(enabled) {
        this.config.enabled = enabled;
        localStorage.setItem('taskManager_logEnabled', enabled.toString());
        this.log('SYSTEM', `日志记录${enabled ? '已启用' : '已禁用'}`);
    }

    getLogSummary() {
        const logs = this.getLogs();
        const summary = {
            total: logs.length,
            byType: {},
            byBrowser: {},
            errors: 0,
            lastSync: null
        };

        logs.forEach(log => {
            // 按类型统计
            summary.byType[log.type] = (summary.byType[log.type] || 0) + 1;
            
            // 按浏览器统计
            const browser = log.clientInfo?.browser?.name || 'Unknown';
            summary.byBrowser[browser] = (summary.byBrowser[browser] || 0) + 1;
            
            // 错误统计
            if (log.type === 'ERROR') {
                summary.errors++;
            }
            
            // 最后同步时间
            if (log.type === 'SYNC' && !summary.lastSync) {
                summary.lastSync = log.timestamp;
            }
        });

        return summary;
    }
}

// 创建全局日志实例
window.syncLogger = new SyncLogger();

// 暴露日志控制函数到全局
window.toggleSyncLogging = (enabled) => window.syncLogger.toggleLogging(enabled);
window.exportSyncLogs = () => window.syncLogger.exportLogs();
window.clearSyncLogs = () => window.syncLogger.clearLogs();
window.getSyncLogSummary = () => window.syncLogger.getLogSummary();