//
//  AddIdiomViewMacOS.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Ryakhin on 1/22/22.
//

import SwiftUI

struct AddIdiomViewMacOS: View {
    @Binding var isShowingAddView: Bool
    @EnvironmentObject var idiomsViewModel: IdiomsViewModel
    @State private var showingAlert = false
    @State private var inputIdiom: String = ""
    @State private var inputDefinition: String = ""

    var body: some View {
        VStack {
            HStack {
                Text("Add new idiom").font(.title2).bold()
                Spacer()
                Button {
                    isShowingAddView = false
                } label: {
                    Text("Close")
                }
            }
            HStack {
                Text("IDIOM").font(.system(.caption, design: .rounded)).foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top)
            TextField("Idiom", text: $inputIdiom)
            HStack {
                Text("DEFINITION").font(.system(.caption, design: .rounded)).foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top)
            TextEditor(text: $inputDefinition)
                .padding(1)
                .background(Color.secondary.opacity(0.4))
            Button {
                saveNewIdiom()
            } label: {
                Text("Save").bold()
            }
        }
        .frame(width: 500, height: 300)
        .padding()
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("Ooops..."), message: Text("You should enter an idiom and its definition before saving it"), dismissButton: .default(Text("Got it")))
        })
        .onAppear {
            if !idiomsViewModel.searchText.isEmpty {
                inputIdiom = idiomsViewModel.searchText
            }
        }
    }
    
    private func saveNewIdiom() {
        if !inputIdiom.isEmpty, !inputDefinition.isEmpty {
            idiomsViewModel.addNewIdiom(idiom: inputIdiom, definition: inputDefinition)
            idiomsViewModel.searchText = ""
            isShowingAddView = false
        } else {
            showingAlert = true
        }
    }
}
