//
//  WordDetailView.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 9/28/21.
//

import SwiftUI
import CoreData
import AVKit

struct WordDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var wordsViewModel: WordsViewModel
    @ObservedObject var word: Word
    @State private var isEditingDefinition = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""

    private var examples: [String] {
        guard let data = word.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        let bindingWordDefinition = Binding(
            get: { word.definition ?? "" },
            set: {
                word.definition = $0
            }
        )

        List {
            Section {
                HStack {
                    Text("[\(word.phonetic ?? "No transcription")]")
                    Spacer()
                    Button {
                        var utterance: AVSpeechUtterance {
                            let utterance = AVSpeechUtterance(string: word.wordItself ?? "")
                            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                            return utterance
                        }
                        synthesizer.speak(utterance)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
            } header: {
                Text("Phonetics")
            }

            Section {
                Text(word.partOfSpeech ?? "")
                    .contextMenu {
                        ForEach(PartOfSpeech.allCases, id: \.self) { partCase in
                            Button {
                                word.partOfSpeech = partCase.rawValue
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
                    Text(word.definition ?? "")
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
                            let utterance = AVSpeechUtterance(string: word.definition ?? "")
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
                    TextField("Type an example here", text: $exampleTextFieldStr, onCommit: {
                        withAnimation(.easeInOut) {
                            // save
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
            } header: {
                Text("Examples")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(word.wordItself ?? "")
        .navigationBarItems(leading: Button(action: {
            // favorites
            word.isFavorite.toggle()
            wordsViewModel.save()
        }, label: {
            Image(systemName: "\(word.isFavorite ? "heart.fill" : "heart")")
        }),
           trailing: Button(action: {
            // remove word
            removeWord()
        }, label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }))
    }

    private func removeWord() {
        wordsViewModel.delete(word: word)
        presentationMode.wrappedValue.dismiss()
    }

    private func removeExample(offsets: IndexSet) {
        var examples = self.examples
        examples.remove(atOffsets: offsets)

        let newExamplesData = try? JSONEncoder().encode(examples)
        word.examples = newExamplesData
        wordsViewModel.save()
    }
}
