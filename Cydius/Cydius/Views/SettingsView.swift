import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Stats card
                        HStack(spacing: 0) {
                            StatBlock(value: "\(store.totalInstalled)", label: "Installed")
                            Divider().background(Color.white.opacity(0.1))
                            StatBlock(value: "\(store.apps.count)", label: "Available")
                        }
                        .frame(height: 70)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Security section
                        SectionHeader(title: "SECURITY")

                        VStack(spacing: 0) {
                            // Safe Sign
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle(isOn: $store.safeSignEnabled) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "shield.checkered")
                                            .foregroundColor(.orange)
                                            .frame(width: 28)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Safe Sign")
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                            Text("Scans IPAs for viruses, malware & spyware before installing")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                .padding(14)
                            }

                            Divider().background(Color.white.opacity(0.08)).padding(.leading, 50)

                            // Smart Sign
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle(isOn: $store.smartSignEnabled) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "wifi")
                                            .foregroundColor(.orange)
                                            .frame(width: 28)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Smart Sign")
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                            Text("Only sideload when connected to WiFi, Ethernet or Mobile Data")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                .padding(14)
                            }
                        }
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(14)
                        .padding(.horizontal)

                        // Certificates section
                        SectionHeader(title: "CERTIFICATES")

                        VStack(spacing: 10) {
                            ForEach(store.certificates) { cert in
                                CertificateRow(cert: cert, isSelected: store.selectedCertificate?.id == cert.id) {
                                    store.selectCertificate(cert)
                                }
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 80)
                    }
                    .padding(.top, 16)
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

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
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

struct CertificateRow: View {
    let cert: Certificate
    let isSelected: Bool
    let onSelect: () -> Void

    var statusColor: Color {
        cert.status.color
    }

    var statusText: String {
        cert.status.label
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Text(cert.flagEmoji)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(cert.name)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .font(.subheadline)
                    Text(cert.expiryFormatted)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(statusText)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.15))
                        .cornerRadius(8)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
            }
            .padding(12)
            .background(isSelected ? Color.orange.opacity(0.1) : Color.white.opacity(0.06))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
}
