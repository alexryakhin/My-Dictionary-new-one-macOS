import SwiftUI

struct ChooseDefinitionView: View {
    @StateObject private var viewModel: ChooseDefinitionViewModel

    init(viewModel: ChooseDefinitionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        if !viewModel.words.isEmpty {
            VStack {
                Spacer().frame(height: 100)

                Text(viewModel.words[viewModel.correctAnswerIndex].wordItself ?? "")
                    .font(.largeTitle)
                    .bold()
                Text(viewModel.words[viewModel.correctAnswerIndex].partOfSpeech ?? "")
                    .foregroundColor(.secondary)

                Spacer()
                Text("Choose from the given definitions below")
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
                            viewModel.answerSelected(index)
                        }
                }

                Text(viewModel.isCorrectAnswer ? "" : "Incorrect. Try Again")
                Spacer().frame(height: 100)
            }
            .ignoresSafeArea()
            .navigationTitle("Choose Definition")
            .onAppear {
                viewModel.correctAnswerIndex = Int.random(in: 0...2)
            }
        }
    }
}
