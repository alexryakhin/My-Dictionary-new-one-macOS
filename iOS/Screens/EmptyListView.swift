import SwiftUI

struct EmptyListView: View {
    var text: String

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack {
                Spacer()
                Text(text)
                    .padding(20)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
        }
    }
}

#Preview {
    EmptyListView(text: "Begin to add idioms to your list\nby tapping on plus icon in upper left corner")
}
