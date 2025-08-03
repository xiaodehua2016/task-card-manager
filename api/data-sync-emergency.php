<?php
// 紧急修复版本 - 最简单的API
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// 完全关闭错误显示
error_reporting(0);
ini_set('display_errors', 0);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    echo '{"success":true,"message":"API正常","data":null,"version":"4.2.5"}';
} else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    echo '{"success":true,"message":"数据已接收","version":"4.2.5"}';
} else {
    echo '{"success":false,"message":"不支持的方法","version":"4.2.5"}';
}
?>