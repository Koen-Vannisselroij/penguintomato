# PenguinTomato 🐧

PenguinTomato is a macOS Pomodoro-style focus timer that pairs structured work/break cycles with an ever-encouraging waddle of penguins. Built with SwiftUI, it lives in your menu bar and keeps sessions lighthearted but productive.

<p align="center">
  <img src="Sources/PenguinTomato/Assets.xcassets/FocusPenguin.imageset/FocusPenguin.png" alt="Focus penguin" width="260" />
</p>

## Features
<ul style="list-style:none;padding-left:0;">
  <li style="display:flex;align-items:center;margin-bottom:14px;">
    <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarFocus.imageset/MenuBarFocus.png" alt="Focus icon" width="44" style="margin-right:16px;" />
    <span>Customizable focus and break durations with immediate validation feedback.</span>
  </li>
  <li style="display:flex;align-items:center;margin-bottom:14px;">
    <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarBreak.imageset/MenuBarBreak.png" alt="Break icon" width="44" style="margin-right:16px;" />
    <span>Automatic transitions between focus and break phases so you stay in flow.</span>
  </li>
  <li style="display:flex;align-items:center;margin-bottom:14px;">
    <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarPaused.imageset/MenuBarPaused.png" alt="Pause icon" width="44" style="margin-right:16px;" />
    <span>Delightful penguin illustrations and celebratory sounds when sessions complete.</span>
  </li>
  <li style="display:flex;align-items:center;">
    <img src="Sources/PenguinTomato/Assets.xcassets/SleepingPenguin.imageset/SleepingPenguin.png" alt="Notification icon" width="44" style="margin-right:16px;" />
    <span>Menu bar timer and status icons that mirror the in-app state.</span>
  </li>
</ul>

## Requirements
<ul style="list-style:none;padding-left:0;">
  <li style="display:flex;align-items:center;margin-bottom:12px;">
    <img src="Sources/PenguinTomato/Resources/focussed_penguin.png" alt="Focus penguin" width="48" style="margin-right:16px;" />
    <span>macOS 14 Sonoma or newer.</span>
  </li>
  <li style="display:flex;align-items:center;margin-bottom:12px;">
    <img src="Sources/PenguinTomato/Resources/break_penguin.png" alt="Break penguin" width="48" style="margin-right:16px;" />
    <span>Xcode 15 or newer (for building and signing the app bundle).</span>
  </li>
  <li style="display:flex;align-items:center;">
    <img src="Sources/PenguinTomato/Resources/pause_penguin.png" alt="Pause penguin" width="48" style="margin-right:16px;" />
    <span>Swift 5.9 toolchain (bundled with Xcode 15).</span>
  </li>
</ul>

## Building the App
1. Open the project as an SPM-based workspace by running `open Package.swift` in Finder or Xcode.
2. Select the "PenguinTomato" scheme and your preferred "My Mac" destination.
3. Build and run (`Command + R`) to launch the app with live previews of the timers and penguin artwork.
4. Grant notification permission on first launch to receive completion alerts.

## Running Tests
<ul style="list-style:none;padding-left:0;">
  <li style="display:flex;align-items:center;margin-bottom:12px;">
    <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarFocus.imageset/MenuBarFocus.png" alt="Focus icon" width="40" style="margin-right:16px;" />
    <span>Execute the unit test suite from the command line with <code>swift test</code>.</span>
  </li>
  <li style="display:flex;align-items:center;">
    <img src="Sources/PenguinTomato/Assets.xcassets/MenuBarBreak.imageset/MenuBarBreak.png" alt="Break icon" width="40" style="margin-right:16px;" />
    <span>Or run the <code>PenguinTomatoTests</code> scheme inside Xcode for integrated reporting.</span>
  </li>
</ul>

The tests focus on `TimerModel`, ensuring session transitions, clamping logic, and menu bar messaging behave consistently across machines.

## Assets
<ul style="list-style:none;padding-left:0;">
  <li style="display:flex;align-items:flex-start;margin-bottom:12px;">
    <span>The penguin illustrations and sound live under `Sources/PenguinTomato/Resources/`. They are referenced directly by the Swift Package, so there is no need to copy or relocate them when building or distributing the app.</span>
  </li>
  <li style="display:flex;align-items:center;margin-bottom:12px;">
    <img src="Sources/PenguinTomato/Resources/focussed_penguin.png" alt="Focus penguin" width="48" style="margin-right:16px;" />
    <span>`focussed_penguin.png` — focus session badge.</span>
  </li>
  <li style="display:flex;align-items:center;margin-bottom:12px;">
    <img src="Sources/PenguinTomato/Resources/break_penguin.png" alt="Break penguin" width="48" style="margin-right:16px;" />
    <span>`break_penguin.png` — break-time mascot.</span>
  </li>
  <li style="display:flex;align-items:center;margin-bottom:12px;">
    <img src="Sources/PenguinTomato/Resources/pause_penguin.png" alt="Pause penguin" width="48" style="margin-right:16px;" />
    <span>`pause_penguin.png` — pause state artwork.</span>
  </li>
  <li style="display:flex;align-items:center;margin-bottom:12px;">
    <img src="Sources/PenguinTomato/Resources/sleeping_penguin.png" alt="Sleeping penguin" width="48" style="margin-right:16px;" />
    <span>`sleeping_penguin.png` — idle indicator.</span>
  </li>
  <li style="display:flex;align-items:center;">
    <img src="Sources/PenguinTomato/Resources/penguin_icon.png" alt="Penguin icon" width="48" style="margin-right:16px;" />
    <span>`emperor_penguin_trumpet.mp3` — celebratory completion jingle.</span>
  </li>
</ul>
