import XCTest
@testable import DevMaidKit

final class CleanupCategoryTests: XCTestCase {
    
    func testParseCategory() {
        XCTAssertEqual(CleanupCategory.parse("node-modules"), .nodeModules)
        XCTAssertEqual(CleanupCategory.parse("node"), .nodeModules)
        XCTAssertEqual(CleanupCategory.parse("cargo"), .cargoCache)
        XCTAssertEqual(CleanupCategory.parse(" Rust "), .cargoCache) // alias-based, case-insensitive, trimmed
        XCTAssertNil(CleanupCategory.parse("unknown-category"))
    }

    func testDisplayNameIsConsistent() {
        XCTAssertEqual(CleanupCategory.nodeModules.displayName, "node_modules")
        XCTAssertEqual(CleanupCategory.xcodeDerivedData.displayName, "Xcode DerivedData")
    }

    func testRecursiveTargets() {
        XCTAssertTrue(CleanupCategory.nodeModules.usesRecursiveSearch)
        XCTAssertFalse(CleanupCategory.xcodeDerivedData.usesRecursiveSearch)
        XCTAssertEqual(CleanupCategory.nodeModules.recursiveDirectoryNames, ["node_modules"])
    }
}
