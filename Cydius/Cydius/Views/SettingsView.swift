import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @State private var appleID = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Logo header - orange card with your logo
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.orange)
                                .frame(height: 180)

                            Image("CydiusLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140, height: 140)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Stats card
                        HStack(spacing: 0) {
                            StatBlock(value: "\(store.installedApps.count)", label: "Installed")
                            Divider().background(Color.white.opacity(0.1))
                            StatBlock(value: "\(store.featuredApps.count)", label: "Available")
                        }
                        .frame(height: 70)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Signing section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SIGNING")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .padding(.horizontal)

                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.orange)
                                    .frame(width: 28)
                                TextField("Apple ID (optional)", text: $appleID)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct StatBlock: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
