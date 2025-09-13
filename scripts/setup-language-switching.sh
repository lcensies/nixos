#!/run/current-system/sw/bin/bash

# Script to set up Russian/English language switching in GNOME
# Run this script after logging into GNOME

echo "Setting up Russian/English language switching..."

# Set input sources using gsettings
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"
gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'us'), ('xkb', 'ru')]"
gsettings set org.gnome.desktop.input-sources xkb-options "['grp:alt_shift_toggle']"

echo "Language switching configured!"
echo "You can now use Shift+Alt to switch between English and Russian"
echo "The language indicator should appear in the top panel"

# Restart GNOME Shell to apply changes
echo "Restarting GNOME Shell..."
killall -SIGUSR1 gnome-shell

echo "Setup complete!"
