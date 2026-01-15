import Foundation
import ZIPFoundation

class RaycastStoreService {
    static let shared = RaycastStoreService()
    private let baseURL = "https://backend.raycast.com/api/v1"
    
    func fetchExtensions(page: Int = 1, perPage: Int = 50) async throws -> [RaycastExtension] {
        guard let url = URL(string: "\(baseURL)/store_listings?page=\(page)&per_page=\(perPage)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(RaycastResponse<[RaycastExtension]>.self, from: data)
        return response.data
    }
    
    func search(query: String) async throws -> [RaycastExtension] {
         guard let url = URL(string: "\(baseURL)/store_listings/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(RaycastResponse<[RaycastExtension]>.self, from: data)
        return response.data
    }
    
    func downloadAndInstall(ext: RaycastExtension) async throws {
        guard let url = URL(string: ext.download_url) else {
             throw URLError(.badURL)
        }
        
        let (tempUrl, _) = try await URLSession.shared.download(from: url)
        
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let extensionsDir = appSupport.appendingPathComponent("Vicinae/extensions")
        try FileManager.default.createDirectory(at: extensionsDir, withIntermediateDirectories: true, attributes: nil)
        
        let destination = extensionsDir.appendingPathComponent(ext.name)
        
        // Remove existing
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
        try FileManager.default.unzipItem(at: tempUrl, to: destination)
        
        print("Installed extension \(ext.name) to \(destination.path)")
    }
}
