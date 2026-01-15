import Foundation
import Combine

class RenderStore: ObservableObject {
    @Published var rootNode: RenderNode?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRenderRequest(_:)), name: .didReceiveRenderRequest, object: nil)
    }
    
    @objc private func handleRenderRequest(_ notification: Notification) {
        guard let json = notification.userInfo?["json"] as? String,
              let data = json.data(using: .utf8) else { return }
        
        do {
            let payload = try JSONDecoder().decode(RenderPayload.self, from: data)
            // Currently assuming single view
            if let firstView = payload.views.first {
                DispatchQueue.main.async {
                    self.rootNode = firstView.root
                }
            }
        } catch {
            print("Failed to decode render payload: \(error)")
        }
    }
}
