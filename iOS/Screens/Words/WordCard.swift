//
//  WordCard.swift
//  My Dictionary
//
//  Created by Alexander Bonney on 9/28/21.
//

import SwiftUI

struct WordCard: View {
    @State private var wordClassSelection = 0
    @State private var partOfSpeech = ""
    var wordMeanings: [Meaning]
    var indices: Range<Array<Definition>.Index> {
        wordMeanings[wordClassSelection].definitions.indices
    }
    var definitions: [Definition] {
        wordMeanings[wordClassSelection].definitions
    }
    var tapGesture: (String, String) -> Void

    var body: some View {

        VStack(alignment: .leading) {
            Picker(selection: $wordClassSelection) {
                ForEach(wordMeanings.indices, id: \.self) { index in
                    Text("\(wordMeanings[index].partOfSpeech)")
                }
            } label: {
                Text("selection")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            TabView {
                ForEach(indices, id: \.self) { index in
                    ScrollView {
                        VStack(alignment: .leading) {
                            if !definitions[index].definition.isEmpty {
                                Divider()
                                HStack {
                                    Text("Definition \(index + 1): ").bold()
                                    + Text(definitions[index].definition)
                                }
                                .onTapGesture {
                                    partOfSpeech = wordMeanings[wordClassSelection].partOfSpeech
                                    tapGesture(definitions[index].definition, partOfSpeech)
                                }

                            }
                            if definitions[index].example != nil {
                                Divider()
                                Text("Example: ").bold()
                                + Text(definitions[index].example!)
                            }
                            if !definitions[index].synonyms.isEmpty {
                                Divider()
                                Text("Synonyms: ").bold()
                                + Text(definitions[index].synonyms.joined(separator: ", "))
                            }
                            if !definitions[index].antonyms.isEmpty {
                                Divider()
                                Text("Antonyms: ").bold()
                                + Text(definitions[index].antonyms.joined(separator: ", "))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .tabViewStyle(.page)
        }
    }
}
