<?php
require_once 'config.php';
checkLogin();

// 获取查询参数
$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
$searchQuery = isset($_GET['search']) ? trim($_GET['search']) : '';

// 获取聊天记录
function getChatRecords($userId = 0, $searchQuery = '') {
    try {
        $conn = getDbConnection();
        $sql = "
            SELECT cr.*, 
                   u.email as user_email,
                   COUNT(m.id) as message_count
            FROM chat_records cr
            LEFT JOIN users u ON cr.user_id = u.id
            LEFT JOIN messages m ON cr.id = m.chat_record_id
        ";
        
        $params = [];
        $whereConditions = [];
        
        // 按用户筛选
        if ($userId > 0) {
            $whereConditions[] = "cr.user_id = ?";
            $params[] = $userId;
        }
        
        // 按关键词搜索
        if (!empty($searchQuery)) {
            $whereConditions[] = "(cr.title LIKE ? OR EXISTS (SELECT 1 FROM messages m2 WHERE m2.chat_record_id = cr.id AND m2.content LIKE ?))";
            $params[] = "%$searchQuery%";
            $params[] = "%$searchQuery%";
        }
        
        // 添加 WHERE 子句
        if (!empty($whereConditions)) {
            $sql .= " WHERE " . implode(" AND ", $whereConditions);
        }
        
        // 添加分组和排序
        $sql .= " GROUP BY cr.id ORDER BY cr.updated_at DESC";
        
        $stmt = $conn->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch(PDOException $e) {
        echo "获取聊天记录失败: " . $e->getMessage();
        return [];
    }
}

// 获取特定聊天记录的详细信息
function getChatDetails($chatId) {
    try {
        $conn = getDbConnection();
        $stmt = $conn->prepare("
            SELECT cr.*, u.email as user_email
            FROM chat_records cr
            LEFT JOIN users u ON cr.user_id = u.id
            WHERE cr.id = ?
        ");
        $stmt->execute([$chatId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    } catch(PDOException $e) {
        return null;
    }
}

// 获取特定聊天记录的消息
function getChatMessages($chatId) {
    try {
        $conn = getDbConnection();
        $stmt = $conn->prepare("
            SELECT * FROM messages
            WHERE chat_record_id = ?
            ORDER BY timestamp ASC
        ");
        $stmt->execute([$chatId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch(PDOException $e) {
        return [];
    }
}

// 获取所有用户的列表（用于筛选）
function getAllUsers() {
    try {
        $conn = getDbConnection();
        $stmt = $conn->query("SELECT id, email FROM users ORDER BY email");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch(PDOException $e) {
        return [];
    }
}

// 初始化变量
$chatRecords = getChatRecords($userId, $searchQuery);
$users = getAllUsers();
$chatDetail = null;
$chatMessages = [];

// 如果有查看特定对话的请求
if (isset($_GET['chat_id'])) {
    $chatId = (int)$_GET['chat_id'];
    $chatDetail = getChatDetails($chatId);
    $chatMessages = getChatMessages($chatId);
}
?>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AIChat 管理系统 - 对话记录</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        header {
            background-color: #007bff;
            color: white;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        h1 {
            margin: 0;
            font-size: 24px;
        }
        .user-info {
            display: flex;
            align-items: center;
        }
        .user-info span {
            margin-right: 15px;
        }
        .logout-btn {
            background-color: transparent;
            border: 1px solid white;
            color: white;
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }
        .logout-btn:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        .nav-menu {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-top: 30px;
            overflow: hidden;
        }
        .nav-menu a {
            display: inline-block;
            padding: 15px 20px;
            color: #333;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        .nav-menu a:hover {
            background-color: #f0f0f0;
        }
        .nav-menu a.active {
            background-color: #007bff;
            color: white;
        }
        .content-box {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-top: 30px;
            overflow: hidden;
        }
        .content-header {
            background-color: #f0f0f0;
            padding: 15px 20px;
            border-bottom: 1px solid #ddd;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .content-header h2 {
            margin: 0;
            font-size: 20px;
            color: #333;
        }
        .content-body {
            padding: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            text-align: left;
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f5f5f5;
            font-weight: bold;
        }
        tr:hover {
            background-color: #f9f9f9;
        }
        .btn {
            display: inline-block;
            padding: 6px 12px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }
        .btn-sm {
            padding: 4px 8px;
            font-size: 12px;
        }
        .btn-view {
            background-color: #17a2b8;
        }
        .filter-form {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }
        .filter-form select, .filter-form input {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .filter-form button {
            padding: 8px 15px;
        }
        .no-data {
            text-align: center;
            padding: 30px;
            color: #777;
        }
        .chat-detail {
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .chat-detail h3 {
            margin-top: 0;
            color: #333;
        }
        .chat-detail p {
            margin: 5px 0;
            color: #555;
        }
        .chat-messages {
            margin-top: 20px;
        }
        .message {
            margin-bottom: 15px;
            display: flex;
        }
        .message.user {
            justify-content: flex-end;
        }
        .message-content {
            max-width: 80%;
            padding: 10px 15px;
            border-radius: 18px;
            position: relative;
        }
        .message.user .message-content {
            background-color: #007bff;
            color: white;
            border-bottom-right-radius: 4px;
        }
        .message.ai .message-content {
            background-color: #f1f1f1;
            color: #333;
            border-bottom-left-radius: 4px;
        }
        .message-time {
            font-size: 12px;
            color: #999;
            margin-top: 5px;
            text-align: right;
        }
        .message-reasoning {
            margin-top: 10px;
            padding: 10px;
            background-color: #e9f5e9;
            border-radius: 8px;
            color: #28a745;
            font-size: 14px;
        }
        .back-link {
            margin-bottom: 20px;
            display: inline-block;
        }
    </style>
</head>
<body>
    <header>
        <h1>AIChat 管理系统</h1>
        <div class="user-info">
            <span>欢迎, <?php echo htmlspecialchars($_SESSION['admin_username']); ?></span>
            <a href="logout.php" class="logout-btn">退出</a>
        </div>
    </header>
    
    <div class="container">
        <div class="nav-menu">
            <a href="dashboard.php">仪表盘</a>
            <a href="users.php">用户管理</a>
            <a href="chats.php" class="active">对话记录</a>
        </div>
        
        <?php if ($chatDetail): ?>
            <!-- 显示特定对话记录的详情 -->
            <a href="chats.php" class="back-link">&larr; 返回对话列表</a>
            
            <div class="content-box">
                <div class="content-header">
                    <h2><?php echo htmlspecialchars($chatDetail['title']); ?></h2>
                </div>
                <div class="content-body">
                    <div class="chat-detail">
                        <h3>对话信息</h3>
                        <p><strong>ID:</strong> <?php echo $chatDetail['id']; ?></p>
                        <p><strong>用户:</strong> <?php echo $chatDetail['user_id'] ? htmlspecialchars($chatDetail['user_email']) : '未注册用户'; ?></p>
                        <p><strong>创建时间:</strong> <?php echo date('Y-m-d H:i:s', strtotime($chatDetail['created_at'])); ?></p>
                        <p><strong>最后更新:</strong> <?php echo date('Y-m-d H:i:s', strtotime($chatDetail['updated_at'])); ?></p>
                    </div>
                    
                    <div class="chat-messages">
                        <h3>对话内容</h3>
                        <?php if (empty($chatMessages)): ?>
                            <div class="no-data">该对话没有任何消息</div>
                        <?php else: ?>
                            <?php foreach ($chatMessages as $message): ?>
                                <div class="message <?php echo $message['is_user'] ? 'user' : 'ai'; ?>">
                                    <div class="message-content">
                                        <?php echo nl2br(htmlspecialchars($message['content'])); ?>
                                        <div class="message-time">
                                            <?php echo date('Y-m-d H:i:s', strtotime($message['timestamp'])); ?>
                                        </div>
                                        <?php if (!$message['is_user'] && !empty($message['reasoning_content'])): ?>
                                            <div class="message-reasoning">
                                                <strong>思考过程:</strong><br>
                                                <?php echo nl2br(htmlspecialchars($message['reasoning_content'])); ?>
                                            </div>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        <?php else: ?>
            <!-- 显示对话列表 -->
            <div class="content-box">
                <div class="content-header">
                    <h2>对话记录列表</h2>
                </div>
                <div class="content-body">
                    <form class="filter-form" method="get" action="chats.php">
                        <select name="user_id">
                            <option value="0">所有用户</option>
                            <?php foreach ($users as $user): ?>
                                <option value="<?php echo $user['id']; ?>" <?php echo $userId == $user['id'] ? 'selected' : ''; ?>>
                                    <?php echo htmlspecialchars($user['email']); ?>
                                </option>
                            <?php endforeach; ?>
                            <option value="-1" <?php echo $userId === -1 ? 'selected' : ''; ?>>未注册用户</option>
                        </select>
                        <input type="text" name="search" placeholder="搜索关键词..." value="<?php echo htmlspecialchars($searchQuery); ?>">
                        <button type="submit" class="btn">筛选</button>
                        <a href="chats.php" class="btn" style="background-color: #6c757d;">重置</a>
                    </form>
                    
                    <?php if (empty($chatRecords)): ?>
                        <div class="no-data">暂无对话记录</div>
                    <?php else: ?>
                        <table>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>标题</th>
                                    <th>用户</th>
                                    <th>消息数</th>
                                    <th>最后更新</th>
                                    <th>操作</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($chatRecords as $chat): ?>
                                    <tr>
                                        <td><?php echo $chat['id']; ?></td>
                                        <td><?php echo htmlspecialchars($chat['title']); ?></td>
                                        <td><?php echo $chat['user_id'] ? htmlspecialchars($chat['user_email']) : '未注册用户'; ?></td>
                                        <td><?php echo $chat['message_count']; ?></td>
                                        <td><?php echo date('Y-m-d H:i:s', strtotime($chat['updated_at'])); ?></td>
                                        <td>
                                            <a href="chats.php?chat_id=<?php echo $chat['id']; ?>" class="btn btn-sm btn-view">查看详情</a>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    <?php endif; ?>
                </div>
            </div>
        <?php endif; ?>
    </div>
</body>
</html> 