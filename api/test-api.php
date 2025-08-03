<?php
/**
 * API测试脚本 v4.2.5
 * 用于测试data-sync.php是否正常工作
 */

// 设置响应头
header('Content-Type: text/html; charset=utf-8');

echo "<h1>API测试页面 v4.2.5</h1>";
echo "<p>测试时间: " . date('Y-m-d H:i:s') . "</p>";

// 测试PHP基本功能
echo "<h2>1. PHP基本信息</h2>";
echo "<p>PHP版本: " . phpversion() . "</p>";
echo "<p>当前目录: " . __DIR__ . "</p>";

// 测试文件权限
echo "<h2>2. 文件权限测试</h2>";
$dataDir = __DIR__ . '/../data';
$dataFile = $dataDir . '/shared_data.json';

echo "<p>数据目录: $dataDir</p>";
echo "<p>数据目录是否存在: " . (is_dir($dataDir) ? '是' : '否') . "</p>";
echo "<p>数据目录是否可写: " . (is_writable($dataDir) ? '是' : '否') . "</p>";
echo "<p>数据文件: $dataFile</p>";
echo "<p>数据文件是否存在: " . (file_exists($dataFile) ? '是' : '否') . "</p>";

if (file_exists($dataFile)) {
    echo "<p>数据文件大小: " . filesize($dataFile) . " 字节</p>";
    echo "<p>数据文件是否可读: " . (is_readable($dataFile) ? '是' : '否') . "</p>";
    echo "<p>数据文件是否可写: " . (is_writable($dataFile) ? '是' : '否') . "</p>";
}

// 测试JSON功能
echo "<h2>3. JSON功能测试</h2>";
$testData = [
    'version' => '4.2.5',
    'timestamp' => time() * 1000,
    'test' => '中文测试'
];

$jsonString = json_encode($testData, JSON_UNESCAPED_UNICODE);
echo "<p>JSON编码测试: " . ($jsonString ? '成功' : '失败') . "</p>";

if ($jsonString) {
    echo "<p>编码结果: $jsonString</p>";
    
    $decodedData = json_decode($jsonString, true);
    echo "<p>JSON解码测试: " . ($decodedData ? '成功' : '失败') . "</p>";
}

// 测试HTTP请求方法
echo "<h2>4. HTTP请求信息</h2>";
echo "<p>请求方法: " . ($_SERVER['REQUEST_METHOD'] ?? '未知') . "</p>";
echo "<p>请求URI: " . ($_SERVER['REQUEST_URI'] ?? '未知') . "</p>";
echo "<p>客户端IP: " . ($_SERVER['REMOTE_ADDR'] ?? '未知') . "</p>";

// 测试data-sync.php
echo "<h2>5. API接口测试</h2>";
echo "<p><a href='data-sync.php' target='_blank'>测试GET请求</a></p>";

// 创建POST测试表单
echo "<form method='POST' action='data-sync.php' target='_blank'>";
echo "<input type='hidden' name='test' value='1'>";
echo "<p><button type='submit'>测试POST请求</button></p>";
echo "</form>";

// 显示错误日志
echo "<h2>6. 错误日志</h2>";
$errorLogFile = $dataDir . '/api_error.log';
if (file_exists($errorLogFile)) {
    $errorLog = file_get_contents($errorLogFile);
    if ($errorLog) {
        echo "<pre style='background: #f0f0f0; padding: 10px; max-height: 200px; overflow-y: auto;'>";
        echo htmlspecialchars($errorLog);
        echo "</pre>";
    } else {
        echo "<p>错误日志为空</p>";
    }
} else {
    echo "<p>错误日志文件不存在</p>";
}

// 显示访问日志
echo "<h2>7. 访问日志</h2>";
$logFile = $dataDir . '/api_sync.log';
if (file_exists($logFile)) {
    $log = file_get_contents($logFile);
    if ($log) {
        $logLines = explode("\n", $log);
        $recentLines = array_slice($logLines, -10); // 显示最近10行
        echo "<pre style='background: #f0f0f0; padding: 10px; max-height: 200px; overflow-y: auto;'>";
        echo htmlspecialchars(implode("\n", $recentLines));
        echo "</pre>";
    } else {
        echo "<p>访问日志为空</p>";
    }
} else {
    echo "<p>访问日志文件不存在</p>";
}

echo "<hr>";
echo "<p><a href='../sync-test.html'>返回同步测试页面</a></p>";
?>