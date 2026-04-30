import SwiftUI

struct SettingsView: View {
    @AppStorage("udid") var udid = ""
    @AppStorage("appleID") var appleID = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                List {
                    Section {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.orange)
                                    .frame(width: 54, height: 54)
                                Text("⬇️")
                                    .font(.system(size: 28))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Cydius")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Text("version 1.0.0")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(Color(white: 0.07))
                    }

                    Section(header: Text("device").foregroundColor(.gray).font(.system(size: 11)).tracking(1)) {
                        HStack {
                            Label("UDID", systemImage: "iphone")
                                .foregroundColor(.white)
                            Spacer()
                            TextField("enter udid", text: $udid)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.orange)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        .listRowBackground(Color(white: 0.07))

                        HStack {
                            Label("Apple ID", systemImage: "person.circle")
                                .foregroundColor(.white)
                            Spacer()
                            TextField("email", text: $appleID)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.orange)
                                .font(.system(size: 13))
                        }
                        .listRowBackground(Color(white: 0.07))
                    }

                    Section(header: Text("about").foregroundColor(.gray).font(.system(size: 11)).tracking(1)) {
                        HStack {
                            Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                                .foregroundColor(.white)
                            Spacer()
                            Text("github.com/cydius")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .listRowBackground(Color(white: 0.07))

                        HStack {
                            Label("Compatibility", systemImage: "checkmark.shield")
                                .foregroundColor(.white)
                            Spacer()
                            Text("iOS 15 – 17")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .listRowBackground(Color(white: 0.07))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
