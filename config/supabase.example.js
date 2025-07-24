// Supabase配置示例文件
// 复制此文件为 supabase.js 并填入你的实际配置

window.SUPABASE_CONFIG = {
    // 在Supabase项目设置中获取这些值
    url: 'https://your-project-id.supabase.co',
    anonKey: 'your-anon-key-here',
    
    // 可选配置
    options: {
        auth: {
            autoRefreshToken: true,
            persistSession: true,
            detectSessionInUrl: true
        }
    }
};