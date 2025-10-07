<table width="100%" cellspacing="0" cellpadding="20">
  <tr>
    <td bgcolor="#2E3230">
      <h1 align="center"><font color="#FFF6E8">PenguinTomato ⏱️🐧</font></h1>
      <p><font color="#FFF6E8">PenguinTomato is a macOS Pomodoro-style focus timer that pairs structured work/break cycles with an ever-encouraging waddle of penguins. It is built with SwiftUI and ships as a menu bar companion app, keeping your focus sessions lighthearted but productive.</font></p>
      <p align="center"><img src="Sources/PenguinTomato/Resources/focussed_penguin.png" alt="Focus penguin" width="220"></p>

      <h2><font color="#FFF6E8">Features</font></h2>
      <ul>
        <li><font color="#FFF6E8">Customizable focus and break durations with immediate validation feedback.</font></li>
        <li><font color="#FFF6E8">Automatic transitions between focus and break phases so you stay in flow.</font></li>
        <li><font color="#FFF6E8">Menu bar timer and status icons that mirror the in-app state.</font></li>
        <li><font color="#FFF6E8">Delightful penguin illustrations and celebratory sounds when sessions complete.</font></li>
        <li><font color="#FFF6E8">Local notifications to remind you when it is time to switch gears.</font></li>
      </ul>

      <h2><font color="#FFF6E8">Requirements</font></h2>
      <ul>
        <li><font color="#FFF6E8">macOS 14 Sonoma or newer.</font></li>
        <li><font color="#FFF6E8">Xcode 15 or newer (for building and signing the app bundle).</font></li>
        <li><font color="#FFF6E8">Swift 5.9 toolchain (bundled with Xcode 15).</font></li>
      </ul>

      <h2><font color="#FFF6E8">Building the App</font></h2>
      <ol>
        <li><font color="#FFF6E8">Open the project as an SPM-based workspace by running <code>open Package.swift</code> in Finder or Xcode.</font></li>
        <li><font color="#FFF6E8">Select the "PenguinTomato" scheme and your preferred "My Mac" destination.</font></li>
        <li><font color="#FFF6E8">Build and run (<code>Command + R</code>) to launch the app with live previews of the timers and penguin artwork.</font></li>
        <li><font color="#FFF6E8">Grant notification permission on first launch to receive completion alerts.</font></li>
      </ol>

      <h2><font color="#FFF6E8">Running Tests</font></h2>
      <ul>
        <li><font color="#FFF6E8">Execute the unit test suite from the command line with <code>swift test</code>.</font></li>
        <li><font color="#FFF6E8">Or run the <code>PenguinTomatoTests</code> scheme inside Xcode for integrated reporting.</font></li>
      </ul>
      <p><font color="#FFF6E8">The tests focus on <code>TimerModel</code>, ensuring session transitions, clamping logic, and menu bar messaging behave consistently across machines.</font></p>

      <h2><font color="#FFF6E8">Assets</font></h2>
      <p><font color="#FFF6E8">The penguin illustrations and sound live under <code>Sources/PenguinTomato/Resources/</code>. They are referenced directly by the Swift Package, so there is no need to copy or relocate them when building or distributing the app.</font></p>
      <ul>
        <li><font color="#FFF6E8"><code>focussed_penguin.png</code> — focus session badge.</font></li>
        <li><font color="#FFF6E8"><code>break_penguin.png</code> — break-time mascot.</font></li>
        <li><font color="#FFF6E8"><code>pause_penguin.png</code> — pause state artwork.</font></li>
        <li><font color="#FFF6E8"><code>sleeping_penguin.png</code> — idle indicator.</font></li>
        <li><font color="#FFF6E8"><code>emperor_penguin_trumpet.mp3</code> — celebratory completion jingle.</font></li>
      </ul>

      <h2><font color="#FFF6E8">Distributing to Friends</font></h2>
      <ol>
        <li><font color="#FFF6E8">Archive the app from Xcode (<code>Product &gt; Archive</code>) using a Developer ID certificate.</font></li>
        <li><font color="#FFF6E8">Notarize the resulting build (<code>xcrun notarytool submit --wait</code>).</font></li>
        <li><font color="#FFF6E8">Staple the notarization ticket (<code>xcrun stapler staple PenguinTomato.app</code>).</font></li>
        <li><font color="#FFF6E8">Share the signed <code>.app</code> or <code>.dmg</code>; recipients on other Macs can open it without Gatekeeper warnings.</font></li>
      </ol>
      <p><font color="#FFF6E8">If you prefer TestFlight-style distribution, create a Swift package release or host the notarized build on a trusted file share.</font></p>

      <h2><font color="#FFF6E8">Contributing</font></h2>
      <p><font color="#FFF6E8">Questions, feature ideas, or penguin art contributions are welcome! Fork the repository, create a branch, and submit a pull request with a clear description and screenshots where relevant.</font></p>

      <h2><font color="#FFF6E8">License</font></h2>
      <p><font color="#FFF6E8">This project currently has no explicit license. Please treat it as all rights reserved until a license is added.</font></p>
    </td>
  </tr>
</table>
