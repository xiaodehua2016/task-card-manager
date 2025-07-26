/**
 * 跨浏览器数据同步测试工具
 * 用于验证数据同步功能是否正常工作
 */

class SyncTester {
    constructor() {
        this.testResults = [];
        this.isRunning = false;
    }
    
    // 运行完整测试
    async runFullTest() {
        if (this.isRunning) {
            console.warn('测试已在运行中，请等待完成');
            return;
        }
        
        this.isRunning = true;
        this.testResults = [];
        console.log('🧪 开始跨浏览器数据同步测试...');
        
        try {
            await this.testLocalStorage();
            await this.testServerConnection();
            await this.testDataSync();
            await this.testConsistencyFixer();
            
            this.showTestSummary();
        } catch (error) {
            console.error('❌ 测试过程中发生错误:', error);
            this.addResult('测试执行', false, error.message);
        } finally {
            this.isRunning = false;
        }
    }
    
    // 测试本地存储
    async testLocalStorage() {
        console.log('测试本地存储...');
        
        try {
            // 检查localStorage是否可用
            const testKey = '_sync_test_key';
            const testValue = 'test_' + Date.now();
            
            localStorage.setItem(testKey, testValue);
            const readValue = localStorage.getItem(testKey);
            localStorage.removeItem(testKey);
            
            const success = readValue === testValue;
            this.addResult('本地存储', success, success ? '正常工作' : '读写不一致');
            
            // 检查任务数据是否存在
            const taskData = localStorage.getItem('taskManagerData');
            const hasTaskData = !!taskData;
            this.addResult('任务数据', hasTaskData, hasTaskData ? '数据已存在' : '数据不存在');
            
            return success && hasTaskData;
        } catch (error) {
            this.addResult('本地存储', false, error.message);
            return false;
        }
    }
    
    // 测试服务器连接
    async testServerConnection() {
        console.log('测试服务器连接...');
        
        try {
            const response = await fetch('/api/data-sync.php?test=1', {
                method: 'GET',
                cache: 'no-cache'
            });
            
            const success = response.ok;
            let message = success ? '连接成功' : `连接失败: ${response.status}`;
            
            if (success) {
                const data = await response.json();
                message += `, 服务器响应: ${JSON.stringify(data).substring(0, 50)}...`;
            }
            
            this.addResult('服务器连接', success, message);
            return success;
        } catch (error) {
            this.addResult('服务器连接', false, `连接错误: ${error.message}`);
            return false;
        }
    }
    
    // 测试数据同步
    async testDataSync() {
        console.log('测试数据同步...');
        
        try {
            // 检查同步管理器是否存在
            if (!window.dataSyncManager) {
                this.addResult('数据同步管理器', false, '同步管理器不存在');
                return false;
            }
            
            // 测试保存到服务器
            const testData = {
                testId: 'sync_test_' + Date.now(),
                lastUpdateTime: Date.now(),
                message: '这是一个同步测试'
            };
            
            const saveResult = await window.dataSyncManager.saveToServer(testData);
            this.addResult('保存到服务器', saveResult, saveResult ? '保存成功' : '保存失败');
            
            // 等待一秒后检查是否可以从服务器获取数据
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            await window.dataSyncManager.checkForUpdates();
            this.addResult('检查更新', true, '检查更新流程完成');
            
            return saveResult;
        } catch (error) {
            this.addResult('数据同步', false, `同步错误: ${error.message}`);
            return false;
        }
    }
    
    // 测试数据一致性修复工具
    async testConsistencyFixer() {
        console.log('测试数据一致性修复工具...');
        
        try {
            // 检查修复工具是否存在
            if (!window.dataFixer) {
                this.addResult('数据一致性修复工具', false, '修复工具不存在');
                return false;
            }
            
            // 运行诊断
            const diagnosis = window.dataFixer.diagnoseDataIssues();
            const hasIssues = diagnosis.issues.length > 0;
            
            this.addResult('数据诊断', true, 
                hasIssues ? `发现${diagnosis.issues.length}个问题` : '数据一致性正常');
            
            // 如果有问题，尝试修复
            if (hasIssues) {
                const fixResult = window.dataFixer.fixDataConsistency();
                this.addResult('数据修复', fixResult.success, 
                    fixResult.success ? `修复了${fixResult.fixCount}个问题` : '修复失败');
                
                // 再次诊断
                const afterFix = window.dataFixer.diagnoseDataIssues();
                this.addResult('修复后诊断', afterFix.issues.length === 0, 
                    afterFix.issues.length === 0 ? '所有问题已修复' : `仍有${afterFix.issues.length}个问题`);
                
                return fixResult.success && afterFix.issues.length === 0;
            }
            
            return true;
        } catch (error) {
            this.addResult('数据一致性测试', false, `测试错误: ${error.message}`);
            return false;
        }
    }
    
    // 添加测试结果
    addResult(name, success, message) {
        this.testResults.push({
            name,
            success,
            message,
            time: new Date().toLocaleTimeString()
        });
        
        console.log(`${success ? '✅' : '❌'} ${name}: ${message}`);
    }
    
    // 显示测试摘要
    showTestSummary() {
        const total = this.testResults.length;
        const passed = this.testResults.filter(r => r.success).length;
        const failed = total - passed;
        
        console.log('\n📊 测试摘要:');
        console.log(`总测试数: ${total}`);
        console.log(`通过: ${passed}`);
        console.log(`失败: ${failed}`);
        
        if (failed > 0) {
            console.log('\n❌ 失败的测试:');
            this.testResults.filter(r => !r.success).forEach(r => {
                console.log(`- ${r.name}: ${r.message}`);
            });
        }
        
        const overallSuccess = failed === 0;
        console.log(`\n${overallSuccess ? '🎉 所有测试通过!' : '⚠️ 部分测试失败'}`);
        
        return {
            success: overallSuccess,
            total,
            passed,
            failed,
            results: this.testResults
        };
    }
    
    // 获取HTML格式的测试报告
    getHtmlReport() {
        const total = this.testResults.length;
        const passed = this.testResults.filter(r => r.success).length;
        const failed = total - passed;
        const overallSuccess = failed === 0;
        
        return `
        <div class="sync-test-report">
            <h3>跨浏览器数据同步测试报告</h3>
            <div class="test-summary">
                <div class="summary-item">
                    <span class="label">总测试数:</span>
                    <span class="value">${total}</span>
                </div>
                <div class="summary-item passed">
                    <span class="label">通过:</span>
                    <span class="value">${passed}</span>
                </div>
                <div class="summary-item ${failed > 0 ? 'failed' : ''}">
                    <span class="label">失败:</span>
                    <span class="value">${failed}</span>
                </div>
                <div class="overall-result ${overallSuccess ? 'success' : 'failure'}">
                    ${overallSuccess ? '🎉 所有测试通过!' : '⚠️ 部分测试失败'}
                </div>
            </div>
            
            <table class="test-results">
                <thead>
                    <tr>
                        <th>测试项</th>
                        <th>结果</th>
                        <th>详情</th>
                        <th>时间</th>
                    </tr>
                </thead>
                <tbody>
                    ${this.testResults.map(r => `
                        <tr class="${r.success ? 'success' : 'failure'}">
                            <td>${r.name}</td>
                            <td>${r.success ? '✅ 通过' : '❌ 失败'}</td>
                            <td>${r.message}</td>
                            <td>${r.time}</td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
            
            <style>
                .sync-test-report {
                    font-family: Arial, sans-serif;
                    max-width: 800px;
                    margin: 20px auto;
                    padding: 20px;
                    border-radius: 8px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    background: #fff;
                }
                .test-summary {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 15px;
                    margin-bottom: 20px;
                    padding: 15px;
                    background: #f5f5f5;
                    border-radius: 6px;
                }
                .summary-item {
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    min-width: 80px;
                }
                .summary-item .label {
                    font-size: 14px;
                    color: #666;
                }
                .summary-item .value {
                    font-size: 24px;
                    font-weight: bold;
                    color: #333;
                }
                .summary-item.passed .value {
                    color: #2ecc71;
                }
                .summary-item.failed .value {
                    color: #e74c3c;
                }
                .overall-result {
                    flex-grow: 1;
                    text-align: center;
                    font-size: 18px;
                    font-weight: bold;
                    padding: 10px;
                    border-radius: 4px;
                }
                .overall-result.success {
                    background: #d5f5e3;
                    color: #27ae60;
                }
                .overall-result.failure {
                    background: #fadbd8;
                    color: #c0392b;
                }
                .test-results {
                    width: 100%;
                    border-collapse: collapse;
                }
                .test-results th, .test-results td {
                    padding: 10px;
                    text-align: left;
                    border-bottom: 1px solid #ddd;
                }
                .test-results th {
                    background: #f2f2f2;
                }
                .test-results tr.success {
                    background: #f8fffa;
                }
                .test-results tr.failure {
                    background: #fff9f9;
                }
            </style>
        </div>
        `;
    }
}

// 创建全局测试实例
window.syncTester = new SyncTester();

// 添加测试按钮到页面
document.addEventListener('DOMContentLoaded', function() {
    // 创建测试按钮
    const testButton = document.createElement('button');
    testButton.id = 'sync-test-button';
    testButton.innerHTML = '测试数据同步';
    testButton.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: #3498db;
        color: white;
        border: none;
        border-radius: 4px;
        padding: 8px 16px;
        font-size: 14px;
        cursor: pointer;
        z-index: 1000;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    `;
    
    // 添加点击事件
    testButton.onclick = async function() {
        testButton.disabled = true;
        testButton.innerHTML = '测试中...';
        
        try {
            await window.syncTester.runFullTest();
            
            // 显示测试报告
            const reportContainer = document.createElement('div');
            reportContainer.id = 'sync-test-report-container';
            reportContainer.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0,0,0,0.7);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 1001;
            `;
            
            reportContainer.innerHTML = window.syncTester.getHtmlReport();
            reportContainer.onclick = function(e) {
                if (e.target === reportContainer) {
                    document.body.removeChild(reportContainer);
                }
            };
            
            // 添加关闭按钮
            const closeButton = document.createElement('button');
            closeButton.innerHTML = '关闭';
            closeButton.style.cssText = `
                position: absolute;
                top: 20px;
                right: 20px;
                background: #e74c3c;
                color: white;
                border: none;
                border-radius: 4px;
                padding: 8px 16px;
                font-size: 14px;
                cursor: pointer;
            `;
            closeButton.onclick = function() {
                document.body.removeChild(reportContainer);
            };
            
            reportContainer.appendChild(closeButton);
            document.body.appendChild(reportContainer);
            
        } catch (error) {
            console.error('测试执行失败:', error);
            alert('测试执行失败: ' + error.message);
        } finally {
            testButton.disabled = false;
            testButton.innerHTML = '测试数据同步';
        }
    };
    
    document.body.appendChild(testButton);
});

console.log('🧪 数据同步测试工具已加载');