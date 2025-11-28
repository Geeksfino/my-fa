# MyFA - AI 金融助手演示应用

[🇺🇸 English](README.md) | [🇨🇳 中文](README.zh.md)

**MyFA Demo** 是一个展示 AI 驱动的金融助手功能的 iOS 演示应用。它包含对话式 AI、投资组合管理和模拟交易功能。

> **⚠️ 重要提示：** 这是一个**演示/模拟**应用，仅用于教育目的。不涉及真实资金或实际金融交易。

---

## 🚀 快速开始指南

本指南将引导您完成：
1. **设置服务器**
2. **启动服务器**
3. **运行 iOS 应用**并连接到服务器

---

## 📋 前置要求

**必需：**
- **macOS** 系统，已安装 Xcode 15.0+
- **Node.js** 20.0+ 和 **pnpm** 包管理器
- **XcodeGen** 用于 iOS 项目生成
- **iOS 模拟器**或物理 iOS 设备 (iOS 16.0+)
- **DeepSeek API 密钥**（用于 LLM 功能）

**安装前置要求：**

```bash
# 安装 Homebrew（如果未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Node.js（如果未安装）
brew install node

# 安装 pnpm
npm install -g pnpm

# 安装 XcodeGen
brew install xcodegen
```

---

## 🔧 步骤 1：服务器设置

### 1.1 进入服务器目录

```bash
cd server/wealth-mgr
```

### 1.2 安装依赖

```bash
pnpm install
```

这将为两个服务器安装依赖：
- **AG-UI 服务器**（端口 3000）：LLM 驱动的智能体
- **MCP-UI 服务器**（端口 3100）：UI 工具和功能

### 1.3 配置 API 密钥

创建或编辑 `agui-server/.env`：

```env
PORT=3000
AGENT_MODE=llm
LLM_PROVIDER=deepseek
DEEPSEEK_API_KEY=your-deepseek-api-key-here
```

> **注意：** 您需要一个 DeepSeek API 密钥。在 [platform.deepseek.com](https://platform.deepseek.com) 获取

### 1.4 构建服务器

```bash
pnpm build
```

这将编译两个服务器的 TypeScript 代码。

---

## 🚀 步骤 2：启动服务器

### 选项 A：使用启动脚本（推荐）

```bash
./start.sh
```

此脚本将：
1. 在端口 3100 上启动 MCP-UI 服务器
2. 等待其准备就绪
3. 在端口 3000 上启动 AG-UI 服务器
4. 将它们连接在一起

### 选项 B：使用 pnpm

```bash
pnpm dev
```

这通过 pnpm 运行相同的启动过程。

### 验证服务器是否运行

打开新终端并检查：

```bash
# 检查 AG-UI 服务器（主要智能体端点）
curl http://localhost:3000/health

# 检查 MCP-UI 服务器（工具端点）
curl http://localhost:3100/health
```

两者都应返回健康状态。

### 查看服务器日志

在单独的终端中：

```bash
# AG-UI 服务器日志
tail -f agui-server.log

# MCP-UI 服务器日志
tail -f mcpui-server.log
```

**保持服务器运行** - iOS 应用需要它来连接。

---

## 📱 步骤 3：配置并运行 iOS 应用

### 3.1 进入 iOS 目录

```bash
# 从 MyFA 根目录
cd iOS
```

### 3.2 生成 Xcode 项目

```bash
make generate
```

这将使用 XcodeGen 从 `project.yml` 创建 `MyFA.xcodeproj`。

### 3.3 配置服务器连接

iOS 应用在 **Debug** 构建中预配置为连接到 `http://127.0.0.1:3000/agent`。

**对于 iOS 模拟器（默认）：**
- 无需配置 - 应用将自动连接到 `http://127.0.0.1:3000/agent`
- 确保服务器在您的 Mac 上运行

**对于物理设备：**
您需要将服务器 URL 更新为使用 Mac 的 IP 地址：

1. 查找 Mac 的本地 IP 地址：
   ```bash
   ipconfig getifaddr en0
   ```
   示例输出：`192.168.1.100`

2. 设置 `SERVER_URL` 环境变量：
   ```bash
   SERVER_URL=http://192.168.1.100:3000/agent make run
   ```

   或在 Xcode 中设置：
   - 编辑方案 → 运行 → 参数 → 环境变量
   - 添加 `SERVER_URL` = `http://YOUR_MAC_IP:3000/agent`

### 3.4 构建并运行应用

**选项 A：从命令行运行（模拟器）**

```bash
make run
```

这将：
1. 生成 Xcode 项目（如需要）
2. 构建应用
3. 在默认 iOS 模拟器（iPhone 17）上启动它

**选项 B：在 Xcode 中打开**

```bash
make open
```

然后按 `⌘+R` 构建并运行。

**自定义模拟器设备：**

```bash
# 使用特定模拟器
SIMULATOR_DEVICE="iPhone 15 Pro" make run

# 列出可用模拟器
xcrun simctl list devices available
```

---

## ✅ 验证

### 测试服务器连接

1. **在模拟器上启动应用**
2. **发送聊天消息**（例如，"你好"）
3. **检查服务器日志** - 您应该看到请求：
   ```bash
   tail -f server/wealth-mgr/agui-server.log
   ```
4. **检查应用** - 您应该收到 AI 响应

### 从命令行测试

```bash
curl -X POST http://localhost:3000/agent \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{
    "threadId": "test",
    "runId": "1",
    "messages": [{"id":"1","role":"user","content":"你好"}],
    "tools": [],
    "context": []
  }'
```

---

## 🐛 故障排除

### 服务器问题

**端口已被占用：**
```bash
# 更改端口
MCPUI_PORT=3101 AGUI_PORT=3001 ./start.sh
```

**MCP 连接失败：**
```bash
# 检查 MCP-UI 服务器
curl http://localhost:3100/health

# 查看日志
tail -f mcpui-server.log
```

**依赖安装失败：**
```bash
cd server/wealth-mgr
pnpm clean
pnpm install
```

### iOS 构建问题

**找不到 XcodeGen：**
```bash
brew install xcodegen
```

**找不到模拟器：**
```bash
# 列出可用模拟器
xcrun simctl list devices available

# 使用特定模拟器
SIMULATOR_DEVICE="iPhone 15" make run
```

**应用无法连接到服务器：**
1. 验证服务器是否运行：`curl http://localhost:3000/health`
2. 检查 Xcode 控制台中的应用日志
3. 对于物理设备，确保设备和 Mac 在同一网络
4. 使用 Mac 的 IP 设置 `SERVER_URL` 环境变量

---

## 📚 其他资源

- **iOS 应用详情：** 参见 `iOS/README.md`
- **服务器详情：** 参见 `server/wealth-mgr/README.md`
- **App Store 合规性：** 参见 `COMPLIANCE_FIXES_APPLIED.md`

---

## 📄 项目结构

```
MyFA/
├── server/                    # 后端服务器
│   └── wealth-mgr/           # 财富管理智能体服务器
│       ├── agui-server/      # AG-UI 服务器（LLM 智能体）- 端口 3000
│       ├── mcpui-server/     # MCP-UI 服务器（UI 工具）- 端口 3100
│       └── start.sh          # 服务器启动脚本
├── iOS/                      # iOS 应用
│   ├── App/                  # 源代码
│   ├── project.yml           # XcodeGen 项目配置
│   ├── Makefile              # 构建自动化
│   └── README.md             # iOS 特定文档
└── README.md                 # 本文件
```

---

## ⚠️ 免责声明

**这是一个仅用于教育目的的演示应用。**

- 无真实金融数据或交易
- 不用于实际投资决策
- 无金融许可证或监管合规
- 使用风险自负

对于实际金融服务，请咨询持牌金融顾问并使用生产级、受监管的平台。

---

**语言：** [🇺🇸 English](README.md) | [🇨🇳 中文](README.zh.md)

**版本：** 1.0.0  
**最后更新：** 2025年11月28日

