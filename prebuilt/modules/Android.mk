LOCAL_PATH := $(call my-dir)

_kernel_modules := $(notdir $(wildcard $(LOCAL_PATH)/*.ko))

define build-kernel-module
include $$(CLEAR_VARS)
LOCAL_MODULE := kernel-module-$(basename $(1))
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_PATH := $$(TARGET_RECOVERY_ROOT_OUT)/lib/modules
LOCAL_SRC_FILES := $(1)
LOCAL_MODULE_STEM := $(1)
include $$(BUILD_PREBUILT)
endef

$(foreach module,$(_kernel_modules),$(eval $(call build-kernel-module,$(module))))
