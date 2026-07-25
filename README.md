# Waybar-red-papiro
A Waybar for those who wants a waybar + rofi red style.
I created this Waybar configuration to include integrated Rofi-based menus for others who might want the same thing.
I am new to Arch Linux—as of July 24, 2026, I have been using it for just one year—though I have been studying it in all my spare time. I hope you like it; improvements and suggestions are welcome.

## Supported languages

- English
- Español

## Required packages

- Hyprland
- Waybar
- Rofi
- Sway Notification Center (swaync)
- Kitty
- NetworkManager (includes `nmcli`)
- GLib2 (includes `gdbus`)
- wl-clipboard
- brightnessctl
- playerctl
- pavucontrol
- wireplumber
- btop

## Fonts

```bash
sudo pacman -S --needed \
    ttf-jetbrains-mono-nerd \
    noto-fonts-cjk
```

## Optional

- Steam
- Vesktop (recommended instead of Discord. The default module is configured for Vesktop, but you can easily modify `~/.config/waybar/config.jsonc`.)

## Installation

```bash
git clone https://github.com/LeviathanG9/Waybar-red-papiro.git
cd Waybar-red-papiro
chmod +x install.sh
./install.sh
```
