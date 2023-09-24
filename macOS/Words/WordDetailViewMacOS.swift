import SwiftUI

struct WordDetailView: View {
    @ObservedObject var word: Word
    @EnvironmentObject var wordsViewModel: WordsViewModel
    @State private var isEditing = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""
    @State private var partOfSpeech: PartOfSpeech = .noun

    private var examples: [String] {
        guard let data = word.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }

    private let synthesizer = SpeechSynthesizer.shared

    var body: some View {
        VStack {
            // MARK: Title and toolbar
            HStack {
                Text(word.wordItself ?? "").font(.title).bold()
                Spacer()
                Button(action: {
                    word.isFavorite.toggle()
                    wordsViewModel.save()
                }, label: {
                    Image(systemName: "\(word.isFavorite ? "heart.fill" : "heart")")
                        .foregroundColor(.accentColor)
                })
                Button(action: {
                    if !isEditing {
                        isEditing = true
                    } else {
                        word.partOfSpeech = partOfSpeech.rawValue
                        wordsViewModel.save()
                        isEditing = false
                    }
                }, label: {
                    Text(isEditing ? "Save" : "Edit")
                })
            }
            // MARK: Primary Content

            let bindingWordDefinition = Binding(
                get: { word.definition ?? "" },
                set: {
                    word.definition = $0
                }
            )
            ScrollView {
                HStack {
                    Text("Phonetics: ").bold()
                    + Text("[\(word.phonetic ?? "No transcription")]")
                    Spacer()
                    Button {
                        synthesizer.speak(word.wordItself ?? "")
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }

                Divider()

                HStack {
                    if !isEditing {
                        Text("Part Of Speech: ").bold()
                        + Text(word.partOfSpeech ?? "")
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
                        + Text(word.definition ?? "")
                    }
                    Spacer()
                    Button {
                        synthesizer.speak(word.definition ?? "")
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
                                    word.examples = newExamplesData
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
        .navigationTitle(word.wordItself ?? "")
        .onAppear {
            switch word.partOfSpeech {
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
        word.examples = newExamplesData
        wordsViewModel.save()
    }
}
