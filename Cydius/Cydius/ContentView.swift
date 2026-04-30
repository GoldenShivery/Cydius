import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                        .environmentObject(store)
                case 1:
                    InstalledView()
                        .environmentObject(store)
                case 2:
                    SettingsView()
                        .environmentObject(store)
                default:
                    HomeView()
                        .environmentObject(store)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar — always visible, never disappears
            HStack(spacing: 0) {
                TabBarButton(icon: "square.grid.2x2.fill", label: "Apps", tag: 0, selected: $selectedTab)
                TabBarButton(icon: "checkmark.seal.fill", label: "Installed", tag: 1, selected: $selectedTab)
                TabBarButton(icon: "gearshape.fill", label: "Settings", tag: 2, selected: $selectedTab)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(white: 0.15), lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.keyboard)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selected: Int

    var isSelected: Bool { selected == tag }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selected = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .orange : Color(white: 0.4))
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .orange : Color(white: 0.4))
            }
            .frame(maxWidth: .infinity)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
