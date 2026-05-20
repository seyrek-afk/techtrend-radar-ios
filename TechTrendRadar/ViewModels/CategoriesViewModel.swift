import Foundation
import Observation

@Observable
@MainActor
final class CategoriesViewModel {
    var categories: [Category] = []
    var emerging: [EmergingOpportunity] = []
    var isLoading = false
    var error: String?

    private var task: Task<Void, Never>?

    func load() {
        task?.cancel()
        task = Task {
            isLoading = true
            error = nil
            do {
                let r = try await APIService.shared.categories()
                guard !Task.isCancelled else { return }
                categories = r.categories
                emerging   = r.emerging
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    func cancel() { task?.cancel() }
}
