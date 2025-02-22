import SwiftUI
import Combine

final class QuizzesViewModel: ObservableObject {
    @Published var words: [Word] = []

    private let wordsProvider: WordsProviderInterface
    private var cancellables: Set<AnyCancellable> = []

    init(wordsProvider: WordsProviderInterface) {
        self.wordsProvider = wordsProvider
        setupBindings()
    }

    /// Fetches latest data from Core Data
    private func setupBindings() {
        wordsProvider.wordsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.words, on: self)
            .store(in: &cancellables)
    }
}
