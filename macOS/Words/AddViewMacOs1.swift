import SwiftUI

struct AddView: View {
    @Binding private var isShowingAddView: Bool
    @ObservedObject private var wordsViewModel: WordsViewModel
    @ObservedObject private var dictionaryViewModel: DictionaryViewModel

    @State private var definitionInput = ""
    @State private var partOfSpeech: PartOfSpeech = .noun
    @State private var wordClassSelection = 0
    @State private var showingAlert = false

    init(
        isShowingAddView: Binding<Bool>,
        dictionaryViewModel: DictionaryViewModel,
        wordsViewModel: WordsViewModel
    ) {
        self._isShowingAddView = isShowingAddView
        self.dictionaryViewModel = dictionaryViewModel
        self.wordsViewModel = wordsViewModel
    }

    var definitions: [Definition] {
        dictionaryViewModel.resultWordDetails!.meanings[wordClassSelection].definitions
    }

    private let synthesizer = SpeechSynthesizer.shared

    var body: some View {
        VStack {
            HStack {
                Text("Add new word").font(.title2).bold()
                Spacer()
                Button {
                    isShowingAddView = false
                } label: {
                    Text("Close")
                }
            }
            HStack {
                TextField("Enter the word", text: $dictionaryViewModel.inputWord, onCommit: {
                    fetchData()
                }).textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    fetchData()
                } label: {
                    Text("Get definitions")
                }
            }
            TextField("Enter definition", text: $definitionInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if dictionaryViewModel.resultWordDetails == nil {
                Picker(selection: $partOfSpeech, label: Text("Part of Speech")) {
                    ForEach(PartOfSpeech.allCases, id: \.self) { partCase in
                        Text(partCase.rawValue)
                    }
                }
            }

            if dictionaryViewModel.resultWordDetails != nil && dictionaryViewModel.status == .ready {
                VStack {
                    Picker(selection: $wordClassSelection, label: Text("Part of Speech")) {
                        ForEach(dictionaryViewModel.resultWordDetails!.meanings.indices, id: \.self) { index in
                            Text("\(dictionaryViewModel.resultWordDetails!.meanings[index].partOfSpeech)")
                        }
                    }

                    if dictionaryViewModel.resultWordDetails!.phonetic != nil {
                        HStack(spacing: 0) {
                            Text("Phonetic: ").bold()
                            Text(dictionaryViewModel.resultWordDetails!.phonetic ?? "")
                            Spacer()
                            Button {
                                synthesizer.speak(dictionaryViewModel.inputWord)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                            }
                        }
                    }

                    TabView {
                        ForEach(dictionaryViewModel.resultWordDetails!.meanings[wordClassSelection].definitions.indices,
                                id: \.self) { index in
                            ScrollView {
                                VStack(alignment: .leading) {
                                    if !definitions[index].definition.isEmpty {
                                        Divider()
                                        HStack {
                                            Text("Definition \(index + 1): ").bold()
                                            + Text(definitions[index].definition)
                                        }
                                        .onTapGesture {
                                            definitionInput = definitions[index].definition
                                        }
                                    }
                                    if definitions[index].example != nil {
                                        Divider()
                                        Text("Example: ").bold()
                                        + Text(definitions[index].example!)
                                    }
                                    if !definitions[index].synonyms.isEmpty {
                                        Divider()
                                        Text("Synonyms: ").bold()
                                        + Text(definitions[index].synonyms.joined(separator: ", "))
                                    }
                                    if !definitions[index].antonyms.isEmpty {
                                        Divider()
                                        Text("Antonyms: ").bold()
                                        + Text(definitions[index].antonyms.joined(separator: ", "))
                                    }
                                }
                            }.tabItem({
                                Text("\(index + 1)")
                            }).padding(.horizontal)
                        }
                    }
                }
            } else if dictionaryViewModel.status == .loading {
                VStack {
                    Spacer().frame(height: 50)
                    ProgressView()
                    Spacer()
                }
            } else {
                Spacer()
            }

            Button {
                saveNewWord()
            } label: {
                Text("Save").bold()
            }

        }
        .frame(width: 600, height: 500)
        .padding()
        .alert(isPresented: $showingAlert, content: {
            Alert(
                title: Text("Ooops..."),
                message: Text("You should enter a word and its definition before saving it"),
                dismissButton: .default(Text("Got it")))
        })
        .onAppear {
            if !wordsViewModel.searchText.isEmpty {
                dictionaryViewModel.inputWord = wordsViewModel.searchText
                try? dictionaryViewModel.fetchData()
            }
        }
    }

    private func fetchData() {
        do {
            try dictionaryViewModel.fetchData()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func saveNewWord() {
        if !dictionaryViewModel.inputWord.isEmpty, !definitionInput.isEmpty {
            wordsViewModel.addNewWord(
                word: dictionaryViewModel.inputWord.capitalizingFirstLetter(),
                definition: definitionInput.capitalizingFirstLetter(),
                partOfSpeech: partOfSpeech.rawValue,
                phonetic: dictionaryViewModel.resultWordDetails?.phonetic)
            isShowingAddView = false
            dictionaryViewModel.resultWordDetails = nil
            dictionaryViewModel.inputWord = ""
            dictionaryViewModel.status = .blank
        } else {
            showingAlert = true
        }
    }
}
