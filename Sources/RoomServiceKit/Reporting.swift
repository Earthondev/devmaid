import Foundation

public struct DiskUsageSnapshot: Codable, Hashable, Sendable {
    public let totalBytes: Int64
    public let freeBytes: Int64
    public let usedBytes: Int64

    public init(totalBytes: Int64, freeBytes: Int64, usedBytes: Int64) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
    }
}

public struct ScanRecord: Codable, Identifiable, Sendable {
    public let id: String
    public let recordedAt: Date
    public let totalBytes: Int64
    public let itemCount: Int
    public let categories: [String]
    public let searchRoots: [String]
    public let disk: DiskUsageSnapshot

    public init(
        id: String = UUID().uuidString,
        recordedAt: Date,
        totalBytes: Int64,
        itemCount: Int,
        categories: [String],
        searchRoots: [String],
        disk: DiskUsageSnapshot
    ) {
        self.id = id
        self.recordedAt = recordedAt
        self.totalBytes = totalBytes
        self.itemCount = itemCount
        self.categories = categories
        self.searchRoots = searchRoots
        self.disk = disk
    }
}

public struct ScanExportDocument: Codable, Sendable {
    public let productName: String
    public let generatedAt: Date
    public let version: String
    public let searchRoots: [String]
    public let categories: [String]
    public let excludedPaths: [String]
    public let summary: ScanSummary

    public init(
        productName: String,
        generatedAt: Date,
        version: String,
        searchRoots: [String],
        categories: [String],
        excludedPaths: [String],
        summary: ScanSummary
    ) {
        self.productName = productName
        self.generatedAt = generatedAt
        self.version = version
        self.searchRoots = searchRoots
        self.categories = categories
        self.excludedPaths = excludedPaths
        self.summary = summary
    }
}

public struct HistoryExportEntry: Codable, Sendable {
    public let entry: HistoryEntry
    public let manifest: DeleteManifest?

    public init(entry: HistoryEntry, manifest: DeleteManifest?) {
        self.entry = entry
        self.manifest = manifest
    }
}

public struct HistoryExportDocument: Codable, Sendable {
    public let productName: String
    public let generatedAt: Date
    public let version: String
    public let entries: [HistoryExportEntry]

    public init(productName: String, generatedAt: Date, version: String, entries: [HistoryExportEntry]) {
        self.productName = productName
        self.generatedAt = generatedAt
        self.version = version
        self.entries = entries
    }
}
