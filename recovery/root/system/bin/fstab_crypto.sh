#!/system/bin/sh
# Runs from init on "fs", before the recovery binary parses the fstab.
# On this device the real metadata partition is md_udc (p29); p26 ("metadata")
# is unused. Add the FBE flags to /data only when a metadata key exists, so the
# same image also works on an unencrypted (or freshly wiped) firmware.
export TMPDIR=/tmp
KEYDIR=/metadata/vold/metadata_encryption
FSTAB=/system/etc/recovery.fstab
LOG=/tmp/fstab_crypto.log
MD=/dev/block/by-name/md_udc

mkdir -p /metadata 2>/dev/null
mounted=0
if ! mountpoint -q /metadata 2>/dev/null; then
    mount -t ext4 -o ro "${MD}" /metadata 2>/dev/null && mounted=1
fi

if [ -e "${KEYDIR}/key/encrypted_key" ]; then
    if ! grep -q 'keydirectory=' "${FSTAB}"; then
        # TWRP v1 fstab: <mount point> <fs> <device> flags=a;b;c
        # (semicolon separated, no device2 column)
        awk '
            $1 == "/data" && $0 !~ /^[[:space:]]*#/ {
                if ($4 ~ /^flags=/) {
                    # no ";inlinecrypt" here: TWRP does not know that token and
                    # logs "E:Unhandled flag: 'inlinecrypt'" (the "libencryb"
                    # error seen on screen) while the kernel flag lives inside
                    # the fileencryption value above already
                    $4 = $4 ";fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized;keydirectory=/metadata/vold/metadata_encryption"
                }
                print; next
            }
            { print }
        ' "${FSTAB}" > /tmp/recovery.fstab.crypto
        cp /tmp/recovery.fstab.crypto "${FSTAB}"
        echo "metadata encryption present, /data flagged" > "${LOG}"
    else
        echo "metadata encryption present, /data already flagged" > "${LOG}"
    fi
else
    echo "no metadata key, fstab left plain" > "${LOG}"
fi
grep -E "^/data[[:space:]]" "${FSTAB}" >> "${LOG}"

[ "${mounted}" = 1 ] && umount /metadata 2>/dev/null
exit 0
