<?php
// 任务管理系统数据同步API v4.3.6.4
// 修复：确保所有浏览器访问同一个共享数据文件

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 固定的共享数据文件路径 - 所有浏览器都使用这个文件
$dataDir = __DIR__ . '/data';
$sharedDataFile = $dataDir . '/shared_task_data.json'; // 共享数据文件
$logFile = $dataDir . '/sync_log.txt';

// 确保数据目录存在
if (!is_dir($dataDir)) {
    mkdir($dataDir, 0777, true);
    chmod($dataDir, 0777);
}

// 日志函数
function writeLog($message) {
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    $clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $userAgent = substr($_SERVER['HTTP_USER_AGENT'] ?? 'unknown', 0, 100);
    $logEntry = "[$timestamp] [IP:$clientIP] $message | UA: $userAgent\n";
    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

// 获取客户端信息
function getClientInfo() {
    return [
        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
        'timestamp' => time(),
        'session_id' => session_id() ?: 'no_session'
    ];
}

// 安全读取共享数据文件
function readSharedData() {
    global $sharedDataFile;
    
    if (!file_exists($sharedDataFile)) {
        return null;
    }
    
    // 使用文件锁确保读取安全
    $handle = fopen($sharedDataFile, 'r');
    if (!$handle) {
        return null;
    }
    
    if (flock($handle, LOCK_SH)) {
        $content = fread($handle, filesize($sharedDataFile));
        flock($handle, LOCK_UN);
        fclose($handle);
        
        return json_decode($content, true);
    }
    
    fclose($handle);
    return null;
}

// 安全写入共享数据文件
function writeSharedData($data) {
    global $sharedDataFile;
    
    $handle = fopen($sharedDataFile, 'w');
    if (!$handle) {
        return false;
    }
    
    if (flock($handle, LOCK_EX)) {
        $result = fwrite($handle, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        flock($handle, LOCK_UN);
        fclose($handle);
        
        // 确保文件权限
        chmod($sharedDataFile, 0666);
        
        return $result !== false;
    }
    
    fclose($handle);
    return false;
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

    writeLog("收到请求: action=$action");

    switch ($action) {
        case 'sync':
            // 数据同步 - 使用共享文件
            $clientData = $requestData['data'] ?? null;
            $clientTimestamp = $requestData['timestamp'] ?? 0;

            if (!$clientData) {
                throw new Exception('缺少客户端数据');
            }

            // 读取共享数据文件
            $sharedData = readSharedData();
            $needUpdate = false;
            $responseData = $clientData;

            if ($sharedData) {
                $sharedTimestamp = $sharedData['lastUpdateTime'] ?? 0;
                
                writeLog("时间戳比较: 共享=$sharedTimestamp, 客户端=$clientTimestamp");
                
                // 比较时间戳，决定使用哪个数据
                if ($sharedTimestamp > $clientTimestamp) {
                    // 共享数据更新，返回共享数据
                    $responseData = $sharedData;
                    writeLog("返回共享数据 (共享时间戳更新)");
                } else if ($clientTimestamp > $sharedTimestamp) {
                    // 客户端数据更新，保存到共享文件
                    $needUpdate = true;
                    writeLog("保存客户端数据到共享文件 (客户端时间戳更新)");
                } else {
                    // 时间戳相同，合并数据
                    $responseData = mergeTaskData($sharedData, $clientData);
                    $needUpdate = true;
                    writeLog("合并数据到共享文件 (时间戳相同)");
                }
            } else {
                // 共享文件不存在，保存客户端数据
                $needUpdate = true;
                writeLog("首次创建共享数据文件");
            }

            // 如果需要更新共享数据
            if ($needUpdate) {
                $responseData['lastUpdateTime'] = time() * 1000; // 转换为毫秒
                $responseData['syncInfo'] = $clientInfo;
                $responseData['version'] = '4.3.6.4';
                
                if (writeSharedData($responseData)) {
                    writeLog("共享数据保存成功");
                } else {
                    throw new Exception('共享数据保存失败');
                }
            }

            echo json_encode([
                'success' => true,
                'data' => $responseData,
                'message' => '数据同步成功',
                'server_time' => time() * 1000,
                'sync_source' => 'shared_file'
            ], JSON_UNESCAPED_UNICODE);
            break;

        case 'get':
            // 获取共享数据
            $sharedData = readSharedData();
            if ($sharedData) {
                echo json_encode([
                    'success' => true,
                    'data' => $sharedData,
                    'message' => '共享数据获取成功',
                    'sync_source' => 'shared_file'
                ], JSON_UNESCAPED_UNICODE);
                writeLog("共享数据获取成功");
            } else {
                echo json_encode([
                    'success' => false,
                    'data' => null,
                    'message' => '暂无共享数据',
                    'sync_source' => 'shared_file'
                ], JSON_UNESCAPED_UNICODE);
                writeLog("共享数据不存在");
            }
            break;

        case 'debug':
            // 调试信息
            $sharedData = readSharedData();
            echo json_encode([
                'success' => true,
                'debug_info' => [
                    'shared_file_path' => $sharedDataFile,
                    'shared_file_exists' => file_exists($sharedDataFile),
                    'shared_file_size' => file_exists($sharedDataFile) ? filesize($sharedDataFile) : 0,
                    'shared_data_preview' => $sharedData ? array_keys($sharedData) : null,
                    'data_dir_permissions' => substr(sprintf('%o', fileperms($dataDir)), -4),
                    'client_info' => $clientInfo
                ],
                'message' => '调试信息获取成功'
            ], JSON_UNESCAPED_UNICODE);
            writeLog("调试信息请求");
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
        'error_code' => 'SYNC_ERROR',
        'sync_source' => 'shared_file'
    ], JSON_UNESCAPED_UNICODE);
}

// 数据合并函数 - 智能合并任务数据
function mergeTaskData($sharedData, $clientData) {
    $today = date('Y-m-d');
    
    // 以客户端数据为基础
    $mergedData = $clientData;
    
    // 合并历史完成记录
    if (isset($sharedData['completionHistory'])) {
        if (!isset($mergedData['completionHistory'])) {
            $mergedData['completionHistory'] = [];
        }
        
        foreach ($sharedData['completionHistory'] as $date => $completion) {
            if ($date !== $today) {
                // 保留历史数据
                $mergedData['completionHistory'][$date] = $completion;
            } else {
                // 今日数据：合并完成状态（任何一个浏览器完成的任务都算完成）
                if (isset($mergedData['completionHistory'][$today])) {
                    for ($i = 0; $i < count($completion); $i++) {
                        if (isset($mergedData['completionHistory'][$today][$i])) {
                            $mergedData['completionHistory'][$today][$i] = 
                                $mergedData['completionHistory'][$today][$i] || $completion[$i];
                        }
                    }
                } else {
                    $mergedData['completionHistory'][$today] = $completion;
                }
            }
        }
    }
    
    // 合并任务计时数据（取较大值）
    if (isset($sharedData['taskTimes'])) {
        if (!isset($mergedData['taskTimes'])) {
            $mergedData['taskTimes'] = [];
        }
        
        foreach ($sharedData['taskTimes'] as $taskKey => $time) {
            if (!isset($mergedData['taskTimes'][$taskKey])) {
                $mergedData['taskTimes'][$taskKey] = $time;
            } else {
                // 取较大值（累计时间更长的）
                $mergedData['taskTimes'][$taskKey] = max($mergedData['taskTimes'][$taskKey], $time);
            }
        }
    }
    
    // 合并专注记录
    if (isset($sharedData['focusRecords'])) {
        if (!isset($mergedData['focusRecords'])) {
            $mergedData['focusRecords'] = [];
        }
        $mergedData['focusRecords'] = array_merge($sharedData['focusRecords'], $mergedData['focusRecords']);
    }
    
    // 保留用户名和任务列表（以客户端为准）
    $mergedData['username'] = $clientData['username'] ?? $sharedData['username'] ?? '小久';
    $mergedData['tasks'] = $clientData['tasks'] ?? $sharedData['tasks'] ?? [];
    
    return $mergedData;
}
?>