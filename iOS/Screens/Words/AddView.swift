//
//  AddView.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 6/20/21.
//

import SwiftUI
import AVKit

struct AddView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var persistenceController: PersistenceController
    
    @ObservedObject var vm: DictionaryViewModel
    @State private var descriptionField = ""
    @State private var partOfSpeech: PartOfSpeech = .unknown
    @State private var showingAlert = false
    
    private var utterance: AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: vm.inputWord)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        return utterance
    }
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 11) {
                    TextField("Enter your word", text: $vm.inputWord, onCommit: {
                        if !vm.inputWord.isEmpty {
                            do {
                                try vm.fetchData()
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else {
                            print("type a word")
                        }
                    })
                        .padding(.horizontal)
                        .padding(.top, 11)
                    Divider().padding(.leading)
                    TextField("Word's definition", text: $descriptionField)
                        .padding(.horizontal)
                    Divider().padding(.leading)
                    Text(partOfSpeech == .unknown ? "Part of speech" : partOfSpeech.rawValue)
                        .padding(.horizontal)
                        .foregroundColor(
                            partOfSpeech == .unknown
                            ? Color("TextFieldColor")
                            : Color.primary
                        )
                        .contextMenu {
                            ForEach(PartOfSpeech.allCases, id: \.self) { c in
                                Button {
                                    partOfSpeech = c
                                } label: {
                                    Text(c.rawValue)
                                }

                            }
                        }
                    Divider().padding(.leading)
                    Button(action: {
                        searchForWord()
                        hideKeyboard()
                    }, label: {
                        Text("Get definitions from the Internet")
                            .padding(.vertical, 1)
                    })
                        .padding(.bottom, 11)
                        .foregroundColor(vm.inputWord.isEmpty ? Color.gray.opacity(0.5) : .green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .disabled(vm.inputWord.isEmpty)
                }
                .background(Color("TableBackground").cornerRadius(10))
                .padding(.horizontal)
                
                Section {
                    if vm.resultWordDetails != nil && vm.status == .ready {
                        if vm.resultWordDetails!.phonetic != nil {
                            HStack(spacing: 0) {
                                HStack {
                                    Text("Phonetic: ").bold()
                                    + Text(vm.resultWordDetails!.phonetic ?? "")
                                }.padding(.top)
                                Spacer()
                                Button {
                                    synthesizer.speak(utterance)
                                } label: {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.title3)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
                                        .background(Color.accentColor)
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        WordCard(
                            wordMeanings: vm.resultWordDetails!.meanings, tapGesture: { descriptionStr, partOfSpeechStr in
                                descriptionField = descriptionStr
                                
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
                                
                                hideKeyboard()
                            })
                    } else if vm.status == .loading {
                        VStack {
                            Spacer().frame(height: 50)
                            ProgressView()
                            Spacer()
                        }
                        .onTapGesture {
                            hideKeyboard()
                        }
                    } else if vm.status == .blank {
                        VStack {
                            Spacer().frame(height: 25)
                            Text("*After the data shows up here, tap on word's definition to fill it into definition's field.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                            Spacer()
                        }
                        .onTapGesture {
                            hideKeyboard()
                        }
                    } else if vm.status == .error {
                        VStack {
                            Spacer().frame(height: 25)
                            Text("Couldn't get the word's data, check your spelling. Or you lost your internet connection, so check this out as well.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                            Spacer()
                        }
                        .onTapGesture {
                            hideKeyboard()
                        }
                    }
                }
                
                .cornerRadius(15)
            }
            .ignoresSafeArea(.all, edges: [.bottom])
            .background(Color("Background")
                            .ignoresSafeArea()
                            .onTapGesture(perform: {
                        hideKeyboard()
                    })
            )
            .navigationBarTitle("Add new word")
            .navigationBarItems(trailing: Button(action: {
                if !vm.inputWord.isEmpty, !descriptionField.isEmpty {
                    persistenceController.addNewWord(
                        word: vm.inputWord.capitalizingFirstLetter(),
                        definition: descriptionField.capitalizingFirstLetter(),
                        partOfSpeech: partOfSpeech.rawValue,
                        phonetic: vm.resultWordDetails?.phonetic)
                    self.presentationMode.wrappedValue.dismiss()
                    vm.resultWordDetails = nil
                    vm.inputWord = ""
                    vm.status = .blank
                } else {
                    showingAlert = true
                }
            }, label: {
                Text("Save")
            }))
            .alert(isPresented: $showingAlert, content: {
                Alert(title: Text("Ooops..."), message: Text("You should enter a word and its definition before saving it"), dismissButton: .default(Text("Got it")))
            })
            .onAppear {
                searchForWord()
            }
        }
    }
    private func searchForWord() {
        if !vm.inputWord.isEmpty {
            do {
               try vm.fetchData()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("type a word")
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(vm: DictionaryViewModel())
    }
}
