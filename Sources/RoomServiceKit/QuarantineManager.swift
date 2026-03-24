import Foundation

public final class QuarantineManager {
    private let fileManager: FileManager
    private let historyStore: HistoryStore
    private let isoFormatter = ISO8601DateFormatter()

    public init(historyStore: HistoryStore = HistoryStore(), fileManager: FileManager = .default) {
        self.historyStore = historyStore
        self.fileManager = fileManager
    }

    public var quarantineRootURL: URL {
        historyStore.baseURL.appendingPathComponent("quarantine", isDirectory: true)
    }

    public func quarantine(_ items: [ScanItem]) throws -> DeleteManifest {
        try historyStore.ensureReady()
        try fileManager.createDirectory(at: quarantineRootURL, withIntermediateDirectories: true)

        let actionID = makeActionID()
        let actionRootURL = quarantineRootURL.appendingPathComponent(actionID, isDirectory: true)
        let payloadRootURL = actionRootURL.appendingPathComponent("payload", isDirectory: true)

        try fileManager.createDirectory(at: payloadRootURL, withIntermediateDirectories: true)

        var storedItems: [QuarantinedItem] = []

        for (index, item) in items.enumerated() {
            let sourceURL = URL(fileURLWithPath: item.path)
            let destinationURL = payloadRootURL.appendingPathComponent("\(index + 1)-\(sourceURL.lastPathComponent)", isDirectory: true)

            try fileManager.moveItem(at: sourceURL, to: destinationURL)
            storedItems.append(
                QuarantinedItem(
                    originalPath: item.path,
                    quarantinePath: destinationURL.path,
                    category: item.category,
                    bytes: item.bytes,
                    risk: item.risk,
                    note: item.note,
                    groupName: item.groupName
                )
            )
        }

        let manifest = DeleteManifest(actionID: actionID, createdAt: Date(), items: storedItems)
        try writeManifest(manifest, to: actionRootURL)
        try historyStore.record(
            HistoryEntry(
                id: actionID,
                kind: .delete,
                createdAt: manifest.createdAt,
                itemCount: storedItems.count,
                totalBytes: manifest.totalBytes,
                summary: summarize(items: items)
            )
        )

        return manifest
    }

    public func restore(actionID: String) throws -> RestoreResult {
        let manifest = try loadManifest(actionID: actionID)
        var restored: [QuarantinedItem] = []
        var skipped: [String] = []

        for item in manifest.items {
            guard fileManager.fileExists(atPath: item.quarantinePath) else {
                skipped.append("Missing quarantined item for \(item.originalPath)")
                continue
            }

            if fileManager.fileExists(atPath: item.originalPath) {
                skipped.append("Destination already exists at \(item.originalPath)")
                continue
            }

            let originalURL = URL(fileURLWithPath: item.originalPath)
            let parentURL = originalURL.deletingLastPathComponent()
            try fileManager.createDirectory(at: parentURL, withIntermediateDirectories: true)
            try fileManager.moveItem(at: URL(fileURLWithPath: item.quarantinePath), to: originalURL)
            restored.append(item)
        }

        if !restored.isEmpty {
            try historyStore.record(
                HistoryEntry(
                    id: makeActionID(),
                    kind: .restore,
                    createdAt: Date(),
                    itemCount: restored.count,
                    totalBytes: restored.reduce(0) { $0 + $1.bytes },
                    summary: "Restored \(restored.count) item(s) from \(actionID)",
                    sourceActionID: actionID
                )
            )
        }

        return RestoreResult(restored: restored, skipped: skipped)
    }

    public func loadManifest(actionID: String) throws -> DeleteManifest {
        let manifestURL = quarantineRootURL
            .appendingPathComponent(actionID, isDirectory: true)
            .appendingPathComponent("manifest.json")
        let data = try Data(contentsOf: manifestURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DeleteManifest.self, from: data)
    }

    private func writeManifest(_ manifest: DeleteManifest, to actionRootURL: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(manifest)
        try data.write(to: actionRootURL.appendingPathComponent("manifest.json"))
    }

    private func makeActionID() -> String {
        let stamp = isoFormatter.string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        return "\(stamp)-\(UUID().uuidString.prefix(8))"
    }

    private func summarize(items: [ScanItem]) -> String {
        let categories = Set(items.map(\.category.displayName)).sorted()
        if categories.isEmpty {
            return "No items quarantined"
        }
        return "Quarantined \(items.count) item(s) from \(categories.joined(separator: ", "))"
    }
}
