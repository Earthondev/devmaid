import AppKit
import SwiftUI

@main
struct DevMaidDesktopApp: App {
    @StateObject private var model = RoomServiceAppModel()

    private var copy: RoomServiceCopy { model.copy }

    var body: some Scene {
        WindowGroup("DevMaid") {
            RoomServiceRootView()
                .environmentObject(model)
                .frame(minWidth: 1180, minHeight: 760)
                .preferredColorScheme(.light)
                .task {
                    model.handleInitialLoad()
                }
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button(copy.menuAbout) {
                    openDestination(.about)
                }
            }

            CommandGroup(after: .appInfo) {
                Button(copy.menuCheckForUpdates) {
                    model.checkForUpdates(userInitiated: true)
                }
                .disabled(!model.canCheckForUpdates)
            }

            CommandGroup(replacing: .appSettings) {
                Button(copy.menuSettings) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            CommandMenu(copy.menuNavigate) {
                navigationButton(for: .overview, shortcut: "1")
                navigationButton(for: .results, shortcut: "2")
                navigationButton(for: .history, shortcut: "3")
                Divider()
                navigationButton(for: .settings, shortcut: "4")
                navigationButton(for: .about, shortcut: "5")
            }

            CommandGroup(replacing: .sidebar) {
                Button(copy.menuToggleSidebar) {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .option])
            }

            CommandGroup(after: .help) {
                Button(copy.menuSupport) {
                    NSWorkspace.shared.open(RoomServiceLinks.support)
                }
            }
        }

        Settings {
            SettingsScreen()
                .environmentObject(model)
                .frame(width: 700, height: 560)
                .preferredColorScheme(.light)
        }
    }

    @ViewBuilder
    private func navigationButton(for destination: RoomServiceDestination, shortcut: KeyEquivalent) -> some View {
        Button(destination.title(in: model.language)) {
            openDestination(destination)
        }
        .keyboardShortcut(shortcut, modifiers: .command)
    }

    private func openDestination(_ destination: RoomServiceDestination) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            model.destination = destination
        }
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }
}
