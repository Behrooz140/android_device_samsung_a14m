#!/system/bin/sh
# The installed system is already mounted by TWRP at /system_root (erofs, ro).
# Only mount it ourselves when the recovery has not done so yet.
ROM=/system_root

rom_mounted() {
    [ -e "${ROM}/system/bin/servicemanager" ] && [ -e "${ROM}/system/bin/bootstrap/linker64" ]
}

rom_mount() {
    rom_mounted && return 0
    mkdir -p "${ROM}" 2>/dev/null
    for dev in /dev/block/mapper/system /dev/block/mapper/system_a /dev/block/mapper/system_b; do
        [ -e "${dev}" ] || continue
        for fs in erofs ext4; do
            mount -t "${fs}" -o ro "${dev}" "${ROM}" 2>/dev/null || continue
            rom_mounted && return 0
            umount "${ROM}" 2>/dev/null
        done
    done
    return 1
}

vendor_mount() {
    [ -e /vendor/bin/tzdaemon ] && return 0
    for dev in /dev/block/mapper/vendor /dev/block/mapper/vendor_a /dev/block/mapper/vendor_b; do
        [ -e "${dev}" ] || continue
        for fs in erofs ext4; do
            mount -t "${fs}" -o ro "${dev}" /vendor 2>/dev/null || continue
            [ -e /vendor/bin/tzdaemon ] && return 0
            umount /vendor 2>/dev/null
        done
    done
    return 1
}
