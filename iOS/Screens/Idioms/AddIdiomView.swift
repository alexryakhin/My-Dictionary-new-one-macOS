import SwiftUI
import Swinject
import SwinjectAutoregistration

final class AddIdiomViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var inputDefinition: String = ""
    @Published var isShowingAlert = false

    private let idiomsProvider: IdiomsProviderInterface

    init(
        inputText: String,
        idiomsProvider: IdiomsProviderInterface
    ) {
        self.inputText = inputText
        self.idiomsProvider = idiomsProvider
    }

    func addIdiom() {
        if !inputText.isEmpty, !inputDefinition.isEmpty {
            idiomsProvider.addNewIdiom(inputText, definition: inputDefinition)
        } else {
            isShowingAlert = true
        }
    }
}

struct AddIdiomView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: AddIdiomViewModel

    init(viewModel: AddIdiomViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Idiom", text: $viewModel.inputText)
                } header: {
                    Text("Idiom")
                }
                Section {
                    TextEditor(text: $viewModel.inputDefinition)
                        .frame(height: UIScreen.main.bounds.height / 3)
                } header: {
                    Text("Definition")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitle("Add new idiom")
            .navigationBarItems(trailing: Button(action: {
                viewModel.addIdiom()
                dismiss()
            }, label: {
                Text("Save")
                    .font(.system(.headline, design: .rounded))
            }))
            .alert(isPresented: $viewModel.isShowingAlert) {
                Alert(
                    title: Text("Ooops..."),
                    message: Text("You should enter an idiom and its definition before saving it"),
                    dismissButton: .default(Text("Got it"))
                )
            }
        }
    }
}

#Preview {
    DIContainer.shared.resolver.resolve(AddIdiomView.self, argument: "Input idiom")!
}
