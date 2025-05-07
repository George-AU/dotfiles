#!/bin/bash

# Exit on any error
set -e

# Helper functions
check_package() {
    sudo pacman -Qi "$1" &> /dev/null
    return $?
}

check_aur_package() {
    yay -Qi "$1" &> /dev/null
    return $?
}

print_section() {
    echo "====================================="
    echo "$1"
    echo "====================================="
}

# System preparation
print_section "System Preparation"
echo "Unblocking wireless devices..."
sudo rfkill unblock 1
sudo rfkill unblock 3

# System update
print_section "System Update"
echo "Updating system and installing base packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git nano

# Install AUR helper if not present
print_section "AUR Helper Setup"
if ! check_package "yay"; then
    echo "Installing yay AUR helper..."
    cd ~
    mkdir -p git
    cd ~/git
    git clone https://aur.archlinux.org/yay-git.git
    cd yay-git
    makepkg -si --noconfirm
else
    echo "AUR helper (yay) is already installed"
fi

# Hyprland and dependencies
print_section "Installing Hyprland Environment"
if ! check_aur_package "hyprland-git"; then
    echo "Installing Hyprland..."
    yay -S --noconfirm hyprland-git
else
    echo "Hyprland is already installed"
fi

echo "Installing Hyprland dependencies..."
sudo pacman -S --needed --noconfirm \
    polkit-gnome \
    xdg-desktop-portal-hyprland \
    qt5-wayland \
    qt6-wayland \
    wayland-protocols \
    hyprlock \
    waybar \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    rofi-wayland \
    git \
    fastfetch \
    kitty \
    ghostty

# Install additional AUR packages
print_section "Installing Additional AUR Packages"
echo "Installing AUR packages..."
yay -S --needed --noconfirm \
    brave-bin \
    nerd-fonts-fira-code \
    nordic-darker-standard-buttons-theme \
    nordic-darker-theme \
    nordic-kde-git \
    nordic-theme \
    plymouth-git \
    ttf-meslo

print_section "Installation Complete!"
