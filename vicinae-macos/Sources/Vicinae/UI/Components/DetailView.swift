import SwiftUI

struct DetailView: View {
    let node: RenderNode
    
    var body: some View {
        ScrollView {
            if let markdown = node.props["markdown"]?.value as? String {
                Text(LocalizedStringKey(markdown))
                    .padding()
            }
        }
    }
}
