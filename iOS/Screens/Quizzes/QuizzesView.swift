import SwiftUI
import StoreKit

struct QuizzesView: View {
    @AppStorage("isShowingRating") var isShowingRating: Bool = true
    @StateObject var quizzesViewModel = QuizzesViewModel()

    var body: some View {
        NavigationStack {
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
            .overlay {
                if quizzesViewModel.words.count < 10 {
                    EmptyListView(text: "Add at least 10 words\nto your list to play!")
                }
            }
            .navigationTitle("Quizzes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isShowingRating {
                        Button {
                            SKStoreReviewController.requestReview()
                        } label: {
                            Text("Rate app")
                        }
                    }
                }
            }
            .onAppear {
                quizzesViewModel.fetchWords()
            }
        }
    }
}

struct QuizesView_Previews: PreviewProvider {
    static var previews: some View {
        QuizzesView()
    }
}
