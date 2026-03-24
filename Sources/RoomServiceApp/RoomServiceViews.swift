import SwiftUI
import RoomServiceKit

struct RoomServiceRootView: View {
    @EnvironmentObject private var model: RoomServiceAppModel

    private var copy: RoomServiceCopy { model.copy }

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 212, ideal: 236, max: 260)
        } detail: {
            ZStack {
                RoomServiceBackground()

                VStack(spacing: 16) {
                    if let message = model.lastActionMessage {
                        BannerMessage(text: message, systemImage: "checkmark.seal.fill", tint: RoomServicePalette.safe)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if let error = model.lastError {
                        BannerMessage(text: error, systemImage: "exclamationmark.octagon.fill", tint: RoomServicePalette.danger)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if !model.lastRestoreSkipped.isEmpty {
                        BannerMessage(
                            text: copy.skippedRestoreBanner,
                            systemImage: "arrow.triangle.2.circlepath.circle.fill",
                            tint: RoomServicePalette.review
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
                } else if let operation = model.currentOperation {
                    ProgressView(copy.progressTitle(for: operation))
                        .controlSize(.small)
                } else {
                    Button(copy.toolbarRunScan) {
                        model.runScan()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!model.canScan)
                }

                if model.destination == .results {
                    Button(copy.toolbarQuarantineSelected) {
                        model.requestCleanup()
                    }
                    .disabled(!model.canCleanupSelection)
                }
            }
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                RoomServiceMark()
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
                    ForEach(RoomServiceDestination.allCases) { destination in
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
                        .foregroundStyle(RoomServicePalette.ink)
                    Text(copy.sidebarDetail)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(RoomServicePalette.muted)
                }
            }
            .padding(14)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            ZStack {
                LinearGradient(
                    colors: [RoomServicePalette.sidebar, RoomServicePalette.sidebarSecondary],
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
    @EnvironmentObject private var model: RoomServiceAppModel
    private var copy: RoomServiceCopy { model.copy }

    private let grid = [
        GridItem(.adaptive(minimum: 220), spacing: 16),
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
                                    .background(RoomServicePalette.accent.opacity(0.12), in: Capsule())
                                    .foregroundStyle(RoomServicePalette.accent)

                                Text(copy.heroScope)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(RoomServicePalette.muted)
                            }

                            WordmarkLockup(subtitle: copy.tagline)

                            Text(copy.heroDescription)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(RoomServicePalette.muted)
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
                            RoomServiceMark()
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
                        value: RoomServiceFormatters.byteString(model.reclaimableBytes),
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
                                .foregroundStyle(RoomServicePalette.ink)

                            ForEach(RiskLevel.allCases, id: \.self) { risk in
                                HStack(alignment: .top, spacing: 12) {
                                    RiskBadge(risk: risk, language: model.language)
                                    Text(risk.localizedDetail(in: model.language))
                                        .font(.system(size: 13))
                                        .foregroundStyle(RoomServicePalette.muted)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(copy.weeklyTrendTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(RoomServicePalette.ink)

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
                                    .foregroundStyle(RoomServicePalette.muted)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(copy.recentActivityTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(RoomServicePalette.ink)

                            if let latest = model.latestCleanupEntry {
                                Text(latest.summary)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(RoomServicePalette.ink)
                                Text(RoomServiceFormatters.dateTimeString(latest.createdAt))
                                    .font(.system(size: 12))
                                    .foregroundStyle(RoomServicePalette.muted)
                                Text(copy.latestCleanupStats(items: latest.itemCount, bytes: RoomServiceFormatters.byteString(latest.totalBytes)))
                                    .font(.system(size: 13))
                                    .foregroundStyle(RoomServicePalette.muted)
                            } else {
                                Text(copy.noRecentActivity)
                                    .font(.system(size: 13))
                                    .foregroundStyle(RoomServicePalette.muted)
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
    @EnvironmentObject private var model: RoomServiceAppModel
    private var copy: RoomServiceCopy { model.copy }

    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 16) {
                resultsHeader
                HStack(spacing: 12) {
                    InfoChip(title: copy.visibleItemsLabel, value: "\(model.filteredItems.count)", symbolName: "shippingbox.fill")
                    InfoChip(title: copy.visibleSizeLabel, value: RoomServiceFormatters.byteString(model.visibleBytes), symbolName: "internaldrive.fill")
                    InfoChip(title: copy.selectedLabel, value: "\(model.selectedScanItems.count)", symbolName: "checkmark.circle.fill")
                }

                SurfaceCard(padding: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        filterBar
                            .padding(18)

                        if model.filteredItems.isEmpty {
                            emptyResults
                                .padding(.horizontal, 18)
                                .padding(.bottom, 18)
                        } else {
                            Table(model.filteredItems, selection: $model.selectedScanItemIDs) {
                                TableColumn(copy.categoryFilterLabel) { item in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Image(systemName: item.category.symbolName)
                                            Text(item.category.displayName)
                                        }
                                        if let groupName = item.groupName {
                                            Text(groupName)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(RoomServicePalette.muted)
                                        }
                                    }
                                }
                                TableColumn(copy.riskFilterLabel) { item in
                                    RiskBadge(risk: item.risk, language: model.language)
                                }
                                TableColumn(copy.bytesMetricTitle) { item in
                                    Text(RoomServiceFormatters.byteString(item.bytes))
                                        .font(.system(.body, design: .monospaced))
                                }
                                TableColumn(copy.pathTitle) { item in
                                    Text(item.path)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
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
                                    .foregroundStyle(RoomServicePalette.muted)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            inspector
                .frame(width: 320)
        }
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
                Text(copy.visibleSummary(count: model.filteredItems.count, bytes: RoomServiceFormatters.byteString(model.visibleBytes)))
                    .font(.system(size: 13))
                    .foregroundStyle(RoomServicePalette.muted)
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

    private var filterBar: some View {
        HStack(spacing: 12) {
            TextField(copy.filterPlaceholder, text: $model.searchText)
                .textFieldStyle(.roundedBorder)

            Picker(copy.categoryFilterLabel, selection: $model.categoryFilter) {
                Text(copy.allCategories).tag(CleanupCategory?.none)
                ForEach(CleanupCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(CleanupCategory?.some(category))
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

            Picker(copy.sortLabel, selection: $model.sortOption) {
                ForEach(ScanSortOption.allCases) { option in
                    Text(option.title(in: model.language)).tag(option)
                }
            }
            .frame(width: 140)

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
                        Button(category.displayName) {
                            model.selectVisibleResults(for: category)
                        }
                    }
                }
            }
        }
    }

    private var emptyResults: some View {
        VStack(spacing: 18) {
            RoomServiceMark()
                .frame(width: 82, height: 82)

            Text(model.scanSummary == nil ? copy.emptyResultsBeforeScan : copy.emptyResultsFiltered)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(RoomServicePalette.ink)

            Text(copy.emptyResultsDetail)
                .font(.system(size: 13))
                .foregroundStyle(RoomServicePalette.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }

    private var inspector: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(copy.inspectorTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                if let item = model.primarySelectedItem {
                    detailCard(for: item)
                } else if !model.selectedScanItems.isEmpty {
                    batchDetailCard
                } else {
                    Text(copy.inspectorEmpty)
                        .font(.system(size: 13))
                        .foregroundStyle(RoomServicePalette.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.thinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.34), lineWidth: 1)
                                )
                        )
                }

                Spacer()
            }
        }
    }

    private func detailCard(for item: ScanItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(item.category.displayName, systemImage: item.category.symbolName)
                .font(.system(size: 15, weight: .bold))

            RiskBadge(risk: item.risk, language: model.language)
            Text(RoomServiceFormatters.byteString(item.bytes))
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Group {
                Text(copy.pathTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(RoomServicePalette.muted)
                Text(item.path)
                    .font(.system(size: 12))
                    .textSelection(.enabled)
            }

            Group {
                Text(copy.cleanupNoteTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(RoomServicePalette.muted)
                Text(item.category.localizedNote(in: model.language))
                    .font(.system(size: 13))
                    .foregroundStyle(RoomServicePalette.ink)
            }

            Group {
                Text(copy.riskGuidanceTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(RoomServicePalette.muted)
                Text(item.risk.localizedDetail(in: model.language))
                    .font(.system(size: 13))
                    .foregroundStyle(RoomServicePalette.muted)
            }

            if let groupName = item.groupName {
                Group {
                    Text(copy.groupTitle)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(RoomServicePalette.muted)
                    Text(groupName)
                        .font(.system(size: 13))
                        .foregroundStyle(RoomServicePalette.ink)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(copy.quickActionsTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(RoomServicePalette.muted)
                HStack {
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
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.34), lineWidth: 1)
                )
        )
    }

    private var batchDetailCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(copy.batchCleanupTitle)
                .font(.system(size: 15, weight: .bold))
            Text(copy.selectedItemsTitle(count: model.selectedScanItems.count))
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(RoomServiceFormatters.byteString(model.selectedScanItems.reduce(0) { $0 + $1.bytes }))
                .font(.system(size: 14, weight: .semibold))
            Text(copy.batchCleanupDetail)
                .font(.system(size: 13))
                .foregroundStyle(RoomServicePalette.muted)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.34), lineWidth: 1)
                )
        )
    }
}

struct HistoryScreen: View {
    @EnvironmentObject private var model: RoomServiceAppModel
    private var copy: RoomServiceCopy { model.copy }

    var body: some View {
        HStack(spacing: 18) {
            SurfaceCard(padding: 0) {
                List(selection: Binding(
                    get: { model.selectedHistoryID },
                    set: { model.selectHistory(id: $0) }
                )) {
                    ForEach(model.historyEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Label(entry.displayName, systemImage: entry.kind == .delete ? "archivebox.fill" : "arrow.uturn.backward.circle.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                Spacer()
                                Text(RoomServiceFormatters.byteString(entry.totalBytes))
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundStyle(RoomServicePalette.muted)
                            }
                            Text(entry.summary)
                                .font(.system(size: 12))
                            Text(RoomServiceFormatters.dateTimeString(entry.createdAt))
                                .font(.system(size: 11))
                                .foregroundStyle(RoomServicePalette.muted)
                        }
                        .padding(.vertical, 6)
                        .tag(Optional(entry.id))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .frame(minWidth: 320)

            VStack(alignment: .leading, spacing: 16) {
                if let entry = model.selectedHistoryEntry {
                    SurfaceCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.displayName)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                Text(entry.summary)
                                    .font(.system(size: 14))
                                    .foregroundStyle(RoomServicePalette.muted)
                            }
                            Spacer()
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

                    HStack(spacing: 16) {
                        MetricCard(
                            title: copy.itemsMetricTitle,
                            value: "\(entry.itemCount)",
                            detail: copy.itemsMetricDetail,
                            symbolName: "shippingbox.fill"
                        )
                        MetricCard(
                            title: copy.bytesMetricTitle,
                            value: RoomServiceFormatters.byteString(entry.totalBytes),
                            detail: copy.bytesMetricDetail,
                            symbolName: "internaldrive.fill"
                        )
                    }

                    if let manifest = model.selectedHistoryManifest {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(copy.manifestItemsTitle)
                                    .font(.system(size: 16, weight: .bold))
                                List(manifest.items) { item in
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(item.category.displayName)
                                                .font(.system(size: 13, weight: .semibold))
                                            Spacer()
                                            RiskBadge(risk: item.risk, language: model.language)
                                        }
                                        Text(item.originalPath)
                                            .font(.system(size: 12))
                                            .foregroundStyle(RoomServicePalette.muted)
                                            .textSelection(.enabled)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .frame(maxHeight: .infinity)
                                .scrollContentBackground(.hidden)
                            }
                        }
                    } else {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(copy.noManifestPreview)
                                    .font(.system(size: 12))
                                    .foregroundStyle(RoomServicePalette.muted)
                                if let sourceActionID = entry.sourceActionID {
                                    Text("\(copy.sourceActionPrefix) \(sourceActionID)")
                                        .font(.system(size: 12))
                                        .foregroundStyle(RoomServicePalette.muted)
                                }
                            }
                        }
                    }
                } else {
                    SurfaceCard {
                        Text(copy.historyEmpty)
                            .font(.system(size: 14))
                            .foregroundStyle(RoomServicePalette.muted)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct SettingsScreen: View {
    @EnvironmentObject private var model: RoomServiceAppModel
    private var copy: RoomServiceCopy { model.copy }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(copy.settingsTitle)
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.updatesTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.updatesDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(RoomServicePalette.muted)

                        UpdateStatusCard(showAutoCheckToggle: true)
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.languageTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.languageDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(RoomServicePalette.muted)

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
                            .foregroundStyle(RoomServicePalette.muted)

                        if model.excludedPaths.isEmpty {
                            Text(copy.noExclusions)
                                .font(.system(size: 13))
                                .foregroundStyle(RoomServicePalette.muted)
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
                            .foregroundStyle(RoomServicePalette.muted)

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
                            .foregroundStyle(RoomServicePalette.muted)

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
                            .foregroundStyle(RoomServicePalette.muted)
                    }
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(copy.fullDiskAccessTitle)
                            .font(.system(size: 18, weight: .bold))
                        Text(copy.fullDiskAccessDescription)
                            .font(.system(size: 13))
                            .foregroundStyle(RoomServicePalette.muted)

                        Text(copy.fullDiskAccessSteps)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(RoomServicePalette.ink)

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
                            .foregroundStyle(RoomServicePalette.muted)
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
                                    .foregroundStyle(RoomServicePalette.muted)
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
                                .foregroundStyle(RoomServicePalette.muted)
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
                                                    tint: item.kind == .appManaged ? RoomServicePalette.accent : RoomServicePalette.muted
                                                )
                                            }
                                            Text(item.detail)
                                                .font(.system(size: 12))
                                                .foregroundStyle(RoomServicePalette.muted)
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
                            Link(copy.website, destination: RoomServiceLinks.website)
                            Link(copy.support, destination: RoomServiceLinks.support)
                            Link(copy.sponsor, destination: RoomServiceLinks.sponsor)
                            Link(copy.security, destination: RoomServiceLinks.securityEmail)
                        }
                        .font(.system(size: 13, weight: .semibold))

                        Text(copy.supportDeveloperDetail)
                            .font(.system(size: 13))
                            .foregroundStyle(RoomServicePalette.muted)
                    }
                }
            }
            .padding(10)
        }
    }
}

struct OnboardingSheet: View {
    @EnvironmentObject private var model: RoomServiceAppModel

    private var copy: RoomServiceCopy { model.copy }

    var body: some View {
        ZStack {
            RoomServiceBackground()

            VStack(alignment: .leading, spacing: 22) {
                HeroPanel {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 16) {
                            RoomServiceMark()
                                .frame(width: 76, height: 76)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(copy.onboardingTitle)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                Text(copy.onboardingDetail)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(RoomServicePalette.muted)
                            }
                        }

                        HStack(spacing: 12) {
                            InfoChip(title: copy.scanRootsLabel, value: "\(model.searchRoots.count)", symbolName: "folder.fill")
                            InfoChip(title: copy.exclusionsLabel, value: "\(model.excludedPaths.count)", symbolName: "eye.slash.fill")
                            InfoChip(title: copy.selectedCategoriesLabel, value: "\(model.includedCategories.count)", symbolName: "square.grid.2x2.fill")
                        }
                    }
                }

                HStack(alignment: .top, spacing: 16) {
                    onboardingStep(
                        title: copy.onboardingStepOneTitle,
                        detail: copy.onboardingStepOneDetail,
                        symbol: "lock.shield.fill",
                        tint: RoomServicePalette.accent
                    )
                    onboardingStep(
                        title: copy.onboardingStepTwoTitle,
                        detail: copy.onboardingStepTwoDetail,
                        symbol: "slider.horizontal.3",
                        tint: RoomServicePalette.review
                    )
                    onboardingStep(
                        title: copy.onboardingStepThreeTitle,
                        detail: copy.onboardingStepThreeDetail,
                        symbol: "clock.arrow.circlepath",
                        tint: RoomServicePalette.safe
                    )
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(copy.fullDiskAccessTitle)
                            .font(.system(size: 16, weight: .bold))
                        Text(copy.fullDiskAccessSteps)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(RoomServicePalette.ink)
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
                    .foregroundStyle(RoomServicePalette.ink)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(RoomServicePalette.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AboutScreen: View {
    @EnvironmentObject private var model: RoomServiceAppModel

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? version
        return "\(version) (\(build))"
    }

    private var copy: RoomServiceCopy { model.copy }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WordmarkLockup(subtitle: copy.tagline)

                Text(copy.aboutDescription)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(RoomServicePalette.muted)
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
                            Link(copy.website, destination: RoomServiceLinks.website)
                            Link(copy.repository, destination: RoomServiceLinks.repository)
                            Link(copy.support, destination: RoomServiceLinks.support)
                            Link(copy.sponsor, destination: RoomServiceLinks.sponsor)
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
                            .foregroundStyle(RoomServicePalette.muted)
                    }
                }
            }
            .padding(10)
        }
    }
}

struct UpdateStatusCard: View {
    @EnvironmentObject private var model: RoomServiceAppModel

    let showAutoCheckToggle: Bool

    private var copy: RoomServiceCopy { model.copy }

    private var tint: Color {
        switch model.updateState {
        case .idle:
            return RoomServicePalette.accent
        case .checking:
            return RoomServicePalette.accent
        case .upToDate:
            return RoomServicePalette.safe
        case .available:
            return RoomServicePalette.accent
        case .unsupported:
            return RoomServicePalette.review
        case .failed:
            return RoomServicePalette.danger
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    UpdateBadge(title: copy.updateBadgeTitle(for: model.updateState), tint: tint)
                    Text(copy.updateStatusText(for: model.updateState))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(RoomServicePalette.ink)
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
                    .foregroundStyle(RoomServicePalette.muted)
            }

            VStack(alignment: .leading, spacing: 8) {
                if let checkedAt = model.lastUpdateCheckDate {
                    metadataRow(title: copy.lastCheckedLabel, value: RoomServiceFormatters.dateTimeString(checkedAt))
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
                    .foregroundStyle(RoomServicePalette.muted)
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
                .foregroundStyle(RoomServicePalette.muted)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(RoomServicePalette.ink)
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
                    .fill(RoomServicePalette.accent.opacity(0.08))

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
                        colors: [RoomServicePalette.accent, RoomServicePalette.safe],
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
    return prefix + RoomServiceFormatters.byteString(abs(value))
}
