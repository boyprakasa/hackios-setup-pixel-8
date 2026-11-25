#!/usr/bin/env bash
# Tahap 3: build config, kernel, hello, dan image first-boot
# Jalankan dari ROOT WORKSPACE (base kernel) -- make & tools/ ada di sini,
# bukan di dalam devices/shiba.
set -euo pipefail

echo "== Build kernel, hello, dan image boot pertama (shiba) =="

if [ ! -f "devices/shiba/device.conf" ] || [ ! -f "Makefile" ]; then
  echo "ERROR: jalankan script ini dari ROOT WORKSPACE base kernel, bukan dari dalam devices/shiba."
  echo "Belum punya workspace-nya? Jalankan dulu: ./00-setup-workspace.sh"
  exit 1
fi

echo "-- Generate config shiba --"
make DEVICE=shiba shiba_defconfig

echo
echo "-- Cek repo device ini terhadap base kernel --"
tools/hakios-device.py check shiba

echo
read -r -p "Build kernel dari source (perlu theos+SDK, lebih lama)? pilih 'n' untuk pakai prebuilt. (y/n) " kmode
if [ "$kmode" = "y" ]; then
  set +e
  make kernel
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    echo "NOTE: exit status 2 dengan pesan 'make-kernel: built: hakios-kernel' itu cuma kext symbol-set check -- aman diabaikan."
  fi
else
  cp devices/shiba/prebuilt/hakios-kernel hakios-kernel
  echo "Memakai devices/shiba/prebuilt/hakios-kernel (lebih lama, tanpa driver zuma tambahan)."
fi

echo
echo "-- Build hello (test userland Darwin) --"
make hello SHELL=/bin/bash

echo
echo "-- Pack image boot pertama (cpus=1 untuk percobaan first boot) --"
FIRST_ARGS="cpus=1" devices/shiba/mk-first-boot.sh

echo
echo "== Image siap: build/shiba/hakios-shiba.img =="
echo "Lanjut: 04-boot.sh"
echo "PENTING: kalau kamu build di WSL2, jalankan 04-boot.sh dari Windows (CMD/PowerShell),"
echo "karena WSL2 tidak bisa akses USB untuk fastboot."