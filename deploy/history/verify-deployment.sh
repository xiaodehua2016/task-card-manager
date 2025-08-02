#!/bin/bash
# 部署验证脚本 - 检查数据同步功能是否正常工作

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 网站根目录
WEB_ROOT="/www/wwwroot/task-manager"

# 检查是否以root运行
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}请以root用户运行此脚本${NC}"
  exit 1
fi

echo -e "${BLUE}=== 任务管理系统部署验证 ===${NC}"
echo "开始时间: $(date)"
echo

# 检查网站根目录
echo -e "${YELLOW}[1/5] 检查网站目录...${NC}"
if [ -d "$WEB_ROOT" ]; then
  echo -e "${GREEN}✓ 网站目录存在: $WEB_ROOT${NC}"
else
  echo -e "${RED}✗ 网站目录不存在: $WEB_ROOT${NC}"
  echo "请先部署网站或修改脚本中的WEB_ROOT变量"
  exit 1
fi

# 检查数据目录权限
echo -e "\n${YELLOW}[2/5] 检查数据目录权限...${NC}"
DATA_DIR="$WEB_ROOT/data"
if [ -d "$DATA_DIR" ]; then
  OWNER=$(stat -c '%U:%G' "$DATA_DIR")
  PERMS=$(stat -c '%a' "$DATA_DIR")
  echo -e "${GREEN}✓ 数据目录存在${NC}"
  echo "所有者: $OWNER"
  echo "权限: $PERMS"
  
  # 检查是否可写
  if [ -w "$DATA_DIR" ]; then
    echo -e "${GREEN}✓ 数据目录可写${NC}"
  else
    echo -e "${RED}✗ 数据目录不可写${NC}"
    echo "正在修复权限..."
    chown -R www:www "$DATA_DIR"
    chmod -R 755 "$DATA_DIR"
    echo "权限已修复"
  fi
else
  echo -e "${RED}✗ 数据目录不存在${NC}"
  echo "正在创建数据目录..."
  mkdir -p "$DATA_DIR"
  chown -R www:www "$DATA_DIR"
  chmod -R 755 "$DATA_DIR"
  echo "数据目录已创建"
fi

# 检查共享数据文件
echo -e "\n${YELLOW}[3/5] 检查共享数据文件...${NC}"
SHARED_DATA="$DATA_DIR/shared-tasks.json"
if [ -f "$SHARED_DATA" ]; then
  OWNER=$(stat -c '%U:%G' "$SHARED_DATA")
  PERMS=$(stat -c '%a' "$SHARED_DATA")
  SIZE=$(stat -c '%s' "$SHARED_DATA")
  echo -e "${GREEN}✓ 共享数据文件存在${NC}"
  echo "所有者: $OWNER"
  echo "权限: $PERMS"
  echo "大小: $SIZE 字节"
  
  # 检查文件内容
  if [ $SIZE -lt 10 ]; then
    echo -e "${RED}✗ 共享数据文件可能为空或损坏${NC}"
    echo "正在创建默认数据文件..."
    cat > "$SHARED_DATA" << EOF
{
  "version": "4.2.0",
  "lastUpdateTime": $(date +%s000),
  "serverUpdateTime": $(date +%s000),
  "username": "小久",
  "tasks": [],
  "taskTemplates": {
    "daily": [
      { "name": "学而思数感小超市", "type": "daily" },
      { "name": "斑马思维", "type": "daily" },
      { "name": "核桃编程（学生端）", "type": "daily" },
      { "name": "英语阅读", "type": "daily" },
      { "name": "硬笔写字（30分钟）", "type": "daily" },
      { "name": "悦乐达打卡/作业", "type": "daily" },
      { "name": "暑假生活作业", "type": "daily" },
      { "name": "体育/运动（迪卡侬）", "type": "daily" }
    ]
  },
  "dailyTasks": {},
  "completionHistory": {},
  "taskTimes": {},
  "focusRecords": {}
}
EOF
    chown www:www "$SHARED_DATA"
    chmod 644 "$SHARED_DATA"
    echo "默认数据文件已创建"
  fi
else
  echo -e "${RED}✗ 共享数据文件不存在${NC}"
  echo "正在创建默认数据文件..."
  cat > "$SHARED_DATA" << EOF
{
  "version": "4.2.0",
  "lastUpdateTime": $(date +%s000),
  "serverUpdateTime": $(date +%s000),
  "username": "小久",
  "tasks": [],
  "taskTemplates": {
    "daily": [
      { "name": "学而思数感小超市", "type": "daily" },
      { "name": "斑马思维", "type": "daily" },
      { "name": "核桃编程（学生端）", "type": "daily" },
      { "name": "英语阅读", "type": "daily" },
      { "name": "硬笔写字（30分钟）", "type": "daily" },
      { "name": "悦乐达打卡/作业", "type": "daily" },
      { "name": "暑假生活作业", "type": "daily" },
      { "name": "体育/运动（迪卡侬）", "type": "daily" }
    ]
  },
  "dailyTasks": {},
  "completionHistory": {},
  "taskTimes": {},
  "focusRecords": {}
}
EOF
  chown www:www "$SHARED_DATA"
  chmod 644 "$SHARED_DATA"
  echo "默认数据文件已创建"
fi

# 检查API目录权限
echo -e "\n${YELLOW}[4/5] 检查API目录权限...${NC}"
API_DIR="$WEB_ROOT/api"
if [ -d "$API_DIR" ]; then
  OWNER=$(stat -c '%U:%G' "$API_DIR")
  PERMS=$(stat -c '%a' "$API_DIR")
  echo -e "${GREEN}✓ API目录存在${NC}"
  echo "所有者: $OWNER"
  echo "权限: $PERMS"
  
  # 检查数据同步API
  SYNC_API="$API_DIR/data-sync.php"
  if [ -f "$SYNC_API" ]; then
    OWNER=$(stat -c '%U:%G' "$SYNC_API")
    PERMS=$(stat -c '%a' "$SYNC_API")
    echo -e "${GREEN}✓ 数据同步API存在${NC}"
    echo "所有者: $OWNER"
    echo "权限: $PERMS"
  else
    echo -e "${RED}✗ 数据同步API不存在${NC}"
  fi
else
  echo -e "${RED}✗ API目录不存在${NC}"
fi

# 测试数据同步API
echo -e "\n${YELLOW}[5/5] 测试数据同步API...${NC}"
CURL_RESULT=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/data-sync.php 2>/dev/null)

if [ "$CURL_RESULT" = "200" ]; then
  echo -e "${GREEN}✓ 数据同步API响应正常 (HTTP 200)${NC}"
else
  echo -e "${RED}✗ 数据同步API响应异常 (HTTP $CURL_RESULT)${NC}"
  echo "尝试修复常见问题..."
  
  # 检查PHP配置
  if [ -f "$WEB_ROOT/.user.ini" ]; then
    echo "检测到.user.ini文件，尝试解除不可变属性..."
    chattr -i "$WEB_ROOT/.user.ini"
    echo "已解除.user.ini的不可变属性"
  fi
  
  # 设置正确的权限
  echo "设置正确的文件权限..."
  chown -R www:www "$WEB_ROOT"
  find "$WEB_ROOT" -type d -exec chmod 755 {} \;
  find "$WEB_ROOT" -type f -exec chmod 644 {} \;
  
  # 如果有.user.ini，恢复不可变属性
  if [ -f "$WEB_ROOT/.user.ini" ]; then
    echo "恢复.user.ini的不可变属性..."
    chattr +i "$WEB_ROOT/.user.ini"
  fi
  
  echo "权限修复完成，请重新测试API"
fi

# 总结
echo -e "\n${BLUE}=== 验证摘要 ===${NC}"
echo "网站目录: $WEB_ROOT"
echo "数据目录: $DATA_DIR"
echo "共享数据文件: $SHARED_DATA"
echo "API状态: $([ "$CURL_RESULT" = "200" ] && echo "正常" || echo "异常")"
echo "完成时间: $(date)"

# 提供建议
echo -e "\n${YELLOW}建议操作:${NC}"
if [ "$CURL_RESULT" != "200" ]; then
  echo "1. 检查PHP错误日志: tail -f /www/wwwlogs/php-error.log"
  echo "2. 确认PHP版本兼容性: php -v"
  echo "3. 检查网站配置: cat /www/server/panel/vhost/nginx/task-manager.conf"
  echo "4. 重启Web服务: systemctl restart nginx && systemctl restart php-fpm"
else
  echo "1. 在浏览器中访问: http://115.159.5.111/sync-test.html"
  echo "2. 点击\"测试数据同步\"按钮验证跨浏览器同步功能"
  echo "3. 在不同浏览器中打开网站，检查数据是否同步"
fi

echo -e "\n${GREEN}验证脚本执行完毕${NC}"