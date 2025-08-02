# 小久任务管理系统 v4.2.2.1 部署目录说明

## 📋 部署文件说明

本目录包含小久任务管理系统v4.2.2.1的部署相关文件。为了保持目录整洁，建议只保留以下必要文件，其他历史文件可以移动到`history`子目录中。

### 必要保留的文件

以下是v4.2.2.1版本需要保留的核心部署文件：

1. **PowerShell脚本**
   - `deploy-v4.2.2.1.ps1` - 主要部署脚本
   - `git-deploy-v4.2.2.1.ps1` - Git部署脚本

2. **批处理文件**
   - `部署到服务器-v4.2.2.1.bat` - 服务器部署批处理文件
   - `一键部署-v4.2.2.1.bat` - 一键部署批处理文件
   - `快速部署-v4.2.2.1.bat` - 简化版部署批处理文件
   - `Git部署-v4.2.2.1.bat` - Git部署批处理文件

3. **文档文件**
   - `部署指南-v4.2.2.1.md` - 详细的部署指南
   - `README.md` - 本说明文件

### 手动整理步骤

1. 创建history子目录（如果不存在）
   ```
   mkdir history
   ```

2. 将除了上述必要文件外的所有文件移动到history目录
   ```
   move *.* history/
   ```

3. 将必要文件移回deploy目录
   ```
   move history/deploy-v4.2.2.1.ps1 ./
   move history/git-deploy-v4.2.2.1.ps1 ./
   move history/部署到服务器-v4.2.2.1.bat ./
   move history/一键部署-v4.2.2.1.bat ./
   move history/快速部署-v4.2.2.1.bat ./
   move history/Git部署-v4.2.2.1.bat ./
   move history/部署指南-v4.2.2.1.md ./
   move history/README.md ./
   ```

## 🚀 部署方式概述

本系统提供多种部署方式，可根据需求选择最适合的方式：

1. **自动部署到服务器** - 通过PowerShell脚本自动上传并部署到服务器
2. **手动部署到服务器** - 创建部署包后手动上传到服务器（推荐）
3. **Git部署** - 通过Git提交并推送到GitHub/Vercel等平台
4. **仅创建部署包** - 只创建部署包，不执行部署操作

## 📦 部署包说明

部署脚本会自动创建一个名为 `task-manager-v4.2.2.1-complete.zip` 的完整部署包，包含以下内容：

- HTML文件 (index.html, sync-test.html等)
- CSS文件 (css目录)
- JavaScript文件 (js目录)
- API文件 (api目录)
- 数据文件 (data目录)

## 🔧 服务器部署详细步骤

### 手动部署（推荐）

1. 运行 `一键部署-v4.2.2.1.bat` 并选择选项2
2. 脚本会创建部署包 `task-manager-v4.2.2.1-complete.zip`
3. 使用以下方法之一上传部署包：
   - **宝塔面板**（推荐）：
     - 登录宝塔面板 (http://115.159.5.111:8888)
     - 进入文件管理器
     - 上传部署包到 `/www/wwwroot/`
     - 解压到 `/www/wwwroot/task-manager/`
     - 设置权限：所有者 www，权限 755

4. 服务器上的命令（通过SSH或宝塔终端执行）：
   ```bash
   cd /www/wwwroot/
   unzip -o task-manager-v4.2.2.1-complete.zip -d task-manager/
   chown -R www:www task-manager/
   chmod -R 755 task-manager/
   ```

## 📊 v4.2.2.1 版本特性

- ✅ 跨浏览器数据同步 - 彻底修复
- ✅ 实时数据同步 - 3秒内完成
- ✅ 智能错误恢复 - 自动修复机制
- ✅ 本地存储监听 - 即时触发同步
- ✅ 可视化诊断 - 问题排查利器
- ✅ 简化部署流程 - 一个文件搞定
- ✅ 增强部署脚本 - 更稳定可靠

## 🆕 v4.2.2.1 更新内容

此版本主要修复了部署脚本中的问题：

1. 修复了文件复制过程中的错误处理
2. 增强了文件和目录检查机制
3. 改进了字符编码处理
4. 优化了部署流程的稳定性
5. 增加了更详细的错误提示和日志记录