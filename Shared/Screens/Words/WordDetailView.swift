//
//  WordDetailView.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 9/28/21.
//

import SwiftUI
import CoreData

struct WordDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var word: Word
    
    @State private var isEditingDefinition = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""
    
    @FocusState private var focusedField: Field?
    
    private var examples: [String] {
        guard let data = word.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }
    
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
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
            } header: {
                Text("Phonetics")
            }
            
            Section {
                Text(word.partOfSpeech ?? "")
            } header: {
                Text("Part Of Speech")
            }
            Section {
                if isEditingDefinition {
                    TextField("Definition", text: bindingWordDefinition, onCommit: {
                        focusedField = nil
                        isEditingDefinition = false
                        save()
                    })
                        .focused($focusedField, equals: .definition)
                } else {
                    Text(word.definition ?? "")
                        .contextMenu {
                            Button("Edit", action: {
//                                withAnimation {
                                    isEditingDefinition = true
//                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                    focusedField = .definition
                                })
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        focusedField = .example
                    })
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
                                focusedField = nil
                                save()
                            }
                            exampleTextFieldStr = ""
                        }
                    })
                        .focused($focusedField, equals: .example)
                }
            } header: {
                Text("Examples")
            }
            
            
        }
        .navigationTitle(word.content ?? "")
        .navigationBarItems(leading: Button(action: {
            //favorites
            word.isFavorite.toggle()
            save()
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
        viewContext.delete(word)
        save()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func removeExample(offsets: IndexSet) {
        var examples = self.examples
        examples.remove(atOffsets: offsets)
        
        let newExamplesData = try? JSONEncoder().encode(examples)
        word.examples = newExamplesData
        save()
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct WordDetailView_Previews: PreviewProvider {
    static let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            
    static var previews: some View {
                
        let word = Word(context: viewContext)
        word.id = UUID()
        word.content = "Fascinating"
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
