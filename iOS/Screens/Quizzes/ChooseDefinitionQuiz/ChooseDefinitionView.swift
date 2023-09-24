import SwiftUI

struct ChooseDefinitionView: View {
    @EnvironmentObject var quizzesViewModel: QuizzesViewModel
    @State private var rightAnswerIndex = Int.random(in: 0...2)
    @State private var isRightAnswer = true

    var body: some View {
        List {
            Section {
                HStack {
                    Text(quizzesViewModel.words[rightAnswerIndex].wordItself ?? "")
                        .bold()
                    Spacer()
                    Text(quizzesViewModel.words[rightAnswerIndex].partOfSpeech ?? "")
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
                    } label: {
                        Text(quizzesViewModel.words[index].definition ?? "")
                            .foregroundColor(.primary)
                    }
                }
            } footer: {
                Text(isRightAnswer ? "" : "Incorrect. Try Arain")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Choose Definition")
        .onAppear {
            rightAnswerIndex = Int.random(in: 0...2)
        }
    }
}
