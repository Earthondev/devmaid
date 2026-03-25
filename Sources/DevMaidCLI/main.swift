import Foundation
import DevMaidKit

struct CLIError: Error, CustomStringConvertible {
    let description: String
}

@main
struct DevMaidCLI {
    static func main() {
        do {
            try run()
        } catch let error as CLIError {
            fputs("Error: \(error.description)\n", stderr)
            exit(1)
        } catch {
            fputs("Error: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }

    private static func run() throws {
        var arguments = Array(CommandLine.arguments.dropFirst())
        guard let command = arguments.first else {
            printHelp()
            return
        }
        arguments.removeFirst()

        switch command {
        case "scan":
            try runScan(arguments)
        case "delete":
            try runDelete(arguments)
        case "undo":
            try runUndo(arguments)
        case "history":
            try runHistory(arguments)
        case "categories":
            printCategories()
        case "export":
            try runExport(arguments)
        case "help", "--help", "-h":
            printHelp()
        default:
            throw CLIError(description: "Unknown command '\(command)'. Run `devmaid help`.")
        }
    }

    private static func runScan(_ arguments: [String]) throws {
        let options = try parseOptions(arguments)
        let configuration = scanConfiguration(from: options)
        let summary = makeScanner().scan(configuration)

        if options.boolFlags.contains("json") {
            try printJSON(summary)
            return
        }

        print("DevMaid scan")
        print("Found \(summary.items.count) item(s), \(humanBytes(summary.totalBytes)) reclaimable")
        print("")

        if summary.items.isEmpty {
            print("No matching items found.")
        } else {
            for item in summary.items {
                let groupLabel = item.groupName.map { " [\($0)]" } ?? ""
                print("[\(item.risk.label)] \(item.category.rawValue)\(groupLabel)  \(humanBytes(item.bytes))")
                print(item.path)
                print("  \(item.note)")
            }
        }

        if !summary.warnings.isEmpty {
            print("")
            print("Warnings:")
            for warning in summary.warnings {
                print("- \(warning)")
            }
        }
    }

    private static func runDelete(_ arguments: [String]) throws {
        let options = try parseOptions(arguments)
        let configuration = scanConfiguration(from: options)
        let summary = makeScanner().scan(configuration)

        var selected = summary.items

        if let categoryValues = options.values["category"], !categoryValues.isEmpty {
            let categories = try parseCategories(categoryValues)
            selected = selected.filter { categories.contains($0.category) }
        }

        if let paths = options.values["path"], !paths.isEmpty {
            let expandedPaths = Set(paths.map { DevMaidPaths.expandedHomePath($0) })
            selected = selected.filter { expandedPaths.contains($0.path) }
        }

        if options.boolFlags.contains("all") == false,
           options.values["category"] == nil,
           options.values["path"] == nil {
            throw CLIError(description: "Delete requires `--all`, `--category`, or `--path`.")
        }

        if !options.boolFlags.contains("allow-danger") {
            let dangerItems = selected.filter { $0.risk == .danger }
            if !dangerItems.isEmpty {
                let paths = dangerItems.map(\.path).joined(separator: "\n")
                throw CLIError(description: "Dangerous targets require `--allow-danger`.\n\(paths)")
            }
        }

        guard !selected.isEmpty else {
            throw CLIError(description: "No matching items selected for deletion.")
        }

        let total = selected.reduce(Int64(0)) { $0 + $1.bytes }
        if !options.boolFlags.contains("yes") {
            print("About to quarantine \(selected.count) item(s), \(humanBytes(total)) total.")
            print("Continue? [y/N]")
            let confirmation = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard confirmation == "y" || confirmation == "yes" else {
                print("Cancelled.")
                return
            }
        }

        let manifest = try QuarantineManager().quarantine(selected)
        if options.boolFlags.contains("json") {
            try printJSON(manifest)
            return
        }

        print("Quarantined \(manifest.items.count) item(s) into action \(manifest.actionID)")
        print("Stored at \(QuarantineManager().quarantineRootURL.appendingPathComponent(manifest.actionID).path)")
        print("Use `devmaid undo \(manifest.actionID)` to restore.")
    }

    private static func runUndo(_ arguments: [String]) throws {
        var remaining = arguments
        var actionID: String?

        while let token = remaining.first {
            remaining.removeFirst()
            if token == "--id" {
                guard let value = remaining.first else {
                    throw CLIError(description: "Missing value for --id")
                }
                remaining.removeFirst()
                actionID = value
                continue
            }

            if token.hasPrefix("-") {
                throw CLIError(description: "Unknown option \(token)")
            }

            actionID = token
        }

        guard let actionID else {
            throw CLIError(description: "Undo requires an action ID.")
        }

        let result = try QuarantineManager().restore(actionID: actionID)
        print("Restored \(result.restored.count) item(s) from \(actionID).")
        if !result.skipped.isEmpty {
            print("Skipped:")
            for line in result.skipped {
                print("- \(line)")
            }
        }
    }

    private static func runHistory(_ arguments: [String]) throws {
        let options = try parseOptions(arguments)
        let entries = try HistoryStore().load()
        let limit: Int? = options.values["limit"]?.last.flatMap(Int.init)
        let output = limit.map { Array(entries.prefix($0)) } ?? entries

        if options.boolFlags.contains("json") {
            try printJSON(output)
            return
        }

        if output.isEmpty {
            print("No history yet.")
            return
        }

        for entry in output {
            print("\(entry.id) [\(entry.kind.rawValue)] \(humanBytes(entry.totalBytes)) \(entry.itemCount) item(s)")
            print("  \(entry.summary)")
        }
    }

    private static func runExport(_ arguments: [String]) throws {
        guard let subject = arguments.first else {
            throw CLIError(description: "Export requires a subject: `scan` or `history`.")
        }

        let remaining = Array(arguments.dropFirst())
        let options = try parseOptions(remaining)
        let format = options.values["format"]?.last?.lowercased() ?? "json"
        guard format == "json" else {
            throw CLIError(description: "Only `json` export is supported right now.")
        }

        switch subject {
        case "scan":
            let configuration = scanConfiguration(from: options)
            let summary = makeScanner().scan(configuration)
            let document = ScanExportDocument(
                productName: "DevMaid",
                generatedAt: Date(),
                version: currentVersion(),
                searchRoots: configuration.searchRoots,
                categories: configuration.categories.map(\.rawValue),
                excludedPaths: configuration.excludedPaths,
                summary: summary
            )
            try writeExport(document, to: options.values["output"]?.last)
        case "history":
            let entries = try HistoryStore().load()
            let limit: Int? = options.values["limit"]?.last.flatMap(Int.init)
            let output = limit.map { Array(entries.prefix($0)) } ?? entries
            let manager = QuarantineManager()
            let exportEntries = output.map { entry in
                HistoryExportEntry(
                    entry: entry,
                    manifest: entry.kind == .delete ? try? manager.loadManifest(actionID: entry.id) : nil
                )
            }
            let document = HistoryExportDocument(
                productName: "DevMaid",
                generatedAt: Date(),
                version: currentVersion(),
                entries: exportEntries
            )
            try writeExport(document, to: options.values["output"]?.last)
        default:
            throw CLIError(description: "Unknown export subject '\(subject)'. Use `scan` or `history`.")
        }
    }

    private static func printCategories() {
        for category in CleanupCategory.allCases {
            print("\(category.rawValue) [\(category.risk.label)]")
            print("  \(category.displayName)")
            print("  \(category.note)")
        }
    }

    private static func printHelp() {
        print(
            """
            devmaid

            Commands:
              scan [--category <name>] [--search-root <path>] [--exclude <path>] [--limit <n>] [--json]
              delete (--all | --category <name> | --path <path>) [--search-root <path>] [--exclude <path>] [--allow-danger] [--yes] [--json]
              undo <action-id>
              history [--limit <n>] [--json]
              export scan [--category <name>] [--search-root <path>] [--exclude <path>] [--limit <n>] [--format json] [--output <path>]
              export history [--limit <n>] [--format json] [--output <path>]
              categories

            Examples:
              devmaid scan
              devmaid scan --category code-editors --search-root ~/Projects --exclude ~/Projects/client-a/build
              devmaid delete --category xcode-derived-data --yes
              devmaid export scan --format json --output report.json
              devmaid undo 2026-03-24T10-00-00Z-ABC12345
            """
        )
    }

    private static func makeScanner() -> DevMaidScanner {
        DevMaidScanner()
    }

    private static func scanConfiguration(from options: ParsedOptions) -> ScanConfiguration {
        let searchRoots = options.values["search-root"]?.map { DevMaidPaths.expandedHomePath($0) }
            ?? DevMaidPaths.defaultSearchRoots()
        let excludedPaths = options.values["exclude"]?.map { DevMaidPaths.expandedHomePath($0) } ?? []
        let categories = (try? parseCategories(options.values["category"] ?? [])) ?? CleanupCategory.allCases
        let maxItems = options.values["limit"]?.last.flatMap(Int.init)
        return ScanConfiguration(
            categories: categories,
            searchRoots: searchRoots,
            maxItems: maxItems,
            excludedPaths: excludedPaths
        )
    }

    private static func parseCategories(_ rawValues: [String]) throws -> [CleanupCategory] {
        if rawValues.isEmpty {
            return CleanupCategory.allCases
        }

        return try rawValues.map { value in
            guard let category = CleanupCategory.parse(value) else {
                throw CLIError(description: "Unknown category '\(value)'. Run `devmaid categories`.")
            }
            return category
        }
    }

    private static func humanBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private static func writeExport<T: Encodable>(_ value: T, to outputPath: String?) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)

        if let outputPath, !outputPath.isEmpty {
            let expandedPath = DevMaidPaths.expandedHomePath(outputPath)
            try data.write(to: URL(fileURLWithPath: expandedPath))
            print("Wrote export to \(expandedPath)")
            return
        }

        guard let text = String(data: data, encoding: .utf8) else {
            throw CLIError(description: "Failed to encode export as UTF-8 text.")
        }
        print(text)
    }

    private static func printJSON<T: Encodable>(_ value: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        guard let text = String(data: data, encoding: .utf8) else {
            throw CLIError(description: "Failed to encode JSON output.")
        }
        print(text)
    }

    private static func currentVersion() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return version
        }
        return ProcessInfo.processInfo.environment["DEVMAID_VERSION"] ?? "0.2.0"
    }
}

private struct ParsedOptions {
    var values: [String: [String]] = [:]
    var boolFlags = Set<String>()
}

private func parseOptions(_ arguments: [String]) throws -> ParsedOptions {
    var parsed = ParsedOptions()
    var index = 0

    while index < arguments.count {
        let token = arguments[index]
        if token.hasPrefix("--") {
            let flag = String(token.dropFirst(2))
            if index + 1 < arguments.count, arguments[index + 1].hasPrefix("--") == false {
                parsed.values[flag, default: []].append(arguments[index + 1])
                index += 2
            } else {
                parsed.boolFlags.insert(flag)
                index += 1
            }
        } else {
            parsed.values["_positional", default: []].append(token)
            index += 1
        }
    }

    return parsed
}
