#!/usr/bin/env bash
# Установка ядра, собранного в GitHub Actions, в Debian-VM (UTM).
#
# 1. Скачай артефакт kernel-debs-* из Actions и распакуй в папку.
# 2. Перекинь .deb в VM (общая папка UTM / scp).
# 3. В VM:  sudo ./vm-install.sh
#
# Скрипт ставит linux-image-*.deb (initramfs и grub обновятся сами,
# через хуки /etc/kernel/postinst.d), затем опционально linux-headers-*.deb.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Запусти через sudo: sudo $0" >&2
    exit 1
fi

shopt -s nullglob
images=(linux-image-*.deb)
if [ ${#images[@]} -eq 0 ]; then
    echo "Нет linux-image-*.deb в $(pwd)." >&2
    echo "Скачай артефакт kernel-debs-* из GitHub Actions и распакуй сюда." >&2
    exit 1
fi

for deb in "${images[@]}"; do
    echo ">>> dpkg -i $deb"
    dpkg -i "$deb"
done

# headers нужны только для сборки внешних модулей — ставим, если лежат рядом
for deb in linux-headers-*.deb; do
    echo ">>> dpkg -i $deb"
    dpkg -i "$deb" || echo "!! headers не установились (не критично)" >&2
done

REL="$(ls /lib/modules 2>/dev/null | sort -V | tail -1)"
echo
echo "Ядра в /boot:"
ls -1 /boot/vmlinuz-* 2>/dev/null | sed 's|/boot/vmlinuz-|  - |'
echo
echo ">>> update-grub (свежее ядро: $REL)"
update-grub
echo
echo "Готово. 'sudo reboot' — grub загрузит самое новое ядро ($REL)."
echo "Проверка после загрузки: uname -r"
echo "Откат: в меню 'Advanced options for Debian GNU/Linux' выбери старое ядро."
