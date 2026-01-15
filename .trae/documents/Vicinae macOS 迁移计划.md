# Vicinae macOS 原生迁移计划

本计划概述了将 Vicinae 主程序迁移到使用 Swift 和 SwiftUI 的原生 macOS 应用程序的步骤，替代 Qt 框架，同时保留 TypeScript 扩展生态系统。

## 第一阶段：项目初始化与核心基础设施

### 1.1 创建 macOS 项目，项目基础已经创建好，在根目录的vicinae-macos

* 设置项目结构：

  * `Core/`: IPC 通信、扩展管理。

  * `UI/`: SwiftUI 视图、渲染引擎。

  * `API/`: Vicinae API 的原生实现。

  * `Protobuf/`: 从 `.proto` 文件生成的 Swift 代码。

### 1.2 Protobuf 集成

* 添加 `SwiftProtobuf` 依赖（通过 Swift Package Manager）。

* 使用 `protoc` 将现有的 `.proto` 文件（来自 `proto/`）编译为 Swift 代码。

* 创建构建脚本以自动化 Protobuf 生成。

### 1.3 IPC 层实现

* 实现 `IPCClient` 类以处理与 Node.js 扩展管理器的通信。

* **协议**：标准输入/输出（Stdin/Stdout）上的长度前缀（4字节大端序）Protobuf 消息。

* **消息处理**：

  * `Encoder`: 将 `IpcMessage` 封装在长度前缀的缓冲区中。

  * `Decoder`: 读取长度、缓冲字节并解码 `IpcMessage`。

  * `Dispatcher`: 将消息路由到适当的处理程序（`ManagerResponse`, `ExtensionRequest`, `ExtensionEvent`）。

## 第二阶段：扩展管理器集成

### 2.1 Node.js 打包

* 将独立的 `node` 二进制文件打包在 App Bundle 中（或检测系统 node）。

* 将编译后的 `typescript/extension-manager`（来自 `extension-manager/dist`）复制到 App 的资源中。

### 2.2 扩展生命周期管理

* 在 Swift 中实现 `ExtensionService`。

* **启动**：生成运行 `extension-manager.js` 的 `node` 进程。

* **加载扩展**：发送 `ManagerRequest` (LoadCommand) 以启动扩展会话。

* **卸载**：发送 `ManagerRequest` (UnloadCommand) 以停止会话。

* **崩溃处理**：监听 `CrashEvent` 并重启/通知用户。

## 第三阶段：UI 渲染引擎（"浏览器"）

### 3.1 视图模型

* 创建 `RenderStore` (ObservableObject) 以保存当前视图树状态。

* 将来自 `ui.render` 请求的 JSON 载荷解析为 Swift 结构层次结构（`RenderNode`）。

### 3.2 组件映射 (JSON -> SwiftUI)

* 实现递归的 `OmniView`，根据组件类型（`List`, `Grid`, `ActionPanel`, `Detail` 等）进行切换。

* **需实现的组件**：

  * `List` / `List.Item`

  * `Grid` / `Grid.Item`

  * `ActionPanel` / `Action`

  * `Detail` (Markdown 渲染)

  * `Form` (TextField, Dropdown, Checkbox)

* **状态管理**：处理 `dirty` 标志和部分更新（如果 JSON 模式支持，否则进行全量重新渲染）。

### 3.3 导航

* 在 Swift 中实现导航堆栈管理器以处理 `push_view` 和 `pop_view` 请求。

* 维护 `RenderStore` 实例堆栈，每个推送的视图一个。

## 第四阶段：API 桥接实现

### 4.1 系统 API

* **剪贴板**：使用 `NSPasteboard` 实现 `clipboard.read/write`。

* **Toast**：使用自定义 SwiftUI 覆盖层或系统通知实现 `show_toast`。

* **文件系统**：使用 `NSOpenPanel` 实现 `file_search`, `show_open_dialog`。

* **启动器**：使用 `NSWorkspace` 实现 `launch_app`, `open_url`。

### 4.2 Raycast 兼容性

* 确保原生 API 实现符合 Raycast API 兼容层的预期行为。

* 如果 IPC 消息处理正确，现有的 `typescript/raycast-api-compat` 应该可以开箱即用。

## 第五阶段：Raycast 商店与包管理

### 5.1 扩展商店

* 将从 Raycast 商店获取扩展的逻辑（最初为 C++）移植到 Swift。

* 实现下载、解压（使用 `ZIPFoundation` 或系统 `tar`）并安装到应用程序支持目录。

### 5.2 本地扩展发现

* 扫描已安装扩展的标准目录。

* 解析 `package.json` 清单以构建扩展目录。

## 第六阶段：打磨与验证

### 6.1 UI 打磨

* 匹配 Raycast/Vicinae 的视觉风格（半透明材质、键盘为中心的导航）。

* 实现全局热键支持（使用 `Carbon` API 或 `HotKey` 库）。

### 6.2 测试

* 验证与标准 Raycast 扩展的兼容性。

* 测试边缘情况：进程崩溃、重型 UI 载荷、快速导航。

