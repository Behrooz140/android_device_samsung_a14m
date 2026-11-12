#!/system/bin/sh
# Samsung Galaxy A14 4G (a14m): TWRP runs from the recovery partition.
#
# TWRP's "Reboot to recovery" normally relies on init: it writes the Android
# bootloader control block and then restarts the kernel with the reason
# "recovery".  On this device init cannot do the BCB write, because TWRP
# replaces /etc/recovery.fstab with its own (non-fs_mgr) format, so
# read/write_bootloader_message() fail.  init then aborts the reboot and init
# simply restarts TWRP, which looks like a "soft reboot".
#
# So write the BCB here ourselves, verify it, and leave evidence on the SD
# card.  tw_reboot() then performs the restart syscall directly (patch 0013).
MISC=/dev/block/by-name/misc
OUT=/tmp/rebootrecovery.log
: > "$OUT"

{
	echo "== date =="
	date
	echo "== misc =="
	ls -l "$MISC" 2>&1
} >> "$OUT" 2>&1

if [ ! -e "$MISC" ]; then
	echo "misc partition not found" >> "$OUT"
else
	# command[32] and status[32] belong to us; recovery[768] is left alone.
	dd if=/dev/zero of="$MISC" bs=1 count=64 conv=notrunc 2>>"$OUT"
	printf 'boot-recovery' | dd of="$MISC" bs=1 count=13 conv=notrunc 2>>"$OUT"
	sync
	echo "-- misc[0..63] after write --" >> "$OUT"
	dd if="$MISC" bs=1 count=64 2>/dev/null | od -An -tx1 >> "$OUT" 2>&1
	echo "-- command string --" >> "$OUT"
	dd if="$MISC" bs=1 count=13 2>/dev/null >> "$OUT" 2>&1
	echo >> "$OUT"
fi

# Keep the evidence across the reboot: the next TWRP start clears the BCB.
for d in /sdcard/twrp-diag /external_sd/twrp-diag /cache/twrp-diag; do
	if mkdir -p "$d" 2>/dev/null; then
		cp -f "$OUT" "$d/" 2>/dev/null
		cp -f /tmp/recovery.log "$d/recovery-before-reboot.log" 2>/dev/null
	fi
done
sync
