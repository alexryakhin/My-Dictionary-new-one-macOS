import SwiftUI

struct AddWordView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: AddWordViewModel

    init(viewModel: AddWordViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    FormWithDivider {
                        wordCellView
                        definitionCellView
                        partOfSpeechCellView
                        phoneticsCellView
                    }
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    definitionsSectionView
                }
                .editModeDisabling()
            }
            .background(
                Color(.background)
                    .ignoresSafeArea()
                    .editModeDisabling()
            )
            .navigationBarTitle("Add new word")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.saveWord()
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.system(.headline, design: .rounded))
                    }
                }
            }
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(
                    title: Text("Ooops..."),
                    message: Text("You should enter a word and its definition before saving it"),
                    dismissButton: .default(Text("Got it"))
                )
            }
        }
    }

    var wordCellView: some View {
        CellWrapper("Word") {
            CustomTextField("Type a word", text: $viewModel.inputWord, submitLabel: .search) {
                if viewModel.inputWord.isNotEmpty && viewModel.inputWord.isCorrect {
                    viewModel.fetchData()
                }
            }
            .autocorrectionDisabled()
        }
    }

    var definitionCellView: some View {
        CellWrapper("Definition") {
            CustomTextField("Enter definition", text: $viewModel.descriptionField)
                .autocorrectionDisabled()
        }
    }

    @ViewBuilder
    var partOfSpeechCellView: some View {
        var cases: [PartOfSpeech] {
            if let result = viewModel.resultWordDetails {
                return result.meanings
                    .compactMap {
                        PartOfSpeech(rawValue: $0.partOfSpeech)
                    }
            } else {
                return PartOfSpeech.allCases
            }
        }
        CellWrapper("Part of speech") {
            Menu {
                ForEach(cases, id: \.self) { partCase in
                    Button {
                        viewModel.partOfSpeech = partCase
                    } label: {
                        if viewModel.partOfSpeech == partCase {
                            Image(systemName: "checkmark")
                        }
                        Text(partCase.rawValue)
                    }
                }
            } label: {
                Text(viewModel.partOfSpeech?.rawValue ?? "Select a value")
            }
        }
    }

    @ViewBuilder
    var phoneticsCellView: some View {
        if let phonetic = viewModel.resultWordDetails?.phonetic {
            CellWrapper("Phonetics") {
                Text(phonetic)
            } trailingContent: {
                Button {
                    viewModel.speakInputWord()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    @ViewBuilder
    var definitionsSectionView: some View {
        if let meaning = viewModel.resultWordDetails?.meanings.first(where: {
            $0.partOfSpeech == viewModel.partOfSpeech?.rawValue
        }) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Select a definition")
                    .font(.callout)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                ForEach(Array(meaning.definitions.enumerated()), id: \.offset) { offset, element in
                    FormWithDivider {
                        if element.definition.isNotEmpty {
                            CellWrapper("Definition \(offset + 1)") {
                                Text(element.definition)
                                    .multilineTextAlignment(.leading)
                            } onTapAction: {
                                viewModel.descriptionField = element.definition
                                viewModel.partOfSpeech = .init(rawValue: meaning.partOfSpeech) ?? .unknown
                                UIApplication.shared.endEditing()
                            }
                        }
                        if let example = element.example {
                            CellWrapper("Example") {
                                Text(example)
                            }
                        }
                        if element.synonyms.isNotEmpty {
                            CellWrapper("Synonyms") {
                                Text(element.synonyms.joined(separator: ", "))
                            }
                        }
                        if element.antonyms.isNotEmpty {
                            CellWrapper("Antonyms") {
                                Text(element.antonyms.joined(separator: ", "))
                            }
                        }
                    }
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

import Swinject
import SwinjectAutoregistration

#Preview {
    DIContainer.shared.resolver.resolve(AddWordView.self, argument: "input")!
}
