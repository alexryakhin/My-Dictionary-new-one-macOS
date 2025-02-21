import SwiftUI
import CoreData

struct WordDetailsView: View {
    @StateObject private var viewModel: WordDetailsViewModel

    init(viewModel: WordDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
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
                TextField("Definition", text: $viewModel.definitionTextFieldStr)
            } header: {
                Text("Definition")
            } footer: {
                Button {
                    viewModel.speak(viewModel.word.definition)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Listen")
                }
                .foregroundColor(.accentColor)
            }
            Section {
                Button {
                    withAnimation {
                        viewModel.isShowAddExample = true
                    }
                } label: {
                    Text("Add example")
                }

                ForEach(viewModel.word.examplesDecoded, id: \.self) { example in
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
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.word.isFavorite
                          ? "heart.fill"
                          : "heart"
                    )
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
