#!/bin/bash

# Configuration: List of folders to sync from ~/.config to ~/dotfiles
CONFIG_FOLDERS=("hypr" "waybar")

# Paths
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/dotfiles"

# Function to display usage
usage() {
    echo "Usage: $0 {backup|restore}"
    echo "  backup: Copy specified folders from ~/.config to ~/dotfiles"
    echo "  restore: Copy specified folders from ~/dotfiles to ~/.config"
    exit 1
}

# Check if an argument is provided
if [ $# -ne 1 ]; then
    usage
fi

# Create dotfiles directory if it doesn't exist
mkdir -p "$DOTFILES_DIR"

# Backup function: Copy from .config to dotfiles
backup() {
    echo "Backing up configuration folders to $DOTFILES_DIR..."
    for folder in "${CONFIG_FOLDERS[@]}"; do
        if [ -d "$CONFIG_DIR/$folder" ]; then
            echo "Copying $folder..."
            cp -r "$CONFIG_DIR/$folder" "$DOTFILES_DIR/"
        else
            echo "Warning: $folder not found in $CONFIG_DIR, skipping..."
        fi
    done
    echo "Backup complete!"
}

# Restore function: Copy from dotfiles to .config
restore() {
    echo "Restoring configuration folders to $CONFIG_DIR..."
    for folder in "${CONFIG_FOLDERS[@]}"; do
        if [ -d "$DOTFILES_DIR/$folder" ]; then
            echo "Restoring $folder..."
            cp -r "$DOTFILES_DIR/$folder" "$CONFIG_DIR/"
        else
            echo "Warning: $folder not found in $DOTFILES_DIR, skipping..."
        fi
    done
    echo "Restore complete!"
}

# Main logic
case "$1" in
    backup)
        backup
        ;;
    restore)
        restore
        ;;
    *)
        usage
        ;;
esac
