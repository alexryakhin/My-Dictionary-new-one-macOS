import SwiftUI
import Combine

final class AddWordViewModel: ObservableObject {

    @Published var status: FetchingStatus = .blank
    @Published var inputWord = ""
    @Published var resultWordDetails: WordElement?
    @Published var descriptionField = ""
    @Published var partOfSpeech: PartOfSpeech = .unknown
    @Published var showingAlert = false

    private let dictionaryApiService: DictionaryApiServiceInterface
    private let wordsProvider: WordsProviderInterface
    private let speechSynthesizer: SpeechSynthesizerInterface
    private var cancellables = Set<AnyCancellable>()

    init(
        inputWord: String = "",
        dictionaryApiService: DictionaryApiServiceInterface,
        wordsProvider: WordsProviderInterface,
        speechSynthesizer: SpeechSynthesizerInterface
    ) {
        self.inputWord = inputWord
        self.dictionaryApiService = dictionaryApiService
        self.wordsProvider = wordsProvider
        self.speechSynthesizer = speechSynthesizer

        setupBindings()
        if !inputWord.isEmpty {
            fetchData()
        }
    }

    func fetchData() {
        Task { @MainActor in
            status = .loading
            do {
                let words = try await dictionaryApiService.getWords(for: inputWord)
                resultWordDetails = words.first
                status = .ready
            } catch {
                status = .error
            }
        }
    }

    func saveWord() {
        if !inputWord.isEmpty, !descriptionField.isEmpty {
            wordsProvider.addNewWord(
                word: inputWord.capitalizingFirstLetter(),
                definition: descriptionField.capitalizingFirstLetter(),
                partOfSpeech: partOfSpeech.rawValue,
                phonetic: resultWordDetails?.phonetic
            )
            wordsProvider.saveContext()
        } else {
            showingAlert = true
        }
    }

    func speakInputWord() {
        speechSynthesizer.speak(inputWord)
    }

    private func setupBindings() {
        $inputWord
            .dropFirst()
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard self?.status != .loading else { return }
                self?.fetchData()
            }
            .store(in: &cancellables)
    }
}
