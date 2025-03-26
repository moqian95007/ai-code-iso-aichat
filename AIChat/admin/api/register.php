<?php
require_once 'functions.php';

// 允许跨域请求
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 获取 POST 数据
    $data = json_decode(file_get_contents('php://input'), true);
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';
    
    if (empty($email) || empty($password)) {
        jsonResponse(['error' => '邮箱和密码不能为空'], 400);
    }
    
    // 验证邮箱格式
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        jsonResponse(['error' => '邮箱格式不正确'], 400);
    }
    
    try {
        $conn = getDbConnection();
        
        // 检查邮箱是否已存在
        $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            jsonResponse(['error' => '该邮箱已被注册'], 400);
        }
        
        // 密码加密
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        
        // 插入新用户
        $stmt = $conn->prepare("INSERT INTO users (email, password) VALUES (?, ?)");
        $stmt->execute([$email, $hashedPassword]);
        
        $userId = $conn->lastInsertId();
        
        // 生成 token
        $token = generateToken($userId);
        
        // 返回用户信息
        jsonResponse([
            'id' => $userId,
            'email' => $email,
            'token' => $token
        ]);
        
    } catch (PDOException $e) {
        jsonResponse(['error' => '注册失败，请稍后重试'], 500);
    }
} else {
    jsonResponse(['error' => '不支持的请求方法'], 405);
} 