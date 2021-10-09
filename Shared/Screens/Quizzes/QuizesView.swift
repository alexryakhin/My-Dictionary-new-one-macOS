//
//  QuizesView.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 9/30/21.
//

import SwiftUI

struct QuizesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: true)],
        animation: .default)
    var words: FetchedResults<Word>
    
    @State private var playingWords: [Word] = []

    var body: some View {
        NavigationView {
            if words.count < 10 {
                ZStack {
                    Color("Background").ignoresSafeArea()
                    VStack {
                        Spacer().frame(height: 100)
                        Image(systemName: "applescript")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 60)

                        Text("Add at least 10 words\nto your list to play!")
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                }
                .navigationTitle("Quizzes")
            } else {
                List {
                    Section {
                        NavigationLink {
                            SpellingQuizView()
                        } label: {
                            Text("Spelling")
                        }

                        NavigationLink {
                            ChooseDefinitionView(vm: QuizzesViewModel(words: playingWords))
                        } label: {
                            Text("Choose the right definition")
                        }
                    } footer: {
                        Text("All words are from your list.")
                    }
                }
                .navigationTitle("Quizzes")
                .onAppear {
                    playingWords = Array(words)
                }
            }
        }
    }
}

struct QuizesView_Previews: PreviewProvider {
    static var previews: some View {
        QuizesView()
    }
}
