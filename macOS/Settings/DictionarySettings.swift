//
//  DictionarySettings.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Ryakhin on 9/19/22.
//

import SwiftUI

struct DictionarySettings: View {
    var body: some View {
        Form {
            Text("There will be settings in the future :)")
        }
        .frame(width: 300)
        .navigationTitle("Landmark Settings")
        .padding(80)
    }
}

struct DictionarySettings_Previews: PreviewProvider {
    static var previews: some View {
        DictionarySettings()
    }
}
