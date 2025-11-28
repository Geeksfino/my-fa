# MyFA - AI Financial Assistant Demo

[🇨🇳 中文](README.zh.md) | [🇺🇸 English](README.md)

**MyFA Demo** is a demonstration iOS application showcasing AI-powered financial assistance capabilities. It features conversational AI, portfolio management, and simulated trading functionality.

> **⚠️ IMPORTANT:** This is a **DEMO/SIMULATION** application for educational purposes only. No real money or actual financial transactions are involved.

---

## 🚀 Quick Start Guide

This guide will walk you through:
1. **Setting up the server**
2. **Starting the server**
3. **Running the iOS app** to connect to the server

---

## 📋 Prerequisites

**Required:**
- **macOS** with Xcode 15.0+ installed
- **Node.js** 20.0+ and **pnpm** package manager
- **XcodeGen** for iOS project generation
- **iOS Simulator** or physical iOS device (iOS 16.0+)
- **DeepSeek API Key** (for LLM functionality)

**Install Prerequisites:**

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js (if not installed)
brew install node

# Install pnpm
npm install -g pnpm

# Install XcodeGen
brew install xcodegen
```

---

## 🔧 Step 1: Server Setup

### 1.1 Navigate to Server Directory

```bash
cd server/wealth-mgr
```

### 1.2 Install Dependencies

```bash
pnpm install
```

This will install dependencies for both servers:
- **AG-UI Server** (port 3000): LLM-powered agent
- **MCP-UI Server** (port 3100): UI tools and capabilities

### 1.3 Configure API Keys

Create or edit `agui-server/.env`:

```env
PORT=3000
AGENT_MODE=llm
LLM_PROVIDER=deepseek
DEEPSEEK_API_KEY=your-deepseek-api-key-here
```

> **Note:** You need a DeepSeek API key. Get one at [platform.deepseek.com](https://platform.deepseek.com)

### 1.4 Build the Servers

```bash
pnpm build
```

This compiles TypeScript code for both servers.

---

## 🚀 Step 2: Start the Server

### Option A: Using the Start Script (Recommended)

```bash
./start.sh
```

This script will:
1. Start the MCP-UI server on port 3100
2. Wait for it to be ready
3. Start the AG-UI server on port 3000
4. Connect them together

### Option B: Using pnpm

```bash
pnpm dev
```

This runs the same startup process via pnpm.

### Verify Servers Are Running

Open a new terminal and check:

```bash
# Check AG-UI server (main agent endpoint)
curl http://localhost:3000/health

# Check MCP-UI server (tools endpoint)
curl http://localhost:3100/health
```

Both should respond with health status.

### View Server Logs

In separate terminals:

```bash
# AG-UI server logs
tail -f agui-server.log

# MCP-UI server logs
tail -f mcpui-server.log
```

**Keep the server running** - you'll need it for the iOS app to connect.

---

## 📱 Step 3: Configure and Run the iOS App

### 3.1 Navigate to iOS Directory

```bash
# From the MyFA root directory
cd iOS
```

### 3.2 Generate Xcode Project

```bash
make generate
```

This creates `MyFA.xcodeproj` from `project.yml` using XcodeGen.

### 3.3 Configure Server Connection

The iOS app is pre-configured to connect to `http://127.0.0.1:3000/agent` in **Debug** builds.

**For iOS Simulator (default):**
- No configuration needed - the app will automatically connect to `http://127.0.0.1:3000/agent`
- Make sure the server is running on your Mac

**For Physical Device:**
You need to update the server URL to use your Mac's IP address:

1. Find your Mac's local IP address:
   ```bash
   ipconfig getifaddr en0
   ```
   Example output: `192.168.1.100`

2. Set the `SERVER_URL` environment variable:
   ```bash
   SERVER_URL=http://192.168.1.100:3000/agent make run
   ```

   Or set it in Xcode:
   - Edit Scheme → Run → Arguments → Environment Variables
   - Add `SERVER_URL` = `http://YOUR_MAC_IP:3000/agent`

### 3.4 Build and Run the App

**Option A: Run from Command Line (Simulator)**

```bash
make run
```

This will:
1. Generate the Xcode project (if needed)
2. Build the app
3. Launch it on the default iOS simulator (iPhone 17)

**Option B: Open in Xcode**

```bash
make open
```

Then press `⌘+R` to build and run.

**Customize Simulator Device:**

```bash
# Use specific simulator
SIMULATOR_DEVICE="iPhone 15 Pro" make run

# List available simulators
xcrun simctl list devices available
```

---

## ✅ Verification

### Test Server Connection

1. **Launch the app** on the simulator
2. **Send a chat message** (e.g., "Hello")
3. **Check server logs** - you should see the request:
   ```bash
   tail -f server/wealth-mgr/agui-server.log
   ```
4. **Check app** - you should receive an AI response

### Test from Command Line

```bash
curl -X POST http://localhost:3000/agent \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{
    "threadId": "test",
    "runId": "1",
    "messages": [{"id":"1","role":"user","content":"Hello"}],
    "tools": [],
    "context": []
  }'
```

---

## 🐛 Troubleshooting

### Server Issues

**Port already in use:**
```bash
# Change ports
MCPUI_PORT=3101 AGUI_PORT=3001 ./start.sh
```

**MCP connection failed:**
```bash
# Check MCP-UI server
curl http://localhost:3100/health

# Review logs
tail -f mcpui-server.log
```

**Dependencies not installing:**
```bash
cd server/wealth-mgr
pnpm clean
pnpm install
```

### iOS Build Issues

**XcodeGen not found:**
```bash
brew install xcodegen
```

**Simulator not found:**
```bash
# List available simulators
xcrun simctl list devices available

# Use specific simulator
SIMULATOR_DEVICE="iPhone 15" make run
```

**App won't connect to server:**
1. Verify server is running: `curl http://localhost:3000/health`
2. Check app logs in Xcode console
3. For physical device, ensure both device and Mac are on same network
4. Set `SERVER_URL` environment variable with your Mac's IP

---

## 📚 Additional Resources

- **iOS App Details:** See `iOS/README.md`
- **Server Details:** See `server/wealth-mgr/README.md`
- **App Store Compliance:** See `COMPLIANCE_FIXES_APPLIED.md`

---

## 📄 Project Structure

```
MyFA/
├── server/                    # Backend server
│   └── wealth-mgr/           # Wealth management agent server
│       ├── agui-server/      # AG-UI server (LLM agent) - Port 3000
│       ├── mcpui-server/     # MCP-UI server (UI tools) - Port 3100
│       └── start.sh          # Server startup script
├── iOS/                      # iOS application
│   ├── App/                  # Source code
│   ├── project.yml           # XcodeGen project configuration
│   ├── Makefile              # Build automation
│   └── README.md             # iOS-specific docs
└── README.md                 # This file
```

---

## ⚠️ Disclaimer

**This is a demonstration application for educational purposes only.**

- No real financial data or transactions
- Not intended for actual investment decisions
- No financial licenses or regulatory compliance
- Use at your own risk

For actual financial services, consult licensed financial advisors and use production-grade, regulated platforms.

---

**Language:** [🇨🇳 中文](README.zh.md) | [🇺🇸 English](README.md)

**Version:** 1.0.0  
**Last Updated:** November 28, 2025
