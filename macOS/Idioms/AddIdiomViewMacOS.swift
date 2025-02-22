import SwiftUI

struct AddIdiomView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: AddIdiomViewModel

    init(viewModel: AddIdiomViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            HStack {
                Text("Add new idiom").font(.title2).bold()
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                }
            }
            HStack {
                Text("IDIOM")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top)
            TextField("Idiom", text: $viewModel.inputText)
                .textFieldStyle(.roundedBorder)
            HStack {
                Text("DEFINITION")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top)
            TextEditor(text: $viewModel.inputDefinition)
                .padding(1)
                .background(Color.secondary.opacity(0.4))
            Button {
                viewModel.addIdiom()
                dismiss()
            } label: {
                Text("Save")
                    .bold()
            }
        }
        .frame(width: 500, height: 300)
        .padding()
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(
                title: Text("Ooops..."),
                message: Text("You should enter an idiom and its definition before saving it"),
                dismissButton: .default(Text("Got it"))
            )
        }
    }
}
