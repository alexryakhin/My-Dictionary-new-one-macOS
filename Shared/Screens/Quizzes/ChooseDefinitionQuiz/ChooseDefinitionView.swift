//
//  ChooseDefinitionView.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 9/30/21.
//

import SwiftUI

struct ChooseDefinitionView: View {
    @State private var rightAnswerIndex = Int.random(in: 0...2)
    @State private var isRightAnswer = true
    
    @ObservedObject var vm: QuizzesViewModel
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text(vm.words[rightAnswerIndex].wordItself ?? "")
                        .bold()
                    Spacer()
                    Text(vm.words[rightAnswerIndex].partOfSpeech ?? "")
                        .foregroundColor(.secondary)
                }
                
            } header: {
                Text("Given word")
            } footer: {
                Text("Choose from given definitions below")
            }
            
            Section {
                ForEach(0..<3) { index in
                    Button {
                        if vm.words[rightAnswerIndex].id == vm.words[index].id {
                            withAnimation {
                                isRightAnswer = true
                                vm.words.shuffle()
                            }
                        } else {
                            withAnimation {
                                isRightAnswer = false
                            }
                        }
                    } label: {
                        Text(vm.words[index].definition ?? "")
                            .foregroundColor(.primary)
                    }
                }
            } footer: {
                Text(isRightAnswer ? "" : "Incorrect. Try Arain")
            }

        }
        .navigationTitle("Choose Definition")
        .onAppear {
            rightAnswerIndex = Int.random(in: 0...2)
        }
    }
}

class QuizzesViewModel: ObservableObject {
    @Published var words: [Word] = []
    
    init(words: [Word]) {
        self.words = words
    }
}
