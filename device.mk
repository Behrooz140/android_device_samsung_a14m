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

# Prebuilt kernel modules taken from the stock recovery ramdisk.
# They MUST match prebuilt/kernel, otherwise display/touch/storage will not work.
# NOTE: no spaces after the commas in $(call ...); make keeps them in the
# arguments and the helper's regex would no longer match, producing
# "malformed COPY_FILE" errors.
PRODUCT_PACKAGES += \
    $(addprefix kernel-module-,$(basename $(notdir $(wildcard $(LOCAL_PATH)/prebuilt/modules/*.ko))))
# fastbootd (dynamic partitions)
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd
