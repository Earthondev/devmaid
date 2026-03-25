import SwiftUI
import DevMaidKit

struct DevMaidRootView: View {
    @EnvironmentObject private var model: DevMaidAppModel

    private var copy: DevMaidCopy { model.copy }

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 212, ideal: 236, max: 260)
        } detail: {
            ZStack {
                DevMaidBackground()

                VStack(spacing: 16) {
                    if let message = model.lastActionMessage {
                        BannerMessage(text: message, systemImage: "checkmark.seal.fill", tint: DevMaidPalette.safe)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if let error = model.lastError {
                        BannerMessage(text: error, systemImage: "exclamationmark.octagon.fill", tint: DevMaidPalette.danger)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if !model.lastRestoreSkipped.isEmpty {
                        BannerMessage(
                            text: copy.skippedRestoreBanner,
                            systemImage: "arrow.triangle.2.circlepath.circle.fill",
                            tint: DevMaidPalette.review
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    content
                        .id(model.destination)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
                .padding(24)
                .animation(.easeInOut(duration: 0.25), value: model.lastActionMessage)
                .animation(.easeInOut(duration: 0.25), value: model.lastError)
                .animation(.spring(response: 0.42, dampingFraction: 0.86), value: model.destination)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .environment(\.locale, Locale(identifier: model.language.localeIdentifier))
        .sheet(isPresented: $model.showOnboarding) {
            OnboardingSheet()
                .environmentObject(model)
                .frame(minWidth: 760, minHeight: 560)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if model.isScanning {
                    Button(copy.toolbarCancelScan, role: .cancel) {
                        model.cancelScan()
                    }
                    .help(copy.toolbarCancelScan)
                } else if let operation = model.currentOperation {
                    ProgressView(copy.progressTitle(for: operation))
                        .controlSize(.small)
                } else {
                    Button(copy.toolbarRunScan) {
                        model.runScan()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!model.canScan)
                    .help(copy.toolbarRunScan)
                }

                if model.destination == .results {
                    Button(copy.toolbarQuarantineSelected) {
                        model.requestCleanup()
                    }
                    .disabled(!model.canCleanupSelection)
                    .help(copy.toolbarQuarantineSelected)
                }
            }
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                DevMaidMark()
                    .frame(width: 28, height: 28)

                Text(copy.appName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(DevMaidDestination.allCases) { destination in
                        SidebarNavigationButton(
                            title: destination.title(in: model.language),
                            systemImage: destination.symbolName,
                            isSelected: model.destination == destination
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                model.destination = destination
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            SurfaceCard(padding: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(copy.sidebarTagline)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(DevMaidPalette.ink)
                    Text(copy.sidebarDetail)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DevMaidPalette.muted)
                }
            }
            .padding(14)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            ZStack {
                LinearGradient(
                    colors: [DevMaidPalette.sidebar, DevMaidPalette.sidebarSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .opacity(0.32)
            }
        )
        .navigationTitle("")
    }

    @ViewBuilder
    private var content: some View {
        switch model.destination {
        case .overview:
            OverviewScreen()
        case .results:
            ResultsScreen()
        case .history:
            HistoryScreen()
        case .settings:
            SettingsScreen()
        case .about:
            AboutScreen()
        }
    }
}

struct OverviewScreen: View {
    @EnvironmentObject private var model: DevMaidAppModel
    private var copy: DevMaidCopy { model.copy }

    private let grid = [
        GridItem(.adaptive(minimum: 220), spacing: 16),
    ]

    private let actionGrid = [
        GridItem(.adaptive(minimum: 240), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeroPanel {
                    HStack(alignment: .center, spacing: 28) {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(spacing: 10) {
                                Text(copy.heroBadge)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(DevMaidPalette.accent.opacity(0.12), in: Capsule())
                                    .foregroundStyle(DevMaidPalette.accent)

                                Text(copy.heroScope)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(DevMaidPalette.muted)
                            }

                            WordmarkLockup(subtitle: copy.tagline)

                            Text(copy.heroDescription)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(DevMaidPalette.muted)
                                .frame(maxWidth: 640, alignment: .leading)

                            HStack(spacing: 10) {
                                Button(copy.toolbarRunScan) {
                                    model.runScan()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(!model.canScan)

                                Button(copy.openResults) {
                                    withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                                        model.destination = .results
                                    }
                                }
                                .buttonStyle(.bordered)
                            }

                            HStack(spacing: 12) {
                                InfoChip(title: copy.selectedCategoriesLabel, value: "\(model.includedCategories.count)", symbolName: "square.grid.2x2.fill")
                                InfoChip(title: copy.scanRootsLabel, value: "\(model.searchRoots.count)", symbolName: "folder.fill")
                                InfoChip(title: copy.exclusionsLabel, value: "\(model.excludedPaths.count)", symbolName: "eye.slash.fill")
                                InfoChip(title: copy.cleanupModeLabel, value: copy.cleanupModeValue, symbolName: "clock.arrow.circlepath")
                                InfoChip(title: copy.updatesTitle, value: updateChipValue, symbolName: "arrow.triangle.2.circlepath.circle.fill")
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                FeatureBullet(text: copy.heroFeaturePreview, symbolName: "eye.fill")
                                FeatureBullet(text: copy.heroFeatureSharedEngine, symbolName: "terminal.fill")
                                FeatureBullet(text: copy.heroFeatureRestore, symbolName: "arrow.uturn.backward.circle.fill")
                            }
                        }

                        Spacer()

                        VStack(spacing: 18) {
                            DevMaidMark()
                                .frame(width: 168, height: 168)

                            HStack(spacing: 10) {
                                RiskBadge(risk: .safe, language: model.language)
                                RiskBadge(risk: .review, language: model.language)
                                RiskBadge(risk: .danger, language: model.language)
                            }
                        }
                    }
                }

                HStack(spacing: 16) {
                    MetricCard(
                        title: copy.reclaimableStorageTitle,
                        value: DevMaidFormatters.byteString(model.reclaimableBytes),
                        detail: copy.reclaimableStorageDetail,
                        symbolName: "internaldrive.fill"
                    )
                    MetricCard(
                        title: copy.itemsFoundTitle,
                        value: "\(model.reclaimableItemCount)",
                        detail: copy.itemsFoundDetail,
                        symbolName: "shippingbox.fill"
                    )
                    MetricCard(
                        title: copy.scanRootsLabel,
                        value: "\(model.searchRoots.count)",
                        detail: copy.scanRootsDetail,
                        symbolName: "folder.fill.badge.plus"
                    )
                    MetricCard(
                        title: copy.reclaimableDeltaTitle,
                        value: signedByteString(model.reclaimableDeltaBytes),
                        detail: copy.weeklyTrendDetail,
                        symbolName: "chart.line.uptrend.xyaxis"
                    )
                }

                VStack(alignment: .leading, spacing: 16) {
                    SectionTitleRow(
                        title: copy.overviewActionsTitle,
                        detail: copy.overviewActionsDetail
                    )

                    LazyVGrid(columns: actionGrid, spacing: 16) {
                        ActionDeckCard(
                            eyebrow: copy.heroBadge,
                            title: copy.overviewActionScanTitle,
                            detail: copy.overviewActionScanDetail,
                            symbolName: "sparkles.rectangle.stack.fill",
                            tint: DevMaidPalette.accent,
                            buttonTitle: copy.toolbarRunScan
                        ) {
                            model.runScan()
                        }

                        ActionDeckCard(
                            eyebrow: copy.scanResultsTitle,
                            title: copy.overviewActionResultsTitle,
                            detail: copy.overviewActionResultsDetail,
                            symbolName: "checklist.checked",
                            tint: DevMaidPalette.safe,
                            buttonTitle: copy.openResults
                        ) {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                                model.destination = .results
                            }
                        }

                        ActionDeckCard(
                            eyebrow: copy.settingsTitle,
                            title: copy.overviewActionSettingsTitle,
                            detail: copy.overviewActionSettingsDetail,
                            symbolName: "slider.horizontal.3",
                            tint: DevMaidPalette.review,
                            buttonTitle: copy.onboardingOpenSettingsAction
                        ) {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                                model.destination = .settings
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    SectionTitleRow(
                        title: copy.cleanupCategoriesTitle,
                        detail: copy.cleanupCategoriesDetail
                    )

                    LazyVGrid(columns: grid, spacing: 16) {
                        ForEach(model.categoryCards) { card in
                            Button {
                                model.toggleCategory(card.category)
                            } label: {
                                CategoryPill(category: card.category, isEnabled: card.isEnabled, bytes: card.bytes, language: model.language)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.82), value: model.includedCategories)
                }

                HStack(alignment: .top, spacing: 16) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(copy.riskLabelsTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(DevMaidPalette.ink)

                            ForEach(RiskLevel.allCases, id: \.self) { risk in
                                HStack(alignment: .top, spacing: 12) {
                                    RiskBadge(risk: risk, language: model.language)
                                    Text(risk.localizedDetail(in: model.language))
                                        .font(.system(size: 13))
                                        .foregroundStyle(DevMaidPalette.muted)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(copy.weeklyTrendTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(DevMaidPalette.ink)

                            if model.weeklyTrendPoints.count >= 2 {
                                TrendSparkline(points: model.weeklyTrendPoints.map(\.reclaimableBytes))
                                    .frame(height: 70)

                                HStack(spacing: 12) {
                                    InfoChip(
                                        title: copy.reclaimableDeltaTitle,
                                        value: signedByteString(model.reclaimableDeltaBytes),
                                        symbolName: "arrow.up.forward"
                                    )
                                    InfoChip(
                                        title: copy.usedSpaceDeltaTitle,
                                        value: signedByteString(model.usedSpaceDeltaBytes),
                                        symbolName: "internaldrive.fill.badge.minus"
                                    )
                                }
                            } else {
                                Text(copy.noTrendData)
                                    .font(.system(size: 13))
                                    .foregroundStyle(DevMaidPalette.muted)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(copy.recentActivityTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(DevMaidPalette.ink)

                            if let latest = model.latestCleanupEntry {
                                Text(latest.summary)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(DevMaidPalette.ink)
                                Text(DevMaidFormatters.dateTimeString(latest.createdAt))
                                    .font(.system(size: 12))
                                    .foregroundStyle(DevMaidPalette.muted)
                                Text(copy.latestCleanupStats(items: latest.itemCount, bytes: DevMaidFormatters.byteString(latest.totalBytes)))
                                    .font(.system(size: 13))
                                    .foregroundStyle(DevMaidPalette.muted)
                            } else {
                                Text(copy.noRecentActivity)
                                    .font(.system(size: 13))
                                    .foregroundStyle(DevMaidPalette.muted)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    UpdateStatusCard(showAutoCheckToggle: false)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(10)
        }
    }

    private var updateChipValue: String {
        switch model.updateState {
        case .idle:
            return copy.updateIdleBadge
        case .checking:
            return copy.checkingForUpdates
        case .upToDate:
            return copy.updateCurrentBadge
        case .available:
            return copy.updateAvailableBadge
        case .unsupported:
            return copy.updateUnsupportedBadge
        case .failed:
            return copy.updateErrorBadge
        }
    }
}

struct ResultsScreen: View {
    @EnvironmentObject private var model: DevMaidAppModel
    private var copy: DevMaidCopy { model.copy }
    private let workflowGrid = [
        GridItem(.adaptive(minimum: 220), spacing: 12),
    ]

    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 16) {
                resultsHeader
                workflowStrip
                HStack(spacing: 12) {
                    InfoChip(title: copy.visibleItemsLabel, value: "\(model.filteredItems.count)", symbolName: "shippingbox.fill")
                    InfoChip(title: copy.visibleSizeLabel, value: DevMaidFormatters.byteString(model.visibleBytes), symbolName: "internaldrive.fill")
                    InfoChip(title: copy.selectedLabel, value: "\(model.selectedScanItems.count)", symbolName: "checkmark.circle.fill")
                    InfoChip(title: copy.groupedByProjectLabel, value: "\(model.resultGroups.count)", symbolName: "square.stack.3d.up.fill")
                }

                if !model.selectedScanItems.isEmpty {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .center, spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(copy.batchCleanupTitle)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(DevMaidPalette.ink)
                                    Text(copy.selectedItemsTitle(count: model.selectedScanItems.count))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(DevMaidPalette.muted)
                                }

                                Spacer()

                                Text(DevMaidFormatters.byteString(model.selectedScanItems.reduce(0) { $0 + $1.bytes }))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(DevMaidPalette.ink)

                                Button(copy.toolbarQuarantineSelected) {
                                    model.requestCleanup()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(!model.canCleanupSelection)
                            }

                            Text(selectionRiskDetail)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(DevMaidPalette.muted)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                SurfaceCard(padding: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        filterBar
                            .padding(18)

                        if !model.resultGroups.isEmpty {
                            groupedSummaryStrip
                                .padding(.horizontal, 18)
                                .padding(.bottom, 18)
                        }

                        if model.filteredItems.isEmpty {
                            emptyResults
                                .padding(.horizontal, 18)
                                .padding(.bottom, 18)
                        } else {
                            Table(model.filteredItems, selection: $model.selectedScanItemIDs) {
                                TableColumn(copy.itemColumnTitle) { item in
                                    ResultLocationCell(
                                        title: itemDisplayName(for: item),
                                        parentPath: parentDirectoryPath(for: item),
                                        groupName: item.groupName
                                    )
                                    .help(item.path)
                                }
                                .width(min: 300, ideal: 420)
                                TableColumn(copy.categoryFilterLabel) { item in
                                    ResultCategoryCell(category: item.category, language: model.language)
                                }
                                .width(min: 180, ideal: 220)
                                TableColumn(copy.riskFilterLabel) { item in
                                    RiskBadge(risk: item.risk, language: model.language)
                                }
                                .width(min: 110, ideal: 120)
                                TableColumn(copy.bytesMetricTitle) { item in
                                    Text(DevMaidFormatters.byteString(item.bytes))
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundStyle(DevMaidPalette.ink)
                                }
                                .width(min: 108, ideal: 124)
                                TableColumn(copy.actionsColumnTitle) { item in
                                    Menu {
                                        Button(copy.showInFinderAction) {
                                            model.reveal(item)
                                        }
                                        Button(copy.openInTerminalAction) {
                                            model.openInTerminal(item)
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(DevMaidPalette.accent)
                                    }
                                    .menuStyle(.borderlessButton)
                                }
                                .width(min: 54, ideal: 60, max: 60)
                            }
                            .tableStyle(.inset(alternatesRowBackgrounds: true))
                            .frame(maxHeight: .infinity)
                        }
                    }
                }

                if !model.scanWarnings.isEmpty {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(copy.warningsTitle)
                                .font(.system(size: 14, weight: .bold))
                            ForEach(model.scanWarnings, id: \.self) { warning in
                                Text("• \(warning)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(DevMaidPalette.muted)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            inspector
                .frame(width: 320)
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: model.selectedScanItemIDs)
        .animation(.easeInOut(duration: 0.22), value: model.filteredItems.count)
        .alert(copy.reviewCleanupTitle, isPresented: $model.showCleanupConfirmation) {
            Button(copy.cancel, role: .cancel) {}
            Button(copy.quarantineAction) { model.performCleanup() }
        } message: {
            Text(copy.cleanupConfirmationMessage(count: model.selectedScanItems.count))
        }
        .alert(copy.dangerousCleanupTitle, isPresented: $model.showDangerConfirmation) {
            Button(copy.cancel, role: .cancel) {}
            Button(copy.dangerQuarantineAction, role: .destructive) { model.performCleanup() }
        } message: {
            Text(copy.dangerConfirmationMessage)
        }
    }

    private var resultsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(copy.scanResultsTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(copy.visibleSummary(count: model.filteredItems.count, bytes: DevMaidFormatters.byteString(model.visibleBytes)))
                    .font(.system(size: 13))
                    .foregroundStyle(DevMaidPalette.muted)
            }
            Spacer()
            if model.canExportScan {
                Button(copy.exportScanAction) {
                    model.exportCurrentScan()
                }
                .buttonStyle(.bordered)
            }
            if model.currentOperation != nil {
                ProgressView(copy.progressTitle(for: model.currentOperation))
                    .controlSize(.small)
            }
        }
    }

    private var workflowStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitleRow(
                title: copy.resultsWorkflowTitle,
                detail: copy.resultsWorkflowDetail
            )

            LazyVGrid(columns: workflowGrid, spacing: 12) {
                WorkflowStepPill(
                    index: 1,
                    title: copy.toolbarRunScan,
                    detail: copy.resultsWorkflowScanDetail,
                    symbolName: "sparkles",
                    tint: DevMaidPalette.accent
                )
                WorkflowStepPill(
                    index: 2,
                    title: copy.scanResultsTitle,
                    detail: copy.resultsWorkflowReviewDetail(count: model.filteredItems.count, bytes: DevMaidFormatters.byteString(model.visibleBytes)),
                    symbolName: "line.3.horizontal.decrease.circle.fill",
                    tint: DevMaidPalette.review
                )
                WorkflowStepPill(
                    index: 3,
                    title: copy.toolbarQuarantineSelected,
                    detail: copy.resultsWorkflowQuarantineDetail,
                    symbolName: "archivebox.fill",
                    tint: DevMaidPalette.safe
                )
            }
        }
    }

    private var groupedSummaryStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitleRow(
                title: copy.groupedResultsTitle,
                detail: copy.groupedResultsDetail
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(model.resultGroups.prefix(6)) { group in
                        GroupSummaryCard(
                            title: group.title,
                            itemCount: group.itemCount,
                            totalBytes: group.totalBytes,
                            risk: group.highestRisk,
                            language: model.language
                        )
                        .frame(width: 220)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                TextField(copy.filterPlaceholder, text: $model.searchText)
                    .textFieldStyle(.roundedBorder)

                Picker(copy.categoryFilterLabel, selection: $model.categoryFilter) {
                    Text(copy.allCategories).tag(CleanupCategory?.none)
                    ForEach(CleanupCategory.allCases, id: \.self) { category in
                        Text(category.localizedDisplayName(in: model.language)).tag(CleanupCategory?.some(category))
                    }
                }
                .frame(width: 190)

                Picker(copy.riskFilterLabel, selection: $model.riskFilter) {
                    Text(copy.allRisk).tag(RiskLevel?.none)
                    ForEach(RiskLevel.allCases, id: \.self) { risk in
                        Text(risk.localizedDisplayName(in: model.language)).tag(RiskLevel?.some(risk))
                    }
                }
                .frame(width: 150)
            }

            HStack(spacing: 12) {
                Picker(copy.sortLabel, selection: $model.sortOption) {
                    ForEach(ScanSortOption.allCases) { option in
                        Text(option.title(in: model.language)).tag(option)
                    }
                }
                .frame(width: 180)

                Menu(copy.selectionActionsTitle) {
                    Button(copy.selectAllVisibleAction) { model.selectAllVisibleResults() }
                    Button(copy.clearSelectionAction) { model.clearResultSelection() }
                    Divider()
                    Button(copy.selectSafeAction) { model.selectVisibleResults(for: .safe) }
                    Button(copy.selectReviewAction) { model.selectVisibleResults(for: .review) }
                    Button(copy.selectDangerAction) { model.selectVisibleResults(for: .danger) }
                    Divider()
                    Button(copy.selectLargeItemsAction) { model.selectVisibleResults(minimumBytes: 1_073_741_824) }
                    Menu(copy.categoryFilterLabel) {
                        ForEach(CleanupCategory.allCases, id: \.self) { category in
                            Button(category.localizedDisplayName(in: model.language)) {
                                model.selectVisibleResults(for: category)
                            }
                        }
                    }
                }

                Spacer()

                if model.currentOperation == .scanning {
                    ProgressView(copy.progressTitle(for: model.currentOperation))
                        .controlSize(.small)
                }
            }
        }
    }

    private var emptyResults: some View {
        VStack(spacing: 18) {
            DevMaidMark()
                .frame(width: 82, height: 82)

            Text(model.scanSummary == nil ? copy.emptyResultsBeforeScan : copy.emptyResultsFiltered)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(DevMaidPalette.ink)

            Text(copy.emptyResultsDetail)
                .font(.system(size: 13))
                .foregroundStyle(DevMaidPalette.muted)

            HStack(spacing: 10) {
                Button(copy.toolbarRunScan) {
                    model.runScan()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!model.canScan)

                Button(copy.emptyResultsSettingsHint) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                        model.destination = .settings
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }

    private var inspector: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(copy.inspectorTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Group {
                    if let item = model.primarySelectedItem {
                        detailCard(for: item)
                    } else if !model.selectedScanItems.isEmpty {
                        batchDetailCard
                    } else {
                        DetailSectionCard(
                            title: copy.noSelectionYetTitle,
                            detail: copy.inspectorEmpty
                        ) {
                            HStack(spacing: 10) {
                                InfoChip(
                                    title: copy.selectedLabel,
                                    value: "0",
                                    symbolName: "checkmark.circle.fill"
                                )
                                InfoChip(
                                    title: copy.visibleItemsLabel,
                                    value: "\(model.filteredItems.count)",
                                    symbolName: "shippingbox.fill"
                                )
                            }
                        }
                    }
                }
                .id(inspectorStateID)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

                Spacer()
            }
        }
    }

    private var selectionRiskDetail: String {
        let risks = Set(model.selectedScanItems.map(\.risk))
        return risks.count > 1 ? copy.mixedRiskSelectionDetail : copy.uniformRiskSelectionDetail
    }

    private func detailCard(for item: ScanItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            DetailSectionCard(title: copy.selectedPathTitle) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(itemDisplayName(for: item))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(DevMaidPalette.ink)
                                .lineLimit(2)

                            Label(item.category.localizedDisplayName(in: model.language), systemImage: item.category.symbolName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(DevMaidPalette.muted)
                        }

                        Spacer()

                        RiskBadge(risk: item.risk, language: model.language)
                    }

                    HStack(spacing: 10) {
                        InfoChip(
                            title: copy.bytesMetricTitle,
                            value: DevMaidFormatters.byteString(item.bytes),
                            symbolName: "internaldrive.fill"
                        )

                        if let groupName = item.groupName, !groupName.isEmpty {
                            InfoChip(
                                title: copy.groupTitle,
                                value: groupName,
                                symbolName: "square.stack.3d.up.fill"
                            )
                        }
                    }
                }
            }

            DetailSectionCard(title: copy.pathTitle, detail: item.path) {
                Text(parentDirectoryPath(for: item))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(DevMaidPalette.muted)
                    .textSelection(.enabled)
                    .lineLimit(2)
            }

            DetailSectionCard(title: copy.cleanupNoteTitle, detail: item.category.localizedNote(in: model.language)) {
                EmptyView()
            }

            DetailSectionCard(title: copy.riskGuidanceTitle, detail: item.risk.localizedDetail(in: model.language)) {
                HStack(spacing: 10) {
                    Button(copy.showInFinderAction) {
                        model.revealPrimaryItemInFinder()
                    }
                    .buttonStyle(.bordered)

                    Button(copy.openInTerminalAction) {
                        model.openPrimaryItemInTerminal()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var batchDetailCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            DetailSectionCard(title: copy.selectionImpactTitle, detail: copy.batchCleanupDetail) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        InfoChip(
                            title: copy.selectedLabel,
                            value: "\(model.selectedScanItems.count)",
                            symbolName: "checkmark.circle.fill"
                        )
                        InfoChip(
                            title: copy.bytesMetricTitle,
                            value: DevMaidFormatters.byteString(model.selectedScanItems.reduce(0) { $0 + $1.bytes }),
                            symbolName: "internaldrive.fill"
                        )
                    }

                    Text(copy.selectedItemsTitle(count: model.selectedScanItems.count))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(DevMaidPalette.ink)
                }
            }

            DetailSectionCard(title: copy.riskMixTitle, detail: selectionRiskDetail) {
                HStack(spacing: 8) {
                    ForEach(RiskLevel.allCases, id: \.self) { risk in
                        let count = model.selectedScanItems.filter { $0.risk == risk }.count
                        if count > 0 {
                            InfoChip(
                                title: risk.localizedDisplayName(in: model.language),
                                value: "\(count)",
                                symbolName: risk.symbolName
                            )
                        }
                    }
                }
            }

            DetailSectionCard(title: copy.topCategoriesTitle) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(topSelectedCategories, id: \.title) { category in
                        HStack(spacing: 10) {
                            Label(category.title, systemImage: category.symbolName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(DevMaidPalette.ink)
                            Spacer()
                            Text(category.countLabel)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(DevMaidPalette.muted)
                        }
                    }
                }
            }
        }
    }

    private func itemDisplayName(for item: ScanItem) -> String {
        let url = URL(fileURLWithPath: item.path)
        let candidate = url.lastPathComponent
        return candidate.isEmpty ? item.path : candidate
    }

    private func parentDirectoryPath(for item: ScanItem) -> String {
        let url = URL(fileURLWithPath: item.path)
        let parent = url.deletingLastPathComponent().path
        return parent.isEmpty ? item.path : parent
    }

    private var inspectorStateID: String {
        if let item = model.primarySelectedItem {
            return "single-\(item.id.uuidString)"
        }
        if !model.selectedScanItems.isEmpty {
            return "batch-\(model.selectedScanItems.count)-\(model.selectedScanItems.reduce(0) { $0 + $1.bytes })"
        }
        return "empty-\(model.filteredItems.count)"
    }

    private var topSelectedCategories: [(title: String, symbolName: String, countLabel: String, count: Int)] {
        let grouped = Dictionary(grouping: model.selectedScanItems, by: \.category)
        return grouped
            .map { category, items in
                (
                    title: category.localizedDisplayName(in: model.language),
                    symbolName: category.symbolName,
                    countLabel: copy.itemsCountLabel(items.count),
                    count: items.count
                )
            }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
                }
                return lhs.count > rhs.count
            }
            .prefix(3)
            .map { $0 }
    }
}

struct HistoryScreen: View {
    @EnvironmentObject private var model: DevMaidAppModel
    private var copy: DevMaidCopy { model.copy }

    var body: some View {
        HStack(spacing: 18) {
            SurfaceCard(padding: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    SectionTitleRow(
                        title: copy.historyTimelineTitle,
                        detail: copy.historyTimelineDetail
                    )
                    .padding(18)

                    List(selection: Binding(
                        get: { model.selectedHistoryID },
                        set: { model.selectHistory(id: $0) }
                    )) {
                        ForEach(model.historyEntries) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    ActionKindBadge(kind: entry.kind, language: model.language)
                                    Spacer()
                                    Text(DevMaidFormatters.byteString(entry.totalBytes))
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundStyle(DevMaidPalette.muted)
                                }
                                Text(entry.summary)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(DevMaidPalette.ink)
                                    .lineLimit(2)
                                HStack {
                                    Text(DevMaidFormatters.dateTimeString(entry.createdAt))
                                        .font(.system(size: 11))
                                        .foregroundStyle(DevMaidPalette.muted)
                                    Spacer()
                                    Text("\(entry.itemCount)")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(DevMaidPalette.muted)
                                }
                            }
                            .padding(.vertical, 8)
                            .tag(Optional(entry.id))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(minWidth: 320)

            VStack(alignment: .leading, spacing: 16) {
                Group {
                    if let entry = model.selectedHistoryEntry {
                        SurfaceCard {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    ActionKindBadge(kind: entry.kind, language: model.language)
                                    Text(entry.kind.localizedDisplayName(in: model.language))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                    Text(entry.summary)
                                        .font(.system(size: 14))
                                        .foregroundStyle(DevMaidPalette.muted)
                                }
                                Spacer(minLength: 24)
                                VStack(alignment: .trailing, spacing: 10) {
                                    if entry.kind == .delete {
                                        Button(copy.restoreAction) {
                                            model.restoreSelectedHistory()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .disabled(!model.canRestoreSelectedHistory)
                                    }
                                    Button(copy.exportHistoryAction) {
                                        model.exportHistory()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }

                        HStack(spacing: 16) {
                            MetricCard(
                                title: copy.itemsMetricTitle,
                                value: "\(entry.itemCount)",
                                detail: copy.itemsMetricDetail,
                                symbolName: "shippingbox.fill"
                            )
                            MetricCard(
                                title: copy.bytesMetricTitle,
                                value: DevMaidFormatters.byteString(entry.totalBytes),
                                detail: copy.bytesMetricDetail,
                                symbolName: "internaldrive.fill"
                            )
                        }

                        if let manifest = model.selectedHistoryManifest {
                            SurfaceCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    SectionTitleRow(
                                        title: copy.manifestItemsTitle,
                                        detail: copy.manifestItemsDetail
                                    )
                                    ScrollView {
                                        LazyVStack(alignment: .leading, spacing: 10) {
                                            ForEach(manifest.items) { item in
                                                DetailSectionCard(
                                                    title: item.category.localizedDisplayName(in: model.language),
                                                    detail: item.note
                                                ) {
                                                    VStack(alignment: .leading, spacing: 10) {
                                                        HStack {
                                                            RiskBadge(risk: item.risk, language: model.language)
                                                            Spacer()
                                                            Text(DevMaidFormatters.byteString(item.bytes))
                                                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                                .foregroundStyle(DevMaidPalette.muted)
                                                        }
                                                        Text(item.originalPath)
                                                            .font(.system(size: 12))
                                                            .foregroundStyle(DevMaidPalette.ink)
                                                            .textSelection(.enabled)
                                                            .lineLimit(2)
                                                            .truncationMode(.middle)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxHeight: .infinity)
                                }
                            }
                        } else {
                            SurfaceCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(copy.noManifestPreview)
                                        .font(.system(size: 12))
                                        .foregroundStyle(DevMaidPalette.muted)
                                    if let sourceActionID = entry.sourceActionID {
                                        Text("\(copy.sourceActionPrefix) \(sourceActionID)")
                                            .font(.system(size: 12))
                                            .foregroundStyle(DevMaidPalette.muted)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        SurfaceCard {
                            Text(copy.historyEmpty)
                                .font(.system(size: 14))
                                .foregroundStyle(DevMaidPalette.muted)
                        }
                    }
                }
                .id(historyDetailID)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: model.selectedHistoryID)
    }

    private var historyDetailID: String {
        model.selectedHistoryID ?? "history-empty"
    }
}

struct SettingsScreen: View {
    @EnvironmentObject private var model: DevMaidAppModel
    private var copy: DevMaidCopy { model.copy }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeroPanel {
                    HStack(alignment: .top, spacing: 24) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(copy.settingsHeroBadge)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(DevMaidPalette.review.opacity(0.12), in: Capsule())
                                .foregroundStyle(DevMaidPalette.review)

                            Text(copy.settingsTitle)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(DevMaidPalette.ink)

                            Text(copy.settingsHeroDetail)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DevMaidPalette.muted)
                                .frame(maxWidth: 640, alignment: .leading)
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 10) {
                            InfoChip(title: copy.scanRootsLabel, value: "\(model.searchRoots.count)", symbolName: "folder.fill")
                            InfoChip(title: copy.exclusionsLabel, value: "\(model.excludedPaths.count)", symbolName: "eye.slash.fill")
                            InfoChip(title: copy.languageTitle, value: model.language.displayName, symbolName: "character.bubble.fill")
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.updatesTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.updatesDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)

                        UpdateStatusCard(showAutoCheckToggle: true)
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.languageTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.languageDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)

                        Picker(copy.languageTitle, selection: Binding(
                            get: { model.language },
                            set: { model.setLanguage($0) }
                        )) {
                            ForEach(AppLanguage.allCases) { language in
                                Text("\(language.displayName) / \(language.secondaryDisplayName)").tag(language)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.exclusionsTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.exclusionsDescription)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)

                        if model.excludedPaths.isEmpty {
                            Text(copy.noExclusions)
                                .font(.system(size: 13))
                                .foregroundStyle(DevMaidPalette.muted)
                                .padding(.vertical, 4)
                        } else {
                            List(selection: $model.selectedExcludedPath) {
                                ForEach(model.excludedPaths, id: \.self) { path in
                                    Text(path)
                                        .tag(Optional(path))
                                }
                            }
                            .frame(height: 160)
                            .scrollContentBackground(.hidden)
                        }

                        HStack {
                            Button(copy.addExclusion) { model.addExcludedPath() }
                            Button(copy.removeSelectedExclusion) { model.removeSelectedExcludedPath() }
                                .disabled(model.selectedExcludedPath == nil)
                            Button(copy.clearExclusions) { model.clearExcludedPaths() }
                                .disabled(!model.hasExclusions)
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.notificationsTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.notificationsDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)

                        Toggle(copy.notificationsEnabledTitle, isOn: Binding(
                            get: { model.notificationsEnabled },
                            set: { model.setNotificationsEnabled($0) }
                        ))

                        HStack(spacing: 16) {
                            Stepper(
                                "\(copy.freeSpaceThresholdTitle) \(model.freeSpaceAlertThresholdGB) \(copy.thresholdUnitGB)",
                                value: Binding(
                                    get: { model.freeSpaceAlertThresholdGB },
                                    set: { model.setFreeSpaceAlertThreshold($0) }
                                ),
                                in: 5...200
                            )

                            Stepper(
                                "\(copy.reclaimableSpikeThresholdTitle) \(model.reclaimableSpikeThresholdGB) \(copy.thresholdUnitGB)",
                                value: Binding(
                                    get: { model.reclaimableSpikeThresholdGB },
                                    set: { model.setReclaimableSpikeThreshold($0) }
                                ),
                                in: 1...100
                            )
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.scanRootsTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.scanRootsDescription)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)

                        List(selection: $model.selectedSearchRoot) {
                            ForEach(model.searchRoots, id: \.self) { root in
                                Text(root)
                                    .tag(Optional(root))
                            }
                        }
                        .frame(height: 180)
                        .scrollContentBackground(.hidden)

                        HStack {
                            Button(copy.addRoot) { model.addSearchRoot() }
                            Button(copy.removeSelectedRoot) { model.removeSelectedSearchRoot() }
                                .disabled(model.selectedSearchRoot == nil)
                            Button(copy.resetDefaults) { model.resetSearchRoots() }
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.safetyDefaultsTitle)
                            .font(.system(size: 18, weight: .bold))

                        Toggle(copy.askBeforeQuarantine, isOn: Binding(
                            get: { model.requireConfirmation },
                            set: { model.requireConfirmation = $0; model.persistSafeguards() }
                        ))

                        Toggle(copy.requireDangerConfirmation, isOn: Binding(
                            get: { model.requireDangerConfirmation },
                            set: { model.requireDangerConfirmation = $0; model.persistSafeguards() }
                        ))

                        Text(copy.safetyDefaultsDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.fullDiskAccessTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.fullDiskAccessDescription)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)

                        Text(copy.fullDiskAccessSteps)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(DevMaidPalette.ink)

                        HStack {
                            Button(copy.onboardingPrimaryAction) {
                                model.openFullDiskAccessSettings()
                            }
                            .buttonStyle(.bordered)
                            Button(copy.reopenOnboardingAction) {
                                model.reopenOnboarding()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.privacyPolicyTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.privacyPolicyDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)
                        Button(copy.openPrivacyPolicyAction) {
                            model.openPrivacyPolicy()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(copy.startupItemsTitle)
                                    .font(.system(size: 18, weight: .bold))
                                Text(copy.startupItemsDetail)
                                    .font(.system(size: 13))
                                    .foregroundStyle(DevMaidPalette.muted)
                            }
                            Spacer()
                            if model.isLoadingStartupItems {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Button(copy.startupRefreshAction) {
                                model.refreshStartupItems()
                            }
                        }

                        Picker(copy.startupItemsFilterLabel, selection: Binding(
                            get: { model.startupItemsFilter },
                            set: { model.setStartupItemsFilter($0) }
                        )) {
                            ForEach(StartupItemsFilter.allCases) { filter in
                                Text(filter.title(in: model.language)).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)

                        if model.filteredStartupItems.isEmpty {
                            Text(copy.startupNoItems)
                                .font(.system(size: 13))
                                .foregroundStyle(DevMaidPalette.muted)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(model.filteredStartupItems) { item in
                                    HStack(alignment: .top, spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Text(item.name)
                                                    .font(.system(size: 13, weight: .semibold))
                                                StartupKindBadge(
                                                    title: item.kind == .appManaged ? copy.startupManagedBadge : copy.startupReadOnlyBadge,
                                                    tint: item.kind == .appManaged ? DevMaidPalette.accent : DevMaidPalette.muted
                                                )
                                            }
                                            Text(item.detail)
                                                .font(.system(size: 12))
                                                .foregroundStyle(DevMaidPalette.muted)
                                        }
                                        Spacer()
                                        Toggle(
                                            item.isEnabled ? copy.startupDisableAction : copy.startupEnableAction,
                                            isOn: Binding(
                                                get: { item.isEnabled },
                                                set: { model.setStartupItemEnabled(item, enabled: $0) }
                                            )
                                        )
                                        .toggleStyle(.switch)
                                        .labelsHidden()
                                        .disabled(item.kind != .appManaged)
                                    }
                                    if item.id != model.filteredStartupItems.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.supportDeveloperTitle)
                            .font(.system(size: 18, weight: .bold))

                        HStack(spacing: 12) {
                            Link(copy.website, destination: DevMaidLinks.website)
                            Link(copy.support, destination: DevMaidLinks.support)
                            Link(copy.sponsor, destination: DevMaidLinks.sponsor)
                            Link(copy.security, destination: DevMaidLinks.securityEmail)
                        }
                        .font(.system(size: 13, weight: .semibold))

                        Text(copy.supportDeveloperDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)
                    }
                }
            }
            .padding(10)
        }
    }
}

struct OnboardingSheet: View {
    @EnvironmentObject private var model: DevMaidAppModel

    private var copy: DevMaidCopy { model.copy }

    var body: some View {
        ZStack {
            DevMaidBackground()

            VStack(alignment: .leading, spacing: 22) {
                HeroPanel {
                    HStack(alignment: .center, spacing: 24) {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(spacing: 16) {
                                DevMaidMark()
                                    .frame(width: 76, height: 76)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(copy.onboardingTitle)
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                    Text(copy.onboardingDetail)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(DevMaidPalette.muted)
                                }
                            }

                            HStack(spacing: 12) {
                                InfoChip(title: copy.scanRootsLabel, value: "\(model.searchRoots.count)", symbolName: "folder.fill")
                                InfoChip(title: copy.exclusionsLabel, value: "\(model.excludedPaths.count)", symbolName: "eye.slash.fill")
                                InfoChip(title: copy.selectedCategoriesLabel, value: "\(model.includedCategories.count)", symbolName: "square.grid.2x2.fill")
                            }
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 10) {
                            FeatureBullet(text: copy.heroFeaturePreview, symbolName: "eye.fill")
                            FeatureBullet(text: copy.heroFeatureSharedEngine, symbolName: "terminal.fill")
                            FeatureBullet(text: copy.heroFeatureRestore, symbolName: "arrow.uturn.backward.circle.fill")
                        }
                        .frame(maxWidth: 280, alignment: .leading)
                    }
                }

                HStack(alignment: .top, spacing: 16) {
                    onboardingStep(
                        title: copy.onboardingStepOneTitle,
                        detail: copy.onboardingStepOneDetail,
                        symbol: "lock.shield.fill",
                        tint: DevMaidPalette.accent
                    )
                    onboardingStep(
                        title: copy.onboardingStepTwoTitle,
                        detail: copy.onboardingStepTwoDetail,
                        symbol: "slider.horizontal.3",
                        tint: DevMaidPalette.review
                    )
                    onboardingStep(
                        title: copy.onboardingStepThreeTitle,
                        detail: copy.onboardingStepThreeDetail,
                        symbol: "clock.arrow.circlepath",
                        tint: DevMaidPalette.safe
                    )
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.onboardingChecklistTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(DevMaidPalette.ink)
                        Text(copy.onboardingChecklistDetail)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(DevMaidPalette.muted)

                        HStack(spacing: 12) {
                            InfoChip(title: copy.scanRootsLabel, value: "\(model.searchRoots.count)", symbolName: "folder.fill.badge.plus")
                            InfoChip(title: copy.exclusionsLabel, value: "\(model.excludedPaths.count)", symbolName: "eye.slash.fill")
                            InfoChip(title: copy.selectedCategoriesLabel, value: "\(model.includedCategories.count)", symbolName: "square.grid.2x2.fill")
                        }
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(copy.fullDiskAccessTitle)
                            .font(.system(size: 16, weight: .bold))
                        Text(copy.fullDiskAccessSteps)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(DevMaidPalette.ink)
                    }
                }

                HStack {
                    Button(copy.onboardingPrimaryAction) {
                        model.openFullDiskAccessSettings()
                    }
                    .buttonStyle(.borderedProminent)

                    Button(copy.onboardingOpenSettingsAction) {
                        model.destination = .settings
                        model.dismissOnboarding()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(copy.onboardingSecondaryAction) {
                        model.dismissOnboarding()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(28)
        }
    }

    private func onboardingStep(title: String, detail: String, symbol: String, tint: Color) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(DevMaidPalette.ink)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(DevMaidPalette.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AboutScreen: View {
    @EnvironmentObject private var model: DevMaidAppModel

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? version
        return "\(version) (\(build))"
    }

    private var copy: DevMaidCopy { model.copy }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HeroPanel {
                    HStack(alignment: .top, spacing: 24) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(copy.aboutHeroBadge)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(DevMaidPalette.accent.opacity(0.12), in: Capsule())
                                .foregroundStyle(DevMaidPalette.accent)

                            WordmarkLockup(subtitle: copy.tagline)

                            Text(copy.aboutHeroDetail)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DevMaidPalette.muted)
                                .frame(maxWidth: 720, alignment: .leading)
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 10) {
                            InfoChip(title: copy.versionTitle, value: appVersion, symbolName: "macwindow.on.rectangle")
                            InfoChip(title: copy.cliTitle, value: "devmaid", symbolName: "terminal.fill")
                            InfoChip(title: copy.updatesTitle, value: copy.updateBadgeTitle(for: model.updateState), symbolName: "sparkles")
                        }
                    }
                }

                Text(copy.aboutDescription)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DevMaidPalette.muted)
                    .frame(maxWidth: 760, alignment: .leading)

                HStack(spacing: 16) {
                    MetricCard(
                        title: copy.versionTitle,
                        value: appVersion,
                        detail: copy.versionDetail,
                        symbolName: "macwindow.on.rectangle"
                    )
                    MetricCard(
                        title: copy.cliTitle,
                        value: "devmaid",
                        detail: copy.cliDetail,
                        symbolName: "terminal.fill"
                    )
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.updatesTitle)
                            .font(.system(size: 18, weight: .bold))

                        UpdateStatusCard(showAutoCheckToggle: false)
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.linksTitle)
                            .font(.system(size: 18, weight: .bold))
                        HStack(spacing: 12) {
                            Link(copy.website, destination: DevMaidLinks.website)
                            Link(copy.repository, destination: DevMaidLinks.repository)
                            Link(copy.support, destination: DevMaidLinks.support)
                            Link(copy.sponsor, destination: DevMaidLinks.sponsor)
                        }
                        .font(.system(size: 13, weight: .semibold))
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.acknowledgementsTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.acknowledgementsDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(DevMaidPalette.muted)
                    }
                }
            }
            .padding(10)
        }
    }
}

struct UpdateStatusCard: View {
    @EnvironmentObject private var model: DevMaidAppModel

    let showAutoCheckToggle: Bool

    private var copy: DevMaidCopy { model.copy }

    private var tint: Color {
        switch model.updateState {
        case .idle:
            return DevMaidPalette.accent
        case .checking:
            return DevMaidPalette.accent
        case .upToDate:
            return DevMaidPalette.safe
        case .available:
            return DevMaidPalette.accent
        case .unsupported:
            return DevMaidPalette.review
        case .failed:
            return DevMaidPalette.danger
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    UpdateBadge(title: copy.updateBadgeTitle(for: model.updateState), tint: tint)
                    Text(copy.updateStatusText(for: model.updateState))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DevMaidPalette.ink)
                }
                Spacer()

                if model.isCheckingForUpdates {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            HStack(spacing: 12) {
                InfoChip(title: copy.currentVersionLabel, value: model.currentAppVersion, symbolName: "macwindow.on.rectangle")

                if let latestVersion = model.latestKnownVersion {
                    InfoChip(title: copy.latestVersionLabel, value: latestVersion, symbolName: "sparkles")
                }
            }

            if let summary = model.updateSummary, !summary.isEmpty {
                Text(summary)
                    .font(.system(size: 13))
                    .foregroundStyle(DevMaidPalette.muted)
            }

            VStack(alignment: .leading, spacing: 8) {
                if let checkedAt = model.lastUpdateCheckDate {
                    metadataRow(title: copy.lastCheckedLabel, value: DevMaidFormatters.dateTimeString(checkedAt))
                }

                if let feedURL = model.updateFeedURL {
                    metadataRow(title: copy.updateFeedLabel, value: feedURL.absoluteString)
                }
            }

            if showAutoCheckToggle {
                Toggle(copy.autoCheckUpdates, isOn: Binding(
                    get: { model.automaticallyCheckForUpdates },
                    set: { model.setAutomaticUpdateChecks($0) }
                ))

                Text(copy.autoCheckUpdatesDetail)
                    .font(.system(size: 12))
                    .foregroundStyle(DevMaidPalette.muted)
            }

            HStack(spacing: 10) {
                Button(copy.checkForUpdatesAction) {
                    model.checkForUpdates(userInitiated: true)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!model.canCheckForUpdates)

                if model.updateDownloadURL != nil {
                    Button(copy.downloadUpdateAction) {
                        model.openUpdateDownload()
                    }
                    .buttonStyle(.bordered)
                }

                if model.updateReleaseNotesURL != nil {
                    Button(copy.releaseNotesAction) {
                        model.openUpdateReleaseNotes()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private func metadataRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DevMaidPalette.muted)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(DevMaidPalette.ink)
                .textSelection(.enabled)
                .lineLimit(2)
                .truncationMode(.middle)
        }
    }
}

private struct StartupKindBadge: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
            .foregroundStyle(tint)
    }
}

private struct TrendSparkline: View {
    let points: [Int64]

    var body: some View {
        GeometryReader { proxy in
            let values = points.map(Double.init)
            let maxValue = max(values.max() ?? 1, 1)
            let minValue = values.min() ?? 0
            let range = max(maxValue - minValue, 1)

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(DevMaidPalette.accent.opacity(0.08))

                Path { path in
                    for (index, value) in values.enumerated() {
                        let x = proxy.size.width * CGFloat(index) / CGFloat(max(values.count - 1, 1))
                        let y = proxy.size.height * (1 - CGFloat((value - minValue) / range))
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [DevMaidPalette.accent, DevMaidPalette.safe],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}

private func signedByteString(_ value: Int64) -> String {
    let prefix = value > 0 ? "+" : value < 0 ? "-" : ""
    return prefix + DevMaidFormatters.byteString(abs(value))
}
