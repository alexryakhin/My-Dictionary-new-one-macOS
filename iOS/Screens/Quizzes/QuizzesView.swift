//
//  QuizzesView.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 9/30/21.
//

import SwiftUI

struct QuizzesView: View {
    @StateObject var quizzesViewModel = QuizzesViewModel()

    var body: some View {
        NavigationView {
            if quizzesViewModel.words.count < 10 {
                ZStack {
                    Color("Background").ignoresSafeArea()
                    VStack {
                        Spacer()
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
                                .environmentObject(quizzesViewModel)
                        } label: {
                            Text("Spelling")
                        }

                        NavigationLink {
                            ChooseDefinitionView()
                                .environmentObject(quizzesViewModel)
                        } label: {
                            Text("Choose the right definition")
                        }
                    } footer: {
                        Text("All words are from your list.")
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Quizzes")
            }
        }
    }
}

struct QuizesView_Previews: PreviewProvider {
    static var previews: some View {
        QuizzesView()
    }
}
