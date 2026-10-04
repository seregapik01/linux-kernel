#!/bin/bash
set -eu

MODULE=my_module
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARAM_DIR="/sys/module/${MODULE}/parameters"
TARGET="Hello, World!"

if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

make -C "$DIR" build

rmmod "${MODULE}" 2>/dev/null || true
insmod "$DIR/${MODULE}.ko"
trap 'rmmod "${MODULE}" 2>/dev/null || true' EXIT

i=0
while [[ $i -lt ${#TARGET} ]]; do
    code=$(printf '%d' "'${TARGET:$i:1}")
    echo "$i" > "${PARAM_DIR}/idx"
    echo "$code" > "${PARAM_DIR}/ch_val"
    i=$((i + 1))
done

fail=0

if [[ "$(cat "${PARAM_DIR}/my_str")" != "${TARGET}" ]]; then
    echo "FAIL: my_str"
    fail=1
else
    echo "PASS: my_str"
fi

if echo x > "${PARAM_DIR}/my_str" 2>/dev/null; then
    echo "FAIL: my_str writable"
    fail=1
else
    echo "PASS: my_str read-only"
fi

if dmesg | grep -qF "${MODULE}: init"; then
    echo "PASS: init"
else
    echo "FAIL: init"
    fail=1
fi

rmmod "${MODULE}"

if dmesg | grep -qF "${MODULE}: exit"; then
    echo "PASS: exit"
else
    echo "FAIL: exit"
    fail=1
fi

if [[ $fail -eq 0 ]]; then
    echo "ALL TESTS PASSED"
else
    echo "FAILED"
    exit 1
fi
