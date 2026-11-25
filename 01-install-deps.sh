#!/usr/bin/env bash
# Tahap 1: siapkan toolchain build untuk HakiOS (idempotent -- aman dijalankan ulang)
# Jalankan dari ROOT WORKSPACE (base kernel), bukan dari dalam devices/shiba.
# Kalau belum ada workspace-nya, jalankan 00-setup-workspace.sh dulu.
set -euo pipefail

echo "== Instalasi dependency build HakiOS (Pixel 8 / shiba) =="

if [ ! -f "devices/shiba/device.conf" ] || [ ! -f "Makefile" ]; then
  echo "ERROR: jalankan script ini dari ROOT WORKSPACE base kernel"
  echo "(folder yang berisi Makefile dan devices/shiba/device.conf),"
  echo "bukan dari dalam devices/shiba itu sendiri."
  echo "Belum punya workspace-nya? Jalankan dulu: ./00-setup-workspace.sh"
  exit 1
fi

echo "-- Install package dasar (clang, lld, lz4, 7zip, toolchain aarch64, curl, git) --"
sudo apt update
sudo apt install -y clang lld lz4 p7zip-full gcc-aarch64-linux-gnu git curl

echo
echo "-- Sync & checkout PR hakios-uefi #2 (command 'hakios' U-Boot) --"
if [ -d "uefi" ]; then
  git -C uefi fetch origin pull/2/head:pr2
  git -C uefi checkout pr2
  echo "uefi/ sudah di branch pr2."
else
  echo "PERINGATAN: folder uefi/ belum ada (seharusnya hasil sync di 00-setup-workspace.sh)."
  echo "  Coba jalankan ulang: tools/hakios-device.py sync"
fi

echo
echo "-- theos + toolchain iOS (untuk build kernel dari source) --"
if [ -d "$HOME/theos" ]; then
  echo "theos sudah ada di $HOME/theos, skip instalasi."
else
  echo "theos belum ada, menjalankan installer resmi (bisa menanyakan beberapa pilihan SDK/toolchain)..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)" || \
    echo "PERINGATAN: installer theos gagal/dibatalkan -- cek manual di https://theos.dev/docs/installation-linux"
fi

echo
echo "-- Pastikan SDK iPhoneOS16.5 ada (sparse-clone dari theos/sdks kalau belum) --"
if [ -d "$HOME/theos/sdks/iPhoneOS16.5.sdk" ]; then
  echo "iPhoneOS16.5.sdk sudah ada, skip."
else
  TMP_SDK_DIR="$(mktemp -d)"
  if git clone --filter=blob:none --no-checkout --depth=1 https://github.com/theos/sdks.git "$TMP_SDK_DIR" 2>/dev/null; then
    (
      cd "$TMP_SDK_DIR"
      git sparse-checkout init --cone
      git sparse-checkout set iPhoneOS16.5.sdk
      git checkout
    )
    if [ -d "$TMP_SDK_DIR/iPhoneOS16.5.sdk" ]; then
      mkdir -p "$HOME/theos/sdks"
      cp -r "$TMP_SDK_DIR/iPhoneOS16.5.sdk" "$HOME/theos/sdks/"
      echo "iPhoneOS16.5.sdk disalin ke \$HOME/theos/sdks/"
    else
      echo "PERINGATAN: iPhoneOS16.5.sdk tidak ditemukan di repo theos/sdks (mungkin nama tag beda). Cek manual."
    fi
  else
    echo "PERINGATAN: gagal clone theos/sdks. Cek koneksi, atau ambil manual dari https://github.com/theos/sdks"
  fi
  rm -rf "$TMP_SDK_DIR"
fi

echo
echo "Kalau hanya ingin coba first-boot dengan kernel prebuilt (prebuilt/hakios-kernel),"
echo "bagian theos di atas boleh gagal/dilewati -- lanjut saja ke tahap berikutnya."

echo
echo "-- Symlink tambahan (khusus beberapa setup Ubuntu, lihat README repo) --"
if [ -d "xnu-deps/host/bin" ]; then
  if [ -x "$HOME/theos/toolchain/linux/iphone/bin/dsymutil" ]; then
    ln -sf "$HOME/theos/toolchain/linux/iphone/bin/dsymutil" xnu-deps/host/bin/dsymutil
    echo "Symlink dsymutil dibuat/diperbarui."
  fi
  if command -v python3 >/dev/null 2>&1; then
    ln -sf "$(command -v python3)" xnu-deps/host/bin/python
    echo "Symlink python dibuat/diperbarui."
  fi
else
  echo "xnu-deps/host/bin belum ada (biasanya muncul setelah sync/build kernel base pertama kali). Lewati dulu, cek lagi nanti."
fi

echo
echo "== Tahap 1 selesai. Lanjut: 02-prep-device.sh =="