#!/system/bin/sh
# Switch the musb controller role on demand (issue #7).
#
#   usb_role.sh device   -> cmode 3: peripheral, adb/MTP work, no OTG VBUS
#   usb_role.sh host     -> cmode 2: host, OTG devices get 5 V, adb drops
#   usb_role.sh auto     -> cmode 1: let the Type-C/PD stack choose
#   usb_role.sh          -> print the current cmode
#
# This is intentionally temporary: usb_restrict.sh still forces device mode on
# every boot when usb_notify_layer.usb_restrict=1, so a reboot always brings adb
# back.  No setting is persisted.
CMODE=/sys/class/udc/musb-hdrc/device/cmode

case "${1:-}" in
    "")
        cat "$CMODE" 2>/dev/null || exit 1
        exit 0
        ;;
    device|3) role=3 ;;
    host|2)   role=2 ;;
    auto|1)   role=1 ;;
    *)
        echo "usage: $0 [device|host|auto]" >&2
        exit 2
        ;;
esac

[ -w "$CMODE" ] || {
    echo "usb_role: $CMODE is not writable" >&2
    exit 1
}
echo "$role" > "$CMODE" || exit 1
echo "usb_role: cmode=$role"
exit 0
