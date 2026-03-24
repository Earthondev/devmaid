import Foundation

public enum CleanupCategory: String, Codable, CaseIterable, Hashable, Sendable {
    case codeEditors = "code-editors"
    case xcodeDerivedData = "xcode-derived-data"
    case xcodeArchives = "xcode-archives"
    case coreSimulator = "core-simulator"
    case dockerData = "docker-data"
    case nodeModules = "node-modules"
    case pythonVirtualEnvs = "python-virtual-envs"
    case projectArtifacts = "project-artifacts"
    case homebrewCache = "homebrew-cache"
    case npmCache = "npm-cache"
    case pipCache = "pip-cache"
    case poetryCache = "poetry-cache"
    case yarnCache = "yarn-cache"
    case pnpmStore = "pnpm-store"
    case cargoCache = "cargo-cache"
    case nugetCache = "nuget-cache"
    case goCache = "go-cache"
    case playwrightCache = "playwright-cache"
    case cypressCache = "cypress-cache"
    case gradleCache = "gradle-cache"
    case androidArtifacts = "android-artifacts"
    case unityCache = "unity-cache"

    public static func parse(_ value: String) -> CleanupCategory? {
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return CleanupCategory.allCases.first { category in
            category.rawValue == normalized || category.aliases.contains(normalized)
        }
    }

    public var displayName: String {
        switch self {
        case .codeEditors:
            return "Code Editors"
        case .xcodeDerivedData:
            return "Xcode DerivedData"
        case .xcodeArchives:
            return "Xcode Archives"
        case .coreSimulator:
            return "CoreSimulator Devices"
        case .dockerData:
            return "Docker Desktop Data"
        case .nodeModules:
            return "node_modules"
        case .pythonVirtualEnvs:
            return "Python Virtual Envs"
        case .projectArtifacts:
            return "Project Artifacts"
        case .homebrewCache:
            return "Homebrew Cache"
        case .npmCache:
            return "npm Cache"
        case .pipCache:
            return "pip Cache"
        case .poetryCache:
            return "Poetry Cache"
        case .yarnCache:
            return "Yarn Cache"
        case .pnpmStore:
            return "pnpm Store"
        case .cargoCache:
            return "Cargo Cache"
        case .nugetCache:
            return "NuGet Cache"
        case .goCache:
            return "Go Cache"
        case .playwrightCache:
            return "Playwright Cache"
        case .cypressCache:
            return "Cypress Cache"
        case .gradleCache:
            return "Gradle Cache"
        case .androidArtifacts:
            return "Android Artifacts"
        case .unityCache:
            return "Unity Cache"
        }
    }

    public var note: String {
        switch self {
        case .codeEditors:
            return "Workspace storage, logs, and rebuildable editor caches."
        case .xcodeDerivedData:
            return "Rebuildable Xcode build artifacts."
        case .xcodeArchives:
            return "Old archives can be removed, but keep recent release builds."
        case .coreSimulator:
            return "Deletes simulator device data and installed apps."
        case .dockerData:
            return "Potentially removes Docker images, layers, and local volumes."
        case .nodeModules:
            return "Dependencies can be reinstalled, but local installs will disappear."
        case .pythonVirtualEnvs:
            return "Virtual environments are reproducible but project-local tools will need reinstall."
        case .projectArtifacts:
            return "Build folders can be regenerated, but local compiled output will disappear."
        case .homebrewCache:
            return "Safe to clear package download cache."
        case .npmCache:
            return "Safe to clear npm cache."
        case .pipCache:
            return "Safe to clear pip download and wheel cache."
        case .poetryCache:
            return "Poetry package caches can be downloaded again when needed."
        case .yarnCache:
            return "Safe to clear Yarn cache."
        case .pnpmStore:
            return "Package store can be rebuilt, but workspace installs may re-download."
        case .cargoCache:
            return "Cargo registry and git caches can be rebuilt from upstream."
        case .nugetCache:
            return "NuGet packages can be restored again during builds."
        case .goCache:
            return "Go build and module caches can be recreated, but restores may re-download."
        case .playwrightCache:
            return "Browsers will be downloaded again when tests run."
        case .cypressCache:
            return "Cypress binaries will be downloaded again when needed."
        case .gradleCache:
            return "Gradle dependencies will be downloaded again."
        case .androidArtifacts:
            return "Android emulators and shared Android caches can be recreated, but local state may be removed."
        case .unityCache:
            return "Unity asset/cache data may take time to regenerate."
        }
    }

    public var shortDescription: String {
        switch self {
        case .codeEditors:
            return "Editor caches and workspace state"
        case .xcodeDerivedData:
            return "Xcode build output"
        case .xcodeArchives:
            return "Archived app builds"
        case .coreSimulator:
            return "Simulator devices and data"
        case .dockerData:
            return "Docker images, layers, and volumes"
        case .nodeModules:
            return "JavaScript dependencies"
        case .pythonVirtualEnvs:
            return "Python virtual environments"
        case .projectArtifacts:
            return "Build and framework output folders"
        case .homebrewCache:
            return "Homebrew downloads"
        case .npmCache:
            return "npm package cache"
        case .pipCache:
            return "pip package cache"
        case .poetryCache:
            return "Poetry package cache"
        case .yarnCache:
            return "Yarn package cache"
        case .pnpmStore:
            return "pnpm shared store"
        case .cargoCache:
            return "Cargo registry and git cache"
        case .nugetCache:
            return "NuGet package cache"
        case .goCache:
            return "Go build and module cache"
        case .playwrightCache:
            return "Playwright browser binaries"
        case .cypressCache:
            return "Cypress binaries"
        case .gradleCache:
            return "Gradle dependency cache"
        case .androidArtifacts:
            return "Android emulator and shared caches"
        case .unityCache:
            return "Unity cache data"
        }
    }

    public var symbolName: String {
        switch self {
        case .codeEditors:
            return "keyboard.badge.ellipsis"
        case .xcodeDerivedData:
            return "hammer.fill"
        case .xcodeArchives:
            return "shippingbox.fill"
        case .coreSimulator:
            return "iphone.gen3"
        case .dockerData:
            return "shippingbox.circle.fill"
        case .nodeModules:
            return "cube.box.fill"
        case .pythonVirtualEnvs:
            return "chevron.left.forwardslash.chevron.right"
        case .projectArtifacts:
            return "shippingbox.circle"
        case .homebrewCache:
            return "cup.and.saucer.fill"
        case .npmCache:
            return "tray.full.fill"
        case .pipCache:
            return "arrow.down.doc.fill"
        case .poetryCache:
            return "text.book.closed.fill"
        case .yarnCache:
            return "tray.2.fill"
        case .pnpmStore:
            return "shippingbox.and.arrow.backward.fill"
        case .cargoCache:
            return "shippingbox.fill"
        case .nugetCache:
            return "cube.transparent.fill"
        case .goCache:
            return "arrow.triangle.2.circlepath.circle.fill"
        case .playwrightCache:
            return "globe.badge.chevron.backward"
        case .cypressCache:
            return "play.circle.fill"
        case .gradleCache:
            return "internaldrive.fill"
        case .androidArtifacts:
            return "droid"
        case .unityCache:
            return "gamecontroller.fill"
        }
    }

    public var risk: RiskLevel {
        switch self {
        case .xcodeDerivedData, .homebrewCache, .npmCache, .pipCache, .poetryCache, .yarnCache, .cargoCache, .nugetCache, .goCache, .playwrightCache, .cypressCache, .gradleCache:
            return .safe
        case .codeEditors, .xcodeArchives, .coreSimulator, .nodeModules, .pythonVirtualEnvs, .projectArtifacts, .pnpmStore, .androidArtifacts, .unityCache:
            return .review
        case .dockerData:
            return .danger
        }
    }

    public var recursiveDirectoryNames: [String] {
        switch self {
        case .nodeModules:
            return ["node_modules"]
        case .pythonVirtualEnvs:
            return [".venv", "venv"]
        case .projectArtifacts:
            return ["build", "dist", "target", ".next", ".nuxt"]
        default:
            return []
        }
    }

    public var aliases: Set<String> {
        switch self {
        case .codeEditors:
            return ["editors", "editor", "ide", "vscode", "cursor", "jetbrains", "codex", "android-studio"]
        case .xcodeDerivedData:
            return ["deriveddata", "xcode", "xcode-derived", "dd"]
        case .xcodeArchives:
            return ["archives", "xcode-archives"]
        case .coreSimulator:
            return ["simulator", "simulators", "coresimulator"]
        case .dockerData:
            return ["docker"]
        case .nodeModules:
            return ["node", "modules"]
        case .pythonVirtualEnvs:
            return ["python", "venv", ".venv"]
        case .projectArtifacts:
            return ["artifacts", "project", "build", "dist", "target", "next", "nuxt"]
        case .homebrewCache:
            return ["brew", "homebrew"]
        case .npmCache:
            return ["npm"]
        case .pipCache:
            return ["pip"]
        case .poetryCache:
            return ["poetry"]
        case .yarnCache:
            return ["yarn"]
        case .pnpmStore:
            return ["pnpm"]
        case .cargoCache:
            return ["cargo", "rust"]
        case .nugetCache:
            return ["nuget", ".nuget"]
        case .goCache:
            return ["go", "golang"]
        case .playwrightCache:
            return ["playwright"]
        case .cypressCache:
            return ["cypress"]
        case .gradleCache:
            return ["gradle"]
        case .androidArtifacts:
            return ["android", "avd", "emulator"]
        case .unityCache:
            return ["unity", "unity3d"]
        }
    }

    public var fixedPathsRelativeToHome: [String] {
        switch self {
        case .codeEditors:
            return [
                "Library/Application Support/Code/User/workspaceStorage",
                "Library/Application Support/Cursor/User/workspaceStorage",
                "Library/Application Support/Codex",
                "Library/Caches/JetBrains",
                "Library/Application Support/JetBrains",
                "Library/Logs/JetBrains",
            ]
        case .xcodeDerivedData:
            return ["Library/Developer/Xcode/DerivedData"]
        case .xcodeArchives:
            return ["Library/Developer/Xcode/Archives"]
        case .coreSimulator:
            return ["Library/Developer/CoreSimulator/Devices"]
        case .dockerData:
            return [
                "Library/Containers/com.docker.docker/Data",
                "Library/Group Containers/group.com.docker",
            ]
        case .homebrewCache:
            return ["Library/Caches/Homebrew"]
        case .npmCache:
            return [".npm"]
        case .pipCache:
            return [".cache/pip", "Library/Caches/pip"]
        case .poetryCache:
            return ["Library/Caches/pypoetry", "Library/Application Support/pypoetry"]
        case .yarnCache:
            return [".cache/yarn", "Library/Caches/Yarn"]
        case .pnpmStore:
            return ["Library/pnpm/store", "Library/Caches/pnpm", ".pnpm-store"]
        case .cargoCache:
            return [".cargo/registry", ".cargo/git"]
        case .nugetCache:
            return [".nuget/packages"]
        case .goCache:
            return ["Library/Caches/go-build", "go/pkg/mod/cache", "go/pkg/sumdb"]
        case .playwrightCache:
            return ["Library/Caches/ms-playwright"]
        case .cypressCache:
            return ["Library/Caches/Cypress", "Library/Application Support/Cypress"]
        case .gradleCache:
            return [".gradle/caches"]
        case .androidArtifacts:
            return [".android/avd", ".android/build-cache", "Library/Android"]
        case .unityCache:
            return ["Library/Application Support/unity3d", "Library/Unity"]
        case .nodeModules, .pythonVirtualEnvs, .projectArtifacts:
            return []
        }
    }

    public var usesRecursiveSearch: Bool {
        !recursiveDirectoryNames.isEmpty
    }

    public func groupName(for path: String) -> String? {
        switch self {
        case .codeEditors:
            if path.contains("/Code/") { return "VS Code" }
            if path.contains("/Cursor/") { return "Cursor" }
            if path.contains("/Codex") || path.contains("/.codex") { return "Codex" }
            if path.contains("/JetBrains") { return "JetBrains" }
            if path.contains("AndroidStudio") || path.contains("/Android/") { return "Android Studio" }
            return "Editor Data"
        case .projectArtifacts:
            return URL(fileURLWithPath: path).lastPathComponent
        case .androidArtifacts:
            if path.contains("/avd") { return "Android Emulator" }
            return "Android Shared Data"
        default:
            return nil
        }
    }
}
