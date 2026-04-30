import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var searchText = ""
    @State private var selectedCategory: AppItem.AppCategory? = nil
    @State private var showInstall = false
    @State private var selectedApp: AppItem? = nil
    @State private var showIPAPicker = false
    @State private var showScanAlert = false
    @State private var scanResult: ScanResult? = nil
    @State private var isScanning = false
    @State private var pendingIPAUrl: URL? = nil

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

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Upload IPA button
                        Button(action: { showIPAPicker = true }) {
                            HStack {
                                Image(systemName: "arrow.up.doc.fill")
                                    .foregroundColor(.black)
                                Text("Sideload IPA")
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color.orange)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)

                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search", text: $searchText)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // Category filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                CategoryChip(title: "All", selected: selectedCategory == nil) {
                                    selectedCategory = nil
                                }
                                ForEach(AppItem.AppCategory.allCases, id: \.self) { cat in
                                    CategoryChip(title: cat.rawValue, selected: selectedCategory == cat) {
                                        selectedCategory = (selectedCategory == cat) ? nil : cat
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // App list
                        if filtered.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.4))
                                Text("No apps here")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(filtered) { app in
                                    AppRow(app: app, onInstall: {
                                        selectedApp = app
                                        showInstall = true
                                    }, onOpen: {
                                        openApp(bundleID: app.bundleID)
                                    }, onReinstall: {
                                        selectedApp = app
                                        showInstall = true
                                    })
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("CydiusLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
            }
        }
        .sheet(isPresented: $showInstall) {
            if let app = selectedApp {
                InstallSheetView(app: app)
                    .environmentObject(store)
            }
        }
        .fileImporter(
            isPresented: $showIPAPicker,
            allowedContentTypes: [UTType(filenameExtension: "ipa") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    handleIPASelected(url: url)
                }
            case .failure:
                break
            }
        }
        .alert("Scan Complete", isPresented: $showScanAlert) {
            if scanResult?.blocked == false {
                Button("Install Anyway") {
                    if let url = pendingIPAUrl {
                        store.installIPA(url: url)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let r = scanResult {
                Text(scanResultMessage(r))
            }
        }
    }

    func handleIPASelected(url: URL) {
        if store.safeSignEnabled {
            isScanning = true
            store.scanURL(url.absoluteString) { result in
                self.scanResult = result
                self.pendingIPAUrl = url
                self.isScanning = false
                self.showScanAlert = true
            }
        } else {
            store.installIPA(url: url)
        }
    }

    func scanResultMessage(_ r: ScanResult) -> String {
        var msg = "Safety Score: \(r.safetyScore)%\n"
        if r.threats.isEmpty {
            msg += "No threats detected. Safe to install."
        } else {
            msg += "Threats found:\n" + r.threats.joined(separator: "\n")
            if r.blocked { msg += "\n\n⛔ Download blocked." }
        }
        return msg
    }

    func openApp(bundleID: String) {
        if let url = URL(string: "\(bundleID)://") {
            UIApplication.shared.open(url)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Color.orange : Color.white.opacity(0.1))
                .foregroundColor(selected ? .black : .white)
                .cornerRadius(20)
        }
    }
}

struct AppRow: View {
    let app: AppItem
    let onInstall: () -> Void
    let onOpen: () -> Void
    let onReinstall: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 54, height: 54)
                Text(String(app.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(app.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(app.developer)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(app.version + " • " + app.size)
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }

            Spacer()

            VStack(spacing: 6) {
                if app.isInstalled {
                    Button(action: onOpen) {
                        Text("Open")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    Button(action: onReinstall) {
                        Text("Reinstall")
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.gray)
                            .cornerRadius(20)
                    }
                } else {
                    Button(action: onInstall) {
                        Text("GET")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.orange)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}
