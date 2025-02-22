import SwiftUI

struct ChooseDefinitionView: View {
    @ObservedObject private var viewModel: ChooseDefinitionViewModel

    @State private var rightAnswerIndex = Int.random(in: 0...2)
    @State private var isRightAnswer = true

    init(viewModel: ChooseDefinitionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 100)

            Text(viewModel.words[rightAnswerIndex].wordItself ?? "")
                .font(.largeTitle)
                .bold()
            Text(viewModel.words[rightAnswerIndex].partOfSpeech ?? "")
                    .foregroundColor(.secondary)

            Spacer()
            Text("Choose from given definitions below")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(0..<3) { index in
                Text(viewModel.words[index].definition ?? "")
                    .foregroundColor(.primary)
                    .frame(width: 300)
                    .padding()
                    .background(Color.secondary.opacity(0.3))
                    .cornerRadius(15)
                    .padding(3)
                    .onTapGesture {
                        if viewModel.words[rightAnswerIndex].id == viewModel.words[index].id {
                            withAnimation {
                                isRightAnswer = true
                                viewModel.words.shuffle()
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
