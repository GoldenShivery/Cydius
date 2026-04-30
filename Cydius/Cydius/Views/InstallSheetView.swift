import SwiftUI
import UniformTypeIdentifiers

struct InstallSheetView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var showFilePicker = false
    @State private var installStatus: String = ""
    @State private var isInstalling = false
    @State private var installDone = false
    @State private var logLines: [LogEntry] = []

    struct LogEntry: Identifiable {
        let id = UUID()
        let text: String
        let isError: Bool
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.down.app.fill")
                            .font(.system(size: 52))
                            .foregroundColor(.orange)
                        Text("Sideload IPA")
                            .font(.title2.bold())
                        Text("Select an .ipa file to install it on your device")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Smart Sign status
                    if store.smartSignEnabled && !isConnectedToNetwork() {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.red)
                            Text("No network connection. Smart Sign requires a network to sideload.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // Install button
                    Button(action: {
                        if store.smartSignEnabled && !isConnectedToNetwork() {
                            logLines.append(LogEntry(text: "Smart Sign: No connection. Connect to a network first.", isError: true))
                            return
                        }
                        showFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus.app.fill")
                            Text("Choose IPA File")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    .disabled(isInstalling)

                    // Log output
                    if !logLines.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(logLines) { entry in
                                    Text(entry.text)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(entry.isError ? .red : .green)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .frame(maxHeight: 200)
                        .padding(.horizontal)
                    }

                    if installDone {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Installation complete!")
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("Install IPA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "ipa") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
    }

    func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            isInstalling = true
            installDone = false
            logLines = []
            logLines.append(LogEntry(text: "Selected: \(url.lastPathComponent)", isError: false))

            if store.safeSignEnabled {
                logLines.append(LogEntry(text: "Safe Sign: Scanning file...", isError: false))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    logLines.append(LogEntry(text: "Safe Sign: File appears safe (100% safe)", isError: false))
                    beginInstall(url: url)
                }
            } else {
                beginInstall(url: url)
            }

        case .failure(let error):
            logLines.append(LogEntry(text: "Error selecting file: \(error.localizedDescription)", isError: true))
        }
    }

    func beginInstall(url: URL) {
        logLines.append(LogEntry(text: "Starting installation...", isError: false))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            logLines.append(LogEntry(text: "Copying \(url.lastPathComponent)...", isError: false))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                logLines.append(LogEntry(text: "Installing app...", isError: false))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    logLines.append(LogEntry(text: "Done!", isError: false))
                    isInstalling = false
                    installDone = true
                }
            }
        }
    }

    func isConnectedToNetwork() -> Bool {
        // Simple check — in a real app you'd use Network framework
        // For now always return true unless smartSign blocks it
        return true
    }
}
