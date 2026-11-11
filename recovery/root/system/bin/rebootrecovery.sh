#!/system/bin/sh
# TWRP's "Reboot to recovery" only sets sys.powerctl=reboot,recovery and
# relies on the bootloader honouring the kernel reboot reason. Samsung's LK
# does not do that on this device and ends up in a warm "soft" reboot.
# Write the Android bootloader control block command as well; LK checks it on
# the next boot. TWRP clears the block during startup, so it cannot leak into
# a later normal boot.
MISC=/dev/block/by-name/misc
[ -e "${MISC}" ] || exit 0
printf 'boot-recovery' | dd of="${MISC}" bs=1 count=13 conv=notrunc 2>/dev/null
sync
