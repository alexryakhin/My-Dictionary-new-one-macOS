import SwiftUI
import CoreData

struct IdiomsDetailView: View {
    @ObservedObject private var idiomsViewModel: IdiomsViewModel
    @State private var isEditingDefinition = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""

    init(idiomsViewModel: IdiomsViewModel) {
        self.idiomsViewModel = idiomsViewModel
    }

    private var examples: [String] {
        guard let data = idiomsViewModel.selectedIdiom?.examples else { return [] }
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return examples
    }

    private let synthesizer = SpeechSynthesizer.shared

    var body: some View {
        let bindingIdiomDefinition = Binding(
            get: { idiomsViewModel.selectedIdiom?.definition ?? "" },
            set: { idiomsViewModel.selectedIdiom?.definition = $0 }
        )

        List {
            Section {
                Text(idiomsViewModel.selectedIdiom?.idiomItself ?? "")
                    .font(.system(.headline, design: .rounded))
            } header: {
                Text("Idiom")
            } footer: {
                Button {
                    synthesizer.speak(idiomsViewModel.selectedIdiom?.idiomItself ?? "")
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Listen")
                }
                .foregroundColor(.accentColor)
            }

            Section {
                if isEditingDefinition {
                    TextEditor(text: bindingIdiomDefinition)
                        .frame(height: UIScreen.main.bounds.height / 3)
                    Button {
                        isEditingDefinition = false
                        idiomsViewModel.save()
                    } label: {
                        Text("Save")
                    }
                } else {
                    Text(idiomsViewModel.selectedIdiom?.definition ?? "")
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
                        synthesizer.speak(idiomsViewModel.selectedIdiom?.definition ?? "")
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Listen")
                    }
                    .foregroundColor(.accentColor)
                }
            }
            Section {
                Button {
                    if !isShowAddExample {
                        withAnimation {
                            isShowAddExample = true
                        }
                    } else {
                        withAnimation(.easeInOut) {
                            // save
                            isShowAddExample = false
                            if exampleTextFieldStr != "" {
                                let newExamples = examples + [exampleTextFieldStr]
                                let newExamplesData = try? JSONEncoder().encode(newExamples)
                                idiomsViewModel.selectedIdiom?.examples = newExamplesData
                                idiomsViewModel.save()
                            }
                            exampleTextFieldStr = ""
                        }
                    }
                } label: {
                    Text("Add example")
                }

                ForEach(examples, id: \.self) { example in
                    Text(example)
                }
                .onDelete(perform: removeExample)

                if isShowAddExample {
                    TextField("Type an example here", text: $exampleTextFieldStr, onCommit: {
                        withAnimation(.easeInOut) {
                            // save
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
            } header: {
                Text("Examples")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Details")
        .navigationBarItems(leading: Button(action: {
            // favorites
            idiomsViewModel.selectedIdiom?.isFavorite.toggle()
            idiomsViewModel.save()
        }, label: {
            Image(systemName: "\(idiomsViewModel.selectedIdiom?.isFavorite ?? false ? "heart.fill" : "heart")")
        }), trailing: Button(action: {
            idiomsViewModel.deleteCurrentIdiom()
        }, label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }))
    }

    private func removeExample(offsets: IndexSet) {
        var examples = self.examples
        examples.remove(atOffsets: offsets)
        let newExamplesData = try? JSONEncoder().encode(examples)
        idiomsViewModel.selectedIdiom?.examples = newExamplesData
        idiomsViewModel.save()
    }
}
