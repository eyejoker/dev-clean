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
  echo "Schedule automatic cleanup? (macOS launchd)"
  echo "  1) daily   — every day at 3:00 AM"
  echo "  2) weekly  — every Sunday at 3:00 AM (recommended)"
  echo "  3) monthly — 1st of each month at 3:00 AM"
  echo "  4) skip"
  echo ""
  read -rp "Choose [1-4]: " schedule_choice

  CALENDAR_INTERVAL=""
  SCHEDULE_DESC=""
  case "${schedule_choice:-4}" in
    1)
      CALENDAR_INTERVAL="    <key>Hour</key>
    <integer>3</integer>
    <key>Minute</key>
    <integer>0</integer>"
      SCHEDULE_DESC="every day at 3:00 AM"
      ;;
    2)
      CALENDAR_INTERVAL="    <key>Weekday</key>
    <integer>0</integer>
    <key>Hour</key>
    <integer>3</integer>
    <key>Minute</key>
    <integer>0</integer>"
      SCHEDULE_DESC="every Sunday at 3:00 AM"
      ;;
    3)
      CALENDAR_INTERVAL="    <key>Day</key>
    <integer>1</integer>
    <key>Hour</key>
    <integer>3</integer>
    <key>Minute</key>
    <integer>0</integer>"
      SCHEDULE_DESC="1st of each month at 3:00 AM"
      ;;
    *)
      CALENDAR_INTERVAL=""
      ;;
  esac

  if [[ -n "$CALENDAR_INTERVAL" ]]; then
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
    <string>--run</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
${CALENDAR_INTERVAL}
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
    echo "Scheduled: $SCHEDULE_DESC"
    echo "Plist: $PLIST_FILE"
    echo "Uninstall: dev-clean uninstall"
  fi
fi

echo ""
echo "Done! Run 'dev-clean' to preview, 'dev-clean --run' to clean."
echo ""
