import Foundation

public enum RiskLevel: Int, Codable, CaseIterable, Comparable, Sendable {
    case safe = 0
    case review = 1
    case danger = 2

    public static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var label: String {
        switch self {
        case .safe:
            return "safe"
        case .review:
            return "review"
        case .danger:
            return "danger"
        }
    }

    public var displayName: String {
        switch self {
        case .safe:
            return "Safe"
        case .review:
            return "Review"
        case .danger:
            return "Danger"
        }
    }

    public var detail: String {
        switch self {
        case .safe:
            return "Rebuildable or disposable data with low cleanup risk."
        case .review:
            return "Usually safe to remove, but double-check if you rely on local state."
        case .danger:
            return "Can remove heavyweight local environments or data you may want to keep."
        }
    }

    public var symbolName: String {
        switch self {
        case .safe:
            return "checkmark.circle.fill"
        case .review:
            return "exclamationmark.triangle.fill"
        case .danger:
            return "flame.fill"
        }
    }
}

public struct ScanItem: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let category: CleanupCategory
    public let path: String
    public let bytes: Int64
    public let risk: RiskLevel
    public let note: String
    public let groupName: String?

    public init(
        id: UUID = UUID(),
        category: CleanupCategory,
        path: String,
        bytes: Int64,
        risk: RiskLevel,
        note: String,
        groupName: String? = nil
    ) {
        self.id = id
        self.category = category
        self.path = path
        self.bytes = bytes
        self.risk = risk
        self.note = note
        self.groupName = groupName
    }
}

public struct ScanSummary: Codable, Sendable {
    public let startedAt: Date
    public let finishedAt: Date
    public let items: [ScanItem]
    public let warnings: [String]

    public init(startedAt: Date, finishedAt: Date, items: [ScanItem], warnings: [String]) {
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.items = items
        self.warnings = warnings
    }

    public var totalBytes: Int64 {
        items.reduce(0) { $0 + $1.bytes }
    }

    public var itemCount: Int {
        items.count
    }
}

public struct ScanConfiguration: Sendable {
    public let categories: [CleanupCategory]
    public let searchRoots: [String]
    public let maxItems: Int?
    public let excludedPaths: [String]

    public init(
        categories: [CleanupCategory] = CleanupCategory.allCases,
        searchRoots: [String],
        maxItems: Int? = nil,
        excludedPaths: [String] = []
    ) {
        self.categories = categories.isEmpty ? CleanupCategory.allCases : categories
        self.searchRoots = searchRoots
        self.maxItems = maxItems
        self.excludedPaths = excludedPaths
    }
}

public struct QuarantinedItem: Codable, Hashable, Identifiable, Sendable {
    public let originalPath: String
    public let quarantinePath: String
    public let category: CleanupCategory
    public let bytes: Int64
    public let risk: RiskLevel
    public let note: String
    public let groupName: String?

    public init(
        originalPath: String,
        quarantinePath: String,
        category: CleanupCategory,
        bytes: Int64,
        risk: RiskLevel,
        note: String,
        groupName: String? = nil
    ) {
        self.originalPath = originalPath
        self.quarantinePath = quarantinePath
        self.category = category
        self.bytes = bytes
        self.risk = risk
        self.note = note
        self.groupName = groupName
    }

    public var id: String {
        quarantinePath
    }
}

public struct DeleteManifest: Codable, Sendable {
    public let actionID: String
    public let createdAt: Date
    public let items: [QuarantinedItem]

    public init(actionID: String, createdAt: Date, items: [QuarantinedItem]) {
        self.actionID = actionID
        self.createdAt = createdAt
        self.items = items
    }

    public var totalBytes: Int64 {
        items.reduce(0) { $0 + $1.bytes }
    }
}

public enum HistoryActionKind: String, Codable, Sendable {
    case delete
    case restore
}

public struct HistoryEntry: Codable, Identifiable, Sendable {
    public let id: String
    public let kind: HistoryActionKind
    public let createdAt: Date
    public let itemCount: Int
    public let totalBytes: Int64
    public let summary: String
    public let sourceActionID: String?

    public init(
        id: String,
        kind: HistoryActionKind,
        createdAt: Date,
        itemCount: Int,
        totalBytes: Int64,
        summary: String,
        sourceActionID: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.createdAt = createdAt
        self.itemCount = itemCount
        self.totalBytes = totalBytes
        self.summary = summary
        self.sourceActionID = sourceActionID
    }

    public var displayName: String {
        switch kind {
        case .delete:
            return "Cleanup"
        case .restore:
            return "Restore"
        }
    }
}

public struct RestoreResult: Sendable {
    public let restored: [QuarantinedItem]
    public let skipped: [String]

    public init(restored: [QuarantinedItem], skipped: [String]) {
        self.restored = restored
        self.skipped = skipped
    }
}
