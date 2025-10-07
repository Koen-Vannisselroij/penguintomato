import AppKit
import Foundation

extension Bundle {
    /// Loads an image by name from either compiled resources or the raw .xcassets structure.
    func penguinImage(named name: String) -> NSImage? {
        if let compiled = image(forResource: name) {
            return compiled
        }

        // Fallback: load the PNG from the asset catalog directory structure included in the bundle.
        if let url = url(forResource: name, withExtension: "png", subdirectory: "Assets.xcassets/\(name).imageset"),
           let image = NSImage(contentsOf: url) {
            return image
        }

        return nil
    }
}
