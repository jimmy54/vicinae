import SwiftUI

@main
struct VicinaeApp: App {
    @StateObject var renderStore = RenderStore()
    
    init() {
        // Start the Extension Service
        ExtensionService.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(renderStore)
                .onAppear {
                    // Example: Try to fetch extensions from store on launch
                    Task {
                        do {
                            let extensions = try await RaycastStoreService.shared.fetchExtensions()
                            print("Fetched \(extensions.count) extensions from Raycast Store")
                        } catch {
                            print("Failed to fetch extensions: \(error)")
                        }
                    }
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

struct ContentView: View {
    @EnvironmentObject var renderStore: RenderStore
    
    var body: some View {
        VStack {
            if let root = renderStore.rootNode {
                OmniView(node: root)
            } else {
                Text("Vicinae Native")
                    .font(.largeTitle)
                    .padding()
                Text("Waiting for extension content...")
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
