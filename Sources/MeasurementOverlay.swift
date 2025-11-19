// Copyright © 2025 Will Perl
// Licensed under the MIT License

import AppKit

class MeasurementOverlay: NSWindow {
    private var lines: [MeasurementLine] = []
    private var currentStartPoint: CGPoint?
    private var currentEndPoint: CGPoint?
    private var currentRawEndPoint: CGPoint?
    private var currentColorIndex = 0
    private let overlayView: OverlayView
    private var eventMonitors: [Any] = []
    private let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        let screenFrame = NSScreen.main?.frame ?? .zero
        self.overlayView = OverlayView()
        self.onClose = onClose

        super.init(
            contentRect: screenFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        setupWindow()
        setupEventMonitoring()
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    private func setupWindow() {
        level = NSWindow.Level(rawValue: AppConstants.Window.overlayLevel)
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        contentView = overlayView
    }

    private func setupEventMonitoring() {
        addMouseDownMonitor()
        addMouseDraggedMonitor()
        addMouseUpMonitor()
        addMouseMovedMonitor()
        addKeyDownMonitor()
        addFlagsChangedMonitor()
        NSCursor.hide()
    }

    private func addMouseDownMonitor() {
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            self?.handleMouseDown(event)
            return nil
        }
        if let monitor = monitor {
            eventMonitors.append(monitor)
        }
    }

    private func addMouseDraggedMonitor() {
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDragged) { [weak self] event in
            self?.handleMouseDragged(event)
            return nil
        }
        if let monitor = monitor {
            eventMonitors.append(monitor)
        }
    }

    private func addMouseUpMonitor() {
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { [weak self] event in
            self?.handleMouseUp(event)
            return nil
        }
        if let monitor = monitor {
            eventMonitors.append(monitor)
        }
    }

    private func addMouseMovedMonitor() {
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.handleMouseMoved(event)
            return event
        }
        if let monitor = monitor {
            eventMonitors.append(monitor)
        }
    }

    private func addKeyDownMonitor() {
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyDown(event)
            return nil
        }
        if let monitor = monitor {
            eventMonitors.append(monitor)
        }
    }

    private func addFlagsChangedMonitor() {
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
            return event
        }
        if let monitor = monitor {
            eventMonitors.append(monitor)
        }
    }

    private func removeAllEventMonitors() {
        for monitor in eventMonitors {
            NSEvent.removeMonitor(monitor)
        }
        eventMonitors.removeAll()
    }

    private func handleMouseDown(_ event: NSEvent) {
        let location = getMouseLocationInView()
        currentStartPoint = location
        currentEndPoint = location
        overlayView.mousePosition = location
        updateOverlay()
    }

    private func handleMouseDragged(_ event: NSEvent) {
        guard let start = currentStartPoint else { return }
        let location = getMouseLocationInView()
        currentRawEndPoint = location
        let endPoint = shouldSnapToAxis(event) ? snapToAxis(from: start, to: location) : location
        currentEndPoint = endPoint

        let dx = endPoint.x - start.x
        let dy = endPoint.y - start.y
        let distance = sqrt(dx * dx + dy * dy)

        if distance >= 5 {
            overlayView.mousePosition = nil
        } else {
            overlayView.mousePosition = start
        }

        updateOverlay()
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        guard let start = currentStartPoint, let raw = currentRawEndPoint else { return }
        currentEndPoint = shouldSnapToAxis(event) ? snapToAxis(from: start, to: raw) : raw
        updateOverlay()
    }

    private func shouldSnapToAxis(_ event: NSEvent) -> Bool {
        return event.modifierFlags.contains(.shift)
    }

    private func snapToAxis(from start: CGPoint, to end: CGPoint) -> CGPoint {
        let dx = abs(end.x - start.x)
        let dy = abs(end.y - start.y)
        return dx > dy ? CGPoint(x: end.x, y: start.y) : CGPoint(x: start.x, y: end.y)
    }

    private func handleMouseUp(_ event: NSEvent) {
        guard let start = currentStartPoint, let end = currentEndPoint else { return }
        let color = getCurrentColor()
        let line = MeasurementLine(startPoint: start, endPoint: end, color: color)
        lines.append(line)
        advanceColorIndex()
        currentStartPoint = nil
        currentEndPoint = nil
        overlayView.mousePosition = getMouseLocationInView()
        updateOverlay()
    }

    private func handleMouseMoved(_ event: NSEvent) {
        guard currentStartPoint == nil else { return }
        overlayView.mousePosition = getMouseLocationInView()
        overlayView.needsDisplay = true
    }

    private func handleKeyDown(_ event: NSEvent) {
        let escapeKeyCode: UInt16 = 53
        if event.keyCode == escapeKeyCode {
            exitMeasurementMode()
        }
    }

    private func getMouseLocationInView() -> CGPoint {
        let screenLocation = NSEvent.mouseLocation
        guard let view = contentView else { return screenLocation }
        return view.convert(screenLocation, from: nil)
    }

    private func getCurrentColor() -> NSColor {
        let colors = AppConstants.Measurement.lineColors
        return colors[currentColorIndex % colors.count]
    }

    private func advanceColorIndex() {
        currentColorIndex += 1
    }

    private func updateOverlay() {
        overlayView.lines = lines
        overlayView.currentLine = createCurrentLine()
        overlayView.currentColor = getCurrentColor()
        overlayView.needsDisplay = true
    }

    private func createCurrentLine() -> MeasurementLine? {
        guard let start = currentStartPoint, let end = currentEndPoint else {
            return nil
        }
        let color = getCurrentColor()
        return MeasurementLine(startPoint: start, endPoint: end, color: color)
    }

    private func exitMeasurementMode() {
        NSCursor.unhide()
        removeAllEventMonitors()
        orderOut(nil)
        scheduleCleanup()
    }

    private func scheduleCleanup() {
        DispatchQueue.main.async { [weak self] in
            self?.onClose()
        }
    }
}

class OverlayView: NSView {
    var lines: [MeasurementLine] = []
    var currentLine: MeasurementLine?
    var mousePosition: CGPoint?
    var currentColor: NSColor = .cyan

    override var isFlipped: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawEscapeNotification()
        drawAllLines()
        drawCurrentLine()
        drawMouseDot()
    }

    private func drawMouseDot() {
        guard let position = mousePosition else { return }
        let dotDiameter: CGFloat = 5.0
        let dotRect = CGRect(
            x: position.x - dotDiameter / 2,
            y: position.y - dotDiameter / 2,
            width: dotDiameter,
            height: dotDiameter
        )
        let dotPath = NSBezierPath(ovalIn: dotRect)
        currentColor.setFill()
        dotPath.fill()
    }

    private func drawEscapeNotification() {
        let text = AppConstants.Notification.escapeText
        let attributes = createNotificationAttributes()
        let textSize = text.size(withAttributes: attributes)
        let notificationRect = calculateNotificationRect(textSize: textSize)

        drawNotificationBackground(notificationRect)
        drawNotificationText(text, in: notificationRect, attributes: attributes)
    }

    private func createNotificationAttributes() -> [NSAttributedString.Key: Any] {
        let font = NSFont.systemFont(
            ofSize: AppConstants.Notification.notificationFontSize,
            weight: .semibold
        )
        return [
            .font: font,
            .foregroundColor: AppConstants.Notification.notificationTextColor
        ]
    }

    private func calculateNotificationRect(textSize: CGSize) -> CGRect {
        let padding = AppConstants.Notification.notificationPadding
        let topMargin = AppConstants.Notification.notificationTopMargin
        return CGRect(
            x: padding,
            y: topMargin,
            width: textSize.width + padding * 2,
            height: textSize.height + padding * 2
        )
    }

    private func drawNotificationBackground(_ rect: CGRect) {
        let path = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)
        AppConstants.Notification.notificationBackgroundColor.setFill()
        path.fill()
    }

    private func drawNotificationText(_ text: String, in rect: CGRect, attributes: [NSAttributedString.Key: Any]) {
        let padding = AppConstants.Notification.notificationPadding
        let textRect = CGRect(
            x: rect.origin.x + padding,
            y: rect.origin.y + padding,
            width: rect.width - padding * 2,
            height: rect.height - padding * 2
        )
        text.draw(in: textRect, withAttributes: attributes)
    }

    private func drawAllLines() {
        for line in lines {
            drawLine(line)
        }
    }

    private func drawCurrentLine() {
        if let line = currentLine {
            drawLine(line)
        }
    }

    private func drawLine(_ line: MeasurementLine) {
        drawLinePath(line)
        drawMeasurementLabel(line)
    }

    private func drawLinePath(_ line: MeasurementLine) {
        let path = NSBezierPath()
        path.move(to: line.startPoint)
        path.line(to: line.endPoint)
        path.lineWidth = AppConstants.Measurement.lineWidth
        line.color.setStroke()
        path.stroke()
    }

    private func drawMeasurementLabel(_ line: MeasurementLine) {
        guard line.distance >= 5 else { return }

        let pixels = Int(round(line.distance))
        let text = "\(pixels)\(AppConstants.Measurement.pixelsSuffix)"
        let attributes = createTextAttributes(color: line.color)
        let textSize = text.size(withAttributes: attributes)
        let labelRect = calculateLabelRect(for: line, textSize: textSize)

        drawLabelBackground(labelRect)
        drawLabelText(text, in: labelRect, attributes: attributes)
    }

    private func createTextAttributes(color: NSColor) -> [NSAttributedString.Key: Any] {
        let font = NSFont.systemFont(ofSize: AppConstants.Measurement.labelFontSize)
        return [
            .font: font,
            .foregroundColor: color
        ]
    }

    private func calculateLabelRect(for line: MeasurementLine, textSize: CGSize) -> CGRect {
        let padding = AppConstants.Measurement.labelPadding
        let labelHeight = textSize.height + padding * 2
        let labelWidth = textSize.width + padding * 2

        let dx = line.endPoint.x - line.startPoint.x
        let dy = line.endPoint.y - line.startPoint.y
        let length = sqrt(dx * dx + dy * dy)

        guard length > 0 else {
            return CGRect(
                x: line.midPoint.x - labelWidth / 2,
                y: line.midPoint.y - labelHeight / 2,
                width: labelWidth,
                height: labelHeight
            )
        }

        let perpX = -dy / length
        let perpY = dx / length

        let baseDimension = abs(perpX) * labelWidth / 2 + abs(perpY) * labelHeight / 2
        let margin: CGFloat = 8
        let offsetDistance = baseDimension + AppConstants.Measurement.lineWidth / 2 + margin

        let offsetX = perpX * offsetDistance
        let offsetY = perpY * offsetDistance

        return CGRect(
            x: line.midPoint.x + offsetX - labelWidth / 2,
            y: line.midPoint.y + offsetY - labelHeight / 2,
            width: labelWidth,
            height: labelHeight
        )
    }

    private func drawLabelBackground(_ rect: CGRect) {
        let backgroundPath = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        AppConstants.Measurement.labelBackgroundColor.setFill()
        backgroundPath.fill()
    }

    private func drawLabelText(_ text: String, in rect: CGRect, attributes: [NSAttributedString.Key: Any]) {
        let textRect = CGRect(
            x: rect.origin.x + AppConstants.Measurement.labelPadding,
            y: rect.origin.y + AppConstants.Measurement.labelPadding,
            width: rect.width - AppConstants.Measurement.labelPadding * 2,
            height: rect.height - AppConstants.Measurement.labelPadding * 2
        )
        text.draw(in: textRect, withAttributes: attributes)
    }
}
