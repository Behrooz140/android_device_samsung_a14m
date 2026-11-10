#
# Device tree for Samsung Galaxy A14 4G (SM-A145P / a14m)
# MediaTek MT6768 (Helio G80/G85) - Android 15 (One UI 7)
#
# Everything in prebuilt/ was extracted from the stock recovery.img:
#   A145PXXSDDZH1 / AP3A.240905.015.A2 / 2026-07-05
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/a14m

# ----------------------------------------------------------------------------
# Build / minimal manifest
# ----------------------------------------------------------------------------
ALLOW_MISSING_DEPENDENCIES := true

# ----------------------------------------------------------------------------
# Architecture
# ----------------------------------------------------------------------------
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# ----------------------------------------------------------------------------
# Bootloader / platform
# ----------------------------------------------------------------------------
TARGET_BOOTLOADER_BOARD_NAME := a14m
TARGET_BOARD_PLATFORM := mt6768
TARGET_NO_BOOTLOADER := true

# ----------------------------------------------------------------------------
# Display
# ----------------------------------------------------------------------------
TARGET_SCREEN_DENSITY := 450
TARGET_USES_VULKAN := true

# ----------------------------------------------------------------------------
# Kernel (prebuilt from stock recovery.img)
# ----------------------------------------------------------------------------
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 loop.max_part=7 androidboot.selinux=permissive
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x07c08000
BOARD_KERNEL_TAGS_OFFSET := 0x0bc08000
BOARD_KERNEL_IMAGE_NAME := Image.gz

# Compress the recovery ramdisk exactly like the stock image (legacy LZ4).
# The stock kernel has CONFIG_RD_LZ4=y and CONFIG_RD_GZIP=y, so this is not
# strictly required, but keeping the stock format removes one variable.
BOARD_RAMDISK_USE_LZ4 := true

BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
# Match the stock boot header exactly (mkbootimg defaults differ):
#   stock dtb_addr = base + 0x0bc08000 = 0x4bc80000
#   stock board/name = "SRPVJ12A013"
#   stock os_version = 15.0.0, os_patch_level = 2026-07
BOARD_MKBOOTIMG_ARGS += --dtb_offset 0x0bc08000
BOARD_MKBOOTIMG_ARGS += --board SRPVJ12A013
BOARD_MKBOOTIMG_ARGS += --os_version 15.0.0 --os_patch_level 2026-07

TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)

BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
BOARD_INCLUDE_RECOVERY_DTBO := true

# ----------------------------------------------------------------------------
# Partitions
# ----------------------------------------------------------------------------
BOARD_FLASH_BLOCK_SIZE := 262144 # 4096 * 64
BOARD_BOOTIMAGE_PARTITION_SIZE := 80740352
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 80740352

BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor

# Dynamic partitions (super)
BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_SUPER_PARTITION_GROUPS := samsung_dynamic_partitions
BOARD_SAMSUNG_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    vendor \
    product \
    odm \
    system_ext \
    vendor_dlkm \
    odm_dlkm
BOARD_SAMSUNG_DYNAMIC_PARTITIONS_SIZE := 9122611200

# ----------------------------------------------------------------------------
# Recovery
# ----------------------------------------------------------------------------
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USES_MKE2FS := true

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# ----------------------------------------------------------------------------
# Verified boot
# ----------------------------------------------------------------------------
# NOTE: stock firmware is AVB-signed. The image produced with the test key
# will NOT verify against the stock Samsung key. Bootloader must be unlocked
# and dm-verity/verification disabled (patched vbmeta) or this recovery will
# not boot. See README.md.
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

# Prevent anti-rollback from blocking the custom image
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31
PLATFORM_VERSION := 16.1.0

# ----------------------------------------------------------------------------
# TWRP
# ----------------------------------------------------------------------------
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_DEVICE_VERSION := a14m
TW_SCREEN_BLANK_ON_BOOT := true
TW_NO_SCREEN_BLANK := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true

# Display / backlight (mediatek,lcd-backlight, max 0xff)
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 160

# Samsung specifics
TW_NO_REBOOT_BOOTLOADER := true
TW_HAS_DOWNLOAD_MODE := true

# Tools / features
TW_INCLUDE_FASTBOOTD := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_NTFS_3G := true
TW_EXCLUDE_TWRPAPP := true
RECOVERY_SDCARD_ON_DATA := true

# ----------------------------------------------------------------------------
# Crypto (FBE / metadata) - disabled on purpose
# ----------------------------------------------------------------------------
# Samsung One UI uses hardware-wrapped FBE keys (KeyMint/TEE). Decryption needs
# Samsung's proprietary KeyMint/tee libraries from vendor.img and is not
# included here. Enable these only after adding the matching blobs:
#
# TW_INCLUDE_CRYPTO := true
# TW_INCLUDE_CRYPTO_FBE := true
# TW_INCLUDE_FBE_METADATA_DECRYPT := true
# TW_USE_FSCRYPT_POLICY := 2
