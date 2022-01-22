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
    @EnvironmentObject var persistenceController: PersistenceController
    var word: Word
    @State private var isEditingDefinition = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""
        
    private var examples: [String] {
        guard let data = word.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }
    
    private var utterance: AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: word.wordItself ?? "")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        return utterance
    }
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        let bindingWordDefinition = Binding (
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
                        //play audio of word
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
                        ForEach(PartOfSpeech.allCases, id: \.self) { c in
                            Button {
                                word.partOfSpeech = c.rawValue
                                persistenceController.save()
                            } label: {
                                Text(c.rawValue)
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
                        persistenceController.save()
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
                }.onDelete(perform: removeExample)
                
                
                if isShowAddExample {
                    TextField("Type an example here", text: $exampleTextFieldStr, onCommit: {
                        withAnimation(.easeInOut) {
                            //save
                            isShowAddExample = false
                            if exampleTextFieldStr != "" {
                                let newExamples = examples + [exampleTextFieldStr]
                                let newExamplesData = try? JSONEncoder().encode(newExamples)
                                word.examples = newExamplesData
                                persistenceController.save()
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
            //favorites
            word.isFavorite.toggle()
            persistenceController.save()
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
        persistenceController.delete(word: word)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func removeExample(offsets: IndexSet) {
        var examples = self.examples
        examples.remove(atOffsets: offsets)
        
        let newExamplesData = try? JSONEncoder().encode(examples)
        word.examples = newExamplesData
        persistenceController.save()
    }
}

struct WordDetailView_Previews: PreviewProvider {
    static let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            
    static var previews: some View {
                
        let word = Word(context: viewContext)
        word.id = UUID()
        word.wordItself = "Fascinating"
        word.definition = "Extremely interesting"
        word.partOfSpeech = "noun"
        word.phonetic = "fascinating"
        word.timestamp = Date()
        word.isFavorite = true
        
        return NavigationView {
            WordDetailView(word: word)
        }
        
    }
}

fileprivate enum Field: Int, Hashable {
    case partOfSpeech, definition, example
}
