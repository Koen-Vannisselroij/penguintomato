import SwiftUI

@main
struct PenguinTomatoApp: App {
    @StateObject private var model = TimerModel()

    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(model)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } label: {
            Text(model.menuBarLabel)
        }
        .menuBarExtraStyle(.window)
    }
}
