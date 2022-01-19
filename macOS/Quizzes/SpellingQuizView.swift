//
//  SpellingQuizView.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/9/21.
//

import SwiftUI

struct SpellingQuizView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: true)],
        animation: .default)
    private var words: FetchedResults<Word>
    
    @State private var randomWord: Word?
    @State private var answerTextField = ""
    @State private var isRightAnswer = true
    @State private var attemptCount = 0
    @State private var isShowAlert = false
    
    @State private var playingWords: [Word] = []
    
    var body: some View {
        VStack {
            Spacer().frame(height: 100)
//            Text("Definition")
//                .foregroundColor(.secondary)
            
            Text(randomWord?.definition ?? "Error")
                .font(.title)
                .bold()
//                .padding(.vertical)
                .padding(.horizontal, 30)
            
            Text(randomWord?.partOfSpeech ?? "error").foregroundColor(.secondary)

            
            Spacer()
            
            VStack {
                Text("Guess the word and then spell it correctly in a text field below")
                    .foregroundColor(.secondary).font(.caption)


                HStack {
                    TextField("Answer", text: $answerTextField, onCommit: {
                        withAnimation {
                            checkAnswer()
                        }
                    })
                        .frame(maxWidth: 300)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.primary.opacity(0.15))
                .cornerRadius(8)
                .padding(.horizontal, 20)
            }
            Text(isRightAnswer ? "" : incorrectMessage)
            
            Button {
                withAnimation {
                    checkAnswer()
                }
            } label: {
                Text("Confirm answer")
            }.disabled(answerTextField.isEmpty)
            
            Spacer().frame(height: 100)
            
        }
        .navigationTitle("Spelling")
        .onAppear {
            playingWords = Array(words)
            randomWord = playingWords.randomElement()
        }
        .alert(isPresented: $isShowAlert, content: {
            Alert(title: Text("Congratulations"), message: Text("You got all your words!"), dismissButton: .default(Text("Okay"), action: {
                //game over
            }))
        })
        
    }
    
    private var incorrectMessage: String {
        guard let randomWord = randomWord else {
            return ""
        }
        
        if attemptCount > 2 {
            return "Your word is '\(randomWord.wordItself!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))'. Try harder :)"
        } else {
            return "Incorrect. Try again"
        }
    }
    
    private func checkAnswer() {
        guard let randomWord = randomWord else {
            return
        }
        
        guard let wordIndex = playingWords.firstIndex(where: {
            $0.id == randomWord.id
        }) else {
            return
        }
        
        if answerTextField.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == randomWord.wordItself!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            isRightAnswer = true
            answerTextField = ""
            playingWords.remove(at: wordIndex)
            attemptCount = 0
            if !playingWords.isEmpty {
                self.randomWord = playingWords.randomElement()
            } else {
                isShowAlert = true
            }
        } else {
            isRightAnswer = false
            attemptCount += 1
        }
    }
}

//struct SpellingQuizView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpellingQuizView()
//    }
//}
