import Foundation
import FinomaCore

public struct FinomaStore {
    public let root: URL

    public init(root: URL) {
        self.root = root
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    public static func defaultRoot() -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".finoma", isDirectory: true)
    }

    public func url(for fileName: String) -> URL { root.appendingPathComponent(fileName) }
}

final class JSONFileStore<T: Codable & Identifiable> where T.ID == UUID {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "finoma.json.store.\(T.self)")
    private var cache: [T] = []
    private var loaded = false
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileURL: URL) {
        self.fileURL = fileURL
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func load() throws -> [T] {
        try queue.sync {
            if loaded { return cache }
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)
                cache = try decoder.decode([T].self, from: data)
            } else {
                cache = []
            }
            loaded = true
            return cache
        }
    }

    func saveAll(_ items: [T]) throws {
        try queue.sync {
            cache = items
            loaded = true
            let data = try encoder.encode(cache)
            try data.write(to: fileURL, options: .atomic)
        }
    }

    func mutate(_ transform: (inout [T]) -> Void) throws {
        try queue.sync {
            if !loaded { _ = try? load() }
            transform(&cache)
            let data = try encoder.encode(cache)
            try data.write(to: fileURL, options: .atomic)
        }
    }
}

