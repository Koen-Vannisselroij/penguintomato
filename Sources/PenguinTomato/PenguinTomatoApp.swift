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
            HStack(spacing: 8) {
                menuBarIcon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                Text(model.menuBarLabel)
            }
            .foregroundColor(.primary)
        }
        .menuBarExtraStyle(.window)
    }
}

private extension PenguinTomatoApp {
    var menuBarIcon: Image {
        let name = model.menuBarIconName
        if let nsImage = Bundle.module.image(forResource: name) {
            nsImage.isTemplate = true
            nsImage.size = NSSize(width: 22, height: 22)
            return Image(nsImage: nsImage)
        }
        return Image(systemName: "timer")
            .renderingMode(.template)
    }
}
