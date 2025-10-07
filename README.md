# PenguinTomato 🐧

PenguinTomato is a macOS Pomodoro-style focus timer that pairs structured work/break cycles with an ever-encouraging waddle of penguins. Built with SwiftUI, it lives in your menu bar and keeps sessions lighthearted but productive.

<p align="center">
  <img src="Sources/PenguinTomato/Assets.xcassets/FocusPenguin.imageset/FocusPenguin.png" alt="Focus penguin" width="240" />
</p>

## Features
- <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarFocus.imageset/MenuBarFocus.png" alt="Focus icon" width="24" /> Customizable focus and break durations with immediate validation feedback.
- <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarBreak.imageset/MenuBarBreak.png" alt="Break icon" width="24" /> Automatic transitions between focus and break phases so you stay in flow.
- <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarIdle.imageset/MenuBarIdle.png" alt="Menu bar icon" width="24" /> Menu bar timer and status icons that mirror the in-app state.
- <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarPaused.imageset/MenuBarPaused.png" alt="Pause icon" width="24" /> Delightful penguin illustrations and celebratory sounds when sessions complete.
- <img src="Sources/PenguinTomato/Assets.xcassets/SleepingPenguin.imageset/SleepingPenguin.png" alt="Notification icon" width="24" /> Local notifications to remind you when it is time to switch gears.

## Requirements
- macOS 14 Sonoma or newer.
- Xcode 15 or newer (for building and signing the app bundle).
- Swift 5.9 toolchain (bundled with Xcode 15).

## Building the App
1. Open the project as an SPM-based workspace by running `open Package.swift` in Finder or Xcode.
2. Select the "PenguinTomato" scheme and your preferred "My Mac" destination.
3. Build and run (`Command + R`) to launch the app with live previews of the timers and penguin artwork.
4. Grant notification permission on first launch to receive completion alerts.

## Running Tests
- Execute the unit test suite from the command line with `swift test`.
- Or run the `PenguinTomatoTests` scheme inside Xcode for integrated reporting.

The tests focus on `TimerModel`, ensuring session transitions, clamping logic, and menu bar messaging behave consistently across machines.

## Assets
The penguin illustrations and sound live under `Sources/PenguinTomato/Resources/`. They are referenced directly by the Swift Package, so there is no need to copy or relocate them when building or distributing the app.

- `focussed_penguin.png` — focus session badge.
- `break_penguin.png` — break-time mascot.
- `pause_penguin.png` — pause state artwork.
- `sleeping_penguin.png` — idle indicator.
- `emperor_penguin_trumpet.mp3` — celebratory completion jingle.

## Distributing to Friends
1. Archive the app from Xcode (`Product > Archive`) using a Developer ID certificate.
2. Notarize the resulting build (`xcrun notarytool submit --wait`).
3. Staple the notarization ticket (`xcrun stapler staple PenguinTomato.app`).
4. Share the signed `.app` or `.dmg`; recipients on other Macs can open it without Gatekeeper warnings.

If you prefer TestFlight-style distribution, create a Swift package release or host the notarized build on a trusted file share.

## Contributing
Questions, feature ideas, or penguin art contributions are welcome! Fork the repository, create a branch, and submit a pull request with a clear description and screenshots where relevant.

## License
This project currently has no explicit license. Please treat it as all rights reserved until a license is added.
