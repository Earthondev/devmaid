import AppKit
import Foundation
import RoomServiceKit
import SwiftUI
import UserNotifications

enum RoomServiceDestination: String, CaseIterable, Hashable, Identifiable {
    case overview
    case results
    case history
    case settings
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview:
            return "Overview"
        case .results:
            return "Results"
        case .history:
            return "History"
        case .settings:
            return "Settings"
        case .about:
            return "About"
        }
    }

    var symbolName: String {
        switch self {
        case .overview:
            return "square.grid.2x2.fill"
        case .results:
            return "list.bullet.rectangle.portrait.fill"
        case .history:
            return "clock.arrow.circlepath"
        case .settings:
            return "gearshape.fill"
        case .about:
            return "info.circle.fill"
        }
    }
}

enum ScanSortOption: String, CaseIterable, Identifiable {
    case sizeDescending
    case sizeAscending
    case pathAscending
    case riskDescending

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sizeDescending:
            return "Largest first"
        case .sizeAscending:
            return "Smallest first"
        case .pathAscending:
            return "Path A-Z"
        case .riskDescending:
            return "Risk first"
        }
    }

    func apply(to items: [ScanItem]) -> [ScanItem] {
        items.sorted { lhs, rhs in
            switch self {
            case .sizeDescending:
                if lhs.bytes == rhs.bytes {
                    return lhs.path.localizedStandardCompare(rhs.path) == .orderedAscending
                }
                return lhs.bytes > rhs.bytes
            case .sizeAscending:
                if lhs.bytes == rhs.bytes {
                    return lhs.path.localizedStandardCompare(rhs.path) == .orderedAscending
                }
                return lhs.bytes < rhs.bytes
            case .pathAscending:
                return lhs.path.localizedStandardCompare(rhs.path) == .orderedAscending
            case .riskDescending:
                if lhs.risk == rhs.risk {
                    return lhs.bytes > rhs.bytes
                }
                return lhs.risk > rhs.risk
            }
        }
    }
}

enum StartupItemsFilter: String, CaseIterable, Identifiable {
    case all
    case manageableOnly

    var id: String { rawValue }
}

struct CategoryCardState: Identifiable {
    let category: CleanupCategory
    let bytes: Int64
    let itemCount: Int
    let isEnabled: Bool

    var id: CleanupCategory { category }
}

struct TrendSummaryPoint: Identifiable {
    let id: String
    let date: Date
    let reclaimableBytes: Int64
    let freeBytes: Int64
    let usedBytes: Int64
}

enum RoomServiceLinks {
    static let website = URL(string: "https://github.com/your-org/devmaid")!
    static let support = URL(string: "https://github.com/your-org/devmaid/issues")!
    static let sponsor = URL(string: "https://github.com/sponsors/your-org")!
    static let privacy = URL(string: "https://github.com/your-org/devmaid/blob/main/PRIVACY.md")!
    static let repository = URL(string: "https://github.com/your-org/devmaid")!
    static let securityEmail = URL(string: "mailto:security@your-domain.example")!
}

enum AppPreferences {
    static let searchRootsKey = "roomservice.searchRoots"
    static let requireConfirmationKey = "roomservice.requireConfirmation"
    static let requireDangerConfirmationKey = "roomservice.requireDangerConfirmation"
    static let includedCategoriesKey = "roomservice.includedCategories"
    static let languageKey = "roomservice.language"
    static let autoCheckUpdatesKey = "roomservice.autoCheckUpdates"
    static let lastUpdateCheckKey = "roomservice.lastUpdateCheck"
    static let notificationsEnabledKey = "devmaid.notificationsEnabled"
    static let freeSpaceAlertThresholdGBKey = "devmaid.freeSpaceAlertThresholdGB"
    static let reclaimableSpikeThresholdGBKey = "devmaid.reclaimableSpikeThresholdGB"
    static let lastLowSpaceAlertKey = "devmaid.lastLowSpaceAlert"
    static let lastSpikeAlertKey = "devmaid.lastSpikeAlert"
    static let startupItemsFilterKey = "devmaid.startupItemsFilter"
    static let excludedPathsKey = "devmaid.excludedPaths"
    static let completedOnboardingKey = "devmaid.completedOnboarding"

    static var isVolatileEnvironment: Bool {
        let env = ProcessInfo.processInfo.environment
        return env["DEVMAID_VOLATILE_PREFERENCES"] == "1" || env["ROOMSERVICE_VOLATILE_PREFERENCES"] == "1"
    }

    static func loadSearchRoots() -> [String] {
        let env = ProcessInfo.processInfo.environment
        if let override = env["DEVMAID_SEARCH_ROOTS"]?
            .split(separator: ":")
            .map({ String($0) })
            .filter({ !$0.isEmpty }),
           !override.isEmpty {
            return override
        }
        if let override = env["ROOMSERVICE_SEARCH_ROOTS"]?
            .split(separator: ":")
            .map({ String($0) })
            .filter({ !$0.isEmpty }),
           !override.isEmpty {
            return override
        }
        if let roots = UserDefaults.standard.stringArray(forKey: searchRootsKey), !roots.isEmpty {
            return roots
        }
        return RoomServicePaths.defaultSearchRoots()
    }

    static func saveSearchRoots(_ roots: [String]) {
        guard !isVolatileEnvironment else { return }
        UserDefaults.standard.set(roots, forKey: searchRootsKey)
    }

    static func loadBool(key: String, default defaultValue: Bool) -> Bool {
        if UserDefaults.standard.object(forKey: key) == nil {
            return defaultValue
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    static func saveBool(_ value: Bool, key: String) {
        guard !isVolatileEnvironment else { return }
        UserDefaults.standard.set(value, forKey: key)
    }

    static func loadIncludedCategories() -> Set<CleanupCategory> {
        guard let rawValues = UserDefaults.standard.array(forKey: includedCategoriesKey) as? [String] else {
            return Set(CleanupCategory.allCases)
        }
        let categories = rawValues.compactMap(CleanupCategory.parse)
        return categories.isEmpty ? Set(CleanupCategory.allCases) : Set(categories)
    }

    static func saveIncludedCategories(_ categories: Set<CleanupCategory>) {
        guard !isVolatileEnvironment else { return }
        UserDefaults.standard.set(categories.map(\.rawValue).sorted(), forKey: includedCategoriesKey)
    }

    static func loadLanguage() -> AppLanguage {
        let env = ProcessInfo.processInfo.environment
        if let override = env["DEVMAID_LANGUAGE"],
           let language = AppLanguage(rawValue: override) {
            return language
        }
        if let override = env["ROOMSERVICE_LANGUAGE"],
           let language = AppLanguage(rawValue: override) {
            return language
        }
        guard let rawValue = UserDefaults.standard.string(forKey: languageKey),
              let language = AppLanguage(rawValue: rawValue) else {
            return .english
        }
        return language
    }

    static func saveLanguage(_ language: AppLanguage) {
        guard !isVolatileEnvironment else { return }
        UserDefaults.standard.set(language.rawValue, forKey: languageKey)
    }

    static func loadDate(key: String) -> Date? {
        UserDefaults.standard.object(forKey: key) as? Date
    }

    static func saveDate(_ value: Date?, key: String) {
        guard !isVolatileEnvironment else { return }
        UserDefaults.standard.set(value, forKey: key)
    }

    static func loadInt(key: String, default defaultValue: Int) -> Int {
        if UserDefaults.standard.object(forKey: key) == nil {
            return defaultValue
        }
        return UserDefaults.standard.integer(forKey: key)
    }

    static func saveInt(_ value: Int, key: String) {
        guard !isVolatileEnvironment else { return }
        UserDefaults.standard.set(value, forKey: key)
    }

    static func loadString(key: String, default defaultValue: String) -> String {
        UserDefaults.standard.string(forKey: key) ?? defaultValue
    }

    static func saveString(_ value: String, key: String) {
        guard !isVolatileEnvironment else { return }
        UserDefaults.standard.set(value, forKey: key)
    }

    static func loadStringArray(key: String) -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    static func saveStringArray(_ value: [String], key: String) {
        guard !isVolatileEnvironment else { return }
        UserDefaults.standard.set(value, forKey: key)
    }
}

@MainActor
final class RoomServiceAppModel: ObservableObject {
    @Published var destination: RoomServiceDestination = .overview
    @Published var language: AppLanguage
    @Published var scanSummary: ScanSummary?
    @Published var isScanning = false
    @Published var currentOperation: RoomServiceOperation?
    @Published var scanWarnings: [String] = []
    @Published var searchRoots: [String]
    @Published var excludedPaths: [String]
    @Published var includedCategories: Set<CleanupCategory>
    @Published var categoryFilter: CleanupCategory?
    @Published var riskFilter: RiskLevel?
    @Published var searchText = ""
    @Published var sortOption: ScanSortOption = .sizeDescending
    @Published var selectedScanItemIDs = Set<UUID>()
    @Published var historyEntries: [HistoryEntry] = []
    @Published var selectedHistoryID: String?
    @Published var selectedHistoryManifest: DeleteManifest?
    @Published var lastRestoreSkipped: [String] = []
    @Published var lastActionMessage: String?
    @Published var lastError: String?
    @Published var showCleanupConfirmation = false
    @Published var showDangerConfirmation = false
    @Published var requireConfirmation: Bool
    @Published var requireDangerConfirmation: Bool
    @Published var selectedSearchRoot: String?
    @Published var automaticallyCheckForUpdates: Bool
    @Published var isCheckingForUpdates = false
    @Published var availableUpdate: AppUpdateRelease?
    @Published var lastUpdateCheckDate: Date?
    @Published var lastUpdateError: String?
    @Published var unsupportedSystemUpdate: AppUpdateRelease?
    @Published var notificationsEnabled: Bool
    @Published var freeSpaceAlertThresholdGB: Int
    @Published var reclaimableSpikeThresholdGB: Int
    @Published var recentScans: [ScanRecord] = []
    @Published var startupItems: [StartupItem] = []
    @Published var startupItemsFilter: StartupItemsFilter
    @Published var isLoadingStartupItems = false
    @Published var selectedExcludedPath: String?
    @Published var showOnboarding: Bool

    private var scanTask: Task<Void, Never>?
    private let updateService = AppUpdateService()
    private let scanHistoryStore = ScanHistoryStore()
    private var hasPerformedLaunchTasks = false

    private var testScanDelayNanoseconds: UInt64 {
        let env = ProcessInfo.processInfo.environment
        guard let rawValue = env["DEVMAID_TEST_SCAN_DELAY_MS"] ?? env["ROOMSERVICE_TEST_SCAN_DELAY_MS"],
              let milliseconds = UInt64(rawValue) else {
            return 0
        }
        return milliseconds * 1_000_000
    }

    init() {
        self.language = AppPreferences.loadLanguage()
        self.searchRoots = AppPreferences.loadSearchRoots()
        self.excludedPaths = AppPreferences.loadStringArray(key: AppPreferences.excludedPathsKey)
        self.includedCategories = AppPreferences.loadIncludedCategories()
        self.requireConfirmation = AppPreferences.loadBool(key: AppPreferences.requireConfirmationKey, default: true)
        self.requireDangerConfirmation = AppPreferences.loadBool(key: AppPreferences.requireDangerConfirmationKey, default: true)
        self.automaticallyCheckForUpdates = AppPreferences.loadBool(key: AppPreferences.autoCheckUpdatesKey, default: true)
        self.lastUpdateCheckDate = AppPreferences.loadDate(key: AppPreferences.lastUpdateCheckKey)
        self.notificationsEnabled = AppPreferences.loadBool(key: AppPreferences.notificationsEnabledKey, default: true)
        self.freeSpaceAlertThresholdGB = AppPreferences.loadInt(key: AppPreferences.freeSpaceAlertThresholdGBKey, default: 25)
        self.reclaimableSpikeThresholdGB = AppPreferences.loadInt(key: AppPreferences.reclaimableSpikeThresholdGBKey, default: 8)
        self.startupItemsFilter = StartupItemsFilter(rawValue: AppPreferences.loadString(key: AppPreferences.startupItemsFilterKey, default: StartupItemsFilter.all.rawValue)) ?? .all
        self.showOnboarding = AppPreferences.isVolatileEnvironment
            ? false
            : AppPreferences.loadBool(key: AppPreferences.completedOnboardingKey, default: false) == false
        refreshHistory()
        loadRecentScans()
    }

    deinit {
        scanTask?.cancel()
    }

    var currentResults: [ScanItem] {
        scanSummary?.items ?? []
    }

    var filteredItems: [ScanItem] {
        var items = currentResults

        if let categoryFilter {
            items = items.filter { $0.category == categoryFilter }
        }

        if let riskFilter {
            items = items.filter { $0.risk == riskFilter }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            items = items.filter {
                $0.path.localizedCaseInsensitiveContains(query) ||
                $0.category.displayName.localizedCaseInsensitiveContains(query) ||
                $0.category.localizedShortDescription(in: language).localizedCaseInsensitiveContains(query) ||
                $0.category.localizedNote(in: language).localizedCaseInsensitiveContains(query) ||
                $0.note.localizedCaseInsensitiveContains(query)
            }
        }

        return sortOption.apply(to: items)
    }

    var selectedScanItems: [ScanItem] {
        let ids = selectedScanItemIDs
        return filteredItems.filter { ids.contains($0.id) }
    }

    var primarySelectedItem: ScanItem? {
        guard selectedScanItemIDs.count == 1 else { return nil }
        return currentResults.first { selectedScanItemIDs.contains($0.id) }
    }

    var reclaimableBytes: Int64 {
        scanSummary?.totalBytes ?? 0
    }

    var reclaimableItemCount: Int {
        scanSummary?.itemCount ?? 0
    }

    var weeklyTrendPoints: [TrendSummaryPoint] {
        recentScans
            .suffix(7)
            .map {
                TrendSummaryPoint(
                    id: $0.id,
                    date: $0.recordedAt,
                    reclaimableBytes: $0.totalBytes,
                    freeBytes: $0.disk.freeBytes,
                    usedBytes: $0.disk.usedBytes
                )
            }
    }

    var latestTrendPoint: TrendSummaryPoint? {
        weeklyTrendPoints.last
    }

    var previousTrendPoint: TrendSummaryPoint? {
        weeklyTrendPoints.dropLast().last
    }

    var reclaimableDeltaBytes: Int64 {
        guard let latestTrendPoint, let previousTrendPoint else { return 0 }
        return latestTrendPoint.reclaimableBytes - previousTrendPoint.reclaimableBytes
    }

    var usedSpaceDeltaBytes: Int64 {
        guard let latestTrendPoint, let previousTrendPoint else { return 0 }
        return latestTrendPoint.usedBytes - previousTrendPoint.usedBytes
    }

    var canScan: Bool {
        !includedCategories.isEmpty && !searchRoots.isEmpty && currentOperation == nil
    }

    var hasExclusions: Bool {
        !excludedPaths.isEmpty
    }

    var canCleanupSelection: Bool {
        !selectedScanItems.isEmpty && currentOperation == nil
    }

    var canRestoreSelectedHistory: Bool {
        selectedHistoryEntry?.kind == .delete && currentOperation == nil
    }

    var canCheckForUpdates: Bool {
        !isCheckingForUpdates
    }

    var canExportScan: Bool {
        scanSummary != nil && currentOperation == nil
    }

    var visibleBytes: Int64 {
        filteredItems.reduce(0) { $0 + $1.bytes }
    }

    var filteredStartupItems: [StartupItem] {
        switch startupItemsFilter {
        case .all:
            return startupItems
        case .manageableOnly:
            return startupItems.filter { $0.kind == .appManaged }
        }
    }

    var copy: RoomServiceCopy {
        RoomServiceCopy(language: language)
    }

    var currentAppVersion: String {
        updateService.currentDisplayVersion
    }

    var updateFeedURL: URL? {
        updateService.feedURL
    }

    var latestKnownVersion: String? {
        availableUpdate?.displayVersion ?? unsupportedSystemUpdate?.displayVersion
    }

    var updateDownloadURL: URL? {
        availableUpdate?.downloadURL ?? unsupportedSystemUpdate?.downloadURL
    }

    var updateReleaseNotesURL: URL? {
        availableUpdate?.releaseNotesURL ?? unsupportedSystemUpdate?.releaseNotesURL
    }

    var updateSummary: String? {
        availableUpdate?.summary ?? unsupportedSystemUpdate?.summary
    }

    var updateState: RoomServiceUpdateState {
        if isCheckingForUpdates {
            return .checking
        }
        if let availableUpdate {
            return .available(availableUpdate)
        }
        if let unsupportedSystemUpdate {
            return .unsupported(unsupportedSystemUpdate)
        }
        if let lastUpdateError, !lastUpdateError.isEmpty {
            return .failed(lastUpdateError)
        }
        if lastUpdateCheckDate != nil {
            return .upToDate
        }
        return .idle
    }

    var categoryCards: [CategoryCardState] {
        CleanupCategory.allCases.map { category in
            let categoryItems = currentResults.filter { $0.category == category }
            return CategoryCardState(
                category: category,
                bytes: categoryItems.reduce(0) { $0 + $1.bytes },
                itemCount: categoryItems.count,
                isEnabled: includedCategories.contains(category)
            )
        }
    }

    var latestCleanupEntry: HistoryEntry? {
        historyEntries.first(where: { $0.kind == .delete })
    }

    var selectedHistoryEntry: HistoryEntry? {
        guard let selectedHistoryID else { return nil }
        return historyEntries.first(where: { $0.id == selectedHistoryID })
    }

    func runScan() {
        scanTask?.cancel()
        currentOperation = .scanning
        isScanning = true
        scanWarnings = []
        lastError = nil
        lastActionMessage = nil

        let categories = Array(includedCategories).sorted { $0.displayName < $1.displayName }
        let roots = searchRoots
        let exclusions = excludedPaths
        let testDelayNanoseconds = self.testScanDelayNanoseconds

        scanTask = Task { [weak self] in
            guard let self else { return }
            let summary = await Task.detached(priority: .userInitiated) {
                if testDelayNanoseconds > 0 {
                    try? await Task.sleep(nanoseconds: testDelayNanoseconds)
                }
                return RoomServiceScanner().scan(
                    ScanConfiguration(
                        categories: categories,
                        searchRoots: roots,
                        excludedPaths: exclusions
                    )
                )
            }.value

            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                self.scanSummary = summary
                self.scanWarnings = summary.warnings
                self.isScanning = false
                self.currentOperation = nil
                self.destination = .results
                self.selectedScanItemIDs = Set(summary.items.prefix(1).map(\.id))
                self.lastActionMessage = self.copy.scanFinishedMessage(
                    items: summary.itemCount,
                    bytes: RoomServiceFormatters.byteString(summary.totalBytes)
                )
            }

            self.recordScan(summary: summary, roots: roots, categories: categories)
            await self.evaluateAlerts(after: summary)
        }
    }

    func cancelScan() {
        scanTask?.cancel()
        scanTask = nil
        isScanning = false
        currentOperation = nil
        lastActionMessage = copy.scanCanceledMessage
    }

    func toggleCategory(_ category: CleanupCategory) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if includedCategories.contains(category) {
                includedCategories.remove(category)
            } else {
                includedCategories.insert(category)
            }
        }
        AppPreferences.saveIncludedCategories(includedCategories)
    }

    func requestCleanup() {
        guard canCleanupSelection else { return }
        if requireDangerConfirmation && selectedScanItems.contains(where: { $0.risk == .danger }) {
            showDangerConfirmation = true
            return
        }

        if requireConfirmation {
            showCleanupConfirmation = true
            return
        }

        performCleanup()
    }

    func performCleanup() {
        let items = selectedScanItems
        guard !items.isEmpty else { return }
        currentOperation = .quarantining
        lastError = nil

        Task {
            do {
                let manifest = try await Task.detached(priority: .userInitiated) {
                    try QuarantineManager().quarantine(items)
                }.value

                withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                    self.currentOperation = nil
                    self.lastActionMessage = self.copy.quarantinedMessage(items: manifest.items.count, actionID: manifest.actionID)
                    self.selectedScanItemIDs.removeAll()
                }
                self.refreshHistory(selecting: manifest.actionID)
                self.runScan()
            } catch {
                self.currentOperation = nil
                self.lastError = error.localizedDescription
            }
        }
    }

    func refreshHistory(selecting selectedID: String? = nil) {
        do {
            historyEntries = try HistoryStore().load()
            if let selectedID {
                selectedHistoryID = selectedID
            } else if selectedHistoryID == nil {
                selectedHistoryID = historyEntries.first?.id
            } else if historyEntries.contains(where: { $0.id == selectedHistoryID }) == false {
                selectedHistoryID = historyEntries.first?.id
            }
            loadSelectedManifest()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func selectHistory(id: String?) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedHistoryID = id
        }
        loadSelectedManifest()
    }

    func restoreSelectedHistory() {
        guard let entry = selectedHistoryEntry, entry.kind == .delete else { return }
        currentOperation = .restoring
        lastError = nil

        Task {
            do {
                let result = try await Task.detached(priority: .userInitiated) {
                    try QuarantineManager().restore(actionID: entry.id)
                }.value

                withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                    self.currentOperation = nil
                    self.lastRestoreSkipped = result.skipped
                    self.lastActionMessage = self.copy.restoredMessage(items: result.restored.count, actionID: entry.id)
                }
                self.refreshHistory(selecting: entry.id)
                self.runScan()
            } catch {
                self.currentOperation = nil
                self.lastError = error.localizedDescription
            }
        }
    }

    func addSearchRoot() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = copy.addRootPrompt
        panel.message = copy.addRootMessage

        guard panel.runModal() == .OK, let url = panel.url else { return }
        let path = url.standardizedFileURL.path
        if searchRoots.contains(path) == false {
            searchRoots.append(path)
            searchRoots.sort()
            AppPreferences.saveSearchRoots(searchRoots)
            lastActionMessage = copy.addedScanRootMessage(path: path)
        }
    }

    func addExcludedPath() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.prompt = copy.addExclusionPrompt
        panel.message = copy.addExclusionMessage

        guard panel.runModal() == .OK, let url = panel.url else { return }
        let path = url.standardizedFileURL.path
        guard excludedPaths.contains(path) == false else { return }
        excludedPaths.append(path)
        excludedPaths.sort()
        AppPreferences.saveStringArray(excludedPaths, key: AppPreferences.excludedPathsKey)
        lastActionMessage = copy.addedExclusionMessage(path: path)
    }

    func removeSelectedExcludedPath() {
        guard let selectedExcludedPath else { return }
        excludedPaths.removeAll { $0 == selectedExcludedPath }
        AppPreferences.saveStringArray(excludedPaths, key: AppPreferences.excludedPathsKey)
        self.selectedExcludedPath = nil
        lastActionMessage = copy.updatedExclusionsMessage
    }

    func clearExcludedPaths() {
        excludedPaths.removeAll()
        selectedExcludedPath = nil
        AppPreferences.saveStringArray(excludedPaths, key: AppPreferences.excludedPathsKey)
        lastActionMessage = copy.clearedExclusionsMessage
    }

    func removeSelectedSearchRoot() {
        guard let selectedSearchRoot else { return }
        searchRoots.removeAll { $0 == selectedSearchRoot }
        if searchRoots.isEmpty {
            searchRoots = RoomServicePaths.defaultSearchRoots()
        }
        AppPreferences.saveSearchRoots(searchRoots)
        self.selectedSearchRoot = nil
        lastActionMessage = copy.updatedScanRootsMessage
    }

    func resetSearchRoots() {
        searchRoots = RoomServicePaths.defaultSearchRoots()
        AppPreferences.saveSearchRoots(searchRoots)
        selectedSearchRoot = nil
        lastActionMessage = copy.resetScanRootsMessage
    }

    func persistSafeguards() {
        AppPreferences.saveBool(requireConfirmation, key: AppPreferences.requireConfirmationKey)
        AppPreferences.saveBool(requireDangerConfirmation, key: AppPreferences.requireDangerConfirmationKey)
    }

    func setLanguage(_ language: AppLanguage) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.language = language
        }
        AppPreferences.saveLanguage(language)
    }

    func selectAllVisibleResults() {
        selectedScanItemIDs = Set(filteredItems.map(\.id))
    }

    func selectVisibleResults(for risk: RiskLevel) {
        selectedScanItemIDs = Set(filteredItems.filter { $0.risk == risk }.map(\.id))
    }

    func selectVisibleResults(for category: CleanupCategory) {
        selectedScanItemIDs = Set(filteredItems.filter { $0.category == category }.map(\.id))
    }

    func selectVisibleResults(minimumBytes: Int64) {
        selectedScanItemIDs = Set(filteredItems.filter { $0.bytes >= minimumBytes }.map(\.id))
    }

    func clearResultSelection() {
        selectedScanItemIDs.removeAll()
    }

    func revealPrimaryItemInFinder() {
        guard let item = primarySelectedItem else { return }
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: item.path)])
    }

    func openPrimaryItemInTerminal() {
        guard let item = primarySelectedItem else { return }
        let targetURL = URL(fileURLWithPath: item.path)
        let directoryURL = targetURL.hasDirectoryPath ? targetURL : targetURL.deletingLastPathComponent()
        let script = """
        tell application "Terminal"
          activate
          do script "cd \(shellQuoted(directoryURL.path))"
        end tell
        """
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }

    func exportCurrentScan() {
        guard let scanSummary else { return }

        let categories = Array(includedCategories).sorted { $0.displayName < $1.displayName }
        let document = ScanExportDocument(
            productName: copy.appName,
            generatedAt: Date(),
            version: currentAppVersion,
            searchRoots: searchRoots,
            categories: categories.map(\.rawValue),
            excludedPaths: excludedPaths,
            summary: scanSummary
        )

        export(document, suggestedFileName: "devmaid-scan-\(Self.exportTimestamp).json")
    }

    func exportHistory() {
        let manager = QuarantineManager()
        let exportEntries = historyEntries.map { entry in
            HistoryExportEntry(
                entry: entry,
                manifest: entry.kind == .delete ? try? manager.loadManifest(actionID: entry.id) : nil
            )
        }
        let document = HistoryExportDocument(
            productName: copy.appName,
            generatedAt: Date(),
            version: currentAppVersion,
            entries: exportEntries
        )
        export(document, suggestedFileName: "devmaid-history-\(Self.exportTimestamp).json")
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
        AppPreferences.saveBool(enabled, key: AppPreferences.notificationsEnabledKey)

        if enabled {
            Task {
                await NotificationManager.requestAuthorizationIfNeeded()
            }
        }
    }

    func setFreeSpaceAlertThreshold(_ value: Int) {
        freeSpaceAlertThresholdGB = value
        AppPreferences.saveInt(value, key: AppPreferences.freeSpaceAlertThresholdGBKey)
    }

    func setReclaimableSpikeThreshold(_ value: Int) {
        reclaimableSpikeThresholdGB = value
        AppPreferences.saveInt(value, key: AppPreferences.reclaimableSpikeThresholdGBKey)
    }

    func setStartupItemsFilter(_ filter: StartupItemsFilter) {
        startupItemsFilter = filter
        AppPreferences.saveString(filter.rawValue, key: AppPreferences.startupItemsFilterKey)
    }

    func refreshStartupItems() {
        isLoadingStartupItems = true
        Task {
            let items = await Task.detached(priority: .utility) {
                StartupItemsService.loadItems()
            }.value
            withAnimation(.easeInOut(duration: 0.2)) {
                self.startupItems = items
                self.isLoadingStartupItems = false
            }
        }
    }

    func setStartupItemEnabled(_ item: StartupItem, enabled: Bool) {
        guard item.kind == .appManaged else { return }

        currentOperation = enabled ? .restoring : .quarantining
        Task {
            do {
                try await Task.detached(priority: .userInitiated) {
                    try StartupItemsService.setLaunchAtLogin(enabled: enabled)
                }.value
                self.currentOperation = nil
                self.refreshStartupItems()
                self.lastActionMessage = enabled ? self.copy.startupEnabledMessage : self.copy.startupDisabledMessage
            } catch {
                self.currentOperation = nil
                self.lastError = error.localizedDescription
            }
        }
    }

    func dismissOnboarding() {
        showOnboarding = false
        AppPreferences.saveBool(true, key: AppPreferences.completedOnboardingKey)
    }

    func reopenOnboarding() {
        showOnboarding = true
    }

    func openFullDiskAccessSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    func openPrivacyPolicy() {
        NSWorkspace.shared.open(RoomServiceLinks.privacy)
    }

    func handleInitialLoad() {
        guard hasPerformedLaunchTasks == false else { return }
        hasPerformedLaunchTasks = true

        refreshStartupItems()
        Task {
            await evaluateLaunchAlerts()
            if notificationsEnabled {
                await NotificationManager.requestAuthorizationIfNeeded()
            }
        }

        guard automaticallyCheckForUpdates else { return }
        guard shouldPerformAutomaticUpdateCheck() else { return }
        checkForUpdates(userInitiated: false)
    }

    func setAutomaticUpdateChecks(_ enabled: Bool) {
        automaticallyCheckForUpdates = enabled
        AppPreferences.saveBool(enabled, key: AppPreferences.autoCheckUpdatesKey)
    }

    func checkForUpdates(userInitiated: Bool = true) {
        guard isCheckingForUpdates == false else { return }

        isCheckingForUpdates = true
        lastUpdateError = nil
        if userInitiated {
            lastActionMessage = nil
        }

        Task {
            do {
                let result = try await updateService.checkForUpdates()

                withAnimation(.easeInOut(duration: 0.2)) {
                    self.isCheckingForUpdates = false
                    self.lastUpdateCheckDate = result.checkedAt
                    self.availableUpdate = result.state == .updateAvailable ? result.release : nil
                    self.unsupportedSystemUpdate = result.state == .unsupportedSystem ? result.release : nil
                    self.lastUpdateError = nil
                }
                AppPreferences.saveDate(result.checkedAt, key: AppPreferences.lastUpdateCheckKey)
            } catch {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.isCheckingForUpdates = false
                    self.availableUpdate = nil
                    self.unsupportedSystemUpdate = nil
                    self.lastUpdateError = error.localizedDescription
                }
            }
        }
    }

    func openUpdateDownload() {
        guard let url = updateDownloadURL else { return }
        NSWorkspace.shared.open(url)
    }

    func openUpdateReleaseNotes() {
        guard let url = updateReleaseNotesURL else { return }
        NSWorkspace.shared.open(url)
    }

    private func loadRecentScans() {
        do {
            recentScans = try scanHistoryStore.load()
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func recordScan(summary: ScanSummary, roots: [String], categories: [CleanupCategory]) {
        let snapshot = DiskSpaceInspector.snapshot(for: NSHomeDirectory()) ?? DiskUsageSnapshot(
            totalBytes: 0,
            freeBytes: 0,
            usedBytes: 0
        )
        let record = ScanRecord(
            id: ISO8601DateFormatter().string(from: Date()),
            recordedAt: Date(),
            totalBytes: summary.totalBytes,
            itemCount: summary.itemCount,
            categories: categories.map(\.rawValue),
            searchRoots: roots,
            disk: snapshot
        )

        do {
            try scanHistoryStore.record(record)
            recentScans = try scanHistoryStore.load()
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func evaluateLaunchAlerts() async {
        guard let snapshot = DiskSpaceInspector.snapshot(for: NSHomeDirectory()) else { return }
        await maybeSendLowSpaceAlert(snapshot: snapshot)
    }

    private func evaluateAlerts(after summary: ScanSummary) async {
        if let snapshot = DiskSpaceInspector.snapshot(for: NSHomeDirectory()) {
            await maybeSendLowSpaceAlert(snapshot: snapshot)
        }
        await maybeSendReclaimableSpikeAlert(currentBytes: summary.totalBytes)
    }

    private func maybeSendLowSpaceAlert(snapshot: DiskUsageSnapshot) async {
        guard notificationsEnabled else { return }
        let thresholdBytes = Int64(freeSpaceAlertThresholdGB) * 1_073_741_824
        guard snapshot.freeBytes <= thresholdBytes else { return }
        guard shouldPostAlert(lastKey: AppPreferences.lastLowSpaceAlertKey, minimumInterval: 60 * 60 * 6) else { return }

        AppPreferences.saveDate(Date(), key: AppPreferences.lastLowSpaceAlertKey)
        await NotificationManager.post(
            title: copy.lowSpaceAlertTitle,
            body: copy.lowSpaceAlertBody(free: RoomServiceFormatters.byteString(snapshot.freeBytes)),
            identifier: "devmaid.low-space"
        )
    }

    private func maybeSendReclaimableSpikeAlert(currentBytes: Int64) async {
        guard notificationsEnabled else { return }
        guard let previous = recentScans.dropLast().last else { return }
        let delta = currentBytes - previous.totalBytes
        let thresholdBytes = Int64(reclaimableSpikeThresholdGB) * 1_073_741_824
        guard delta >= thresholdBytes else { return }
        guard shouldPostAlert(lastKey: AppPreferences.lastSpikeAlertKey, minimumInterval: 60 * 60 * 6) else { return }

        AppPreferences.saveDate(Date(), key: AppPreferences.lastSpikeAlertKey)
        await NotificationManager.post(
            title: copy.reclaimableSpikeAlertTitle,
            body: copy.reclaimableSpikeAlertBody(delta: RoomServiceFormatters.byteString(delta)),
            identifier: "devmaid.reclaimable-spike"
        )
    }

    private func shouldPostAlert(lastKey: String, minimumInterval: TimeInterval) -> Bool {
        guard let lastDate = AppPreferences.loadDate(key: lastKey) else { return true }
        return Date().timeIntervalSince(lastDate) >= minimumInterval
    }

    private func shouldPerformAutomaticUpdateCheck() -> Bool {
        guard let lastUpdateCheckDate else { return true }
        return Date().timeIntervalSince(lastUpdateCheckDate) >= 60 * 60 * 12
    }

    private func export<T: Encodable>(_ value: T, suggestedFileName: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedFileName
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(value)
            try data.write(to: url)
            lastActionMessage = copy.exportSavedMessage(path: url.path)
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func loadSelectedManifest() {
        guard let entry = selectedHistoryEntry, entry.kind == .delete else {
            selectedHistoryManifest = nil
            return
        }

        do {
            selectedHistoryManifest = try QuarantineManager().loadManifest(actionID: entry.id)
        } catch {
            selectedHistoryManifest = nil
        }
    }

    private static var exportTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: Date())
    }

    private func shellQuoted(_ path: String) -> String {
        "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
