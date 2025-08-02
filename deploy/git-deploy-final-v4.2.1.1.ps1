# 小久任务管理系统 v4.2.1 Git部署脚本 (版本 v4.2.1.1)
# 包含详细日志输出功能

# 如果遇到执行策略限制，请以管理员身份运行：
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 颜色定义
$RED = "$([char]0x1b)[31m"
$GREEN = "$([char]0x1b)[32m"
$YELLOW = "$([char]0x1b)[33m"
$BLUE = "$([char]0x1b)[34m"
$NC = "$([char]0x1b)[0m" # 无颜色

# 配置
$VERSION = "v4.2.1"
$SCRIPT_VERSION = "v4.2.1.1"
$BRANCH = "main"

# 创建带时间戳的日志文件
$logTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "git_deploy_log_${logTimestamp}.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage -Encoding UTF8
}

Write-Log "${BLUE}=== 小久任务管理系统 ${VERSION} Git部署脚本 ${SCRIPT_VERSION} ===${NC}"
Write-Log "开始时间: $(Get-Date)"
Write-Log "日志文件: $logFile"
Write-Log ""

# 确保我们在项目根目录
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $scriptDir

Set-Location $projectRoot
Write-Log "工作目录: $(Get-Location)"

# 步骤1: 检查Git状态
Write-Log "${YELLOW}[1/4] 检查Git状态...${NC}"

# 检查Git是否安装
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Log "${RED}错误: Git未安装或不在PATH中${NC}"
    Write-Log "请安装Git后重试"
    exit 1
}

Write-Log "Git版本: $(git --version)"

# 检查是否为Git仓库
if (-not (Test-Path ".git")) {
    Write-Log "${RED}错误: 这不是一个Git仓库${NC}"
    Write-Log "请先初始化Git仓库:"
    Write-Log "  git init"
    Write-Log "  git remote add origin [repository-url]"
    exit 1
}

# 检查Git状态
$gitStatus = git status --porcelain 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}错误: 获取Git状态失败${NC}"
    exit 1
}

Write-Log "${GREEN}✓ Git仓库状态检查完成${NC}"

# 检查远程仓库
$remoteUrl = git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Log "远程仓库: $remoteUrl"
} else {
    Write-Log "${YELLOW}警告: 未配置远程仓库${NC}"
}

# 步骤2: 添加文件到暂存区
Write-Log "`n${YELLOW}[2/4] 添加文件到暂存区...${NC}"

# 显示当前状态
$statusOutput = git status --short
if ($statusOutput) {
    Write-Log "当前文件状态:"
    $statusOutput | ForEach-Object { Write-Log "  $_" }
} else {
    Write-Log "没有文件更改"
}

# 添加所有文件
git add . 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}错误: 添加文件到暂存区失败${NC}"
    exit 1
}

# 检查暂存的文件
$stagedFiles = git diff --cached --name-only
$fileCount = ($stagedFiles | Measure-Object).Count

if ($fileCount -eq 0) {
    Write-Log "${YELLOW}没有更改需要提交${NC}"
    Write-Log "所有文件都是最新的"
    exit 0
}

Write-Log "${GREEN}✓ 添加了 $fileCount 个文件到暂存区${NC}"
Write-Log "暂存的文件:"
$stagedFiles | ForEach-Object { Write-Log "  $_" }

# 步骤3: 创建提交
Write-Log "`n${YELLOW}[3/4] 创建提交...${NC}"

# 生成提交信息
$commitMessage = @"
🚀 发布 ${VERSION} - 数据一致性增强版

✨ 新功能:
- 跨浏览器数据同步功能
- 数据一致性自动修复
- 同步测试工具
- 部署验证工具

🔧 优化:
- 部署脚本全面优化 (脚本版本: ${SCRIPT_VERSION})
- 权限处理智能化
- 错误处理增强
- 详细日志输出
- 版本号管理规范化

🐛 修复:
- 跨浏览器任务数量不一致
- .user.ini权限问题
- 部署脚本兼容性问题
- PowerShell编码问题
- 密码文件路径问题

📦 部署:
- 一键部署脚本
- 多环境支持
- 自动验证和修复
- 完整日志记录
- 历史文件管理
"@

Write-Log "提交信息:"
$commitMessage.Split("`n") | ForEach-Object { Write-Log "  $_" }

# 创建提交
git commit -m $commitMessage 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}错误: 创建提交失败${NC}"
    Write-Log "请检查Git配置:"
    Write-Log "  git config --global user.name 'Your Name'"
    Write-Log "  git config --global user.email 'your.email@example.com'"
    exit 1
}

Write-Log "${GREEN}✓ 提交创建成功${NC}"

# 获取提交信息
$commitHash = git rev-parse HEAD
$commitShort = $commitHash.Substring(0, 7)
Write-Log "提交哈希: $commitShort"

# 步骤4: 推送到远程仓库
Write-Log "`n${YELLOW}[4/4] 推送到远程仓库...${NC}"

# 检查远程仓库
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}错误: 未配置远程仓库${NC}"
    Write-Log "请添加远程仓库:"
    Write-Log "  git remote add origin [repository-url]"
    exit 1
}

Write-Log "推送到分支: $BRANCH"
Write-Log "远程仓库: $remoteUrl"

# 推送到远程
git push origin $BRANCH 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "${RED}错误: 推送到远程仓库失败${NC}"
    Write-Log "可能的原因:"
    Write-Log "1. 网络连接问题"
    Write-Log "2. 认证问题"
    Write-Log "3. 远程仓库冲突"
    Write-Log ""
    Write-Log "尝试手动推送:"
    Write-Log "  git push origin $BRANCH"
    
    # 尝试获取更多错误信息
    Write-Log "`n尝试获取详细错误信息..."
    $pushResult = git push origin $BRANCH 2>&1
    Write-Log "推送输出: $pushResult"
    
    exit 1
}

Write-Log "${GREEN}✓ 成功推送到远程仓库${NC}"

# 部署摘要
Write-Log "`n${BLUE}=== 部署摘要 ===${NC}"
Write-Log "项目版本: $VERSION"
Write-Log "脚本版本: $SCRIPT_VERSION"
Write-Log "分支: $BRANCH"
Write-Log "提交文件数: $fileCount"
Write-Log "提交哈希: $commitShort"
Write-Log "远程仓库: $remoteUrl"
Write-Log "日志文件: $logFile"
Write-Log "完成时间: $(Get-Date)"

Write-Log "`n${GREEN}Git部署完成！${NC}"
Write-Log "代码已成功推送到远程仓库"

# 检查GitHub Pages或其他部署服务
Write-Log "`n${YELLOW}后续步骤:${NC}"
Write-Log "1. 检查GitHub Pages是否自动部署"
Write-Log "2. 验证网站是否更新到最新版本"
Write-Log "3. 测试跨浏览器数据同步功能"

Write-Log "`n部署日志已保存到: $logFile"