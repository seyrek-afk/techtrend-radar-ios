import Foundation
import Observation

@Observable
@MainActor
final class StockDetailViewModel {
    var stocks: [StockSummary] = []
    var detail: StockDetail?
    var isLoadingStocks = false
    var isLoadingDetail = false
    var stocksError: String?
    var detailError: String?

    private var stocksTask: Task<Void, Never>?
    private var detailTask: Task<Void, Never>?

    func loadStocks(for categoryId: String) {
        stocksTask?.cancel()
        stocksTask = Task {
            isLoadingStocks = true
            stocksError = nil
            do {
                let result = try await APIService.shared.categoryStocks(categoryId)
                guard !Task.isCancelled else { return }
                stocks = result
            } catch {
                guard !Task.isCancelled else { return }
                stocksError = error.localizedDescription
            }
            isLoadingStocks = false
        }
    }

    func loadDetail(ticker: String) {
        detailTask?.cancel()
        detail = nil
        detailTask = Task {
            isLoadingDetail = true
            detailError = nil
            do {
                let result = try await APIService.shared.stockDetail(ticker)
                guard !Task.isCancelled else { return }
                detail = result
            } catch {
                guard !Task.isCancelled else { return }
                detailError = error.localizedDescription
            }
            isLoadingDetail = false
        }
    }

    func cancel() {
        stocksTask?.cancel()
        detailTask?.cancel()
    }
}
