import Foundation

public enum DevMaidPaths {
    public static func expandedHomePath(_ path: String, fileManager: FileManager = .default) -> String {
        if path == "~" {
            return fileManager.homeDirectoryForCurrentUser.path
        }

        if path.hasPrefix("~/") {
            let home = fileManager.homeDirectoryForCurrentUser.path
            return home + "/" + path.dropFirst(2)
        }

        return path
    }

    public static func defaultSearchRoots(fileManager: FileManager = .default, currentDirectory: String = FileManager.default.currentDirectoryPath) -> [String] {
        let home = fileManager.homeDirectoryForCurrentUser.path
        let candidates = [
            currentDirectory,
            "\(home)/Desktop",
            "\(home)/Documents",
            "\(home)/Developer",
            "\(home)/Projects",
            "\(home)/Workspace",
            "\(home)/Code",
            "\(home)/Sites",
            "\(home)/Work",
        ]

        var seen = Set<String>()
        let roots = candidates.compactMap { rawPath -> String? in
            let path = expandedHomePath(rawPath, fileManager: fileManager)
            guard fileManager.fileExists(atPath: path) else {
                return nil
            }

            let standardized = URL(fileURLWithPath: path).standardizedFileURL.path
            guard seen.insert(standardized).inserted else {
                return nil
            }
            return standardized
        }

        return roots.isEmpty ? [home] : roots
    }
}

public enum DevMaidFormatters {
    private static func makeByteFormatter() -> ByteCountFormatter {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }

    private static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    public static func byteString(_ bytes: Int64) -> String {
        Self.makeByteFormatter().string(fromByteCount: bytes)
    }

    public static func dateTimeString(_ date: Date) -> String {
        Self.makeDateFormatter().string(from: date)
    }
}

public enum DiskSpaceInspector {
    public static func snapshot(for path: String, fileManager: FileManager = .default) -> DiskUsageSnapshot? {
        guard let attributes = try? fileManager.attributesOfFileSystem(forPath: path),
              let total = attributes[.systemSize] as? NSNumber,
              let free = attributes[.systemFreeSize] as? NSNumber else {
            return nil
        }

        let totalBytes = total.int64Value
        let freeBytes = free.int64Value
        let usedBytes = max(0, totalBytes - freeBytes)
        return DiskUsageSnapshot(totalBytes: totalBytes, freeBytes: freeBytes, usedBytes: usedBytes)
    }
}

enum ProcessError: Error, CustomStringConvertible {
    case launchFailed(String)
    case nonZeroExit(String)

    var description: String {
        switch self {
        case .launchFailed(let message), .nonZeroExit(let message):
            return message
        }
    }
}

struct ProcessRunner {
    func capture(_ executable: String, arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            throw ProcessError.launchFailed("Failed to launch \(executable): \(error.localizedDescription)")
        }

        process.waitUntilExit()

        let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let errorOutput = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        guard process.terminationStatus == 0 else {
            let message = errorOutput.isEmpty ? output : errorOutput
            throw ProcessError.nonZeroExit(message.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return output
    }
}

struct DirectorySizer {
    private let processRunner = ProcessRunner()
    private let fileManager = FileManager.default

    func sizeInBytes(at path: String) throws -> Int64 {
        if let bytes = try? sizeUsingDU(path: path) {
            return bytes
        }

        return try recursiveSize(path: path)
    }

    private func sizeUsingDU(path: String) throws -> Int64 {
        let output = try processRunner.capture("/usr/bin/du", arguments: ["-sk", path])
        guard let firstToken = output.split(whereSeparator: \.isWhitespace).first,
              let kilobytes = Int64(firstToken) else {
            throw ProcessError.nonZeroExit("Unable to parse du output for \(path)")
        }
        return kilobytes * 1024
    }

    private func recursiveSize(path: String) throws -> Int64 {
        let rootURL = URL(fileURLWithPath: path)
        let keys: [URLResourceKey] = [
            .isRegularFileKey,
            .isDirectoryKey,
            .isSymbolicLinkKey,
            .totalFileAllocatedSizeKey,
            .fileAllocatedSizeKey,
            .fileSizeKey,
        ]

        var total: Int64 = 0
        let rootValues = try rootURL.resourceValues(forKeys: Set(keys))
        if rootValues.isRegularFile == true {
            total += Int64(rootValues.totalFileAllocatedSize ?? rootValues.fileAllocatedSize ?? rootValues.fileSize ?? 0)
            return total
        }

        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: keys,
            options: [.skipsPackageDescendants],
            errorHandler: { _, _ in true }
        ) else {
            return total
        }

        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: Set(keys)) else {
                continue
            }

            if values.isSymbolicLink == true {
                if values.isDirectory == true {
                    enumerator.skipDescendants()
                }
                continue
            }

            if values.isRegularFile == true {
                total += Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? values.fileSize ?? 0)
            }
        }

        return total
    }
}
