#!/system/bin/sh
# Take the device model from Samsung's bootloader.
#
# PRODUCT_MODEL is fixed at build time, but one image serves every a14m
# variant (SM-A145P, SM-A145R, ...).  Samsung's bootloader passes the real
# model as androidboot.em.model, which shows up as ro.boot.em.model, so copy
# it into the ro.product.*model properties that the build defined.  Runs from
# init before adbd starts, so the adb banner ("model:...") is right as well.
model=$(getprop ro.boot.em.model)
[ -n "$model" ] || exit 0

for p in ro.product.model \
         ro.product.odm.model \
         ro.product.product.model \
         ro.product.system.model \
         ro.product.system_ext.model \
         ro.product.vendor.model; do
	[ -n "$(getprop "$p")" ] && /system/bin/resetprop "$p" "$model"
done
exit 0
