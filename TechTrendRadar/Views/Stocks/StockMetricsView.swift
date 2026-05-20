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
            // Tab selector
            HStack(spacing: 0) {
                ForEach(MetricsTab.allCases, id: \.self) { t in
                    Button(t.rawValue) {
                        withAnimation(.easeInOut(duration: 0.18)) { tab = t }
                    }
                    .font(TTFont.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(tab == t ? Color.accent : Color.slateMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        tab == t
                            ? Color.accent.opacity(0.12)
                            : Color.clear
                    )
                    .overlay(
                        Rectangle()
                            .fill(tab == t ? Color.accent : Color.clear)
                            .frame(height: 2),
                        alignment: .bottom
                    )
                }
            }
            .background(Color.bgSurface.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Content
            switch tab {
            case .fundamental:
                if let f = detail.fundamentals {
                    FundamentalRows(f: f)
                }
            case .technical:
                if let t = detail.technicals {
                    TechnicalRows(t: t, price: detail.price)
                }
            }
        }
        .padding(14)
        .glassCard()
    }
}

// MARK: - Fundamental Rows

struct FundamentalRows: View {
    let f: Fundamentals

    private func row(_ label: String, _ value: String?) -> some View {
        MetricRow(label: label, value: value)
    }

    private func pct(_ v: Double?) -> String? {
        guard let v else { return nil }
        return String(format: "%.1f%%", v * 100)
    }

    private func fmt(_ v: Double?, digits: Int = 2) -> String? {
        guard let v else { return nil }
        return String(format: "%.\(digits)f", v)
    }

    private func marketCapFormatted(_ cap: Int?) -> String? {
        guard let cap else { return nil }
        if cap >= 1_000_000_000_000 {
            return String(format: "$%.1fT", Double(cap) / 1_000_000_000_000)
        } else if cap >= 1_000_000_000 {
            return String(format: "$%.1fB", Double(cap) / 1_000_000_000)
        } else {
            return String(format: "$%.1fM", Double(cap) / 1_000_000)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            row("F/K Oranı",       fmt(f.peRatio))
            Divider().background(Color.white.opacity(0.05))
            row("F/S Oranı",       fmt(f.psRatio))
            Divider().background(Color.white.opacity(0.05))
            row("F/DD Oranı",      fmt(f.pbRatio))
            Divider().background(Color.white.opacity(0.05))
            row("Öz Kaynak Getirisi", pct(f.roe))
            Divider().background(Color.white.opacity(0.05))
            row("EPS",             fmt(f.eps))
            Divider().background(Color.white.opacity(0.05))
            row("Temettü Getirisi", pct(f.dividendYield))
            Divider().background(Color.white.opacity(0.05))
            row("52h Düşük",       fmt(f.week52Low).map { "$" + $0 })
            Divider().background(Color.white.opacity(0.05))
            row("52h Yüksek",      fmt(f.week52High).map { "$" + $0 })
            Divider().background(Color.white.opacity(0.05))
            row("Piyasa Değeri",   marketCapFormatted(f.marketCap))
        }
    }
}

// MARK: - Technical Rows

struct TechnicalRows: View {
    let t: Technicals
    let price: Double?

    private func fmt(_ v: Double?, digits: Int = 2) -> String? {
        guard let v else { return nil }
        return String(format: "%.\(digits)f", v)
    }

    private var rsiInterpretation: String? {
        guard let rsi = t.rsi14 else { return nil }
        if rsi > 70 { return "Aşırı Alım" }
        if rsi < 30 { return "Aşırı Satım" }
        return "Nötr"
    }

    private var macdInterpretation: String? {
        guard let hist = t.macdHist else { return nil }
        return hist > 0 ? "Yükseliş" : "Düşüş"
    }

    private func maVsPrice(_ ma: Double?) -> String? {
        guard let ma, let p = price else { return fmt(ma) }
        let diff = (p - ma) / ma * 100
        let base = String(format: "$%.2f", ma)
        let rel  = String(format: " (%@%.1f%%)", diff >= 0 ? "+" : "", diff)
        return base + rel
    }

    var body: some View {
        VStack(spacing: 0) {
            MetricRow(
                label: "RSI(14)",
                value: fmt(t.rsi14, digits: 1),
                annotation: rsiInterpretation,
                annotationColor: rsiColor
            )
            Divider().background(Color.white.opacity(0.05))
            MetricRow(label: "MACD",       value: fmt(t.macd))
            Divider().background(Color.white.opacity(0.05))
            MetricRow(label: "MACD Sinyal", value: fmt(t.macdSignal))
            Divider().background(Color.white.opacity(0.05))
            MetricRow(
                label: "MACD Hist.",
                value: fmt(t.macdHist),
                annotation: macdInterpretation,
                annotationColor: macdColor
            )
            Divider().background(Color.white.opacity(0.05))
            MetricRow(label: "MA(20)",     value: maVsPrice(t.ma20))
            Divider().background(Color.white.opacity(0.05))
            MetricRow(label: "MA(50)",     value: maVsPrice(t.ma50))
        }
    }

    private var rsiColor: Color {
        guard let rsi = t.rsi14 else { return .slateMuted }
        if rsi > 70 { return .negative }
        if rsi < 30 { return .positive }
        return .warning
    }

    private var macdColor: Color {
        guard let hist = t.macdHist else { return .slateMuted }
        return hist > 0 ? .positive : .negative
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
            Text(label)
                .font(TTFont.caption)
                .foregroundStyle(Color.slateMuted)
            Spacer()
            HStack(spacing: 8) {
                if let val = value {
                    Text(val)
                        .font(TTFont.mono)
                        .foregroundStyle(Color.slateText)
                } else {
                    Text("—")
                        .font(TTFont.mono)
                        .foregroundStyle(Color.slateMuted)
                }
                if let ann = annotation {
                    Text(ann)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(annotationColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(annotationColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 10)
    }
}
