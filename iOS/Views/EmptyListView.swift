import SwiftUI

struct EmptyListView<Actions: View>: View {
    private let label: String
    private let description: String
    private let actions: () -> Actions

    init(
        label: String,
        description: String,
        @ViewBuilder actions: @escaping () -> Actions = { EmptyView() }
    ) {
        self.label = label
        self.description = description
        self.actions = actions
    }

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            if #available(iOS 17.0, *) {
                ContentUnavailableView(
                    label: {
                        Text(label)
                    },
                    description: {
                        Text(description)
                    },
                    actions: actions
                )
            } else {
                Text(description)
                    .padding(20)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    EmptyListView(
        label: "No idioms yet",
        description: "Begin to add idioms to your list by tapping on plus icon in upper left corner"
    )
}
