// Copyright © 2025 Will Perl
// Licensed under the MIT License

import AppKit

enum AppConstants {
    static let appName = "ScreenMeasure"
    static let menuItemMeasure = "Measure"
    static let menuItemQuit = "Quit"

    enum Measurement {
        static let lineWidth: CGFloat = 3.0
        static let lineColors: [NSColor] = [
            .cyan,
            NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),
            NSColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 1.0),
            NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),
            NSColor(red: 1.0, green: 0.3, blue: 1.0, alpha: 1.0)
        ]
        static let labelFontSize: CGFloat = 14.0
        static let labelBackgroundColor = NSColor.black.withAlphaComponent(0.7)
        static let labelTextColor = NSColor.white
        static let labelPadding: CGFloat = 6.0
        static let pixelsSuffix = "px"
    }

    enum Notification {
        static let escapeText = "ESC to Stop"
        static let notificationFontSize: CGFloat = 16.0
        static let notificationPadding: CGFloat = 20.0
        static let notificationTopMargin: CGFloat = 50.0
        static let notificationBackgroundColor = NSColor.black.withAlphaComponent(0.5)
        static let notificationTextColor = NSColor.white
    }

    enum Window {
        static let overlayLevel = Int(CGWindowLevelForKey(.popUpMenuWindow))
    }
}
