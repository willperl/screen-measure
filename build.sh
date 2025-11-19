#!/bin/bash

set -e

APP_NAME="ScreenMeasure"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building $APP_NAME..."

# Clean previous build
rm -rf "$BUILD_DIR"

# Create app bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compile Swift sources
echo "Compiling Swift sources..."
swiftc -O \
    -framework AppKit \
    -o "$MACOS_DIR/$APP_NAME" \
    Sources/*.swift

# Copy Info.plist
cp Info.plist "$CONTENTS_DIR/"

# Copy app icon if it exists
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns "$RESOURCES_DIR/"
    echo "App icon copied"
fi

echo "Build complete! App bundle created at: $APP_DIR"
echo ""
echo "To run the app:"
echo "  open $APP_DIR"
