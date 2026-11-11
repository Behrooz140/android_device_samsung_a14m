#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/samsung/a14m

# Dynamic partitions (super)
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Recovery ramdisk files (destination is relative to $(PRODUCT_OUT))
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.recovery.mt6768.rc:recovery/root/init.recovery.mt6768.rc \
    $(LOCAL_PATH)/recovery/root/init.recovery.samsung.rc:recovery/root/init.recovery.samsung.rc \
    $(LOCAL_PATH)/recovery/root/system/etc/twrp.flags:recovery/root/system/etc/twrp.flags

# Himax HX83112 touch firmware.  himax_ic_HX83112_o22.ko calls
# request_firmware() for these names and the stock cmdline already contains
# firmware_class.path=/vendor/firmware.  In stock recovery /vendor comes from
# the super partition, but TWRP does not mount /vendor, so the files have to
# live in the recovery ramdisk itself (they were extracted from vendor.img).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/vendor/firmware/hx83112f_txd_boe_firmware.bin:recovery/root/vendor/firmware/hx83112f_txd_boe_firmware.bin \
    $(LOCAL_PATH)/recovery/root/vendor/firmware/hx83112f_txd_boe_mpfw.bin:recovery/root/vendor/firmware/hx83112f_txd_boe_mpfw.bin

# Prebuilt kernel modules taken from the stock recovery ramdisk.
# They MUST match prebuilt/kernel, otherwise display/touch/storage will not work
# (mediatek-drm, lcd_*, touch_common, ufs-mediatek ... are all modules on this
# device, so without them TWRP has no display, no touch and no storage).
#
# The modules must land in the recovery ramdisk at /lib/modules, because that
# is where init's first stage looks for modules.load.recovery in recovery mode.
# NOTE: no spaces after the commas in $(call ...); make keeps them in the
# arguments and the helper's regex would no longer match, producing
# "malformed COPY_FILE" errors.
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*.ko,$(LOCAL_PATH)/prebuilt/modules,recovery/root/lib/modules) \
    $(LOCAL_PATH)/prebuilt/modules/modules.alias:recovery/root/lib/modules/modules.alias \
    $(LOCAL_PATH)/prebuilt/modules/modules.dep:recovery/root/lib/modules/modules.dep \
    $(LOCAL_PATH)/prebuilt/modules/modules.softdep:recovery/root/lib/modules/modules.softdep \
    $(LOCAL_PATH)/prebuilt/modules/modules.load.recovery:recovery/root/lib/modules/modules.load.recovery
# fastbootd (dynamic partitions)
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd

# /data decryption (FBE v2 + metadata encryption) and diagnostics. crash_dump
# installs as crash_dump64; without it an abort in the recovery binary leaves
# nothing but "Fatal signal 6" in the log.
PRODUCT_PACKAGES += \
    langsdorff_decrypt \
    crash_dump \
    gk_verify
