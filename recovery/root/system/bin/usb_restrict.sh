#!/system/bin/sh
# Make adb/MTP work when the bootloader restricts USB.
#
# Some units boot with usb_notify_layer.usb_restrict=1 on the kernel command
# line (seen on an SM-A145R running A145RXXSEDZE4).  Samsung's usb_notify then
# logs "reserve_state_check usb restrict param is set, disable all USB
# operations" and reserves the vbus event, so mtk_set_peripheral() is never
# reached and musb stays at USB_ROLE_NONE ("do nothing, usb_on:0").  The
# parameter is 0444 and libmodprobe appends command-line options last, so it
# cannot be overridden from the ramdisk.
#
# musb_dr's "cmode" (0 none, 1 normal, 2 host, 3 device) bypasses usb_notify
# and calls the role switch directly.  Forcing device mode turns host/OTG off
# for the session, so do it only when the restriction is actually set: units
# without it keep normal role switching.
RESTRICT=/sys/module/usb_notify_layer/parameters/usb_restrict
CMODE=/sys/class/udc/musb-hdrc/device/cmode

[ "$(cat "$RESTRICT" 2>/dev/null)" = "1" ] || exit 0
[ -w "$CMODE" ] || exit 0
echo 3 > "$CMODE"
exit 0
