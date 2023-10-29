import SwiftUI

struct WordDetailView: View {
    @ObservedObject private var wordsViewModel: WordsViewModel
    
    @State private var isEditing = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""
    @State private var partOfSpeech: PartOfSpeech = .noun

    init(wordsViewModel: WordsViewModel) {
        self.wordsViewModel = wordsViewModel
    }

    private var examples: [String] {
        guard let data = wordsViewModel.selectedWord?.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }

    private let synthesizer = SpeechSynthesizer.shared

    var body: some View {
        VStack {
            // MARK: Title and toolbar
            HStack {
                Text(wordsViewModel.selectedWord?.wordItself ?? "").font(.title).bold()
                Spacer()
                Button(action: {
                    wordsViewModel.selectedWord?.isFavorite.toggle()
                    wordsViewModel.save()
                }, label: {
                    Image(systemName: "\(wordsViewModel.selectedWord?.isFavorite ?? false ? "heart.fill" : "heart")")
                        .foregroundColor(.accentColor)
                })
                Button(action: {
                    if !isEditing {
                        isEditing = true
                    } else {
                        wordsViewModel.selectedWord?.partOfSpeech = partOfSpeech.rawValue
                        wordsViewModel.save()
                        isEditing = false
                    }
                }, label: {
                    Text(isEditing ? "Save" : "Edit")
                })
            }
            // MARK: Primary Content

            let bindingWordDefinition = Binding(
                get: { wordsViewModel.selectedWord?.definition ?? "" },
                set: {
                    wordsViewModel.selectedWord?.definition = $0
                }
            )
            ScrollView {
                HStack {
                    Text("Phonetics: ").bold()
                    + Text("[\(wordsViewModel.selectedWord?.phonetic ?? "No transcription")]")
                    Spacer()
                    Button {
                        synthesizer.speak(wordsViewModel.selectedWord?.wordItself ?? "")
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }

                Divider()

                HStack {
                    if !isEditing {
                        Text("Part Of Speech: ").bold()
                        + Text(wordsViewModel.selectedWord?.partOfSpeech ?? "")
                    } else {
                        Picker(selection: $partOfSpeech, label: Text("Part of Speech").bold()) {
                            ForEach(PartOfSpeech.allCases, id: \.self) { partCase in
                                Text(partCase.rawValue)
                            }
                        }
                    }
                    Spacer()
                }

                Divider()

                HStack {
                    if isEditing {
                        Text("Definition: ").bold()
                        TextField("Definition", text: bindingWordDefinition)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text("Definition: ").bold()
                        + Text(wordsViewModel.selectedWord?.definition ?? "")
                    }
                    Spacer()
                    Button {
                        synthesizer.speak(wordsViewModel.selectedWord?.definition ?? "")
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }

                Divider()

                VStack(alignment: .leading) {
                    HStack {
                        Text("Examples:").bold()
                        Spacer()
                        if !examples.isEmpty {
                            Button {
                                withAnimation {
                                    isShowAddExample = true
                                }
                            } label: {
                                Text("Add example")
                            }
                        }
                    }

                    if !examples.isEmpty {
                        ForEach(examples.indices, id: \.self) { index in
                            if !isEditing {
                                Text("\(index + 1). \(examples[index])")
                            } else {
                                HStack {
                                    Button {
                                        removeExample(of: index)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    Text("\(index + 1). \(examples[index])")
                                }
                            }
                        }
                    } else {
                        HStack {
                            Text("No examples yet..")
                            Button {
                                withAnimation {
                                    isShowAddExample = true
                                }
                            } label: {
                                Text("Add example")
                            }
                        }
                    }
                    if isShowAddExample {
                        TextField("Type an example here", text: $exampleTextFieldStr, onCommit: {
                            withAnimation(.easeInOut) {
                                isShowAddExample = false
                                if exampleTextFieldStr != "" {
                                    let newExamples = examples + [exampleTextFieldStr]
                                    let newExamplesData = try? JSONEncoder().encode(newExamples)
                                    wordsViewModel.selectedWord?.examples = newExamplesData
                                    wordsViewModel.save()
                                }
                                exampleTextFieldStr = ""
                            }
                        })
                    }
                }
            }
        }
        .padding()
        .navigationTitle(wordsViewModel.selectedWord?.wordItself ?? "")
        .onAppear {
            switch wordsViewModel.selectedWord?.partOfSpeech {
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
        }
    }

    // MARK: Private methods
    private func removeExample(of index: Int) {
        var examples = self.examples
        examples.remove(at: index)

        let newExamplesData = try? JSONEncoder().encode(examples)
        wordsViewModel.selectedWord?.examples = newExamplesData
        wordsViewModel.save()
    }
}
