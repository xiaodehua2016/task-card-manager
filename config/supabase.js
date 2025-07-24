// Supabase配置文件
// 已配置实际的项目信息

window.SUPABASE_CONFIG = {
    // Supabase项目配置
    url: 'https://zjnjqnftcmxygunzbqch.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqbmpxbmZ0Y214eWd1bnpicWNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjEwNTQsImV4cCI6MjA2ODkzNzA1NH0.6BVJF0oOAENTWusDthRj1IHcwzCmlhqvv1xxK5jYA2Q',
    
    // 可选配置
    options: {
        auth: {
            autoRefreshToken: true,
            persistSession: true,
            detectSessionInUrl: true
        }
    }
};

// 配置加载确认
console.log('✅ Supabase配置已加载');