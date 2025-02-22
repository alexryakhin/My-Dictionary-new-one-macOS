import SwiftUI
import Swinject
import SwinjectAutoregistration

struct MainTabView: View {
    private let resolver = DIContainer.shared.resolver
    @State var selectedSidebarItem: SidebarItem = .words

    var body: some View {
        let selectionBinding = Binding {
            selectedSidebarItem
        } set: { newValue in
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
            case .words: resolver ~> WordsListView.self
            case .idioms: resolver ~> IdiomsListView.self
            case .quizzes: resolver ~> QuizzesView.self
            }
        } detail: {
            Text("Select an item")
        }
        .fontDesign(.rounded)
    }
}
