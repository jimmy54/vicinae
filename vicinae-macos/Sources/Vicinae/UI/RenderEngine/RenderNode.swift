import Foundation

struct RenderNode: Codable, Identifiable {
    var id: String = UUID().uuidString
    let type: String
    let props: [String: AnyCodable]
    let children: [RenderNode]?
    
    enum CodingKeys: String, CodingKey {
        case type, props, children
    }
}

struct ViewData: Codable {
    let root: RenderNode?
}

struct RenderPayload: Codable {
    let views: [ViewData]
}
