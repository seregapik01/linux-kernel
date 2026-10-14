#!/usr/bin/env bash
# Install a GitHub Actions-built kernel into a Debian VM (UTM).
#
# 1. Download the kernel-debs-* artifact from Actions and unpack it.
# 2. Move the .deb files into the VM (UTM shared folder / scp).
# 3. Inside the VM:  sudo ./vm-install.sh
#
# The script installs linux-image-*.deb (initramfs and grub are updated
# automatically via the /etc/kernel/postinst.d hooks), then optionally
# linux-headers-*.deb.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root: sudo $0" >&2
    exit 1
fi

shopt -s nullglob
images=(linux-image-*.deb)
if [ ${#images[@]} -eq 0 ]; then
    echo "No linux-image-*.deb found in $(pwd)." >&2
    echo "Download the kernel-debs-* artifact from GitHub Actions and unpack it here." >&2
    exit 1
fi

for deb in "${images[@]}"; do
    echo ">>> dpkg -i $deb"
    dpkg -i "$deb"
done

# headers are only needed to build external modules — install them if present
for deb in linux-headers-*.deb; do
    echo ">>> dpkg -i $deb"
    dpkg -i "$deb" || echo "!! headers failed to install (not critical)" >&2
done

REL="$(ls /lib/modules 2>/dev/null | sort -V | tail -1)"
echo
echo "Kernels in /boot:"
ls -1 /boot/vmlinuz-* 2>/dev/null | sed 's|/boot/vmlinuz-|  - |'
echo
echo ">>> update-grub (newest kernel: $REL)"
update-grub
echo
echo "Done. 'sudo reboot' — grub will boot the newest kernel ($REL)."
echo "Verify after boot: uname -r"
echo "Rollback: pick the old kernel under 'Advanced options for Debian GNU/Linux'."
