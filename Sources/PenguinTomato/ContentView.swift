import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: TimerModel

    private let accentPrimary = Palette.tomatoRed
    private let accentSecondary = Palette.outlineBrown
    private let cardBackground = Palette.creamWhite.opacity(0.94)

    @State private var expandedEditor: TimerModel.Mode? = .focus
    @State private var editorText: [TimerModel.Mode: String] = [:]
    @State private var invalidEditors: Set<TimerModel.Mode> = []

    var body: some View {
        ZStack {
            LinearGradient(colors: [Palette.creamWhite, Color.white], startPoint: .top, endPoint: .bottom)
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
            ZStack {
                penguinImage
                    .frame(width: 200, height: 200)

                Text(model.formattedRemaining)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundStyle(.black)
                    .shadow(radius: 3)
                    .accessibilityLabel("Remaining time")
            }

            HStack(spacing: 8) {
                modeIcon(for: model.currentMode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 84, height: 84)

                Text(model.currentMode.displayName)
                    .font(.headline)
                    .foregroundColor(accentSecondary)
            }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(
        RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Palette.penguinBlack.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Palette.penguinBlack.opacity(0.06), radius: 18, y: 10)
        )
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
            .buttonStyle(DestructiveActionButtonStyle(color: accentPrimary))
            .disabled(model.state != .running)

            Button("Reset") {
                model.reset()
            }
            .buttonStyle(SecondaryActionButtonStyle(primary: accentPrimary, outline: accentSecondary))
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
                    .fill(color)
                    .shadow(color: color.opacity(configuration.isPressed ? 0.12 : 0.35), radius: 12, y: 8)
            )
            .foregroundColor(Palette.creamWhite)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    let primary: Color
    let outline: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 24)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .stroke(outline, lineWidth: 2)
                    .background(
                        Capsule()
                            .fill(primary.opacity(configuration.isPressed ? 0.22 : 0.08))
                    )
            )
            .foregroundColor(outline)
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
            .foregroundColor(.white.opacity(isEnabled ? 1 : 0.6))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }

    private func opacity(for configuration: Configuration) -> Double {
        if !isEnabled { return 0.3 }
        return configuration.isPressed ? 0.7 : 1.0
    }
}

private struct StatusChip: View {
    let text: String
    let color: Color
    var iconSystemName: String? = nil
    var assetName: String? = nil
    var textColor: Color = Palette.creamWhite

    var body: some View {
        HStack(spacing: 8) {
            if let assetName,
               let image = Bundle.module.image(forResource: assetName) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)
            } else if let iconSystemName {
                Image(systemName: iconSystemName)
            }

            Text(text)
                .font(.footnote.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color)
        )
        .foregroundColor(textColor)
    }
}

private struct FocusCyclesCount: View {
    let count: Int

    var body: some View {
        HStack(spacing: 12) {
            focusIcon

            VStack(alignment: .leading, spacing: 2) {
                Text("Icebergs climbed")
                    .font(.caption.weight(.medium))
                    .foregroundColor(Palette.outlineBrown)
                Text("\(count)")
                    .font(.title3.monospacedDigit().weight(.semibold))
                    .foregroundColor(Palette.outlineBrown)
            }
        }
    }

    @ViewBuilder
    private var focusIcon: some View {
        if let image = Bundle.module.image(forResource: "FocusBadge") {
            Image(nsImage: image)
                .resizable()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            Text("🐟")
                .font(.system(size: 42))
        }
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
                        .foregroundColor(Palette.outlineBrown)

                    Spacer()

                    Capsule()
                        .fill(Palette.tomatoRed.opacity(0.15))
                        .overlay(
                            Text(summary)
                                .font(.callout.monospacedDigit())
                                .foregroundColor(Palette.tomatoRed)
                                .padding(.horizontal, 12)
                        )
                        .frame(height: 30)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Palette.outlineBrown.opacity(0.6))
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
                                .stroke(isInvalid ? Color.red.opacity(0.8) : Palette.outlineBrown.opacity(0.25), lineWidth: 1)
                        )
                        .onSubmit(onCommit)

                    Button("Apply") {
                        onCommit()
                    }
                    .buttonStyle(SecondaryActionButtonStyle(primary: Palette.tomatoRed, outline: Palette.outlineBrown))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

private extension ContentView {
    var statusChip: some View {
        switch model.state {
        case .running:
            if model.currentMode == .focus {
                return AnyView(
                    HStack(spacing: 8) {
                        modeIcon(for: .focus)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 84, height: 84)
                        Text("Focus")
                            .font(.headline)
                            .foregroundColor(Palette.outlineBrown)
                    }
                )
            } else {
                return AnyView(StatusChip(text: "Break", color: Palette.beakOrange.opacity(0.85), iconSystemName: "cup.and.saucer.fill", textColor: Palette.outlineBrown))
            }
        case .paused:
            return AnyView(StatusChip(text: "Paused", color: Palette.cheekPink, iconSystemName: "pause.circle"))
        case .idle:
            if model.currentMode == .breakTime {
                return AnyView(StatusChip(text: "Break ready", color: Palette.beakOrange.opacity(0.5), iconSystemName: "cup.and.saucer", textColor: Palette.outlineBrown))
            }
            return AnyView(StatusChip(text: "Idle", color: Palette.creamWhite.opacity(0.9), assetName: "SleepingPenguin", textColor: Palette.outlineBrown))
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
            return Image(systemName: "cup.and.saucer.fill")
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
    static let penguinBlack = Color(red: 59/255, green: 48/255, blue: 44/255)
    static let creamWhite = Color(red: 1.0, green: 246/255, blue: 232/255)
    static let beakOrange = Color(red: 247/255, green: 164/255, blue: 76/255)
    static let cheekPink = Color(red: 248/255, green: 184/255, blue: 168/255)
    static let tomatoRed = Color(red: 228/255, green: 71/255, blue: 46/255)
    static let leafGreen = Color(red: 76/255, green: 122/255, blue: 58/255)
    static let outlineBrown = Color(red: 77/255, green: 59/255, blue: 51/255)
}
