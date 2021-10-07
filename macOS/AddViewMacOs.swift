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
    var indices: Range<Array<Definition>.Index> {
        vm.resultWordDetails!.meanings[wordClassSelection].definitions.indices
    }
    var definitions: [Definition] {
        vm.resultWordDetails!.meanings[wordClassSelection].definitions
    }
    
    var body: some View {
        VStack {
            Text("Add new word")
            
            TextField("Enter the word", text: $vm.inputWord)
            TextField("Enter definition", text: $definitionInput)
            
            Picker(selection: $partOfSpeech, label: Text("Part of Speech")) {
                ForEach(PartOfSpeech.allCases, id: \.self) { c in
                    Text(c.rawValue)
                }
            }
            
            Button {
                vm.fetchData()
                print(vm.resultWordDetails)
            } label: {
                Text("Get definitions from the internet")
            }
            
            Group {
                if vm.resultWordDetails != nil && vm.status == .ready {
                    TabView() {
                        ForEach(indices, id: \.self) { index in
                            ScrollView {
                                VStack(alignment: .leading) {
                                    if !definitions[index].definition.isEmpty {
                                        Divider()
                                        Text("**Definition \(index + 1):** \(definitions[index].definition)")
                                            .onTapGesture {
                                                let partOfSpeechStr = vm.resultWordDetails!.meanings[wordClassSelection].partOfSpeech
                                                
                                                switch partOfSpeechStr {
                                                case "noun":
                                                    partOfSpeech = .noun
                                                case "verb":
                                                    partOfSpeech = .verb
                                                case "adjective":
                                                    partOfSpeech = .adjective
                                                case "adverb":
                                                    partOfSpeech = .adverb
                                                case "exclamation":
                                                    partOfSpeech = .exclamation
                                                case "conjunction":
                                                    partOfSpeech = .conjunction
                                                case "pronoun":
                                                    partOfSpeech = .pronoun
                                                case "number":
                                                    partOfSpeech = .number
                                                default:
                                                    partOfSpeech = .unknown
                                                }
                                                
                                                definitionInput = definitions[index].definition
                                                
                                            }
                                        
                                    }
                                    if definitions[index].example != nil {
                                        Divider()
                                        Text("**Example:** \(definitions[index].example!)")
                                    }
                                    if !definitions[index].synonyms.isEmpty {
                                        Divider()
                                        Text("**Synonyms:** \(definitions[index].synonyms.joined(separator: ", "))")
                                    }
                                    if !definitions[index].antonyms.isEmpty {
                                        Divider()
                                        Text("**Antonyms:** \(definitions[index].antonyms.joined(separator: ", "))")
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            
            
            Button {
                isShowingAddView = false
            } label: {
                Text("Save")
            }
            
        }.padding()
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
