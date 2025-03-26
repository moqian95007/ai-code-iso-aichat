<?php
require_once 'functions.php';

// 允许跨域请求
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 获取 POST 数据
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = $data['user_id'] ?? 0;
    
    if (empty($userId)) {
        jsonResponse(['error' => '用户ID不能为空'], 400);
    }
    
    try {
        $conn = getDbConnection();
        
        // 检查用户是否存在
        $stmt = $conn->prepare("SELECT id FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        if (!$stmt->fetch()) {
            jsonResponse(['error' => '用户不存在'], 400);
        }
        
        // 获取所有聊天记录
        $stmt = $conn->prepare("
            SELECT cr.id, cr.client_id, cr.title, cr.last_message, cr.created_at, cr.updated_at
            FROM chat_records cr
            WHERE cr.user_id = ?
            ORDER BY cr.updated_at DESC
        ");
        $stmt->execute([$userId]);
        $chatRecords = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $result = [];
        
        foreach ($chatRecords as $record) {
            // 获取聊天记录中的消息
            $stmt = $conn->prepare("
                SELECT id, content, reasoning_content, is_user, timestamp
                FROM messages
                WHERE chat_record_id = ?
                ORDER BY timestamp ASC
            ");
            $stmt->execute([$record['id']]);
            $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // 整理消息数组
            $formattedMessages = [];
            foreach ($messages as $message) {
                $formattedMessages[] = [
                    'id' => generateUUID(),
                    'content' => $message['content'],
                    'reasoningContent' => $message['reasoning_content'],
                    'isUser' => (bool)$message['is_user'],
                    'timestamp' => formatDateISO8601($message['timestamp'])
                ];
            }
            
            // 添加聊天记录
            $result[] = [
                'id' => $record['client_id'] ?? generateUUID(),
                'title' => $record['title'],
                'lastMessage' => $record['last_message'],
                'timestamp' => formatDateISO8601($record['updated_at']),
                'messages' => $formattedMessages
            ];
        }
        
        jsonResponse([
            'success' => true,
            'chat_records' => $result
        ]);
        
    } catch (PDOException $e) {
        jsonResponse(['error' => '下载聊天记录失败：' . $e->getMessage()], 500);
    }
} else {
    jsonResponse(['error' => '不支持的请求方法'], 405);
}

// 生成 UUID
function generateUUID() {
    return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
}

// 格式化日期为 ISO8601
function formatDateISO8601($date) {
    return date('c', strtotime($date));
} 