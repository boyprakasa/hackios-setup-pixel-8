#!/usr/bin/env bash
# Tahap 0: siapkan STRUKTUR workspace yang benar.
#
# hackios-devices-shiba BUKAN repo yang berdiri sendiri -- ia harus jadi
# subfolder devices/shiba/ di dalam clone base kernel (Martinvlba/hakios-xnu-kernel,
# fork dari oosexgang/hakios-xnu-kernel). Semua `make` dan `tools/hakios-device.py`
# dijalankan dari root base kernel ini, BUKAN dari dalam devices/shiba.
#
# Usage:
#   ./00-setup-workspace.sh [WORKSPACE_DIR] [EXISTING_SHIBA_CLONE_DIR]
#
# WORKSPACE_DIR           : ke mana base kernel di-clone (default: ~/Projects/Pixel/hakios)
# EXISTING_SHIBA_CLONE_DIR: kalau kamu SUDAH clone hackios-devices-shiba sebelumnya
#                           (mis. ~/Projects/Pixel/hackios-devices-shiba), script ini
#                           akan MEMINDAHKAN-nya ke devices/shiba, bukan clone ulang.
set -euo pipefail

BASE_KERNEL_URL="https://github.com/Martinvlba/hakios-xnu-kernel.git"
DEVICE_REPO_URL="https://github.com/3kierz/hackios-devices-shiba.git"

WORKSPACE="${1:-$HOME/Projects/Pixel/hakios}"
EXISTING_CLONE="${2:-}"

# Auto-deteksi clone lama kalau argumen ke-2 tidak dikasih
if [ -z "$EXISTING_CLONE" ] && [ -d "$HOME/Projects/Pixel/hackios-devices-shiba/.git" ]; then
  EXISTING_CLONE="$HOME/Projects/Pixel/hackios-devices-shiba"
fi

echo "== Menyiapkan workspace HakiOS =="
echo "Workspace (base kernel) : $WORKSPACE"
echo "Clone shiba yang dipakai: ${EXISTING_CLONE:-"(akan clone baru dari $DEVICE_REPO_URL)"}"
echo

if [ -d "$WORKSPACE/.git" ]; then
  echo "Base kernel sudah ada di $WORKSPACE, skip clone."
else
  echo "-- Clone base kernel (Martinvlba/hakios-xnu-kernel) --"
  git clone "$BASE_KERNEL_URL" "$WORKSPACE"
fi

cd "$WORKSPACE"

if [ ! -f "tools/hakios-device.py" ]; then
  echo "ERROR: tools/hakios-device.py tidak ditemukan di $WORKSPACE."
  echo "Cek lagi apakah BASE_KERNEL_URL benar / repo-nya masih ada."
  exit 1
fi

echo
echo "-- Sync device & UEFI resmi sesuai devices/manifest.conf (akita, uefi, dll) --"
tools/hakios-device.py sync || echo "Peringatan: sync sebagian/gagal -- tetap lanjut, shiba ditaruh manual di bawah."

echo
if [ -f "devices/shiba/device.conf" ]; then
  echo "devices/shiba sudah ada, skip."
elif [ -n "$EXISTING_CLONE" ] && [ -d "$EXISTING_CLONE" ]; then
  echo "-- Memindahkan clone lama ($EXISTING_CLONE) ke devices/shiba --"
  mkdir -p devices
  mv "$EXISTING_CLONE" devices/shiba
else
  echo "-- Clone hackios-devices-shiba langsung ke devices/shiba --"
  mkdir -p devices
  git clone "$DEVICE_REPO_URL" devices/shiba
fi

echo
echo "-- Verifikasi --"
if [ -f "devices/shiba/device.conf" ] && [ -f "Makefile" ]; then
  echo "OK: workspace valid."
  echo "  Base kernel : $WORKSPACE"
  echo "  Device shiba: $WORKSPACE/devices/shiba"
else
  echo "PERINGATAN: struktur belum lengkap, cek manual Makefile & devices/shiba/device.conf"
fi

echo
echo "== PENTING ================================================="
echo "Mulai sekarang, jalankan SEMUA script lain (01-04) dari dalam:"
echo "  $WORKSPACE"
echo "BUKAN dari dalam $WORKSPACE/devices/shiba"
echo "=============================================================="