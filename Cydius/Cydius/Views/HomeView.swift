import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var searchText = ""
    @State private var selectedCategory: AppItem.AppCategory? = nil

    var filtered: [AppItem] {
        store.featuredApps.filter {
            (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == nil || $0.category == selectedCategory)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cydius")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("community app store")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.orange)
                                    .frame(width: 44, height: 44)
                                Text("⬇️")
                                    .font(.system(size: 22))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                        // Search
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            TextField("search apps, tweaks, tools...", text: $searchText)
                                .foregroundColor(.white)
                                .font(.system(size: 15))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(white: 0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                        // Category pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                CategoryPill(title: "All", isSelected: selectedCategory == nil) {
                                    selectedCategory = nil
                                }
                                ForEach(AppItem.AppCategory.allCases, id: \.self) { cat in
                                    CategoryPill(title: cat.rawValue, isSelected: selectedCategory == cat) {
                                        selectedCategory = selectedCategory == cat ? nil : cat
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)

                        // Featured banner
                        if searchText.isEmpty && selectedCategory == nil {
                            FeaturedBanner(app: store.featuredApps.first!) {
                                store.beginInstall(app: store.featuredApps.first!)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                            SectionHeader(title: "all apps")
                        }

                        // App list
                        LazyVStack(spacing: 0) {
                            ForEach(filtered) { app in
                                AppRow(app: app) {
                                    store.beginInstall(app: app)
                                }
                                Divider()
                                    .background(Color(white: 0.12))
                                    .padding(.leading, 76)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $store.showInstallSheet) {
                InstallSheetView()
                    .environmentObject(store)
            }
        }
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .black : .gray)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.orange : Color(white: 0.12))
                .cornerRadius(20)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct FeaturedBanner: View {
    let app: AppItem
    let onInstall: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.85), Color.orange.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)

            VStack(alignment: .leading, spacing: 6) {
                Text("featured")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1.5)
                Text(app.name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(app.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)

                Button(action: onInstall) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("install")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                }
                .padding(.top, 4)
            }
            .padding(18)
        }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .tracking(1.2)
                .padding(.horizontal, 20)
            Spacer()
        }
        .padding(.bottom, 10)
    }
}

struct AppRow: View {
    let app: AppItem
    let onInstall: () -> Void
    @State private var pressed = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 54, height: 54)
                Text("⬇️")
                    .font(.system(size: 26))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(app.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(app.developer)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                HStack(spacing: 8) {
                    Text(app.version)
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                    Text("·")
                        .foregroundColor(.gray)
                        .font(.system(size: 11))
                    Text(app.size)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text("·")
                        .foregroundColor(.gray)
                        .font(.system(size: 11))
                    Text(app.category.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: onInstall) {
                HStack(spacing: 4) {
                    Image(systemName: app.isInstalled ? "checkmark" : "arrow.down")
                        .font(.system(size: 11, weight: .bold))
                    Text(app.isInstalled ? "open" : "get")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(app.isInstalled ? .gray : .orange)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    app.isInstalled
                        ? Color(white: 0.12)
                        : Color.orange.opacity(0.15)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(app.isInstalled ? Color(white: 0.2) : Color.orange.opacity(0.4), lineWidth: 0.5)
                )
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black)
        .contentShape(Rectangle())
    }
}
