import SwiftUI

struct StockDetailView: View {
    let ticker: String
    @State private var vm = StockDetailViewModel()

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            content
        }
        .navigationTitle(ticker)
        .navigationBarTitleDisplayMode(.inline)
        .task { vm.loadDetail(ticker: ticker) }
        .onDisappear { vm.cancel() }
        .refreshable { vm.loadDetail(ticker: ticker) }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoadingDetail {
            LoadingStockDetail()
        } else if let err = vm.detailError {
            ErrorStateView(message: err) { vm.loadDetail(ticker: ticker) }
        } else if let detail = vm.detail {
            StockDetailContent(detail: detail)
        }
    }
}

// MARK: - Full Detail Content

struct StockDetailContent: View {
    let detail: StockDetail
    @State private var metricsTab: MetricsTab = .fundamental

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                StockPriceHeader(detail: detail)
                descriptionView
                chartView
                healthView
                signalsRow
                metricsView
                sectorView
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let desc = detail.description, !desc.isEmpty {
            Text(desc)
                .font(TTFont.body)
                .foregroundStyle(Color.slateMuted)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .glassCard()
        }
    }

    @ViewBuilder
    private var chartView: some View {
        if !detail.history.isEmpty {
            StockChartView(history: detail.history, changePositive: (detail.changePctDay ?? 0) >= 0)
        }
    }

    @ViewBuilder
    private var healthView: some View {
        if let health = detail.healthScore {
            HealthScoresView(health: health)
        }
    }

    private var signalsRow: some View {
        HStack(spacing: 10) {
            if let sig = detail.signalMedium { SignalCard(signal: sig, horizon: "Orta Vadeli") }
            if let sig = detail.signalLong   { SignalCard(signal: sig, horizon: "Uzun Vadeli") }
        }
    }

    @ViewBuilder
    private var metricsView: some View {
        if detail.fundamentals != nil || detail.technicals != nil {
            StockMetricsView(detail: detail, tab: $metricsTab)
        }
    }

    @ViewBuilder
    private var sectorView: some View {
        if !detail.sectorComparison.isEmpty {
            SectorComparisonView(metrics: detail.sectorComparison)
        }
    }
}

// MARK: - Price Header

struct StockPriceHeader: View {
    let detail: StockDetail

    var body: some View {
        HStack {
            leftInfo
            Spacer()
            rightInfo
        }
        .padding(14)
        .glassCard()
    }

    private var leftInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let name = detail.name {
                Text(name).font(TTFont.heading).foregroundStyle(Color.slateText)
            }
            HStack(spacing: 6) {
                if let s = detail.sector { KeywordBadge(text: s, color: .accent) }
                if detail.stale { KeywordBadge(text: "Önbellekten", color: .slateMuted) }
            }
        }
    }

    private var rightInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if let price = detail.price {
                Text(String(format: "$%.2f", price)).font(TTFont.monoLg).foregroundStyle(Color.slateText)
            }
            HStack(spacing: 8) {
                if let d = detail.changePctDay { PriceChangeBadge(value: d) }
                if let w = detail.changePct52w {
                    Text("52h: " + String(format: "%@%.1f%%", w >= 0 ? "+" : "", w * 100))
                        .font(TTFont.caption)
                        .foregroundStyle(Color.slateMuted)
                }
            }
        }
    }
}

// MARK: - Health Scores

struct HealthScoresView: View {
    let health: HealthScore

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Sağlık Skorları")
            HStack(spacing: 10) {
                HealthBar(label: "Temel",   score: health.fundamentalScore, grade: health.fundamentalGrade)
                HealthBar(label: "Teknik",  score: health.technicalScore,   grade: health.technicalGrade)
                HealthBar(label: "Bileşik", score: health.compositeScore,   grade: health.compositeGrade)
            }
        }
        .padding(14)
        .glassCard()
    }
}

struct HealthBar: View {
    let label: String
    let score: Int
    let grade: String

    var body: some View {
        let color = Color.gradeColor(grade)
        VStack(spacing: 6) {
            Text(grade)
                .font(.system(size: 26, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.bgSurface).frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(score) / 100, height: 5)
                }
            }
            .frame(height: 5)
            Text(label).font(TTFont.label).foregroundStyle(Color.slateMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Signal Card

struct SignalCard: View {
    let signal: TradeSignal
    let horizon: String

    private var color: Color { .signalColor(signal.direction) }

    private var icon: String {
        switch signal.direction {
        case "STRONG_BUY", "BUY":          return "arrow.up.circle.fill"
        case "STRONG_SELL", "SELL":        return "arrow.down.circle.fill"
        default:                           return "minus.circle.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color)
                Text(horizon).font(TTFont.label).foregroundStyle(Color.slateMuted).tracking(0.8)
            }
            Text(signal.labelTr).font(TTFont.heading).foregroundStyle(color)
            if let r = signal.rationale {
                Text(r).font(TTFont.caption).foregroundStyle(Color.slateMuted).lineLimit(3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(color.opacity(0.25), lineWidth: 1))
        )
    }
}

// MARK: - Sector Comparison

struct SectorComparisonView: View {
    let metrics: [SectorMetric]

    var body: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "Sektör Karşılaştırması")
            VStack(spacing: 0) {
                ForEach(Array(metrics.enumerated()), id: \.element.id) { idx, metric in
                    SectorMetricRow(metric: metric)
                    if idx < metrics.count - 1 {
                        Divider().background(Color.white.opacity(0.05))
                    }
                }
            }
            .padding(14)
            .glassCard()
        }
    }
}

struct SectorMetricRow: View {
    let metric: SectorMetric

    private var vsColor: Color {
        guard let pct = metric.vsSectorPct else { return .slateMuted }
        return pct >= 0 ? .positive : .negative
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(metric.label).font(TTFont.caption).foregroundStyle(Color.slateMuted)
                Spacer()
                if let v = metric.value {
                    Text(String(format: "%.2f", v)).font(TTFont.mono).foregroundStyle(Color.slateText)
                }
                if let pct = metric.vsSectorPct {
                    Text(String(format: "%@%.1f%%", pct >= 0 ? "+" : "", pct))
                        .font(TTFont.caption).fontWeight(.semibold).foregroundStyle(vsColor)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(vsColor.opacity(0.12)).clipShape(Capsule())
                }
            }
            if let insight = metric.insight {
                Text(insight).font(.system(size: 11)).foregroundStyle(Color.slateMuted.opacity(0.7))
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Loading Skeleton

struct LoadingStockDetail: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach([80, 60, 200, 120, 100], id: \.self) { h in
                    SkeletonView().frame(height: CGFloat(h))
                }
            }
            .padding(16)
        }
    }
}
