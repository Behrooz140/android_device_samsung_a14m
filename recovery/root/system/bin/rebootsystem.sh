#!/system/bin/sh
# A "boot-recovery" command left in misc would send the next boot back into
# recovery, so clear the command word before booting Android.
MISC=/dev/block/by-name/misc
[ -e "${MISC}" ] || exit 0
dd if=/dev/zero of="${MISC}" bs=1 count=32 conv=notrunc 2>/dev/null
sync
