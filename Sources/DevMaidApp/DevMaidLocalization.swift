import Foundation
import DevMaidKit

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case thai = "th"

    var id: String { rawValue }

    var localeIdentifier: String {
        switch self {
        case .english:
            return "en_US"
        case .thai:
            return "th_TH"
        }
    }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .thai:
            return "ไทย"
        }
    }

    var secondaryDisplayName: String {
        switch self {
        case .english:
            return "อังกฤษ"
        case .thai:
            return "Thai"
        }
    }
}

enum DevMaidOperation {
    case scanning
    case quarantining
    case restoring
}

enum DevMaidUpdateState {
    case idle
    case checking
    case upToDate
    case available(AppUpdateRelease)
    case unsupported(AppUpdateRelease)
    case failed(String)
}

struct DevMaidCopy {
    let language: AppLanguage

    private var isThai: Bool { language == .thai }

    var appName: String { "DevMaid" }
    var tagline: String { isThai ? "ตัวช่วยล้างพื้นที่สำหรับนักพัฒนา" : "Storage cleanup for developers" }
    var sidebarTagline: String { isThai ? "ล้างไฟล์ dev แบบเห็นก่อนลบ" : "Preview-first cleanup" }
    var sidebarDetail: String { isThai ? "ทุกอย่างถูกสแกนและติดป้ายความเสี่ยงก่อนย้ายเข้า quarantine" : "Everything is scanned and labeled before DevMaid moves anything into quarantine." }
    var toolbarRunScan: String { isThai ? "เริ่มสแกน" : "Run Scan" }
    var toolbarCancelScan: String { isThai ? "ยกเลิกสแกน" : "Cancel Scan" }
    var toolbarQuarantineSelected: String { isThai ? "กักกันรายการที่เลือก" : "Quarantine Selected" }
    var cancel: String { isThai ? "ยกเลิก" : "Cancel" }
    var menuAbout: String { isThai ? "เกี่ยวกับ DevMaid" : "About DevMaid" }
    var menuCheckForUpdates: String { isThai ? "ตรวจสอบอัปเดต…" : "Check for Updates…" }
    var menuSettings: String { isThai ? "ตั้งค่า…" : "Settings…" }
    var menuNavigate: String { isThai ? "ไปที่" : "Navigate" }
    var menuView: String { isThai ? "มุมมอง" : "View" }
    var menuHelp: String { isThai ? "ช่วยเหลือ" : "Help" }
    var menuToggleSidebar: String { isThai ? "ซ่อนหรือแสดงแถบด้านข้าง" : "Toggle Sidebar" }
    var menuSupport: String { isThai ? "ศูนย์ช่วยเหลือ DevMaid" : "DevMaid Support" }

    var heroBadge: String { isThai ? "ล้างเครื่องสาย dev โดยเฉพาะ" : "Developer-first cleanup" }
    var heroScope: String { "Xcode, Docker, node_modules, .venv" }
    var heroDescription: String {
        isThai
            ? "ดูไฟล์สายพัฒนาที่กินพื้นที่บน Mac ก่อนย้ายอะไรออกจริง DevMaid ทำให้เห็นความเสี่ยงชัด ย้ายเข้า quarantine ก่อน และย้อนคืนได้ง่าย"
            : "Preview the disk-heavy developer junk on your Mac before you move anything. DevMaid keeps the risky parts visible, quarantine-first, and easy to undo."
    }
    var openResults: String { isThai ? "เปิดผลสแกน" : "Open Results" }
    var selectedCategoriesLabel: String { isThai ? "หมวดที่เลือก" : "Selected categories" }
    var scanRootsLabel: String { isThai ? "โฟลเดอร์ที่สแกน" : "Scan roots" }
    var exclusionsLabel: String { isThai ? "รายการยกเว้น" : "Exclusions" }
    var cleanupModeLabel: String { isThai ? "โหมดการล้าง" : "Cleanup mode" }
    var cleanupModeValue: String { isThai ? "กักกันก่อนลบ" : "Quarantine first" }
    var heroFeaturePreview: String { isThai ? "เห็นขนาด หมวด path และระดับความเสี่ยงก่อนย้ายไฟล์ทุกครั้ง" : "See sizes, categories, paths, and risk labels before anything is moved." }
    var heroFeatureSharedEngine: String { isThai ? "ใช้ engine เดียวกันทั้งแอปและ CLI เพื่อให้พฤติกรรมคงที่" : "Use the same cleanup engine in the app and the CLI, so behavior stays predictable." }
    var heroFeatureRestore: String { isThai ? "ย้อนคืน action ก่อนหน้าได้จาก History ทุกเมื่อ" : "Restore earlier actions from History whenever you need to back out a cleanup." }

    var reclaimableStorageTitle: String { isThai ? "พื้นที่ที่คืนได้" : "Reclaimable storage" }
    var reclaimableStorageDetail: String { isThai ? "อ้างอิงจากผลสแกนล่าสุดตามหมวด cleanup ที่คุณเลือก" : "Most recent scan across your selected developer cleanup targets." }
    var itemsFoundTitle: String { isThai ? "รายการที่พบ" : "Items found" }
    var itemsFoundDetail: String { isThai ? "ทุก candidate ถูกแสดงก่อนจะกักกันอะไรออกไป" : "Every cleanup candidate is visible before you quarantine anything." }
    var scanRootsDetail: String { isThai ? "รากโฟลเดอร์ที่รวมอยู่ในการสแกนแบบ recursive ตอนนี้" : "Workspace roots currently included in recursive scanning." }

    var cleanupCategoriesTitle: String { isThai ? "หมวด Cleanup" : "Cleanup Categories" }
    var cleanupCategoriesDetail: String { isThai ? "กดที่การ์ดเพื่อรวมหรือตัดหมวดนี้ออกจากการสแกนรอบถัดไป" : "Click a card to include or exclude it from the next scan." }
    var riskLabelsTitle: String { isThai ? "ระดับความเสี่ยง" : "Risk labels" }
    var recentActivityTitle: String { isThai ? "กิจกรรมล่าสุด" : "Recent activity" }
    var noRecentActivity: String { isThai ? "ยังไม่มีประวัติการล้าง เริ่มสแกน ตรวจรายการ แล้วค่อยกักกันเมื่อพร้อม" : "No cleanup history yet. Run a scan, review the results, and quarantine selected items when you're ready." }
    var overviewActionsTitle: String { isThai ? "ทางลัดที่แนะนำ" : "Recommended next steps" }
    var overviewActionsDetail: String { isThai ? "เริ่มจากการสแกนก่อน แล้วค่อยไล่ review หรือปรับ coverage ตาม workflow ของคุณ" : "Start with a scan, then review the findings or tune coverage for your workflow." }
    var overviewActionScanTitle: String { isThai ? "สแกนเครื่องรอบถัดไป" : "Run the next scan" }
    var overviewActionScanDetail: String { isThai ? "ใช้ search roots และหมวดที่เลือกตอนนี้เพื่อดึงภาพรวมล่าสุดของ dev junk บนเครื่อง" : "Use the current scan roots and selected categories to refresh the latest view of reclaimable dev junk." }
    var overviewActionResultsTitle: String { isThai ? "รีวิวก่อนกักกัน" : "Review before quarantine" }
    var overviewActionResultsDetail: String { isThai ? "เปิดผลสแกนเพื่อตรวจ path, risk label และเลือกเฉพาะรายการที่พร้อมย้ายเข้า quarantine" : "Open the results to inspect paths, risk labels, and select only the items you want to quarantine." }
    var overviewActionSettingsTitle: String { isThai ? "ปรับ coverage ให้เหมาะ" : "Tune your coverage" }
    var overviewActionSettingsDetail: String { isThai ? "เช็ก exclusions, scan roots และค่า safety defaults ก่อน cleanup รอบจริง" : "Review exclusions, scan roots, and safety defaults before your next real cleanup pass." }

    var visibleItemsLabel: String { isThai ? "รายการที่มองเห็น" : "Visible items" }
    var visibleSizeLabel: String { isThai ? "ขนาดที่มองเห็น" : "Visible size" }
    var selectedLabel: String { isThai ? "ที่เลือก" : "Selected" }
    var groupedByProjectLabel: String { isThai ? "กลุ่มที่มองเห็น" : "Visible groups" }
    var warningsTitle: String { isThai ? "คำเตือน" : "Warnings" }
    var reviewCleanupTitle: String { isThai ? "ยืนยันการกักกัน" : "Review cleanup" }
    var quarantineAction: String { isThai ? "ย้ายเข้า Quarantine" : "Quarantine" }
    var dangerousCleanupTitle: String { isThai ? "รายการเสี่ยงต้องยืนยันอีกครั้ง" : "Dangerous cleanup requires another check" }
    var dangerQuarantineAction: String { isThai ? "กักกันรายการเสี่ยง" : "Quarantine Danger Items" }
    func cleanupConfirmationMessage(count: Int) -> String {
        isThai
            ? "ย้าย \(count) รายการเข้า quarantine ใช่ไหม คุณย้อนคืนได้ภายหลังจาก History"
            : "Move \(count) item(s) into quarantine? You can undo this later from History."
    }
    var dangerConfirmationMessage: String {
        isThai
            ? "รายการที่คุณเลือกมีหมวดเสี่ยง เช่น Docker data DevMaid จะย้ายเข้า quarantine ก่อนเหมือนเดิม แต่ควรยืนยันอีกครั้งก่อนดำเนินการ"
            : "Your selection includes danger-labeled items such as Docker data. DevMaid will still quarantine them first, but you should confirm before proceeding."
    }
    var scanResultsTitle: String { isThai ? "ผลการสแกน" : "Scan Results" }
    var itemColumnTitle: String { isThai ? "รายการ" : "Item" }
    var actionsColumnTitle: String { isThai ? "การทำงาน" : "Actions" }
    func latestCleanupStats(items: Int, bytes: String) -> String {
        isThai ? "\(items) รายการ • \(bytes)" : "\(items) item(s) • \(bytes)"
    }
    func visibleSummary(count: Int, bytes: String) -> String {
        isThai ? "พบ \(count) รายการ • \(bytes)" : "\(count) visible item(s) • \(bytes)"
    }
    func progressTitle(for operation: DevMaidOperation?) -> String {
        switch operation {
        case .scanning:
            return isThai ? "กำลังสแกน…" : "Scanning…"
        case .quarantining:
            return isThai ? "กำลังกักกัน…" : "Quarantining…"
        case .restoring:
            return isThai ? "กำลังกู้คืน…" : "Restoring…"
        case nil:
            return ""
        }
    }
    var filterPlaceholder: String { isThai ? "ค้นหาจาก path หรือ note" : "Filter by path or note" }
    var categoryFilterLabel: String { isThai ? "หมวด" : "Category" }
    var allCategories: String { isThai ? "ทุกหมวด" : "All categories" }
    var riskFilterLabel: String { isThai ? "ความเสี่ยง" : "Risk" }
    var allRisk: String { isThai ? "ทุกระดับ" : "All risk" }
    var sortLabel: String { isThai ? "เรียง" : "Sort" }
    var emptyResultsBeforeScan: String { isThai ? "เริ่มสแกนเพื่อดูรายการที่ล้างได้" : "Run a scan to see your cleanup candidates." }
    var emptyResultsFiltered: String { isThai ? "ไม่มีรายการที่ตรงกับ filter ตอนนี้" : "No results match the current filters." }
    var emptyResultsDetail: String { isThai ? "DevMaid จะแสดงทุกอย่างก่อนเสมอ ก่อนย้ายอะไรเข้า quarantine" : "DevMaid always shows what it finds before anything is quarantined." }
    var resultsWorkflowTitle: String { isThai ? "workflow ที่แนะนำ" : "Recommended workflow" }
    var resultsWorkflowDetail: String { isThai ? "สแกน ตรวจ แล้วค่อยกักกันเป็นชุด" : "Scan, review, then quarantine in batches." }
    var resultsWorkflowScanDetail: String { isThai ? "ดึงภาพรวมล่าสุด" : "Refresh the latest scan" }
    func resultsWorkflowReviewDetail(count: Int, bytes: String) -> String {
        isThai ? "กำลังเห็น \(count) รายการ • \(bytes)" : "\(count) visible • \(bytes)"
    }
    var resultsWorkflowQuarantineDetail: String { isThai ? "ย้ายชุดที่พร้อมก่อน" : "Quarantine the ready batch" }
    var emptyResultsSettingsHint: String { isThai ? "เปิด Settings" : "Open Settings" }
    var groupedResultsTitle: String { isThai ? "กลุ่มที่เด่นที่สุดตอนนี้" : "Largest visible groups" }
    var groupedResultsDetail: String { isThai ? "ดูเร็วว่าพื้นที่ส่วนใหญ่กองอยู่ที่กลุ่มไหน" : "See which groups dominate the result set." }
    var inspectorTitle: String { isThai ? "ตัวตรวจสอบ" : "Inspector" }
    var inspectorEmpty: String { isThai ? "เลือกรายการอย่างน้อยหนึ่งรายการเพื่อดูผลกระทบ ระดับความเสี่ยง และ path แบบเต็ม" : "Select one or more items to inspect the cleanup impact, risk label, and exact path." }
    var pathTitle: String { isThai ? "Path" : "Path" }
    var cleanupNoteTitle: String { isThai ? "หมายเหตุการล้าง" : "Cleanup note" }
    var riskGuidanceTitle: String { isThai ? "คำแนะนำความเสี่ยง" : "Risk guidance" }
    var batchCleanupTitle: String { isThai ? "ล้างหลายรายการ" : "Batch cleanup" }
    func selectedItemsTitle(count: Int) -> String {
        isThai ? "เลือกอยู่ \(count) รายการ" : "\(count) item(s) selected"
    }
    var batchCleanupDetail: String { isThai ? "DevMaid จะย้ายรายการเหล่านี้เข้า quarantine ก่อน และคุณกู้คืนได้ภายหลังจาก History" : "DevMaid will move these items into quarantine first. You can restore them later from History." }
    var mixedRiskSelectionDetail: String { isThai ? "มีหลายระดับความเสี่ยงในชุดเดียวกัน" : "This selection mixes multiple risk levels." }
    var uniformRiskSelectionDetail: String { isThai ? "ชุดนี้กักกันพร้อมกันได้ค่อนข้างมั่นใจ" : "This batch is consistent enough to quarantine together." }
    func itemsCountLabel(_ count: Int) -> String {
        isThai ? "\(count) รายการ" : "\(count) items"
    }

    var historyTitle: String { isThai ? "ประวัติ" : "History" }
    var historyTimelineTitle: String { isThai ? "ไทม์ไลน์การล้างล่าสุด" : "Recent cleanup timeline" }
    var historyTimelineDetail: String { isThai ? "เลือก action เพื่อดูสิ่งที่ย้ายเข้า quarantine และกู้คืนกลับได้เมื่อจำเป็น" : "Select an action to inspect what moved into quarantine and restore it when needed." }
    var restoreAction: String { isThai ? "กู้คืน Action นี้" : "Restore Action" }
    var itemsMetricTitle: String { isThai ? "รายการ" : "Items" }
    var itemsMetricDetail: String { isThai ? "จำนวน object ที่อยู่ใน action นี้" : "Objects tracked in this action." }
    var bytesMetricTitle: String { isThai ? "ขนาด" : "Bytes" }
    var bytesMetricDetail: String { isThai ? "ขนาดรวมที่บันทึกไว้ใน manifest" : "Total footprint recorded in the action manifest." }
    var manifestItemsTitle: String { isThai ? "รายการใน Manifest" : "Manifest items" }
    var manifestItemsDetail: String { isThai ? "ดู path เดิม หมวด และระดับความเสี่ยงของรายการที่อยู่ใน action นี้" : "Review the original paths, categories, and risk labels stored in this action." }
    var noManifestPreview: String { isThai ? "ไม่มี manifest preview สำหรับ history รายการนี้" : "No manifest preview available for this history entry." }
    var sourceActionPrefix: String { isThai ? "อ้างอิงจาก action:" : "Source action:" }
    var historyEmpty: String { isThai ? "เลือก history entry เพื่อดูรายละเอียดหรือกู้คืน action การล้าง" : "Select a history entry to inspect it or restore a cleanup action." }
    var selectionImpactTitle: String { isThai ? "ผลกระทบของชุดที่เลือก" : "Selection impact" }
    var riskMixTitle: String { isThai ? "ระดับความเสี่ยงในชุดนี้" : "Risk mix" }
    var topCategoriesTitle: String { isThai ? "หมวดที่เด่นในชุดนี้" : "Top categories in this batch" }
    var noSelectionYetTitle: String { isThai ? "ยังไม่ได้เลือกรายการ" : "No selection yet" }
    var selectedPathTitle: String { isThai ? "รายการที่เลือกอยู่" : "Current selection" }

    var settingsTitle: String { isThai ? "การตั้งค่า" : "Settings" }
    var settingsHeroBadge: String { isThai ? "ศูนย์ควบคุมการทำงาน" : "Control center" }
    var settingsHeroDetail: String { isThai ? "ปรับ coverage, ความปลอดภัย, ภาษา, อัปเดต และลิงก์ช่วยเหลือของ DevMaid จากจุดเดียว" : "Tune DevMaid's coverage, safety defaults, language, updates, and support links from one place." }
    var notificationsTitle: String { isThai ? "การแจ้งเตือนอัจฉริยะ" : "Smart alerts" }
    var notificationsDetail: String { isThai ? "แจ้งเตือนเมื่อพื้นที่ว่างต่ำเกินไป หรือเมื่อรอบสแกนล่าสุดพบ reclaimable storage เพิ่มขึ้นมากผิดปกติ" : "Get notified when free space drops too low or when a scan finds an unusual reclaimable-storage spike." }
    var notificationsEnabledTitle: String { isThai ? "เปิดการแจ้งเตือนภายในเครื่อง" : "Enable local notifications" }
    var freeSpaceThresholdTitle: String { isThai ? "เตือนเมื่อพื้นที่ว่างต่ำกว่า" : "Alert when free space falls below" }
    var reclaimableSpikeThresholdTitle: String { isThai ? "เตือนเมื่อ reclaimable storage เพิ่มขึ้นเกิน" : "Alert when reclaimable storage jumps by" }
    var thresholdUnitGB: String { isThai ? "GB" : "GB" }
    var weeklyTrendTitle: String { isThai ? "แนวโน้ม 7 สแกนล่าสุด" : "Latest 7-scan trend" }
    var weeklyTrendDetail: String { isThai ? "ดู reclaimable storage และการเปลี่ยนแปลงพื้นที่ใช้จริงจากประวัติในเครื่องเท่านั้น" : "Compare reclaimable storage and used-space drift from local scan history only." }
    var reclaimableDeltaTitle: String { isThai ? "การเปลี่ยนแปลงที่ล้างได้" : "Reclaimable delta" }
    var usedSpaceDeltaTitle: String { isThai ? "การเปลี่ยนแปลงพื้นที่ใช้จริง" : "Used-space delta" }
    var noTrendData: String { isThai ? "ยังมีข้อมูลไม่พอสำหรับแนวโน้ม รันสแกนเพิ่มอีกสักสองสามครั้งแล้ว DevMaid จะเริ่มเล่า trend ให้เห็น" : "Not enough scans yet for a useful trend. Run a few more scans and DevMaid will start showing the pattern." }
    var updatesTitle: String { isThai ? "อัปเดต" : "Updates" }
    var updatesDetail: String { isThai ? "เช็กเวอร์ชันล่าสุดจาก update feed แล้วเปิดหน้าโหลดเมื่อมีรุ่นใหม่พร้อมใช้งาน" : "Check the latest version from your update feed and jump straight to the download page when a newer build is ready." }
    var checkForUpdatesAction: String { isThai ? "เช็กอัปเดต" : "Check for Updates" }
    var checkingForUpdates: String { isThai ? "กำลังเช็กอัปเดต…" : "Checking for updates…" }
    var downloadUpdateAction: String { isThai ? "ดาวน์โหลดอัปเดต" : "Download Update" }
    var releaseNotesAction: String { isThai ? "ดูบันทึกการเปลี่ยนแปลง" : "Release Notes" }
    var autoCheckUpdates: String { isThai ? "เช็กอัปเดตอัตโนมัติเมื่อเปิดแอป" : "Check for updates automatically on launch" }
    var autoCheckUpdatesDetail: String { isThai ? "DevMaid จะเช็กแบบเงียบ ๆ ไม่เกินทุก 12 ชั่วโมง" : "DevMaid performs a quiet launch check no more than once every 12 hours." }
    var currentVersionLabel: String { isThai ? "เวอร์ชันปัจจุบัน" : "Current version" }
    var latestVersionLabel: String { isThai ? "เวอร์ชันล่าสุด" : "Latest version" }
    var lastCheckedLabel: String { isThai ? "เช็กล่าสุด" : "Last checked" }
    var updateFeedLabel: String { isThai ? "Update feed" : "Update feed" }
    var updateStatusIdle: String { isThai ? "ยังไม่ได้เช็กอัปเดต" : "No update check yet" }
    var updateStatusChecking: String { isThai ? "กำลังตรวจสอบเวอร์ชันล่าสุด" : "Checking the latest release now." }
    var updateStatusCurrent: String { isThai ? "คุณใช้เวอร์ชันล่าสุดอยู่แล้ว" : "You're already on the latest version." }
    func updateStatusAvailable(version: String) -> String {
        isThai ? "มีเวอร์ชันใหม่ \(version) พร้อมดาวน์โหลด" : "Version \(version) is ready to download."
    }
    func updateStatusUnsupported(version: String) -> String {
        isThai ? "มีเวอร์ชันใหม่ \(version) แต่ต้องใช้ macOS รุ่นใหม่กว่า" : "Version \(version) is available, but it needs a newer macOS release."
    }
    func updateStatusFailed(_ message: String) -> String {
        isThai ? "เช็กอัปเดตไม่สำเร็จ: \(message)" : "Update check failed: \(message)"
    }
    var updateCurrentBadge: String { isThai ? "ล่าสุด" : "Current" }
    var updateAvailableBadge: String { isThai ? "มีอัปเดต" : "Update available" }
    var updateUnsupportedBadge: String { isThai ? "ต้องอัปเกรด macOS" : "Requires newer macOS" }
    var updateErrorBadge: String { isThai ? "เช็กไม่สำเร็จ" : "Check failed" }
    var updateIdleBadge: String { isThai ? "พร้อมเช็ก" : "Ready to check" }
    var languageTitle: String { isThai ? "ภาษา" : "Language" }
    var languageDetail: String { isThai ? "สลับภาษา UI ของแอประหว่างไทยและอังกฤษได้ทันที" : "Switch the app interface between Thai and English instantly." }
    var onboardingTitle: String { isThai ? "เริ่มต้นใช้งาน DevMaid" : "Welcome to DevMaid" }
    var onboardingDetail: String { isThai ? "ตั้งค่าเบื้องต้นให้พร้อมก่อนสแกนจริง เพื่อให้การล้างปลอดภัย เข้าใจง่าย และได้ coverage ดีสุดบน macOS" : "Set up the essentials before your first real scan so cleanup stays safe, clear, and fully covered on macOS." }
    var onboardingStepOneTitle: String { isThai ? "1. ให้สิทธิ์ Full Disk Access" : "1. Grant Full Disk Access" }
    var onboardingStepOneDetail: String { isThai ? "เพื่อให้สแกน Xcode, Simulator, editor caches และไฟล์ dev junk ได้ครบกว่าเดิม" : "This improves coverage for Xcode, Simulator, editor caches, and other protected developer junk." }
    var onboardingStepTwoTitle: String { isThai ? "2. เช็ก scan roots กับ exclusions" : "2. Review scan roots and exclusions" }
    var onboardingStepTwoDetail: String { isThai ? "เลือก workspace ที่ควรสแกน และเพิ่ม project/path ที่ไม่อยากให้แตะไว้ในรายการยกเว้น" : "Choose the workspaces to scan, then add any projects or paths you never want touched to the exclusion list." }
    var onboardingStepThreeTitle: String { isThai ? "3. ทุกอย่างยัง preview-first" : "3. Everything stays preview-first" }
    var onboardingStepThreeDetail: String { isThai ? "DevMaid จะให้คุณเห็นก่อนลบเสมอ ย้ายเข้า quarantine ก่อน และ undo ได้จาก History" : "DevMaid always lets you review first, quarantines instead of hard deleting, and supports undo from History." }
    var onboardingPrimaryAction: String { isThai ? "เปิด Privacy & Security" : "Open Privacy & Security" }
    var onboardingSecondaryAction: String { isThai ? "เริ่มใช้งาน" : "Start using DevMaid" }
    var onboardingOpenSettingsAction: String { isThai ? "ไปที่ Settings" : "Go to Settings" }
    var onboardingChecklistTitle: String { isThai ? "ก่อนเริ่มสแกนครั้งแรก" : "Before your first scan" }
    var onboardingChecklistDetail: String { isThai ? "เช็ก 3 จุดนี้ก่อน แล้วประสบการณ์รอบแรกจะลื่นและปลอดภัยกว่ามาก" : "Check these three things first and your first cleanup pass will feel much smoother and safer." }
    var reopenOnboardingAction: String { isThai ? "เปิดคู่มือเริ่มต้นอีกครั้ง" : "Reopen welcome guide" }
    var scanRootsTitle: String { isThai ? "โฟลเดอร์ที่ใช้สแกน" : "Scan roots" }
    var scanRootsDescription: String { isThai ? "DevMaid จะสแกนรากโฟลเดอร์เหล่านี้เพื่อหา target แบบ recursive อย่าง `node_modules`, `.venv`, `build`, `dist` และ `.next`" : "DevMaid scans these workspace roots for recursive targets like `node_modules`, `.venv`, `build`, `dist`, and `.next`." }
    var addRoot: String { isThai ? "เพิ่มโฟลเดอร์" : "Add Root" }
    var removeSelectedRoot: String { isThai ? "ลบที่เลือก" : "Remove Selected" }
    var resetDefaults: String { isThai ? "คืนค่าเริ่มต้น" : "Reset Defaults" }
    var exclusionsTitle: String { isThai ? "รายการยกเว้น" : "Exclusions" }
    var exclusionsDescription: String { isThai ? "Path ในรายการนี้จะไม่ถูกสแกนและจะไม่โผล่ใน cleanup results ทั้งในแอปและ CLI เมื่อใช้ค่าเดียวกัน" : "Paths in this list are skipped during scanning and will never appear in cleanup results when the same config is used in the app or CLI." }
    var addExclusion: String { isThai ? "เพิ่มรายการยกเว้น" : "Add Exclusion" }
    var removeSelectedExclusion: String { isThai ? "ลบที่เลือก" : "Remove Selected" }
    var clearExclusions: String { isThai ? "ล้างทั้งหมด" : "Clear All" }
    var noExclusions: String { isThai ? "ยังไม่มี path ที่ถูกยกเว้น ตอนนี้ DevMaid จะสแกนทุก search root ที่เลือกไว้" : "No exclusions yet. DevMaid will scan everything under your chosen search roots." }
    var safetyDefaultsTitle: String { isThai ? "ค่าความปลอดภัย" : "Safety defaults" }
    var askBeforeQuarantine: String { isThai ? "ถามก่อนกักกันรายการที่เลือก" : "Ask before quarantining selected items" }
    var requireDangerConfirmation: String { isThai ? "ให้ยืนยันเพิ่มเมื่อมีรายการ danger" : "Require an extra confirmation for danger-labeled items" }
    var safetyDefaultsDetail: String { isThai ? "GUI นี้จะผ่าน quarantine ก่อนเสมอ และไม่มี direct-delete path" : "Cleanup always goes through quarantine first. DevMaid does not add a direct-delete path in the GUI." }
    var fullDiskAccessTitle: String { isThai ? "Full Disk Access" : "Full Disk Access" }
    var fullDiskAccessDescription: String { isThai ? "ถ้าจะให้สแกนได้ครบบน macOS ควรให้สิทธิ์ Full Disk Access กับแอป หรือกับ Terminal เมื่อต้องใช้ CLI" : "For complete scan coverage on macOS, grant Full Disk Access to the app or to Terminal when you use the CLI." }
    var fullDiskAccessSteps: String {
        isThai
            ? "1. เปิด System Settings\n2. ไปที่ Privacy & Security\n3. เปิด Full Disk Access\n4. เพิ่ม DevMaid หรือ Terminal"
            : "1. Open System Settings\n2. Go to Privacy & Security\n3. Open Full Disk Access\n4. Add DevMaid or Terminal"
    }
    var startupItemsTitle: String { isThai ? "Startup Items" : "Startup items" }
    var startupItemsDetail: String { isThai ? "ดูรายการเปิดอัตโนมัติเมื่อ login และจัดการรายการที่ DevMaid ควบคุมได้อย่างปลอดภัย" : "Inspect login items and manage the startup entry that DevMaid can safely control." }
    var startupItemsFilterLabel: String { isThai ? "แสดง" : "Show" }
    var startupItemsAllFilter: String { isThai ? "ทั้งหมด" : "All items" }
    var startupItemsManageableFilter: String { isThai ? "เฉพาะที่จัดการได้" : "Manageable only" }
    var startupManagedBadge: String { isThai ? "จัดการได้" : "Manageable" }
    var startupReadOnlyBadge: String { isThai ? "อ่านอย่างเดียว" : "Read only" }
    var startupEnableAction: String { isThai ? "เปิดใช้งาน" : "Enable" }
    var startupDisableAction: String { isThai ? "ปิดใช้งาน" : "Disable" }
    var startupRefreshAction: String { isThai ? "รีเฟรชรายการ" : "Refresh items" }
    var startupNoItems: String { isThai ? "ยังไม่พบ startup item ที่อ่านได้ในเครื่องนี้" : "No readable startup items were found on this Mac yet." }
    var supportDeveloperTitle: String { isThai ? "สนับสนุนนักพัฒนา" : "Support the developer" }
    var website: String { isThai ? "เว็บไซต์" : "Website" }
    var support: String { isThai ? "ซัพพอร์ต" : "Support" }
    var sponsor: String { isThai ? "สนับสนุน" : "Sponsor" }
    var security: String { isThai ? "แจ้งปัญหาความปลอดภัย" : "Security" }
    var supportDeveloperDetail: String { isThai ? "ลิงก์สนับสนุนควรอยู่ใน Settings และ About เพื่อให้เห็นง่ายโดยไม่ไปรบกวน flow การล้าง" : "Keep support links here and in About so they stay visible without interrupting cleanup flows." }
    var privacyPolicyTitle: String { isThai ? "นโยบายความเป็นส่วนตัว" : "Privacy policy" }
    var privacyPolicyDetail: String { isThai ? "DevMaid เก็บข้อมูล scan/history ไว้ในเครื่องเท่านั้น และตอนนี้ยังไม่มี telemetry ภายนอก" : "DevMaid keeps scan and history data on-device, and this build does not include external telemetry." }
    var openPrivacyPolicyAction: String { isThai ? "เปิดไฟล์ Privacy" : "Open Privacy file" }

    var aboutDescription: String { isThai ? "ล้าง Xcode, Docker, node_modules, virtual environments, browser-test caches และไฟล์ dev อื่น ๆ แบบเห็นก่อนลบ" : "Preview-first cleanup for Xcode, Docker, node_modules, virtual environments, browser-test caches, and the other storage problems that hit developer Macs hardest." }
    var aboutHeroBadge: String { isThai ? "แจกฟรีสำหรับสายพัฒนา" : "Free developer utility" }
    var aboutHeroDetail: String { isThai ? "DevMaid คือ native Mac app ที่ใช้ shared cleanup engine เดียวกับ CLI และออกแบบมาให้ล้างแบบ preview-first, quarantine-first, undo ได้จริง" : "DevMaid is a native Mac app powered by the same shared cleanup engine as the CLI, built around preview-first, quarantine-first cleanup with real undo support." }
    var versionTitle: String { isThai ? "เวอร์ชัน" : "Version" }
    var versionDetail: String { isThai ? "เดสก์ท็อป GUI ที่ใช้ shared cleanup engine เดียวกับ CLI" : "Desktop GUI powered by the same shared cleanup engine as the CLI." }
    var cliTitle: String { "CLI" }
    var cliDetail: String { isThai ? "ใช้ engine เดียวกันและคงพฤติกรรม quarantine-first" : "Same engine, same quarantine-first behavior." }
    var linksTitle: String { isThai ? "ลิงก์" : "Links" }
    var repository: String { isThai ? "รีโพซิทอรี" : "Repository" }
    var acknowledgementsTitle: String { isThai ? "ขอบคุณและเครดิต" : "Acknowledgements" }
    var acknowledgementsDetail: String { isThai ? "สร้างด้วย Swift, SwiftUI, Swift Package Manager และ framework ของ macOS โดย logic การล้างถูกแชร์ร่วมกันระหว่างเดสก์ท็อปแอปกับ CLI เพื่อให้พฤติกรรมคาดเดาได้" : "Built with Swift, SwiftUI, Swift Package Manager, and macOS system frameworks. Cleanup logic is shared across the desktop app and the CLI so behavior stays predictable." }

    var quickActionsTitle: String { isThai ? "การกระทำด่วน" : "Quick actions" }
    var showInFinderAction: String { isThai ? "เปิดใน Finder" : "Show in Finder" }
    var openInTerminalAction: String { isThai ? "เปิดใน Terminal" : "Open in Terminal" }
    var selectionActionsTitle: String { isThai ? "การเลือกแบบด่วน" : "Selection shortcuts" }
    var selectAllVisibleAction: String { isThai ? "เลือกทั้งหมดที่มองเห็น" : "Select all visible" }
    var clearSelectionAction: String { isThai ? "ล้างรายการที่เลือก" : "Clear selection" }
    var selectSafeAction: String { isThai ? "เลือกเฉพาะ safe" : "Select safe" }
    var selectReviewAction: String { isThai ? "เลือกเฉพาะ review" : "Select review" }
    var selectDangerAction: String { isThai ? "เลือกเฉพาะ danger" : "Select danger" }
    var selectLargeItemsAction: String { isThai ? "เลือก 1 GB ขึ้นไป" : "Select 1 GB+" }
    var exportScanAction: String { isThai ? "ส่งออกผลสแกน" : "Export scan" }
    var exportHistoryAction: String { isThai ? "ส่งออกประวัติ" : "Export history" }
    var groupTitle: String { isThai ? "กลุ่ม" : "Group" }
    var skippedRestoreBanner: String { isThai ? "บางรายการกู้คืนไม่ได้เพราะตำแหน่งเดิมมีไฟล์อยู่แล้ว" : "Some restored items were skipped because the original location already exists." }
    func scanFinishedMessage(items: Int, bytes: String) -> String {
        isThai ? "สแกนเสร็จ พบ \(items) รายการ คืนพื้นที่ได้ \(bytes)" : "Scan finished with \(items) item(s) and \(bytes) reclaimable."
    }
    var scanCanceledMessage: String { isThai ? "ยกเลิกการสแกนแล้ว" : "Scan canceled." }
    func quarantinedMessage(items: Int, actionID: String) -> String {
        isThai ? "ย้าย \(items) รายการเข้า quarantine แล้ว (\(actionID))" : "Quarantined \(items) item(s) into \(actionID)."
    }
    func restoredMessage(items: Int, actionID: String) -> String {
        isThai ? "กู้คืน \(items) รายการจาก \(actionID) แล้ว" : "Restored \(items) item(s) from \(actionID)."
    }
    func addedScanRootMessage(path: String) -> String {
        isThai ? "เพิ่ม scan root แล้ว: \(path)" : "Added scan root \(path)."
    }
    func exportSavedMessage(path: String) -> String {
        isThai ? "บันทึกไฟล์ส่งออกแล้ว: \(path)" : "Saved export to \(path)."
    }
    var updatedScanRootsMessage: String { isThai ? "อัปเดตรายการ scan root แล้ว" : "Updated scan roots." }
    var resetScanRootsMessage: String { isThai ? "รีเซ็ต scan root กลับเป็นค่าเริ่มต้นแล้ว" : "Reset search roots to defaults." }
    var addRootPrompt: String { isThai ? "เพิ่มโฟลเดอร์" : "Add Root" }
    var addRootMessage: String { isThai ? "เลือกโฟลเดอร์ที่ DevMaid ควรสแกนแบบ recursive เพื่อหาไฟล์ dev junk" : "Choose a folder DevMaid should scan recursively for developer junk." }
    var addExclusionPrompt: String { isThai ? "เพิ่มรายการยกเว้น" : "Add Exclusion" }
    var addExclusionMessage: String { isThai ? "เลือก path ที่ DevMaid ไม่ควรสแกนหรือแสดงใน cleanup results" : "Choose a path DevMaid should never scan or show in cleanup results." }
    func addedExclusionMessage(path: String) -> String {
        isThai ? "เพิ่มรายการยกเว้นแล้ว: \(path)" : "Added exclusion \(path)."
    }
    var updatedExclusionsMessage: String { isThai ? "อัปเดตรายการยกเว้นแล้ว" : "Updated exclusions." }
    var clearedExclusionsMessage: String { isThai ? "ล้างรายการยกเว้นทั้งหมดแล้ว" : "Cleared all exclusions." }
    var startupEnabledMessage: String { isThai ? "เปิดให้ DevMaid เริ่มทำงานตอน login แล้ว" : "DevMaid will now launch at login." }
    var startupDisabledMessage: String { isThai ? "ปิดการเริ่ม DevMaid ตอน login แล้ว" : "DevMaid will no longer launch at login." }
    var lowSpaceAlertTitle: String { isThai ? "พื้นที่ Mac ใกล้เต็ม" : "Mac storage is getting tight" }
    func lowSpaceAlertBody(free: String) -> String {
        isThai ? "เหลือพื้นที่ว่างประมาณ \(free) DevMaid แนะนำให้เปิดแอปมาตรวจรายการที่ล้างได้" : "Only about \(free) is left free. Open DevMaid to review cleanup candidates."
    }
    var reclaimableSpikeAlertTitle: String { isThai ? "พบไฟล์ล้างได้เพิ่มขึ้นมาก" : "Reclaimable storage jumped" }
    func reclaimableSpikeAlertBody(delta: String) -> String {
        isThai ? "รอบสแกนล่าสุดพบ reclaimable storage เพิ่มขึ้น \(delta) ลองเปิด DevMaid เพื่อตรวจรายการใหม่" : "The latest scan found \(delta) more reclaimable storage. Open DevMaid to review the new candidates."
    }

    func updateStatusText(for state: DevMaidUpdateState) -> String {
        switch state {
        case .idle:
            return updateStatusIdle
        case .checking:
            return updateStatusChecking
        case .upToDate:
            return updateStatusCurrent
        case .available(let release):
            return updateStatusAvailable(version: release.displayVersion)
        case .unsupported(let release):
            return updateStatusUnsupported(version: release.displayVersion)
        case .failed(let message):
            return updateStatusFailed(message)
        }
    }

    func updateBadgeTitle(for state: DevMaidUpdateState) -> String {
        switch state {
        case .idle:
            return updateIdleBadge
        case .checking:
            return checkingForUpdates
        case .upToDate:
            return updateCurrentBadge
        case .available:
            return updateAvailableBadge
        case .unsupported:
            return updateUnsupportedBadge
        case .failed:
            return updateErrorBadge
        }
    }
}

extension DevMaidDestination {
    func title(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.overview, .english): return "Overview"
        case (.overview, .thai): return "ภาพรวม"
        case (.results, .english): return "Results"
        case (.results, .thai): return "ผลสแกน"
        case (.history, .english): return "History"
        case (.history, .thai): return "ประวัติ"
        case (.settings, .english): return "Settings"
        case (.settings, .thai): return "ตั้งค่า"
        case (.about, .english): return "About"
        case (.about, .thai): return "เกี่ยวกับ"
        }
    }
}

extension ScanSortOption {
    func title(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.sizeDescending, .english): return "Largest first"
        case (.sizeDescending, .thai): return "ใหญ่สุดก่อน"
        case (.sizeAscending, .english): return "Smallest first"
        case (.sizeAscending, .thai): return "เล็กสุดก่อน"
        case (.pathAscending, .english): return "Path A-Z"
        case (.pathAscending, .thai): return "Path A-Z"
        case (.riskDescending, .english): return "Risk first"
        case (.riskDescending, .thai): return "เสี่ยงสุดก่อน"
        }
    }
}

extension StartupItemsFilter {
    func title(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.all, .english): return "All items"
        case (.all, .thai): return "ทั้งหมด"
        case (.manageableOnly, .english): return "Manageable only"
        case (.manageableOnly, .thai): return "เฉพาะที่จัดการได้"
        }
    }
}

extension RiskLevel {
    func localizedDisplayName(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.safe, .english): return "Safe"
        case (.safe, .thai): return "ปลอดภัย"
        case (.review, .english): return "Review"
        case (.review, .thai): return "ควรเช็ก"
        case (.danger, .english): return "Danger"
        case (.danger, .thai): return "เสี่ยง"
        }
    }

    func localizedDetail(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.safe, .english):
            return "Usually safe to remove. It can be recreated later when tools need it."
        case (.safe, .thai):
            return "โดยทั่วไปลบได้ค่อนข้างปลอดภัย และระบบจะสร้างใหม่ได้เมื่อเครื่องมือต้องใช้"
        case (.review, .english):
            return "Usually recoverable, but double-check if you rely on local state."
        case (.review, .thai):
            return "มักสร้างกลับได้ แต่ควรเช็กก่อนถ้าคุณพึ่งพา state ในเครื่อง"
        case (.danger, .english):
            return "Can affect active development environments or data you may want to keep."
        case (.danger, .thai):
            return "อาจกระทบ environment ที่กำลังใช้งานอยู่หรือข้อมูลที่คุณยังต้องเก็บไว้"
        }
    }
}

extension HistoryActionKind {
    func localizedDisplayName(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.delete, .english): return "Cleanup"
        case (.delete, .thai): return "การล้าง"
        case (.restore, .english): return "Restore"
        case (.restore, .thai): return "การกู้คืน"
        }
    }
}

extension CleanupCategory {
    func localizedDisplayName(in language: AppLanguage) -> String {
        guard language == .thai else { return displayName }
        switch self {
        case .codeEditors: return "Code Editors"
        case .xcodeDerivedData: return "Xcode DerivedData"
        case .xcodeArchives: return "Xcode Archives"
        case .coreSimulator: return "CoreSimulator"
        case .dockerData: return "Docker Data"
        case .nodeModules: return "node_modules"
        case .pythonVirtualEnvs: return "Python Envs"
        case .projectArtifacts: return "Project Artifacts"
        case .homebrewCache: return "Homebrew Cache"
        case .npmCache: return "npm Cache"
        case .pipCache: return "pip Cache"
        case .poetryCache: return "Poetry Cache"
        case .yarnCache: return "Yarn Cache"
        case .pnpmStore: return "pnpm Store"
        case .cargoCache: return "Cargo Cache"
        case .nugetCache: return "NuGet Cache"
        case .goCache: return "Go Cache"
        case .playwrightCache: return "Playwright Cache"
        case .cypressCache: return "Cypress Cache"
        case .gradleCache: return "Gradle Cache"
        case .androidArtifacts: return "Android Artifacts"
        case .unityCache: return "Unity Cache"
        }
    }

    func localizedShortDescription(in language: AppLanguage) -> String {
        guard language == .thai else { return shortDescription }
        switch self {
        case .xcodeDerivedData: return "ไฟล์ build ของ Xcode"
        case .xcodeArchives: return "ไฟล์ archive ของแอป"
        case .coreSimulator: return "ข้อมูลและ device ของ Simulator"
        case .dockerData: return "image, layer และ volume ของ Docker"
        case .nodeModules: return "dependency ของ JavaScript"
        case .pythonVirtualEnvs: return "virtual environment ของ Python"
        case .homebrewCache: return "ไฟล์ดาวน์โหลดของ Homebrew"
        case .npmCache: return "แคชแพ็กเกจ npm"
        case .yarnCache: return "แคชแพ็กเกจ Yarn"
        case .pnpmStore: return "store กลางของ pnpm"
        case .playwrightCache: return "browser binaries ของ Playwright"
        case .cypressCache: return "binaries ของ Cypress"
        case .gradleCache: return "แคช dependency ของ Gradle"
        case .unityCache: return "แคชของ Unity"
        case .codeEditors: return "แคชของ editor และ IDE"
        case .projectArtifacts: return "โฟลเดอร์ build ของโปรเจกต์"
        case .pipCache: return "แคชแพ็กเกจ pip"
        case .poetryCache: return "แคชของ Poetry"
        case .cargoCache: return "แคชของ Cargo และ Rust"
        case .nugetCache: return "แคชแพ็กเกจ NuGet"
        case .goCache: return "แคช build และ module ของ Go"
        case .androidArtifacts: return "artifact ของ Android/Gradle/AVD"
        }
    }

    func localizedNote(in language: AppLanguage) -> String {
        guard language == .thai else { return note }
        switch self {
        case .xcodeDerivedData: return "เป็น build artifacts ของ Xcode ที่สร้างใหม่ได้"
        case .xcodeArchives: return "ลบ archive เก่าได้ แต่ควรเก็บ build ปล่อยเวอร์ชันล่าสุดไว้"
        case .coreSimulator: return "จะลบข้อมูล simulator และแอปที่ติดตั้งอยู่ใน simulator"
        case .dockerData: return "อาจลบ image, layer และ local volume ของ Docker"
        case .nodeModules: return "ติดตั้ง dependency ใหม่ได้ แต่แพ็กเกจที่ลงไว้ในเครื่องจะหายไป"
        case .pythonVirtualEnvs: return "virtual env สร้างใหม่ได้ แต่ tooling ในโปรเจกต์จะต้องติดตั้งใหม่"
        case .homebrewCache: return "ล้างแคชไฟล์ดาวน์โหลดของแพ็กเกจได้ค่อนข้างปลอดภัย"
        case .npmCache: return "ล้างแคช npm ได้ค่อนข้างปลอดภัย"
        case .yarnCache: return "ล้างแคช Yarn ได้ค่อนข้างปลอดภัย"
        case .pnpmStore: return "store ของ pnpm สร้างใหม่ได้ แต่ workspace อาจต้องดาวน์โหลดซ้ำ"
        case .playwrightCache: return "browser จะถูกดาวน์โหลดใหม่เมื่อรันเทสต์อีกครั้ง"
        case .cypressCache: return "binary ของ Cypress จะถูกดาวน์โหลดใหม่เมื่อจำเป็น"
        case .gradleCache: return "dependency ของ Gradle จะถูกดาวน์โหลดใหม่"
        case .unityCache: return "ข้อมูลแคชของ Unity อาจใช้เวลาสร้างใหม่พอสมควร"
        case .codeEditors: return "ล้างแคชและ state ที่สร้างใหม่ได้ของ VS Code, Cursor, Codex, JetBrains และ Android Studio"
        case .projectArtifacts: return "ล้างโฟลเดอร์อย่าง build, dist, target, .next และ .nuxt จากโปรเจกต์"
        case .pipCache: return "แคชของ pip จะถูกสร้างใหม่เมื่อดาวน์โหลด dependency ครั้งถัดไป"
        case .poetryCache: return "Poetry จะดาวน์โหลด dependency ใหม่เมื่อจำเป็น"
        case .cargoCache: return "Cargo และ Rust toolchain อาจต้อง build หรือดาวน์โหลดซ้ำ"
        case .nugetCache: return "NuGet จะดาวน์โหลด package ใหม่เมื่อต้องใช้"
        case .goCache: return "Go จะ rebuild หรือดึง module ใหม่บางส่วนเมื่อจำเป็น"
        case .androidArtifacts: return "อาจล้างไฟล์ build/AVD/cache ของ Android Studio และ Gradle ที่สร้างใหม่ได้"
        }
    }
}
