#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit common TWRP configuration.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from a14m device.
$(call inherit-product, device/samsung/a14m/device.mk)

PRODUCT_DEVICE := a14m
PRODUCT_NAME := twrp_a14m
PRODUCT_BRAND := samsung
# Fallback only: at boot, model_from_bootloader.sh replaces the ro.product.*model
# properties with the bootloader's ro.boot.em.model (SM-A145P, SM-A145R, ...).
PRODUCT_MODEL := Galaxy A14 4G
PRODUCT_MANUFACTURER := samsung

PRODUCT_GMS_CLIENTID_BASE := android-samsung

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="a14mnnxx-user 15 AP3A.240905.015.A2 A145PXXSDDZH1 release-keys"

BUILD_FINGERPRINT := samsung/a14mnnxx/a14m:15/AP3A.240905.015.A2/A145PXXSDDZH1:user/release-keys
