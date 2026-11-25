# Checklist — HakiOS di Pixel 8 (shiba)

> Mau sekali jalan langsung semua tahap (clone workspace → deps → prep → build → boot)?
> `./run.sh all` (otomatis pakai `~/Projects/Pixel/hakios` & deteksi clone lama).
> Tahap `prep` dan `boot` tetap akan berhenti nanya konfirmasi (unlock bootloader, dll),
> jadi tetap perlu kamu tunggu/isi interaktif di tengah jalan.

## Struktur penting

`hackios-devices-shiba` BUKAN repo berdiri sendiri. Ia harus jadi subfolder
`devices/shiba/` di dalam clone base kernel (`Martinvlba/hakios-xnu-kernel`).
Semua `make` dan `tools/hakios-device.py` dijalankan dari ROOT WORKSPACE (base
kernel), BUKAN dari dalam `devices/shiba`.

```
~/Projects/Pixel/hakios/          <- WORKSPACE (base kernel, clone Martinvlba)
├── Makefile                      <- jalankan make dari sini
├── tools/hakios-device.py
├── uefi/                         <- hasil sync
└── devices/
    ├── akita/                    <- hasil sync (kalau ada di manifest)
    └── shiba/                    <- hackios-devices-shiba ditaruh di sini
        └── device.conf
```

## Tahap 0 — Workspace (`./run.sh workspace`)

- [ ] Base kernel ter-clone ke `~/Projects/Pixel/hakios` (atau path lain)
- [ ] `tools/hakios-device.py sync` sukses (uefi/, device resmi lain)
- [ ] `devices/shiba/device.conf` ada (clone lama dipindah / clone baru dibuat)
- [ ] Mulai dari sini, SEMUA perintah dijalankan dari root workspace ini

## Tahap 1 — Toolchain (`./run.sh deps`) — sudah otomatis & idempotent

- [ ] clang, lld, lz4, 7zip, gcc-aarch64-linux-gnu terpasang
- [ ] `uefi/` sudah di branch `pr2` (command `hakios` U-Boot)
- [ ] theos ter-install otomatis via installer resmi (`install-theos`) kalau belum ada
- [ ] `sdks/iPhoneOS16.5.sdk` otomatis di-sparse-clone dari `theos/sdks` kalau belum ada
- [ ] Semua langkah di atas di-skip otomatis kalau sudah pernah dilakukan (aman dijalankan ulang)

## Tahap 2 — Device (`./run.sh prep`)

- [ ] OEM unlocking aktif & `fastboot flashing unlock` sudah dijalankan
- [ ] `devices/shiba/boot-info/fdt.dtb` berhasil diambil
- [ ] `devices/shiba/prebuilt/device-tree.dtb` sudah di-copy
- [ ] `soc/zuma-addrs.py` sudah di-generate ulang
- [ ] (opsional) firmware vendor sudah ditarik
- [ ] (opsional) kalibrasi haptic sudah dicatat

## Tahap 3 — Build (`./run.sh build`)

- [ ] `shiba_defconfig` berhasil dibuat
- [ ] `tools/hakios-device.py check shiba` lolos
- [ ] kernel (source atau prebuilt) siap
- [ ] `hello` berhasil dibuild
- [ ] `build/shiba/hakios-shiba.img` berhasil di-pack

## Tahap 4 — Boot pertama (`./run.sh boot`, dari Windows kalau pakai WSL2)

- [ ] Banner U-Boot muncul
- [ ] Watchdog "counting, stopped" → "kept as a net"
- [ ] "DECON0 trigger unmasked"
- [ ] Loader/payload ditemukan
- [ ] "XNULOADER v3", "platform akita"
- [ ] Kernel jalan, tidak reset di EL1
- [ ] **"Hello from user space on Darwin!"** 🎉

## Setelah hello berhasil — nyalakan satu per satu

- [ ] `touchscreen=1`
- [ ] `buttons=1`
- [ ] `display_probe=1`
- [ ] `pcie=5` (cek log: harus kedetek chip `0x4398`)
- [ ] `haptic=1`
- [ ] `amp=1`
- [ ] `thermal=1`

## Kalau macet

- `devices/shiba/pull-log.sh` untuk tarik log pstore dari Android (butuh root)
- Bandingkan dengan tabel "Seen / Not seen" di README repo
