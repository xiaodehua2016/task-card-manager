<?php
/**
 * 简单的数据同步API
 * 用于跨浏览器数据共享
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$dataFile = __DIR__ . '/../data/shared-tasks.json';
$dataDir = dirname($dataFile);

// 确保数据目录存在并可写
if (!is_dir($dataDir)) {
    mkdir($dataDir, 0755, true);
}

// 确保文件存在且可写
if (!file_exists($dataFile)) {
    $defaultData = [
        'version' => '4.2.4',
        'lastUpdateTime' => time() * 1000,
        'serverUpdateTime' => time() * 1000,
        'username' => '小久',
        'tasks' => [],
        'taskTemplates' => [
            'daily' => []
        ],
        'dailyTasks' => [],
        'completionHistory' => []
    ];
    file_put_contents($dataFile, json_encode($defaultData, JSON_PRETTY_PRINT));
    chmod($dataFile, 0644);
}

try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // 读取数据
        if (file_exists($dataFile)) {
            $data = file_get_contents($dataFile);
            $jsonData = json_decode($data, true);
            
            if ($jsonData === null) {
                // 文件损坏，返回空数据
                echo json_encode([
                    'success' => true,
                    'data' => null,
                    'message' => '数据文件为空'
                ]);
            } else {
                echo json_encode([
                    'success' => true,
                    'data' => $jsonData,
                    'lastModified' => filemtime($dataFile)
                ]);
            }
        } else {
            // 文件不存在
            echo json_encode([
                'success' => true,
                'data' => null,
                'message' => '数据文件不存在'
            ]);
        }
        
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // 保存数据
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        if ($data === null) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => '无效的JSON数据'
            ]);
            exit();
        }
        
        // 添加服务器时间戳
        $data['serverUpdateTime'] = time() * 1000; // 毫秒时间戳
        
        // 保存到文件
        $result = file_put_contents($dataFile, json_encode($data, JSON_PRETTY_PRINT));
        
        if ($result !== false) {
            // 确保文件权限正确
            chmod($dataFile, 0644);
            
            echo json_encode([
                'success' => true,
                'message' => '数据保存成功',
                'timestamp' => $data['serverUpdateTime']
            ]);
            
            // 记录同步日志
            error_log(date('[Y-m-d H:i:s]') . " 数据同步成功: " . $_SERVER['REMOTE_ADDR'] . "\n", 3, __DIR__ . '/../data/sync.log');
        } else {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => '数据保存失败: ' . error_get_last()['message']
            ]);
            
            // 记录错误日志
            error_log(date('[Y-m-d H:i:s]') . " 数据保存失败: " . error_get_last()['message'] . "\n", 3, __DIR__ . '/../data/error.log');
        }
        
    } else {
        http_response_code(405);
        echo json_encode([
            'success' => false,
            'message' => '不支持的请求方法'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => '服务器错误: ' . $e->getMessage()
    ]);
}
?>