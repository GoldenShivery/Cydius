import Foundation
import SwiftUI

class AppStore: ObservableObject {
    @Published var featuredApps: [AppItem] = []
    @Published var installedApps: [AppItem] = []
    @Published var activeInstall: AppItem? = nil
    @Published var installLogs: [String] = []
    @Published var installProgress: Double = 0
    @Published var isInstalling: Bool = false
    @Published var certificates: [CydCertificate] = []
    @Published var safeSignEnabled: Bool = true
    @Published var smartSignEnabled: Bool = true
    @Published var selectedCertificate: CydCertificate? = nil

    init() {
        loadBuiltInApps()
        loadSampleCertificates()
    }

    func loadBuiltInApps() {
        featuredApps = [
            AppItem(
                name: "Cydius",
                bundleID: "com.cydius.app",
                version: "1.0.0",
                developer: "Cydius Team",
                description: "The original Cydius sideloading app.",
                downloadURL: "https://github.com/GoldenShivery/Cydius/releases/latest/download/Cydius.ipa",
                size: "12 MB",
                category: .apps
            ),
            AppItem(
                name: "Cydius Lightweight",
                bundleID: "com.cydius.lite",
                version: "1.0.0",
                developer: "Cydius Team",
                description: "A lighter version of Cydius with fewer features.",
                downloadURL: "https://github.com/GoldenShivery/Cydius/releases/latest/download/CydiusLite.ipa",
                size: "6 MB",
                category: .apps
            )
        ]
    }

    func loadSampleCertificates() {
        certificates = [
            CydCertificate(
                name: "Free Developer Cert",
                country: "US",
                status: .safe,
                expiryDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                isSelected: true
            ),
            CydCertificate(
                name: "Enterprise Cert",
                country: "GB",
                status: .revoked,
                expiryDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                isSelected: false
            )
        ]
        selectedCertificate = certificates.first
    }

    func beginInstall(app: AppItem) {
        guard !isInstalling else { return }
        activeInstall = app
        isInstalling = true
        installLogs = []
        installProgress = 0

        simulateInstall(app: app)
    }

    func installIPA(url: URL) {
        guard !isInstalling else { return }
        let fakeApp = AppItem(
            name: url.deletingPathExtension().lastPathComponent,
            bundleID: "com.sideloaded.\(url.deletingPathExtension().lastPathComponent.lowercased())",
            version: "1.0",
            developer: "Sideloaded",
            description: "Sideloaded via Cydius",
            downloadURL: url.absoluteString,
            size: "Unknown",
            category: .apps
        )
        activeInstall = fakeApp
        isInstalling = true
        installLogs = []
        installProgress = 0
        simulateInstall(app: fakeApp)
    }

    func scanURL(_ urlString: String, completion: @escaping (ScanResult) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            // Simulate scan - in real app would call VirusTotal or similar
            let isSuspicious = urlString.contains("mediafire") || urlString.contains("mega") || urlString.contains("drive.google")
            let score = isSuspicious ? Int.random(in: 30...70) : Int.random(in: 85...100)
            let threats: [String]
            if score < 50 {
                threats = ["Potential Malware", "Suspicious Origin"]
            } else if score < 75 {
                threats = ["Unverified Source"]
            } else {
                threats = []
            }
            let result = ScanResult(safetyScore: score, threats: threats, blocked: score < 50)
            DispatchQueue.main.async { completion(result) }
        }
    }

    private func simulateInstall(app: AppItem) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"

        let steps: [(Double, String)] = [
            (0.05, "[\(formatter.string(from: now))] Cydius installer initializing..."),
            (0.10, "[\(formatter.string(from: now))] Resolving bundle: \(app.bundleID)"),
            (0.18, "[\(formatter.string(from: now))] GET \(app.downloadURL)"),
            (0.25, "[\(formatter.string(from: now))] HTTP/1.1 200 OK"),
            (0.32, "[\(formatter.string(from: now))] Downloading \(app.size)..."),
            (0.42, "[\(formatter.string(from: now))] Download complete. Verifying SHA256..."),
            (0.50, "[\(formatter.string(from: now))] Signature check passed ✓"),
            (0.58, "[\(formatter.string(from: now))] Extracting payload..."),
            (0.65, "[\(formatter.string(from: now))] installd: installing \(app.bundleID)"),
            (0.75, "[\(formatter.string(from: now))] Writing to /var/containers/Bundle/Application/"),
            (0.85, "[\(formatter.string(from: now))] Registering with SpringBoard..."),
            (0.92, "[\(formatter.string(from: now))] Finalizing install..."),
            (1.00, "[\(formatter.string(from: now))] ✓ \(app.name) installed successfully!")
        ]

        for (i, step) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                self.installProgress = step.0
                self.installLogs.append(step.1)
                if step.0 >= 1.0 {
                    var installed = app
                    installed.isInstalled = true
                    self.installedApps.append(installed)
                    if let idx = self.featuredApps.firstIndex(where: { $0.id == app.id }) {
                        self.featuredApps[idx].isInstalled = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.isInstalling = false
                    }
                }
            }
        }
    }
}

struct ScanResult {
    let safetyScore: Int
    let threats: [String]
    let blocked: Bool
}

struct CydCertificate: Identifiable {
    let id = UUID()
    var name: String
    var country: String
    var status: CertStatus
    var expiryDate: Date
    var isSelected: Bool

    enum CertStatus {
        case safe, revoked, expired
    }
}
