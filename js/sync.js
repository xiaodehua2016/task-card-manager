/**
 * 小久任务管理系统 - 智能同步逻辑 (v5.0 重构版)
 * 解决同步刷屏问题，提供稳定、低干扰的后台同步
 */
document.addEventListener('DOMContentLoaded', () => {
    // 确保 TaskManager 主应用已加载
    if (!window.TaskManager) {
        console.error("Sync script loaded before main app. Aborting sync initialization.");
        return;
    }

    const Sync = {
        // --- 配置 ---
        config: {
            apiUrl: 'api/data-sync.php', // 主API端点
            syncInterval: 15000, // 同步间隔15秒，降低频率
            requestTimeout: 8000, // 请求超时8秒
            initialDelay: 3000   // 初始延迟3秒
        },

        // --- 状态 ---
        state: {
            syncTimer: null,
            isSyncing: false,
            lastServerUpdateTime: 0 // 上次已知的服务器时间戳
        },

        // --- 初始化 ---
        init() {
            console.log("Initializing Smart Sync v5.0...");
            setTimeout(() => {
                this.start();
            }, this.config.initialDelay);
        },

        // --- 同步控制 ---
        start() {
            if (this.state.syncTimer) {
                clearInterval(this.state.syncTimer);
            }
            this.state.syncTimer = setInterval(() => this.runSync(), this.config.syncInterval);
            console.log(`Sync started. Interval: ${this.config.syncInterval / 1000}s`);
            this.runSync(); // 立即执行一次
        },

        stop() {
            if (this.state.syncTimer) {
                clearInterval(this.state.syncTimer);
                this.state.syncTimer = null;
                console.log("Sync stopped.");
            }
        },

        // --- 核心同步流程 ---
        async runSync() {
            if (this.state.isSyncing) {
                console.log("Sync already in progress. Skipping.");
                return;
            }
            this.state.isSyncing = true;
            console.log("Running sync...");

            try {
                const localData = window.TaskManager.state.data;
                const localUpdateTime = localData.lastUpdateTime || 0;

                // 1. 从服务器获取最新数据和时间戳
                const serverResponse = await this.fetchWithTimeout(`${this.config.apiUrl}?action=get`);
                if (!serverResponse.ok) throw new Error(`Server responded with status ${serverResponse.status}`);
                
                const serverResult = await serverResponse.json();
                if (!serverResult.data) throw new Error("Invalid data from server.");

                const serverData = serverResult.data;
                const serverUpdateTime = serverData.lastUpdateTime || 0;

                // 2. 智能决策
                if (localUpdateTime > serverUpdateTime) {
                    // 本地数据更新，推送到服务器
                    console.log("Local data is newer. Pushing to server.");
                    await this.pushToServer(localData);
                    this.state.lastServerUpdateTime = localUpdateTime;
                    this.showNotification("数据已成功同步到云端！", "success");

                } else if (serverUpdateTime > localUpdateTime && serverUpdateTime > this.state.lastServerUpdateTime) {
                    // 服务器数据更新，且是新版本，拉取到本地
                    console.log("Server data is newer. Pulling to local.");
                    window.TaskManager.state.data = serverData;
                    window.TaskManager.saveData();
                    window.TaskManager.renderAll(); // 重新渲染UI
                    this.state.lastServerUpdateTime = serverUpdateTime;
                    this.showNotification("数据已从云端更新！", "success");

                } else {
                    // 数据一致，无需操作
                    console.log("Data is already in sync.");
                    // 只有在第一次或手动检查时才提示
                    if (this.state.lastServerUpdateTime === 0) {
                         this.showNotification("数据已同步", "info");
                    }
                    this.state.lastServerUpdateTime = serverUpdateTime;
                }

            } catch (error) {
                console.error("Sync failed:", error);
                this.showNotification(`同步失败: ${error.message}`, "error");
            } finally {
                this.state.isSyncing = false;
            }
        },

        // --- 网络请求 ---
        async pushToServer(data) {
            const response = await this.fetchWithTimeout(this.config.apiUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'update', data: data })
            });
            if (!response.ok) throw new Error('Failed to push data to server.');
            return response.json();
        },

        fetchWithTimeout(resource, options = {}) {
            const { timeout = this.config.requestTimeout } = options;
            const controller = new AbortController();
            const id = setTimeout(() => controller.abort(), timeout);
            return fetch(resource, {
                ...options,
                signal: controller.signal
            }).finally(() => {
                clearTimeout(id);
            });
        },

        // --- UI通知 ---
        showNotification(message, type = 'info') {
            let notificationEl = document.getElementById('sync-notification');
            if (!notificationEl) {
                notificationEl = document.createElement('div');
                notificationEl.id = 'sync-notification';
                document.body.appendChild(notificationEl);
            }

            notificationEl.textContent = message;
            notificationEl.className = `sync-notification ${type} show`;

            // 避免重复的计时器
            if (notificationEl.hideTimer) {
                clearTimeout(notificationEl.hideTimer);
            }

            notificationEl.hideTimer = setTimeout(() => {
                notificationEl.classList.remove('show');
            }, 3000);
        }
    };

    // 启动同步
    Sync.init();
});