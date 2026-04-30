import SwiftUI
import Combine

class AppStore: ObservableObject {
    @Published var featuredApps: [AppItem] = []
    @Published var installedApps: [AppItem] = []
    @Published var activeInstall: AppItem? = nil
    @Published var installStages: [InstallStage] = []
    @Published var installProgress: Double = 0
    @Published var currentStageIndex: Int = -1
    @Published var installLog: [LogLine] = []
    @Published var showInstallSheet: Bool = false
    @Published var installComplete: Bool = false

    struct LogLine: Identifiable {
        let id = UUID()
        let text: String
        let type: LineType
        enum LineType { case info, success, warning, error, system }
    }

    init() { loadSampleApps() }

    func loadSampleApps() {
        featuredApps = [
            AppItem(name: "Filza File Manager", bundleID: "com.tigisoftware.Filza", version: "4.0.1", developer: "Tigisoftware", description: "Full-featured file manager for iOS with root access support.", downloadURL: "https://example.com/filza.ipa", size: "12.4 MB", category: .tools),
            AppItem(name: "AppStore++", bundleID: "com.appstoreplus", version: "2.1", developer: "Majd", description: "Download older versions of any App Store app.", downloadURL: "https://example.com/appstoreplus.ipa", size: "3.2 MB", category: .tweaks),
            AppItem(name: "Dopamine", bundleID: "com.opa334.dopamine", version: "2.2.5", developer: "opa334", description: "Rootless jailbreak for iOS 15-16.", downloadURL: "https://example.com/dopamine.ipa", size: "28.7 MB", category: .tools),
            AppItem(name: "Trollstore", bundleID: "com.opa334.trollstore", version: "2.0.1", developer: "opa334", description: "Permanent IPA installer using CoreTrust bug.", downloadURL: "https://example.com/trollstore.ipa", size: "5.1 MB", category: .tools),
            AppItem(name: "uYouPlus", bundleID: "com.google.ios.youtube", version: "19.12.1", developer: "Community", description: "YouTube with no ads, background play, and downloads.", downloadURL: "https://example.com/uyouplus.ipa", size: "67.3 MB", category: .apps),
            AppItem(name: "Spotify++", bundleID: "com.spotify.client", version: "9.0.2", developer: "Community", description: "Spotify with Premium features unlocked for free.", downloadURL: "https://example.com/spotifypp.ipa", size: "44.8 MB", category: .apps),
        ]
    }

    func beginInstall(app: AppItem) {
        activeInstall = app
        installProgress = 0
        installComplete = false
        installLog = []
        currentStageIndex = -1
        installStages = [
            InstallStage(name: "Downloading", icon: "arrow.down.circle"),
            InstallStage(name: "Unpacking", icon: "archivebox"),
            InstallStage(name: "Verifying", icon: "checkmark.shield"),
            InstallStage(name: "Signing", icon: "signature"),
            InstallStage(name: "Installing", icon: "square.and.arrow.down"),
        ]
        showInstallSheet = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.runInstallPipeline()
        }
    }

    private func runInstallPipeline() {
        let appName = activeInstall?.name ?? "app"
        let bundleID = activeInstall?.bundleID ?? "com.app"
        let stageLogs: [[LogLine]] = [
            [
                LogLine(text: "→ connecting to source...", type: .info),
                LogLine(text: "→ resolved CDN endpoint", type: .info),
                LogLine(text: "→ downloading \(appName).ipa", type: .system),
                LogLine(text: "✓ download complete", type: .success),
            ],
            [
                LogLine(text: "→ opening zip container", type: .info),
                LogLine(text: "→ extracting Payload/", type: .info),
                LogLine(text: "→ found 247 bundle files", type: .system),
                LogLine(text: "✓ archive unpacked", type: .success),
            ],
            [
                LogLine(text: "→ reading Info.plist", type: .info),
                LogLine(text: "→ bundle ID: \(bundleID)", type: .system),
                LogLine(text: "⚠ original signature stripped", type: .warning),
                LogLine(text: "✓ bundle structure valid", type: .success),
            ],
            [
                LogLine(text: "→ loading provisioning profile", type: .info),
                LogLine(text: "→ signing binary + frameworks", type: .info),
                LogLine(text: "→ injecting entitlements", type: .system),
                LogLine(text: "✓ codesign verified SHA-256", type: .success),
            ],
            [
                LogLine(text: "→ device handshake OK", type: .info),
                LogLine(text: "→ pushing to /var/tmp/", type: .info),
                LogLine(text: "→ installd pipeline running", type: .system),
                LogLine(text: "✓ installation complete!", type: .success),
            ],
        ]
        let stageDurations: [Double] = [1.8, 1.2, 1.4, 1.6, 2.0]
        let stageProgressRanges: [(Double, Double)] = [(0,18),(18,38),(38,58),(58,80),(80,100)]

        func runStage(_ index: Int) {
            guard index < installStages.count else {
                DispatchQueue.main.async {
                    self.installProgress = 100
                    self.installComplete = true
                    if var installed = self.activeInstall {
                        installed.isInstalled = true
                        self.installedApps.append(installed)
                    }
                }
                return
            }
            DispatchQueue.main.async {
                self.currentStageIndex = index
                for i in 0..<self.installStages.count {
                    if i < index { self.installStages[i].status = .done }
                    else if i == index { self.installStages[i].status = .active }
                    else { self.installStages[i].status = .waiting }
                }
            }
            let logs = stageLogs[index]
            let range = stageProgressRanges[index]
            let duration = stageDurations[index]
            let logInterval = duration / Double(logs.count)
            for (i, log) in logs.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + logInterval * Double(i)) {
                    self.installLog.append(log)
                    let fraction = Double(i + 1) / Double(logs.count)
                    self.installProgress = range.0 + fraction * (range.1 - range.0)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.3) {
                runStage(index + 1)
            }
        }
        runStage(0)
    }

    func cancelInstall() {
        showInstallSheet = false
        activeInstall = nil
    }
}
