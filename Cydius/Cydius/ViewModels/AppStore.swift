import SwiftUI
import Combine

class AppStore: ObservableObject {
    @Published var apps: [AppModel] = [
        AppModel(
            name: "Cydius",
            bundleID: "com.cydius.app",
            version: "1.0",
            developer: "Cydius Team",
            description: "Main Cydius application",
            downloadURL: "",
            size: "45 MB",
            category: .apps,
            isInstalled: true
        ),
        AppModel(
            name: "Cydius Lightweight",
            bundleID: "com.cydius.lite",
            version: "1.0",
            developer: "Cydius Team",
            description: "Lighter version of Cydius",
            downloadURL: "",
            size: "25 MB",
            category: .apps,
            isInstalled: false
        )
    ]
    
    var installedApps: [AppModel] {
        apps.filter { $0.isInstalled }
    }
    
    var featuredApps: [AppModel] {
        apps
    }
    
    @Published var selectedCertificate: Certificate?
    
    @Published var safeSignEnabled: Bool = false
    @Published var smartSignEnabled: Bool = false
    
    @Published var certificates: [Certificate] = [
        Certificate(
            name: "Cydius Developer",
            country: "US",
            status: .safe,
            expiryDate: Calendar.current.date(byAdding: .day, value: 365, to: Date()) ?? Date(),
            isSelected: true
        ),
        Certificate(
            name: "Enterprise Signing",
            country: "CN",
            status: .revoked,
            expiryDate: Calendar.current.date(byAdding: .day, value: 180, to: Date()) ?? Date(),
            isSelected: false
        ),
        Certificate(
            name: "Test Certificate",
            country: "UK",
            status: .expired,
            expiryDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            isSelected: false
        )
    ]
    
    func reinstallApp(_ app: AppModel) {
        guard let index = apps.firstIndex(where: { $0.id == app.id }) else { return }
        apps[index].isInstalled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.apps[index].isInstalled = true
        }
    }
    
    func openApp(_ app: AppModel) {
        print("Opening \(app.name)")
    }
    
    func installIPA(from url: URL) {
        print("Installing IPA from: \(url)")
    }
}

struct Certificate: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let status: CertificateStatus
    let expiryDate: Date
    var isSelected: Bool
    
    enum CertificateStatus {
        case safe
        case revoked
        case expired
        
        var displayText: String {
            switch self {
            case .safe: return "Valid"
            case .revoked: return "Revoked"
            case .expired: return "Expired"
            }
        }
    }
}
