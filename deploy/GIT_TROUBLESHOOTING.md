# Git 推送失败故障排除指南

当您遇到 `Failed to connect to github.com port 443` 错误时，这通常是由于您当前的网络环境无法通过 HTTPS 协议稳定连接到 GitHub。

本文档提供一个高效的解决方案：**将 Git 远程仓库地址从 HTTPS 切换到 SSH。**

---

### 为什么切换到 SSH？

-   **更稳定**：SSH 协议使用不同的端口，通常能绕过公司或公共网络对 HTTPS 端口的限制。
-   **更安全**：基于密钥对的认证，无需每次都输入用户名和密码。
-   **推荐方式**：是 Git 官方推荐的与远程仓库交互的方式之一。

---

### 步骤 1: 检查您当前的远程仓库地址

在项目根目录的终端中运行以下命令：

```bash
git remote -v
```

您可能会看到类似这样的输出 (注意开头的 `https://`)：
```
origin  https://github.com/xiaodehua2016/task-card-manager.git (fetch)
origin  https://github.com/xiaodehua2016/task-card-manager.git (push)
```

---

### 步骤 2: 切换到 SSH 地址

执行以下命令，将远程地址 `origin` 修改为 SSH 格式。

```bash
git remote set-url origin git@github.com:xiaodehua2016/task-card-manager.git
```

---

### 步骤 3: 验证更改

再次运行检查命令：

```bash
git remote -v
```

现在，您应该看到地址已经变成了 SSH 格式 (注意开头的 `git@github.com`):
```
origin  git@github.com:xiaodehua2016/task-card-manager.git (fetch)
origin  git@github.com:xiaodehua2016/task-card-manager.git (push)
```

---

### 步骤 4: 重新尝试推送

现在，您可以再次运行 `deploy/publish-to-git.bat` 脚本，或者手动执行 `git push` 命令。它现在将通过 SSH 协议进行推送，很大概率会成功。

```bash
git push origin main
```

---

### **重要前提**

要使用 SSH，您需要确保已经在您的电脑上生成了 SSH 密钥，并已将其公钥添加到了您的 GitHub 账户中。

如果您不确定是否已配置，可以参考 GitHub 的官方指南：
-   [检查现有的 SSH 密钥](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys)
-   [生成新的 SSH 密钥并添加到 ssh-agent](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
-   [将新的 SSH 密钥添加到您的 GitHub 帐户](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)