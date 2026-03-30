#!/bin/bash

username="$(logname)"

# Ensure we run from the repo root (sed edits local files before deploy)
cd "$(dirname "$0")"

# Check for sudo
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with sudo."
  exit 1
fi

# Check if nvidia-inst is installed
# If it is, do the Nvidia stuff
if pacman -Qq nvidia-inst 2>/dev/null | grep -q .; then
  echo "Adding a custom desktop file for Nvidia sessions..."
  mkdir -p /usr/share/wayland-sessions
  cat <<EOF >/usr/share/wayland-sessions/hyprland-nvidia.desktop
[Desktop Entry]
Name=Hyprland-Nvidia
Comment=Hyprland with Nvidia
Exec=start-hyprland -- --unsupported-gpu
Type=Application
EOF
  echo "Adding dracut config for early module loading..."
  cat <<EOF >/etc/dracut.conf.d/nvidia-modules.conf
force_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
EOF
  echo "Regenerating initrds..."
  reinstall-kernels || dracut-rebuild
fi

# Install the custom package list
echo "Installing needed packages..."
pacman -S --noconfirm --noprogressbar --needed --disable-download-timeout $(<packages-repository.txt)

# Allow user to run pacman without password (needed for yay inside sudo)
echo "${username} ALL=(ALL) NOPASSWD: /usr/bin/pacman" > /etc/sudoers.d/yay-temp

# Install AUR packages (yay must not run as root)
echo "Installing AUR packages..."
sudo -u "${username}" yay -S --noconfirm --noprogressbar --needed --disable-download-timeout $(<packages-repository-aur.txt)

# Remove temporary sudoers rule
rm -f /etc/sudoers.d/yay-temp

# Hide uwsm-managed session (uwsm not installed)
rm -f /usr/share/wayland-sessions/hyprland-uwsm.desktop

# Deploy user configs
echo "Deploying user configs..."
rsync -a .config "/home/${username}/"
rsync -a .local "/home/${username}/"
# Restore user ownership
chown -R "${username}:${username}" "/home/${username}"

# Deploy system configs
echo "Deploying system configs..."
rsync -a --chown=root:root etc/ /etc/

# Check if the script is running in a virtual machine
if systemd-detect-virt | grep -vq "none"; then
  echo "Virtual machine detected; enabling software rendering workarounds..."
  # Greeter: uncomment software rendering variables in ReGreet config
  sed -i '/^#WLR_RENDERER_ALLOW_SOFTWARE/s/^#//' /etc/greetd/regreet.toml
  sed -i '/^#WLR_NO_HARDWARE_CURSORS/s/^#//' /etc/greetd/regreet.toml
  # User session: add env vars to hyprland.conf for Aquamarine + wlroots compat
  cat <<'EOF' >> "/home/${username}/.config/hypr/hyprland.conf"

# VM workarounds (auto-added by installer)
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_NO_HARDWARE_CURSORS,1
env = AQ_NO_ATOMIC,1
env = LIBGL_ALWAYS_SOFTWARE,1
EOF
fi

# Enable services
echo "Enabling services..."
systemctl -f enable greetd.service
systemctl enable bluetooth.service

echo "Installation complete."
