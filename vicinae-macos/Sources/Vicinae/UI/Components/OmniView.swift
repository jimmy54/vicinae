import SwiftUI

struct OmniView: View {
    let node: RenderNode
    
    var body: some View {
        Group {
            switch node.type {
            case "list":
                ListView(node: node)
            case "detail":
                DetailView(node: node)
            case "grid":
                Text("Grid View Placeholder")
            case "form":
                Text("Form View Placeholder")
            default:
                Text("Unknown component: \(node.type)")
            }
        }
    }
}
