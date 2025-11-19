// Copyright © 2025 Will Perl
// Licensed under the MIT License

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var measurementOverlay: MeasurementOverlay?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarIcon()
        preventAppFromAppearingInDock()
    }

    private func setupMenuBarIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureStatusItemButton()
        configureStatusItemMenu()
    }

    private func configureStatusItemButton() {
        if let button = statusItem?.button {
            button.image = createMenuBarIcon()
        }
    }

    private func createMenuBarIcon() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()
        drawRulerIcon()
        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private func drawRulerIcon() {
        drawLeftVertical()
        drawLeftDiagonal()
        drawRightDiagonal()
        drawRightVertical()
    }

    private func drawLeftVertical() {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 2, y: 10))
        path.line(to: NSPoint(x: 2, y: 3))
        path.lineWidth = 3
        path.lineCapStyle = .round
        NSColor.black.setStroke()
        path.stroke()
    }

    private func drawLeftDiagonal() {
        let startX: CGFloat = 3.5
        let startY: CGFloat = 15
        let endX: CGFloat = 8
        let endY: CGFloat = 4

        let shrinkFactor: CGFloat = 0.15
        let newStartX = startX + (endX - startX) * shrinkFactor
        let newStartY = startY + (endY - startY) * shrinkFactor
        let newEndX = endX - (endX - startX) * shrinkFactor
        let newEndY = endY - (endY - startY) * shrinkFactor

        let topPointShift: CGFloat = 0.35
        let finalEndY = newEndY + (startY - endY) * topPointShift

        let path = NSBezierPath()
        path.move(to: NSPoint(x: newStartX, y: newStartY))
        path.line(to: NSPoint(x: newEndX, y: finalEndY))
        path.lineWidth = 3
        path.lineCapStyle = .round
        NSColor.black.setStroke()
        path.stroke()
    }

    private func drawRightDiagonal() {
        let startX: CGFloat = 10
        let startY: CGFloat = 4
        let endX: CGFloat = 14.5
        let endY: CGFloat = 15

        let shrinkFactor: CGFloat = 0.15
        let newStartX = startX + (endX - startX) * shrinkFactor
        let newStartY = startY + (endY - startY) * shrinkFactor
        let newEndX = endX - (endX - startX) * shrinkFactor
        let newEndY = endY - (endY - startY) * shrinkFactor

        let topPointShift: CGFloat = 0.35
        let finalStartY = newStartY + (endY - startY) * topPointShift

        let path = NSBezierPath()
        path.move(to: NSPoint(x: newStartX, y: finalStartY))
        path.line(to: NSPoint(x: newEndX, y: newEndY))
        path.lineWidth = 3
        path.lineCapStyle = .round
        NSColor.black.setStroke()
        path.stroke()
    }

    private func drawRightVertical() {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 16, y: 10))
        path.line(to: NSPoint(x: 16, y: 3))
        path.lineWidth = 3
        path.lineCapStyle = .round
        NSColor.black.setStroke()
        path.stroke()
    }

    private func configureStatusItemMenu() {
        let menu = NSMenu()
        menu.addItem(createMeasureMenuItem())
        menu.addItem(NSMenuItem.separator())
        menu.addItem(createQuitMenuItem())
        statusItem?.menu = menu
    }

    private func createMeasureMenuItem() -> NSMenuItem {
        let item = NSMenuItem(
            title: AppConstants.menuItemMeasure,
            action: #selector(startMeasuring),
            keyEquivalent: ""
        )
        item.target = self
        return item
    }

    private func createQuitMenuItem() -> NSMenuItem {
        let item = NSMenuItem(
            title: AppConstants.menuItemQuit,
            action: #selector(quitApp),
            keyEquivalent: ""
        )
        item.target = self
        return item
    }

    @objc private func startMeasuring() {
        createAndShowOverlay()
    }

    private func createAndShowOverlay() {
        measurementOverlay = MeasurementOverlay(onClose: { [weak self] in
            self?.measurementOverlay = nil
        })
        NSApp.activate(ignoringOtherApps: true)
        measurementOverlay?.makeKeyAndOrderFront(nil)
        measurementOverlay?.makeFirstResponder(measurementOverlay?.contentView)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private func preventAppFromAppearingInDock() {
        NSApp.setActivationPolicy(.accessory)
    }
}
