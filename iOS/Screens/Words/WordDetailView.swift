import SwiftUI
import CoreData

struct WordDetailView: View {
    @ObservedObject private var wordsViewModel: WordsViewModel
    @State private var isEditingDefinition = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""

    init(wordsViewModel: WordsViewModel) {
        self.wordsViewModel = wordsViewModel
    }

    private var examples: [String] {
        guard let data = wordsViewModel.selectedWord?.examples else { return [] }
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return examples
    }

    private let speechSynthesizer = SpeechSynthesizer.shared

    var body: some View {
        let bindingWordDefinition = Binding(
            get: { wordsViewModel.selectedWord?.definition ?? "" },
            set: { wordsViewModel.selectedWord?.definition = $0 }
        )

        List {
            Section {
                HStack {
                    Text("[\(wordsViewModel.selectedWord?.phonetic ?? "No transcription")]")
                    Spacer()
                    Button {
                        speechSynthesizer.speak(wordsViewModel.selectedWord?.wordItself ?? "")
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
            } header: {
                Text("Phonetics")
            }

            Section {
                Text(wordsViewModel.selectedWord?.partOfSpeech ?? "")
                    .contextMenu {
                        ForEach(PartOfSpeech.allCases, id: \.self) { partCase in
                            Button {
                                wordsViewModel.selectedWord?.partOfSpeech = partCase.rawValue
                                wordsViewModel.save()
                            } label: {
                                Text(partCase.rawValue)
                            }
                        }
                    }
            } header: {
                Text("Part Of Speech")
            }
            Section {
                if isEditingDefinition {
                    TextField("Definition", text: bindingWordDefinition, onCommit: {
                        isEditingDefinition = false
                        wordsViewModel.save()
                    }).disableAutocorrection(true)
                } else {
                    Text(wordsViewModel.selectedWord?.definition ?? "")
                        .contextMenu {
                            Button("Edit", action: {
                                    isEditingDefinition = true
                            })
                        }
                }
            } header: {
                Text("Definition")
            } footer: {
                if !isEditingDefinition {
                    Button {
                        speechSynthesizer.speak(wordsViewModel.selectedWord?.definition ?? "")
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Listen")
                    }
                    .foregroundColor(.accentColor)
                }
            }
            Section {
                Button {
                    withAnimation {
                        isShowAddExample = true
                    }
                } label: {
                    Text("Add example")
                }

                ForEach(examples, id: \.self) { example in
                    Text(example)
                }
                .onDelete(perform: removeExample)

                if isShowAddExample {
                    TextField("Type an example here", text: $exampleTextFieldStr)
                    .onSubmit {
                        onSaveExampleButton()
                    }
                    .submitLabel(.done)
                }
            } header: {
                Text("Examples")
            } footer: {
                if isShowAddExample {
                    Button {
                        onSaveExampleButton()
                    } label: {
                        Image(systemName: "checkmark")
                        Text("Save")
                    }
                    .foregroundColor(.accentColor)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(wordsViewModel.selectedWord?.wordItself ?? "")
        .navigationBarItems(leading: Button(action: {
            // favorites
            wordsViewModel.selectedWord?.isFavorite.toggle()
            wordsViewModel.save()
        }, label: {
            Image(systemName: "\(wordsViewModel.selectedWord?.isFavorite ?? false ? "heart.fill" : "heart")")
        }),
           trailing: Button(action: {
            wordsViewModel.deleteCurrentWord()
        }, label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }))
        .scrollDismissesKeyboard(.interactively)
    }

    private func removeExample(offsets: IndexSet) {
        var examples = self.examples
        examples.remove(atOffsets: offsets)

        let newExamplesData = try? JSONEncoder().encode(examples)
        wordsViewModel.selectedWord?.examples = newExamplesData
        wordsViewModel.save()
    }

    private func onSaveExampleButton() {
        withAnimation(.easeInOut) {
            // save
            isShowAddExample = false
            if exampleTextFieldStr != "" {
                let newExamples = examples + [exampleTextFieldStr]
                let newExamplesData = try? JSONEncoder().encode(newExamples)
                wordsViewModel.selectedWord?.examples = newExamplesData
                wordsViewModel.save()
            }
            exampleTextFieldStr = ""
        }
    }
}
