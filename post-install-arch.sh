#!/bin/bash

# Exit on any error
set -e

# Ensure script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" >&2
   exit 1
fi

# Unblock wireless devices
echo "Unblocking wireless devices..."
rfkill unblock 1
rfkill unblock 3

# Update system and install base development tools
echo "Updating system and installing base-devel, git, and nano..."
pacman -Syu --noconfirm
pacman -S --needed --noconfirm base-devel git nano

# Create git directory and clone yay-git from AUR
echo "Setting up yay AUR helper..."
cd ~
mkdir -p git
cd ~/git
git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg -si --noconfirm

# Install core packages
echo "Installing core packages: fastfetch, kitty..."
pacman -S --needed --noconfirm fastfetch kitty

# Install Hyprland (AUR) and related dependencies
echo "Installing Hyprland and dependencies..."
yay -S --noconfirm hyprland-git
pacman -S --needed --noconfirm polkit-gnome xdg-desktop-portal-hyprland qt5-wayland qt6-wayland wayland-protocols
pacman -S --needed --noconfirm hyprlock waybar ttf-jetbrains-mono ttf-jetbrains-mono-nerd
pacman -S --needed --noconfirm rofi-wayland git

echo "Installation complete! You can now configure Hyprland and other tools."
