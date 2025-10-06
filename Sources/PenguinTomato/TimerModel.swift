import Foundation
import SwiftUI

@MainActor
final class TimerModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case focus
        case shortBreak
        case longBreak
        case custom

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .focus: return "Focus"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            case .custom: return "Custom"
            }
        }

        var completionMessage: String {
            switch self {
            case .focus:
                return "Focus session complete! Time for a break."
            case .shortBreak:
                return "Short break wrapped up. Ready to refocus?"
            case .longBreak:
                return "Long break finished. Back to the iceberg!"
            case .custom:
                return "Custom timer finished."
            }
        }
    }

    enum State: String {
        case idle
        case running
        case paused
    }

    @Published private(set) var currentMode: Mode
    @Published private(set) var state: State = .idle
    @Published private(set) var remaining: Int
    @Published private var durationMinutes: [Mode: Int]
    @Published private(set) var cyclesCompleted: Int = 0

    private var timer: DispatchSourceTimer?
    private let notificationManager: NotificationManager
    private let soundPlayer: SoundPlayer

    init(notificationManager: NotificationManager = .shared,
         soundPlayer: SoundPlayer = .shared) {
        self.notificationManager = notificationManager
        self.soundPlayer = soundPlayer

        var defaults: [Mode: Int] = [:]
        defaults[.focus] = 25
        defaults[.shortBreak] = 5
        defaults[.longBreak] = 15
        defaults[.custom] = 20

        durationMinutes = defaults
        currentMode = .focus
        remaining = (defaults[.focus] ?? 25) * 60
    }

    var menuBarLabel: String {
        switch state {
        case .running:
            return "🐧 " + formattedRemaining
        case .paused, .idle:
            return "🐧 Idle"
        }
    }

    var formattedRemaining: String {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func setMode(_ mode: Mode) {
        guard mode != currentMode else { return }
        cancelTimer()
        notificationManager.cancelPending()
        currentMode = mode
        remaining = duration(for: mode) * 60
        state = .idle
    }

    func start() {
        guard state != .running else { return }
        if remaining <= 0 {
            remaining = duration(for: currentMode) * 60
        }
        notificationManager.cancelPending()
        notificationManager.scheduleTimerNotification(after: remaining, message: currentMode.completionMessage)
        createTimer()
        state = .running
    }

    func pause() {
        guard state == .running else { return }
        cancelTimer()
        state = .paused
        notificationManager.cancelPending()
    }

    func reset() {
        cancelTimer()
        remaining = duration(for: currentMode) * 60
        state = .idle
        notificationManager.cancelPending()
    }

    func quickStart(_ minutes: Int) {
        updateDuration(for: .custom, minutes: minutes)
        currentMode = .custom
        remaining = minutes * 60
        state = .idle
        start()
    }

    func duration(for mode: Mode) -> Int {
        max(1, durationMinutes[mode] ?? 1)
    }

    func updateDuration(for mode: Mode, minutes: Int) {
        let clamped = max(1, minutes)
        durationMinutes[mode] = clamped
        if mode == currentMode && state != .running {
            remaining = clamped * 60
        }
    }

    private func createTimer() {
        cancelTimer()
        let newTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        newTimer.schedule(deadline: .now() + 1, repeating: 1)
        newTimer.setEventHandler { [weak self] in
            guard let self else { return }
            self.tick()
        }
        timer = newTimer
        newTimer.resume()
    }

    private func tick() {
        guard remaining > 0 else {
            completeTimer()
            return
        }

        remaining -= 1
        if remaining <= 0 {
            completeTimer()
        }
    }

    private func completeTimer() {
        cancelTimer()
        notificationManager.cancelPending()
        soundPlayer.playPenguin()
        notificationManager.deliverCompletionNotification(message: currentMode.completionMessage)
        if currentMode == .focus {
            cyclesCompleted += 1
        }
        remaining = duration(for: currentMode) * 60
        state = .idle
    }

    private func cancelTimer() {
        timer?.setEventHandler {}
        timer?.cancel()
        timer = nil
    }
}
