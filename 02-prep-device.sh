#!/usr/bin/env bash
# Tahap 2: ambil data dari Pixel 8 (shiba) yang dibutuhkan port ini
# Jalankan dari ROOT WORKSPACE (base kernel), bukan dari dalam devices/shiba.
set -euo pipefail

echo "== Persiapan device Pixel 8 (shiba) =="

if [ ! -f "devices/shiba/device.conf" ] || [ ! -f "Makefile" ]; then
  echo "ERROR: jalankan script ini dari ROOT WORKSPACE base kernel, bukan dari dalam devices/shiba."
  echo "Belum punya workspace-nya? Jalankan dulu: ./00-setup-workspace.sh"
  exit 1
fi

cat <<'EOF'
Pastikan dulu:
  - Settings > Developer options > OEM unlocking AKTIF
  - Sudah jalankan: fastboot flashing unlock
    (PERINGATAN: ini WIPE semua data di HP)
EOF
read -r -p "Sudah unlock bootloader? (y/n) " ans
if [ "$ans" != "y" ]; then
  echo "Unlock dulu bootloader-nya sebelum lanjut."
  exit 1
fi

echo
echo "-- Ambil info boot phone (butuh adb root: userdebug build atau Magisk) --"
devices/shiba/pull-boot-info.sh

mkdir -p devices/shiba/prebuilt
cp devices/shiba/boot-info/fdt.dtb devices/shiba/prebuilt/device-tree.dtb
echo "fdt.dtb disalin ke devices/shiba/prebuilt/device-tree.dtb"

echo
echo "-- Regenerate alamat SoC dari fdt.dtb phone kamu --"
devices/shiba/soc/zuma-addrs.py devices/shiba/boot-info/fdt.dtb

echo
echo "Cek manual yang disarankan README (tidak otomatis di sini):"
echo "  - bandingkan devices/shiba/boot-info/fdt.dtb dengan"
echo "    devices/shiba/u-boot/files/dts/upstream/src/arm64/exynos/google/zuma-shiba.dts"
echo "    (terutama blok memory@ dan /reserved-memory)"
echo "  - cek devices/shiba/u-boot/boot-image: header version 4, kernel LZ4, dan avb_footer"
echo "    harus cocok 'fastboot getvar partition-size:boot_a'"

echo
read -r -p "Ambil firmware vendor sekarang (butuh root)? (y/n) " fw
if [ "$fw" = "y" ]; then
  devices/shiba/pull-firmware.sh
fi

echo
read -r -p "Mau ambil kalibrasi haptic juga (opsional, butuh root)? (y/n) " hap
if [ "$hap" = "y" ]; then
  cat <<'EOF'
Jalankan manual di root shell HP:
  cat /sys/bus/i2c/devices/*-0043/calibration/{f0_stored,redc_stored}

Lalu tambahkan hasilnya ke command line boot nanti (file hakios-shiba.env atau
FIRST_ARGS saat build), contoh:
  haptic_f0=0x... haptic_redc=0x...
EOF
fi

echo
echo "== Tahap 2 selesai. Lanjut: 03-build.sh =="