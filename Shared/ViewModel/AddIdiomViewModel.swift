//
//  AddIdiomViewModel.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 2/20/25.
//

import Combine
import SwiftUI

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
            idiomsProvider.saveContext()
        } else {
            isShowingAlert = true
        }
    }
}
