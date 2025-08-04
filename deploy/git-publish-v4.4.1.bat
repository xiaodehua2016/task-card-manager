@echo off
chcp 65001 >nul
echo ========================================
echo 任务管理系统 v4.4.1 Git发布脚本
echo ========================================
echo.

set VERSION=4.4.1
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOG_FILE=git-publish-log-%TIMESTAMP%.txt

echo [%time%] 开始Git发布流程...
echo 版本: %VERSION%
echo 时间戳: %TIMESTAMP%
echo.
echo [%time%] 开始Git发布流程... >> %LOG_FILE%
echo 版本: %VERSION% >> %LOG_FILE%
echo 时间戳: %TIMESTAMP% >> %LOG_FILE%

:: 检查Git状态
echo [%time%] 检查Git状态...
echo [%time%] 检查Git状态... >> %LOG_FILE%
cd ..
git status >> deploy\%LOG_FILE%

:: 添加所有更改
echo [%time%] 添加文件到Git...
echo [%time%] 添加文件到Git... >> deploy\%LOG_FILE%
git add . >> deploy\%LOG_FILE%

:: 检查是否有更改需要提交
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo [%time%] 没有检测到更改，跳过提交
    echo [%time%] 没有检测到更改，跳过提交 >> deploy\%LOG_FILE%
    goto :tag_and_push
)

:: 提交更改
echo [%time%] 提交更改...
echo [%time%] 提交更改... >> deploy\%LOG_FILE%
git commit -m "发布任务管理系统 v%VERSION% - 实现服务器串行更新机制

主要更新:
- 实现服务器主导的串行更新机制，确保数据一致性
- 新增 serial-update.php API，支持排他锁和队列处理
- 优化客户端逻辑，支持乐观更新和错误回滚
- 添加完整的操作日志和错误日志系统
- 清理冗余代码，保留核心功能
- 版本号更新为 v%VERSION%

技术改进:
- 服务器端文件锁机制防止并发冲突
- 客户端队列处理确保操作顺序
- 完善的错误处理和用户反馈
- 详细的日志记录便于问题分析

构建时间: %TIMESTAMP%" >> deploy\%LOG_FILE%

:tag_and_push
:: 创建版本标签
echo [%time%] 创建版本标签...
echo [%time%] 创建版本标签... >> deploy\%LOG_FILE%
git tag -a v%VERSION% -m "任务管理系统 v%VERSION% 正式发布

主要特性:
- 服务器串行更新机制
- 跨浏览器数据同步
- 完整的日志系统
- 优化的用户体验

发布时间: %TIMESTAMP%" >> deploy\%LOG_FILE%

:: 推送到远程仓库
echo [%time%] 推送到远程仓库...
echo [%time%] 推送到远程仓库... >> deploy\%LOG_FILE%
git push origin main >> deploy\%LOG_FILE%

:: 推送标签
echo [%time%] 推送标签...
echo [%time%] 推送标签... >> deploy\%LOG_FILE%
git push origin v%VERSION% >> deploy\%LOG_FILE%

:: 显示最新提交信息
echo [%time%] 显示最新提交信息...
echo [%time%] 显示最新提交信息... >> deploy\%LOG_FILE%
git log --oneline -5 >> deploy\%LOG_FILE%

:: 显示远程仓库信息
echo [%time%] 显示远程仓库信息...
echo [%time%] 显示远程仓库信息... >> deploy\%LOG_FILE%
git remote -v >> deploy\%LOG_FILE%

echo.
echo ========================================
echo Git发布完成！
echo 版本: v%VERSION%
echo 日志文件: deploy\%LOG_FILE%
echo ========================================
echo.

echo [%time%] Git发布脚本执行完成
echo [%time%] Git发布脚本执行完成 >> deploy\%LOG_FILE%

cd deploy
pause