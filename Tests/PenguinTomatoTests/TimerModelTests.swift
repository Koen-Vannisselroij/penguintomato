import XCTest
@testable import PenguinTomato

@MainActor
final class TimerModelTests: XCTestCase {

    func testInitialState() {
        let model = TimerModel()
        defer { model.stop() }

        XCTAssertEqual(model.state, .idle)
        XCTAssertEqual(model.currentMode, .focus)
        XCTAssertEqual(model.remaining, 25 * 60)
        XCTAssertEqual(model.menuBarLabel, "Idle")
        XCTAssertEqual(model.menuBarIconName, "MenuBarIdle")
    }

    func testStartAndPause() {
        let model = TimerModel()
        defer { model.stop() }

        model.start()
        XCTAssertEqual(model.state, .running)
        XCTAssertEqual(model.menuBarIconName, "MenuBarFocus")

        model.pause()
        XCTAssertEqual(model.state, .paused)
        XCTAssertEqual(model.menuBarLabel, "Paused")
    }

    func testStopResetsToFocus() {
        let model = TimerModel()
        defer { model.stop() }

        model.updateDuration(for: .focus, seconds: 90)
        model.start()
        model.stop()

        XCTAssertEqual(model.state, .idle)
        XCTAssertEqual(model.currentMode, .focus)
        XCTAssertEqual(model.remaining, 90)
        XCTAssertEqual(model.menuBarLabel, "Idle")
    }

    func testUpdateDurationAdjustsIdleRemaining() {
        let model = TimerModel()
        defer { model.stop() }

        model.updateDuration(for: .focus, seconds: 120)
        XCTAssertEqual(model.remaining, 120)

        model.updateDuration(for: .breakTime, seconds: 180)
        XCTAssertEqual(model.duration(for: .breakTime), 180)
        XCTAssertEqual(model.remaining, 120)
    }

    func testDurationClampToMinimum() {
        let model = TimerModel()
        defer { model.stop() }

        model.updateDuration(for: .focus, seconds: 0)
        XCTAssertEqual(model.duration(for: .focus), 1)
    }

    func testFocusCompletionStartsBreak() async throws {
        let model = TimerModel()
        defer { model.stop() }

        model.updateDuration(for: .focus, seconds: 1)
        model.updateDuration(for: .breakTime, seconds: 1)

        model.start()

        try await Task.sleep(nanoseconds: 1_300_000_000)

        XCTAssertEqual(model.currentMode, .breakTime)
        XCTAssertEqual(model.state, .running)
        XCTAssertEqual(model.menuBarIconName, "MenuBarBreak")
    }

    func testBreakCompletionReturnsToFocus() async throws {
        let model = TimerModel()
        defer { model.stop() }

        model.updateDuration(for: .focus, seconds: 1)
        model.updateDuration(for: .breakTime, seconds: 1)

        model.start()

        try await Task.sleep(nanoseconds: 2_600_000_000)

        XCTAssertEqual(model.currentMode, .focus)
        XCTAssertEqual(model.state, .idle)
        XCTAssertEqual(model.cyclesCompleted, 1)
        XCTAssertEqual(model.menuBarLabel, "Idle")
    }

    func testResetKeepsCurrentMode() {
        let model = TimerModel()
        defer { model.stop() }

        model.updateDuration(for: .focus, seconds: 1)
        model.start()
        model.reset()

        XCTAssertEqual(model.currentMode, .focus)
        XCTAssertEqual(model.state, .idle)
        XCTAssertEqual(model.remaining, model.duration(for: .focus))
    }
}
