//
//  ChooseDefinitionView.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/9/21.
//

import SwiftUI

struct ChooseDefinitionView: View {
    @State private var rightAnswerIndex = Int.random(in: 0...2)
    @State private var isRightAnswer = true
    
    @ObservedObject var vm: QuizzesViewModel
    
    var body: some View {
        VStack {
            Spacer().frame(height: 100)
//            Text("Given word:")

            Text(vm.words[rightAnswerIndex].wordItself ?? "")
                .font(.largeTitle)
                .bold()
//                .padding()
            Text(vm.words[rightAnswerIndex].partOfSpeech ?? "")
                    .foregroundColor(.secondary)
            
            Spacer()
            Text("Choose from given definitions below")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(0..<3) { index in
                Text(vm.words[index].definition ?? "")
                    .foregroundColor(.primary)
                    .frame(width: 300)
                    .padding()
                    .background(Color.secondary.opacity(0.3))
                    .cornerRadius(15)
                    .padding(3)
                    .onTapGesture {
                        if vm.words[rightAnswerIndex].id == vm.words[index].id {
                            withAnimation {
                                isRightAnswer = true
                                vm.words.shuffle()
                                rightAnswerIndex = Int.random(in: 0...2)
                            }
                        } else {
                            withAnimation {
                                isRightAnswer = false
                            }
                        }
                    }
            }
            
            Text(isRightAnswer ? "" : "Incorrect. Try Arain")
            Spacer().frame(height: 100)
        }
        .ignoresSafeArea()
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
