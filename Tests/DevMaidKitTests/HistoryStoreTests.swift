import XCTest
@testable import DevMaidKit

final class HistoryStoreTests: XCTestCase {
    var tempDirectory: URL!
    var fileManager: FileManager!
    var store: HistoryStore!

    override func setUp() {
        super.setUp()
        fileManager = .default
        tempDirectory = fileManager.temporaryDirectory.appendingPathComponent("DevMaidHistoryTests-\(UUID().uuidString)")
        try! fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        // We initialize the store with a specific baseURL to avoid ~/.devmaid 
        store = HistoryStore(baseURL: tempDirectory, fileManager: fileManager)
    }

    override func tearDown() {
        try? fileManager.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func testCanRecordAndLoadHistory() throws {
        // Given
        let entry1 = HistoryEntry(
            id: "1",
            kind: .delete,
            createdAt: Date(),
            itemCount: 1,
            totalBytes: 1024,
            summary: "Cleanup node_modules"
        )
        
        let entry2 = HistoryEntry(
            id: "2",
            kind: .restore,
            createdAt: Date().addingTimeInterval(10), // second entry is newer
            itemCount: 1,
            totalBytes: 1024,
            summary: "Undone cleanup"
        )

        // When
        try store.record(entry1)
        try store.record(entry2)

        let loaded = try store.load()

        // Then
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].id, "2") // sorted by newer first 
        XCTAssertEqual(loaded[1].id, "1")
    }

    func testEmptyHistoryReturnsEmpty() throws {
        let loaded = try store.load()
        XCTAssertEqual(loaded.count, 0)
    }
}
