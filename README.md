# AIChat 应用

AIChat 是一个基于 SwiftUI 开发的 iOS 聊天应用，集成了 DeepSeek 大语言模型，让用户可以与 AI 进行自然语言对话。应用支持深度思考模式、聊天历史记录管理、用户账户系统等功能，为用户提供丰富的 AI 对话体验。

## 功能特点

- **双模型切换**：支持在 DeepSeek-V3（标准模式）和 DeepSeek-R1（深度思考模式）之间切换
- **深度思考可视化**：在深度思考模式下，显示 AI 的思考过程
- **用户账户系统**：支持用户注册和登录，非登录用户有聊天次数限制
- **数据同步**：登录后自动同步聊天记录到云端，在多设备间保持一致
- **聊天记录管理**：自动保存对话，并支持按照时间分组显示（今天、昨天、更早）
- **搜索功能**：支持搜索历史对话内容
- **即时反馈**：发送消息时显示加载动画，提升用户体验
- **新聊天创建**：随时可以开始新的对话
- **后台管理系统**：提供完整的用户和聊天记录管理功能

## 技术架构

AIChat 采用 MVVM 架构设计，主要组件包括：

### 视图层 (View)
- `ContentView`：应用的主要容器，包含标签式导航
- `ChatView`：聊天界面，显示消息并处理用户输入
- `ChatListView`：显示聊天记录列表，支持搜索和删除
- `MessageBubbleView`：消息气泡组件，支持显示思考内容
- `LoadingBubbleView`：加载动画组件
- `LoginView`：用户登录和注册界面
- `UserProfileView`：用户个人资料界面

### 模型层 (Model)
- `Message`：消息数据模型，包含内容、时间戳等
- `ChatRecord`：聊天记录数据模型，包含一组消息
- `AIResponse`：API 响应模型，包含回复内容和思考内容
- `User`：用户数据模型，包含用户ID、邮箱和token

### 视图模型层 (ViewModel)
- `ChatStore`：管理聊天记录的存储和检索

### 服务层 (Service)
- `ChatService`：处理与 DeepSeek API 的通信
- `AuthService`：处理用户认证和聊天记录同步

### 后台管理系统
- `dashboard.php`：管理系统仪表盘，显示统计数据
- `users.php`：用户管理页面，支持编辑用户信息
- `chats.php`：聊天记录管理页面，支持查看详细对话内容
- `logout.php`：退出登录功能

## 目录结构

```
AIChat/
├── AIChatApp.swift              # 应用入口
├── ContentView.swift            # 主视图
├── ChatView.swift               # 聊天界面
├── ChatListView.swift           # 聊天记录列表
├── MessageBubbleView.swift      # 消息气泡组件
├── LoadingBubbleView.swift      # 加载动画组件
├── LoginView.swift              # 登录/注册界面
├── UserProfileView.swift        # 用户信息界面
├── ChatService.swift            # AI 聊天服务
├── Services/
│   └── AuthService.swift        # 认证服务
├── Models/
│   ├── Models.swift             # 聊天相关数据模型
│   ├── User.swift               # 用户数据模型
│   └── ChatStore.swift          # 聊天记录管理
└── admin/                       # 后台管理系统
    ├── index.php                # 管理员登录
    ├── dashboard.php            # 仪表盘
    ├── users.php                # 用户管理
    ├── chats.php                # 聊天记录管理 
    ├── logout.php               # 退出登录
    └── api/                     # API接口
        ├── login.php            # 登录API
        ├── register.php         # 注册API
        ├── upload_chats.php     # 上传聊天记录
        ├── download_chats.php   # 下载聊天记录
        └── functions.php        # 通用函数
```

## 使用方法

### 用户注册和登录
1. 未登录状态下，点击聊天界面的"登录"按钮
2. 选择"登录"或"注册"模式
3. 输入邮箱和密码完成操作
4. 登录后可以使用无限次聊天，并自动同步聊天记录

### 开始新对话
1. 打开应用，默认进入聊天界面
2. 在输入框中输入问题并发送
3. 等待 AI 回复（过程中会显示加载动画）

### 切换思考模式
- 点击聊天界面上方的"深度思考"按钮可以切换思考模式：
  - 绿色背景：深度思考模式已开启 (DeepSeek-R1)
  - 灰色背景：标准模式 (DeepSeek-V3)

### 管理聊天记录
1. 点击底部标签栏的"记录"进入聊天记录界面
2. 使用顶部搜索栏搜索记录
3. 向左滑动记录可以删除

### 退出登录
1. 点击聊天界面中的用户邮箱打开用户资料页面
2. 点击"退出登录"按钮
3. 退出登录后聊天记录将被清空，以确保隐私安全

## 后台管理系统

### 登录管理系统
1. 访问管理系统登录页面
2. 使用管理员账号登录

### 主要功能
- **仪表盘**：显示用户数量、聊天记录数量和消息数量等统计信息
- **用户管理**：查看和编辑用户信息
- **聊天记录**：查看和管理用户的聊天记录
- **详细消息**：查看每条聊天记录的详细消息内容

## API 配置

应用使用 DeepSeek API 进行通信，API 密钥存储在 `ChatService.swift` 文件中。在生产环境中，建议将 API 密钥存储在更安全的位置，如 Keychain。

## 开发环境

- Xcode 15.2+
- Swift 5.9+
- iOS 17.0+
- PHP 8.0+
- MySQL 8.0+
- 支持 SwiftUI 生命周期

## 未来计划

- 支持多轮对话上下文
- 添加主题切换功能
- 支持导出聊天记录
- 添加语音输入和朗读功能
- 实现聊天记录加密存储
- 添加社交分享功能 