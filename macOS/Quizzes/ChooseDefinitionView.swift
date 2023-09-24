import SwiftUI

struct ChooseDefinitionView: View {
    @State private var rightAnswerIndex = Int.random(in: 0...2)
    @State private var isRightAnswer = true
    @EnvironmentObject var quizzesViewModel: QuizzesViewModel

    var body: some View {
        VStack {
            Spacer().frame(height: 100)

            Text(quizzesViewModel.words[rightAnswerIndex].wordItself ?? "")
                .font(.largeTitle)
                .bold()
            Text(quizzesViewModel.words[rightAnswerIndex].partOfSpeech ?? "")
                    .foregroundColor(.secondary)

            Spacer()
            Text("Choose from given definitions below")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(0..<3) { index in
                Text(quizzesViewModel.words[index].definition ?? "")
                    .foregroundColor(.primary)
                    .frame(width: 300)
                    .padding()
                    .background(Color.secondary.opacity(0.3))
                    .cornerRadius(15)
                    .padding(3)
                    .onTapGesture {
                        if quizzesViewModel.words[rightAnswerIndex].id == quizzesViewModel.words[index].id {
                            withAnimation {
                                isRightAnswer = true
                                quizzesViewModel.words.shuffle()
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
