//
//  WordsDetailViewMacOS.swift
//  My Dictionary (macOS)
//
//  Created by Alexander Bonney on 10/7/21.
//

import SwiftUI
import AVKit

struct WordDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var word: Word
    
    @State private var isEditing = false
    @State private var isShowAddExample = false
    @State private var exampleTextFieldStr = ""
    @State private var partOfSpeech: PartOfSpeech = .noun

    
    private var examples: [String] {
        guard let data = word.examples else {return []}
        guard let examples = try? JSONDecoder().decode([String].self, from: data) else {return []}
        return examples
    }
    
    var utterance: AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: word.wordItself ?? "")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        return utterance
    }
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            // MARK: Title and toolbar
            HStack {
                Text(word.wordItself ?? "").font(.title).bold()
                Spacer()
                Button(action: {
                    //favorites
                    word.isFavorite.toggle()
                    save()
                }, label: {
                    Image(systemName: "\(word.isFavorite ? "heart.fill" : "heart")")
                        .foregroundColor(.accentColor)
                })
                Button(action: {
                    if !isEditing {
                        isEditing = true
                    } else {
                        word.partOfSpeech = partOfSpeech.rawValue
                        save()
                        isEditing = false
                    }
                }, label: {
                    Text(isEditing ? "Save" : "Edit")
                })
            }
            // MARK: Primary Content
            
            let bindingWordDefinition = Binding (
                get: { word.definition ?? "" },
                set: {
                    word.definition = $0
                }
            )
            
            ScrollView {
                
                HStack {
                    Text("Phonetics: ").bold()
                    + Text("[\(word.phonetic ?? "No transcription")]")
                    Spacer()
                    Button {
                        //play audio of word
                        synthesizer.speak(utterance)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
                
                Divider()
                
                HStack {
                    if !isEditing {
                        Text("Part Of Speech: ").bold()
                        + Text(word.partOfSpeech ?? "")
                    } else {
                        Picker(selection: $partOfSpeech, label: Text("Part of Speech").bold()) {
                            ForEach(PartOfSpeech.allCases, id: \.self) { c in
                                Text(c.rawValue)
                            }
                        }
                    }
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    if isEditing {
                        Text("Definition: ").bold()
                        TextField("Definition", text: bindingWordDefinition)
                    } else {
                        Text("Definition: ").bold()
                        + Text(word.definition ?? "")
                    }
                    Spacer()
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Examples:").bold()
                        Spacer()
                        if !examples.isEmpty {
                            Button {
                                withAnimation {
                                    isShowAddExample = true
                                }
                            } label: {
                                Text("Add example")
                            }
                        }
                    }
                    
                    if !examples.isEmpty {
                        ForEach(examples.indices, id: \.self) { index in
                            if !isEditing {
                                Text("\(index + 1). \(examples[index])")
                            } else {
                                HStack {
                                    Button {
                                        removeExample(of: index)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    Text("\(index + 1). \(examples[index])")
                                }
                            }
                        }
                    } else {
                        HStack {
                            Text("No examples yet..")
                            Button {
                                withAnimation {
                                    isShowAddExample = true
                                }
                            } label: {
                                Text("Add example")
                            }
                        }
                    }
                    
                    
                    if isShowAddExample {
                        TextField("Type an example here", text: $exampleTextFieldStr, onCommit: {
                            withAnimation(.easeInOut) {
                                //save
                                isShowAddExample = false
                                if exampleTextFieldStr != "" {
                                    let newExamples = examples + [exampleTextFieldStr]
                                    let newExamplesData = try? JSONEncoder().encode(newExamples)
                                    word.examples = newExamplesData
                                    save()
                                }
                                exampleTextFieldStr = ""
                            }
                        })
                    }
                }
            }
            
        }
        .padding()
        .navigationTitle(word.wordItself ?? "")
        .onAppear {
            switch word.partOfSpeech {
            case "noun":
                partOfSpeech = .noun
            case "verb":
                partOfSpeech = .verb
            case "adjective":
                partOfSpeech = .adjective
            case "adverb":
                partOfSpeech = .adverb
            case "exclamation":
                partOfSpeech = .exclamation
            case "conjunction":
                partOfSpeech = .conjunction
            case "pronoun":
                partOfSpeech = .pronoun
            case "number":
                partOfSpeech = .number
            default:
                partOfSpeech = .unknown
            }
        }
    }
    
    // MARK: Private methods
    private func save() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func removeExample(of index: Int) {
        var examples = self.examples
        examples.remove(at: index)
        
        let newExamplesData = try? JSONEncoder().encode(examples)
        word.examples = newExamplesData
        save()
    }
}

struct WordsDetailViewMacOS_Previews: PreviewProvider {
    static let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        
        let word = Word(context: viewContext)
        word.id = UUID()
        word.wordItself = "Fascinating"
        word.definition = "Extremely interesting"
        word.partOfSpeech = "noun"
        word.phonetic = "fascinating"
        word.timestamp = Date()
        word.isFavorite = true
        
        return NavigationView {
            WordDetailView(word: word)
        }
        
    }
}
