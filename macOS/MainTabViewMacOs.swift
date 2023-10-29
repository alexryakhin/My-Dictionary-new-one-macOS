import SwiftUI

struct MainTabView: View {
    @StateObject private var wordsViewModel = WordsViewModel()
    @StateObject private var idiomsViewModel = IdiomsViewModel()
    @StateObject private var quizzesViewModel = QuizzesViewModel()

    @State var selectedSidebarItem: SidebarItem = .words

    var body: some View {
        let selectionBinding = Binding {
            selectedSidebarItem
        } set: { newValue in
            wordsViewModel.selectedWord = nil
            idiomsViewModel.selectedIdiom = nil
            quizzesViewModel.selectedQuiz = nil
            selectedSidebarItem = newValue
        }

        NavigationSplitView {
            List(selection: selectionBinding) {
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
            case .words: WordsListView(wordsViewModel: wordsViewModel)
            case .idioms: IdiomsListViewMacOS(idiomsViewModel: idiomsViewModel)
            case .quizzes: QuizzesView(quizzesViewModel: quizzesViewModel)
            }
        } detail: {
            Text("Select an item")
        }
        .fontDesign(.rounded)
    }
}
