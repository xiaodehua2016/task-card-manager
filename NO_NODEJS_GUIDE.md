# 无Node.js环境使用指南

## 🎯 适用场景
- 不想安装Node.js
- Node.js安装失败
- npm命令无法使用
- 希望快速配置项目

## 🚀 三种无Node.js配置方案

### 方案一：浏览器配置工具（推荐）

1. **打开配置工具**
   - 双击 `simple-setup.html` 文件
   - 在浏览器中打开配置界面

2. **填写配置信息**
   - Supabase项目URL：`https://你的项目ID.supabase.co`
   - API密钥：从Supabase控制台复制

3. **生成并下载配置文件**
   - 点击"生成配置文件"按钮
   - 自动下载 `supabase.js` 文件

4. **放置配置文件**
   - 将下载的文件放到项目的 `config` 文件夹中
   - 确保路径为：`config/supabase.js`

### 方案二：手动复制配置

1. **复制配置模板**
   ```cmd
   # Windows命令提示符
   copy config\supabase.example.js config\supabase.js
   ```

2. **编辑配置文件**
   - 用记事本打开 `config\supabase.js`
   - 找到这两行：
     ```javascript
     url: 'https://your-project-id.supabase.co',
     anonKey: 'your-anon-key-here',
     ```
   - 替换为实际的URL和密钥

3. **保存文件**
   - 保存并关闭编辑器

### 方案三：在线配置生成器

如果本地文件无法使用，可以使用在线工具：

1. **访问在线生成器**（示例代码）
   ```html
   <!-- 可以创建一个简单的HTML页面 -->
   <textarea id="url" placeholder="输入Supabase URL"></textarea>
   <textarea id="key" placeholder="输入API密钥"></textarea>
   <button onclick="generateConfig()">生成配置</button>
   <pre id="output"></pre>
   
   <script>
   function generateConfig() {
       const url = document.getElementById('url').value;
       const key = document.getElementById('key').value;
       const config = `window.SUPABASE_CONFIG = {
           url: '${url}',
           anonKey: '${key}',
           options: {
               auth: {
                   autoRefreshToken: true,
                   persistSession: true,
                   detectSessionInUrl: true
               }
           }
       };`;
       document.getElementById('output').textContent = config;
   }
   </script>
   ```

## 🔧 本地运行项目

### 方法一：直接打开HTML文件
- 双击 `index.html` 文件
- 在浏览器中直接运行

### 方法二：使用Python服务器
```cmd
# 如果安装了Python
python -m http.server 8000
# 然后访问 http://localhost:8000
```

### 方法三：使用其他工具
- **Live Server**（VS Code插件）
- **XAMPP**（包含Apache服务器）
- **WAMP**（Windows Apache MySQL PHP）

## 📱 移动端测试

### 局域网访问
1. **获取电脑IP地址**
   ```cmd
   ipconfig
   # 找到IPv4地址，如：192.168.1.100
   ```

2. **启动本地服务器**
   ```cmd
   python -m http.server 8000
   ```

3. **手机访问**
   - 确保手机和电脑在同一WiFi
   - 在手机浏览器输入：`http://192.168.1.100:8000`

### GitHub Pages部署
1. **推送代码到GitHub**
   ```cmd
   git add .
   git commit -m "添加Supabase配置"
   git push origin main
   ```

2. **启用GitHub Pages**
   - 进入仓库设置
   - 找到Pages选项
   - 选择GitHub Actions作为源

3. **访问在线版本**
   - 使用GitHub提供的链接
   - 在任何设备上访问

## ✅ 验证配置成功

### 检查配置文件
1. 确认 `config/supabase.js` 文件存在
2. 打开文件检查URL和密钥是否正确
3. 确保没有语法错误

### 测试功能
1. **打开项目**
   - 在浏览器中打开 `index.html`

2. **检查控制台**
   - 按F12打开开发者工具
   - 查看Console标签
   - 应该看到"Supabase配置已加载"消息

3. **测试同步**
   - 修改任务状态
   - 在另一个浏览器标签页刷新
   - 确认数据已同步

## 🚨 常见问题

### 问题1：配置文件不生效
**解决方案**：
- 检查文件路径是否正确
- 确认文件名为 `supabase.js`
- 检查HTML文件是否正确引用

### 问题2：跨域错误
**解决方案**：
- 不要直接双击HTML文件
- 使用本地服务器运行
- 或部署到GitHub Pages

### 问题3：数据不同步
**解决方案**：
- 检查Supabase项目状态
- 验证API密钥是否正确
- 查看浏览器控制台错误信息

### 问题4：移动端无法访问
**解决方案**：
- 确保设备在同一网络
- 检查防火墙设置
- 使用GitHub Pages在线访问

## 📋 完整配置检查清单

- [ ] Supabase项目已创建
- [ ] 数据库表已创建
- [ ] 获取了正确的URL和API密钥
- [ ] 配置文件已创建：`config/supabase.js`
- [ ] HTML文件正确引用配置文件
- [ ] 本地可以正常运行
- [ ] 多设备同步功能正常

## 💡 小贴士

1. **备份配置**：保存好URL和API密钥
2. **测试环境**：先在本地测试，再部署
3. **移动优先**：确保移动端体验良好
4. **定期更新**：关注Supabase服务状态

## 🎉 成功标志

当您看到以下情况时，说明配置成功：
- 页面正常加载，没有错误
- 可以添加和修改任务
- 不同设备间数据能够同步
- 离线使用后联网能自动同步

无需Node.js，您也能享受完整的多设备同步功能！