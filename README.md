# 小久的任务卡片管理系统 v3.0

[![版本](https://img.shields.io/badge/版本-v3.0.0-blue.svg)](https://github.com/用户名/仓库名/releases/tag/v3.0.0)
[![部署状态](https://img.shields.io/badge/部署-GitHub%20Pages-green.svg)](https://用户名.github.io/仓库名)
[![数据库](https://img.shields.io/badge/数据库-Supabase-orange.svg)](https://supabase.com)

一个专为儿童设计的任务管理Web应用，支持多设备实时同步。

## ✨ 主要功能

- 📋 **任务管理**: 支持每日任务、一次性任务、例行任务
- ⏰ **专注力训练**: 内置番茄钟功能，培养专注习惯
- 📊 **数据统计**: 可视化完成情况，激励持续进步
- 🏆 **成就系统**: 多种徽章奖励，增加使用乐趣
- 🔄 **多设备同步**: 支持手机、平板、电脑间实时数据同步
- 🎨 **儿童友好**: 卡通风格界面，操作简单直观

## 🚀 快速开始

### 在线体验
访问 [GitHub Pages 演示](https://your-username.github.io/task-card-manager)

### 本地运行
```bash
# 克隆项目
git clone https://github.com/your-username/task-card-manager.git
cd task-card-manager

# 启动本地服务器
python -m http.server 8000
# 或使用Node.js
npx serve .

# 访问 http://localhost:8000
```

## 🔧 部署配置

### 方案一：仅本地使用
直接打开 `index.html` 即可使用，数据存储在浏览器本地。

### 方案二：多设备同步部署
支持真正的多设备数据同步，推荐用于家庭多设备使用。

#### 1. 创建Supabase项目
```bash
# 访问 https://supabase.com 创建项目
# 执行 DEPLOYMENT.md 中的SQL创建数据表
```

#### 2. 配置项目
```bash
# 使用自动配置脚本
node deploy-setup.js setup <你的Supabase-URL> <你的API-Key>

# 或手动创建配置文件
cp config/supabase.example.js config/supabase.js
# 编辑 config/supabase.js 填入实际配置
```

#### 3. 部署到GitHub Pages
```bash
# 推送代码到GitHub
git add .
git commit -m "配置Supabase同步"
git push origin main

# GitHub Actions会自动部署到Pages
```

详细部署说明请查看：
- [🚀 快速开始指南](./QUICK_START.md) - 5分钟快速部署
- [🌐 无Node.js使用指南](./NO_NODEJS_GUIDE.md) - 无需安装Node.js
- [⚙️ Node.js环境安装](./NODE_SETUP.md) - 环境配置指南
- [🔧 Node.js问题修复](./FIX_NODE_INSTALLATION.md) - 安装问题解决
- [📋 完整部署指南](./DEPLOYMENT.md) - 详细步骤说明  
- [🛠️ 故障排除指南](./TROUBLESHOOTING.md) - 常见问题解决

## 📱 使用说明

### 基本操作
1. **添加任务**: 点击"编辑任务"按钮添加新任务
2. **完成任务**: 点击任务卡片上的"完成"按钮
3. **专注训练**: 点击"开始执行"进入专注模式
4. **查看统计**: 点击"查看统计"了解完成情况

### 多设备同步
- 在任意设备上修改任务状态
- 其他设备会自动同步最新数据
- 支持离线使用，联网后自动同步

### 任务类型
- **每日任务**: 每天重复的固定任务
- **一次性任务**: 有截止日期的临时任务
- **例行任务**: 按周期重复的任务

## 🎯 技术特性

### 前端技术
- **纯前端**: HTML5 + CSS3 + 原生JavaScript
- **响应式设计**: 支持手机、平板、桌面设备
- **PWA就绪**: 支持离线使用和桌面安装
- **无框架依赖**: 轻量级，加载速度快

### 数据同步
- **本地优先**: 所有操作先在本地完成，确保流畅体验
- **云端备份**: 自动同步到Supabase云数据库
- **冲突解决**: 智能合并多设备间的数据变更
- **离线支持**: 网络断开时仍可正常使用

### 安全性
- **数据加密**: 传输过程使用HTTPS加密
- **隐私保护**: 数据仅存储必要信息
- **访问控制**: 每个用户只能访问自己的数据

## 📊 项目结构

```
task-card-manager/
├── index.html              # 主页面
├── edit-tasks.html         # 任务编辑页面
├── focus-challenge.html    # 专注力挑战页面
├── statistics.html         # 统计分析页面
├── today-tasks.html        # 今日任务管理页面
├── css/                    # 样式文件
│   ├── main.css           # 主样式
│   ├── cards.css          # 任务卡片样式
│   └── ...                # 其他样式文件
├── js/                     # JavaScript文件
│   ├── storage.js         # 数据存储管理
│   ├── main.js            # 主页面逻辑
│   ├── supabase-config.js # 云端同步配置
│   └── ...                # 其他功能模块
├── config/                 # 配置文件
│   └── supabase.example.js # Supabase配置示例
├── .github/workflows/      # GitHub Actions
│   └── deploy.yml         # 自动部署配置
└── docs/                   # 文档文件
    ├── DEPLOYMENT.md      # 部署指南
    └── README.md          # 项目说明
```

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 开发环境设置
```bash
# 克隆项目
git clone https://github.com/your-username/task-card-manager.git
cd task-card-manager

# 安装开发依赖（可选）
npm install -g live-server

# 启动开发服务器
live-server --port=8000
```

### 提交规范
- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 样式调整
- refactor: 代码重构

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- [Supabase](https://supabase.com) - 提供云端数据库服务
- [GitHub Pages](https://pages.github.com) - 提供免费静态网站托管
- 所有贡献者和用户的支持

## 🔧 故障排除

如果遇到问题，请查看：
- `deploy/TROUBLESHOOTING.md` - 详细的故障排除指南
- `installenv/NODE_SETUP.md` - Node.js环境配置
- `PROJECT_STATUS.md` - 项目完整状态报告

## 📞 联系方式

- 项目地址: https://github.com/your-username/task-card-manager
- 问题反馈: [GitHub Issues](https://github.com/your-username/task-card-manager/issues)
- 项目文档: 查看 `deploy/` 和 `installenv/` 目录

## 🎉 项目状态

✅ **核心功能完成**: 任务管理、数据统计、专注训练  
✅ **多设备同步**: 支持手机、平板、电脑间实时数据同步  
✅ **云端备份**: 基于Supabase的安全数据存储  
✅ **部署就绪**: 可一键部署到GitHub Pages  
✅ **文档完整**: 详细的部署和使用指南  

---

**让孩子在游戏化的任务管理中培养良好习惯！** 🌟  
**现在支持多设备实时同步，随时随地管理任务！** 📱💻🖥️
