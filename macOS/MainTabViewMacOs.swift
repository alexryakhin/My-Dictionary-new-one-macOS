import SwiftUI

struct MainTabView: View {
    @StateObject var wordsViewModel = WordsViewModel()
    @StateObject var quizzesViewModel = QuizzesViewModel()
    @StateObject var idiomsViewModel = IdiomsViewModel()
    
    @State var selectedSidebarItem: SidebarItem = .words

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
                        }
                    }
                } header: {
                    Text("My Dictionary").font(.title2).bold().padding(.vertical, 16)
                }
            }
        } content: {
            switch selectedSidebarItem {
            case .words: WordsListView().environmentObject(wordsViewModel)
            case .idioms: IdiomsListViewMacOS().environmentObject(idiomsViewModel)
            case .quizzes: QuizzesView().environmentObject(quizzesViewModel)
            }
        } detail: {
            Text("Select an item")
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
