<?php
/**
 * 超简化数据同步API v4.2.5
 * 专门解决HTML错误输出问题
 */

// 立即设置响应头，确保输出JSON格式
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 完全关闭所有错误显示和输出缓冲
ini_set('display_errors', 0);
ini_set('log_errors', 0);
error_reporting(0);
ob_clean();

// 处理OPTIONS请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    echo '{"success":true,"message":"OPTIONS OK"}';
    exit;
}

// 数据文件路径
$dataFile = __DIR__ . '/shared_data.json';

try {
    // 处理GET请求
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        if (file_exists($dataFile)) {
            $content = file_get_contents($dataFile);
            if ($content && strlen($content) > 0) {
                $data = json_decode($content, true);
                if ($data !== null) {
                    echo json_encode([
                        'success' => true,
                        'message' => '数据获取成功',
                        'data' => $data,
                        'timestamp' => time() * 1000,
                        'version' => '4.2.5'
                    ]);
                    exit;
                }
            }
        }
        
        // 没有数据时返回空数据结构
        echo json_encode([
            'success' => true,
            'message' => '暂无数据',
            'data' => null,
            'timestamp' => time() * 1000,
            'version' => '4.2.5'
        ]);
        exit;
    }
    
    // 处理POST请求
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $input = file_get_contents('php://input');
        if ($input && strlen($input) > 0) {
            $data = json_decode($input, true);
            if ($data !== null) {
                // 添加服务器时间戳
                $data['serverUpdateTime'] = time() * 1000;
                $data['serverVersion'] = '4.2.5';
                
                // 保存数据
                $result = file_put_contents($dataFile, json_encode($data));
                if ($result !== false) {
                    echo json_encode([
                        'success' => true,
                        'message' => '数据保存成功',
                        'timestamp' => time() * 1000,
                        'version' => '4.2.5'
                    ]);
                    exit;
                }
            }
        }
        
        echo json_encode([
            'success' => false,
            'message' => '数据保存失败',
            'timestamp' => time() * 1000,
            'version' => '4.2.5'
        ]);
        exit;
    }
    
    // 不支持的请求方法
    echo json_encode([
        'success' => false,
        'message' => '不支持的请求方法',
        'timestamp' => time() * 1000,
        'version' => '4.2.5'
    ]);
    
} catch (Exception $e) {
    // 即使出现异常也只输出JSON
    echo json_encode([
        'success' => false,
        'message' => '服务器内部错误',
        'timestamp' => time() * 1000,
        'version' => '4.2.5'
    ]);
}
?>