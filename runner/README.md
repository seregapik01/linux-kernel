# Kernel build runner (GitHub Actions → .deb → UTM)

Ядро **x86_64** собирается в GitHub Actions, артефактом отдаются готовые
`.deb` пакеты. Ноутбук в сборке не участвует.

## Поток

1. Запушь ветку `ci/kernel-build-runner` в GitHub.
2. GitHub → **Actions** → **kernel-build-runner** → **Run workflow**.
3. Заполни параметры:
   | Поле | Что делает | По умолчанию |
   |---|---|---|
   | `kernel_version` | версия ядра с kernel.org | `7.0.3` |
   | `localversion` | суффикс в `uname -r` | `-gha` |
   | `config_flags` | твои CONFIG-флаги поверх `runner/kernel-base.config` | пусто |
   | `upload_vmlinux` | приложить `vmlinux` (нужен для KGDB/gdb на хосте) | `false` |
   | `retention_days` | срок хранения артефакта | `14` |
4. По окончании (зелёный билд) скачай артефакт
   `kernel-debs-<версия><суффикс>-amd64` со страницы запуска.
5. Перекинь `.deb` в VM (общая папка UTM или scp) и запусти
   [vm-install.sh](vm-install.sh).

## Примеры `config_flags`

По одному `KEY=VALUE` на строку. Значения: `y`, `m`, `n` или строка/число.

```text
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
CONFIG_KGDB_KDB=y
CONFIG_RANDOMIZE_BASE=n
```

`RANDOMIZE_BASE=n` (KASLR off) — чтобы адреса в gdb совпадали с символами.
Итоговые значения всех запрошенных флагов видны в **Summary** запуска —
проверь, что флаг не «съели» зависимости (`=m` там, где просил `=y`, и т.п.).

## Установка в VM

```bash
# внутри Debian (UTM), в папке с распакованными .deb
sudo ./vm-install.sh
sudo reboot
uname -r   # должно показать 7.0.3-gha (или твой суффикс)
```

`dpkg -i` сам вызывает хуки: `update-initramfs` и `update-grub`.
Старое ядро `6.1.0-50-amd64` остаётся в меню grub → откат в любой момент:
**Advanced options for Debian GNU/Linux** → старое ядро.

## Нюансы

- Базовый конфиг: [kernel-base.config](kernel-base.config) (копия
  `HW_01_build_kernel/.config`). Хочешь другой — правь его или передай
  флагами.
- `-dbg` пакет не собирается (профиль `nokerneldbg`) — экономит ~30 минут
  и гигабайты. Отладочные символы в самом ядре остаются (`DEBUG_INFO=y`).
- Каждая сборка с **новым** `localversion` (`-gha2`, `-gha3`, ...) ставится
  в VM рядом со старой — удобно сравнивать. С тем же суффиксом `dpkg -i`
  просто перезапишет предыдущую.
- Первый билд на бесплатном раннере (4 vCPU) — примерно 60–120 минут,
  повторные с тёплым ccache-кэшем — заметно быстрее.
  В **public** репозитории Actions бесплатны и без лимита минут;
  в private лимитируется (2000 мин/мес на free-плане).
- `vmlinux` артефакт нужен, когда отлаживаешь через KGDB с хоста:
  `zstd -d vmlinux-*.zst`, затем в gdb `file vmlinux` + `target remote`.
