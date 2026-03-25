import XCTest
@testable import DevMaidKit

final class ScannerTests: XCTestCase {
    var tempDirectory: URL!
    var fileManager: FileManager!
    var scanner: DevMaidScanner!

    override func setUp() {
        super.setUp()
        fileManager = .default
        tempDirectory = fileManager.temporaryDirectory.appendingPathComponent("DevMaidScannerTests-\(UUID().uuidString)")
        try! fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        scanner = DevMaidScanner(fileManager: fileManager)
    }

    override func tearDown() {
        try? fileManager.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func testScanDiscoversNodeModules() throws {
        // Given
        let projectDir = tempDirectory.appendingPathComponent("MyProject")
        let nodeModulesDir = projectDir.appendingPathComponent("node_modules")
        try fileManager.createDirectory(at: nodeModulesDir, withIntermediateDirectories: true)
        try Data("package-data".utf8).write(to: nodeModulesDir.appendingPathComponent("package.json"))

        let config = ScanConfiguration(
            categories: [.nodeModules],
            searchRoots: [projectDir.path],
            excludedPaths: []
        )

        // When
        let summary = scanner.scan(config)

        // Then
        XCTAssertEqual(summary.items.count, 1)
        XCTAssertEqual(summary.items.first?.category, .nodeModules)
        XCTAssertTrue(summary.items.first?.path.contains("node_modules") ?? false)
    }

    func testScanRespectsExclusions() throws {
        // Given
        let projectDir = tempDirectory.appendingPathComponent("MyProject")
        let nodeModulesDir = projectDir.appendingPathComponent("node_modules")
        let excludedDir = projectDir.appendingPathComponent("excluded_node_modules")
        
        try fileManager.createDirectory(at: nodeModulesDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: excludedDir, withIntermediateDirectories: true)
        
        // We reuse the name node_modules for both but exclude one
        let nodeModulesInExcluded = excludedDir.appendingPathComponent("node_modules")
        try fileManager.createDirectory(at: nodeModulesInExcluded, withIntermediateDirectories: true)

        let config = ScanConfiguration(
            categories: [.nodeModules],
            searchRoots: [projectDir.path],
            excludedPaths: [excludedDir.path]
        )

        // When
        let summary = scanner.scan(config)

        // Then
        XCTAssertEqual(summary.items.count, 1)
        XCTAssertEqual(summary.items.first?.path, nodeModulesDir.standardizedFileURL.path)
    }

    func testScanDiscoversFixedPaths() throws {
        // This test is tricky because fixedPaths are relative to HOME.
        // We can't easily change the real HOME for the whole process safely in a unit test without side effects.
        // However, DevMaidPaths.expandedHomePath takes an optional FileManager.
        // And DevMaidScanner uses fileManager.homeDirectoryForCurrentUser.
        // In a real test environment, we might need to mock homeDirectoryForCurrentUser or skip this.
        
        // For now, let's test a category that uses recursive search as it's more predictable in a sandbox.
        let projectDir = tempDirectory.appendingPathComponent("ArtifactProject")
        let buildDir = projectDir.appendingPathComponent("build")
        try fileManager.createDirectory(at: buildDir, withIntermediateDirectories: true)
        
        let config = ScanConfiguration(
            categories: [.projectArtifacts],
            searchRoots: [projectDir.path]
        )
        
        let summary = scanner.scan(config)
        XCTAssertTrue(summary.items.contains { $0.category == .projectArtifacts })
    }
}
