//
//  DIContainer.swift
//  MyDictionaryApp
//
//  Created by Aleksandr Riakhin on 2/19/25.
//

import Swinject

final class DIContainer {

    nonisolated(unsafe) static let shared = DIContainer()

    private let assembler: Assembler

    var resolver: Resolver { assembler.resolver }

    private var assembled: Set<String> = .init()

    private init() {
        self.assembler = Assembler([])
    }

    func assemble<T>(assembly: T) where T: Assembly, T: Identifiable {
        guard let id = assembly.id as? String else {
            return
        }
        guard !assembled.contains(id) else {
            return
        }
        assembler.apply(assembly: assembly)
    }
}
