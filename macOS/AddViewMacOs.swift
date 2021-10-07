//
//  AddViewMacOs.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI

struct AddView: View {
    @Binding var isShowingAddView: Bool
    
    var body: some View {
        VStack {
            Text("Hello, World!")

            Button {
                isShowingAddView = false
            } label: {
                Text("Hide")
            }

        }.padding()
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(isShowingAddView: .constant(true))
    }
}
