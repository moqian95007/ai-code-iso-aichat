<?php
require_once 'config.php';
checkLogin();

// 处理用户编辑
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'edit') {
    $userId = $_POST['user_id'] ?? 0;
    $email = $_POST['email'] ?? '';
    
    try {
        $conn = getDbConnection();
        $stmt = $conn->prepare("UPDATE users SET email = ? WHERE id = ?");
        $stmt->execute([$email, $userId]);
        
        // 如果有新密码，则更新密码
        if (!empty($_POST['password'])) {
            $password = password_hash($_POST['password'], PASSWORD_DEFAULT);
            $stmt = $conn->prepare("UPDATE users SET password = ? WHERE id = ?");
            $stmt->execute([$password, $userId]);
        }
        
        $successMessage = "用户更新成功！";
    } catch(PDOException $e) {
        $errorMessage = "更新用户失败: " . $e->getMessage();
    }
}

// 获取所有用户
function getUsers() {
    try {
        $conn = getDbConnection();
        $stmt = $conn->query("
            SELECT u.*, 
                   COUNT(DISTINCT cr.id) as chat_count, 
                   COUNT(m.id) as message_count
            FROM users u
            LEFT JOIN chat_records cr ON u.id = cr.user_id
            LEFT JOIN messages m ON cr.id = m.chat_record_id
            GROUP BY u.id
            ORDER BY u.created_at DESC
        ");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch(PDOException $e) {
        echo "获取用户列表失败: " . $e->getMessage();
        return [];
    }
}

$users = getUsers();
?>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AIChat 管理系统 - 用户管理</title>
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
        .btn-edit {
            background-color: #28a745;
        }
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            overflow: auto;
        }
        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 20px;
            border-radius: 8px;
            max-width: 500px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover {
            color: black;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .form-control {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .form-buttons {
            margin-top: 20px;
            text-align: right;
        }
        .alert {
            padding: 10px 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .no-data {
            text-align: center;
            padding: 30px;
            color: #777;
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
            <a href="users.php" class="active">用户管理</a>
            <a href="chats.php">对话记录</a>
        </div>
        
        <?php if (isset($successMessage)): ?>
            <div class="alert alert-success"><?php echo $successMessage; ?></div>
        <?php endif; ?>
        
        <?php if (isset($errorMessage)): ?>
            <div class="alert alert-danger"><?php echo $errorMessage; ?></div>
        <?php endif; ?>
        
        <div class="content-box">
            <div class="content-header">
                <h2>注册用户列表</h2>
            </div>
            <div class="content-body">
                <?php if (empty($users)): ?>
                    <div class="no-data">暂无注册用户</div>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>邮箱</th>
                                <th>注册时间</th>
                                <th>聊天数量</th>
                                <th>消息数量</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($users as $user): ?>
                                <tr>
                                    <td><?php echo $user['id']; ?></td>
                                    <td><?php echo htmlspecialchars($user['email']); ?></td>
                                    <td><?php echo date('Y-m-d H:i:s', strtotime($user['created_at'])); ?></td>
                                    <td><?php echo $user['chat_count']; ?></td>
                                    <td><?php echo $user['message_count']; ?></td>
                                    <td>
                                        <button class="btn btn-sm btn-edit" onclick="openEditModal(<?php echo $user['id']; ?>, '<?php echo htmlspecialchars($user['email']); ?>')">编辑</button>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
        </div>
    </div>
    
    <!-- 编辑用户模态框 -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeEditModal()">&times;</span>
            <h2>编辑用户</h2>
            <form method="post" action="users.php">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" id="edit_user_id" name="user_id" value="">
                
                <div class="form-group">
                    <label for="edit_email">邮箱</label>
                    <input type="email" id="edit_email" name="email" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="edit_password">新密码（留空则不修改）</label>
                    <input type="password" id="edit_password" name="password" class="form-control">
                </div>
                
                <div class="form-buttons">
                    <button type="button" class="btn" onclick="closeEditModal()" style="background-color: #6c757d;">取消</button>
                    <button type="submit" class="btn" style="margin-left: 10px;">保存</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        // 获取模态框
        var editModal = document.getElementById("editModal");
        
        // 打开编辑模态框
        function openEditModal(userId, email) {
            document.getElementById('edit_user_id').value = userId;
            document.getElementById('edit_email').value = email;
            document.getElementById('edit_password').value = '';
            editModal.style.display = "block";
        }
        
        // 关闭模态框
        function closeEditModal() {
            editModal.style.display = "none";
        }
        
        // 点击模态框外部关闭
        window.onclick = function(event) {
            if (event.target == editModal) {
                closeEditModal();
            }
        }
    </script>
</body>
</html> 