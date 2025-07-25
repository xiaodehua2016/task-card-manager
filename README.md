# 小久的任务卡片管理系统 v4.0.0

一个专为儿童设计的友好任务管理工具，帮助培养良好习惯和专注力。

## 🌟 项目特色

- 🎨 **儿童友好界面** - 色彩丰富，操作简单
- 📱 **多设备支持** - 支持电脑、平板、手机访问
- 💾 **多种存储方案** - 支持云端同步和本地文件存储
- 🚀 **多平台部署** - GitHub Pages、Vercel、Gitee Pages
- 🔒 **数据安全** - 本地优先存储，支持数据导入导出
- ⚡ **零依赖部署** - 纯静态文件，无需服务器

## 🎯 功能特性

### 核心功能
- ✅ 任务创建和管理
- ✅ 任务完成状态跟踪
- ✅ 进度可视化显示
- ✅ 每日统计和分析
- ✅ 专注力挑战游戏
- ✅ 成就徽章系统

### 数据管理
- ✅ 本地文件存储（IndexedDB + LocalStorage）
- ✅ 云端数据同步（Supabase）
- ✅ 数据导入导出功能
- ✅ 自动备份提醒
- ✅ 多设备数据同步

### 部署方案
- ✅ GitHub Pages（国际访问）
- ✅ Vercel（全球CDN）
- ✅ Gitee Pages（国内优化）
- ✅ 腾讯云静态托管（可选）

## 🚀 快速开始

### 在线访问
- **GitHub Pages**: https://xiaodehua2016.github.io/task-card-manager/
- **Vercel**: https://xiaojiu-task-manager.vercel.app/
- **Gitee Pages**: 即将上线

### 本地运行
```bash
# 克隆项目
git clone https://github.com/xiaodehua2016/task-card-manager.git

# 进入项目目录
cd task-card-manager

# 使用任意HTTP服务器运行
# 方法1：使用Python
python -m http.server 8000

# 方法2：使用Node.js
npx serve .

# 方法3：直接打开index.html
```

## 📁 项目结构

```
task-card-manager/
├── index.html              # 主页面
├── edit-tasks.html         # 任务编辑页面
├── statistics.html         # 统计页面
├── focus-challenge.html    # 专注挑战页面
├── today-tasks.html        # 今日任务管理
├── css/                    # 样式文件
│   ├── main.css           # 主样式
│   ├── cards.css          # 卡片样式
│   └── animations.css     # 动画效果
├── js/                     # JavaScript文件
│   ├── main.js            # 主逻辑（云端版本）
│   ├── main-file-only.js  # 主逻辑（文件存储版本）
│   ├── storage.js         # 存储管理
│   ├── file-storage.js    # 文件存储系统
│   ├── import-export.js   # 数据导入导出
│   └── supabase-config.js # 云端配置
├── config/                 # 配置文件
│   └── supabase.js        # 数据库配置
├── api/                    # API路由（Vercel）
│   └── config.js          # 安全配置接口
├── deploy/                 # 部署文档
│   ├── GITEE_PAGES_DEPLOYMENT.md
│   ├── VERCEL_DEPLOYMENT_LOG.md
│   └── ...
└── README.md              # 项目说明
```

## 🛠️ 技术栈

### 前端技术
- **HTML5** - 语义化标记
- **CSS3** - 现代样式和动画
- **JavaScript ES6+** - 原生JavaScript，无框架依赖
- **PWA** - 渐进式Web应用支持

### 存储方案
- **IndexedDB** - 主要本地存储
- **LocalStorage** - 备份存储
- **Supabase** - 云端数据库（可选）

### 部署平台
- **GitHub Pages** - 静态网站托管
- **Vercel** - 现代化部署平台
- **Gitee Pages** - 国内访问优化

## 📊 版本历史

### v4.0.0 (2025-01-25) - 文件存储重构版
- 🆕 新增完整的文件存储系统
- 🆕 支持数据导入导出功能
- 🆕 多平台部署架构
- 🔧 优化安全配置管理
- 🔧 改进移动端兼容性
- 📚 完善项目文档

### v3.0.6 (2025-01-24) - 稳定优化版
- 🔧 修复数据同步一致性问题
- 🔧 优化错误处理机制
- 🔧 改进用户体验
- 📱 增强移动端支持

### v3.0.1-3.0.5 - 迭代修复版本
- 🐛 修复Supabase配置问题
- 🐛 解决跨浏览器同步问题
- 🐛 修复用户管理逻辑
- 🧹 清理数据库冗余数据

## 🎯 使用指南

### 基础使用
1. **创建任务** - 在任务编辑页面添加新任务
2. **完成任务** - 点击任务卡片上的"标记完成"按钮
3. **查看进度** - 主页面显示当日完成进度
4. **查看统计** - 统计页面显示历史数据分析

### 数据管理
1. **导出数据** - 设置页面点击"导出数据"
2. **导入数据** - 选择JSON文件进行数据导入
3. **多设备同步** - 通过导出/导入实现设备间数据同步

### 专注挑战
1. **设置时间** - 选择专注时长（15-60分钟）
2. **开始挑战** - 点击开始按钮进入专注模式
3. **完成奖励** - 完成后获得成就徽章

## 🔧 开发指南

### 环境要求
- Node.js 16+ （用于开发工具）
- 现代浏览器（Chrome 80+, Firefox 75+, Safari 13+）

### 开发命令
```bash
# 安装开发依赖（可选）
npm install -g live-server

# 启动开发服务器
live-server --port=8080

# 代码格式化（如果使用Prettier）
npx prettier --write "**/*.{js,css,html}"
```

### 构建部署
```bash
# 提交代码
git add .
git commit -m "feat: 新功能描述"
git push origin main

# 自动触发部署到各平台
```

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 提交规范
- `feat:` 新功能
- `fix:` 修复bug
- `docs:` 文档更新
- `style:` 代码格式调整
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建过程或辅助工具的变动

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- 感谢所有使用和反馈的用户
- 感谢开源社区的支持
- 特别感谢CodeBuddy AI的开发协助

## 📞 联系方式

- GitHub: [@xiaodehua2016](https://github.com/xiaodehua2016)
- 项目地址: https://github.com/xiaodehua2016/task-card-manager
- 问题反馈: [GitHub Issues](https://github.com/xiaodehua2016/task-card-manager/issues)

---

**让我们一起帮助孩子们培养良好的习惯！** 🌟