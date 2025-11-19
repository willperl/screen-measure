# ScreenMeasure

A lightweight native macOS menu bar application for measuring pixel distances on your screen.

## Features

- **Menu Bar Integration** - Lives in your menu bar, always accessible
- **Precise Measurements** - Click and drag to measure distances in pixels
- **Multiple Lines** - Draw multiple measurement lines that persist on screen
- **Color-Coded Lines** - Each line cycles through bright colors (cyan, red, green, orange, magenta)
- **Axis Snapping** - Hold SHIFT while dragging to snap to horizontal or vertical lines
- **Smart Labels** - Distance labels automatically position to avoid overlapping with lines
- **Visual Feedback** - Colored cursor dot shows where your next line will start
- **Clean Exit** - Press ESC to clear all measurements and return to normal use

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9 or later (for building from source)

## Installation

### Option 1: Download Pre-built App
1. Go to [Releases](../../releases)
2. Download `ScreenMeasure.app` from the latest release
3. Unzip and drag to your Applications folder
4. Run the app (you may need to right-click → Open the first time)

### Option 2: Build from Source
1. Clone this repository
2. Open Terminal and navigate to the project directory
3. Run the build script:
   ```bash
   ./build.sh
   ```
4. The built app will be in `build/ScreenMeasure.app`
5. Drag it to your Applications folder or run directly

## Usage

1. **Launch** - Run ScreenMeasure.app (it appears in your menu bar as an "M" icon)
2. **Start Measuring** - Click the menu bar icon and select "Measure"
3. **Draw Lines** - Click and drag to draw measurement lines
   - Hold SHIFT to snap to horizontal or vertical
   - Each new line uses a different color
4. **Exit** - Press ESC to clear all lines and exit measurement mode
5. **Quit** - Click the menu bar icon and select "Quit" to close the app

## Technical Details

- **Framework**: Native AppKit
- **Language**: Swift
- **Architecture**: Menu bar app (LSUIElement, no dock icon)
- **Drawing**: NSBezierPath with transparent overlay window
- **Event Handling**: Local event monitors for mouse and keyboard input

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

Will Perl

---

**Note**: This app requires accessibility permissions to capture mouse and keyboard events during measurement mode.
