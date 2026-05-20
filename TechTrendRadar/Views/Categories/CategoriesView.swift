import SwiftUI

struct CategoriesView: View {
    @State private var vm = CategoriesViewModel()

    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("TechTrend Radar")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { ConnectorStatusBadge() } }
                .navigationDestination(for: Category.self) { cat in CategoryDetailView(category: cat) }
        }
        .task { vm.load() }
        .onDisappear { vm.cancel() }
        .refreshable { vm.load() }
    }

    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            if vm.isLoading && vm.categories.isEmpty {
                LoadingCategoriesList()
            } else if let err = vm.error, vm.categories.isEmpty {
                ErrorStateView(message: err, retry: vm.load)
            } else {
                categoryList
            }
        }
    }

    private var categoryList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                categoriesSection
                if !vm.emerging.isEmpty { emergingSection }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var categoriesSection: some View {
        Section {
            VStack(spacing: 10) {
                ForEach(vm.categories) { cat in
                    NavigationLink(value: cat) { CategoryRow(category: cat) }
                        .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        } header: {
            sectionHeader("Tech Kategorileri")
        }
    }

    private var emergingSection: some View {
        Section {
            VStack(spacing: 10) {
                ForEach(vm.emerging) { opp in EmergingRow(opportunity: opp) }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        } header: {
            sectionHeader("Gelişen Fırsatlar")
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        SectionHeader(title: title)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.bgBase)
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category

    var body: some View {
        let color = Color.category(category.color)
        HStack(spacing: 14) {
            categoryIcon(color: color)
            categoryInfo
            Spacer()
            tickerCount(color: color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard()
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(color.opacity(0.18), lineWidth: 1))
    }

    private func categoryIcon(color: Color) -> some View {
        ZStack {
            Circle().fill(color.opacity(0.15)).frame(width: 44, height: 44)
            Image(systemName: sfSymbol(for: category.icon))
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(color)
        }
    }

    private var categoryInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(category.name)
                .font(TTFont.heading)
                .foregroundStyle(Color.slateText)
            Text(category.description)
                .font(TTFont.caption)
                .foregroundStyle(Color.slateMuted)
                .lineLimit(1)
        }
    }

    private func tickerCount(color: Color) -> some View {
        HStack(spacing: 6) {
            Text("\(category.tickers.count)")
                .font(TTFont.caption)
                .foregroundStyle(color)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.slateMuted)
        }
    }
}

// MARK: - Emerging Row

struct EmergingRow: View {
    let opportunity: EmergingOpportunity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            rowHeader
            Text(opportunity.description)
                .font(TTFont.caption)
                .foregroundStyle(Color.slateMuted)
                .lineLimit(2)
            if !opportunity.signalTickers.isEmpty { tickerBadges }
        }
        .padding(14)
        .glassCard()
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.warning.opacity(0.18), lineWidth: 1))
    }

    private var rowHeader: some View {
        HStack {
            Text(opportunity.title)
                .font(TTFont.heading)
                .foregroundStyle(Color.slateText)
            Spacer()
            Text(opportunity.timeline)
                .font(TTFont.label)
                .foregroundStyle(Color.warning)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.warning.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private var tickerBadges: some View {
        HStack(spacing: 6) {
            ForEach(opportunity.signalTickers.prefix(4), id: \.self) { ticker in
                Text(ticker)
                    .font(TTFont.label)
                    .foregroundStyle(Color.accentViolet)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.accentViolet.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Connector Status Badge

struct ConnectorStatusBadge: View {
    @State private var health: ConnectorHealth?

    private var isHealthy: Bool { health?.status == "ok" }

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isHealthy ? Color.positive : Color.warning)
                .frame(width: 7, height: 7)
                .shadow(color: isHealthy ? Color.positive.opacity(0.6) : .clear, radius: 3)
            Text(isHealthy ? "Canlı" : "Kısmi")
                .font(TTFont.caption)
                .foregroundStyle(Color.slateMuted)
        }
        .task { health = try? await APIService.shared.health() }
    }
}

// MARK: - Loading Skeleton

struct LoadingCategoriesList: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(0..<8, id: \.self) { _ in SkeletonView().frame(height: 70) }
            }
            .padding(16)
        }
    }
}

// MARK: - Icon Mapping

func sfSymbol(for lucideIcon: String) -> String {
    switch lucideIcon {
    case "Cpu":        return "cpu"
    case "Brain":      return "brain.head.profile"
    case "Zap":        return "bolt.fill"
    case "Shield":     return "shield.fill"
    case "Cloud":      return "cloud.fill"
    case "Globe":      return "globe"
    case "Database":   return "cylinder.fill"
    case "Layers":     return "square.3.layers.3d"
    case "Network":    return "network"
    case "Lock":       return "lock.fill"
    case "Activity":   return "waveform.path.ecg"
    case "BarChart":   return "chart.bar.fill"
    case "TrendingUp": return "chart.line.uptrend.xyaxis"
    case "Settings":   return "gearshape.fill"
    case "Monitor":    return "display"
    default:           return "sparkles"
    }
}
