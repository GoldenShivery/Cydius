import SwiftUI

struct InstalledView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                if store.installedApps.isEmpty {
                    VStack(spacing: 14) {
                        Text("⬇️").font(.system(size: 52))
                        Text("no apps installed yet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Text("head to browse and install something")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(store.installedApps) { app in
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.orange)
                                            .frame(width: 54, height: 54)
                                        Text("⬇️").font(.system(size: 26))
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(app.name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(app.developer)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        Text("v" + app.version + " · installed")
                                            .font(.system(size: 11))
                                            .foregroundColor(.green)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 20))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                Divider()
                                    .background(Color(white: 0.1))
                                    .padding(.leading, 76)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("installed")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
