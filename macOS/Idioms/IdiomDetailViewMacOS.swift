import SwiftUI

struct IdiomDetailViewMacOS: View {
    @ObservedObject private var viewModel: IdiomDetailsViewModel
    @State private var isEditing = false

    init(viewModel: IdiomDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            // MARK: Title and toolbar
            HStack {
                Text(viewModel.idiom.idiomItself ?? "").font(.title).bold()
                Spacer()
                Button {
                    viewModel.speak(viewModel.idiom.idiomItself)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
                Button(action: {
                    viewModel.toggleFavorite()
                }, label: {
                    Image(systemName: "\(viewModel.idiom.isFavorite ?? false ? "heart.fill" : "heart")")
                        .foregroundColor(.accentColor)
                })
                Button(action: {
                    if !isEditing {
                        isEditing = true
                    } else {
                        viewModel.save()
                        isEditing = false
                    }
                }, label: {
                    Text(isEditing ? "Save" : "Edit")
                })
            }
            // MARK: Primary Content

            ScrollView {
                HStack {
                    if isEditing {
                        Text("Definition: ").bold()
                        TextEditor(text: $viewModel.definitionTextFieldStr)
                            .padding(1)
                            .background(Color.secondary.opacity(0.4))
                    } else {
                        Text("Definition: ").bold()
                        + Text(viewModel.idiom.definition ?? "")
                    }
                    Spacer()
                    Button {
                        viewModel.speak(viewModel.idiom.definition)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }

                Divider()

                VStack(alignment: .leading) {
                    HStack {
                        Text("Examples:").bold()
                        Spacer()
                        if !viewModel.idiom.examplesDecoded.isEmpty {
                            Button {
                                withAnimation {
                                    viewModel.isShowAddExample = true
                                }
                            } label: {
                                Text("Add example")
                            }
                        }
                    }

                    if !viewModel.idiom.examplesDecoded.isEmpty {
                        ForEach(Array(viewModel.idiom.examplesDecoded.enumerated()), id: \.offset) { offset, element in
                            if !isEditing {
                                Text("\(offset + 1). \(viewModel.idiom.examplesDecoded[offset])")
                            } else {
                                HStack {
                                    Button {
                                        viewModel.removeExample(element)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    Text("\(offset + 1). \(viewModel.idiom.examplesDecoded[offset])")
                                }
                            }
                        }
                    } else {
                        HStack {
                            Text("No examples yet..")
                            Button {
                                withAnimation {
                                    viewModel.isShowAddExample = true
                                }
                            } label: {
                                Text("Add example")
                            }
                        }
                    }

                    if viewModel.isShowAddExample {
                        TextField("Type an example here", text: $viewModel.exampleTextFieldStr, onCommit: {
                            withAnimation(.easeInOut) {
                                viewModel.addExample()
                            }
                        })
                    }
                }
            }
        }
        .padding()
        .navigationTitle(viewModel.idiom.idiomItself ?? "")
    }
}
