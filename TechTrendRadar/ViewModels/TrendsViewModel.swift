import Foundation
import Observation

@Observable
@MainActor
final class TrendsViewModel {
    var items: [TrendItem] = []
    var isLoading = false
    var error: String?
    var isStale = false

    private var task: Task<Void, Never>?

    func load() {
        task?.cancel()
        task = Task {
            isLoading = true
            error = nil
            do {
                let r = try await APIService.shared.trends()
                guard !Task.isCancelled else { return }
                items   = r.data
                isStale = r.stale
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    func cancel() { task?.cancel() }
}
