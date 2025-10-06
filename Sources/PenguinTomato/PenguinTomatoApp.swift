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
            HStack(spacing: 6) {
                menuBarIcon
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                Text(model.menuBarLabel)
            }
        }
        .menuBarExtraStyle(.window)
    }
}

private extension PenguinTomatoApp {
    var menuBarIcon: Image {
        let name = model.menuBarIconName
        if let image = Bundle.module.image(forResource: name) {
            return Image(nsImage: image)
        }
        return Image(systemName: "timer")
    }
}
