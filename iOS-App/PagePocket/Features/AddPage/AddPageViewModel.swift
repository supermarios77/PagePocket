import Foundation
import Combine

final class AddPageViewModel: ObservableObject {
    @Published var urlText: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var lastSavedTitle: String?

    private let saveService: PageSaveService

    init(saveService: PageSaveService = PageSaveService()) {
        self.saveService = saveService
    }

    @MainActor
    func save(isCleaned: Bool = false) async {
        guard !isSaving else { return }
        isSaving = true
        errorMessage = nil
        lastSavedTitle = nil
        do {
            let result = try await saveService.savePage(from: urlText, isCleaned: isCleaned)
            lastSavedTitle = result.title ?? result.url.absoluteString
            urlText = ""
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
        isSaving = false
    }
}


