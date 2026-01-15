import Cocoa
import SwiftProtobuf

class SystemAPIService {
    static let shared = SystemAPIService()
    
    private init() {}
    
    func handleRequest(_ request: Proto_Ext_Extension_Request, completion: @escaping (Proto_Ext_Extension_Response) -> Void) {
        var response = Proto_Ext_Extension_Response()
        response.requestID = request.requestID
        
        switch request.data.payload {
        case .clipboard(let req):
            if case .readContent = req.payload {
                let text = NSPasteboard.general.string(forType: .string) ?? ""
                var respData = Proto_Ext_Clipboard_Response()
                var readTextResp = Proto_Ext_Clipboard_ReadContentResponse()
                var content = Proto_Ext_Clipboard_ClipboardReadContent()
                content.text = text
                readTextResp.content = content
                respData.payload = .readContent(readTextResp)
                
                var extRespData = Proto_Ext_Extension_ResponseData()
                extRespData.payload = .clipboard(respData)
                response.result = .data(extRespData)
                completion(response)
            } else if case .copy(let copyReq) = req.payload {
                 NSPasteboard.general.clearContents()
                 // Assuming content.text for simplicity, handling oneof content
                 if case .text(let text) = copyReq.content.content {
                     NSPasteboard.general.setString(text, forType: .string)
                 }
                 var respData = Proto_Ext_Clipboard_Response()
                 respData.payload = .copy(Proto_Ext_Clipboard_CopyToClipboardResponse())
                 
                 var extRespData = Proto_Ext_Extension_ResponseData()
                 extRespData.payload = .clipboard(respData)
                 response.result = .data(extRespData)
                 completion(response)
            }
            
        case .app(let req):
            if case .open(let openReq) = req.payload {
                if let url = URL(string: openReq.target) {
                    NSWorkspace.shared.open(url)
                }
                var respData = Proto_Ext_Application_Response()
                respData.payload = .open(Proto_Ext_Common_AckResponse())
                
                var extRespData = Proto_Ext_Extension_ResponseData()
                extRespData.payload = .app(respData)
                response.result = .data(extRespData)
                completion(response)
            }
            
        case .ui(let req):
             if case .showToast(let toastReq) = req.payload {
                 // Show toast (Log for now)
                 print("TOAST: \(toastReq.title)")
                 
                 var respData = Proto_Ext_Ui_Response()
                 respData.payload = .showToast(Proto_Ext_Common_AckResponse())
                 
                 var extRespData = Proto_Ext_Extension_ResponseData()
                 extRespData.payload = .ui(respData)
                 response.result = .data(extRespData)
                 completion(response)
             }
             
        default:
             // Unhandled
             break
        }
    }
}
