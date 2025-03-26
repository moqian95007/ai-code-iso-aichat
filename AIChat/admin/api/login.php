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
    
    try {
        $conn = getDbConnection();
        
        // 查询用户
        $stmt = $conn->prepare("SELECT id, email, password FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user || !password_verify($password, $user['password'])) {
            jsonResponse(['error' => '邮箱或密码错误'], 401);
        }
        
        // 生成 token
        $token = generateToken($user['id']);
        
        // 返回用户信息
        jsonResponse([
            'id' => $user['id'],
            'email' => $user['email'],
            'token' => $token
        ]);
        
    } catch (PDOException $e) {
        jsonResponse(['error' => '登录失败，请稍后重试'], 500);
    }
} else {
    jsonResponse(['error' => '不支持的请求方法'], 405);
} 