import SwiftUI
import CoreData

struct IdiomDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: IdiomDetailsViewModel

    init(viewModel: IdiomDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                Text(viewModel.idiom.idiomItself ?? "")
                    .font(.system(.headline, design: .rounded))
            } header: {
                Text("Idiom")
            } footer: {
                Button {
                    viewModel.speak(viewModel.idiom.idiomItself)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Listen")
                }
                .foregroundColor(.accentColor)
            }

            Section {
                TextEditor(text: $viewModel.definitionTextFieldStr)
                    .frame(height: 200)
            } header: {
                Text("Definition")
            } footer: {
                Button {
                    viewModel.speak(viewModel.idiom.definition)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Listen")
                }
                .foregroundColor(.accentColor)
            }
            Section {
                Button {
                    if !viewModel.isShowAddExample {
                        withAnimation {
                            viewModel.isShowAddExample = true
                        }
                    } else {
                        withAnimation(.easeInOut) {
                            viewModel.addExample()
                        }
                    }
                } label: {
                    Text("Add example")
                }

                ForEach(viewModel.idiom.examplesDecoded, id: \.self) { example in
                    Text(example)
                }
                .onDelete(perform: viewModel.removeExample)

                if viewModel.isShowAddExample {
                    TextField("Type an example here", text: $viewModel.exampleTextFieldStr, onCommit: {
                        withAnimation(.easeInOut) {
                            viewModel.addExample()
                        }
                    })
                }
            } header: {
                Text("Examples")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.deleteCurrentIdiom()
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.idiom.isFavorite
                          ? "heart.fill"
                          : "heart"
                    )
                }
            }
        }
    }
}
