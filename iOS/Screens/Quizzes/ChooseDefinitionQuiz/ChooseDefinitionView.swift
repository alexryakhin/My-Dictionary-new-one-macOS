import SwiftUI
import Combine

struct ChooseDefinitionView: View {
    @StateObject private var viewModel: ChooseDefinitionViewModel

    init(viewModel: ChooseDefinitionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        if !viewModel.words.isEmpty {
            List {
                Section {
                    HStack {
                        Text(viewModel.correctWord.wordItself ?? "")
                            .bold()
                        Spacer()
                        Text(viewModel.correctWord.partOfSpeech ?? "")
                            .foregroundColor(.secondary)
                    }

                } header: {
                    Text("Given word")
                } footer: {
                    Text("Choose from the given definitions below")
                }

                Section {
                    ForEach(0..<3) { index in
                        Button {
                            viewModel.answerSelected(index)
                        } label: {
                            Text(viewModel.words[index].definition ?? "")
                                .foregroundColor(.primary)
                        }
                    }
                } footer: {
                    Text(viewModel.isCorrectAnswer ? "" : "Incorrect. Try Again")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Choose Definition")
            .onAppear {
                viewModel.correctAnswerIndex = Int.random(in: 0...2)
            }
        }
    }
}
