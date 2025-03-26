<?php
require_once 'config.php';

// 创建表结构
function setupDatabase() {
    try {
        $conn = getDbConnection();
        
        // 创建用户表
        $conn->exec("
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(255) NOT NULL UNIQUE,
                password VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");
        
        // 创建对话记录表
        $conn->exec("
            CREATE TABLE IF NOT EXISTS chat_records (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                user_id INT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");
        
        // 创建消息表
        $conn->exec("
            CREATE TABLE IF NOT EXISTS messages (
                id INT AUTO_INCREMENT PRIMARY KEY,
                chat_record_id INT NOT NULL,
                content TEXT NOT NULL,
                reasoning_content TEXT,
                is_user BOOLEAN NOT NULL,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (chat_record_id) REFERENCES chat_records(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");
        
        // 创建管理员表
        $conn->exec("
            CREATE TABLE IF NOT EXISTS admins (
                id INT AUTO_INCREMENT PRIMARY KEY,
                username VARCHAR(50) NOT NULL UNIQUE,
                password VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ");
        
        // 插入默认管理员账号
        $adminUsername = 'admin';
        $adminPassword = password_hash('admin123', PASSWORD_DEFAULT);
        
        $stmt = $conn->prepare("SELECT COUNT(*) FROM admins WHERE username = ?");
        $stmt->execute([$adminUsername]);
        
        if ($stmt->fetchColumn() == 0) {
            $stmt = $conn->prepare("INSERT INTO admins (username, password) VALUES (?, ?)");
            $stmt->execute([$adminUsername, $adminPassword]);
            echo "默认管理员账号已创建: username=admin, password=admin123<br>";
        }
        
        echo "数据库初始化完成！<br>";
        echo "<a href='index.php'>返回登录页面</a>";
        
    } catch(PDOException $e) {
        die("数据库设置失败: " . $e->getMessage());
    }
}

// 执行数据库初始化
setupDatabase(); 