import Foundation
import SwiftProtobuf

protocol IPCClientDelegate: AnyObject {
    func ipcClient(_ client: IPCClient, didReceiveMessage message: Proto_Ext_IpcMessage)
    func ipcClientDidDisconnect(_ client: IPCClient)
}

class IPCClient {
    weak var delegate: IPCClientDelegate?
    
    private let inputHandle: FileHandle
    private let outputHandle: FileHandle
    private var buffer = Data()
    private let queue = DispatchQueue(label: "com.vicinae.ipc")
    
    init(inputHandle: FileHandle, outputHandle: FileHandle) {
        self.inputHandle = inputHandle
        self.outputHandle = outputHandle
        
        self.inputHandle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if data.isEmpty {
                // EOF
                self?.disconnect()
                return
            }
            self?.queue.async {
                self?.handleData(data)
            }
        }
    }
    
    func send(_ message: Proto_Ext_IpcMessage) {
        queue.async { [weak self] in
            guard let self = self else { return }
            do {
                let binaryData = try message.serializedData()
                var length = UInt32(binaryData.count).bigEndian
                let lengthData = Data(bytes: &length, count: 4)
                
                try self.outputHandle.write(contentsOf: lengthData)
                try self.outputHandle.write(contentsOf: binaryData)
            } catch {
                print("Failed to send IPC message: \(error)")
            }
        }
    }
    
    private func handleData(_ data: Data) {
        buffer.append(data)
        
        while buffer.count >= 4 {
            let lengthData = buffer.prefix(4)
            let length = UInt32(bigEndian: lengthData.withUnsafeBytes { $0.load(as: UInt32.self) })
            
            if buffer.count >= 4 + Int(length) {
                let messageData = buffer.subdata(in: 4..<(4 + Int(length)))
                buffer.removeFirst(4 + Int(length))
                
                do {
                    let message = try Proto_Ext_IpcMessage(serializedBytes: messageData)
                    DispatchQueue.main.async {
                        self.delegate?.ipcClient(self, didReceiveMessage: message)
                    }
                } catch {
                    print("Failed to decode IPC message: \(error)")
                }
            } else {
                // Not enough data yet
                break
            }
        }
    }
    
    private func disconnect() {
        self.inputHandle.readabilityHandler = nil
        DispatchQueue.main.async {
            self.delegate?.ipcClientDidDisconnect(self)
        }
    }
}
