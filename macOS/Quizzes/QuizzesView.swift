import SwiftUI

struct QuizzesView: View {
    @StateObject var quizzesViewModel = QuizzesViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            if quizzesViewModel.words.count < 10 {
                Spacer()
                Text("Add at least 10 words\nto your list to play!")
                    .lineSpacing(10)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
            } else {
                List {
                    Section {
                        NavigationLink(destination: SpellingQuizView().environmentObject(quizzesViewModel)) {
                            Text("Spelling")
                                .padding(.vertical, 8)
                        }
                        NavigationLink(destination: ChooseDefinitionView().environmentObject(quizzesViewModel)) {
                            Text("Choose the right definition")
                                .padding(.vertical, 8)
                        }
                    }
                }
                .font(.title3)
            }
        }
//        .ignoresSafeArea()
        .navigationTitle("Quizzes")
        .onAppear {
            quizzesViewModel.fetchWords()
        }
    }
}

struct QuizzesView_Previews: PreviewProvider {
    static var previews: some View {
        QuizzesView()
    }
}
