import SwiftUI

struct AddView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var wordsViewModel: WordsViewModel
    @StateObject var dictionaryViewModel = DictionaryViewModel()
    @State private var descriptionField = ""
    @State private var partOfSpeech: PartOfSpeech = .unknown
    @State private var showingAlert = false

    private let synthesizer = SpeechSynthesizer.shared

    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 11) {
                    TextField("Enter your word", text: $dictionaryViewModel.inputWord, onCommit: {
                        if !dictionaryViewModel.inputWord.isEmpty {
                            do {
                                try dictionaryViewModel.fetchData()
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else {
                            print("type a word")
                        }
                    })
                        .padding(.horizontal)
                        .padding(.top, 11)
                    Divider().padding(.leading)
                    TextField("Word's definition", text: $descriptionField)
                        .padding(.horizontal)
                    Divider().padding(.leading)
                    partOfSpeechMenu
                    Divider().padding(.leading)
                    Button(action: {
                        searchForWord()
                        hideKeyboard()
                    }, label: {
                        Text("Get definitions from the Internet")
                            .padding(.vertical, 1)
                    })
                        .padding(.bottom, 11)
                        .foregroundColor(dictionaryViewModel.inputWord.isEmpty ? Color.gray.opacity(0.5) : .green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .disabled(dictionaryViewModel.inputWord.isEmpty)
                }
                .background(Color("TableBackground").cornerRadius(10))
                .padding(.horizontal)

                detailsView
            }
            .ignoresSafeArea(.all, edges: [.bottom])
            .background(
                Color("Background")
                    .ignoresSafeArea()
                    .onTapGesture(perform: {
                        hideKeyboard()
                    })
            )
            .navigationBarTitle("Add new word")
            .navigationBarItems(trailing: Button(action: {
                if !dictionaryViewModel.inputWord.isEmpty, !descriptionField.isEmpty {
                    wordsViewModel.addNewWord(
                        word: dictionaryViewModel.inputWord.capitalizingFirstLetter(),
                        definition: descriptionField.capitalizingFirstLetter(),
                        partOfSpeech: partOfSpeech.rawValue,
                        phonetic: dictionaryViewModel.resultWordDetails?.phonetic)
                    self.presentationMode.wrappedValue.dismiss()
                    dictionaryViewModel.resultWordDetails = nil
                    dictionaryViewModel.inputWord = ""
                    dictionaryViewModel.status = .blank
                } else {
                    showingAlert = true
                }
            }, label: {
                Text("Save")
                    .font(.system(.headline, design: .rounded))
            }))
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
    }

    private func searchForWord() {
        if !dictionaryViewModel.inputWord.isEmpty {
            do {
               try dictionaryViewModel.fetchData()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("type a word")
        }
    }

    var errorView: some View {
        VStack {
            Spacer().frame(height: 25)
            Text("Couldn't get the word's data, check your spelling. Or you lost your internet connection, so check this out as well.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    var blanckView: some View {
        VStack {
            Spacer().frame(height: 25)
            Text("*After the data shows up here, tap on word's definition to fill it into definition's field.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    var loadingView: some View {
        VStack {
            Spacer().frame(height: 50)
            ProgressView()
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    var detailsView: some View {
        Section {
            if let resultWordDetails = dictionaryViewModel.resultWordDetails,
                dictionaryViewModel.status == .ready
            {
                if let phonetic = resultWordDetails.phonetic {
                    HStack(spacing: 0) {
                        HStack {
                            Text("Phonetic: ").bold()
                            + Text(phonetic)
                        }.padding(.top)
                        Spacer()
                        Button {
                            synthesizer.speak(dictionaryViewModel.inputWord)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title3)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                }

                WordCard(
                    wordMeanings: resultWordDetails.meanings,
                    tapGesture: { descriptionStr, partOfSpeechStr in
                        descriptionField = descriptionStr

                        switch partOfSpeechStr {
                        case "noun":
                            partOfSpeech = .noun
                        case "verb":
                            partOfSpeech = .verb
                        case "adjective":
                            partOfSpeech = .adjective
                        case "adverb":
                            partOfSpeech = .adverb
                        case "exclamation":
                            partOfSpeech = .exclamation
                        case "conjunction":
                            partOfSpeech = .conjunction
                        case "pronoun":
                            partOfSpeech = .pronoun
                        case "number":
                            partOfSpeech = .number
                        default:
                            partOfSpeech = .unknown
                        }

                        hideKeyboard()
                    })
                .onAppear {
                    if let meaning = resultWordDetails.meanings.first,
                        let definition = meaning.definitions.first {
                        descriptionField = definition.definition
                        partOfSpeech = .noun
                    }
                }
            } else if dictionaryViewModel.status == .loading {
                loadingView
            } else if dictionaryViewModel.status == .blank {
                blanckView
            } else if dictionaryViewModel.status == .error {
                errorView
            }
        }
        .cornerRadius(15)
    }

    var partOfSpeechMenu: some View {
        Menu {
            ForEach(PartOfSpeech.allCases, id: \.self) { partCase in
                Button {
                    partOfSpeech = partCase
                } label: {
                    if partOfSpeech == partCase {
                        Image(systemName: "checkmark")
                    }
                    Text(partCase.rawValue)
                }
            }
        } label: {
            Text(partOfSpeech == .unknown ? "Part of speech" : partOfSpeech.rawValue)
                .padding(.horizontal)
                .foregroundColor(
                    partOfSpeech == .unknown
                    ? Color.accentColor
                    : Color.primary
                )
        }
    }
}
