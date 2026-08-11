#!/bin/bash
set -e

echo "🔨 Building Gwen for macOS (Apple Silicon M4)..."

export DEVELOPER_DIR="/Library/Developer/CommandLineTools"

# 1. Compile Swift executable
swift build -c release

# 2. Bundle into Gwen.app
APP_DIR="build/Gwen.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Copy binary
cp ".build/release/Gwen" "$MACOS_DIR/Gwen"

# Create Info.plist
cat <<EOF > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Gwen</string>
    <key>CFBundleIdentifier</key>
    <string>com.antigravity.gwen</string>
    <key>CFBundleName</key>
    <string>Gwen</string>
    <key>CFBundleDisplayName</key>
    <string>Gwen Eye Health Assistant</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSCameraUsageDescription</key>
    <string>Gwen uses the front camera strictly on-device via M4 Neural Engine to monitor blink frequency and ergonomic posture. No images or videos are saved or transmitted.</string>
</dict>
</plist>
EOF

chmod +x "$MACOS_DIR/Gwen"

echo "✅ Gwen.app built successfully at: $APP_DIR"

# 3. Install to Applications for Spotlight launch
USER_APPS="$HOME/Applications"
mkdir -p "$USER_APPS"
rm -rf "$USER_APPS/Gwen.app"
cp -R "$APP_DIR" "$USER_APPS/Gwen.app"

echo "🚀 Installed Gwen to $USER_APPS/Gwen.app for Spotlight indexing!"

