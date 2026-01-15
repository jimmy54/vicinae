import Foundation

struct RaycastResponse<T: Codable>: Codable {
    let data: T
}

struct RaycastExtension: Codable, Identifiable {
    let id: String
    let name: String
    let title: String
    let description: String
    let author: RaycastUser
    let owner: RaycastUser?
    let icons: RaycastIcons
    let commands: [RaycastCommand]
    let download_url: String
}

struct RaycastUser: Codable {
    let name: String
    let handle: String
    let avatar: String?
}

struct RaycastIcons: Codable {
    let light: String?
    let dark: String?
}

struct RaycastCommand: Codable, Identifiable {
    let id: String
    let name: String
    let title: String
    let subtitle: String?
    let description: String?
}
