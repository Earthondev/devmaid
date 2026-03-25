import Foundation

public final class ScanHistoryStore {
    private let fileManager: FileManager
    public let baseURL: URL
    public let historyFileURL: URL
    private let maxRecords: Int

    public init(baseURL: URL? = nil, maxRecords: Int = 60, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.maxRecords = maxRecords

        let resolvedBaseURL: URL
        if let baseURL {
            resolvedBaseURL = baseURL
        } else if let override = ProcessInfo.processInfo.environment["DEVMAID_HOME"], !override.isEmpty {
            resolvedBaseURL = URL(fileURLWithPath: DevMaidPaths.expandedHomePath(override, fileManager: fileManager), isDirectory: true)
        } else if let override = ProcessInfo.processInfo.environment["ROOMSERVICE_HOME"], !override.isEmpty {
            resolvedBaseURL = URL(fileURLWithPath: DevMaidPaths.expandedHomePath(override, fileManager: fileManager), isDirectory: true)
        } else {
            resolvedBaseURL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".roomservice", isDirectory: true)
        }

        self.baseURL = resolvedBaseURL
        self.historyFileURL = self.baseURL.appendingPathComponent("scan-history.json")
    }

    public func ensureReady() throws {
        try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        if !fileManager.fileExists(atPath: historyFileURL.path) {
            try Data("[]".utf8).write(to: historyFileURL)
        }
    }

    public func load() throws -> [ScanRecord] {
        try ensureReady()
        let data = try Data(contentsOf: historyFileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([ScanRecord].self, from: data)
            .sorted { $0.recordedAt > $1.recordedAt }
    }

    public func record(_ entry: ScanRecord) throws {
        var entries = try load()
        entries.insert(entry, at: 0)
        if entries.count > maxRecords {
            entries = Array(entries.prefix(maxRecords))
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(entries)
        try data.write(to: historyFileURL)
    }
}
