import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @AppStorage("appleID") var appleID = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // App header
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.orange)
                                .frame(width: 80, height: 80)
                            Text("⬇️")
                                .font(.system(size: 40))
                        }
                        VStack(spacing: 4) {
                            Text("Cydius")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("version 1.0.0")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 20)

                    // Stats card
                    HStack(spacing: 0) {
                        StatCard(value: "\(store.installedApps.count)", label: "installed")
                        Divider()
                            .frame(height: 40)
                            .background(Color(white: 0.15))
                        StatCard(value: "\(store.featuredApps.count)", label: "available")
                        Divider()
                            .frame(height: 40)
                            .background(Color(white: 0.15))
                        StatCard(value: "iOS 16+", label: "supported")
                    }
                    .padding(.vertical, 16)
                    .background(Color(white: 0.07))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)

                    // Sign in section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ACCOUNT")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                            .tracking(1.2)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 18))
                                    .frame(width: 32)
                                TextField("apple id (optional)", text: $appleID)
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(Color(white: 0.07))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }

                    // About section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ABOUT")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                            .tracking(1.2)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            SettingsRow(icon: "chevron.left.forwardslash.chevron.right", iconColor: .orange, title: "GitHub", value: "github.com/GoldenShivery/Cydius")
                            Divider().background(Color(white: 0.1)).padding(.leading, 52)
                            SettingsRow(icon: "checkmark.shield.fill", iconColor: .green, title: "Compatibility", value: "iOS 16 – 26")
                            Divider().background(Color(white: 0.1)).padding(.leading, 52)
                            SettingsRow(icon: "paintbrush.fill", iconColor: .blue, title: "UI Inspired By", value: "Scarlet & eSign")
                        }
                        .background(Color(white: 0.07))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }

                    // Clear installed
                    if !store.installedApps.isEmpty {
                        Button {
                            withAnimation {
                                store.installedApps.removeAll()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                Text("clear installed apps")
                                    .foregroundColor(.red)
                                    .font(.system(size: 15))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
