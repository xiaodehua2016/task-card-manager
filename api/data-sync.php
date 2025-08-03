<?php
/**
 * 简单的数据同步API v4.2.5
 * 用于跨浏览器数据共享
 * 增强日志记录功能
 */

// 禁用错误显示，避免HTML错误输出
ini_set('display_errors', 0);
ini_set('log_errors', 1);
error_reporting(E_ALL);

// 设置响应头（提前设置，避免输出干扰）
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 设置日志文件
$logFile = __DIR__ . '/../data/api_sync.log';
$errorLogFile = __DIR__ . '/../data/api_error.log';

// 记录日志函数
function logMessage($message, $isError = false) {
    global $logFile, $errorLogFile;
    
    try {
        $timestamp = date('[Y-m-d H:i:s]');
        $clientIP = isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : 'unknown';
        $userAgent = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : 'unknown';
        $logEntry = "$timestamp [$clientIP] [$userAgent] $message\n";
        
        $targetFile = $isError ? $errorLogFile : $logFile;
        
        // 确保日志目录存在
        $logDir = dirname($targetFile);
        if (!file_exists($logDir)) {
            @mkdir($logDir, 0755, true);
        }
        
        @file_put_contents($targetFile, $logEntry, FILE_APPEND | LOCK_EX);
    } catch (Exception $e) {
        // 日志记录失败时不影响主要功能
    }
}

// 记录请求信息
$requestMethod = isset($_SERVER['REQUEST_METHOD']) ? $_SERVER['REQUEST_METHOD'] : 'UNKNOWN';
$requestUri = isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : 'UNKNOWN';
logMessage("收到请求: $requestMethod $requestUri");

// 处理OPTIONS请求（预检请求）
if ($requestMethod === 'OPTIONS') {
    logMessage("处理OPTIONS预检请求");
    http_response_code(200);
    exit;
}

// 数据文件路径
$dataFile = __DIR__ . '/../data/shared_data.json';

// 确保数据目录存在
try {
    $dataDir = dirname($dataFile);
    if (!file_exists($dataDir)) {
        if (!@mkdir($dataDir, 0755, true)) {
            logMessage("创建数据目录失败: $dataDir", true);
            // 使用当前目录作为备选
            $dataFile = __DIR__ . '/shared_data.json';
            logMessage("使用备选数据文件路径: $dataFile");
        } else {
            logMessage("创建数据目录: $dataDir");
        }
    }
} catch (Exception $e) {
    logMessage("数据目录处理异常: " . $e->getMessage(), true);
    // 使用当前目录作为备选
    $dataFile = __DIR__ . '/shared_data.json';
}

// 处理GET请求 - 获取数据
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    logMessage("处理GET请求 - 获取数据");
    
    if (file_exists($dataFile)) {
        $data = file_get_contents($dataFile);
        if ($data) {
            logMessage("成功读取数据文件，大小: " . strlen($data) . " 字节");
            
            // 验证JSON格式
            $jsonData = json_decode($data, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                // 返回格式化的响应
                echo json_encode([
                    'success' => true,
                    'message' => '数据获取成功',
                    'data' => $jsonData,
                    'timestamp' => time() * 1000,
                    'version' => '4.2.5'
                ], JSON_UNESCAPED_UNICODE);
            } else {
                logMessage("数据文件JSON格式错误: " . json_last_error_msg(), true);
                echo json_encode([
                    'success' => false,
                    'message' => '数据文件格式错误',
                    'error' => json_last_error_msg()
                ]);
            }
        } else {
            logMessage("数据文件为空", true);
            echo json_encode([
                'success' => true,
                'message' => '数据文件为空',
                'data' => null
            ]);
        }
    } else {
        logMessage("数据文件不存在，返回默认数据");
        $defaultData = [
            'version' => '4.2.5',
            'lastUpdateTime' => time() * 1000,
            'tasks' => [],
            'taskTemplates' => ['daily' => []],
            'completionHistory' => new stdClass(),
            'taskTimes' => new stdClass(),
            'focusRecords' => new stdClass()
        ];
        
        echo json_encode([
            'success' => true,
            'message' => '返回默认数据',
            'data' => $defaultData
        ], JSON_UNESCAPED_UNICODE);
    }
}

// 处理POST请求 - 保存数据
else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    logMessage("处理POST请求 - 保存数据");
    
    // 获取原始POST数据
    $rawData = file_get_contents('php://input');
    
    if (!$rawData) {
        logMessage("接收到空数据", true);
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => '接收到空数据'
        ]);
        exit;
    }
    
    logMessage("接收到数据，大小: " . strlen($rawData) . " 字节");
    
    // 尝试解析JSON
    $jsonData = json_decode($rawData, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        $errorMsg = "JSON解析错误: " . json_last_error_msg();
        logMessage($errorMsg, true);
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => $errorMsg
        ]);
        exit;
    }
    
    // 添加服务器时间戳
    $jsonData['serverUpdateTime'] = time() * 1000; // 毫秒时间戳
    $jsonData['serverVersion'] = '4.2.5';
    
    // 转换回JSON
    $jsonString = json_encode($jsonData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
    // 保存数据
    try {
        // 创建备份
        if (file_exists($dataFile)) {
            $backupFile = $dataFile . '.bak';
            copy($dataFile, $backupFile);
            logMessage("创建数据备份: $backupFile");
        }
        
        // 写入新数据
        $result = file_put_contents($dataFile, $jsonString);
        
        if ($result !== false) {
            logMessage("数据保存成功，大小: $result 字节");
            echo json_encode([
                'success' => true,
                'message' => '数据保存成功',
                'timestamp' => $jsonData['serverUpdateTime'],
                'version' => $jsonData['serverVersion']
            ]);
        } else {
            logMessage("数据保存失败", true);
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => '数据保存失败'
            ]);
        }
    } catch (Exception $e) {
        $errorMsg = "保存数据时发生异常: " . $e->getMessage();
        logMessage($errorMsg, true);
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => $errorMsg
        ]);
    }
}

// 处理其他请求
else {
    $method = $_SERVER['REQUEST_METHOD'];
    logMessage("不支持的请求方法: $method", true);
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => "不支持的请求方法: $method"
    ]);
}