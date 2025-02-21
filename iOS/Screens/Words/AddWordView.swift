import SwiftUI

struct AddWordView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: AddWordViewModel

    init(viewModel: AddWordViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack {
                FormWithDivider {
                    CellWrapper {
                        TextField("Enter your word", text: $viewModel.inputWord, onCommit: {
                            if !viewModel.inputWord.isEmpty {
                                viewModel.fetchData()
                            } else {
                                // TODO: snack
                                print("type a word")
                            }
                        })
                    }

                    CellWrapper {
                        TextField("Word's definition", text: $viewModel.descriptionField)
                    }

                    CellWrapper {
                        partOfSpeechMenu
                    }

                    CellWrapper {
                        Text("Get definitions from the Internet")
                    } onTapAction: {
                        viewModel.fetchData()
                        UIApplication.shared.endEditing()
                    }
                    .disabled(viewModel.inputWord.isEmpty)
                }
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                detailsView
            }
            .ignoresSafeArea(.all, edges: [.bottom])
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

    var errorView: some View {
        VStack {
            Spacer().frame(height: 25)
            Text("Couldn't get the word's data, check your spelling. Or you lost your internet connection, so check this out as well.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
        .editModeDisabling()
    }

    var blankView: some View {
        VStack {
            Spacer().frame(height: 25)
            Text("*After the data shows up here, tap on word's definition to fill it into definition's field.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
        .editModeDisabling()
    }

    var loadingView: some View {
        VStack {
            Spacer().frame(height: 50)
            ProgressView()
            Spacer()
        }
        .editModeDisabling()
    }

    var detailsView: some View {
        Section {
            switch viewModel.status {
            case .blank:
                blankView
            case .loading:
                loadingView
            case .error:
                errorView
            case .ready:
                if let result = viewModel.resultWordDetails {
                    if let phonetic = result.phonetic {
                        HStack(spacing: 0) {
                            HStack {
                                Text("Phonetic: ").bold()
                                + Text(phonetic)
                            }.padding(.top)
                            Spacer()
                            Button {
                                viewModel.speakInputWord()
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title3)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal)
                                    .background(Color.accentColor.gradient)
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }

                    WordCard(wordMeanings: result.meanings) { descriptionStr, partOfSpeechStr in
                        viewModel.descriptionField = descriptionStr
                        viewModel.partOfSpeech = .init(rawValue: partOfSpeechStr) ?? .unknown
                        UIApplication.shared.endEditing()
                    }
                    .onAppear {
                        if let meaning = result.meanings.first,
                           let definition = meaning.definitions.first {
                            viewModel.descriptionField = definition.definition
                            viewModel.partOfSpeech = .init(rawValue: meaning.partOfSpeech) ?? .unknown
                        }
                    }
                }
            }
        }
        .cornerRadius(16)
    }

    var partOfSpeechMenu: some View {
        Menu {
            ForEach(PartOfSpeech.allCases, id: \.self) { partCase in
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
            Text(
                viewModel.partOfSpeech == .unknown
                ? "Part of speech"
                : viewModel.partOfSpeech.rawValue
            )
            .foregroundColor(
                viewModel.partOfSpeech == .unknown
                ? Color.accentColor
                : Color.primary
            )
        }
    }
}

import Swinject
import SwinjectAutoregistration

#Preview {
    DIContainer.shared.resolver.resolve(AddWordView.self, argument: "input")!
}
