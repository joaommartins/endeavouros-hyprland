# Hyprland Setup for EndeavourOS

**EndeavourOS Community Edition — Hyprland**

[![Maintenance](https://img.shields.io/maintenance/yes/2026.svg)]()

A complete Hyprland desktop environment for EndeavourOS, including login screen, audio, bluetooth, screen sharing, and sensible default keybindings.

## Installation

### With the EOS Installer

1. In the live environment, choose "Fetch your install customization file" from the Welcome app.
2. Paste the URL for the customisation script:
```
https://raw.githubusercontent.com/joaommartins/endeavouros-hyprland/main/setup_hyprland_isomode.bash
```
3. Click <kbd>OK</kbd>, then start the installer and proceed with an **online** installation. Choose **"no desktop"** on the DE selection screen.

### Post-Installation

```bash
git clone https://github.com/joaommartins/endeavouros-hyprland.git
cd endeavouros-hyprland
sudo ./hyprland-install.sh
```

## What's Included

| Category | Components |
|---|---|
| Window manager | Hyprland, hyprpaper (wallpaper), hypridle (idle), hyprlock (lock screen) |
| Desktop shell | noctalia-shell (status bar, widgets — built on quickshell) |
| Login | greetd + ReGreet |
| Terminal | foot |
| Editor | helix |
| Launcher | HyprLauncher (Super+Space) |
| File manager | Thunar |
| Notifications | mako |
| Audio | PipeWire (via EndeavourOS base + pipewire-audio), pamixer |
| Bluetooth | bluez (EndeavourOS base) + blueman |
| Screenshots | hyprshot / grim + slurp |
| Clipboard | cliphist + wl-clipboard + fuzzel (Super+V) |
| Screen sharing | xdg-desktop-portal-hyprland + PipeWire |
| Brightness | brightnessctl |
| Media keys | playerctl |

## Default Keybindings

| Key | Action |
|---|---|
| Super + Return | Terminal (foot) |
| Super + Space | App launcher |
| Super + Q | Close window |
| Super + F | Toggle floating |
| Super + M | Fullscreen |
| Super + L | Lock screen |
| Super + V | Clipboard history |
| Super + 1-0 | Switch workspace 1–10 |
| Super + Shift + 1-0 | Move window to workspace |
| Super + Arrow keys | Move focus |
| Super + Mouse drag | Move / resize window |
| Print | Screenshot (selection) |
| Shift + Print | Screenshot (full display) |
| Ctrl + Print | Screenshot (window) |
| Volume / Brightness / Media keys | Work out of the box |

## Post-Install Configuration

- Monitor settings: edit `~/.config/hypr/hyprland.conf` (defaults to auto-detect)
- Keyboard layout: configure in the `input` section of `hyprland.conf`
- Wallpaper: edit `~/.config/hypr/hyprpaper.conf`
- Idle/lock timeouts: edit `~/.config/hypr/hypridle.conf` (default: lock 5min, display off 10min, suspend 30min)

## Virtual Machine Notes

The installer auto-detects VMs and enables software rendering workarounds automatically.
