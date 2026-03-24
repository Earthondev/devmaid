import Foundation

struct AppUpdateRelease: Decodable, Sendable {
    let version: String
    let build: String?
    let minimumSystemVersion: String?
    let summary: String?
    let downloadURL: URL
    let releaseNotesURL: URL?
    let publishedAt: Date?

    enum CodingKeys: String, CodingKey {
        case version
        case build
        case minimumSystemVersion
        case summary
        case downloadURL
        case releaseNotesURL
        case publishedAt
    }

    var displayVersion: String {
        guard let build, !build.isEmpty, build != version else {
            return version
        }
        return "\(version) (\(build))"
    }
}

struct AppUpdateCheckResult: Sendable {
    enum State: Sendable {
        case upToDate
        case updateAvailable
        case unsupportedSystem
    }

    let state: State
    let release: AppUpdateRelease
    let checkedAt: Date
}

private struct AppUpdateDocument: Decodable {
    let releases: [AppUpdateRelease]

    init(from decoder: Decoder) throws {
        if let release = try? AppUpdateRelease(from: decoder) {
            self.releases = [release]
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.releases = try container.decode([AppUpdateRelease].self, forKey: .releases)
    }

    enum CodingKeys: String, CodingKey {
        case releases
    }
}

struct AppUpdateConfiguration: Sendable {
    let feedURL: URL?

    static func load(bundle: Bundle = .main, environment: [String: String] = ProcessInfo.processInfo.environment) -> AppUpdateConfiguration {
        if let override = environment["DEVMAID_UPDATE_FEED_URL"], let url = parseURL(override) {
            return AppUpdateConfiguration(feedURL: url)
        }

        if let override = environment["ROOMSERVICE_UPDATE_FEED_URL"], let url = parseURL(override) {
            return AppUpdateConfiguration(feedURL: url)
        }

        if let infoValue = bundle.object(forInfoDictionaryKey: "DevMaidUpdateFeedURL") as? String,
           let url = parseURL(infoValue) {
            return AppUpdateConfiguration(feedURL: url)
        }

        return AppUpdateConfiguration(feedURL: URL(string: "https://github.com/Earthondev/devmaid/releases/latest/download/appcast.json"))
    }

    private static func parseURL(_ rawValue: String) -> URL? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if trimmed.contains("://") {
            return URL(string: trimmed)
        }

        return URL(fileURLWithPath: trimmed)
    }
}

enum AppUpdateError: LocalizedError {
    case missingFeedURL
    case invalidFeed
    case emptyFeed

    var errorDescription: String? {
        switch self {
        case .missingFeedURL:
            return "No update feed URL is configured."
        case .invalidFeed:
            return "The update feed format is invalid."
        case .emptyFeed:
            return "The update feed did not contain any releases."
        }
    }
}

struct AppUpdateService {
    let configuration: AppUpdateConfiguration
    let bundle: Bundle
    let session: URLSession

    init(
        configuration: AppUpdateConfiguration = .load(),
        bundle: Bundle = .main,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.bundle = bundle
        self.session = session
    }

    var feedURL: URL? {
        configuration.feedURL
    }

    var currentVersion: String {
        (bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0.1.0"
    }

    var currentBuild: String {
        (bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? currentVersion
    }

    var currentDisplayVersion: String {
        let version = currentVersion
        let build = currentBuild
        return build == version ? version : "\(version) (\(build))"
    }

    func checkForUpdates() async throws -> AppUpdateCheckResult {
        guard let feedURL else {
            throw AppUpdateError.missingFeedURL
        }

        let data = try await loadData(from: feedURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let document = try? decoder.decode(AppUpdateDocument.self, from: data) else {
            throw AppUpdateError.invalidFeed
        }

        guard let latestRelease = document.releases.max(by: { compareReleases($0, $1) == .orderedAscending }) else {
            throw AppUpdateError.emptyFeed
        }

        let checkedAt = Date()
        let currentRelease = AppUpdateRelease(
            version: currentVersion,
            build: currentBuild,
            minimumSystemVersion: nil,
            summary: nil,
            downloadURL: feedURL,
            releaseNotesURL: nil,
            publishedAt: nil
        )

        let comparison = compareReleases(currentRelease, latestRelease)
        let isSupported = isCurrentSystemCompatible(with: latestRelease.minimumSystemVersion)
        let state: AppUpdateCheckResult.State

        if comparison == .orderedAscending {
            state = isSupported ? .updateAvailable : .unsupportedSystem
        } else {
            state = .upToDate
        }

        return AppUpdateCheckResult(state: state, release: latestRelease, checkedAt: checkedAt)
    }

    private func loadData(from url: URL) async throws -> Data {
        if url.isFileURL {
            return try Data(contentsOf: url)
        }

        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 12
        )
        let (data, _) = try await session.data(for: request)
        return data
    }

    private func compareReleases(_ lhs: AppUpdateRelease, _ rhs: AppUpdateRelease) -> ComparisonResult {
        let versionResult = compareVersionStrings(lhs.version, rhs.version)
        guard versionResult == .orderedSame else {
            return versionResult
        }

        return compareVersionStrings(lhs.build ?? lhs.version, rhs.build ?? rhs.version)
    }

    private func compareVersionStrings(_ lhs: String, _ rhs: String) -> ComparisonResult {
        (lhs as NSString).compare(rhs, options: .numeric)
    }

    private func isCurrentSystemCompatible(with minimumVersion: String?) -> Bool {
        guard let minimumVersion, !minimumVersion.isEmpty else {
            return true
        }

        let parts = minimumVersion
            .split(separator: ".")
            .map { Int($0) ?? 0 }

        let minimum = OperatingSystemVersion(
            majorVersion: parts[safe: 0] ?? 0,
            minorVersion: parts[safe: 1] ?? 0,
            patchVersion: parts[safe: 2] ?? 0
        )

        return ProcessInfo.processInfo.isOperatingSystemAtLeast(minimum)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
