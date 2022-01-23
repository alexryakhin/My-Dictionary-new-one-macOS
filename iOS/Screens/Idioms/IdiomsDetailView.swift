//
//  IdiomsDetailView.swift
//  My Dictionary (iOS)
//
//  Created by Alexander Ryakhin on 1/22/22.
//

import SwiftUI
import CoreData
import AVKit

struct IdiomsDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var idiomsViewModel: IdiomsViewModel
    @ObservedObject var idiom: Idiom
    @State private var isEditingDefinition = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""

    private var examples: [String] {
        guard let data = idiom.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        let bindingIdiomDefinition = Binding(
            get: { idiom.definition ?? "" },
            set: {
                idiom.definition = $0
            }
        )

        List {
            Section {
                Text(idiom.idiomItself ?? "")
                    .font(.system(.headline, design: .rounded))
            } header: {
                Text("Idiom")
            } footer: {
                Button {
                    var utterance: AVSpeechUtterance {
                        let utterance = AVSpeechUtterance(string: idiom.idiomItself ?? "")
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        return utterance
                    }
                    synthesizer.speak(utterance)
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
                    Text(idiom.definition ?? "")
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
                        var utterance: AVSpeechUtterance {
                            let utterance = AVSpeechUtterance(string: idiom.definition ?? "")
                            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                            return utterance
                        }
                        synthesizer.speak(utterance)
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
                                idiom.examples = newExamplesData
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
                                idiom.examples = newExamplesData
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
            idiom.isFavorite.toggle()
            idiomsViewModel.save()
        }, label: {
            Image(systemName: "\(idiom.isFavorite ? "heart.fill" : "heart")")
        }), trailing: Button(action: {
            // remove word
            removeIdiom()
        }, label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }))
    }

    private func removeIdiom() {
        idiomsViewModel.delete(idiom: idiom)
        presentationMode.wrappedValue.dismiss()
    }

    private func removeExample(offsets: IndexSet) {
        var examples = self.examples
        examples.remove(atOffsets: offsets)
        let newExamplesData = try? JSONEncoder().encode(examples)
        idiom.examples = newExamplesData
        idiomsViewModel.save()
    }
}
