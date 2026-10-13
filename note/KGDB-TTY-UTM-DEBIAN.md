1. Settings for UTM image
```bash
# UTM → settings VM → Ports/Serial
# Mode: Connect server TCP (TCP Server)
# Target:  Automatic serial device
# Host:  127.0.0.1
# Port:  4444
# Wait connect: off
```
2. Check serial 
```bash
cat /proc/tty/driver/serial
```
3. Check kgdb in kernel
```bash
grep -E 'CONFIG_KGDB|CONFIG_KGDB_SERIAL_CONSOLE|CONFIG_KGDB_KDB|CONFIG_DEBUG_INFO|CONFIG_RANDOMIZE_BASE' /boot/config-$(uname -r)
```
need->
```bash
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
CONFIG_KGDB_KDB=y
```

4. Install gdb
```bash
brew install gdb
```

opt. Check TCP connect without GDB
```bash
# On macOS
nc -v 127.0.0.1 4444
# Debian
stty -F /dev/ttyS0 115200 raw -echo -crtscts
printf 'hello\n' > /dev/ttyS0

```