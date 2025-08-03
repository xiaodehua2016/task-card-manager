<?php
// 最简单的API测试文件
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

echo json_encode([
    'status' => 'success',
    'message' => 'PHP is working correctly!',
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => phpversion()
]);
?>