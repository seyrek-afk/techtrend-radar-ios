import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    @State private var selectedTab: AnalysisTab = .why
    @State private var vm = StockDetailViewModel()

    private var color: Color { .category(category.color) }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Category header
                    CategoryHeader(category: category, color: color)

                    // Analysis tabs
                    AnalysisTabs(
                        selected: $selectedTab,
                        category: category,
                        color: color
                    )

                    // Stocks section
                    StocksSection(vm: vm, category: category, color: color)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { vm.loadStocks(for: category.id) }
        .onDisappear { vm.cancel() }
    }
}

// MARK: - Category Header

struct CategoryHeader: View {
    let category: Category
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 52, height: 52)
                Image(systemName: sfSymbol(for: category.icon))
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.description)
                    .font(TTFont.body)
                    .foregroundStyle(Color.slateText)

                HStack(spacing: 8) {
                    KeywordBadge(text: category.sectorLabel, color: color)
                    KeywordBadge(text: "\(category.tickers.count) hisse", color: .slateMuted)
                }
            }
            Spacer()
        }
        .padding(14)
        .glassCard()
    }
}

// MARK: - Analysis Tabs

enum AnalysisTab: String, CaseIterable {
    case why   = "Neden"
    case near  = "Yakın Vade"
    case mid   = "Orta Vade"
    case opp   = "Fırsat"
}

struct AnalysisTabs: View {
    @Binding var selected: AnalysisTab
    let category: Category
    let color: Color

    private var content: String {
        switch selected {
        case .why:  return category.whyTrending
        case .near: return category.nearTerm
        case .mid:  return category.midTerm
        case .opp:  return category.opportunity
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tab buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AnalysisTab.allCases, id: \.self) { tab in
                        Button(tab.rawValue) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selected = tab
                            }
                        }
                        .font(TTFont.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(selected == tab ? color : Color.slateMuted)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selected == tab ? color.opacity(0.12) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(
                                            selected == tab ? color.opacity(0.4) : Color.white.opacity(0.06),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                }
            }

            // Content
            Text(content)
                .font(TTFont.body)
                .foregroundStyle(Color.slateText)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.bgSurface.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(color.opacity(0.12), lineWidth: 1)
                        )
                )
        }
        .padding(14)
        .glassCard()
    }
}

// MARK: - Stocks Section

struct StocksSection: View {
    let vm: StockDetailViewModel
    let category: Category
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "İlgili Hisseler")

            if vm.isLoadingStocks {
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        SkeletonView().frame(height: 60)
                    }
                }
            } else if let err = vm.stocksError {
                Text(err)
                    .font(TTFont.caption)
                    .foregroundStyle(Color.negative)
                    .padding(12)
            } else {
                ForEach(vm.stocks) { stock in
                    NavigationLink(value: stock.ticker) {
                        StockSummaryRow(stock: stock, color: color)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationDestination(for: String.self) { ticker in
            StockDetailView(ticker: ticker)
        }
    }
}

// MARK: - Stock Summary Row

struct StockSummaryRow: View {
    let stock: StockSummary
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(stock.ticker)
                    .font(TTFont.mono)
                    .foregroundStyle(color)
                if let name = stock.name {
                    Text(name)
                        .font(TTFont.caption)
                        .foregroundStyle(Color.slateMuted)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                if let price = stock.price {
                    Text(String(format: "$%.2f", price))
                        .font(TTFont.mono)
                        .foregroundStyle(Color.slateText)
                }
                if let change = stock.changePctDay {
                    PriceChangeBadge(value: change)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassCard(radius: 10)
    }
}
