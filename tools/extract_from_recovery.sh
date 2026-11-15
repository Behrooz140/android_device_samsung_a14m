#!/bin/bash
#
# extract_from_recovery.sh - re-extract every prebuilt blob used by this
# device tree directly from a stock Samsung recovery.img.
#
# Copyright (C) 2026 The Android Open Source Project
# SPDX-License-Identifier: Apache-2.0
#
# Usage:
#   ./tools/extract_from_recovery.sh /path/to/recovery.img
#
# What it extracts (all from the image, nothing downloaded):
#   prebuilt/kernel                       Android boot v2 kernel (Image.gz)
#   prebuilt/dtbo.img                     recovery_dtbo section
#   prebuilt/dtb.img                      dtb section (Samsung wrapper included)
#   prebuilt/modules/*                    lib/modules from the ramdisk
#   recovery/root/init.recovery.mt6768.rc
#   recovery/root/init.recovery.samsung.rc
#   tools/stock_recovery.fstab            reference copy of the stock fstab
#
# Requires: python3, plus gzip/xz/lzma/bzip2/lz4 matching the ramdisk format.
#

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "usage: $0 /path/to/recovery.img" >&2
    exit 1
fi

IMG="$1"
if [ ! -f "$IMG" ]; then
    echo "error: '$IMG' not found" >&2
    exit 1
fi

# Absolute path, needed because we cd around later.
case "$IMG" in
    /*) ;;
    *) IMG="$PWD/$IMG" ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PREBUILT_DIR="$DEVICE_DIR/prebuilt"
RECOVERY_ROOT="$DEVICE_DIR/recovery/root"

for tool in python3; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "error: required tool '$tool' not found" >&2
        exit 1
    }
done

WORK="$(mktemp -d "${TMPDIR:-/tmp}/a14m-extract.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

echo "==> reading boot image: $IMG"
python3 - "$IMG" "$WORK" <<'PY'
import hashlib
import struct
import sys

img_path, out_dir = sys.argv[1], sys.argv[2]
data = open(img_path, "rb").read()

if data[:8] != b"ANDROID!":
    sys.exit("error: not an Android boot image (magic != ANDROID!)")

(ks, ka, rs, ra, ss, sa, ta, ps, hv, osv) = struct.unpack_from("<10I", data, 8)

if ps not in (2048, 4096, 8192, 16384):
    sys.exit("error: unexpected page size %d" % ps)

if hv >= 2:
    rdtbo_size, = struct.unpack_from("<I", data, 1632)
    rdtbo_off, = struct.unpack_from("<Q", data, 1636)
    hsz, dtb_size = struct.unpack_from("<II", data, 1644)
    dtb_addr, = struct.unpack_from("<Q", data, 1652)
else:
    rdtbo_size = 0
    rdtbo_off = 0
    hsz = 1632
    dtb_size = 0
    dtb_addr = 0

def align(n):
    return (n + ps - 1) // ps * ps

o = align(hsz)
kernel = data[o:o + ks]
o += align(ks)

ramdisk = data[o:o + rs]
o += align(rs)

second = data[o:o + ss]
o += align(ss)

# Prefer the explicit recovery_dtbo_offset field when it is sane.
if rdtbo_size and 0 < rdtbo_off <= len(data) - rdtbo_size:
    dtbo = data[rdtbo_off:rdtbo_off + rdtbo_size]
    o = align(rdtbo_off + rdtbo_size)
else:
    dtbo = data[o:o + rdtbo_size]
    o += align(rdtbo_size)

dtb = data[o:o + dtb_size]

def dump(name, blob):
    path = out_dir + "/" + name
    with open(path, "wb") as f:
        f.write(blob)
    print("    %-28s %10d bytes  md5 %s"
          % (name, len(blob), hashlib.md5(blob).hexdigest()))

print("==> boot header v%d, page size %d" % (hv, ps))
dump("kernel", kernel)
dump("ramdisk.img", ramdisk)
if second:
    dump("second.img", second)
if dtbo:
    dump("dtbo.img", dtbo)
if dtb:
    dump("dtb.img", dtb)

with open(out_dir + "/info.txt", "w") as f:
    f.write("header_version=%d\n" % hv)
    f.write("page_size=%d\n" % ps)
    f.write("kernel_size=%d\n" % ks)
    f.write("ramdisk_size=%d\n" % rs)
    f.write("second_size=%d\n" % ss)
    f.write("dtbo_size=%d\n" % rdtbo_size)
    f.write("dtb_size=%d\n" % dtb_size)
    f.write("kernel_addr=0x%x\n" % ka)
    f.write("ramdisk_addr=0x%x\n" % ra)
    f.write("tags_addr=0x%x\n" % ta)
PY

[ -s "$WORK/kernel" ] || { echo "error: kernel not extracted" >&2; exit 1; }
[ -s "$WORK/ramdisk.img" ] || { echo "error: ramdisk not extracted" >&2; exit 1; }

echo "==> decompressing ramdisk"
magic="$(head -c 4 "$WORK/ramdisk.img" | od -An -tx1 | tr -d ' \n')"
case "$magic" in
    1f8b*)
        gzip -dc "$WORK/ramdisk.img" > "$WORK/ramdisk.cpio" ;;
    02214c18|04224d18)
        command -v lz4 >/dev/null 2>&1 || { echo "error: lz4 not installed" >&2; exit 1; }
        lz4 -d -c "$WORK/ramdisk.img" > "$WORK/ramdisk.cpio" 2>/dev/null ;;
    fd377a58)
        xz -dc "$WORK/ramdisk.img" > "$WORK/ramdisk.cpio" ;;
    5d0000)
        lzma -dc "$WORK/ramdisk.img" > "$WORK/ramdisk.cpio" ;;
    425a68*)
        bzip2 -dc "$WORK/ramdisk.img" > "$WORK/ramdisk.cpio" ;;
    30373037*)
        cp "$WORK/ramdisk.img" "$WORK/ramdisk.cpio" ;;
    *)
        echo "error: unknown ramdisk compression (magic $magic)" >&2
        exit 1 ;;
esac

echo "==> extracting ramdisk files"
python3 - "$WORK/ramdisk.cpio" "$WORK/modules" "$RECOVERY_ROOT" "$SCRIPT_DIR" <<'PY'
import os
import stat
import sys

cpio_path, modules_out, recovery_root, script_dir = sys.argv[1:5]
data = open(cpio_path, "rb").read()

os.makedirs(modules_out, exist_ok=True)
os.makedirs(recovery_root, exist_ok=True)

KEEP_RC = {
    "init.recovery.mt6768.rc": os.path.join(recovery_root, "init.recovery.mt6768.rc"),
    "init.recovery.samsung.rc": os.path.join(recovery_root, "init.recovery.samsung.rc"),
    "system/etc/recovery.fstab": os.path.join(script_dir, "stock_recovery.fstab"),
}

def normalized(name):
    while name.startswith("./"):
        name = name[2:]
    return name.lstrip("/")

pos = 0
modules = 0
others = 0
while True:
    hdr = data[pos:pos + 110]
    if hdr[:6] not in (b"070701", b"070702"):
        break

    def field(i):
        return int(hdr[6 + i * 8:6 + (i + 1) * 8], 16)

    mode = field(1)
    filesize = field(6)
    namesize = field(11)

    raw_name = data[pos + 110:pos + 110 + namesize - 1]
    pos += 110 + namesize
    pos = (pos + 3) & ~3

    blob = data[pos:pos + filesize]
    pos += filesize
    pos = (pos + 3) & ~3

    name = normalized(raw_name.decode("utf-8", "replace"))
    if name == "TRAILER!!!":
        break
    if not name:
        continue

    target = None
    if name.startswith("lib/modules/"):
        target = os.path.join(modules_out, os.path.relpath(name, "lib/modules"))
    elif name in KEEP_RC:
        target = KEEP_RC[name]

    if target is None:
        continue

    os.makedirs(os.path.dirname(target), exist_ok=True)
    if stat.S_ISLNK(mode):
        if os.path.lexists(target):
            os.unlink(target)
        os.symlink(blob.decode("utf-8", "replace"), target)
    elif stat.S_ISREG(mode):
        with open(target, "wb") as f:
            f.write(blob)
        os.chmod(target, 0o644)
        if target.startswith(modules_out):
            modules += 1
        else:
            others += 1

print("    modules extracted : %d" % modules)
print("    other files       : %d" % others)
PY

echo "==> installing files"
mkdir -p "$PREBUILT_DIR" "$RECOVERY_ROOT"

cp -f "$WORK/kernel" "$PREBUILT_DIR/kernel"
if [ -s "$WORK/dtbo.img" ]; then
    cp -f "$WORK/dtbo.img" "$PREBUILT_DIR/dtbo.img"
else
    echo "    warning: image has no recovery_dtbo section, keeping existing dtbo.img"
fi
if [ -s "$WORK/dtb.img" ]; then
    cp -f "$WORK/dtb.img" "$PREBUILT_DIR/dtb.img"
else
    echo "    warning: image has no dtb section, keeping existing dtb.img"
fi

if [ -d "$WORK/modules" ] && [ -n "$(ls -A "$WORK/modules" 2>/dev/null)" ]; then
    # prebuilt/modules/Android.mk belongs to the tree, not to the ramdisk
    if [ -f "$PREBUILT_DIR/modules/Android.mk" ]; then
        cp -a "$PREBUILT_DIR/modules/Android.mk" "$WORK/modules.Android.mk"
    fi
    rm -rf "$PREBUILT_DIR/modules"
    mkdir -p "$PREBUILT_DIR/modules"
    cp -a "$WORK/modules/." "$PREBUILT_DIR/modules/"
    if [ -f "$WORK/modules.Android.mk" ]; then
        cp -a "$WORK/modules.Android.mk" "$PREBUILT_DIR/modules/Android.mk"
    fi
    # stock touch_common_o22.ko refuses to probe in recovery: re-apply the fix
    if [ -f "$PREBUILT_DIR/modules/touch_common_o22.ko" ]; then
        echo "==> patching touch_common_o22.ko (see tools/patch_touch_bootmode.py)"
        python3 "$SCRIPT_DIR/patch_touch_bootmode.py" \
            "$PREBUILT_DIR/modules/touch_common_o22.ko" | sed 's/^/    /'
    fi
else
    echo "    warning: no kernel modules found in ramdisk, keeping existing modules"
fi

echo
echo "==> done"
echo "    kernel        : $(md5sum "$PREBUILT_DIR/kernel" | awk '{print $1}')"
[ -f "$PREBUILT_DIR/dtbo.img" ] && \
    echo "    dtbo.img      : $(md5sum "$PREBUILT_DIR/dtbo.img" | awk '{print $1}')"
[ -f "$PREBUILT_DIR/dtb.img" ] && \
    echo "    dtb.img       : $(md5sum "$PREBUILT_DIR/dtb.img" | awk '{print $1}')"
echo "    modules       : $(find "$PREBUILT_DIR/modules" -name '*.ko' | wc -l) .ko files"
echo
echo "    Next: review 'git diff' and make sure prebuilt/kernel and"
echo "    prebuilt/modules come from the same firmware build."
