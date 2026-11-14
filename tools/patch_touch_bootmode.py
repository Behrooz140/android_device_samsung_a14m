#!/usr/bin/env python3
"""Re-apply the touch boot-mode fix to touch_common_o22.ko (Samsung a14m).

touch_common_o22.ko's tp_detect_panel() refuses to start any touch controller
unless the bootloader reports NORMAL_BOOT (0) or ALARM_BOOT (7):

    if ((boot_mode != NORMAL_BOOT) && (boot_mode != ALARM_BOOT)) {
        TP_ERROR("tp init fail because boot_mode = %d\\n", boot_mode);
        return -EINVAL;
    }

In recovery the bootloader reports 2, so every touch driver (Himax, Jadard,
Chipone, OmniVision) logs "No need to load ... touch driver".  The compiled
check is

    ldr  w4, [x20, #8]     ; boot_mode
    cbz  w4, <ok>          ; NORMAL_BOOT -> continue
    cmp  w4, #7            ; ALARM_BOOT
    b.ne <fail>

and the fix from commit e57ad3d turns "cbz w4, <ok>" into "b <ok>", so the
check always behaves as for boot_mode 0 (for the A145P/A145R builds: .text
+0x2b68, 64000034 -> 03000014).  Only those 4 bytes change; vermagic, CRCs
and the ELF layout are untouched, and the module is unsigned like every other
vendor module here.

extract_from_recovery.sh runs this on every re-extraction, because a stock
recovery always carries the unpatched module.

Usage: patch_touch_bootmode.py <touch_common_o22.ko> [--check]
  --check  only report the state; exit 0 if patched, 1 if not.
"""
import re
import struct
import sys

LDR = re.escape(bytes.fromhex("840a40b9"))     # ldr  w4, [x20, #8]
CMP = re.escape(bytes.fromhex("9f1c0071"))     # cmp  w4, #7
ANY = rb"[\x00-\xff]{4}"
PATTERN = re.compile(LDR + b"(" + ANY + b")" + CMP + b"(" + ANY + b")", re.DOTALL)


def is_cbz_w4(insn):
    return (insn & 0xFF00001F) == 0x34000004          # cbz w4, imm19


def is_b(insn):
    return (insn & 0xFC000000) == 0x14000000          # b imm26


def is_bne(insn):
    return (insn & 0xFF00001F) == 0x54000001          # b.ne imm19


def cbz_to_b(insn):
    imm19 = (insn >> 5) & 0x7FFFF
    if imm19 & 0x40000:                              # sign-extend
        imm19 -= 1 << 19
    return 0x14000000 | (imm19 & 0x3FFFFFF)


def scan(data):
    """Return (unpatched_offsets, patched_offsets) of the second instruction."""
    unpatched, patched = [], []
    for m in PATTERN.finditer(data):
        second = struct.unpack("<I", m.group(1))[0]
        fourth = struct.unpack("<I", m.group(2))[0]
        if not is_bne(fourth):
            continue
        if is_cbz_w4(second):
            unpatched.append(m.start(1))
        elif is_b(second):
            patched.append(m.start(1))
    return unpatched, patched


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) != 1:
        sys.exit(__doc__)
    path, check_only = args[0], "--check" in sys.argv[1:]
    data = bytearray(open(path, "rb").read())
    unpatched, patched = scan(data)

    if not unpatched and len(patched) == 1:
        print(f"{path}: patched (b at file offset 0x{patched[0]:x})")
        return 0
    if len(unpatched) != 1 or patched:
        sys.exit(f"{path}: expected exactly one boot_mode check, found "
                 f"{len(unpatched)} unpatched / {len(patched)} patched; not touching it "
                 "(different module build?)")
    off = unpatched[0]
    if check_only:
        print(f"{path}: NOT patched (cbz at file offset 0x{off:x})")
        return 1
    old = struct.unpack_from("<I", data, off)[0]
    new = cbz_to_b(old)
    struct.pack_into("<I", data, off, new)
    open(path, "wb").write(data)
    print(f"{path}: patched file offset 0x{off:x}: {old:08x} -> {new:08x} "
          "(cbz w4 -> b: accept every boot mode like NORMAL_BOOT)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
