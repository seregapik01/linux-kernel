# Kernel build runner (GitHub Actions → .deb → UTM)

Builds an **x86_64** kernel on GitHub Actions and ships ready-to-install
`.deb` packages as artifacts. Your laptop takes no part in the build.

## Workflow

1. Push the `ci/kernel-build-runner` branch to GitHub.
2. GitHub → **Actions** → **kernel-build-runner** → **Run workflow**.
3. Fill in the inputs:

   | Input | Meaning | Default |
   |---|---|---|
   | `kernel_version` | kernel version from kernel.org | `7.0.3` |
   | `localversion` | suffix in `uname -r` | `-gha` |
   | `config_flags` | your CONFIG flags on top of `runner/kernel-base.config` | empty |
   | `upload_vmlinux` | also upload `vmlinux` (needed for KGDB/gdb on the host) | `false` |
   | `retention_days` | artifact retention, days | `14` |

4. When the build is green, download the
   `kernel-debs-<version><suffix>-amd64` artifact from the run page.
5. Move the `.deb` files into the VM (UTM shared folder or scp) and run
   [vm-install.sh](vm-install.sh).

## `config_flags` examples

One `KEY=VALUE` per line. Values: `y`, `m`, `n`, or a string/number.

```text
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
CONFIG_KGDB_KDB=y
CONFIG_RANDOMIZE_BASE=n
```

`RANDOMIZE_BASE=n` (KASLR off) — so that gdb addresses match the symbols.
The final values of all requested flags are shown in the run **Summary** —
check that kconfig dependencies did not override your flag (`=m` where you
asked for `=y`, and so on).

## Installing into the VM

```bash
# inside Debian (UTM), in the folder with the unpacked .deb files
sudo ./vm-install.sh
sudo reboot
uname -r   # should show 7.0.3-gha (or your suffix)
```

`dpkg -i` triggers the Debian hooks itself: `update-initramfs` and
`update-grub`. The old `6.1.0-50-amd64` kernel stays in the grub menu, so
you can roll back at any time via **Advanced options for Debian GNU/Linux**
→ the old kernel.

## Notes

- Base config: [kernel-base.config](kernel-base.config) (a copy of
  `HW_01_build_kernel/.config`). Edit it or override with flags to change it.
- The `-dbg` package is not built (the `nokerneldbg` profile) — saves
  ~30 minutes and gigabytes. Debug symbols remain in the kernel itself
  (`DEBUG_INFO=y`).
- Each build with a **new** `localversion` (`-gha2`, `-gha3`, ...) is
  installed in the VM next to the old one — handy for comparing. The same
  suffix simply overwrites the previous build via `dpkg -i`.
- The first build on a free runner (4 vCPU) takes about 60–120 minutes;
  later runs with a warm ccache are much faster. Actions are free and
  unlimited for **public** repositories; private ones consume minutes
  (2000/month on the free plan).
- The `vmlinux` artifact is needed when debugging over KGDB from the host:
  `zstd -d vmlinux-*.zst`, then in gdb `file vmlinux` + `target remote`.
