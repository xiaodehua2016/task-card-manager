// Vercel API路由 - 安全配置获取
export default function handler(req, res) {
  // 只允许GET请求
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // 验证请求来源
  const allowedOrigins = [
    'https://xiaojiu-task-manager.vercel.app',
    'https://task-manager.vercel.app',
    'http://localhost:3000',
    'http://127.0.0.1:3000'
  ];
  
  const origin = req.headers.origin;
  const referer = req.headers.referer;
  
  // 检查来源域名
  const isValidOrigin = allowedOrigins.some(allowed => 
    origin?.includes(allowed.replace('https://', '').replace('http://', '')) ||
    referer?.includes(allowed.replace('https://', '').replace('http://', ''))
  );
  
  if (!isValidOrigin && process.env.NODE_ENV === 'production') {
    console.log('拒绝访问 - Origin:', origin, 'Referer:', referer);
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  // 设置CORS头
  res.setHeader('Access-Control-Allow-Origin', origin || '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Cache-Control', 'public, max-age=300'); // 5分钟缓存
  
  // 返回配置（从环境变量读取）
  const config = {
    supabaseUrl: process.env.SUPABASE_URL || 'https://zjnjqnftcmxygunzbqch.supabase.co',
    supabaseKey: process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqbmpxbmZ0Y214eWd1bnpicWNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjEwNTQsImV4cCI6MjA2ODkzNzA1NH0.6BVJF0oOAENTWusDthRj1IHcwzCmlhqvv1xxK5jYA2Q',
    timestamp: Date.now(),
    version: '3.0.6'
  };
  
  console.log('配置请求成功 - Origin:', origin);
  res.json(config);
}