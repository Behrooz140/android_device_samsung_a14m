#!/system/bin/sh
. /system/bin/rom_mount.sh

vendor_mount

# The firmware HALs need Android 15 system libraries. These come from the A15
# ramdisk/source and are carried in /system/tee/lib64 so they do not depend on
# the installed ROM. SYS comes first on purpose: the a14m vendor libbinder.so
# lacks openDeclaredPassthroughHal(), which the A15 libbinder_ndk needs, and the
# vendor KeyMint/gatekeeper libs shipped here are the ones in /system/tee.
SYS="/system/tee/lib64/bootstrap:/system/tee/lib64"
VEN="/vendor/lib64:/vendor/lib64/hw"
export LD_LIBRARY_PATH="${SYS}:${VEN}"
export ANDROID_ROOT=/system
export ANDROID_DATA=/data

exec /system/bin/tee_linker64 "$@"
