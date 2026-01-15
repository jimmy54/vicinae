import SwiftUI

struct ListView: View {
    let node: RenderNode
    
    var body: some View {
        List {
            if let children = node.children {
                ForEach(children) { child in
                    if child.type == "list-item" {
                        ListItemView(node: child)
                    }
                }
            }
        }
    }
}

struct ListItemView: View {
    let node: RenderNode
    
    var body: some View {
        HStack {
            // Icon placeholder
            if let icon = node.props["icon"]?.value as? String {
                Image(systemName: "circle") // TODO: Resolve icon
            }
            
            VStack(alignment: .leading) {
                if let title = node.props["title"]?.value as? String {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle = node.props["subtitle"]?.value as? String {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Accessories placeholder
             if let accessories = node.props["accessories"]?.value as? [[String: Any]] {
                 // Complex handling needed
                 Text("...")
             }
        }
    }
}
