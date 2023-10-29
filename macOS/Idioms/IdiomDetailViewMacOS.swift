import SwiftUI

struct IdiomDetailViewMacOS: View {
    @ObservedObject private var idiomsViewModel: IdiomsViewModel
    @State private var isEditing = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""

    init(idiomsViewModel: IdiomsViewModel) {
        self.idiomsViewModel = idiomsViewModel
    }

    private var examples: [String] {
        guard let data = idiomsViewModel.selectedIdiom?.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }

    let synthesizer = SpeechSynthesizer.shared

    var body: some View {
        VStack {
            // MARK: Title and toolbar
            HStack {
                Text(idiomsViewModel.selectedIdiom?.idiomItself ?? "").font(.title).bold()
                Spacer()
                Button {
                    synthesizer.speak(idiomsViewModel.selectedIdiom?.idiomItself ?? "")
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
                Button(action: {
                    idiomsViewModel.selectedIdiom?.isFavorite.toggle()
                    idiomsViewModel.save()
                }, label: {
                    Image(systemName: "\(idiomsViewModel.selectedIdiom?.isFavorite ?? false ? "heart.fill" : "heart")")
                        .foregroundColor(.accentColor)
                })
                Button(action: {
                    if !isEditing {
                        isEditing = true
                    } else {
                        idiomsViewModel.save()
                        isEditing = false
                    }
                }, label: {
                    Text(isEditing ? "Save" : "Edit")
                })
            }
            // MARK: Primary Content

            let bindingIdiomDefinition = Binding(
                get: { idiomsViewModel.selectedIdiom?.definition ?? "" },
                set: {
                    idiomsViewModel.selectedIdiom?.definition = $0
                }
            )

            ScrollView {
                HStack {
                    if isEditing {
                        Text("Definition: ").bold()
                        TextEditor(text: bindingIdiomDefinition)
                            .padding(1)
                            .background(Color.secondary.opacity(0.4))
                    } else {
                        Text("Definition: ").bold()
                        + Text(idiomsViewModel.selectedIdiom?.definition ?? "")
                    }
                    Spacer()
                    Button {
                        synthesizer.speak(idiomsViewModel.selectedIdiom?.definition ?? "")
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
                                    idiomsViewModel.selectedIdiom?.examples = newExamplesData
                                    idiomsViewModel.save()
                                }
                                exampleTextFieldStr = ""
                            }
                        })
                    }
                }
            }
        }
        .padding()
        .navigationTitle(idiomsViewModel.selectedIdiom?.idiomItself ?? "")
    }

    // MARK: Private methods
    private func removeExample(of index: Int) {
        var examples = self.examples
        examples.remove(at: index)

        let newExamplesData = try? JSONEncoder().encode(examples)
        idiomsViewModel.selectedIdiom?.examples = newExamplesData
        idiomsViewModel.save()
    }
}
