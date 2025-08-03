# 任务管理系统 v5.0.0 部署手册

本文档提供两种将 v5.0.0 重构版部署到服务器的方法：
1.  **方法A：通过 Git 发布 (推荐)** - 适合版本控制和持续集成。
2.  **方法B：手动打包部署** - 适合快速、一次性的部署。

---

## 方法A：通过 Git 发布 (推荐)

此方法假设您已经将项目初始化为 Git 仓库，并已设置好远程仓库地址。

### 步骤 1: 将所有更改添加到暂存区

打开项目根目录下的终端，执行以下命令：

```bash
# 添加所有文件的更改，包括新增、修改和删除的文件
git add .
```

### 步骤 2: 提交更改

创建一个清晰的提交信息，以标记这次重大的重构。

```bash
# 提交更改并附上说明
git commit -m "feat: Refactor project to v5.0.0" -m "- 重构核心逻辑 main.js 和同步逻辑 sync.js.
- 删除了所有临时的修复脚本和测试页面.
- 解决了 Chrome 按钮无响应、Edge 任务为空和同步刷屏的问题."
```

### 步骤 3: 推送到远程仓库

将本地的提交推送到您的远程仓库（例如 GitHub, Gitee）。

```bash
# 将 main 分支的更改推送到名为 origin 的远程仓库
git push origin main
```

### 步骤 4: 在服务器上拉取更新 (如果适用)

如果您的服务器配置了从 Git 仓库拉取代码，请登录服务器并执行：

```bash
# 登录服务器
ssh root@115.159.5.111

# 进入项目目录
cd /www/wwwroot/task-manager/

# 拉取最新的代码
git pull origin main

# 设置正确的文件权限 (如果需要)
chown -R www:www .
chmod -R 755 .

# 重启服务
systemctl restart nginx
```

---

## 方法B：手动打包部署

此方法将创建一个干净的 `.zip` 部署包，然后手动上传到服务器。

### 步骤 1: 创建部署包

我将为您创建一个新的部署脚本 `deploy-v5.0.0.bat` 来自动完成打包。
您只需在本地双击运行此脚本即可。

**(下一步我将为您创建此脚本)**

运行后，您将在 `deploy/` 目录下找到一个名为 `task-manager-v5.0.0.zip` 的文件。

### 步骤 2: 上传部署包到服务器

将 `task-manager-v5.0.0.zip` 文件上传到您的 115 服务器的 `/www/wwwroot/` 目录下。
您可以使用以下任一工具：
-   **宝塔面板** 的文件管理器
-   **FTP/SFTP 客户端** (如 FileZilla, WinSCP)
-   **SCP 命令行工具**

**使用 SCP 的示例命令:**
(在您本地电脑的终端中运行)
```bash
scp "C:\path\to\your\project\deploy\task-manager-v5.0.0.zip" root@115.159.5.111:/www/wwwroot/
```

### 步骤 3: 在服务器上解压和配置

通过 SSH 登录到您的 115 服务器并执行以下命令：

```bash
# 1. 登录服务器
ssh root@115.159.5.111

# 2. 进入目标目录
cd /www/wwwroot/

# 3. (可选) 备份旧版本
mv task-manager task-manager-backup-$(date +%F)

# 4. 解压新的部署包
unzip -o task-manager-v5.0.0.zip -d task-manager/

# 5. 设置正确的文件权限
chown -R www:www task-manager/
chmod -R 755 task-manager/

# 6. 重启 Nginx 服务
systemctl restart nginx

# 7. (可选) 清理上传的zip包
rm task-manager-v5.0.0.zip
```

### 步骤 4: 验证部署

打开浏览器，访问 `http://115.159.5.111/`。
-   检查浏览器控制台是否有错误。
-   在 Chrome 和 Edge 浏览器中测试所有功能。
-   确认版本号显示为 `v5.0.0`。