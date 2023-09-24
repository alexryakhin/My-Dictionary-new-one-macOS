import SwiftUI

struct IdiomDetailViewMacOS: View {
    @EnvironmentObject var idiomsViewModel: IdiomsViewModel
    @ObservedObject var idiom: Idiom
    @State private var isEditing = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""

    private var examples: [String] {
        guard let data = idiom.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }

    let synthesizer = SpeechSynthesizer.shared

    var body: some View {
        VStack {
            // MARK: Title and toolbar
            HStack {
                Text(idiom.idiomItself ?? "").font(.title).bold()
                Spacer()
                Button {
                    synthesizer.speak(idiom.idiomItself ?? "")
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
                Button(action: {
                    idiom.isFavorite.toggle()
                    idiomsViewModel.save()
                }, label: {
                    Image(systemName: "\(idiom.isFavorite ? "heart.fill" : "heart")")
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
                get: { idiom.definition ?? "" },
                set: {
                    idiom.definition = $0
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
                        + Text(idiom.definition ?? "")
                    }
                    Spacer()
                    Button {
                        synthesizer.speak(idiom.definition ?? "")
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
                                    idiom.examples = newExamplesData
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
        .navigationTitle(idiom.idiomItself ?? "")
    }

    // MARK: Private methods
    private func removeExample(of index: Int) {
        var examples = self.examples
        examples.remove(at: index)

        let newExamplesData = try? JSONEncoder().encode(examples)
        idiom.examples = newExamplesData
        idiomsViewModel.save()
    }
}
