import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var searchText = ""
    @State private var showInstallSheet = false

    var filteredApps: [AppModel] {
        if searchText.isEmpty { return store.apps }
        return store.apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search", text: $searchText)
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                    // Sideload button
                    Button(action: { showInstallSheet = true }) {
                        HStack {
                            Image(systemName: "arrow.down.app.fill")
                            Text("Sideload IPA")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                    // App list
                    if filteredApps.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "tray")
                                .font(.system(size: 44))
                                .foregroundColor(.secondary)
                            Text("No apps yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Tap Sideload IPA to install your first app")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .padding()
                    } else {
                        List {
                            Section(header: Text("All Apps")) {
                                ForEach(filteredApps) { app in
                                    AppRowView(app: app)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Cydius")
            .sheet(isPresented: $showInstallSheet) {
                InstallSheetView()
                    .environmentObject(store)
            }
        }
    }
}

struct AppRowView: View {
    let app: AppModel
    @EnvironmentObject var store: AppStore

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "app.fill")
                        .foregroundColor(.orange)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.headline)
                Text(app.bundleID)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button("Open") {
                    // open app
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Reinstall") {
                    store.reinstallApp(app)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}
