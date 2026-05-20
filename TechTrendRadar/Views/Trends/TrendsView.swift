import SwiftUI

struct TrendsView: View {
    @State private var vm = TrendsViewModel()
    @State private var selectedSector: String? = nil

    private var sectors: [String] {
        Array(Set(vm.items.compactMap(\.sector))).sorted()
    }

    private var filtered: [TrendItem] {
        guard let s = selectedSector else { return vm.items }
        return vm.items.filter { $0.sector == s }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                if vm.isLoading && vm.items.isEmpty {
                    LoadingTrends()
                } else if let err = vm.error, vm.items.isEmpty {
                    ErrorStateView(message: err, retry: vm.load)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            Section {
                                // Sector filter chips
                                if !sectors.isEmpty {
                                    SectorFilter(
                                        sectors: sectors,
                                        selected: $selectedSector
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                }

                                // Trend items
                                VStack(spacing: 8) {
                                    ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, item in
                                        TrendItemRow(item: item, rank: idx + 1)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                            } header: {
                                HStack {
                                    SectionHeader(title: "HackerNews Trendleri")
                                    Spacer()
                                    if vm.isStale {
                                        KeywordBadge(text: "Önbellekten", color: .slateMuted)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.bgBase)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Trendler")
            .navigationBarTitleDisplayMode(.large)
        }
        .task { vm.load() }
        .onDisappear { vm.cancel() }
        .refreshable { vm.load() }
    }
}

// MARK: - Sector Filter

struct SectorFilter: View {
    let sectors: [String]
    @Binding var selected: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "Tümü", isSelected: selected == nil) {
                    selected = nil
                }
                ForEach(sectors, id: \.self) { sector in
                    FilterChip(label: sector, isSelected: selected == sector) {
                        selected = selected == sector ? nil : sector
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(TTFont.caption)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Color.accent : Color.slateMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accent.opacity(0.12) : Color.bgSurface.opacity(0.5))
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    isSelected ? Color.accent.opacity(0.4) : Color.white.opacity(0.06),
                                    lineWidth: 1
                                )
                        )
                )
        }
    }
}

// MARK: - Trend Item Row

struct TrendItemRow: View {
    let item: TrendItem
    let rank: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(rank)")
                    .font(TTFont.label)
                    .foregroundStyle(Color.slateMuted)
                    .frame(width: 20, alignment: .trailing)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 6) {
                    if let url = item.url, let link = URL(string: url) {
                        Link(destination: link) {
                            Text(item.title)
                                .font(TTFont.body)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.slateText)
                                .multilineTextAlignment(.leading)
                        }
                    } else {
                        Text(item.title)
                            .font(TTFont.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.slateText)
                    }

                    HStack(spacing: 6) {
                        // Score
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.warning)
                            Text("\(item.score)")
                                .font(TTFont.caption)
                                .foregroundStyle(Color.slateMuted)
                        }

                        if let sector = item.sector {
                            KeywordBadge(text: sector, color: .accent)
                        }
                    }

                    if !item.keywords.isEmpty {
                        FlowLayout(spacing: 5) {
                            ForEach(item.keywords.prefix(5), id: \.self) { kw in
                                KeywordBadge(text: kw, color: .accentViolet)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .glassCard(radius: 10)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0, y: CGFloat = 0, maxH: CGFloat = 0

        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > width && x > 0 { x = 0; y += maxH + spacing; maxH = 0 }
            x += s.width + spacing
            maxH = max(maxH, s.height)
        }
        return CGSize(width: width, height: y + maxH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, maxH: CGFloat = 0

        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX; y += maxH + spacing; maxH = 0
            }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            maxH = max(maxH, s.height)
        }
    }
}

// MARK: - Loading

struct LoadingTrends: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(0..<10, id: \.self) { _ in
                    SkeletonView().frame(height: 80)
                }
            }
            .padding(16)
        }
    }
}
