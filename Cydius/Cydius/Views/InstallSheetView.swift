import SwiftUI

struct InstallSheetView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(white: 0.04).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(white: 0.25))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        // App header
                        if let app = store.activeInstall {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.orange)
                                        .frame(width: 60, height: 60)
                                    Text("⬇️")
                                        .font(.system(size: 30))
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(app.name)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(app.developer + " · " + app.version)
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if store.installComplete {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.green)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Ring progress
                        RingProgressView(progress: store.installProgress / 100)
                            .frame(width: 130, height: 130)
                            .padding(.vertical, 6)

                        // Stage steps
                        VStack(spacing: 0) {
                            ForEach(Array(store.installStages.enumerated()), id: \.element.id) { idx, stage in
                                StageRow(stage: stage, isLast: idx == store.installStages.count - 1)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Terminal log
                        TerminalView(lines: store.installLog)
                            .padding(.horizontal, 20)

                        // Done / Cancel
                        if store.installComplete {
                            Button {
                                dismiss()
                            } label: {
                                Text("done")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.orange)
                                    .cornerRadius(14)
                            }
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            Button {
                                store.cancelInstall()
                                dismiss()
                            } label: {
                                Text("cancel")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer(minLength: 30)
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.installComplete)
    }
}

struct RingProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(white: 0.12), lineWidth: 10)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.orange,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                Text("installing")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .tracking(1)
            }
        }
    }
}

struct StageRow: View {
    let stage: InstallStage
    let isLast: Bool

    var statusColor: Color {
        switch stage.status {
        case .done: return .green
        case .active: return .orange
        case .waiting: return Color(white: 0.2)
        case .failed: return .red
        }
    }

    var icon: String {
        switch stage.status {
        case .done: return "checkmark"
        case .active: return "circle.fill"
        case .waiting: return "circle"
        case .failed: return "xmark"
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(stage.status == .waiting ? 1 : 0.2))
                        .frame(width: 28, height: 28)
                    if stage.status == .active {
                        Circle()
                            .stroke(Color.orange, lineWidth: 1.5)
                            .frame(width: 28, height: 28)
                    }
                    Image(systemName: icon)
                        .font(.system(size: stage.status == .active ? 8 : 11, weight: .bold))
                        .foregroundColor(statusColor)
                }

                if !isLast {
                    Rectangle()
                        .fill(stage.status == .done ? Color.green.opacity(0.4) : Color(white: 0.12))
                        .frame(width: 1.5, height: 32)
                        .animation(.easeInOut, value: stage.status)
                }
            }
            .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(stage.name)
                    .font(.system(size: 14, weight: stage.status == .active ? .semibold : .regular))
                    .foregroundColor(stage.status == .active ? .white : stage.status == .done ? Color(white: 0.5) : Color(white: 0.3))
                if stage.status == .active {
                    Text("in progress...")
                        .font(.system(size: 11))
                        .foregroundColor(.orange.opacity(0.7))
                } else if stage.status == .done {
                    Text("complete")
                        .font(.system(size: 11))
                        .foregroundColor(.green.opacity(0.6))
                }
            }
            .padding(.leading, 8)
            .padding(.vertical, isLast ? 8 : 0)

            Spacer()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: stage.status)
    }
}

struct TerminalView: View {
    let lines: [AppStore.LogLine]

    var lineColor: (AppStore.LogLine) -> Color {
        return { line in
            switch line.type {
            case .success: return .green
            case .warning: return .yellow
            case .error: return .red
            case .system: return Color(red: 0.37, green: 0.64, blue: 0.98)
            case .info: return Color(white: 0.65)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 5) {
                    Circle().fill(Color.red.opacity(0.6)).frame(width: 9, height: 9)
                    Circle().fill(Color.yellow.opacity(0.6)).frame(width: 9, height: 9)
                    Circle().fill(Color.green.opacity(0.6)).frame(width: 9, height: 9)
                }
                Spacer()
                Text("install log")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color(white: 0.3))
                Spacer()
                Rectangle().fill(Color.clear).frame(width: 50, height: 9)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(white: 0.07))

            VStack(alignment: .leading, spacing: 4) {
                ForEach(lines) { line in
                    HStack(spacing: 8) {
                        Text("›")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(white: 0.25))
                        Text(line.text)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(lineColor(line))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                if !lines.isEmpty {
                    HStack(spacing: 4) {
                        Text("›")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(white: 0.25))
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 7, height: 13)
                            .opacity(1)
                            .animation(Animation.easeInOut(duration: 0.6).repeatForever(), value: lines.count)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(white: 0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(white: 0.1), lineWidth: 0.5)
        )
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.2), value: lines.count)
    }
}
