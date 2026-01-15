import Foundation
import SwiftProtobuf

class ExtensionService: IPCClientDelegate {
    static let shared = ExtensionService()
    
    private var process: Process?
    private var ipcClient: IPCClient?
    
    // Map request ID to completion handler
    private var pendingRequests: [String: (Proto_Ext_ManagerResponse) -> Void] = [:]
    
    private init() {}
    
    func start() {
        guard process == nil else { return }
        
        let nodePath = findNodePath()
        let managerPath = findExtensionManagerPath()
        
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: nodePath)
        process.arguments = [managerPath]
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        process.environment = [
            "NODE_ENV": "production",
            "VICINAE_VERSION": "1.0.0", // TODO: Get from bundle
            "VICINAE_COMMIT": "unknown",
            "PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" // Ensure node can find tools if needed
        ]
        
        do {
            try process.run()
            self.process = process
            
            // Note: IPCClient writes to process.stdin (inputPipe) and reads from process.stdout (outputPipe)
            // But Pipe names are relative to the process. 
            // process.standardInput is where we write TO the process. So we write to inputPipe.fileHandleForWriting.
            // process.standardOutput is where we read FROM the process. So we read from outputPipe.fileHandleForReading.
            
            self.ipcClient = IPCClient(
                inputHandle: outputPipe.fileHandleForReading,
                outputHandle: inputPipe.fileHandleForWriting
            )
            self.ipcClient?.delegate = self
            
            print("Extension Manager started.")
            
            // Handle stderr
            errorPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                    print("[Extension Manager Error]: \(str)")
                }
            }
            
        } catch {
            print("Failed to start Extension Manager: \(error)")
        }
    }
    
    func stop() {
        process?.terminate()
        process = nil
        ipcClient = nil
    }
    
    // MARK: - API
    
    func loadExtension(extensionId: String, vicinaePath: String, entrypoint: String, completion: @escaping (Result<String, Error>) -> Void) {
        var reqData = Proto_Ext_Manager_RequestData()
        var loadCmd = Proto_Ext_Manager_ManagerLoadCommand()
        loadCmd.extensionID = extensionId
        loadCmd.vicinaePath = vicinaePath
        loadCmd.entrypoint = entrypoint
        loadCmd.env = .development // Default for now
        loadCmd.mode = .view
        
        reqData.load = loadCmd
        
        sendManagerRequest(reqData) { response in
            switch response.result {
            case .value(let value):
                switch value.data {
                case .load(let loadResp):
                    completion(.success(loadResp.sessionID))
                default:
                    completion(.failure(NSError(domain: "Vicinae", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])))
                }
            case .error(let err):
                completion(.failure(NSError(domain: "Vicinae", code: 2, userInfo: [NSLocalizedDescriptionKey: err.errorText])))
            case nil:
                completion(.failure(NSError(domain: "Vicinae", code: 3, userInfo: [NSLocalizedDescriptionKey: "Empty response"])))
            }
        }
    }
    
    private func sendManagerRequest(_ data: Proto_Ext_Manager_RequestData, completion: @escaping (Proto_Ext_ManagerResponse) -> Void) {
        let requestId = UUID().uuidString
        pendingRequests[requestId] = completion
        
        var msg = Proto_Ext_IpcMessage()
        var req = Proto_Ext_ManagerRequest()
        req.requestID = requestId
        req.payload = data
        msg.payload = .managerRequest(req)
        
        ipcClient?.send(msg)
    }
    
    private func findNodePath() -> String {
        if let path = Bundle.main.path(forResource: "node", ofType: nil) {
            return path
        }
        // Try to find system node
        if FileManager.default.fileExists(atPath: "/usr/local/bin/node") {
            return "/usr/local/bin/node"
        }
        if FileManager.default.fileExists(atPath: "/opt/homebrew/bin/node") {
            return "/opt/homebrew/bin/node"
        }
        return "node" // Rely on PATH
    }
    
    private func findExtensionManagerPath() -> String {
        if let path = Bundle.main.path(forResource: "extension-manager", ofType: "js") {
            return path
        }
        // Dev fallback
        return "/Users/jimmy54/Documents/github/vicinae/typescript/extension-manager/dist/runtime.js"
    }
    
    // MARK: - IPCClientDelegate
    
    func ipcClient(_ client: IPCClient, didReceiveMessage message: Proto_Ext_IpcMessage) {
        switch message.payload {
        case .managerResponse(let response):
            if let handler = pendingRequests.removeValue(forKey: response.requestID) {
                handler(response)
            }
        case .extensionRequest(let request):
            handleExtensionRequest(request)
        case .extensionEvent(let event):
            handleExtensionEvent(event)
        default:
            break
        }
    }
    
    func ipcClientDidDisconnect(_ client: IPCClient) {
        print("IPC Client disconnected")
        stop()
    }
    
    private func handleExtensionRequest(_ request: Proto_Ext_QualifiedExtensionRequest) {
        // Route to API handlers
        print("Received extension request: \(request)")
        
        // Example: UI Render
        if case .ui(let uiReq) = request.request.data.payload {
            if case .render(let renderReq) = uiReq.payload {
                // Dispatch to UI
                NotificationCenter.default.post(name: .didReceiveRenderRequest, object: nil, userInfo: ["json": renderReq.json])
            }
        }
    }
    
    private func handleExtensionEvent(_ event: Proto_Ext_QualifiedExtensionEvent) {
        // Handle events (logs, etc)
        print("Received extension event: \(event)")
    }
}

extension Notification.Name {
    static let didReceiveRenderRequest = Notification.Name("didReceiveRenderRequest")
}
