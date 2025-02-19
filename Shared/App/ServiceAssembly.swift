//
//  ServiceAssembly.swift
//  MyDictionaryApp
//
//  Created by Aleksandr Riakhin on 2/19/25.
//

import Swinject
import SwinjectAutoregistration

final class ServiceAssembly: Assembly, Identifiable {

    var id: String = "ServiceAssembly"

    func assemble(container: Container) {
        container.register(DictionaryApiServiceInterface.self) { _ in
            DictionaryApiService()
        }
        .inObjectScope(.container)

        container.register(SpeechSynthesizerInterface.self) { _ in
            SpeechSynthesizer()
        }
        .inObjectScope(.container)

        container.register(CoreDataContainerInterface.self) { _ in
            CoreDataContainer()
        }
        .inObjectScope(.container)

        container.register(WordsProviderInterface.self) { resolver in
            WordsProvider(
                coreDataContainer: resolver ~> CoreDataContainerInterface.self
            )
        }
        .inObjectScope(.container)

        container.register(IdiomsProviderInterface.self) { resolver in
            IdiomsProvider(
                coreDataContainer: resolver ~> CoreDataContainerInterface.self
            )
        }
        .inObjectScope(.container)
    }
}
