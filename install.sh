#!/bin/bash
# dev-clean installer
# Usage: curl -fsSL https://raw.githubusercontent.com/eyejoker/dev-clean/main/install.sh | bash

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="dev-clean"
REPO_URL="https://raw.githubusercontent.com/eyejoker/dev-clean/main/dev-clean"

echo ""
echo "=== Installing dev-clean ==="
echo ""

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download or copy script
if [[ -f "$SCRIPT_NAME" ]]; then
  cp "$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
  echo "Copied from local file."
else
  curl -fsSL "$REPO_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"
  echo "Downloaded from GitHub."
fi

chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
echo "Installed to $INSTALL_DIR/$SCRIPT_NAME"

# Check if install dir is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo ""
  echo "WARNING: $INSTALL_DIR is not in your PATH."
  echo "Add this to your shell profile (~/.zshrc or ~/.bashrc):"
  echo ""
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
fi

# macOS launchd scheduling (optional)
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo ""
  read -rp "Install weekly launchd schedule? (y/N) " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    PLIST_DIR="$HOME/Library/LaunchAgents"
    PLIST_FILE="$PLIST_DIR/com.eyejoker.dev-clean.plist"
    mkdir -p "$PLIST_DIR"

    cat > "$PLIST_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.eyejoker.dev-clean</string>
  <key>ProgramArguments</key>
  <array>
    <string>${INSTALL_DIR}/${SCRIPT_NAME}</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Weekday</key>
    <integer>0</integer>
    <key>Hour</key>
    <integer>3</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>${HOME}/.local/share/dev-clean/last-run.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/.local/share/dev-clean/last-run.log</string>
</dict>
</plist>
PLIST

    mkdir -p "$HOME/.local/share/dev-clean"
    launchctl bootout "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST_FILE"
    echo "Scheduled: every Sunday at 3:00 AM"
    echo "Plist: $PLIST_FILE"
  fi
fi

echo ""
echo "Done! Run 'dev-clean --dry-run' to preview."
echo ""
