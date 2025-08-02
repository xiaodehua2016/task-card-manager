# Git手动推送指南

## 背景

在使用Git部署脚本时，可能会因为网络问题、认证问题或其他原因导致自动推送失败。本指南提供了手动推送代码到远程仓库的详细步骤。

## 前提条件

1. 已成功执行Git部署脚本的本地提交部分
2. 已配置远程仓库

## 手动推送命令

### 基本推送命令

```bash
# 推送到默认远程仓库(origin)
git push -u origin main

# 查看所有配置的远程仓库
git remote -v

# 推送到指定远程仓库
git push -u 远程仓库名 main
```

### 推送到特定平台

```bash
# 推送到GitHub
git push -u origin main

# 推送到Gitee
git push -u gitee main

# 推送到Coding
git push -u coding main
```

### 处理常见问题

#### 1. 认证失败

如果遇到认证失败，可以尝试以下方法：

```bash
# 使用HTTPS方式时，配置凭据缓存
git config --global credential.helper store

# 重新推送，输入用户名和密码
git push -u origin main
```

对于GitHub，可能需要使用个人访问令牌(PAT)而不是密码：
1. 访问GitHub设置 -> Developer settings -> Personal access tokens
2. 生成新令牌，选择repo权限
3. 使用生成的令牌作为密码

#### 2. 网络连接问题

如果遇到网络连接问题，可以尝试以下方法：

```bash
# 设置HTTP代理
git config --global http.proxy http://代理服务器:端口

# 设置HTTPS代理
git config --global https.proxy https://代理服务器:端口

# 取消代理设置
git config --global --unset http.proxy
git config --global --unset https.proxy
```

#### 3. 分支冲突

如果远程仓库已有内容，可能会遇到分支冲突：

```bash
# 先拉取远程仓库内容
git pull origin main --allow-unrelated-histories

# 解决冲突后再推送
git push -u origin main
```

#### 4. 强制推送

如果确定要覆盖远程仓库内容，可以使用强制推送（谨慎使用）：

```bash
git push -f origin main
```

## 切换远程仓库

如果一个远程仓库无法访问，可以尝试推送到其他已配置的远程仓库：

```bash
# 添加新的远程仓库
git remote add 远程仓库名 仓库URL

# 修改现有远程仓库URL
git remote set-url 远程仓库名 新URL

# 删除远程仓库
git remote remove 远程仓库名
```

## 查看推送状态

```bash
# 查看本地分支与远程分支的关系
git branch -vv

# 查看远程仓库信息
git remote show origin
```

## 注意事项

1. 确保有远程仓库的写入权限
2. 使用SSH密钥可以避免频繁输入密码
3. 推送前先拉取最新代码，避免冲突
4. 谨慎使用强制推送，可能会覆盖他人提交

## 常用SSH配置

```bash
# 生成SSH密钥
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 添加SSH密钥到SSH代理
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# 测试SSH连接
ssh -T git@github.com
ssh -T git@gitee.com
```

将公钥添加到GitHub/Gitee/Coding等平台的SSH密钥设置中。