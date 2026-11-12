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
# So write the BCB here ourselves, using exactly the fields TWRP fills in when
# it is started with --fastboot:
#   command[32]  = "boot-recovery"
#   status[32]   = zero
#   recovery[768]= "recovery\n--fastboot"
# get_args() then finds tokens[0] == "recovery" and appends "--fastboot", which
# selects fastbootd without depending on the "boot-fastboot" special case.
# Then tw_reboot() restarts with the reason "recovery" (patch 0014), exactly
# like Reboot to Recovery, so the kernel and every process start fresh.
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
	# command + status + recovery + stage (32+32+768+32); the rest of the
	# partition is left untouched.
	dd if=/dev/zero of="$MISC" bs=1 count=864 conv=notrunc 2>>"$OUT"
	printf 'boot-recovery' | dd of="$MISC" bs=1 seek=0 conv=notrunc 2>>"$OUT"
	printf 'recovery\n--fastboot' | dd of="$MISC" bs=1 seek=64 conv=notrunc 2>>"$OUT"
	sync
	echo "-- misc[0..95] after write --" >> "$OUT"
	dd if="$MISC" bs=1 count=96 2>/dev/null | od -An -tx1 -c >> "$OUT" 2>&1
fi

# Keep the evidence across the reboot: the next TWRP start clears the BCB.
for d in /sdcard/twrp-diag /external_sd/twrp-diag /cache/twrp-diag; do
	if mkdir -p "$d" 2>/dev/null; then
		cp -f "$OUT" "$d/" 2>/dev/null
	fi
done
sync
