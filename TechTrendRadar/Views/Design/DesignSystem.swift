import SwiftUI

// MARK: - Color Palette

extension Color {
    static let bgBase      = Color(red: 0.059, green: 0.090, blue: 0.165)   // #0F172A
    static let bgSurface   = Color(red: 0.118, green: 0.161, blue: 0.235)   // #1E293B
    static let slateText   = Color(red: 0.698, green: 0.745, blue: 0.808)   // slate-300
    static let slateMuted  = Color(red: 0.427, green: 0.478, blue: 0.549)   // slate-500
    static let accent      = Color(red: 0.220, green: 0.745, blue: 0.973)   // #38BDF8 sky
    static let accentViolet = Color(red: 0.506, green: 0.549, blue: 0.973)  // #818CF8
    static let positive    = Color(red: 0.133, green: 0.773, blue: 0.369)   // #22C55E
    static let negative    = Color(red: 0.937, green: 0.267, blue: 0.267)   // #EF4444
    static let warning     = Color(red: 0.961, green: 0.620, blue: 0.043)   // #F59E0B

    static func category(_ key: String) -> Color {
        switch key {
        case "sky":     return Color(red: 0.220, green: 0.745, blue: 0.973)
        case "violet":  return Color(red: 0.698, green: 0.549, blue: 0.980)
        case "amber":   return Color(red: 0.961, green: 0.620, blue: 0.043)
        case "teal":    return Color(red: 0.200, green: 0.827, blue: 0.710)
        case "purple":  return Color(red: 0.667, green: 0.333, blue: 0.933)
        case "cyan":    return Color(red: 0.220, green: 0.886, blue: 0.976)
        case "emerald": return Color(red: 0.063, green: 0.741, blue: 0.455)
        case "indigo":  return Color(red: 0.388, green: 0.400, blue: 0.945)
        case "orange":  return Color(red: 0.976, green: 0.451, blue: 0.086)
        case "rose":    return Color(red: 0.953, green: 0.267, blue: 0.506)
        case "red":     return Color(red: 0.937, green: 0.267, blue: 0.267)
        default:        return .accent
        }
    }

    static func signalColor(_ direction: String) -> Color {
        switch direction {
        case "STRONG_BUY":  return .positive
        case "BUY":         return Color(red: 0.063, green: 0.741, blue: 0.455)
        case "HOLD":        return .warning
        case "SELL":        return Color(red: 0.976, green: 0.451, blue: 0.086)
        case "STRONG_SELL": return .negative
        default:            return .slateMuted
        }
    }

    static func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A": return .positive
        case "B": return .accent
        case "C": return .warning
        case "D": return Color(red: 0.976, green: 0.451, blue: 0.086)
        case "F": return .negative
        default:  return .slateMuted
        }
    }
}

// MARK: - Typography

enum TTFont {
    static let title    = Font.system(size: 22, weight: .bold, design: .default)
    static let heading  = Font.system(size: 17, weight: .semibold)
    static let body     = Font.system(size: 15, weight: .regular)
    static let caption  = Font.system(size: 12, weight: .medium)
    static let label    = Font.system(size: 10, weight: .semibold, design: .default)
    static let mono     = Font.system(size: 14, weight: .medium, design: .monospaced)
    static let monoLg   = Font.system(size: 20, weight: .semibold, design: .monospaced)
}

// MARK: - Glass Card

struct GlassCardStyle: ViewModifier {
    var radius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: radius)
                    .fill(Color.bgSurface.opacity(0.55))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius))
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                    )
            }
    }
}

extension View {
    func glassCard(radius: CGFloat = 14) -> some View {
        modifier(GlassCardStyle(radius: radius))
    }
}

// MARK: - Skeleton Loader

struct SkeletonView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.bgSurface.opacity(0.8))
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.06), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: phase * (geo.size.width * 1.5) - geo.size.width * 0.5)
                }
                .clipped()
            }
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(TTFont.label)
            .foregroundStyle(Color.slateMuted)
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Price Change Badge

struct PriceChangeBadge: View {
    let value: Double

    private var isPositive: Bool { value >= 0 }
    private var formatted: String {
        String(format: "%@%.2f%%", isPositive ? "+" : "", value * 100)
    }

    var body: some View {
        Text(formatted)
            .font(TTFont.caption)
            .fontWeight(.semibold)
            .foregroundStyle(isPositive ? Color.positive : Color.negative)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((isPositive ? Color.positive : Color.negative).opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - Keyword Badge

struct KeywordBadge: View {
    let text: String
    var color: Color = .accent

    var body: some View {
        Text(text)
            .font(TTFont.label)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .overlay(Capsule().strokeBorder(color.opacity(0.25), lineWidth: 1))
            .clipShape(Capsule())
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(Color.slateMuted)
            Text(message)
                .font(TTFont.body)
                .foregroundStyle(Color.slateMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error State

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.warning)
            Text(message)
                .font(TTFont.body)
                .foregroundStyle(Color.slateText)
                .multilineTextAlignment(.center)
            Button("Tekrar Dene", action: retry)
                .buttonStyle(.bordered)
                .tint(.accent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
