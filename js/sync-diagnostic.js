/**
 * 数据同步诊断和修复工具
 * 用于排查和解决跨浏览器数据同步问题
 */

class SyncDiagnostic {
    constructor() {
        this.syncEndpoint = '/api/data-sync.php';
        this.storageKeys = ['taskManagerData', 'xiaojiu_tasks', 'tasks'];
        this.diagnosticResults = {};
    }

    // 运行完整诊断
    async runFullDiagnostic() {
        console.log('🔍 开始数据同步诊断...');
        
        const results = {
            timestamp: new Date().toISOString(),
            localData: this.checkLocalData(),
            serverData: await this.checkServerData(),
            syncStatus: null,
            recommendations: []
        };

        // 分析同步状态
        results.syncStatus = this.analyzeSyncStatus(results.localData, results.serverData);
        
        // 生成建议
        results.recommendations = this.generateRecommendations(results);
        
        this.diagnosticResults = results;
        this.displayResults(results);
        
        return results;
    }

    // 检查本地数据
    checkLocalData() {
        const localData = {
            available: false,
            keys: [],
            data: null,
            lastUpdateTime: 0,
            dataSize: 0
        };

        for (const key of this.storageKeys) {
            try {
                const data = localStorage.getItem(key);
                if (data) {
                    localData.keys.push(key);
                    const parsed = JSON.parse(data);
                    
                    if (!localData.data || (parsed.lastUpdateTime > localData.lastUpdateTime)) {
                        localData.data = parsed;
                        localData.lastUpdateTime = parsed.lastUpdateTime || 0;
                        localData.available = true;
                    }
                    
                    localData.dataSize += data.length;
                }
            } catch (error) {
                console.warn(`检查本地存储键 ${key} 失败:`, error);
            }
        }

        return localData;
    }

    // 检查服务器数据
    async checkServerData() {
        const serverData = {
            available: false,
            accessible: false,
            data: null,
            lastUpdateTime: 0,
            serverUpdateTime: 0,
            error: null
        };

        try {
            const response = await fetch(this.syncEndpoint + '?diagnostic=1&t=' + Date.now(), {
                method: 'GET',
                cache: 'no-cache'
            });

            serverData.accessible = response.ok;

            if (response.ok) {
                const responseData = await response.json();
                
                if (responseData.success && responseData.data) {
                    serverData.available = true;
                    serverData.data = responseData.data;
                    serverData.lastUpdateTime = responseData.data.lastUpdateTime || 0;
                    serverData.serverUpdateTime = responseData.data.serverUpdateTime || 0;
                } else {
                    serverData.error = responseData.message || '服务器返回空数据';
                }
            } else {
                serverData.error = `HTTP ${response.status}`;
            }
        } catch (error) {
            serverData.error = error.message;
        }

        return serverData;
    }

    // 分析同步状态
    analyzeSyncStatus(localData, serverData) {
        const status = {
            level: 'unknown',
            message: '',
            timeDiff: 0,
            needsSync: false
        };

        if (!localData.available && !serverData.available) {
            status.level = 'error';
            status.message = '本地和服务器都没有数据';
        } else if (!localData.available) {
            status.level = 'warning';
            status.message = '只有服务器有数据，本地数据缺失';
            status.needsSync = true;
        } else if (!serverData.available) {
            status.level = 'warning';
            status.message = '只有本地有数据，服务器数据缺失';
            status.needsSync = true;
        } else {
            // 比较时间戳
            const localTime = localData.lastUpdateTime;
            const serverTime = Math.max(serverData.lastUpdateTime, serverData.serverUpdateTime);
            status.timeDiff = Math.abs(localTime - serverTime);

            if (status.timeDiff < 5000) { // 5秒内
                status.level = 'success';
                status.message = '数据同步正常';
            } else if (status.timeDiff < 60000) { // 1分钟内
                status.level = 'warning';
                status.message = `数据有轻微延迟 (${Math.round(status.timeDiff/1000)}秒)`;
                status.needsSync = true;
            } else {
                status.level = 'error';
                status.message = `数据严重不同步 (${Math.round(status.timeDiff/60000)}分钟)`;
                status.needsSync = true;
            }
        }

        return status;
    }

    // 生成修复建议
    generateRecommendations(results) {
        const recommendations = [];

        if (!results.serverData.accessible) {
            recommendations.push({
                type: 'critical',
                action: 'checkServer',
                message: '检查服务器连接和API配置'
            });
        }

        if (results.syncStatus.needsSync) {
            recommendations.push({
                type: 'important',
                action: 'forceSync',
                message: '执行强制同步修复数据不一致'
            });
        }

        if (results.localData.keys.length > 1) {
            recommendations.push({
                type: 'optimization',
                action: 'cleanupStorage',
                message: '清理重复的本地存储键'
            });
        }

        if (results.localData.dataSize > 100000) { // 100KB
            recommendations.push({
                type: 'optimization',
                action: 'optimizeData',
                message: '数据量较大，建议优化存储结构'
            });
        }

        return recommendations;
    }

    // 显示诊断结果
    displayResults(results) {
        console.group('📊 数据同步诊断报告');
        
        console.log('🕒 诊断时间:', results.timestamp);
        
        console.group('💾 本地数据状态');
        console.log('可用:', results.localData.available ? '✅' : '❌');
        console.log('存储键:', results.localData.keys);
        console.log('数据大小:', Math.round(results.localData.dataSize / 1024) + 'KB');
        console.log('最后更新:', new Date(results.localData.lastUpdateTime).toLocaleString());
        console.groupEnd();

        console.group('🌐 服务器数据状态');
        console.log('可访问:', results.serverData.accessible ? '✅' : '❌');
        console.log('有数据:', results.serverData.available ? '✅' : '❌');
        if (results.serverData.error) {
            console.log('错误:', results.serverData.error);
        }
        if (results.serverData.available) {
            console.log('最后更新:', new Date(results.serverData.lastUpdateTime).toLocaleString());
            console.log('服务器时间:', new Date(results.serverData.serverUpdateTime).toLocaleString());
        }
        console.groupEnd();

        console.group('🔄 同步状态');
        const statusIcon = {
            'success': '✅',
            'warning': '⚠️',
            'error': '❌',
            'unknown': '❓'
        }[results.syncStatus.level];
        console.log('状态:', statusIcon, results.syncStatus.message);
        if (results.syncStatus.timeDiff > 0) {
            console.log('时间差:', Math.round(results.syncStatus.timeDiff / 1000) + '秒');
        }
        console.groupEnd();

        if (results.recommendations.length > 0) {
            console.group('💡 修复建议');
            results.recommendations.forEach((rec, index) => {
                const icon = {
                    'critical': '🚨',
                    'important': '⚠️',
                    'optimization': '💡'
                }[rec.type];
                console.log(`${index + 1}. ${icon} ${rec.message}`);
            });
            console.groupEnd();
        }

        console.groupEnd();
    }

    // 执行自动修复
    async autoFix() {
        console.log('🔧 开始自动修复...');
        
        const results = await this.runFullDiagnostic();
        let fixCount = 0;

        for (const rec of results.recommendations) {
            try {
                switch (rec.action) {
                    case 'forceSync':
                        if (window.dataSyncManager && window.dataSyncManager.forceSync) {
                            const success = await window.dataSyncManager.forceSync();
                            if (success) {
                                console.log('✅ 强制同步完成');
                                fixCount++;
                            }
                        }
                        break;
                        
                    case 'cleanupStorage':
                        this.cleanupDuplicateStorage();
                        console.log('✅ 清理重复存储完成');
                        fixCount++;
                        break;
                }
            } catch (error) {
                console.error(`修复操作失败 (${rec.action}):`, error);
            }
        }

        console.log(`🎉 自动修复完成，成功修复 ${fixCount} 个问题`);
        
        // 重新诊断验证修复效果
        setTimeout(() => {
            this.runFullDiagnostic();
        }, 2000);
        
        return fixCount;
    }

    // 清理重复的本地存储
    cleanupDuplicateStorage() {
        const mainKey = 'taskManagerData';
        let mainData = null;
        let latestTime = 0;

        // 找到最新的数据
        for (const key of this.storageKeys) {
            try {
                const data = localStorage.getItem(key);
                if (data) {
                    const parsed = JSON.parse(data);
                    const updateTime = parsed.lastUpdateTime || 0;
                    
                    if (updateTime > latestTime) {
                        latestTime = updateTime;
                        mainData = parsed;
                    }
                }
            } catch (error) {
                console.warn(`处理存储键 ${key} 时出错:`, error);
            }
        }

        if (mainData) {
            // 保存到主键
            localStorage.setItem(mainKey, JSON.stringify(mainData));
            
            // 删除其他键
            for (const key of this.storageKeys) {
                if (key !== mainKey) {
                    localStorage.removeItem(key);
                }
            }
        }
    }

    // 获取最新诊断结果
    getLastResults() {
        return this.diagnosticResults;
    }
}

// 创建全局诊断工具实例
window.syncDiagnostic = new SyncDiagnostic();

// 添加控制台快捷命令
window.checkSync = () => window.syncDiagnostic.runFullDiagnostic();
window.fixSync = () => window.syncDiagnostic.autoFix();

console.log('🔧 数据同步诊断工具已加载');
console.log('💡 使用 checkSync() 检查同步状态');
console.log('💡 使用 fixSync() 自动修复同步问题');