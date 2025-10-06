import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: TimerModel

    private let gradientStart = Color("IceBlue", bundle: .module)
    private let primaryButtonColor = Color(red: 0.09, green: 0.38, blue: 0.86)

    var body: some View {
        VStack(spacing: 16) {
            penguinTimer
            modePicker
            durationStepper
            controlRow
            quickStartButtons
        }
        .padding(20)
        .frame(width: 320)
        .background(
            LinearGradient(colors: [gradientStart, .white], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .tint(primaryButtonColor)
        .foregroundStyle(.primary)
    }

    private var penguinTimer: some View {
        ZStack {
            penguinImage
                .frame(width: 180, height: 180)

            Text(model.formattedRemaining)
                .font(.system(size: 36, weight: .semibold, design: .monospaced))
                .foregroundStyle(.black)
                .shadow(radius: 2)
                .accessibilityLabel("Remaining time")
        }
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

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(TimerModel.Mode.allCases) { mode in
                Button {
                    model.setMode(mode)
                } label: {
                    Text(mode.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(mode == model.currentMode ? primaryButtonColor : Color.white.opacity(0.25))
                        )
                        .overlay(
                            Capsule()
                                .stroke(primaryButtonColor, lineWidth: 1)
                        )
                        .foregroundColor(mode == model.currentMode ? .white : primaryButtonColor)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var durationStepper: some View {
        Stepper(value: Binding(
            get: { model.duration(for: model.currentMode) },
            set: { model.updateDuration(for: model.currentMode, minutes: $0) }
        ), in: 1...180) {
            Text("Duration: \(model.duration(for: model.currentMode)) min")
        }
    }

    private var controlRow: some View {
        HStack(spacing: 12) {
            if model.state == .running {
                Button("Pause") {
                    model.pause()
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryButtonColor)
            } else {
                Button("Start") {
                    model.start()
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryButtonColor)
            }

            Button("Reset") {
                model.reset()
            }
            .buttonStyle(.borderedProminent)
            .tint(primaryButtonColor)

            Spacer()

            VStack(alignment: .trailing) {
                Text("Focus cycles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(model.cyclesCompleted)")
                    .font(.body.monospacedDigit())
            }
        }
    }

    private var quickStartButtons: some View {
        HStack {
            Text("Quick start")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach([15, 25, 45], id: \.self) { minutes in
                Button("\(minutes)m") {
                    model.quickStart(minutes)
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryButtonColor)
                .controlSize(.small)
            }

            Spacer()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerModel())
}
