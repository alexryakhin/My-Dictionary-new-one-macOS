//
//  QuizzesView.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/9/21.
//

import SwiftUI

struct QuizzesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: true)],
        animation: .default)
    var words: FetchedResults<Word>
    
    @State private var playingWords: [Word] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            if words.count < 10 {
                HStack {
                    Text("Quizzes").font(.title2).bold().padding().padding(.top, 50)
                    Spacer()
                }
                Text("Add at least 10 words\nto your list to play!")
                    .lineSpacing(10)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
            } else {
                Text("Quizzes").font(.title2).bold().padding(.horizontal).padding(.top, 50)
                List {
                    NavigationLink(destination: SpellingQuizView()) {
                        Text("Spelling")
                    }
                    NavigationLink(destination: ChooseDefinitionView(vm: QuizzesViewModel(words: playingWords))) {
                        Text("Choose the right definition")
                    }
                }
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Quizzes")
        .onAppear {
            playingWords = Array(words)
        }
    }
}

struct QuizzesView_Previews: PreviewProvider {
    static var previews: some View {
        QuizzesView()
    }
}
