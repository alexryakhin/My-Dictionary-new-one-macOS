//
//  AddViewMacOs.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct AddView: View {
    @Binding var isShowingAddView: Bool
    @State private var definitionInput = ""
    @State private var partOfSpeech: PartOfSpeech = .noun
    @ObservedObject var vm = DictionaryManager()
    @State private var wordClassSelection = 0
//    var indices: Range<Array<Definition>.Index> {
//
//    }
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
                isShowingAddView = false
            } label: {
                Text("Save").bold()
            }
            
        }
        .frame(width: 500, height: 400)
        .padding()
    }
    
    private func fetchData() {
        do {
            try vm.fetchData()
        } catch {
            print(error.localizedDescription)
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
