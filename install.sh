#!/usr/bin/env bash
set -euo pipefail

# Agent Hub installer
# Usage: curl -fsSL https://agent-hub.dev/install.sh | sh

REPO="limai-io/agent-hub-releases"
INSTALL_DIR="$HOME/.agent-hub/bin"

# Detect platform
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
  darwin) PLATFORM="darwin" ;;
  linux)  PLATFORM="linux" ;;
  *)
    echo "Error: Unsupported OS: $OS"
    exit 1
    ;;
esac

case "$ARCH" in
  x86_64|amd64) ARCH="x64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *)
    echo "Error: Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

BINARY="agent-hub-${PLATFORM}-${ARCH}"
echo "Detected platform: ${PLATFORM}-${ARCH}"

# Get latest release URL
DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${BINARY}"
echo "Downloading from: ${DOWNLOAD_URL}"

# Download
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

if command -v curl &>/dev/null; then
  curl -fsSL "$DOWNLOAD_URL" -o "$TMPFILE"
elif command -v wget &>/dev/null; then
  wget -qO "$TMPFILE" "$DOWNLOAD_URL"
else
  echo "Error: curl or wget is required"
  exit 1
fi

# Install
mkdir -p "$INSTALL_DIR"
mv "$TMPFILE" "${INSTALL_DIR}/agent-hub"
chmod +x "${INSTALL_DIR}/agent-hub"

# Add to PATH if not already there
SHELL_NAME="$(basename "$SHELL")"
case "$SHELL_NAME" in
  zsh)  RC_FILE="$HOME/.zshrc" ;;
  bash) RC_FILE="$HOME/.bashrc" ;;
  *)    RC_FILE="$HOME/.profile" ;;
esac

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo "export PATH=\"\$HOME/.agent-hub/bin:\$PATH\"" >> "$RC_FILE"
  echo "Added $INSTALL_DIR to PATH in $RC_FILE"
fi

echo ""
echo "agent-hub installed to ${INSTALL_DIR}/agent-hub"
echo ""
echo "Run 'source ${RC_FILE}' or open a new terminal, then:"
echo "  agent-hub login"
echo ""
