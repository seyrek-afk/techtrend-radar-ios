import SwiftUI
import Charts

struct StockChartView: View {
    let history: [PricePoint]
    let changePositive: Bool

    @State private var selectedIndex: Int?

    private var lineColor: Color { changePositive ? .positive : .negative }
    private var minPrice: Double { history.map(\.close).min() ?? 0 }
    private var maxPrice: Double { history.map(\.close).max() ?? 0 }
    private var padding: Double { max((maxPrice - minPrice) * 0.05, 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerRow
            chartBody
            dateLabels
        }
        .padding(.vertical, 14)
        .glassCard()
    }

    private var headerRow: some View {
        Group {
            if let idx = selectedIndex, history.indices.contains(idx) {
                HStack {
                    Text(history[idx].date)
                        .font(TTFont.caption)
                        .foregroundStyle(Color.slateMuted)
                    Spacer()
                    Text(String(format: "$%.2f", history[idx].close))
                        .font(TTFont.mono)
                        .foregroundStyle(lineColor)
                }
                .padding(.horizontal, 14)
            } else {
                SectionHeader(title: "Fiyat Geçmişi")
                    .padding(.horizontal, 14)
            }
        }
    }

    private var chartBody: some View {
        Chart {
            ForEach(Array(history.enumerated()), id: \.element.id) { idx, point in
                AreaMark(
                    x: .value("İndeks", idx),
                    yStart: .value("Alt", minPrice - padding),
                    yEnd: .value("Fiyat", point.close)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [lineColor.opacity(0.25), lineColor.opacity(0.02)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("İndeks", idx),
                    y: .value("Fiyat", point.close)
                )
                .foregroundStyle(lineColor)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
            }

            if let idx = selectedIndex, history.indices.contains(idx) {
                RuleMark(x: .value("Seçili", idx))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))
                    .foregroundStyle(Color.slateMuted.opacity(0.5))
                PointMark(
                    x: .value("İndeks", idx),
                    y: .value("Fiyat", history[idx].close)
                )
                .symbolSize(50)
                .foregroundStyle(lineColor)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { val in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.white.opacity(0.05))
                AxisValueLabel {
                    if let d = val.as(Double.self) {
                        Text(String(format: "$%.0f", d))
                            .font(TTFont.label)
                            .foregroundStyle(Color.slateMuted)
                    }
                }
            }
        }
        .chartYScale(domain: (minPrice - padding)...(maxPrice + padding))
        .chartOverlay { proxy in
            GeometryReader { geo in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geo.frame(in: .local).minX
                                if let rawIdx = proxy.value(atX: x, as: Int.self),
                                   history.indices.contains(rawIdx) {
                                    selectedIndex = rawIdx
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.15)) {
                                    selectedIndex = nil
                                }
                            }
                    )
            }
        }
        .frame(height: 180)
        .padding(.horizontal, 8)
    }

    private var dateLabels: some View {
        HStack {
            Text(history.first?.date ?? "")
            Spacer()
            Text(history.last?.date ?? "")
        }
        .font(TTFont.label)
        .foregroundStyle(Color.slateMuted)
        .padding(.horizontal, 14)
    }
}
