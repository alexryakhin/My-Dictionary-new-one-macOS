//
//  AddViewMacOs.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct AddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isShowingAddView: Bool
    @State private var definitionInput = ""
    @State private var partOfSpeech: PartOfSpeech = .noun
    @ObservedObject var vm = DictionaryManager()
    @State private var wordClassSelection = 0
    @State private var showingAlert = false
    
    var definitions: [Definition] {
        vm.resultWordDetails!.meanings[wordClassSelection].definitions
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Add new word").font(.title2).bold()
                Spacer()
                Button {
                    isShowingAddView = false
                } label: {
                    Text("Close")
                }

            }
            HStack {
                TextField("Enter the word", text: $vm.inputWord, onCommit:  {
                    fetchData()
                })
                Button {
                    fetchData()
                } label: {
                    Text("Get definitions")
                }
            }
            TextField("Enter definition", text: $definitionInput)
            
            if vm.resultWordDetails == nil {
                Picker(selection: $partOfSpeech, label: Text("Part of Speech")) {
                    ForEach(PartOfSpeech.allCases, id: \.self) { c in
                        Text(c.rawValue)
                    }
                }
                
            }
            
            
            
            if vm.resultWordDetails != nil && vm.status == .ready {
                VStack {
                    Picker(selection: $wordClassSelection, label: Text("Part of Speech")) {
                        ForEach(vm.resultWordDetails!.meanings.indices, id: \.self) { index in
                            Text("\(vm.resultWordDetails!.meanings[index].partOfSpeech)")
                        }
                    }
                    
                    if vm.resultWordDetails!.phonetic != nil {
                        HStack(spacing: 0) {
                            Text("Phonetic: ").bold()
                            Text(vm.resultWordDetails!.phonetic ?? "")
                            Spacer()
                            Button {
        //                        speak the word
        //                        synthesizer.speak(utterance)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    
                            }
                        }
                    }
                    
                    TabView() {
                        ForEach(vm.resultWordDetails!.meanings[wordClassSelection].definitions.indices, id: \.self) { index in
                            ScrollView {
                                VStack(alignment: .leading) {
                                    if !definitions[index].definition.isEmpty {
                                        Divider()
                                        HStack {
                                            Text("Definition \(index + 1): ").bold()
                                            + Text(definitions[index].definition)
                                        }
                                        .onTapGesture {
                                            definitionInput = definitions[index].definition
                                        }
                                    }
                                    if definitions[index].example != nil {
                                        Divider()
                                        Text("Example: ").bold()
                                        + Text(definitions[index].example!)
                                    }
                                    if !definitions[index].synonyms.isEmpty {
                                        Divider()
                                        Text("Synonyms: ").bold()
                                        + Text(definitions[index].synonyms.joined(separator: ", "))
                                    }
                                    if !definitions[index].antonyms.isEmpty {
                                        Divider()
                                        Text("Antonyms: ").bold()
                                        + Text(definitions[index].antonyms.joined(separator: ", "))
                                    }
                                }
                            }.tabItem({
                                Text("\(index + 1)")
                            })
                                .padding(.horizontal)
                        }
                    }
                }
            } else {
                Spacer()
            }
            
            
            Button {
                saveNewWord()
            } label: {
                Text("Save").bold()
            }
            
        }
        .frame(width: 600, height: 500)
        .padding()
    }
    
    private func fetchData() {
        do {
            try vm.fetchData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveNewWord() {
        if !vm.inputWord.isEmpty, !definitionInput.isEmpty {
            let newWord = Word(context: viewContext)
            newWord.id = UUID()
            newWord.wordItself = vm.inputWord
            newWord.definition = definitionInput
            if vm.resultWordDetails == nil {
                newWord.partOfSpeech = partOfSpeech.rawValue
            } else {
                newWord.partOfSpeech = vm.resultWordDetails!.meanings[wordClassSelection].partOfSpeech
            }
            newWord.phonetic = vm.resultWordDetails?.phonetic
            newWord.timestamp = Date()
            save()
            isShowingAddView = false
            vm.resultWordDetails = nil
            vm.inputWord = ""
            vm.status = .blank
        } else {
            showingAlert = true
        }
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

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(isShowingAddView: .constant(true))
    }
}

enum PartOfSpeech: String, CaseIterable {
    case noun
    case verb
    case adjective
    case adverb
    case exclamation
    case conjunction
    case pronoun
    case number
    case unknown
}
