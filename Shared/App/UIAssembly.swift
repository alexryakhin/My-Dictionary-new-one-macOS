//
//  UIAssembly.swift
//  MyDictionaryApp
//
//  Created by Aleksandr Riakhin on 2/19/25.
//

import Swinject
import SwinjectAutoregistration
import SwiftUI

final class UIAssembly: Assembly, Identifiable {

    var id: String = "UIAssembly"

    func assemble(container: Container) {
        container.register(MainTabView.self) { _ in
            MainTabView()
        }

#if os(iOS)
        container.register(OnboardingView.self) { _ in
            OnboardingView()
        }

        container.register(WordsListView.self) { resolver in
            let viewModel = WordsViewModel(
                wordsProvider: resolver ~> WordsProviderInterface.self
            )
            return WordsListView(viewModel: viewModel)
        }

        container.register(AddWordView.self) { resolver, inputWord in
            let viewModel = AddWordViewModel(
                inputWord: inputWord,
                dictionaryApiService: resolver ~> DictionaryApiServiceInterface.self,
                wordsProvider: resolver ~> WordsProviderInterface.self,
                speechSynthesizer: resolver ~> SpeechSynthesizerInterface.self
            )
            return AddWordView(viewModel: viewModel)
        }

        container.register(WordDetailsView.self) { resolver, word in
            let viewModel = WordDetailsViewModel(
                word: word,
                wordsProvider: resolver ~> WordsProviderInterface.self,
                speechSynthesizer: resolver ~> SpeechSynthesizerInterface.self
            )
            return WordDetailsView(viewModel: viewModel)
        }

        container.register(IdiomsListView.self) { resolver in
            let viewModel = IdiomsViewModel(
                idiomsProvider: resolver ~> IdiomsProviderInterface.self
            )
            return IdiomsListView(viewModel: viewModel)
        }

        container.register(AddIdiomView.self) { resolver, inputText in
            let viewModel = AddIdiomViewModel(
                inputText: inputText,
                idiomsProvider: resolver ~> IdiomsProviderInterface.self
            )
            return AddIdiomView(viewModel: viewModel)
        }

        container.register(IdiomDetailsView.self) { resolver, idiom in
            let viewModel = IdiomDetailsViewModel(
                idiom: idiom,
                idiomsProvider: resolver ~> IdiomsProviderInterface.self,
                speechSynthesizer: resolver ~> SpeechSynthesizerInterface.self
            )
            return IdiomDetailsView(viewModel: viewModel)
        }

        container.register(QuizzesView.self) { resolver in
            let viewModel = QuizzesViewModel(
                wordsProvider: resolver ~> WordsProviderInterface.self
            )
            return QuizzesView(viewModel: viewModel)
        }

        container.register(SpellingQuizView.self) { resolver in
            let viewModel = SpellingQuizViewModel(
                wordsProvider: resolver ~> WordsProviderInterface.self
            )
            return SpellingQuizView(viewModel: viewModel)
        }

        container.register(ChooseDefinitionView.self) { resolver in
            let viewModel = ChooseDefinitionViewModel(
                wordsProvider: resolver ~> WordsProviderInterface.self
            )
            return ChooseDefinitionView(viewModel: viewModel)
        }

        container.register(SettingsView.self) { _ in
            let viewModel = SettingsViewModel()
            return SettingsView(viewModel: viewModel)
        }
#elseif os(macOS)

        container.register(WordsListView.self) { resolver in
            let viewModel = WordsViewModel(
                wordsProvider: resolver ~> WordsProviderInterface.self
            )
            return WordsListView(viewModel: viewModel)
        }

        container.register(IdiomsListView.self) { resolver in
            let viewModel = IdiomsViewModel(
                idiomsProvider: resolver ~> IdiomsProviderInterface.self
            )
            return IdiomsListView(viewModel: viewModel)
        }

        container.register(QuizzesView.self) { resolver in
            let viewModel = QuizzesViewModel(
                wordsProvider: resolver ~> WordsProviderInterface.self
            )
            return QuizzesView(viewModel: viewModel)
        }

        container.register(SpellingQuizView.self) { resolver in
            let viewModel = SpellingQuizViewModel(
                wordsProvider: resolver ~> WordsProviderInterface.self
            )
            return SpellingQuizView(viewModel: viewModel)
        }

        container.register(ChooseDefinitionView.self) { resolver in
            let viewModel = ChooseDefinitionViewModel(
                wordsProvider: resolver ~> WordsProviderInterface.self
            )
            return ChooseDefinitionView(viewModel: viewModel)
        }

        container.register(DictionarySettings.self) { _ in
            let viewModel = SettingsViewModel()
            return DictionarySettings(viewModel: viewModel)
        }

#endif
    }
}
