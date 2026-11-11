#!/system/bin/sh
#
# Collect boot/input/touch diagnostics inside TWRP and store them where they
# survive a reboot.  Started as a oneshot service from
# init.recovery.mt6768.rc, so TWRP itself is unaffected.
#
# Output locations (whichever is writable):
#   /sdcard/twrp-diag/     internal storage, only if /data could be mounted
#   <microSD>/twrp-diag/   external card (mmcblk1)
#   /cache/twrp-diag/      cache partition (survives reboot, needs PC or root)
#   /tmp/twrp-diag/        volatile copy for the current session
#
# The interesting file is diag.txt; recovery.log is TWRP's own log.

LOG=/tmp/twrp-diag
mkdir -p "$LOG" 2>/dev/null

# Give the kernel time to finish probing (module load is done by init's first
# stage, but i2c/touch probes can be deferred) and TWRP time to write its log.
sleep 25

dmesg > "$LOG/dmesg.txt" 2>/dev/null

{
  echo "== date =="
  date
  echo
  echo "== /proc/cmdline =="
  cat /proc/cmdline
  echo
  echo "== /proc/version =="
  cat /proc/version
  echo
  echo "== loaded modules (display / touch / i2c / keys) =="
  grep -E 'himax|touch|jadard|chipone|omnivision|lcd_|mtk_disp|mtk_panel|i2c-mt65xx|pinctrl-mt6768|mediatek-drm|mtk-kpd|sec_ext|sec_debug' /proc/modules 2>/dev/null
  echo
  echo "== module count =="
  grep -c '^' /proc/modules 2>/dev/null
  echo
  echo "== /proc/bus/input/devices =="
  cat /proc/bus/input/devices
  echo
  echo "== /dev/input =="
  ls -l /dev/input
  echo
  echo "== input device names =="
  for e in /sys/class/input/event*; do
    [ -e "$e" ] || continue
    echo "$e = $(cat "$e/device/name" 2>/dev/null)"
  done
  echo
  echo "== abs capabilities per event node =="
  for e in /sys/class/input/event*; do
    [ -e "$e" ] || continue
    echo "-- $e"
    cat "$e/device/capabilities/abs" 2>/dev/null
  done
  echo
  echo "== i2c buses / devices =="
  ls /sys/bus/i2c/devices 2>/dev/null
  echo
  echo "== block devices (mmcblk*) =="
  ls -l /dev/block/mmcblk* 2>/dev/null
  echo
  echo "== mounts =="
  cat /proc/mounts
  echo
  echo "== touch related dmesg =="
  dmesg 2>/dev/null | grep -iE 'hx83112|himax|hbtp|touch|tpd|input:|firmware|panel' | tail -300
  echo
  echo "== dmesg tail =="
  dmesg 2>/dev/null | tail -500
} > "$LOG/diag.txt" 2>&1

cp /tmp/recovery.log "$LOG/recovery.log" 2>/dev/null

cat > "$LOG/README.txt" <<'EOT'
TWRP touch diagnostics
======================

diag.txt         Everything that matters: dmesg, input devices, loaded
                 modules, i2c devices, mounts.
recovery.log     TWRP's own log from this boot.
dmesg.txt        Raw kernel log.
SAVED-TO.txt     Where this folder was copied to.

Just send diag.txt (and recovery.log if it is not empty).
EOT

# Where did we manage to save?
: > "$LOG/SAVED-TO.txt"

# 1) internal storage (only works when TWRP could mount /data)
if [ -d /sdcard ] && touch /sdcard/.twrp-diag-test 2>/dev/null; then
  rm -f /sdcard/.twrp-diag-test
  mkdir -p /sdcard/twrp-diag 2>/dev/null
  cp -f "$LOG"/* /sdcard/twrp-diag/ 2>/dev/null
  echo "/sdcard/twrp-diag" >> "$LOG/SAVED-TO.txt"
fi

# 2) microSD card - use it if TWRP already mounted it, otherwise mount it
#    ourselves, trying every filesystem a card may come formatted with.
sd_done=0
for m in /external_sd /mnt/sd; do
  if [ -d "$m" ] && touch "$m/.twrp-diag-test" 2>/dev/null; then
    rm -f "$m/.twrp-diag-test"
    mkdir -p "$m/twrp-diag" 2>/dev/null
    cp -f "$LOG"/* "$m/twrp-diag/" 2>/dev/null
    echo "microSD(already mounted):$m/twrp-diag" >> "$LOG/SAVED-TO.txt"
    sync
    sd_done=1
    break
  fi
done
if [ "$sd_done" = "0" ]; then
  for fs in exfat vfat ext4; do
    for dev in /dev/block/mmcblk1p1 /dev/block/mmcblk1; do
      [ -e "$dev" ] || continue
      mkdir -p /mnt/sd 2>/dev/null
      if mount -t "$fs" -o rw "$dev" /mnt/sd 2>/dev/null; then
        mkdir -p /mnt/sd/twrp-diag 2>/dev/null
        cp -f "$LOG"/* /mnt/sd/twrp-diag/ 2>/dev/null
        echo "microSD($fs on $dev):/twrp-diag" >> "$LOG/SAVED-TO.txt"
        sync
        umount /mnt/sd 2>/dev/null
        sd_done=1
        break
      fi
    done
    [ "$sd_done" = "1" ] && break
  done
fi

# 3) /cache - already mounted by TWRP, or mount it ourselves
saved_cache=0
if [ -d /cache ] && touch /cache/.twrp-diag-test 2>/dev/null; then
  rm -f /cache/.twrp-diag-test
  mkdir -p /cache/twrp-diag 2>/dev/null
  cp -f "$LOG"/* /cache/twrp-diag/ 2>/dev/null
  saved_cache=1
fi
if [ "$saved_cache" = "0" ]; then
  mkdir -p /mnt/cache 2>/dev/null
  if mount -t ext4 -o rw /dev/block/by-name/cache /mnt/cache 2>/dev/null; then
    mkdir -p /mnt/cache/twrp-diag 2>/dev/null
    cp -f "$LOG"/* /mnt/cache/twrp-diag/ 2>/dev/null
    saved_cache=1
    sync
    umount /mnt/cache 2>/dev/null
  fi
fi
[ "$saved_cache" = "1" ] && echo "/cache/twrp-diag" >> "$LOG/SAVED-TO.txt"

# Make the result visible in dmesg too, in case nothing was writable.
echo "twrp-diag: saved to: $(tr '\n' ' ' < "$LOG/SAVED-TO.txt")" > /dev/kmsg 2>/dev/null

exit 0
