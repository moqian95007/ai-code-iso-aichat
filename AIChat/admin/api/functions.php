<?php
require_once '../config.php';

// 生成 JWT token
function generateToken($userId) {
    $key = "your_secret_key"; // 建议使用更安全的密钥存储方式
    $payload = [
        "user_id" => $userId,
        "exp" => time() + (7 * 24 * 60 * 60) // 7天过期
    ];
    
    $header = base64_encode(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
    $payload = base64_encode(json_encode($payload));
    $signature = hash_hmac('sha256', "$header.$payload", $key, true);
    $signature = base64_encode($signature);
    
    return "$header.$payload.$signature";
}

// 返回 JSON 响应
function jsonResponse($data, $status = 200) {
    header('Content-Type: application/json');
    http_response_code($status);
    echo json_encode($data);
    exit;
} 