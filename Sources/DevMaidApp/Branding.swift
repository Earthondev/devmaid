import SwiftUI
import DevMaidKit

enum DevMaidPalette {
    static let accent = Color(red: 0.16, green: 0.52, blue: 0.82)
    static let accentSecondary = Color(red: 0.23, green: 0.80, blue: 0.77)
    static let accentTertiary = Color(red: 0.53, green: 0.72, blue: 0.96)
    static let canvas = Color(red: 0.95, green: 0.98, blue: 1.0)
    static let mist = Color.white.opacity(0.42)
    static let card = Color.white.opacity(0.42)
    static let cardStrong = Color.white.opacity(0.58)
    static let border = Color.white.opacity(0.58)
    static let borderStrong = Color.black.opacity(0.12)
    static let borderAccent = accent.opacity(0.14)
    static let sidebar = Color(red: 0.16, green: 0.24, blue: 0.34)
    static let sidebarSecondary = Color(red: 0.23, green: 0.34, blue: 0.45)
    static let ink = Color(red: 0.12, green: 0.16, blue: 0.22)
    static let muted = Color(red: 0.37, green: 0.45, blue: 0.55)
    static let safe = Color(red: 0.09, green: 0.68, blue: 0.55)
    static let review = Color(red: 0.88, green: 0.58, blue: 0.18)
    static let danger = Color(red: 0.82, green: 0.30, blue: 0.30)
    static let glow = accent.opacity(0.16)
    static let glowSecondary = accentSecondary.opacity(0.18)

    static func color(for risk: RiskLevel) -> Color {
        switch risk {
        case .safe:
            return safe
        case .review:
            return review
        case .danger:
            return danger
        }
    }
}

struct DevMaidBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.98, blue: 1.0),
                    Color(red: 0.93, green: 0.98, blue: 0.99),
                    Color(red: 0.96, green: 0.97, blue: 0.99),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 340, style: .continuous)
                .fill(Color.white.opacity(0.18))
                .frame(width: 880, height: 500)
                .rotationEffect(.degrees(-12))
                .offset(x: 200, y: -220)
                .blur(radius: 24)

            Circle()
                .fill(DevMaidPalette.accent.opacity(0.18))
                .frame(width: 540, height: 540)
                .offset(x: 420, y: -280)
                .blur(radius: 34)

            Circle()
                .fill(DevMaidPalette.accentSecondary.opacity(0.14))
                .frame(width: 420, height: 420)
                .offset(x: -260, y: 320)
                .blur(radius: 34)

            Circle()
                .fill(DevMaidPalette.accentTertiary.opacity(0.12))
                .frame(width: 360, height: 360)
                .offset(x: -420, y: -180)
                .blur(radius: 28)

            VStack {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.76),
                        Color.white.opacity(0.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                Spacer()
            }
        }
    }
}

struct DevMaidMark: View {
    @State private var isFloating = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DevMaidPalette.accent, DevMaidPalette.accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .padding(18)

            VStack(spacing: 11) {
                Capsule()
                    .fill(Color.white.opacity(0.92))
                    .frame(width: 68, height: 14)

                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.92))
                    .frame(width: 86, height: 18)

                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.88))
                    .frame(width: 104, height: 22)
            }

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.94))
                        .offset(x: -16, y: 18)
                        .rotationEffect(.degrees(isFloating ? 10 : -4))
                        .scaleEffect(isFloating ? 1.08 : 0.92)
                }
                Spacer()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(isFloating ? 1.0 : 0.97)
        .offset(y: isFloating ? -3 : 3)
        .shadow(color: DevMaidPalette.glow, radius: 22, y: 14)
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.52), lineWidth: 1.2)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }
}

struct WordmarkLockup: View {
    let subtitle: String

    init(subtitle: String = "Storage cleanup for developers") {
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 16) {
            DevMaidMark()
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text("DevMaid")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(DevMaidPalette.ink)
                Text(subtitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DevMaidPalette.muted)
            }
        }
    }
}

struct RiskBadge: View {
    let risk: RiskLevel
    let language: AppLanguage

    var body: some View {
        Label(risk.localizedDisplayName(in: language), systemImage: risk.symbolName)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(DevMaidPalette.color(for: risk).opacity(0.14), in: Capsule())
            .foregroundStyle(DevMaidPalette.color(for: risk))
    }
}

struct SurfaceCard<Content: View>: View {
    let padding: CGFloat
    @ViewBuilder let content: Content

    init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DevMaidPalette.cardStrong,
                                        DevMaidPalette.mist.opacity(0.18),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(DevMaidPalette.border, lineWidth: 1.1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(DevMaidPalette.borderStrong, lineWidth: 0.7)
                            .blur(radius: 0.2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(DevMaidPalette.borderAccent, lineWidth: 0.8)
                            .padding(1)
                    )
                    .shadow(color: Color.white.opacity(0.34), radius: 1, y: 1)
                    .shadow(color: Color.black.opacity(0.08), radius: 28, y: 18)
            )
    }
}

struct HeroPanel<Content: View>: View {
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(26)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.60),
                                        Color(red: 0.89, green: 0.96, blue: 1.0).opacity(0.42),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(DevMaidPalette.border, lineWidth: 1.2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(DevMaidPalette.borderStrong.opacity(0.7), lineWidth: 0.7)
                            .padding(1)
                    )
                    .shadow(color: DevMaidPalette.glow, radius: 26, y: 18)
            )
    }
}

struct SectionTitleRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(DevMaidPalette.ink)
                Text(detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DevMaidPalette.muted)
            }
            Spacer()
        }
    }
}

struct InfoChip: View {
    let title: String
    let value: String
    let symbolName: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbolName)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 28, height: 28)
                .background(DevMaidPalette.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(DevMaidPalette.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(DevMaidPalette.ink)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DevMaidPalette.muted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(DevMaidPalette.border, lineWidth: 1.1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(DevMaidPalette.borderStrong.opacity(0.65), lineWidth: 0.65)
                .padding(0.8)
        )
        .shadow(color: Color.white.opacity(0.18), radius: 1, y: 1)
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 6)
    }
}

struct FeatureBullet: View {
    let text: String
    let symbolName: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbolName)
                .font(.system(size: 11, weight: .bold))
                .frame(width: 24, height: 24)
                .background(DevMaidPalette.accent.opacity(0.12), in: Circle())
                .foregroundStyle(DevMaidPalette.accent)

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DevMaidPalette.ink)
        }
    }
}

struct CategoryPill: View {
    let category: CleanupCategory
    let isEnabled: Bool
    let bytes: Int64
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(category.displayName.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(0.8)
                        .foregroundStyle(DevMaidPalette.muted)
                    Label(category.localizedShortDescription(in: language), systemImage: category.symbolName)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(DevMaidPalette.ink)
                }
                Spacer(minLength: 8)
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isEnabled ? DevMaidPalette.accent : DevMaidPalette.muted.opacity(0.7))
            }

            Text(category.localizedNote(in: language))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DevMaidPalette.muted)
                .lineLimit(2)

            HStack {
                RiskBadge(risk: category.risk, language: language)
                Spacer()
                Text(bytes > 0 ? DevMaidFormatters.byteString(bytes) : (language == .thai ? "รวมไว้แล้ว" : "Included"))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(DevMaidPalette.ink)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(DevMaidPalette.card.opacity(0.42))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isEnabled ? DevMaidPalette.accent.opacity(0.36) : DevMaidPalette.border, lineWidth: 1.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(DevMaidPalette.borderStrong.opacity(isEnabled ? 0.35 : 0.55), lineWidth: 0.65)
                        .padding(0.8)
                )
        )
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let detail: String
    let symbolName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: symbolName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DevMaidPalette.accent)
                    .frame(width: 34, height: 34)
                    .background(DevMaidPalette.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(DevMaidPalette.ink)

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DevMaidPalette.ink)

            Text(detail)
                .font(.system(size: 12))
                .foregroundStyle(DevMaidPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(DevMaidPalette.cardStrong.opacity(0.52))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(DevMaidPalette.border, lineWidth: 1.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(DevMaidPalette.borderStrong.opacity(0.65), lineWidth: 0.7)
                        .padding(0.8)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 24, y: 18)
        )
    }
}

struct BannerMessage: View {
    let text: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(text)
                .lineLimit(2)
            Spacer()
        }
        .font(.system(size: 13, weight: .medium))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tint.opacity(0.28), lineWidth: 1.1)
        )
        .foregroundStyle(tint)
    }
}

struct SidebarNavigationButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 18)

                Text(title)
                    .font(.system(size: 13, weight: .semibold))

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.18) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? Color.white.opacity(0.34) : Color.clear, lineWidth: 1.1)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white.opacity(isSelected ? 0.98 : 0.84))
    }
}

struct UpdateBadge: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.14), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(tint.opacity(0.3), lineWidth: 1.1)
            )
            .foregroundStyle(tint)
    }
}

struct WorkflowStepPill: View {
    let index: Int
    let title: String
    let detail: String
    let symbolName: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.14))
                    .frame(width: 34, height: 34)
                Image(systemName: symbolName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(index). \(title)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(DevMaidPalette.ink)
                    .lineLimit(1)
                Text(detail)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DevMaidPalette.muted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .topLeading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(DevMaidPalette.border, lineWidth: 1.1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(DevMaidPalette.borderStrong.opacity(0.55), lineWidth: 0.65)
                .padding(0.8)
        )
    }
}

struct ActionDeckCard: View {
    let eyebrow: String
    let title: String
    let detail: String
    let symbolName: String
    let tint: Color
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(eyebrow.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(0.8)
                            .foregroundStyle(DevMaidPalette.muted)
                        Text(title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(DevMaidPalette.ink)
                    }
                    Spacer()
                    Image(systemName: symbolName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(tint)
                        .frame(width: 36, height: 36)
                        .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Text(detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DevMaidPalette.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Button(buttonTitle, action: action)
                    .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct GroupSummaryCard: View {
    let title: String
    let itemCount: Int
    let totalBytes: Int64
    let risk: RiskLevel
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(DevMaidPalette.ink)
                        .lineLimit(2)
                    Text(language == .thai ? "\(itemCount) รายการ" : "\(itemCount) items")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DevMaidPalette.muted)
                }
                Spacer(minLength: 8)
                RiskBadge(risk: risk, language: language)
            }

            Text(DevMaidFormatters.byteString(totalBytes))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(DevMaidPalette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(DevMaidPalette.border, lineWidth: 1.1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(DevMaidPalette.borderStrong.opacity(0.55), lineWidth: 0.65)
                .padding(0.8)
        )
    }
}

struct ResultLocationCell: View {
    let title: String
    let parentPath: String
    let groupName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DevMaidPalette.accent)

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DevMaidPalette.ink)
                    .lineLimit(1)

                if let groupName, !groupName.isEmpty {
                    Text(groupName)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(DevMaidPalette.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DevMaidPalette.accent.opacity(0.10), in: Capsule())
                        .lineLimit(1)
                }
            }

            Text(parentPath)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(DevMaidPalette.muted)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

struct ResultCategoryCell: View {
    let category: CleanupCategory
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(category.localizedDisplayName(in: language), systemImage: category.symbolName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DevMaidPalette.ink)

            Text(category.localizedShortDescription(in: language))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DevMaidPalette.muted)
                .lineLimit(2)
        }
    }
}

struct DetailSectionCard<Content: View>: View {
    let title: String
    let detail: String?
    @ViewBuilder let content: Content

    init(title: String, detail: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detail = detail
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(DevMaidPalette.muted)

                if let detail, !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DevMaidPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(DevMaidPalette.border, lineWidth: 1.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(DevMaidPalette.borderStrong.opacity(0.55), lineWidth: 0.65)
                        .padding(0.8)
                )
        )
        .shadow(color: Color.white.opacity(0.18), radius: 1, y: 1)
        .shadow(color: Color.black.opacity(0.04), radius: 12, y: 8)
    }
}

struct ActionKindBadge: View {
    let kind: HistoryActionKind
    let language: AppLanguage

    var tint: Color {
        switch kind {
        case .delete:
            return DevMaidPalette.review
        case .restore:
            return DevMaidPalette.safe
        }
    }

    var systemImage: String {
        switch kind {
        case .delete:
            return "archivebox.fill"
        case .restore:
            return "arrow.uturn.backward.circle.fill"
        }
    }

    var body: some View {
        Label(kind.localizedDisplayName(in: language), systemImage: systemImage)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.14), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(tint.opacity(0.26), lineWidth: 1.1)
            )
            .foregroundStyle(tint)
    }
}
