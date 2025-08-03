<?php
// 任务管理系统数据同步API v4.3.6.3
// 支持跨浏览器数据同步

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 数据文件路径
$dataDir = __DIR__ . '/data';
$dataFile = $dataDir . '/task_data.json';

// 确保数据目录存在
if (!is_dir($dataDir)) {
    mkdir($dataDir, 0755, true);
}

// 日志函数
function writeLog($message) {
    $logFile = __DIR__ . '/data/sync_log.txt';
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $message\n";
    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

// 获取客户端信息
function getClientInfo() {
    return [
        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
        'timestamp' => time()
    ];
}

try {
    // 只处理POST请求
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('只支持POST请求');
    }

    // 获取请求数据
    $input = file_get_contents('php://input');
    $requestData = json_decode($input, true);

    if (!$requestData) {
        throw new Exception('无效的JSON数据');
    }

    $action = $requestData['action'] ?? '';
    $clientInfo = getClientInfo();

    writeLog("收到请求: action=$action, IP={$clientInfo['ip']}");

    switch ($action) {
        case 'sync':
            // 数据同步
            $clientData = $requestData['data'] ?? null;
            $clientTimestamp = $requestData['timestamp'] ?? 0;

            if (!$clientData) {
                throw new Exception('缺少客户端数据');
            }

            // 读取服务器数据
            $serverData = null;
            if (file_exists($dataFile)) {
                $serverDataJson = file_get_contents($dataFile);
                $serverData = json_decode($serverDataJson, true);
            }

            $needUpdate = false;
            $responseData = $clientData;

            if ($serverData) {
                $serverTimestamp = $serverData['lastUpdateTime'] ?? 0;
                
                // 比较时间戳，决定使用哪个数据
                if ($serverTimestamp > $clientTimestamp) {
                    // 服务器数据更新，返回服务器数据
                    $responseData = $serverData;
                    writeLog("返回服务器数据 (服务器时间戳: $serverTimestamp > 客户端时间戳: $clientTimestamp)");
                } else if ($clientTimestamp > $serverTimestamp) {
                    // 客户端数据更新，保存到服务器
                    $needUpdate = true;
                    writeLog("保存客户端数据 (客户端时间戳: $clientTimestamp > 服务器时间戳: $serverTimestamp)");
                } else {
                    // 时间戳相同，合并数据
                    $responseData = mergeData($serverData, $clientData);
                    $needUpdate = true;
                    writeLog("合并数据 (时间戳相同: $clientTimestamp)");
                }
            } else {
                // 服务器没有数据，保存客户端数据
                $needUpdate = true;
                writeLog("首次保存数据");
            }

            // 如果需要更新服务器数据
            if ($needUpdate) {
                $responseData['lastUpdateTime'] = time() * 1000; // 转换为毫秒
                $responseData['syncInfo'] = $clientInfo;
                
                if (file_put_contents($dataFile, json_encode($responseData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE))) {
                    writeLog("数据保存成功");
                } else {
                    throw new Exception('数据保存失败');
                }
            }

            echo json_encode([
                'success' => true,
                'data' => $responseData,
                'message' => '数据同步成功',
                'server_time' => time() * 1000
            ], JSON_UNESCAPED_UNICODE);
            break;

        case 'get':
            // 获取数据
            if (file_exists($dataFile)) {
                $data = json_decode(file_get_contents($dataFile), true);
                echo json_encode([
                    'success' => true,
                    'data' => $data,
                    'message' => '数据获取成功'
                ], JSON_UNESCAPED_UNICODE);
            } else {
                echo json_encode([
                    'success' => false,
                    'data' => null,
                    'message' => '暂无数据'
                ], JSON_UNESCAPED_UNICODE);
            }
            writeLog("数据获取请求");
            break;

        default:
            throw new Exception('不支持的操作: ' . $action);
    }

} catch (Exception $e) {
    writeLog("错误: " . $e->getMessage());
    
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'error_code' => 'SYNC_ERROR'
    ], JSON_UNESCAPED_UNICODE);
}

// 数据合并函数
function mergeData($serverData, $clientData) {
    $today = date('Y-m-d');
    
    // 以客户端数据为基础
    $mergedData = $clientData;
    
    // 合并历史完成记录
    if (isset($serverData['completionHistory'])) {
        if (!isset($mergedData['completionHistory'])) {
            $mergedData['completionHistory'] = [];
        }
        
        foreach ($serverData['completionHistory'] as $date => $completion) {
            if ($date !== $today) {
                // 保留历史数据
                $mergedData['completionHistory'][$date] = $completion;
            }
        }
    }
    
    // 合并任务计时数据
    if (isset($serverData['taskTimes'])) {
        if (!isset($mergedData['taskTimes'])) {
            $mergedData['taskTimes'] = [];
        }
        
        foreach ($serverData['taskTimes'] as $taskKey => $time) {
            if (!isset($mergedData['taskTimes'][$taskKey])) {
                $mergedData['taskTimes'][$taskKey] = $time;
            } else {
                // 取较大值
                $mergedData['taskTimes'][$taskKey] = max($mergedData['taskTimes'][$taskKey], $time);
            }
        }
    }
    
    // 合并专注记录
    if (isset($serverData['focusRecords'])) {
        if (!isset($mergedData['focusRecords'])) {
            $mergedData['focusRecords'] = [];
        }
        $mergedData['focusRecords'] = array_merge($serverData['focusRecords'], $mergedData['focusRecords']);
    }
    
    return $mergedData;
}
?>