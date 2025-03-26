<?php
// 数据库连接配置
$db_host = 'localhost';
$db_name = 'aichat';
$db_user = 'aichat';
$db_pass = 'PxpmDEtH35RdARtK';

// 创建数据库连接
function getDbConnection() {
    global $db_host, $db_name, $db_user, $db_pass;
    
    try {
        $conn = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_pass);
        // 设置 PDO 错误模式为异常
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $conn->exec("SET NAMES utf8mb4");
        return $conn;
    } catch(PDOException $e) {
        die("数据库连接失败: " . $e->getMessage());
    }
}

// 检查登录状态
function checkLogin() {
    // 开始会话（如果尚未开始）
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    // 检查是否已登录
    if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
        // 重定向到登录页面
        header('Location: index.php');
        exit;
    }
} 