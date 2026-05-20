import SwiftUI
import Charts

struct StockChartView: View {
    let history: [PricePoint]
    let changePositive: Bool

    @State private var selectedPoint: PricePoint?
    @State private var plotWidth: CGFloat = 0

    private var lineColor: Color { changePositive ? .positive : .negative }
    private var minPrice: Double { history.map(\.close).min() ?? 0 }
    private var maxPrice: Double { history.map(\.close).max() ?? 0 }
    private var priceRange: Double { maxPrice - minPrice }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Selection overlay
            if let p = selectedPoint {
                HStack {
                    Text(p.date)
                        .font(TTFont.caption)
                        .foregroundStyle(Color.slateMuted)
                    Spacer()
                    Text(String(format: "$%.2f", p.close))
                        .font(TTFont.mono)
                        .foregroundStyle(lineColor)
                }
                .padding(.horizontal, 14)
            } else {
                SectionHeader(title: "Fiyat Geçmişi")
                    .padding(.horizontal, 14)
            }

            Chart {
                ForEach(Array(history.enumerated()), id: \.element.id) { idx, point in
                    AreaMark(
                        x: .value("Tarih", idx),
                        yStart: .value("Taban", minPrice - priceRange * 0.05),
                        yEnd: .value("Fiyat", point.close)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [lineColor.opacity(0.3), lineColor.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Tarih", idx),
                        y: .value("Fiyat", point.close)
                    )
                    .foregroundStyle(lineColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }

                if let sel = selectedPoint,
                   let idx = history.firstIndex(where: { $0.id == sel.id }) {
                    RuleMark(x: .value("Seçili", idx))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))
                        .foregroundStyle(Color.slateMuted.opacity(0.6))

                    PointMark(
                        x: .value("Tarih", idx),
                        y: .value("Fiyat", sel.close)
                    )
                    .symbolSize(60)
                    .foregroundStyle(lineColor)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { v in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.white.opacity(0.05))
                    AxisValueLabel {
                        if let d = v.as(Double.self) {
                            Text(String(format: "$%.0f", d))
                                .font(TTFont.label)
                                .foregroundStyle(Color.slateMuted)
                        }
                    }
                }
            }
            .chartYScale(domain: (minPrice - priceRange * 0.05)...(maxPrice + priceRange * 0.05))
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { val in
                                    let x = val.location.x - geo.frame(in: .local).minX
                                    if let idx: Int = proxy.value(atX: x),
                                       history.indices.contains(idx) {
                                        selectedPoint = history[idx]
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        selectedPoint = nil
                                    }
                                }
                        )
                }
            }
            .frame(height: 180)
            .padding(.horizontal, 8)

            // Date range labels
            if let first = history.first, let last = history.last {
                HStack {
                    Text(first.date)
                    Spacer()
                    Text(last.date)
                }
                .font(TTFont.label)
                .foregroundStyle(Color.slateMuted)
                .padding(.horizontal, 14)
            }
        }
        .padding(.vertical, 14)
        .glassCard()
    }
}
