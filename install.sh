#!/usr/bin/env bash

set -e

echo "========================================="
echo "      Waybar Red Papiro Installer"
echo "========================================="
echo

if ! command -v pacman >/dev/null; then
    echo "This installer currently supports Arch-based distributions only."
    exit 1
fi

packages=(
    hyprland
    waybar
    rofi
    swaync
    kitty
    networkmanager
    glib2
    wl-clipboard
    brightnessctl
    playerctl
    pavucontrol
    wireplumber
    btop
)

missing=()

echo "Checking dependencies..."

for pkg in "${packages[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
        missing+=("$pkg")
    fi
done

echo

if ((${#missing[@]} != 0)); then
    echo "The following packages are missing:"
    printf "  • %s\n" "${missing[@]}"
    echo

    read -rp "Install them now? [Y/n] " ans

    if [[ ! $ans =~ ^[Nn]$ ]]; then
        sudo pacman -S --needed "${missing[@]}"
    else
        echo
        echo "Installation cancelled."
        exit 1
    fi
else
    echo "All required packages are already installed."
fi

echo

mkdir -p "$HOME/.config"

if [[ -d "$HOME/.config/waybar" ]]; then
    echo "Backing up existing Waybar configuration..."
    rm -rf "$HOME/.config/waybar.backup"
    mv "$HOME/.config/waybar" "$HOME/.config/waybar.backup"
fi

if [[ -d "$HOME/.config/rofi" ]]; then
    echo "Backing up existing Rofi configuration..."
    rm -rf "$HOME/.config/rofi.backup"
    mv "$HOME/.config/rofi" "$HOME/.config/rofi.backup"
fi

echo

echo "Installing Waybar..."

cp -r waybar "$HOME/.config/"
cp -r rofi "$HOME/.config/"

echo

echo "========================================="
echo " Installation completed successfully!"
echo "========================================="
echo
echo "Notes:"
echo " • Install the fonts if you haven't already:"
echo
echo "   sudo pacman -S --needed ttf-jetbrains-mono-nerd noto-fonts-cjk"
echo
echo " • Restart Waybar:"
echo
echo "   pkill waybar && waybar &"
echo
