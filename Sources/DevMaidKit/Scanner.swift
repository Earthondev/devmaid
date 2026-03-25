import Foundation

public final class DevMaidScanner {
    private let fileManager: FileManager
    private let sizer: DirectorySizer

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.sizer = DirectorySizer()
    }

    public func scan(_ configuration: ScanConfiguration) -> ScanSummary {
        let startedAt = Date()
        var items: [ScanItem] = []
        var warnings: [String] = []
        var seenPaths = Set<String>()

        let categories = configuration.categories.isEmpty ? CleanupCategory.allCases : configuration.categories
        let roots = configuration.searchRoots.map { DevMaidPaths.expandedHomePath($0, fileManager: fileManager) }
        let excludedPaths = Set(
            configuration.excludedPaths
                .map { DevMaidPaths.expandedHomePath($0, fileManager: fileManager) }
                .map { URL(fileURLWithPath: $0).standardizedFileURL.path }
        )

        for category in categories {
            if category.usesRecursiveSearch {
                let found = discoverDirectories(
                    named: Set(category.recursiveDirectoryNames),
                    in: roots,
                    excludedPaths: excludedPaths
                )
                for path in found {
                    let standardized = URL(fileURLWithPath: path).standardizedFileURL.path
                    guard isExcluded(standardized, excludedPaths: excludedPaths) == false else {
                        continue
                    }
                    guard seenPaths.insert(standardized).inserted else {
                        continue
                    }

                    do {
                        let bytes = try sizer.sizeInBytes(at: standardized)
                        items.append(
                            ScanItem(
                                category: category,
                                path: standardized,
                                bytes: bytes,
                                risk: category.risk,
                                note: category.note,
                                groupName: category.groupName(for: standardized)
                            )
                        )
                    } catch {
                        warnings.append("Could not size \(standardized): \(error.localizedDescription)")
                    }
                }
            }

            for relativePath in category.fixedPathsRelativeToHome {
                let fullPath = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(relativePath).path
                guard fileManager.fileExists(atPath: fullPath) else {
                    continue
                }

                let standardized = URL(fileURLWithPath: fullPath).standardizedFileURL.path
                guard isExcluded(standardized, excludedPaths: excludedPaths) == false else {
                    continue
                }
                guard seenPaths.insert(standardized).inserted else {
                    continue
                }

                do {
                    let bytes = try sizer.sizeInBytes(at: standardized)
                    items.append(
                        ScanItem(
                            category: category,
                            path: standardized,
                            bytes: bytes,
                            risk: category.risk,
                            note: category.note,
                            groupName: category.groupName(for: standardized)
                        )
                    )
                } catch {
                    warnings.append("Could not size \(standardized): \(error.localizedDescription)")
                }
            }
        }

        items.sort {
            if $0.bytes == $1.bytes {
                return $0.path.localizedStandardCompare($1.path) == .orderedAscending
            }
            return $0.bytes > $1.bytes
        }

        let limitedItems: [ScanItem]
        if let maxItems = configuration.maxItems {
            limitedItems = Array(items.prefix(maxItems))
        } else {
            limitedItems = items
        }

        return ScanSummary(
            startedAt: startedAt,
            finishedAt: Date(),
            items: limitedItems,
            warnings: warnings.sorted()
        )
    }

    private func discoverDirectories(named targetNames: Set<String>, in roots: [String], excludedPaths: Set<String>) -> [String] {
        var results: [String] = []
        let keys: [URLResourceKey] = [
            .isDirectoryKey,
            .isSymbolicLinkKey,
            .isPackageKey,
        ]

        for root in roots {
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: root, isDirectory: &isDirectory), isDirectory.boolValue else {
                continue
            }
            if isExcluded(root, excludedPaths: excludedPaths) {
                continue
            }

            let rootURL = URL(fileURLWithPath: root, isDirectory: true)
            guard let enumerator = fileManager.enumerator(
                at: rootURL,
                includingPropertiesForKeys: keys,
                options: [.skipsPackageDescendants],
                errorHandler: { _, _ in true }
            ) else {
                continue
            }

            for case let url as URL in enumerator {
                if isExcluded(url.path, excludedPaths: excludedPaths) {
                    enumerator.skipDescendants()
                    continue
                }

                guard let values = try? url.resourceValues(forKeys: Set(keys)) else {
                    continue
                }

                if values.isSymbolicLink == true {
                    if values.isDirectory == true {
                        enumerator.skipDescendants()
                    }
                    continue
                }

                guard values.isDirectory == true else {
                    continue
                }

                let name = url.lastPathComponent
                if targetNames.contains(name) {
                    results.append(url.path)
                    enumerator.skipDescendants()
                    continue
                }

                if shouldPrune(name: name) {
                    enumerator.skipDescendants()
                }
            }
        }

        return results
    }

    private func isExcluded(_ path: String, excludedPaths: Set<String>) -> Bool {
        excludedPaths.contains { excluded in
            path == excluded || path.hasPrefix(excluded + "/")
        }
    }

    private func shouldPrune(name: String) -> Bool {
        let pruned: Set<String> = [
            ".git",
            ".svn",
            ".hg",
            ".build",
            "DerivedData",
            "dist",
            "build",
        ]

        return pruned.contains(name)
    }
}
