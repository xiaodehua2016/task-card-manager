<?php
/**
 * 任务管理系统串行更新API v4.4.2
 * 实现服务器主导的串行更新机制，确保数据一致性
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 配置文件路径
$dataDir = __DIR__ . '/../data';
$dataFile = $dataDir . '/tasks_v4.4.2.json';
$lockFile = $dataDir . '/update.lock';
$logFile = $dataDir . '/update_log.txt';
$errorLogFile = $dataDir . '/error_log.txt';

// 确保数据目录存在
if (!is_dir($dataDir)) {
    mkdir($dataDir, 0777, true);
    chmod($dataDir, 0777);
}

/**
 * 写入操作日志
 */
function writeLog($message, $type = 'INFO') {
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    $clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $userAgent = substr($_SERVER['HTTP_USER_AGENT'] ?? 'unknown', 0, 100);
    $logEntry = "[$timestamp] [$type] [IP:$clientIP] $message | UA: $userAgent\n";
    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

/**
 * 写入错误日志
 */
function writeErrorLog($message, $context = []) {
    global $errorLogFile;
    $timestamp = date('Y-m-d H:i:s');
    $clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $contextStr = empty($context) ? '' : ' | Context: ' . json_encode($context);
    $logEntry = "[$timestamp] [ERROR] [IP:$clientIP] $message$contextStr\n";
    file_put_contents($errorLogFile, $logEntry, FILE_APPEND | LOCK_EX);
}

/**
 * 获取排他锁
 */
function acquireExclusiveLock($timeout = 10) {
    global $lockFile;
    $startTime = time();
    
    while (time() - $startTime < $timeout) {
        if (!file_exists($lockFile)) {
            $lockData = [
                'locked' => true,
                'lockTime' => time() * 1000,
                'lockClient' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
                'pid' => getmypid()
            ];
            
            if (file_put_contents($lockFile, json_encode($lockData), LOCK_EX) !== false) {
                writeLog("获取排他锁成功");
                return true;
            }
        }
        
        // 检查锁是否过期（超过30秒自动释放）
        if (file_exists($lockFile)) {
            $lockContent = file_get_contents($lockFile);
            $lockData = json_decode($lockContent, true);
            if ($lockData && (time() * 1000 - $lockData['lockTime']) > 30000) {
                unlink($lockFile);
                writeLog("清理过期锁文件");
            }
        }
        
        usleep(100000); // 等待100ms
    }
    
    writeLog("获取排他锁超时", 'WARN');
    return false;
}

/**
 * 释放排他锁
 */
function releaseExclusiveLock() {
    global $lockFile;
    if (file_exists($lockFile)) {
        unlink($lockFile);
        writeLog("释放排他锁");
    }
}

/**
 * 加载服务器数据
 */
function loadServerData() {
    global $dataFile;
    
    if (!file_exists($dataFile)) {
    // 创建默认数据结构
        $today = date('Y-m-d');
        $defaultData = [
            'version' => '4.4.2',
            'lastUpdateTime' => time() * 1000,
            'updateSequence' => 0,
            'users' => [
                'xiaojiu' => [
                    'username' => '小久',
                    'tasks' => [
                        '学而思数感小超市',
                        '斑马思维',
                        '核桃编程（学生端）',
                        '英语阅读',
                        '硬笔写字（30分钟）',
                        '悦乐达打卡/作业',
                        '暑假生活作业',
                        '体育/运动（迪卡侬）'
                    ],
                    'dailyCompletion' => [
                        $today => [
                            'completion' => [false, false, false, false, false, false, false, false],
                            'updateTime' => time() * 1000,
                            'updateClient' => 'system_init'
                        ]
                    ],
                    'taskTiming' => [
                        $today => []
                    ],
                    'focusRecords' => []
                ]
            ]
        ];
        
        file_put_contents($dataFile, json_encode($defaultData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        chmod($dataFile, 0666);
        writeLog("创建默认数据文件");
        return $defaultData;
    }
    
    $content = file_get_contents($dataFile);
    $data = json_decode($content, true);
    
    if (!$data) {
        writeErrorLog("数据文件解析失败", ['file' => $dataFile]);
        throw new Exception('数据文件损坏');
    }
    
    return $data;
}

/**
 * 保存服务器数据
 */
function saveServerData($data) {
    global $dataFile;
    
    $data['lastUpdateTime'] = time() * 1000;
    $data['updateSequence'] = ($data['updateSequence'] ?? 0) + 1;
    
    $jsonData = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
    if (file_put_contents($dataFile, $jsonData, LOCK_EX) === false) {
        writeErrorLog("保存数据文件失败", ['file' => $dataFile]);
        throw new Exception('保存数据失败');
    }
    
    chmod($dataFile, 0666);
    writeLog("保存服务器数据成功，序列号: " . $data['updateSequence']);
    return true;
}

/**
 * 更新任务完成状态
 */
function updateTaskCompletion($serverData, $request) {
    $userId = $request['userId'] ?? 'xiaojiu';
    $today = date('Y-m-d');
    $taskIndex = intval($request['taskIndex']);
    $completed = (bool)$request['completed'];
    
    // 确保用户数据存在
    if (!isset($serverData['users'][$userId])) {
        writeErrorLog("用户不存在", ['userId' => $userId]);
        throw new Exception('用户不存在');
    }
    
    $userData = &$serverData['users'][$userId];
    
    // 确保今日完成数据存在
    if (!isset($userData['dailyCompletion'][$today])) {
        $taskCount = count($userData['tasks']);
        $userData['dailyCompletion'][$today] = [
            'completion' => array_fill(0, $taskCount, false),
            'updateTime' => time() * 1000,
            'updateClient' => $request['clientId'] ?? 'unknown'
        ];
    }
    
    // 验证任务索引
    if ($taskIndex < 0 || $taskIndex >= count($userData['tasks'])) {
        writeErrorLog("任务索引无效", ['taskIndex' => $taskIndex, 'taskCount' => count($userData['tasks'])]);
        throw new Exception('任务索引无效');
    }
    
    // 更新任务状态
    $oldStatus = $userData['dailyCompletion'][$today]['completion'][$taskIndex];
    $userData['dailyCompletion'][$today]['completion'][$taskIndex] = $completed;
    $userData['dailyCompletion'][$today]['updateTime'] = time() * 1000;
    $userData['dailyCompletion'][$today]['updateClient'] = $request['clientId'] ?? 'unknown';
    
    writeLog("更新任务状态: 用户=$userId, 任务=$taskIndex, 状态=$oldStatus->$completed");
    
    return $serverData;
}

/**
 * 开始任务计时
 */
function startTaskTimer($serverData, $request) {
    $userId = $request['userId'] ?? 'xiaojiu';
    $today = date('Y-m-d');
    $taskIndex = intval($request['taskIndex']);
    
    $userData = &$serverData['users'][$userId];
    
    // 确保计时数据存在
    if (!isset($userData['taskTiming'][$today])) {
        $userData['taskTiming'][$today] = [];
    }
    
    // 记录开始时间
    if (!isset($userData['taskTiming'][$today][$taskIndex])) {
        $userData['taskTiming'][$today][$taskIndex] = 0;
    }
    
    writeLog("开始任务计时: 用户=$userId, 任务=$taskIndex");
    
    return $serverData;
}

/**
 * 停止任务计时
 */
function stopTaskTimer($serverData, $request) {
    $userId = $request['userId'] ?? 'xiaojiu';
    $today = date('Y-m-d');
    $taskIndex = intval($request['taskIndex']);
    $elapsedTime = intval($request['elapsedTime'] ?? 0);
    
    $userData = &$serverData['users'][$userId];
    
    // 确保计时数据存在
    if (!isset($userData['taskTiming'][$today])) {
        $userData['taskTiming'][$today] = [];
    }
    
    // 累加计时时间
    $currentTime = $userData['taskTiming'][$today][$taskIndex] ?? 0;
    $userData['taskTiming'][$today][$taskIndex] = $currentTime + $elapsedTime;
    
    writeLog("停止任务计时: 用户=$userId, 任务=$taskIndex, 用时={$elapsedTime}秒, 累计=" . $userData['taskTiming'][$today][$taskIndex] . "秒");
    
    return $serverData;
}

/**
 * 处理更新请求
 */
function handleUpdateRequest($request) {
    // 验证请求格式
    if (!isset($request['action'])) {
        throw new Exception('缺少操作类型');
    }
    
    // 获取排他锁
    if (!acquireExclusiveLock(10)) {
        throw new Exception('服务器繁忙，请稍后重试');
    }
    
    try {
        // 加载服务器数据
        $serverData = loadServerData();
        
        // 根据操作类型处理
        switch ($request['action']) {
            case 'updateTask':
                $serverData = updateTaskCompletion($serverData, $request);
                break;
                
            case 'startTimer':
                $serverData = startTaskTimer($serverData, $request);
                break;
                
            case 'stopTimer':
                $serverData = stopTaskTimer($serverData, $request);
                break;
                
            case 'getData':
                // 只读操作，不需要更新
                break;
                
            default:
                throw new Exception('不支持的操作类型: ' . $request['action']);
        }
        
        // 保存数据（除了只读操作）
        if ($request['action'] !== 'getData') {
            saveServerData($serverData);
        }
        
        // 返回成功响应
        return [
            'success' => true,
            'data' => $serverData,
            'message' => '操作成功',
            'timestamp' => time() * 1000,
            'sequence' => $serverData['updateSequence'] ?? 0
        ];
        
    } finally {
        // 释放锁
        releaseExclusiveLock();
    }
}

// 主处理逻辑
try {
    writeLog("收到请求: " . $_SERVER['REQUEST_METHOD']);
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('只支持POST请求');
    }
    
    // 获取请求数据
    $input = file_get_contents('php://input');
    $request = json_decode($input, true);
    
    if (!$request) {
        throw new Exception('无效的JSON数据');
    }
    
    writeLog("处理请求: " . json_encode($request, JSON_UNESCAPED_UNICODE));
    
    // 处理请求
    $response = handleUpdateRequest($request);
    
    // 返回响应
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    writeLog("请求处理成功");
    
} catch (Exception $e) {
    writeErrorLog($e->getMessage(), ['request' => $request ?? null]);
    
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'timestamp' => time() * 1000
    ], JSON_UNESCAPED_UNICODE);
}
?>