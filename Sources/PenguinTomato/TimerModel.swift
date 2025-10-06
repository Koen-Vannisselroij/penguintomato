import Foundation
import SwiftUI

@MainActor
final class TimerModel: ObservableObject {
    enum Mode: String, Identifiable, CaseIterable {
        case focus
        case breakTime

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .focus: return "Focus"
            case .breakTime: return "Break"
            }
        }

        var completionMessage: String {
            switch self {
            case .focus:
                return "Focus session complete! Enjoy your break."
            case .breakTime:
                return "Break finished! Ready to refocus?"
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
    @Published private var durationSeconds: [Mode: Int]
    @Published private(set) var cyclesCompleted: Int = 0

    private var timer: DispatchSourceTimer?
    private let notificationManager: NotificationManager
    private let soundPlayer: SoundPlayer

    init(notificationManager: NotificationManager = .shared,
         soundPlayer: SoundPlayer = .shared) {
        self.notificationManager = notificationManager
        self.soundPlayer = soundPlayer

        var defaults: [Mode: Int] = [:]
        defaults[.focus] = 25 * 60
        defaults[.breakTime] = 5 * 60

        durationSeconds = defaults
        currentMode = .focus
        remaining = defaults[.focus] ?? 25 * 60
    }

    var menuBarLabel: String {
        switch state {
        case .running:
            return formattedRemaining
        case .paused:
            return "Paused"
        case .idle:
            return currentMode == .breakTime ? "Break ready" : "Idle"
        }
    }

    var menuBarIconName: String {
        switch state {
        case .running:
            return currentMode == .focus ? "MenuBarFocus" : "MenuBarBreak"
        case .paused:
            return "MenuBarPaused"
        case .idle:
            return currentMode == .breakTime ? "MenuBarBreak" : "MenuBarIdle"
        }
    }

    var formattedRemaining: String {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        guard state != .running else { return }
        if remaining <= 0 {
            remaining = duration(for: currentMode)
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
        remaining = duration(for: currentMode)
        state = .idle
        notificationManager.cancelPending()
    }

    func stop() {
        cancelTimer()
        remaining = duration(for: .focus)
        currentMode = .focus
        state = .idle
        notificationManager.cancelPending()
    }

    func duration(for mode: Mode) -> Int {
        max(1, durationSeconds[mode] ?? 60)
    }

    func updateDuration(for mode: Mode, seconds: Int) {
        let clamped = max(1, seconds)
        durationSeconds[mode] = clamped
        if mode == currentMode && state == .idle {
            remaining = clamped
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
            beginBreakSession()
        } else {
            currentMode = .focus
            remaining = duration(for: .focus)
            state = .idle
        }
    }

    private func cancelTimer() {
        timer?.setEventHandler {}
        timer?.cancel()
        timer = nil
    }

    private func beginBreakSession() {
        currentMode = .breakTime
        remaining = duration(for: .breakTime)
        state = .idle
        start()
    }
}
