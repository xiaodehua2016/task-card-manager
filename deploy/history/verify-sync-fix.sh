#!/bin/bash

# 数据同步修复验证脚本
# 用于验证跨浏览器数据同步问题是否已解决

echo "🔍 开始验证数据同步修复..."

# 服务器信息
SERVER_IP="115.159.5.111"
WEB_ROOT="/www/wwwroot/task-manager"
API_ENDPOINT="http://${SERVER_IP}/api/data-sync.php"

echo "📋 验证清单:"
echo "1. 检查API文件是否存在"
echo "2. 检查数据目录权限"
echo "3. 测试API响应"
echo "4. 验证跨浏览器同步功能"
echo ""

# 1. 检查API文件
echo "🔍 1. 检查API文件..."
if ssh root@${SERVER_IP} "[ -f ${WEB_ROOT}/api/data-sync.php ]"; then
    echo "✅ API文件存在"
else
    echo "❌ API文件不存在"
    exit 1
fi

# 2. 检查数据目录
echo "🔍 2. 检查数据目录..."
ssh root@${SERVER_IP} "
    if [ ! -d ${WEB_ROOT}/data ]; then
        mkdir -p ${WEB_ROOT}/data
        echo '📁 创建数据目录'
    fi
    
    chown -R www:www ${WEB_ROOT}/data
    chmod -R 755 ${WEB_ROOT}/data
    
    echo '✅ 数据目录权限已设置'
    ls -la ${WEB_ROOT}/data/
"

# 3. 测试API响应
echo "🔍 3. 测试API响应..."
response=$(curl -s -w "%{http_code}" -o /tmp/api_test.json "${API_ENDPOINT}")
http_code="${response: -3}"

if [ "$http_code" = "200" ]; then
    echo "✅ API响应正常 (HTTP 200)"
    echo "📄 API响应内容:"
    cat /tmp/api_test.json | jq . 2>/dev/null || cat /tmp/api_test.json
else
    echo "❌ API响应异常 (HTTP $http_code)"
    cat /tmp/api_test.json
fi

# 4. 测试数据同步
echo "🔍 4. 测试数据同步..."
test_data='{
    "version": "4.2.1",
    "lastUpdateTime": '$(date +%s000)',
    "username": "测试用户",
    "tasks": [],
    "taskTemplates": {"daily": []},
    "dailyTasks": {},
    "completionHistory": {}
}'

# 发送测试数据
echo "📤 发送测试数据..."
post_response=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$test_data" \
    -o /tmp/post_test.json \
    "${API_ENDPOINT}")

post_code="${post_response: -3}"

if [ "$post_code" = "200" ]; then
    echo "✅ 数据保存成功"
    cat /tmp/post_test.json | jq . 2>/dev/null || cat /tmp/post_test.json
else
    echo "❌ 数据保存失败 (HTTP $post_code)"
    cat /tmp/post_test.json
fi

# 验证数据读取
echo "📥 验证数据读取..."
sleep 1
get_response=$(curl -s -w "%{http_code}" -o /tmp/get_test.json "${API_ENDPOINT}?t=$(date +%s)")
get_code="${get_response: -3}"

if [ "$get_code" = "200" ]; then
    echo "✅ 数据读取成功"
    
    # 检查数据是否匹配
    if grep -q "测试用户" /tmp/get_test.json; then
        echo "✅ 数据同步验证成功"
    else
        echo "⚠️ 数据内容可能不匹配"
    fi
else
    echo "❌ 数据读取失败 (HTTP $get_code)"
fi

# 5. 检查文件权限
echo "🔍 5. 检查文件权限..."
ssh root@${SERVER_IP} "
    echo '📁 数据目录权限:'
    ls -la ${WEB_ROOT}/data/
    
    echo '📄 API文件权限:'
    ls -la ${WEB_ROOT}/api/data-sync.php
    
    echo '🌐 Web根目录权限:'
    ls -la ${WEB_ROOT}/ | head -10
"

# 6. 生成验证报告
echo ""
echo "📊 验证报告:"
echo "=================="
echo "API可访问性: $([ "$http_code" = "200" ] && echo "✅ 正常" || echo "❌ 异常")"
echo "数据保存功能: $([ "$post_code" = "200" ] && echo "✅ 正常" || echo "❌ 异常")"
echo "数据读取功能: $([ "$get_code" = "200" ] && echo "✅ 正常" || echo "❌ 异常")"
echo "数据同步验证: $(grep -q "测试用户" /tmp/get_test.json 2>/dev/null && echo "✅ 成功" || echo "❌ 失败")"
echo ""

# 7. 提供访问链接
echo "🔗 测试链接:"
echo "主页面: http://${SERVER_IP}/"
echo "同步测试: http://${SERVER_IP}/sync-test.html"
echo "API测试: ${API_ENDPOINT}"
echo ""

# 8. 浏览器测试建议
echo "🌐 浏览器测试建议:"
echo "1. 在Chrome中打开: http://${SERVER_IP}/"
echo "2. 添加一些任务并完成"
echo "3. 在Firefox中打开同一地址"
echo "4. 检查任务是否同步显示"
echo "5. 在不同浏览器中交替操作，验证实时同步"
echo ""

echo "✅ 验证脚本执行完成"
echo "💡 如果所有项目都显示正常，说明数据同步问题已修复"