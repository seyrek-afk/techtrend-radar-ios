import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    @State private var selectedTab: AnalysisTab = .why
    @State private var vm = StockDetailViewModel()

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    CategoryHeader(category: category)
                    AnalysisTabs(selected: $selectedTab, category: category)
                    StocksSection(vm: vm, category: category)
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

    var body: some View {
        let color = Color.category(category.color)
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.18)).frame(width: 52, height: 52)
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
    case why  = "Neden"
    case near = "Yakın Vade"
    case mid  = "Orta Vade"
    case opp  = "Fırsat"
}

struct AnalysisTabs: View {
    @Binding var selected: AnalysisTab
    let category: Category

    private var content: String {
        switch selected {
        case .why:  return category.whyTrending
        case .near: return category.nearTerm
        case .mid:  return category.midTerm
        case .opp:  return category.opportunity
        }
    }

    var body: some View {
        let color = Color.category(category.color)
        VStack(alignment: .leading, spacing: 12) {
            tabButtons(color: color)
            contentBox(color: color)
        }
        .padding(14)
        .glassCard()
    }

    private func tabButtons(color: Color) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AnalysisTab.allCases, id: \.self) { tab in
                    tabButton(tab: tab, color: color)
                }
            }
        }
    }

    private func tabButton(tab: AnalysisTab, color: Color) -> some View {
        let isSelected = selected == tab
        return Button(tab.rawValue) {
            withAnimation(.easeInOut(duration: 0.2)) { selected = tab }
        }
        .font(TTFont.caption)
        .fontWeight(.semibold)
        .foregroundStyle(isSelected ? color : Color.slateMuted)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? color.opacity(0.12) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isSelected ? color.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func contentBox(color: Color) -> some View {
        Text(content)
            .font(TTFont.body)
            .foregroundStyle(Color.slateText)
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgSurface.opacity(0.4))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(color.opacity(0.12), lineWidth: 1))
            )
    }
}

// MARK: - Stocks Section

struct StocksSection: View {
    let vm: StockDetailViewModel
    let category: Category

    var body: some View {
        let color = Color.category(category.color)
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "İlgili Hisseler")
            stocksContent(color: color)
        }
        .navigationDestination(for: String.self) { ticker in
            StockDetailView(ticker: ticker)
        }
    }

    @ViewBuilder
    private func stocksContent(color: Color) -> some View {
        if vm.isLoadingStocks {
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in SkeletonView().frame(height: 60) }
            }
        } else if let err = vm.stocksError {
            Text(err).font(TTFont.caption).foregroundStyle(Color.negative).padding(12)
        } else {
            ForEach(vm.stocks) { stock in
                NavigationLink(value: stock.ticker) {
                    StockSummaryRow(stock: stock, color: color)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Stock Summary Row

struct StockSummaryRow: View {
    let stock: StockSummary
    let color: Color

    var body: some View {
        HStack {
            stockInfo
            Spacer()
            priceInfo
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassCard(radius: 10)
    }

    private var stockInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(stock.ticker).font(TTFont.mono).foregroundStyle(color)
            if let name = stock.name {
                Text(name).font(TTFont.caption).foregroundStyle(Color.slateMuted).lineLimit(1)
            }
        }
    }

    private var priceInfo: some View {
        VStack(alignment: .trailing, spacing: 3) {
            if let price = stock.price {
                Text(String(format: "$%.2f", price)).font(TTFont.mono).foregroundStyle(Color.slateText)
            }
            if let change = stock.changePctDay {
                PriceChangeBadge(value: change)
            }
        }
    }
}
