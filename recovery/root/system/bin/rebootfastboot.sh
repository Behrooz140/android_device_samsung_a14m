#!/system/bin/sh
# Samsung Galaxy A14 4G (a14m): enter fastbootd on the next boot.
#
# TWRP's "Reboot to Fastboot" normally relies on init: it writes a
# "boot-fastboot" bootloader control block and restarts the kernel, then the
# freshly started recovery reads that block and starts fastbootd.  On this
# device init cannot do the BCB write, because TWRP replaces
# /etc/recovery.fstab with its own (non-fs_mgr) format, so
# write_bootloader_message() fails and init restarts TWRP instead - which is
# what a hanging/unchanged Reboot to Fastboot looked like.
#
# So write the BCB here ourselves (patch 0018 also teaches TWRP's own BCB
# reader about /dev/block/by-name/misc), then tw_reboot() restarts with the
# reason "recovery" (patch 0014), exactly like Reboot to Recovery.  On the
# next boot TWRP sees "boot-fastboot" and starts fastbootd as a new process.
MISC=/dev/block/by-name/misc
OUT=/tmp/rebootfastboot.log
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
	printf 'boot-fastboot' | dd of="$MISC" bs=1 count=13 conv=notrunc 2>>"$OUT"
	sync
	echo "-- misc[0..63] after write --" >> "$OUT"
	dd if="$MISC" bs=1 count=64 2>/dev/null | od -An -tx1 >> "$OUT" 2>&1
	echo "-- command string --" >> "$OUT"
	dd if="$MISC" bs=1 count=13 2>/dev/null >> "$OUT"
	echo >> "$OUT"
fi

# Keep the evidence across the reboot: the next TWRP start clears the BCB.
for d in /sdcard/twrp-diag /external_sd/twrp-diag /cache/twrp-diag; do
	if mkdir -p "$d" 2>/dev/null; then
		cp -f "$OUT" "$d/" 2>/dev/null
	fi
done
sync
