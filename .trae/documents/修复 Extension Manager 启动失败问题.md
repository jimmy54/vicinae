
# 修复 Extension Manager 启动失败问题

分析显示 `ExtensionService` 启动失败的原因是缺少 Node.js 模块 `/Users/jimmy54/Documents/github/vicinae/typescript/extension-manager/dist/index.js`。这意味着 `extension-manager` 项目尚未编译。

此外，用户在终端遇到的 `npm ERR!` 是因为在 `typescript` 根目录下运行了 `npm` 命令，而该目录没有 `package.json` 文件。

我们将按顺序编译 TypeScript 项目依赖。

## 1. 编译 API 依赖
首先需要编译被其他模块依赖的 `@vicinae/api` 包。
1. 进入 `typescript/api` 目录
2. 安装依赖 (`npm install`)
3. 编译项目 (`npm run build`)

## 2. 编译 Extension Manager
接着编译核心的扩展管理器。
1. 进入 `typescript/extension-manager` 目录
2. 安装依赖 (`npm install`)
3. 编译项目 (`npm run build`)

执行完上述步骤后，`dist/index.js` 将会被生成，Vicinae 应用应当能够正常启动 Extension Manager。
