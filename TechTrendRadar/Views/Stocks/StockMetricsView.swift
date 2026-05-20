import SwiftUI

enum MetricsTab: String, CaseIterable {
    case fundamental = "Temel Analiz"
    case technical   = "Teknik Analiz"
}

struct StockMetricsView: View {
    let detail: StockDetail
    @Binding var tab: MetricsTab

    var body: some View {
        VStack(spacing: 12) {
            tabSelector
            tabContent
        }
        .padding(14)
        .glassCard()
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(MetricsTab.allCases, id: \.self) { t in
                tabButton(t)
            }
        }
        .background(Color.bgSurface.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func tabButton(_ t: MetricsTab) -> some View {
        let isSelected = tab == t
        return Button(t.rawValue) {
            withAnimation(.easeInOut(duration: 0.18)) { tab = t }
        }
        .font(TTFont.caption)
        .fontWeight(.semibold)
        .foregroundStyle(isSelected ? Color.accent : Color.slateMuted)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isSelected ? Color.accent.opacity(0.12) : Color.clear)
        .overlay(Rectangle().fill(isSelected ? Color.accent : Color.clear).frame(height: 2), alignment: .bottom)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .fundamental:
            if let f = detail.fundamentals { FundamentalRows(f: f) }
        case .technical:
            if let t = detail.technicals { TechnicalRows(t: t, price: detail.price) }
        }
    }
}

// MARK: - Fundamental Rows

struct FundamentalRows: View {
    let f: Fundamentals

    var body: some View {
        VStack(spacing: 0) {
            MetricRow(label: "F/K Oranı",         value: fmt(f.peRatio))
            divider
            MetricRow(label: "F/S Oranı",         value: fmt(f.psRatio))
            divider
            MetricRow(label: "F/DD Oranı",        value: fmt(f.pbRatio))
            divider
            MetricRow(label: "Öz Kaynak Getirisi", value: pct(f.roe))
            divider
            MetricRow(label: "EPS",               value: fmt(f.eps))
            divider
            MetricRow(label: "Temettü Getirisi",  value: pct(f.dividendYield))
            divider
            MetricRow(label: "52h Düşük",         value: dollar(f.week52Low))
            divider
            MetricRow(label: "52h Yüksek",        value: dollar(f.week52High))
            divider
            MetricRow(label: "Piyasa Değeri",     value: marketCap(f.marketCap))
        }
    }

    private var divider: some View {
        Divider().background(Color.white.opacity(0.05))
    }

    private func fmt(_ v: Double?) -> String? {
        guard let v else { return nil }
        return String(format: "%.2f", v)
    }

    private func pct(_ v: Double?) -> String? {
        guard let v else { return nil }
        return String(format: "%.1f%%", v * 100)
    }

    private func dollar(_ v: Double?) -> String? {
        guard let v else { return nil }
        return String(format: "$%.2f", v)
    }

    private func marketCap(_ cap: Int?) -> String? {
        guard let cap else { return nil }
        if cap >= 1_000_000_000_000 { return String(format: "$%.1fT", Double(cap) / 1e12) }
        if cap >= 1_000_000_000     { return String(format: "$%.1fB", Double(cap) / 1e9) }
        return String(format: "$%.1fM", Double(cap) / 1e6)
    }
}

// MARK: - Technical Rows

struct TechnicalRows: View {
    let t: Technicals
    let price: Double?

    var body: some View {
        VStack(spacing: 0) {
            MetricRow(label: "RSI(14)",    value: rsiValue,  annotation: rsiLabel,  annotationColor: rsiColor)
            divider
            MetricRow(label: "MACD",      value: fmt(t.macd))
            divider
            MetricRow(label: "MACD Sinyal", value: fmt(t.macdSignal))
            divider
            MetricRow(label: "MACD Hist.", value: fmt(t.macdHist), annotation: macdLabel, annotationColor: macdColor)
            divider
            MetricRow(label: "MA(20)",    value: maVsPrice(t.ma20))
            divider
            MetricRow(label: "MA(50)",    value: maVsPrice(t.ma50))
        }
    }

    private var divider: some View {
        Divider().background(Color.white.opacity(0.05))
    }

    private func fmt(_ v: Double?) -> String? {
        guard let v else { return nil }
        return String(format: "%.2f", v)
    }

    private var rsiValue: String? { fmt(t.rsi14) }

    private var rsiLabel: String? {
        guard let rsi = t.rsi14 else { return nil }
        if rsi > 70 { return "Aşırı Alım" }
        if rsi < 30 { return "Aşırı Satım" }
        return "Nötr"
    }

    private var rsiColor: Color {
        guard let rsi = t.rsi14 else { return .slateMuted }
        if rsi > 70 { return .negative }
        if rsi < 30 { return .positive }
        return .warning
    }

    private var macdLabel: String? {
        guard let hist = t.macdHist else { return nil }
        return hist > 0 ? "Yükseliş" : "Düşüş"
    }

    private var macdColor: Color {
        guard let hist = t.macdHist else { return .slateMuted }
        return hist > 0 ? .positive : .negative
    }

    private func maVsPrice(_ ma: Double?) -> String? {
        guard let ma else { return nil }
        let base = String(format: "$%.2f", ma)
        guard let p = price else { return base }
        let diff = (p - ma) / ma * 100
        return base + String(format: " (%@%.1f%%)", diff >= 0 ? "+" : "", diff)
    }
}

// MARK: - Metric Row

struct MetricRow: View {
    let label: String
    let value: String?
    var annotation: String? = nil
    var annotationColor: Color = .slateMuted

    var body: some View {
        HStack {
            Text(label).font(TTFont.caption).foregroundStyle(Color.slateMuted)
            Spacer()
            HStack(spacing: 8) {
                Text(value ?? "—")
                    .font(TTFont.mono)
                    .foregroundStyle(value != nil ? Color.slateText : Color.slateMuted)
                if let ann = annotation {
                    Text(ann)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(annotationColor)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(annotationColor.opacity(0.12)).clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 10)
    }
}
