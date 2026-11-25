#!/usr/bin/env bash
# Tahap 4: boot image via fastboot (RAM only, tidak di-flash)
set -euo pipefail

echo "== Boot image via fastboot (shiba) =="
echo "PERHATIAN: kalau proses build dilakukan di WSL2, JALANKAN SCRIPT INI DARI WINDOWS"
echo "(CMD/PowerShell dengan platform-tools Windows), karena WSL2 tidak bisa lihat device USB."
echo

if [ ! -f "build/shiba/hakios-shiba.img" ]; then
  echo "ERROR: build/shiba/hakios-shiba.img tidak ditemukan. Jalankan 03-build.sh dulu."
  exit 1
fi

echo "-- Reboot ke bootloader --"
adb reboot bootloader
sleep 3

echo "-- fastboot boot (hanya jalan di RAM, restart akan balik ke Android) --"
fastboot boot build/shiba/hakios-shiba.img

cat <<'EOF'

Perhatikan log serial/pstore untuk urutan berikut (lihat "Seen / Not seen" di README
kalau salah satu tidak muncul):

  1. Banner U-Boot
  2. "[oosexgang] watchdog 0x10060000: ... counting, stopped" lalu "kept as a net"
  3. "[oosexgang] display: DECON0 trigger unmasked"
  4. "[oosexgang] hakios: payload of ...", "loader of ..."
  5. "== XNULOADER v3 ==", "CurrentEL=2", "platform akita"
     (baris "platform akita" ini NORMAL juga untuk Pixel 8 -- itu nama platform
     loader untuk semua phone zuma)
  6. "jumping to ...", lalu baris-baris kernel
  7. "Hello from user space on Darwin!" lalu restart otomatis ke Android

Kalau macet di salah satu tahap, tarik log balik (root, di Android) dengan:
  devices/shiba/pull-log.sh
EOF

echo
echo "== Setelah hello berhasil, nyalakan fitur satu per satu =="
echo "(touchscreen=1, buttons=1, display_probe=1, pcie=5, haptic=1, amp=1, thermal=1)"
echo "Lihat CHECKLIST.md untuk daftar lengkap."