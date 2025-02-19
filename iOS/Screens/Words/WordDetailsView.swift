import SwiftUI
import CoreData

struct WordDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: WordDetailsViewModel

    init(viewModel: WordDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        let bindingWordDefinition = Binding(
            get: { viewModel.word.definition ?? "" },
            set: { viewModel.word.definition = $0 }
        )

        List {
            Section {
                HStack {
                    Text("[\(viewModel.word.phonetic ?? "No transcription")]")
                    Spacer()
                    Button {
                        viewModel.speak(viewModel.word.wordItself)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
            } header: {
                Text("Phonetics")
            }

            Section {
                Text(viewModel.word.partOfSpeech ?? "")
                    .contextMenu {
                        ForEach(PartOfSpeech.allCases, id: \.self) { partCase in
                            Button {
                                viewModel.changePartOfSpeech(partCase.rawValue)
                            } label: {
                                Text(partCase.rawValue)
                            }
                        }
                    }
            } header: {
                Text("Part Of Speech")
            }

            Section {
                if viewModel.isEditingDefinition {
                    TextField("Definition", text: bindingWordDefinition, onCommit: {
                        viewModel.isEditingDefinition = false
                        viewModel.save()
                    }).disableAutocorrection(true)
                } else {
                    Text(viewModel.word.definition ?? "")
                        .contextMenu {
                            Button("Edit", action: {
                                viewModel.isEditingDefinition = true
                            })
                        }
                }
            } header: {
                Text("Definition")
            } footer: {
                if !viewModel.isEditingDefinition {
                    Button {
                        viewModel.speak(viewModel.word.definition)
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
                        viewModel.isShowAddExample = true
                    }
                } label: {
                    Text("Add example")
                }

                ForEach(viewModel.examples, id: \.self) { example in
                    Text(example)
                }
                .onDelete(perform: viewModel.removeExample)

                if viewModel.isShowAddExample {
                    TextField("Type an example here", text: $viewModel.exampleTextFieldStr)
                        .onSubmit {
                            viewModel.saveExample()
                        }
                        .submitLabel(.done)
                }
            } header: {
                Text("Examples")
            } footer: {
                if viewModel.isShowAddExample {
                    Button {
                        viewModel.saveExample()
                    } label: {
                        Image(systemName: "checkmark")
                        Text("Save")
                    }
                    .foregroundColor(.accentColor)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.word.wordItself ?? "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.deleteCurrentWord()
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // favorites
                    viewModel.word.isFavorite.toggle()
                    viewModel.save()
                } label: {
                    Image(systemName: viewModel.word.isFavorite ?? false
                          ? "heart.fill"
                          : "heart"
                    )
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
