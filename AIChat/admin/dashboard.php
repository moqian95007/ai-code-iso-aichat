<?php
require_once 'config.php';
checkLogin();

// 获取用户总数
function getUserCount() {
    try {
        $conn = getDbConnection();
        $stmt = $conn->query("SELECT COUNT(*) FROM users");
        return $stmt->fetchColumn();
    } catch(PDOException $e) {
        return 0;
    }
}

// 获取聊天记录总数
function getChatRecordCount() {
    try {
        $conn = getDbConnection();
        $stmt = $conn->query("SELECT COUNT(*) FROM chat_records");
        return $stmt->fetchColumn();
    } catch(PDOException $e) {
        return 0;
    }
}

// 获取消息总数
function getMessageCount() {
    try {
        $conn = getDbConnection();
        $stmt = $conn->query("SELECT COUNT(*) FROM messages");
        return $stmt->fetchColumn();
    } catch(PDOException $e) {
        return 0;
    }
}

$userCount = getUserCount();
$chatRecordCount = getChatRecordCount();
$messageCount = getMessageCount();
?>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AIChat 管理系统 - 仪表盘</title>
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
        .stats-container {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        .stat-card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
            flex-basis: calc(33.333% - 20px);
            margin-bottom: 20px;
            text-align: center;
        }
        .stat-card h2 {
            margin-top: 0;
            color: #333;
            font-size: 18px;
        }
        .stat-card .number {
            font-size: 48px;
            font-weight: bold;
            color: #007bff;
            margin: 10px 0;
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
        @media (max-width: 768px) {
            .stat-card {
                flex-basis: 100%;
            }
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
            <a href="dashboard.php" class="active">仪表盘</a>
            <a href="users.php">用户管理</a>
            <a href="chats.php">对话记录</a>
        </div>
        
        <div class="stats-container">
            <div class="stat-card">
                <h2>注册用户数</h2>
                <div class="number"><?php echo $userCount; ?></div>
            </div>
            <div class="stat-card">
                <h2>对话记录数</h2>
                <div class="number"><?php echo $chatRecordCount; ?></div>
            </div>
            <div class="stat-card">
                <h2>消息总数</h2>
                <div class="number"><?php echo $messageCount; ?></div>
            </div>
        </div>
    </div>
</body>
</html> 