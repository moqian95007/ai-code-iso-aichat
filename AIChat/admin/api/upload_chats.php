<?php
require_once 'functions.php';

// 允许跨域请求
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // 获取 POST 数据
    $rawInput = file_get_contents('php://input');
    error_log("收到上传请求数据: " . $rawInput);
    
    $data = json_decode($rawInput, true);
    $userId = $data['user_id'] ?? 0;
    $chatRecords = $data['chat_records'] ?? [];
    
    if (empty($userId) || empty($chatRecords)) {
        jsonResponse(['error' => '用户ID或聊天记录为空'], 400);
    }
    
    try {
        $conn = getDbConnection();
        
        // 检查用户是否存在
        $stmt = $conn->prepare("SELECT id FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        if (!$stmt->fetch()) {
            jsonResponse(['error' => '用户不存在'], 400);
        }
        
        // 开始事务
        $conn->beginTransaction();
        $savedCount = 0;
        
        foreach ($chatRecords as $record) {
            // 检查聊天记录是否已存在
            $stmt = $conn->prepare("SELECT id FROM chat_records WHERE client_id = ?");
            $stmt->execute([$record['id']]);
            $existingRecord = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($existingRecord) {
                // 更新已存在的聊天记录
                $stmt = $conn->prepare("UPDATE chat_records SET title = ?, last_message = ?, updated_at = NOW() WHERE id = ?");
                $stmt->execute([$record['title'], $record['last_message'], $existingRecord['id']]);
                $chatRecordId = $existingRecord['id'];
            } else {
                // 插入新的聊天记录
                $stmt = $conn->prepare("INSERT INTO chat_records (client_id, title, last_message, user_id, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())");
                $stmt->execute([$record['id'], $record['title'], $record['last_message'], $userId]);
                $chatRecordId = $conn->lastInsertId();
            }
            
            // 处理聊天消息
            if (isset($record['messages']) && is_array($record['messages'])) {
                foreach ($record['messages'] as $message) {
                    // 检查消息是否已存在
                    $stmt = $conn->prepare("SELECT id FROM messages WHERE chat_record_id = ? AND content = ? AND is_user = ? LIMIT 1");
                    $stmt->execute([$chatRecordId, $message['content'], $message['is_user']]);
                    
                    if (!$stmt->fetch()) {
                        // 插入新消息
                        $stmt = $conn->prepare("INSERT INTO messages (chat_record_id, content, reasoning_content, is_user, timestamp) VALUES (?, ?, ?, ?, NOW())");
                        $stmt->execute([
                            $chatRecordId,
                            $message['content'],
                            $message['reasoning_content'] ?? null,
                            $message['is_user'] ? 1 : 0
                        ]);
                    }
                }
            }
            
            $savedCount++;
        }
        
        // 提交事务
        $conn->commit();
        
        jsonResponse([
            'success' => true, 
            'message' => '聊天记录上传成功',
            'count' => $savedCount
        ]);
        
    } catch (PDOException $e) {
        // 记录错误到日志
        error_log("上传聊天记录错误: " . $e->getMessage());
        
        // 回滚事务
        if (isset($conn) && $conn->inTransaction()) {
            $conn->rollBack();
        }
        
        jsonResponse(['error' => '上传聊天记录失败：' . $e->getMessage()], 500);
    }
} else {
    jsonResponse(['error' => '不支持的请求方法'], 405);
} 