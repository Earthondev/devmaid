import AppKit
import Foundation
import ServiceManagement

struct StartupItem: Identifiable, Hashable {
    enum Kind: String {
        case appManaged
        case readOnly
    }

    let id: String
    let name: String
    let detail: String
    let kind: Kind
    let isEnabled: Bool
}

enum StartupItemsService {
    static func loadItems() -> [StartupItem] {
        var items = [appManagedItem()]
        items.append(contentsOf: readOnlyLoginItems())
        return items.sorted { lhs, rhs in
            if lhs.kind != rhs.kind {
                return lhs.kind == .appManaged
            }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    static func setLaunchAtLogin(enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }

    private static func appManagedItem() -> StartupItem {
        let status = SMAppService.mainApp.status
        return StartupItem(
            id: "devmaid.app-managed",
            name: "DevMaid",
            detail: statusDescription(status),
            kind: .appManaged,
            isEnabled: status == .enabled
        )
    }

    private static func readOnlyLoginItems() -> [StartupItem] {
        let script = """
        tell application "System Events"
          set outputLines to {}
          repeat with loginItem in login items
            try
              set end of outputLines to (name of loginItem as text) & "||" & (path of loginItem as text)
            on error
              set end of outputLines to (name of loginItem as text) & "||"
            end try
          end repeat
          return outputLines as string
        end tell
        """

        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script),
              let descriptor = appleScript.executeAndReturnError(&error).stringValue else {
            if let error {
                NSLog("StartupItemsService error: \(error)")
            }
            return []
        }

        return descriptor
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { line in
                let parts = line.components(separatedBy: "||")
                let name = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                    ? parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    : "Login Item"
                let path = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                return StartupItem(
                    id: "readonly.\(name.lowercased()).\(path.lowercased())",
                    name: name,
                    detail: path.isEmpty ? "Managed by macOS" : path,
                    kind: .readOnly,
                    isEnabled: true
                )
            }
    }

    private static func statusDescription(_ status: SMAppService.Status) -> String {
        switch status {
        case .enabled:
            return "Launch at login enabled"
        case .requiresApproval:
            return "Needs approval in System Settings"
        case .notFound:
            return "Helper not registered yet"
        case .notRegistered:
            return "Launch at login disabled"
        @unknown default:
            return "Unknown startup state"
        }
    }
}
