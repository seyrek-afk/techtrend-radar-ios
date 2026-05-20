import Foundation

// MARK: - Categories

struct CategoriesResponse: Codable {
    let categories: [Category]
    let emerging: [EmergingOpportunity]
}

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String
    let description: String
    let whyTrending: String
    let nearTerm: String
    let midTerm: String
    let opportunity: String
    let tickers: [String]
    let sectorLabel: String
    let benchmarks: CategoryBenchmarks

    enum CodingKeys: String, CodingKey {
        case id, name, icon, color, description, tickers, opportunity
        case whyTrending  = "why_trending"
        case nearTerm     = "near_term"
        case midTerm      = "mid_term"
        case sectorLabel  = "sector_label"
        case benchmarks
    }
}

struct CategoryBenchmarks: Codable {
    let avgPe: Double?
    let avgPb: Double?
    let avgRoe: Double?

    enum CodingKeys: String, CodingKey {
        case avgPe  = "avg_pe"
        case avgPb  = "avg_pb"
        case avgRoe = "avg_roe"
    }
}

struct EmergingOpportunity: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let timeline: String
    let signalTickers: [String]

    enum CodingKeys: String, CodingKey {
        case id, title, description, timeline
        case signalTickers = "signal_tickers"
    }
}

// MARK: - Stocks

struct StockSummary: Codable, Identifiable {
    let ticker: String
    let name: String?
    let price: Double?
    let changePctDay: Double?
    let marketCap: Int?
    let sector: String?
    let stale: Bool

    var id: String { ticker }

    enum CodingKeys: String, CodingKey {
        case ticker, name, price, sector, stale
        case changePctDay = "change_pct_day"
        case marketCap    = "market_cap"
    }
}

struct StockDetail: Codable, Identifiable {
    let ticker: String
    let name: String?
    let sector: String?
    let description: String?
    let price: Double?
    let changePctDay: Double?
    let changePct52w: Double?
    let fundamentals: Fundamentals?
    let technicals: Technicals?
    let history: [PricePoint]
    let healthScore: HealthScore?
    let signalMedium: TradeSignal?
    let signalLong: TradeSignal?
    let sectorComparison: [SectorMetric]
    let stale: Bool

    var id: String { ticker }

    enum CodingKeys: String, CodingKey {
        case ticker, name, sector, description, price, fundamentals, technicals, history, stale
        case changePctDay    = "change_pct_day"
        case changePct52w    = "change_pct_52w"
        case healthScore     = "health_score"
        case signalMedium    = "signal_medium"
        case signalLong      = "signal_long"
        case sectorComparison = "sector_comparison"
    }
}

struct Fundamentals: Codable {
    let peRatio: Double?
    let psRatio: Double?
    let pbRatio: Double?
    let roe: Double?
    let eps: Double?
    let dividendYield: Double?
    let week52Low: Double?
    let week52High: Double?
    let marketCap: Int?

    enum CodingKeys: String, CodingKey {
        case roe, eps
        case peRatio      = "pe_ratio"
        case psRatio      = "ps_ratio"
        case pbRatio      = "pb_ratio"
        case dividendYield = "dividend_yield"
        case week52Low    = "week52_low"
        case week52High   = "week52_high"
        case marketCap    = "market_cap"
    }
}

struct Technicals: Codable {
    let rsi14: Double?
    let macd: Double?
    let macdSignal: Double?
    let macdHist: Double?
    let ma20: Double?
    let ma50: Double?

    enum CodingKeys: String, CodingKey {
        case macd
        case rsi14      = "rsi_14"
        case macdSignal = "macd_signal"
        case macdHist   = "macd_hist"
        case ma20       = "ma_20"
        case ma50       = "ma_50"
    }
}

struct PricePoint: Codable, Identifiable {
    let date: String
    let close: Double
    let volume: Int?

    var id: String { date }
}

struct HealthScore: Codable {
    let fundamentalScore: Int
    let technicalScore: Int
    let compositeScore: Int
    let fundamentalGrade: String
    let technicalGrade: String
    let compositeGrade: String

    enum CodingKeys: String, CodingKey {
        case fundamentalScore  = "fundamental_score"
        case technicalScore    = "technical_score"
        case compositeScore    = "composite_score"
        case fundamentalGrade  = "fundamental_grade"
        case technicalGrade    = "technical_grade"
        case compositeGrade    = "composite_grade"
    }
}

struct TradeSignal: Codable {
    let direction: String
    let labelTr: String
    let color: String
    let rationale: String?

    enum CodingKeys: String, CodingKey {
        case direction, color, rationale
        case labelTr = "label_tr"
    }
}

struct SectorMetric: Codable, Identifiable {
    let label: String
    let value: Double?
    let sectorAvg: Double?
    let vsSectorPct: Double?
    let insight: String?

    var id: String { label }

    enum CodingKeys: String, CodingKey {
        case label, value, insight
        case sectorAvg   = "sector_avg"
        case vsSectorPct = "vs_sector_pct"
    }
}

// MARK: - Trends

struct TrendListResponse: Codable {
    let data: [TrendItem]
    let stale: Bool
    let source: String
}

struct TrendItem: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String?
    let score: Int
    let keywords: [String]
    let sector: String?
    let stale: Bool
}

// MARK: - Health

struct ConnectorHealth: Codable {
    let status: String
    let components: ConnectorComponents
    let timestamp: String
}

struct ConnectorComponents: Codable {
    let hackernews: ConnectorState?
    let yfinance: ConnectorState?
}

struct ConnectorState: Codable {
    let state: String
    let healthy: Bool
}
