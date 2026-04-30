import Foundation

struct AppItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var bundleID: String
    var version: String
    var developer: String
    var description: String
    var downloadURL: String
    var iconURL: String
    var size: String
    var category: AppCategory
    var isInstalled: Bool = false
    var installProgress: Double = 0

    enum AppCategory: String, Codable, CaseIterable {
        case tweaks = "Tweaks"
        case apps = "Apps"
        case games = "Games"
        case tools = "Tools"
        case themes = "Themes"
    }
}

struct InstallStage: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var status: StageStatus = .waiting

    enum StageStatus {
        case waiting, active, done, failed
    }
}
