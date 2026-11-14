> English translation of the Persian [README.md](README.md) as of commit e7ca670. The Persian original is authoritative.

# TWRP Device Tree — Samsung Galaxy A14 4G (SM-A145P / `a14m`)

A dedicated device tree for building **TWRP 12.1** for the
**Samsung Galaxy A14 4G — SM-A145P**, based on the phone's own stock recovery file.

> **Status: build 20 has been tested on the phone and works.**
> Boot, display, touch, storage, the `super` logical partitions,
> `Install Image` to logical partitions, their visibility in
> **Advanced Wipe**, and **Reboot → Recovery** all work correctly.
>
> The only remaining limitation is **`/data` decryption**, which is practically
> impossible from the `recovery` partition (section 9). This limitation stems from
> the bootloader's behavior, not from a bug in the tree.

Repository: `https://github.com/Behrooz140/android_device_samsung_a14m`

---

## 1) Feature status

| Feature | Status | Notes |
|---|---|---|
| Booting TWRP from the `recovery` partition | ✅ | Boot header exactly matches stock |
| Display and brightness | ✅ | `TW_BRIGHTNESS_PATH` points to the real backlight |
| Touch (Himax HX83112) | ✅ | The touch firmware is included in the ramdisk |
| MicroSD read/write | ✅ | `/external_sd` (exFAT/vfat) |
| Internal storage `/sdcard` | ⚠️ | Only when `/data` is mounted |
| `super` logical partitions | ✅ | Read-only mount + `flashimg=1` |
| `Install Image` to `system`/`vendor`/… | ✅ | Patch 0008 |
| Logical partitions visible in Advanced Wipe | ✅ | Patch 0012 + `wipeingui` |
| Wiping the filesystem on `super` | ⚠️ | Samsung's `super` metadata is read-only |
| Backup of logical partitions | ❌ (intentional) | TWRP disables backup for `super`; use the stock image |
| `Reboot → Recovery` | ✅ | Patch 0013 + writing the BCB directly |
| `Reboot → Fastboot` | ✅ | Patches 0014 + 0018: writing a `--fastboot` BCB and restarting into recovery |
| Displayed temperature | ⚠️ | Patch 0016; the recovery kernel has no CPU zone, so the battery temperature is shown |
| Vibration (haptics) | ✅ | Patch 0017: driving `brightness` directly and resetting the trigger |
| Wiping Dalvik / ART Cache | ⚠️ | Patch 0015; `/cache` is wiped, `dalvik-cache` inside the encrypted `/data` is not accessible |
| `Reboot → System` | ✅ | |
| fastbootd / repacktools / lptools | ✅ | |
| `/data` decryption | ❌ | The bootloader does not bring up the TEE in recovery mode |
| APEX | Removed | `TW_EXCLUDE_APEX := true` |

`Reboot → Fastboot`, vibration and the battery temperature were tested on the
phone in build 23 and confirmed with the MicroSD logs (section 12).

---

## 2) Device specifications

| Item | Value |
|---|---|
| Model | Samsung Galaxy A14 4G |
| Device code | `SM-A145P` |
| Codename | `a14m` (Samsung product name: `a14mnnxx`) |
| Chipset | MediaTek **MT6768** (Helio G80/G85) |
| Architecture | arm64-v8a + armeabi-v7a (`cortex-a55`) |
| Android | 15 / One UI 7 |
| Stock build | `A145PXXSDDZH1` / `AP3A.240905.015.A2` |
| Security patch | `2026-07-05` |
| Fingerprint | `samsung/a14mnnxx/a14m:15/AP3A.240905.015.A2/A145PXXSDDZH1:user/release-keys` |
| Recovery partition | `80,740,352` bytes (p40) |
| `super` partition | `9,126,805,504` bytes (p46) |

Display: `BOE / TXD / INX / JDI` panels with the `hx83112f`, `jd9522t`,
`nl9922c`, `td4375` drivers.
Touch: `himax HX83112`, `jadard JD9522T`, `chipone` and `focaltech`.

---

## 3) Source of the prebuilts and the boot header

All of the files below were extracted **from the phone's own stock `recovery.img`**
(not from the internet, nor from a similar device). The kernel, DTB/DTBO and modules
therefore match the hardware of this exact build.

| File | Size | MD5 | Notes |
|---|---:|---|---|
| `prebuilt/kernel` | 13,975,532 | `933b3c79216a10cd47b5c93ce16e10e9` | Stock `Image.gz` (gzip) |
| `prebuilt/dtb.img` | 182,127 | `ab5bacb2fe7589c25026e21ab718e5ef` | MT6768 base DTB |
| `prebuilt/dtbo.img` | 79,837 | `08eba6a650cffcad2e8209398b135364` | DTBO for the `A14M MEA OPEN 00` board |
| `prebuilt/modules/` | 25 MB | — | 198 `.ko` files + `modules.alias`, `modules.dep`, `modules.softdep`, `modules.load.recovery` |

The output boot header must be identical to stock **byte for byte**:

```
header version : 2
page size      : 4096
kernel  addr   : 0x40080000
ramdisk addr   : 0x47C80000
tags    addr   : 0x4BC80000
dtb     addr   : 0x4BC80000
cmdline        : bootopt=64S3,32N2,64N2 loop.max_part=7
board name     : SRPVJ12A013
os version     : 15.0.0 / 2026-07
ramdisk format : LZ4 (legacy frame)
```

These values are set explicitly in `BoardConfig.mk`
(`--board SRPVJ12A013`, `--dtb_offset 0x0bc08000`,
`--os_version 15.0.0 --os_patch_level 2026-07`, `BOARD_RAMDISK_USE_LZ4`).
Changing any of them causes the bootloader to reject the image or the kernel
to fail to find the ramdisk.

> The modules **must** be of the same generation as `prebuilt/kernel`; if you change
> the kernel (e.g. to a custom kernel), these modules will no longer load, and display,
> touch, storage and USB will stop working.

---

## 4) Tree structure

```
device/samsung/a14m/
├── .github/workflows/build-twrp.yml ← build workflow for GitHub Actions
├── .gitignore
├── Android.bp / Android.mk / AndroidProducts.mk
├── BoardConfig.mk              ← kernel, partitions, AVB and TWRP flags
├── device.mk                   ← copies ramdisk files and modules
├── twrp_a14m.mk                ← twrp_a14m product
├── vendorsetup.sh
├── recovery.fstab              ← TWRP-specific fstab (v2 format)
├── prebuilt/
│   ├── kernel                  ← stock Image.gz
│   ├── dtb.img                 ← stock base DTB
│   ├── dtbo.img                ← stock DTBO
│   └── modules/                ← 198 stock kernel modules + dependencies
├── decrypt/                    ← software part of /data decryption
│   ├── Android.bp              ← defines langsdorff_decrypt and gk_verify
│   ├── langsdorff_decrypt.cpp  ← unlocks FBE v2 + metadata with KeyMint
│   └── gk_verify.cpp           ← password verification with gatekeeper HIDL 1.0
├── patches/                    ← TWRP source patches (0001 to 0017)
├── recovery/root/
│   ├── init.recovery.mt6768.rc ← USB, TEE, decrypt service, diag
│   ├── init.recovery.samsung.rc← efs preparation
│   ├── sbin/twrp-diag.sh       ← diagnostic log collection
│   ├── system/bin/             ← decrypt.sh, data_release.sh,
│   │                             fstab_crypto.sh, rebootrecovery.sh, …
│   ├── system/etc/init/        ← stock rc files (dsms, snapuserd, …)
│   ├── system/etc/twrp.flags   ← optional entries (USB-OTG)
│   └── system/tee/             ← Samsung TEE stack for the decryption attempt
└── tools/
    ├── extract_from_recovery.sh← re-extracts the prebuilts
    └── stock_recovery.fstab    ← stock fstab for comparison
```

The `recovery/root/...` files are copied via `PRODUCT_COPY_FILES` to
`out/target/product/a14m/recovery/root/...` and end up inside the ramdisk.
The modules sit in `recovery/root/lib/modules/`, which is the same path
init searches for `modules.load.recovery` in recovery mode.

The patches are intentionally kept inside the repository itself; the workflow applies them to
the TWRP source before building, so there is no need to maintain a hand-modified copy of TWRP.

---

## 5) Building with GitHub Actions (main method)

A ready-made workflow is located in `.github/workflows/build-twrp.yml`, and it is
the same method that all of the tested builds were built with.

Steps:

1. Open the repository → **Actions** tab → the
   **Build TWRP (a14m)** workflow.
2. Click **Run workflow** and choose the inputs:
   - `variant`: `eng` (default) or `userdebug`
   - `target`: `recoveryimage` (for this phone) or `bootimage`
3. When it finishes (roughly 1 to 2 hours, 350-minute cap), download these
   files from the **Artifacts** section:
   - `recovery.img` — the raw image
   - `twrp_a14m.tar.md5` — ready-made Odin package (AP slot)
   - `MD5SUMS.txt` and `SHA256SUMS.txt`

The Artifact is named `twrp-a14m-<run number>`; the run number of the tested
build is **20**.

What the workflow does:

- Prepares the AOSP dependencies, `repo` and disk space
- `repo init/sync` of the manifest
  `minimal-manifest-twrp/platform_manifest_twrp_aosp`, branch `twrp-12.1`
  (`--depth=1` version)
- Copies the device tree to `device/samsung/a14m`
- Applies **all** `patches/*.patch` to `bootable/recovery`:

  ```bash
  patch -p1 --forward --fuzz=3 -d bootable/recovery < patches/0001-....patch
  ```

- Builds with `lunch twrp_a14m-eng` and `mka recoveryimage`
- Builds the Odin package (tar + MD5) and uploads the Artifact

Notes:

- `ccache` is intentionally not used; on the GitHub runner it produced
  a `Read-only file system` error on `~/.ccache/tmp`.
- If you push a `v*` tag, a **GitHub Release** is created as well, in addition
  to the Artifact:
  ```bash
  git tag v1.0.0 && git push origin v1.0.0
  ```
- If the build fails, an Artifact named `build-logs-<run>` containing
  `verbose.log.gz` and `error.log` is uploaded.
- Automatic runs on every push are disabled by default (each run uses up the
  Actions quota); to enable them, uncomment the `push.branches` block in the
  workflow file.

---

## 6) Local build (optional)

```bash
mkdir -p ~/twrp && cd ~/twrp

repo init --depth=1 \
  -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git \
  -b twrp-12.1
repo sync -j"$(nproc)" --force-sync --no-clone-bundle --no-tags

ln -s /root/device/samsung/a14m device/samsung/a14m

# Apply the patches manually (the workflow does this automatically)
shopt -s nullglob
for p in device/samsung/a14m/patches/*.patch; do
  echo "--- $p"
  patch -p1 --forward --fuzz=3 -d bootable/recovery < "$p"
done

. build/envsetup.sh
lunch twrp_a14m-eng
mka recoveryimage -j"$(nproc)"
```

Output: `out/target/product/a14m/recovery.img`

Requirements: 64-bit Linux, about 100 GB of free space, 8 to 16 GB of RAM,
and `git`, `repo`, `python3`, `lz4`, `cpio`, `openjdk-11`.

---

## 7) Installing on the phone

### 7.1 Preparation

1. Remove the Samsung account and the screen lock.
2. Enable `OEM unlocking` in Developer options.
3. Connect the phone to the internet so that **KG State = Checking** and
   **RMM State = Normal**; otherwise Odin will block the flash
   and a 7-day wait may be required.
4. Enter **Download Mode** with `Volume Down + Volume Up` + USB cable and
   unlock the bootloader (all data will be wiped).
5. Boot into the system once and check Developer options again.

### 7.2 Disabling AVB — mandatory

The stock `recovery.img` is signed with Samsung's key, and the phone's `vbmeta` holds the hash of that
same image. The image this tree builds is signed with the **AOSP test key**;
as long as the stock `vbmeta` is on the phone, the bootloader rejects the image,
and the result is the Samsung logo and a reboot.

A reliable method for Samsung (no fastboot required):

1. Download the full firmware for **exactly the same build** as the phone
   (`AP_...tar.md5` from SamFW / SamMobile).
2. Install the **Magisk** app on the phone.
3. In Magisk: `Install` → `Select and Patch a File` → select the
   `AP_....tar.md5` file so that `boot.img` and `vbmeta.img` get patched.
4. Flash the output file `magisk_patched-....tar` with Odin in the **AP** slot
   and uncheck `Auto Reboot`.
5. After `PASS`, immediately boot into recovery with `Volume Up + Power`.

If you don't want root: extract only `vbmeta.img` from that same output and
flash just that file in a tar.

### 7.3 Flashing the recovery

The `twrp_a14m.tar.md5` file that the Artifact produces is ready for Odin as is:

```
Odin → Options: uncheck Auto Reboot
Odin → AP: twrp_a14m.tar.md5 → Start
```

If you want to build it yourself:

```bash
tar -cf twrp_a14m.tar recovery.img
md5sum twrp_a14m.tar >> twrp_a14m.tar
mv twrp_a14m.tar twrp_a14m.tar.md5
```

> After flashing, boot into recovery **immediately** with `Volume Up + Power` (cable
> unplugged) so that the stock system doesn't get a chance to overwrite the recovery.
> On first entry, do `Swipe to Allow Modifications`.

### 7.4 Updating TWRP

To install a newer version you don't need to use Odin again; copy the
`recovery.img` file to the MicroSD and, inside TWRP, use
**Install → Install Image → Recovery**. Then tap
**Reboot → Recovery** (section 8.4).

### 7.5 Returning to stock

Extract the stock `recovery.img` from that same `AP_...tar.md5` (or from TWRP's own
backup) and flash it with Odin in the AP slot. Flashing `boot`/`lk`/`preloader`
is not necessary and not recommended.

---

## 8) Features and partition behavior

### 8.1 `super` logical partitions

Eight logical partitions are defined in `recovery.fstab`:

`system`, `vendor`, `product`, `odm`, `system_ext`, `vendor_dlkm`,
`system_dlkm`, `odm_dlkm`

Each entry has these flags:

```
flags=display=<name>;logical;backup=1;flashimg=1;fsflags=ro;wipeingui
```

- **`fsflags=ro` is required.** Samsung has marked these partitions in the
  `super` metadata with the read-only attribute (`liblp attr=0x1`);
  the `dm-*` devices are read-only, and mounting without `MS_RDONLY` fails with
  `EACCES (Permission denied)`.
- **`flashimg=1`** allows a raw image (`system.img`, `vendor.img`, …) to be
  written via `Install Image` directly to that same logical partition;
  patch 0008 checks the image size (plain or sparse) and writes it to the
  corresponding `dm`.
- **`wipeingui`** makes the partition appear in **Advanced Wipe**.
  While parsing the fstab, TWRP marks every `Is_Super` partition as "not wipeable"
  and applies the flags later; patch 0012 changes this behavior only when
  the fstab itself explicitly asks for `wipeingui`
  (`Wipe_Available_in_GUI`). Backup remains disabled for these partitions
  (`Set_Can_Be_Backed_Up(false)`) and they do not appear in the Backup menu.
- **Wiping the filesystem** on `super` only succeeds when the `super`
  metadata is writable; on this phone it is not. To restore a partition,
  use `Install Image`, not Wipe.
- The `/super` partition itself is also added by TWRP as a separate entry
  (patch 0002 reads its size from the block device) and is available for
  dd/raw backup.

### 8.2 Boot and recovery images

`boot`, `recovery`, `init_boot`, `vendor_boot`, `dtbo` are defined with `flashimg=1`
and `backup=1`; you can take image backups or write new
images. `misc` is for display/reading only and intentionally has no `backup`, so that
a recovery BCB doesn't get restored by mistake.

### 8.3 Advanced Wipe and sensitive partitions

- Wipeable: `/data`, `/cache`, `/metadata`, `/external_sd` and the
  logical partitions (with the limitation from section 8.1).
- The wipe option is **never** enabled on `efs`, `persist`, `nvdata`;
  these hold the IMEI, radio calibration and sensor data and cannot be
  recovered once wiped. These partitions are in the fstab only for backup and
  read-only mounting (`fsflags=ro`).
- `/prism`, `/optics`, `/md1img`, `/spmfw`, `/scp1`, `/sspm_1` are defined
  for display/backup only.
- During the decryption attempt, `/efs` is temporarily `remount,rw`, because
  on stock TEEGRIS and gatekeeper also write to these same partitions; this
  is done only inside `decrypt_stack.sh` and has no effect on the behavior of
  the Wipe menu.

### 8.4 The `Reboot → Recovery` mechanism

On this phone, `Reboot → Recovery` **did not work** via the usual init path:
TWRP replaces `/etc/recovery.fstab` with its own format (not `fs_mgr`),
so `read/write_bootloader_message()` in init fails,
init returns without rebooting, and because the `recovery` service in
`init.recovery.service.rc` lacks the `oneshot` option, init runs that same TWRP
again; the result was a "soft reboot" without the Samsung logo.

Fix (patch 0013 + script):

1. `rebootrecovery.sh` writes the BCB to `/dev/block/by-name/misc` itself:
   `command[32]` and `status[32]` are zeroed and the string `boot-recovery`
   is written; it is then verified with `od` and logged to
   `/tmp/rebootrecovery.log`.
2. Instead of relying on init, `tw_reboot(rb_recovery)` directly calls
   `syscall(__NR_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
   LINUX_REBOOT_CMD_RESTART2, "recovery")`.
3. If the syscall is rejected, it falls back to `property_set(ANDROID_RB_PROPERTY, "reboot,")`;
   the BCB that was written still sends the bootloader into recovery.

Evidence of this operation is available in the next session in
`/sdcard/twrp-diag/rebootrecovery.log` (or `/external_sd/twrp-diag/` and
`/cache/twrp-diag/`).

### 8.5 Reboot to Fastboot, CPU temperature, vibration and Dalvik

**`Reboot → Fastboot`** (patches 0014 and 0018): for the `fastboot` target, init
also has to write the BCB and has the same problem as section 8.4; so it again ended in a "soft reboot".
In build 21, an attempt was made to have TWRP re-execute itself with
`execl("/system/bin/recovery", "recovery", "--fastboot")`, but this
hung: the new binary came up in the same process, with the same
DRM/USB and input devices already open.

As of build 23, the correct path is the same as the real boot path:

1. `rebootfastboot.sh` writes the BCB to `/dev/block/by-name/misc` itself
   (`command[32]` and `status[32]` zeroed, then `boot-recovery` and
   `recovery\n--fastboot`) and keeps evidence of it in
   `/tmp/rebootfastboot.log` and the `twrp-diag` folders.
2. `tw_reboot(rb_fastboot)` restarts the system with `LINUX_REBOOT_CMD_RESTART2` and the reason
   `recovery` (exactly like Reboot→Recovery), so
   the kernel and all processes come up from scratch.
3. On the next boot, `args::get_args()` reads the `recovery` field from `misc`,
   adds the `--fastboot` token, and fastbootd is started as a fresh
   process.
4. Patch 0018 is needed because `get_misc_blk_device()` uses `ReadDefaultFstab()`
   and does not understand the TWRP-format fstab (`failed to read
   default fstab`); it now falls back to `/dev/block/by-name/misc`
   on failure.

**fastbootd limitation:** fastbootd itself also reads `/etc/recovery.fstab` with
`fs_mgr` and fails
(`ReadDefaultFstab(): failed to find device default fstab`). This error is
non-fatal, and entering/exiting and `fastboot devices` work, but
the `super` logical partitions are not visible through fastboot. To flash those
partitions, use TWRP's own `Install Image`.

**CPU temperature** (patch 0016): by default TWRP reads `/sys/class/thermal/thermal_zone0/temp`;
on this phone zone0 is `mtk-master-charger` and always returns 0.
The patch searches all `thermal_zone*` for a `type` equal to `mtktscpu`
(and then `mtkcput`/`cpu`/anything containing `cpu`) and returns the correct
path.

**Actual temperature limitation:** the stock recovery kernel is a reduced build and in
recovery mode it registers only the charger and battery zones (`thermal_zone0..7`);
the CPU zone (i.e. `mtktscpu`) does not exist at all. The evidence is build 21's
`diag.txt`: only `mtk-master-charger`, `mtk-slave-charger`, `mtk-gauge`
and `battery` are visible. So the SoC temperature cannot be read in recovery. In this case
the patch falls back to the battery zone (`battery`/`mtktsbattery`/`mtk-gauge`)
so that the number doesn't stay fixed at 0; the number you see is the **battery temperature**, not the CPU's, and
this is stated honestly in the README.

**Vibration** (patch 0017): the `regulator-vibrator` driver exposes the motor as an LED
with `brightness` up to `max_brightness` (255), and after probe it
stays on with `brightness=255`. The `transient` trigger also works **in reverse** on this
device: `activate=1` turns the motor **off** for `duration` milliseconds
and then leaves it on again; that is why in build 21
the vibration was always on and cut out for one second on every touch.

As of build 23, the trigger and `activate` have been dropped:

- `init.recovery.mt6768.rc` writes `trigger=none` and `brightness=0`
  in `on fs` and `on boot`, so the motor is off from the
  start.
- `vibrate()` writes `brightness=max_brightness` directly and, after
  `timeout_ms` (in a separate thread, without blocking input), sets `brightness=0`
  back; overlapping pulses are handled with a counter.

**Dalvik / ART Cache** (patch 0015): when mounting `/data` failed, the
`Wipe_Dalvik_Cache()` function returned `false` for the whole operation and only gave the generic message
"Failed to wipe dalvik". Now the `/cache/recovery/…` paths are wiped first,
and if `/data` doesn't mount, the specific message "Unable to mount /data"
is shown and the rest of the Wipe operation continues. The
`dalvik-cache` itself is inside the encrypted `/data` and, as long as recovery cannot
unlock `/data` (section 9), it cannot be wiped; wiping it completely is only possible from
within Android (with root) or once decryption has been enabled.

### 8.6 Internal storage and MicroSD

- The MicroSD is mounted at `/external_sd` and works with exFAT, vfat and ext4;
  TWRP detects the filesystem itself when mounting.
- `/sdcard` is mapped to `/data/media/0`
  (`RECOVERY_SDCARD_ON_DATA := true`) and is only available when `/data` is mounted.
  Put your backups on the MicroSD.

### 8.7 Bundled tools

`fastbootd`, `repacktools`, `lptools`, `resetprop`/`libresetprop`,
`ntfs-3g` and `TW_EXCLUDE_TWRPAPP` are enabled/disabled in `BoardConfig.mk`.
The APEX loader has been intentionally removed, because on this device's 6.6 kernel it
failed with the error `Value too large for defined data type` and
produced `twrp.apex.loaded=false`; nothing in this recovery needs
the APEX libraries.

### 8.8 Diagnostic log

The `twrpdiag` service (oneshot, from `init.recovery.mt6768.rc`) runs the script
`/sbin/twrp-diag.sh`. About 45 seconds after boot, these
files are saved to the first writable destination:

| Path | Notes |
|---|---|
| `/sdcard/twrp-diag/` | Only if `/data` is mounted |
| `/external_sd/twrp-diag/` | MicroSD (most persistent) |
| `/cache/twrp-diag/` | cache partition |
| `/metadata/twrp-diag/` | `md_udc`, unencrypted and persistent |
| `/tmp/twrp-diag/` | This session only |

Important files:

- `diag.txt` — dmesg, loaded modules, input/i2c devices, mounts,
  TEE and decryption status, all thermal zones, vibrator status (active trigger and
  `brightness`, `duration`/`activate`/`state` for comparison), TWRP
  haptics/temperature settings, and the first 128 bytes of `misc`/`boot_para`/`para`
- `recovery.log` — TWRP's own log
- `last_kmsg.txt` — kernel log of the previous session (for investigating reboots)
- `rebootrecovery.log` — evidence of the BCB write for Reboot→Recovery
- `rebootfastboot.log` — evidence of the BCB write for Reboot→Fastboot
- `decrypt.log`, `fstab_crypto.log` — details of the decryption attempt
- `SAVED-TO.txt` — list of the destinations the files were saved to

For sending, `diag.txt` alone is usually enough; if it isn't empty,
`recovery.log` is useful too.

---

## 9) `/data` decryption limitation

Samsung's Android 15 uses both **FBE v2** and **metadata encryption**
(`dm-default-key`) for `/data`: all the raw `userdata` blocks are encrypted with a key
that is stored in `/metadata` (`md_udc`, p29). Unlocking it requires
Samsung's security stack (TEEGRIS, KeyMint, gatekeeper) to come up.

The tree ships this stack and tries to run it from the `recovery`
partition:

- `decrypt/langsdorff_decrypt.cpp` — unlocking the keys via KeyMint and
  building `dm-default-key` on `userdata`
- `decrypt/gk_verify.cpp` — password verification with gatekeeper HIDL 1.0
- `recovery/root/system/bin/decrypt.sh`, `decrypt_stack.sh`,
  `fstab_crypto.sh`, `data_release.sh`
- `recovery/root/system/tee/` — TEE libraries and binaries

But the evidence in the logs shows that **the bootloader intentionally does not bring up the TEE
in recovery mode**:

```
BOOTPROF: ... lk=6183, tfa=0, sec_os=0, gz=0
log_store: bootmode: 0x2
[rpmb] Recovery or Charging boot. Do not run TEEgris RPMB
TZDEV ERR tz_iwsock_connect(624): Failed to connect socket root_task, error=-111
```

That is, `tfa=0` and `sec_os=0`, and the explicit message "do not run TEEGRIS on a
recovery boot". The result is that KeyMint/gatekeeper are not available, and no
change to the kernel or ramdisk can compensate for this; the limitation is in
the `lk` (bootloader) partition.

Consequences:

- TWRP cannot unlock the encrypted `/data`; `/sdcard` is not
  available either.
- Use **MicroSD** (`/external_sd`) or USB-OTG for backups.
- If the data doesn't matter, use `Format Data` so that `/data` becomes usable
  with a fresh key.
- The only technically possible route to decryption is running TWRP from the `boot` partition on
  a normal boot (in which the TEE comes up) or modifying `lk`; neither has been done in this
  version, and each carries its own risks.

---

## 10) Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| Samsung logo and reboot | Stock `vbmeta` | Section 7.2 |
| Black screen, but `adb devices` responds | Brightness/panel or module | Check `diag.txt` and `TW_BRIGHTNESS_PATH` |
| Touch doesn't work | Different panel/touch revision | `diag.txt` and replacing the modules with those from the same firmware |
| `Reboot → Recovery` is quick and without a logo | BCB not written | Check `misc` in `diag.txt`; flash a version that includes patch 0013 |
| `Reboot → Fastboot` brings TWRP up again or hangs | init cannot write the BCB | Patches 0014 and 0018; check `rebootfastboot.log` |
| CPU temperature always 0 | Reading `thermal_zone0` (charger) | Patch 0016; check `diag.txt` |
| Displayed temperature is lower than the actual SoC temperature | The recovery kernel has no CPU zone | This is normal; the number is the battery temperature (section 8.5) |
| Vibration is always on or cuts out on touch | Inverted `transient` trigger | Patch 0017; check `trigger`/`brightness` in `diag.txt` |
| Vibration doesn't work in recovery | `brightness`/`max_brightness` | Patch 0017; check the `brightness` value in `diag.txt` |
| Dalvik isn't wiped, or "Failed to wipe dalvik" | `/data` doesn't mount | Patch 0015; `dalvik-cache` inside the encrypted `/data` is not accessible without decryption |
| `/data` doesn't mount | Metadata encryption | This is normal; section 9 |
| Logical partition missing from Wipe | `wipeingui` or patch 0012 | Flash build 20 or later |
| `E:Unhandled flag: 'inlinecrypt'` | Unknown token in the fstab | Don't add `inlinecrypt` to `/data` |
| Odin gets stuck at `FAIL` | KG/RMM or wrong `vbmeta`/model | Section 7.1 |

If TWRP comes up but something is wrong, first grab `diag.txt` from the MicroSD;
almost every "why" question is answered in that one file.

---

## 11) Patch list

The patches are applied to `bootable/recovery` (branch `android-12.1`).
Numbers 0004 and 0006 were removed; their contents were merged into later patches.

| Patch | Subject |
|---|---|
| `0001-decrypt-through-ce-unlock` | Routing the password to `decrypt_user.sh` and the TEE stack instead of keymaster 4 HIDL |
| `0002-super-partition-size` | Showing the real size of `/super` on the backup screen |
| `0003-data-on-decrypted-mapper` | Mounting `/data` on `/dev/block/mapper/userdata` after decryption |
| `0005-format-data-raw-partition` | Releasing `dm-default-key` before formatting `/data` |
| `0007-storage-path-after-late-data-mount` | Fixing `/sdcard` when `/data` is mounted late |
| `0008-flash-image-to-logical-partitions` | Writing raw/sparse images to logical partitions |
| `0009-wait-for-decrypt-during-splash` | Waiting for `decrypt.sh` during the splash and setting the encryption state |
| `0010-fscrypt-policies-through-decrypt-refs` | Mapping fscrypt v2 policies in backup/restore |
| `0011-remount-data-under-stale-sdcard-bind` | Clearing the stale `/sdcard` bind on `/data` |
| `0012-keep-logical-wipe-flags` | Honoring `wipeingui` for `super` partitions |
| `0013-direct-reboot-recovery` | Direct `LINUX_REBOOT_CMD_RESTART2` for Reboot→Recovery |
| `0014-direct-fastboot-restart` | `--fastboot` BCB + `RESTART2("recovery")` for Reboot→Fastboot |
| `0015-dalvik-without-data` | Wiping Dalvik without failing when `/data` isn't mounted |
| `0016-autodetect-cpu-temp-zone` | Finding the CPU zone by `type`, with fallback to the battery zone |
| `0017-enable-leds-vibrator-trigger` | Driving the vibrator with `brightness` only and resetting the trigger |
| `0018-bootloader-message-misc-fallback` | BCB read/write fallback to `/dev/block/by-name/misc` |

---

## 12) Changes

### Build 23 — `dabe5f4`

- Patch 0014 rewritten: instead of `execl` in the same process (which hung),
  `rebootfastboot.sh` writes the BCB itself (`boot-recovery` + `recovery\n--fastboot`)
  and TWRP is restarted with
  `RESTART2("recovery")`; fastbootd comes up on the next boot as a
  fresh process.
- New patch 0018: when `ReadDefaultFstab()` fails, `get_misc_blk_device()`
  falls back to `/dev/block/by-name/misc`; previously
  `failed to read default fstab` meant the BCB was neither read nor
  written.
- Patch 0017 rewritten: the `transient` trigger (which works inverted on this
  driver) was dropped; the vibrator is turned on by writing `brightness` directly and
  turned off in a separate thread. The "always on + cuts out on touch" problem is fixed.
- `init.recovery.mt6768.rc` writes `trigger=none` and `brightness=0`
  in `on fs` and `on boot` so that the motor is off from the
  start.
- Patch 0016: fallback to the battery zone when the recovery kernel has no CPU zone at all;
  the displayed number is the battery temperature (section 8.5).
- `twrp-diag.sh`: the vibrator is logged before and after the trigger test, and at the end
  `trigger=none`/`brightness=0` is restored.
- Verified output (GitHub Actions run number 23, ID `43225710875`,
  commit `dabe5f4`; the boot header differs from build 21 only in the ramdisk size and
  digest):
  `recovery.img` = `23e2c99b27eea82b859dc0f852bdf290`,
  `twrp_a14m.tar.md5` = `d53f4f01d14300599c35e357fc0cbbed`.
  Checked in the ramdisk: `rebootfastboot.sh` (0755), `trigger none`/
  `brightness 0` in the rc, and the battery fallback string and `by-name/misc` in the
  libraries are present.
- Tested on the phone and confirmed from the MicroSD logs:
  - `rebootfastboot.log`: `boot-recovery` and
    `recovery\n--fastboot` correctly written to `misc`.
  - `last_kmsg`: `init: starting service 'fastbootd'` and
    `fastbootd: initializing functionfs`, then
    `reboot: Restarting system with command 'recovery'`.
  - dmesg: `trigger=[none]`, `brightness=0` and 80ms vibration pulses only
    on touch (no staying on permanently).
  - `diag.txt`: `thermal_zone6/7` (battery) = 36°C and the message
    "No CPU thermal zone in this kernel; using the battery zone".

### Build 21 — `75e9a52`

- Patch 0014: **Reboot → Fastboot** fixed by re-executing `recovery --fastboot`
  in the same PID; no more soft reboot into TWRP.
- Patch 0015: **Wipe Dalvik** no longer fails the whole operation when `/data` is
  missing; the `/cache` paths are wiped and the specific message "Unable to mount
  /data" is shown.
- Patch 0016: the CPU temperature is shown by detecting the `mtktscpu` zone (and name-based fallbacks)
  instead of `thermal_zone0`.
- Patch 0017: vibration works in recovery by selecting the `transient` LED trigger;
  fallback to `timed_output` and `brightness`.
- `twrp-diag.sh`: added thermal zones, vibrator/trigger status, vibrator
  modules, and TWRP haptics and temperature settings to `diag.txt`.
- Verified output (GitHub Actions run `43210526874`):
  `recovery.img` = `385a68bf44011c9190b621e9c2297d4f`,
  `twrp_a14m.tar.md5` = `cda7490defa69f6c86a1218cbc6ed5d3`.

### Build 20 — `363347a`

- Patch 0012: logical partitions with `wipeingui` are visible in **Advanced Wipe**
  (backup still managed).
- Patch 0013: **Reboot → Recovery** fixed by writing the BCB and a direct `RESTART2`;
  no more "soft reboot" back into TWRP itself.
- `rebootrecovery.sh`: clearing command/status, writing `boot-recovery`,
  verifying with `od`, and copying the evidence to `/sdcard`, `/external_sd`, `/cache`.
- `twrp-diag.sh`: added a dump of the `misc`, `boot_para`, `para` partitions
  and copying of `/proc/last_kmsg` and `/tmp/rebootrecovery.log`.
- `flashimg=1` flag for all eight logical partitions.

### Build 19 — `6fae5cf`

- Read-only mounting of the `super` partitions (`fsflags=ro`) and fixes to the
  fstab flags; removal of dead entries.
- `efs`/`sec_efs` are temporarily made read-write during decryption.
- Improved detection and saving of `twrp-diag` on `/metadata` and MicroSD (exFAT).

### Build 18 — `e4e351b` and earlier

- Removed APEX to fix the `twrp.apex.loaded=false` errors.
- Added `flashimg` and attempted writing to logical partitions.
- Built the decryption stack (KeyMint AIDL + TEEGRIS + gatekeeper) and discovered
  that the bootloader does not run the TEE in recovery mode.

---

## 13) Re-extracting the prebuilts

If you have updated the phone's firmware:

```bash
cd device/samsung/a14m
./tools/extract_from_recovery.sh /path/to/recovery.img
```

The script reads the v2 boot header, computes the offsets from the page size,
extracts `prebuilt/kernel`, `dtbo.img`, `dtb.img`, unpacks the ramdisk
(gzip/lz4/xz/lzma/bzip2) and puts `lib/modules/*` into
`prebuilt/modules/`, updates the rc files and prints the
MD5s. Requirements: `python3` and the corresponding compression tool.

---

## 14) Warnings

- Never flash `preloader`, `lk`, `tee1` or `tzar`; doing so risks a hard
  brick. This tree targets `recovery` only.
- Unlocking the bootloader permanently sets `Warranty Bit` to 1 (Knox trip).
- `PLATFORM_SECURITY_PATCH` is set to `2099-12-31` so that anti-rollback doesn't block
  booting the custom image.
- Before doing anything, back up your important data and keep your own stock firmware
  files (`AP`, `BL`, `CSC`).

---

## 15) References

- Manifest: `minimal-manifest-twrp/platform_manifest_twrp_aosp`, branch `twrp-12.1`
- TWRP source: `TeamWin/android_bootable_recovery`, branch `android-12.1`
- fstab and partition names: `system/etc/recovery.fstab` inside the stock ramdisk
  (`tools/stock_recovery.fstab` for comparison)
- Panel/touch/backlight names: `dtbo.img` and the stock modules
- Similar trees (for comparison only, not copied): `twrpdtgen/android_device_samsung_a14m`,
  `forforksake/recovery_device_samsung_a14m`

---

## License

```
SPDX-License-Identifier: Apache-2.0
```

The prebuilt files (kernel, DTB/DTBO and modules) belong to Samsung/MediaTek
and are distributed under the stock firmware's license.
