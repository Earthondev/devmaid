import Foundation

public final class HistoryStore {
    private let fileManager: FileManager
    public let baseURL: URL
    public let historyFileURL: URL

    public init(baseURL: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let resolvedBaseURL: URL
        if let baseURL {
            resolvedBaseURL = baseURL
        } else if let override = ProcessInfo.processInfo.environment["DEVMAID_HOME"], !override.isEmpty {
            resolvedBaseURL = URL(fileURLWithPath: RoomServicePaths.expandedHomePath(override, fileManager: fileManager), isDirectory: true)
        } else if let override = ProcessInfo.processInfo.environment["ROOMSERVICE_HOME"], !override.isEmpty {
            resolvedBaseURL = URL(fileURLWithPath: RoomServicePaths.expandedHomePath(override, fileManager: fileManager), isDirectory: true)
        } else {
            resolvedBaseURL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".roomservice", isDirectory: true)
        }

        self.baseURL = resolvedBaseURL
        self.historyFileURL = self.baseURL.appendingPathComponent("history.jsonl")
    }

    public func ensureReady() throws {
        try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        if !fileManager.fileExists(atPath: historyFileURL.path) {
            fileManager.createFile(atPath: historyFileURL.path, contents: nil)
        }
    }

    public func record(_ entry: HistoryEntry) throws {
        try ensureReady()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let payload = try encoder.encode(entry)
        guard let handle = try? FileHandle(forWritingTo: historyFileURL) else {
            throw CocoaError(.fileWriteUnknown)
        }
        defer { try? handle.close() }

        try handle.seekToEnd()
        handle.write(payload)
        handle.write(Data("\n".utf8))
    }

    public func load() throws -> [HistoryEntry] {
        try ensureReady()
        let data = try Data(contentsOf: historyFileURL)
        guard !data.isEmpty else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return String(decoding: data, as: UTF8.self)
            .split(separator: "\n")
            .compactMap { line in
                try? decoder.decode(HistoryEntry.self, from: Data(line.utf8))
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
}
