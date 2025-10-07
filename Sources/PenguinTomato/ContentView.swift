import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: TimerModel

    private let accentPrimary = Palette.buttonPrimary
    private let accentSecondary = Palette.textPrimary
    private let cardBackground = Palette.creamWhite.opacity(0.85)

    @State private var expandedEditor: TimerModel.Mode? = nil
    @State private var editorText: [TimerModel.Mode: String] = [:]
    @State private var invalidEditors: Set<TimerModel.Mode> = []

    var body: some View {
        ZStack {
            LinearGradient(colors: [Palette.backgroundDark, Palette.creamWhite], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                penguinCard
                durationSection
                controlSection
            }
            .padding(24)
            .frame(width: 360)
        }
        .tint(accentPrimary)
        .foregroundColor(accentSecondary)
        .onAppear { refreshEditorTexts() }
    }

    private var penguinCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                Text(model.formattedRemaining)
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundColor(Palette.whiteAccent)
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
                    .accessibilityLabel("Remaining time")

                modeIcon(for: model.currentMode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Palette.statusIconSize, height: Palette.statusIconSize)
            }

            Text("\(model.currentMode.displayName) phase")
                .font(.headline)
                .foregroundColor(accentSecondary)
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var penguinImage: some View {
        if let image = Bundle.module.image(forResource: "PenguinBelly") {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Text("🐧")
                .font(.system(size: 140))
        }
    }

    private var durationSection: some View {
        VStack(spacing: 18) {
            DurationEditorRow(
                title: "Focus duration",
                detail: "Work session",
                seconds: model.duration(for: .focus),
                text: binding(for: .focus),
                isExpanded: expandedEditor == .focus,
                isInvalid: invalidEditors.contains(.focus),
                onToggle: { toggleEditor(.focus) },
                onCommit: { applyDuration(for: .focus) }
            )

            DurationEditorRow(
                title: "Break duration",
                detail: "Runs automatically after focus",
                seconds: model.duration(for: .breakTime),
                text: binding(for: .breakTime),
                isExpanded: expandedEditor == .breakTime,
                isInvalid: invalidEditors.contains(.breakTime),
                onToggle: { toggleEditor(.breakTime) },
                onCommit: { applyDuration(for: .breakTime) }
            )

            HStack {
                FocusCyclesCount(count: model.cyclesCompleted)

                Spacer()

                statusChip
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Palette.penguinBlack.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Palette.penguinBlack.opacity(0.05), radius: 12, y: 6)
        )
    }

    private var controlSection: some View {
        HStack(spacing: 14) {
            if model.state == .running {
                Button("Pause") {
                    model.pause()
                }
                .buttonStyle(PrimaryActionButtonStyle(color: accentPrimary))
            } else {
                Button("Start") {
                    model.start()
                }
                .buttonStyle(PrimaryActionButtonStyle(color: accentPrimary))
            }

            Button("Stop") {
                model.stop()
            }
            .buttonStyle(DestructiveActionButtonStyle(color: Palette.buttonSecondary))
            .disabled(model.state != .running)

            Button("Reset") {
                model.reset()
            }
            .buttonStyle(SecondaryActionButtonStyle(strokeColor: Palette.outlineLight, fillColor: Palette.backgroundDark))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerModel())
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(color.opacity(configuration.isPressed ? 0.85 : 1.0))
            )
            .foregroundColor(Palette.whiteAccent)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    let strokeColor: Color
    let fillColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 24)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .stroke(strokeColor, lineWidth: 2)
                    .background(
                        Capsule()
                            .fill(fillColor.opacity(configuration.isPressed ? 0.2 : 0.08))
                    )
            )
            .foregroundColor(strokeColor.opacity(configuration.isPressed ? 0.85 : 1.0))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

private struct DestructiveActionButtonStyle: ButtonStyle {
    let color: Color
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 24)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(color.opacity(opacity(for: configuration)))
            )
            .foregroundColor(Palette.whiteAccent.opacity(isEnabled ? 1 : 0.6))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }

    private func opacity(for configuration: Configuration) -> Double {
        if !isEnabled { return 0.25 }
        return configuration.isPressed ? 0.7 : 1.0
    }
}

private struct FocusCyclesCount: View {
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            if let image = Bundle.module.image(forResource: "FocusBadge") {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Palette.statusIconSize, height: Palette.statusIconSize)
            } else {
                Text("🐧")
                    .font(.system(size: 42))
            }

            VStack(spacing: 2) {
                Text("Icebergs climbed")
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Palette.textPrimary)
                Text("\(count)")
                    .font(.title3.monospacedDigit().weight(.semibold))
                    .foregroundColor(Palette.textPrimary)
            }
        }
        .help("Number of focus sessions you’ve completed this run")
    }
}

private struct DurationEditorRow: View {
    let title: String
    let detail: String
    let seconds: Int
    @Binding var text: String
    let isExpanded: Bool
    let isInvalid: Bool
    let onToggle: () -> Void
    let onCommit: () -> Void

    private var summary: String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Palette.textPrimary)

                    Spacer()

                    Capsule()
                        .fill(Palette.buttonPrimary.opacity(0.15))
                        .overlay(
                            Text(summary)
                                .font(.callout.monospacedDigit())
                                .foregroundColor(Palette.buttonPrimary)
                                .padding(.horizontal, 12)
                        )
                        .frame(height: 30)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Palette.textPrimary.opacity(0.6))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(detail)

            if isExpanded {
                HStack(spacing: 12) {
                    TextField("mm:ss", text: $text)
                        .textFieldStyle(.plain)
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Palette.creamWhite)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isInvalid ? Color.red.opacity(0.8) : Palette.outlineLight.opacity(0.25), lineWidth: 1)
                        )
                        .onSubmit(onCommit)

                    Button("Apply") {
                        onCommit()
                    }
                    .buttonStyle(SecondaryActionButtonStyle(strokeColor: Palette.outlineLight, fillColor: Palette.backgroundDark))
                }
                .transition(.opacity)
            }
        }
    }
}

private extension ContentView {
    var statusChip: some View {
        switch model.state {
        case .running:
            if model.currentMode == .focus {
                return AnyView(largePenguinStatus(iconName: "FocusPenguin", title: "Focus"))
            } else {
                return AnyView(largePenguinStatus(iconName: "BreakPenguin", title: "Break"))
            }
        case .paused:
            return AnyView(largePenguinStatus(iconName: "PausePenguin", title: "Paused"))
        case .idle:
            if model.currentMode == .breakTime {
                return AnyView(largePenguinStatus(iconName: "BreakPenguin", title: "Break ready"))
            }
            return AnyView(largePenguinStatus(iconName: "SleepingPenguin", title: "Idle"))
        }
    }

    func toggleEditor(_ mode: TimerModel.Mode) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if expandedEditor == mode {
                expandedEditor = nil
            } else {
                expandedEditor = mode
                editorText[mode] = formattedDuration(for: mode)
                invalidEditors.remove(mode)
            }
        }
    }

    func applyDuration(for mode: TimerModel.Mode) {
        let text = editorText[mode] ?? ""
        guard let seconds = parseDuration(text) else {
            invalidEditors.insert(mode)
            return
        }
        invalidEditors.remove(mode)
        model.updateDuration(for: mode, seconds: seconds)
        editorText[mode] = formattedDuration(seconds: seconds)
    }

    func modeIcon(for mode: TimerModel.Mode) -> Image {
        switch mode {
        case .focus:
            if let image = Bundle.module.image(forResource: "FocusPenguin") {
                return Image(nsImage: image)
            }
            return Image(systemName: "bolt.fill")
        case .breakTime:
            if let image = Bundle.module.image(forResource: "BreakPenguin") {
                return Image(nsImage: image)
            }
            return Image(systemName: "cup.and.saucer.fill")
        }
    }

    func largePenguinStatus(iconName: String, title: String) -> some View {
        let size: CGFloat = Palette.statusIconSize
        return VStack(spacing: 8) {
            if let image = Bundle.module.image(forResource: iconName) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            }

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(Palette.textPrimary)
        }
    }

    func binding(for mode: TimerModel.Mode) -> Binding<String> {
        Binding<String>(
            get: { editorText[mode] ?? formattedDuration(for: mode) },
            set: { editorText[mode] = $0 }
        )
    }

    func refreshEditorTexts() {
        for mode in TimerModel.Mode.allCases {
            editorText[mode] = formattedDuration(for: mode)
        }
    }

    func formattedDuration(for mode: TimerModel.Mode) -> String {
        formattedDuration(seconds: model.duration(for: mode))
    }

    func formattedDuration(seconds: Int) -> String {
        let clamped = max(0, seconds)
        let minutes = clamped / 60
        let secs = clamped % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    func parseDuration(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let totalSeconds: Int
        if trimmed.contains(":") {
            let parts = trimmed.split(separator: ":", omittingEmptySubsequences: false)
            guard parts.count == 2,
                  let minutes = Int(parts[0]),
                  let seconds = Int(parts[1]),
                  (0..<60).contains(seconds) else { return nil }
            totalSeconds = minutes * 60 + seconds
        } else if let minutes = Int(trimmed) {
            totalSeconds = minutes * 60
        } else {
            return nil
        }

        return (1...12 * 60 * 60).contains(totalSeconds) ? totalSeconds : nil
    }
}

private enum Palette {
    static let penguinBlack = Color(red: 32/255, green: 36/255, blue: 34/255)
    static let backgroundDark = Color(red: 46/255, green: 50/255, blue: 48/255)
    static let creamWhite = Color(red: 62/255, green: 66/255, blue: 64/255)
    static let beakOrange = Color(red: 247/255, green: 164/255, blue: 76/255)
    static let cheekPink = Color(red: 248/255, green: 184/255, blue: 168/255)
    static let buttonPrimary = Color(red: 94/255, green: 108/255, blue: 126/255)
    static let buttonSecondary = Color(red: 72/255, green: 84/255, blue: 100/255)
    static let leafGreen = Color(red: 108/255, green: 162/255, blue: 118/255)
    static let whiteAccent = Color(red: 255/255, green: 246/255, blue: 232/255)
    static let outlineLight = Palette.whiteAccent.opacity(0.7)
    static let textPrimary = Palette.whiteAccent.opacity(0.92)
    static let statusIconSize: CGFloat = 84
}
