import SwiftUI

struct WordDetailView: View {
    @ObservedObject private var viewModel: WordDetailsViewModel

    @State private var isEditing = false
    @State private var partOfSpeech: PartOfSpeech = .noun

    init(viewModel: WordDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            titleAndToolbar
            content
        }
        .padding()
        .navigationTitle(viewModel.word.wordItself ?? "")
        .onAppear {
            if let partOfSpeechRawValue = viewModel.word.partOfSpeech {
                partOfSpeech = PartOfSpeech(rawValue: partOfSpeechRawValue) ?? .unknown
            }
        }
    }

    // MARK: - Title and toolbar

    private var titleAndToolbar: some View {
        HStack {
            Text(viewModel.word.wordItself ?? "")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: "\(viewModel.word.isFavorite ? "heart.fill" : "heart")")
                    .foregroundColor(.accentColor)
            }

            Button {
                if !isEditing {
                    isEditing = true
                } else {
                    viewModel.changePartOfSpeech(partOfSpeech.rawValue)
                    isEditing = false
                }
            } label: {
                Text(isEditing ? "Save" : "Edit")
            }
        }
    }

    // MARK: - Primary Content

    private var content: some View {
        ScrollView {
            HStack {
                Text("Phonetics: ").bold()
                + Text("[\(viewModel.word.phonetic ?? "No transcription")]")
                Spacer()
                Button {
                    viewModel.speak(viewModel.word.wordItself)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }

            Divider()

            HStack {
                if !isEditing {
                    Text("Part Of Speech: ").bold()
                    + Text(viewModel.word.partOfSpeech ?? "")
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
                    TextField("Definition", text: $viewModel.definitionTextFieldStr)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text("Definition: ").bold()
                    + Text(viewModel.word.definition ?? "")
                }
                Spacer()
                Button {
                    viewModel.speak(viewModel.word.definition)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }

            Divider()

            VStack(alignment: .leading) {
                HStack {
                    Text("Examples:").bold()
                    Spacer()
                    if !viewModel.word.examplesDecoded.isEmpty {
                        Button {
                            withAnimation {
                                viewModel.isShowAddExample = true
                            }
                        } label: {
                            Text("Add example")
                        }
                    }
                }

                if !viewModel.word.examplesDecoded.isEmpty {
                    ForEach(Array(viewModel.word.examplesDecoded.enumerated()), id: \.offset) { offset, element in
                        if !isEditing {
                            Text("\(offset + 1). \(viewModel.word.examplesDecoded[offset])")
                        } else {
                            HStack {
                                Button {
                                    viewModel.removeExample(element)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                Text("\(offset + 1). \(viewModel.word.examplesDecoded[offset])")
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("No examples yet..")
                        Button {
                            withAnimation {
                                viewModel.isShowAddExample = true
                            }
                        } label: {
                            Text("Add example")
                        }
                    }
                }
                if viewModel.isShowAddExample {
                    TextField("Type an example here", text: $viewModel.exampleTextFieldStr, onCommit: {
                        withAnimation(.easeInOut) {
                            viewModel.saveExample()
                        }
                    })
                }
            }
        }
    }
}
