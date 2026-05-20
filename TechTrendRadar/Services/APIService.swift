import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case network(Error)
    case http(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:      return "Geçersiz API adresi"
        case .network(let e):  return "Bağlantı hatası: \(e.localizedDescription)"
        case .http(let code):  return "Sunucu hatası: HTTP \(code)"
        case .decoding(let e): return "Veri okunamadı: \(e.localizedDescription)"
        }
    }
}

final class APIService: Sendable {
    static let shared = APIService()

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024,
            diskPath: "techtrend_api"
        )
        cfg.requestCachePolicy        = .useProtocolCachePolicy
        cfg.timeoutIntervalForRequest  = 15
        cfg.timeoutIntervalForResource = 30
        cfg.httpAdditionalHeaders      = ["Accept": "application/json"]
        return URLSession(configuration: cfg)
    }()

    private let decoder = JSONDecoder()

    var baseURL: String {
        UserDefaults.standard.string(forKey: "apiBaseURL")
            ?? "https://leaders-button-lexmark-airplane.trycloudflare.com"
    }

    // MARK: Generic fetch

    private func fetch<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw APIError.invalidURL }

        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw APIError.http(http.statusCode)
            }
            return try decoder.decode(T.self, from: data)
        } catch let e as APIError { throw e }
          catch let e as DecodingError { throw APIError.decoding(e) }
          catch { throw APIError.network(error) }
    }

    // MARK: Endpoints

    func categories() async throws -> CategoriesResponse {
        try await fetch("/api/categories/")
    }

    func categoryStocks(_ id: String) async throws -> [StockSummary] {
        try await fetch("/api/categories/\(id)/stocks")
    }

    func stockDetail(_ ticker: String) async throws -> StockDetail {
        try await fetch("/api/stocks/\(ticker)")
    }

    func trends() async throws -> TrendListResponse {
        try await fetch("/api/trends/")
    }

    func health() async throws -> ConnectorHealth {
        try await fetch("/health/connectors")
    }
}
