// Supabase配置文件
class SupabaseConfig {
    constructor() {
        this.supabase = null;
        this.currentUser = null;
        this.isConfigured = false;
        
        // 动态加载配置
        this.loadConfig().then(() => {
            if (this.isConfigured) {
                this.init();
            } else {
                console.warn('Supabase未配置，将仅使用本地存储');
            }
        });
    }

    // 动态加载配置
    async loadConfig() {
        console.log('🔄 开始加载Supabase配置...');
        
        try {
            // 方法1: 从Vercel API获取配置
            console.log('尝试从API加载配置...');
            const response = await fetch('/api/config', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                const config = await response.json();
                this.supabaseUrl = config.supabaseUrl;
                this.supabaseKey = config.supabaseKey;
                this.isConfigured = true;
                console.log('✅ 从API加载配置成功');
                return;
            } else {
                console.warn('API配置加载失败，状态码:', response.status);
            }
        } catch (error) {
            console.warn('API配置加载失败:', error.message);
        }
        
        try {
            // 方法2: 从本地配置文件获取（降级方案）
            if (window.SUPABASE_CONFIG) {
                console.log('使用本地配置文件...');
                this.supabaseUrl = window.SUPABASE_CONFIG.url;
                this.supabaseKey = window.SUPABASE_CONFIG.anonKey;
                this.isConfigured = true;
                console.log('✅ 使用本地配置成功');
                return;
            }
        } catch (error) {
            console.warn('本地配置加载失败:', error.message);
        }
        
        // 方法3: 使用默认配置（最后的降级方案）
        console.warn('使用默认配置...');
        this.supabaseUrl = 'https://zjnjqnftcmxygunzbqch.supabase.co';
        this.supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqbmpxbmZ0Y214eWd1bnpicWNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjEwNTQsImV4cCI6MjA2ODkzNzA1NH0.6BVJF0oOAENTWusDthRj1IHcwzCmlhqvv1xxK5jYA2Q';
        this.isConfigured = true;
        console.log('⚠️ 使用默认配置');
    }

    // 初始化Supabase客户端
    async init() {
        if (!this.isConfigured) {
            console.log('Supabase未配置，跳过初始化');
            return false;
        }

        try {
            // 动态加载Supabase SDK
            if (!window.supabase) {
                await this.loadSupabaseSDK();
            }
            
            this.supabase = window.supabase.createClient(this.supabaseUrl, this.supabaseKey);
            console.log('Supabase客户端初始化成功');
            
            // 测试连接
            const { data, error } = await this.supabase.from('users').select('count').limit(1);
            if (error && error.code !== 'PGRST116') {
                throw new Error(`数据库连接测试失败: ${error.message}`);
            }
            
            // 检查用户登录状态
            await this.checkUser();
            return true;
        } catch (error) {
            console.error('Supabase初始化失败:', error);
            this.isConfigured = false;
            return false;
        }
    }

    // 动态加载Supabase SDK
    async loadSupabaseSDK() {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
            script.onload = resolve;
            script.onerror = reject;
            document.head.appendChild(script);
        });
    }

    // 检查或创建用户
    // 检查或创建用户（单用户系统）
    async checkUser() {
        if (!this.supabase) {
            console.warn('Supabase客户端未初始化');
            return null;
        }

        try {
            const username = window.taskStorage?.getUsername() || '小久';
            
            // 首先尝试查找现有的用户（按用户名）
            const { data: existingUsers, error: searchError } = await this.supabase
                .from('users')
                .select('id, username')
                .eq('username', username)
                .limit(1);
            
            if (searchError) {
                console.error('查找用户失败:', searchError);
                throw searchError;
            }
            
            if (existingUsers && existingUsers.length > 0) {
                // 找到现有用户，使用第一个
                this.currentUser = existingUsers[0];
                localStorage.setItem('supabase_user_id', this.currentUser.id);
                console.log('✅ 使用现有用户:', this.currentUser);
                return this.currentUser;
            }
            
            // 如果没有找到用户，检查是否有任何用户存在
            const { data: allUsers, error: countError } = await this.supabase
                .from('users')
                .select('id, username')
                .limit(1);
            
            if (countError) {
                console.error('检查用户数量失败:', countError);
                throw countError;
            }
            
            if (allUsers && allUsers.length > 0) {
                // 如果已经有用户存在，使用第一个用户
                this.currentUser = allUsers[0];
                localStorage.setItem('supabase_user_id', this.currentUser.id);
                console.log('✅ 使用系统中的第一个用户:', this.currentUser);
                
                // 更新用户名为当前设置的用户名
                if (this.currentUser.username !== username) {
                    await this.supabase
                        .from('users')
                        .update({ username: username })
                        .eq('id', this.currentUser.id);
                    this.currentUser.username = username;
                    console.log('✅ 已更新用户名为:', username);
                }
                
                return this.currentUser;
            }
            
            // 如果没有任何用户，创建第一个用户
            const { data, error } = await this.supabase
                .from('users')
                .insert([{ username: username }])
                .select()
                .single();
            
            if (error) {
                console.error('创建用户失败:', error);
                throw error;
            }
            
            this.currentUser = data;
            localStorage.setItem('supabase_user_id', this.currentUser.id);
            console.log('✅ 创建新用户成功:', this.currentUser);
            
            return this.currentUser;
            
        } catch (error) {
            console.error('用户检查失败:', error);
            return null;
        }
    }

    // 上传数据到云端
    async uploadData(data) {
        if (!this.isConfigured || !this.supabase || !this.currentUser) {
            console.warn('Supabase未配置或未初始化，跳过数据上传');
            return null;
        }

        try {
            // 确保数据包含必要字段
            const uploadData = {
                user_id: this.currentUser.id,
                data: data,
                last_update_time: data.lastUpdateTime || Date.now()
            };

            const { data: result, error } = await this.supabase
                .from('task_data')
                .upsert([uploadData], {
                    onConflict: 'user_id'
                })
                .select()
                .single();

            if (error) {
                console.error('数据上传错误:', error);
                throw error;
            }
            
            console.log('数据上传成功:', result);
            return result;
        } catch (error) {
            console.error('数据上传失败:', error);
            // 不抛出错误，允许本地继续工作
            return null;
        }
    }

    // 从云端下载数据
    async downloadData() {
        if (!this.isConfigured || !this.supabase || !this.currentUser) {
            console.warn('Supabase未配置或未初始化，跳过数据下载');
            return null;
        }

        try {
            const { data, error } = await this.supabase
                .from('task_data')
                .select('data')
                .eq('user_id', this.currentUser.id)
                .single();

            if (error && error.code !== 'PGRST116') { // PGRST116 = 没有找到记录
                console.error('数据下载错误:', error);
                throw error;
            }

            console.log('数据下载成功:', data);
            return data?.data || null;
        } catch (error) {
            console.error('数据下载失败:', error);
            // 不抛出错误，允许本地继续工作
            return null;
        }
    }

    // 监听实时数据变化
    // 监听实时数据变化
    subscribeToChanges(callback) {
        if (!this.supabase || !this.currentUser) {
            console.warn('无法订阅数据变化：Supabase未初始化');
            return null;
        }

        const subscription = this.supabase
            .channel('task_data_changes')
            .on('postgres_changes', {
                event: '*',
                schema: 'public',
                table: 'task_data',
                filter: `user_id=eq.${this.currentUser.id}`
            }, async (payload) => {
                console.log('🔄 收到实时数据变化:', payload);
                
                // 处理数据更新
                if (payload.eventType === 'UPDATE' || payload.eventType === 'INSERT') {
                    const newData = payload.new?.data;
                    if (newData && callback) {
                        console.log('📥 应用远程数据更新');
                        callback(newData);
                        
                        // 显示同步提示
                        this.showSyncNotification('数据已从其他设备同步');
                    }
                }
            })
            .subscribe((status) => {
                console.log('📡 实时订阅状态:', status);
            });

        return subscription;
    }

    // 显示同步通知
    showSyncNotification(message) {
        // 创建或更新通知元素
        let notification = document.getElementById('sync-notification');
        if (!notification) {
            notification = document.createElement('div');
            notification.id = 'sync-notification';
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: #4CAF50;
                color: white;
                padding: 12px 20px;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                z-index: 10000;
                font-size: 14px;
                transform: translateX(100%);
                transition: transform 0.3s ease;
            `;
            document.body.appendChild(notification);
        }

        notification.textContent = message;
        notification.style.transform = 'translateX(0)';

        // 3秒后隐藏
        setTimeout(() => {
            notification.style.transform = 'translateX(100%)';
        }, 3000);
    }

    // 强制同步数据
    async forceSyncData() {
        if (!this.isConfigured || !this.supabase || !this.currentUser) {
            console.warn('无法强制同步：Supabase未配置');
            return false;
        }

        try {
            console.log('🔄 开始强制同步数据...');
            
            // 下载最新数据
            const cloudData = await this.downloadData();
            if (cloudData && window.taskStorage) {
                // 比较时间戳，使用最新的数据
                const localData = window.taskStorage.getAllData();
                const cloudTime = cloudData.lastUpdateTime || 0;
                const localTime = localData.lastUpdateTime || 0;
                
                if (cloudTime > localTime) {
                    console.log('📥 应用云端数据（更新）');
                    window.taskStorage.loadFromData(cloudData);
                    this.showSyncNotification('已同步最新数据');
                    
                    // 刷新页面显示
                    if (typeof window.refreshDisplay === 'function') {
                        window.refreshDisplay();
                    }
                    return true;
                } else {
                    console.log('📤 本地数据更新，上传到云端');
                    await this.uploadData(localData);
                    return true;
                }
            }
            
            return false;
        } catch (error) {
            console.error('强制同步失败:', error);
            return false;
        }
    }

    // 检查网络连接状态
    isOnline() {
        return navigator.onLine;
    }
}

// 创建全局实例
window.supabaseConfig = new SupabaseConfig();