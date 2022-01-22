//
//  AddIdiomView.swift
//  My Dictionary (iOS)
//
//  Created by Alexander Ryakhin on 1/22/22.
//

import SwiftUI

struct AddIdiomView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var idiomsViewModel: IdiomsViewModel
    @State private var inputDefinition: String = ""
    @State private var isShowingAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Idiom", text: $idiomsViewModel.searchText)
                } header: {
                    Text("Idiom")
                }
                Section {
                    TextEditor(text: $inputDefinition)
                        .frame(height: UIScreen.main.bounds.height / 3)
                } header: {
                    Text("Definition")
                }
            }
            .navigationBarTitle("Add new idiom")
            .navigationBarItems(trailing: Button(action: {
                if !idiomsViewModel.searchText.isEmpty, !inputDefinition.isEmpty {
                    idiomsViewModel.addNewIdiom(idiom: idiomsViewModel.searchText, definition: inputDefinition)
                    idiomsViewModel.searchText = ""
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    isShowingAlert = true
                }
            }, label: {
                Text("Save")
                    .font(.system(.headline, design: .rounded))
            }))
            .alert(isPresented: $isShowingAlert, content: {
                Alert(title: Text("Ooops..."), message: Text("You should enter an idiom and its definition before saving it"), dismissButton: .default(Text("Got it")))
            })
        }
    }
}

struct AddIdiomView_Previews: PreviewProvider {
    static var previews: some View {
        AddIdiomView()
    }
}
