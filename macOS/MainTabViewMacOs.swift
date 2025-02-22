import SwiftUI
import Swinject
import SwinjectAutoregistration

struct MainTabView: View {
    private let resolver = DIContainer.shared.resolver
    @State private var selectedSidebarItem: SidebarItem = .words

    @State private var selectedWord: Word?
    @State private var selectedIdiom: Idiom?
    @State private var selectedQuiz: Quiz?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSidebarItem) {
                Section {
                    ForEach(SidebarItem.allCases, id: \.self) { item in
                        NavigationLink(value: item) {
                            Label {
                                Text(item.title)
                            } icon: {
                                item.image
                            }
                            .padding(.vertical, 8)
                            .font(.title3)
                        }
                    }
                } header: {
                    Text("My Dictionary").font(.title2).bold().padding(.vertical, 16)
                }
            }
        } content: {
            switch selectedSidebarItem {
            case .words:
                resolver.resolve(WordsListView.self, argument: $selectedWord)!
            case .idioms:
                resolver.resolve(IdiomsListView.self, argument: $selectedIdiom)!
            case .quizzes:
                resolver.resolve(QuizzesView.self, argument: $selectedQuiz)!
            }
        } detail: {
            if let selectedWord {
                resolver.resolve(WordDetailsView.self, argument: selectedWord)!
            } else if let selectedIdiom {
                resolver.resolve(IdiomDetailsView.self, argument: selectedIdiom)!
            } else if let selectedQuiz {
                quizView(for: selectedQuiz)
            } else {
                Text("Select an item")
            }
        }
        .fontDesign(.rounded)
    }

    @ViewBuilder
    func quizView(for quiz: Quiz) -> some View {
        switch quiz {
        case .spelling:
            resolver ~> SpellingQuizView.self
        case .chooseDefinitions:
            resolver ~> ChooseDefinitionView.self
        }
    }
}
