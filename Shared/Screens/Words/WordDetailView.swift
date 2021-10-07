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
    
    var word: Word
    @State private var isEditingDefinition = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""
    
    var examples: [Example] {
        Array(word.examples as! Set<Example>)
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("[\(word.phonetic ?? "No transcription")]")
                    Spacer()
                    Button {
                        //play audio of word
                        print(word.examples)
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
                Text(word.definition ?? "")
                    .contextMenu {
                        Button("Edit", action: {
                            withAnimation {
                                isEditingDefinition = true
                            }
                        })
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
                    Text(example.string ?? "")
                }
                
                
                if isShowAddExample {
                    TextField("Type an example here", text: $exampleTextFieldStr, onCommit: {
                        withAnimation(.easeInOut) {
                            //save
                            isShowAddExample = false
                            if exampleTextFieldStr != "" {
                                let newExample = Example(context: viewContext)
                                newExample.string = exampleTextFieldStr
                                
                                word.examples?.adding(newExample)
                                print(word.examples)
                            }
                            exampleTextFieldStr = ""
                        }
                    })
                }
            } header: {
                Text("Examples")
            }
            
            
        }
        .navigationTitle(word.content ?? "")
        .navigationBarItems(leading: Button(action: {
            //favorites
            if word.isFavorite {
                word.isFavorite = false
            } else {
                word.isFavorite = true
            }
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
        try? viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}

struct WordDetailView_Previews: PreviewProvider {
    static let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            
    static var previews: some View {
        let example1 = Example(context: viewContext)
        example1.string = "Example 1"
                
        let word = Word(context: viewContext)
        word.id = UUID()
        word.content = "Fascinating"
        word.definition = "Extremely interesting"
        word.partOfSpeech = "noun"
        word.phonetic = "fascinating"
        word.timestamp = Date()
        word.isFavorite = true
        
        example1.word = word
        
        
        return NavigationView {
            WordDetailView(word: word)
        }
        
    }
}
