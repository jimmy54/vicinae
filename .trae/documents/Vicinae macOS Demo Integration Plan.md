# 修复与集成计划

根据您的报错信息，存在两个主要问题：
1. **运行时错误**：`Extension Manager` 启动失败，因为找不到编译后的 JS 文件 (`dist/index.js`)。
2. **编译错误**：Demo 项目无法导入 `Vicinae` 模块，这是因为 `vicinae-macos` 目前配置为可执行文件（Executable），而不是库（Library），无法被其他项目直接导入。

我将按以下步骤解决：

## 第一步：编译 TypeScript Extension Manager
您的运行时错误是因为 TypeScript 代码尚未编译。
*   **操作**：在 `typescript/extension-manager` 目录下运行安装依赖和构建命令。
*   **目标**：生成 `dist/index.js`，解决 `MODULE_NOT_FOUND` 错误。

## 第二步：重构 Package.swift 以支持库引用
为了让 Demo 项目能使用核心功能，我需要调整 Swift Package 的结构。
*   **操作**：
    *   将核心逻辑（IPC, UI渲染, Store等）提取到一个新的库 Target：`VicinaeCore`。
    *   保留 `Vicinae` 作为可执行 Target，依赖 `VicinaeCore`。
    *   在 `Package.swift` 中导出一项 `library` 产品 `VicinaeCore`。
*   **目标**：使 `vicinae-macos` 可以作为第三方库被引入到 Demo 项目中。

## 第三步：更新 Demo 项目代码
*   **操作**：将 Demo 项目中的 `import Vicinae` 修改为 `import VicinaeCore`。
*   **注意**：您需要在 Xcode 项目设置中，手动将本地的 `vicinae-macos` 文件夹添加为 Package Dependency（如果尚未添加）。

## 第四步：解决资源路径问题
您提到的 `Invalid Resource 'Resources': File not found` 是因为 `Package.swift` 中引用了 `Resources` 目录，但可能该目录为空或未正确创建。
*   **操作**：检查并确保 `Sources/VicinaeCore/Resources` 存在（如果移动了代码），或者暂时移除该资源引用，直到我们需要打包 Node.js 二进制文件为止。

执行完这些步骤后，您就可以在 Demo App 中正常运行并看到 Vicinae 的核心功能了。
