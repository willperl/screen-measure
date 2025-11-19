// Copyright © 2025 Will Perl
// Licensed under the MIT License

import AppKit

struct MeasurementLine {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let color: NSColor

    var distance: CGFloat {
        calculateDistance()
    }

    private func calculateDistance() -> CGFloat {
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        return sqrt(dx * dx + dy * dy)
    }

    var midPoint: CGPoint {
        calculateMidPoint()
    }

    private func calculateMidPoint() -> CGPoint {
        CGPoint(
            x: (startPoint.x + endPoint.x) / 2,
            y: (startPoint.y + endPoint.y) / 2
        )
    }
}
