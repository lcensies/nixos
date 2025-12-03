#!/usr/bin/env bash
# Script to enable Forge extension in GNOME Shell
# This is a workaround for session crashes that occur when Forge is enabled by default

echo "Enabling Forge extension..."

# Enable Forge extension
gsettings set org.gnome.shell enabled-extensions "['searchlight@icedman.github.com', 'forge@jmmaranan.com']"

# Enable Forge settings
gsettings set org.gnome.shell.extensions.forge enabled true

echo "Forge extension enabled successfully!"
echo "You may need to restart GNOME Shell or log out and back in for changes to take effect."
echo ""
echo "To restart GNOME Shell, press Alt+F2, type 'r', and press Enter"
echo "Or log out and back in to your session."

