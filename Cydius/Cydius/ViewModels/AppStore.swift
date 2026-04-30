import SwiftUI
import Combine

class AppStore: ObservableObject {
    @Published var apps: [AppModel] = [
        AppModel(
            name: "Cydius",
            bundleID: "com.cydius.app",
            version: "1.0",
            developer: "Cydius Team",
            description: "Main sideloading app",
            downloadURL: "https://cydius.app/download",
            size: "15 MB",
            category: .apps,
            isInstalled: true
        ),
        AppModel(
            name: "Cydius Lightweight",
            bundleID: "com.cydius.lite",
            version: "1.0",
            developer: "Cydius Team",
            description: "Lightweight version",
            downloadURL: "https://cydius.app/lite",
            size: "8 MB",
            category: .apps,
            isInstalled: false
        )
    ]

    @Published var safeSignEnabled: Bool = false
    @Published var smartSignEnabled: Bool = false

    @Published var certificates: [Certificate] = [
        Certificate(
            name: "Cydius Developer",
            country: "US",
            status: .valid,
            expiry: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
            isSelected: true
        )
    ]

    @Published var selectedCertificateID: UUID? = nil
    @Published var appleID: String = ""

    var installedApps: [AppModel] {
        apps.filter { $0.isInstalled }
    }
    
    var featuredApps: [AppModel] {
        apps
    }
    
    var selectedCertificate: Certificate? {
        certificates.first { $0.id == selectedCertificateID }
    }

    @Published var totalInstalled: Int = 1
    @Published var totalSideloaded: Int = 0

    func reinstallApp(_ app: AppModel) {
        var currentApps = apps
        if let idx = currentApps.firstIndex(where: { $0.id == app.id }) {
            currentApps[idx].isInstalled = false
            apps = currentApps
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                var updatedApps = self.apps
                if let i = updatedApps.firstIndex(where: { $0.id == app.id }) {
                    updatedApps[i].isInstalled = true
                    self.apps = updatedApps
                }
            }
        }
    }

    func selectCertificate(_ cert: Certificate) {
        selectedCertificateID = cert.id
    }
}

struct Certificate: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let status: CertStatus
    let expiry: Date
    var isSelected: Bool

    enum CertStatus {
        case valid, revoked, expired

        var label: String {
            switch self {
            case .valid: return "Valid"
            case .revoked: return "Revoked"
            case .expired: return "Expired"
            }
        }

        var color: Color {
            switch self {
            case .valid: return .green
            case .revoked: return .red
            case .expired: return .orange
            }
        }
    }

    var expiryFormatted: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: expiry)
    }

    var flagEmoji: String {
        let base: UInt32 = 127397
        return country.unicodeScalars.compactMap {
            Unicode.Scalar(base + $0.value).map { String($0) }
        }.joined()
    }
}
