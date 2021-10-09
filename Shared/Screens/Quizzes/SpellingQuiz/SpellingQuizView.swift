//
//  SpellingQuizView.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 9/30/21.
//

import SwiftUI

struct SpellingQuizView: View {
    @Environment(\.presentationMode) var presentationMode
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
        List {
            Section {
                Text(randomWord?.definition ?? "Error")
            } header: {
                Text("Definition")
            } footer: {
                Text("Guess the word and then spell it correctly in a text field below")
            }

            Section {
                HStack {
                    TextField("Type here", text: $answerTextField, onCommit:  {
                        withAnimation {
                            checkAnswer()
                        }
                    })
                    Spacer()
                    Text(randomWord?.partOfSpeech ?? "error").foregroundColor(.secondary)
                }
            } footer: {
                Text(isRightAnswer ? "" : incorrectMessage)
            }
            
            Section {
                Button {
                    withAnimation {
                        checkAnswer()
                    }
                } label: {
                    Text("Confirm answer")
                }.disabled(answerTextField.isEmpty)

            }
        }
        .navigationTitle("Spelling")
        .onAppear {
            playingWords = Array(words)
            randomWord = playingWords.randomElement()
        }
        .alert(isPresented: $isShowAlert, content: {
            Alert(title: Text("Congratulations"), message: Text("You got all your words!"), dismissButton: .default(Text("Okay"), action: {
                presentationMode.wrappedValue.dismiss()
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

struct SpellingQuizView_Previews: PreviewProvider {
    static var previews: some View {
        SpellingQuizView()
    }
}
