#!/usr/bin/env bash
username="$1"

# Clone the repo
echo "Cloning the EOS Community Hyprland repo..."
git clone https://github.com/joaommartins/endeavouros-hyprland.git hyprland

# Check if nvidia-inst is installed
# If it is, do the Nvidia stuff
if pacman -Qq nvidia-inst 2>/dev/null | grep -q .; then
    echo "Adding the --unsupported-gpu flag to the hyprland call in greetd.conf..."
    sed -i 's|sway -c|hyprland -c|' hyprland/etc/greetd/greetd.conf
    echo "Adding a custom desktop file for Nvidia sessions..."
    mkdir -p /usr/share/wayland-sessions
    cat <<EOF > /usr/share/wayland-sessions/hyprland-nvidia.desktop
[Desktop Entry]
Name=Hyprland-Nvidia
Comment=Hyprland with Nvidia
Exec=hyprland --unsupported-gpu
Type=Application
EOF
    echo "Adding dracut config for early module loading..."
    cat <<EOF > /etc/dracut.conf.d/nvidia-modules.conf
force_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
EOF
    echo "Regenerating initrds..."
    reinstall-kernels || dracut-rebuild
fi

# Install the custom package list
echo "Installing needed packages..."
pacman -S --noconfirm --noprogressbar --needed --disable-download-timeout $(< ./hyprland/packages-repository.txt)

mapfile -t pkgs < <(grep -v '^\s*#' hyprland/packages-repository-aur.txt | sed '/^\s*$/d')
if [ ${#pkgs[@]} -gt 0 ]; then
  sudo -u "$username" yay -S --noconfirm --needed "${pkgs[@]}"
fi

# Deploy user configs
echo "Deploying user configs..."
rsync -a hyprland/.config "/home/${username}/"
rsync -a hyprland/.local "/home/${username}/"
rsync -a hyprland/home_config/ "/home/${username}/"
# Restore user ownership
chown -R "${username}:${username}" "/home/${username}"

# Deploy system configs
echo "Deploying system configs..."
rsync -a --chown=root:root hyprland/etc/ /etc/

# Check if the script is running in a virtual machine
if systemd-detect-virt | grep -vq "none"; then
  echo "Virtual machine detected; enabling WLR_RENDERER_ALLOW_SOFTWARE variable in ReGreet config..."
  # Uncomment WLR_RENDERER_ALLOW_SOFTWARE variable in ReGreet config
  sed -i '/^#WLR_RENDERER_ALLOW_SOFTWARE/s/^#//' /etc/greetd/regreet.toml
fi

# Remove the repo
echo "Removing the EOS Community Hyprland repo..."
rm -rf hyprland

# Enable the Greetd service
echo "Enabling the Greetd service..."
systemctl enable greetd.service

echo "Installation complete."
