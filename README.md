# TWRP Device Tree — Samsung Galaxy A14 4G (SM-A145P / `a14m`)

درخت دستگاه (device tree) اختصاصی برای ساخت **TWRP 12.1** روی
**Samsung Galaxy A14 4G — SM-A145P**، بر پایهٔ فایل ریکاوری استوک خودِ گوشی.

> **وضعیت: بیلد ۲۰ روی گوشی تست شده و کار می‌کند.**
> بوت، نمایشگر، تاچ، ذخیره‌سازی، پارتیشن‌های منطقی `super`،
> `Install Image` روی پارتیشن‌های منطقی، دیده‌شدن آن‌ها در
> **Advanced Wipe** و **Reboot → Recovery** همگی درست کار می‌کنند.
>
> تنها محدودیت باقی‌مانده **رمزگشایی `/data`** است که از پارتیشن
> `recovery` عملاً غیرممکن است (بخش ۹). این محدودیت ناشی از رفتار
> بوت‌لودر است، نه اشکال درخت.

ریپازیتوری: `https://github.com/Behrooz140/android_device_samsung_a14m`

---

## ۱) وضعیت امکانات

| امکان | وضعیت | توضیح |
|---|---|---|
| بوت TWRP از پارتیشن `recovery` | ✅ | هدر بوت دقیقاً مطابق استوک |
| نمایشگر و روشنایی | ✅ | `TW_BRIGHTNESS_PATH` روی backlight واقعی |
| تاچ (Himax HX83112) | ✅ | فریمور تاچ داخل رم‌دیسک قرار دارد |
| خواندن/نوشتن MicroSD | ✅ | `/external_sd` (exFAT/vfat) |
| حافظهٔ داخلی `/sdcard` | ⚠️ | فقط وقتی `/data` مانت شود |
| پارتیشن‌های منطقی `super` | ✅ | مانت فقط‌خواندنی + `flashimg=1` |
| `Install Image` روی `system`/`vendor`/… | ✅ | پچ ۰۰۰۸ |
| دیده‌شدن پارتیشن‌های منطقی در Advanced Wipe | ✅ | پچ ۰۰۱۲ + `wipeingui` |
| پاک‌کردن فایل‌سیستم روی `super` | ⚠️ | متادیتای `super` سامسونگ فقط‌خواندنی است |
| Backup پارتیشن‌های منطقی | ❌ (عمدی) | TWRP برای `super` بکاپ را می‌بندد؛ از ایمیج استوک استفاده کنید |
| `Reboot → Recovery` | ✅ | پچ ۰۰۱۳ + نوشتن مستقیم BCB |
| `Reboot → Fastboot` | ✅ | پچ ۰۰۱۴: اجرای مجدد خود TWRP با `--fastboot` |
| دمای CPU در نوار بالا | ✅ | پچ ۰۰۱۶: پیدا کردن زون `mtktscpu` با نام |
| ویبره (هپتیک) | ✅ | پچ ۰۰۱۷: انتخاب تریگر LED `transient` |
| پاک‌کردن Dalvik / ART Cache | ⚠️ | پچ ۰۰۱۵؛ `/cache` پاک می‌شود، `dalvik-cache` داخل `/data` رمزنگاری‌شده در دسترس نیست |
| `Reboot → System` | ✅ | |
| fastbootd / repacktools / lptools | ✅ | |
| رمزگشایی `/data` | ❌ | بوت‌لودر در حالت ریکاوری TEE را بالا نمی‌آورد |
| APEX | حذف‌شده | `TW_EXCLUDE_APEX := true` |

---

## ۲) مشخصات دستگاه

| مورد | مقدار |
|---|---|
| مدل | Samsung Galaxy A14 4G |
| کد دستگاه | `SM-A145P` |
| کدنام | `a14m` (نام محصول سامسونگ: `a14mnnxx`) |
| چیپست | MediaTek **MT6768** (Helio G80/G85) |
| معماری | arm64-v8a + armeabi-v7a (`cortex-a55`) |
| اندروید | ۱۵ / One UI 7 |
| بیلد استوک | `A145PXXSDDZH1` / `AP3A.240905.015.A2` |
| پچ امنیتی | `2026-07-05` |
| فرگمنت | `samsung/a14mnnxx/a14m:15/AP3A.240905.015.A2/A145PXXSDDZH1:user/release-keys` |
| پارتیشن ریکاوری | `80,740,352` بایت (p40) |
| پارتیشن `super` | `9,126,805,504` بایت (p46) |

نمایشگر: پنل‌های `BOE / TXD / INX / JDI` با درایورهای `hx83112f`, `jd9522t`,
`nl9922c`, `td4375`.
تاچ: `himax HX83112`، `jadard JD9522T`، `chipone` و `focaltech`.

---

## ۳) منبع prebuiltها و هدر بوت

همهٔ فایل‌های زیر **از `recovery.img` استوک خودِ گوشی** استخراج شده‌اند
(نه از اینترنت و نه از دستگاه مشابه). بنابراین کرنل، DTB/DTBO و ماژول‌ها
دقیقاً با سخت‌افزار همین بیلد هم‌خوان هستند.

| فایل | اندازه | MD5 | توضیح |
|---|---:|---|---|
| `prebuilt/kernel` | 13,975,532 | `933b3c79216a10cd47b5c93ce16e10e9` | `Image.gz` استوک (gzip) |
| `prebuilt/dtb.img` | 182,127 | `ab5bacb2fe7589c25026e21ab718e5ef` | DTB پایهٔ MT6768 |
| `prebuilt/dtbo.img` | 79,837 | `08eba6a650cffcad2e8209398b135364` | DTBO برد `A14M MEA OPEN 00` |
| `prebuilt/modules/` | 25 MB | — | ۱۹۸ فایل `.ko` + `modules.alias`, `modules.dep`, `modules.softdep`, `modules.load.recovery` |

هدر بوت خروجی باید **بایت‌به‌بایت** با استوک یکی باشد:

```
header version : 2
page size      : 4096
kernel  addr   : 0x40080000
ramdisk addr   : 0x47C80000
tags    addr   : 0x4BC80000
dtb     addr   : 0x4BC80000
cmdline        : bootopt=64S3,32N2,64N2 loop.max_part=7
board name     : SRPVJ12A013
os version     : 15.0.0 / 2026-07
ramdisk format : LZ4 (legacy frame)
```

این مقادیر در `BoardConfig.mk` صریحاً تنظیم شده‌اند
(`--board SRPVJ12A013`, `--dtb_offset 0x0bc08000`,
`--os_version 15.0.0 --os_patch_level 2026-07`, `BOARD_RAMDISK_USE_LZ4`).
تغییر هرکدام باعث می‌شود بوت‌لودر تصویر را رد کند یا کرنل ramdisk را
پیدا نکند.

> ماژول‌ها **باید** با `prebuilt/kernel` هم‌نسل باشند؛ اگر کرنل را عوض کنید
> (مثلاً کرنل کاستوم)، این ماژول‌ها دیگر لود نمی‌شوند و نمایشگر، تاچ،
> ذخیره‌سازی و USB از کار می‌افتند.

---

## ۴) ساختار درخت

```
device/samsung/a14m/
├── .github/workflows/build-twrp.yml ← ورک‌فلو ساخت روی GitHub Actions
├── .gitignore
├── Android.bp / Android.mk / AndroidProducts.mk
├── BoardConfig.mk              ← کرنل، پارتیشن‌ها، AVB و فلگ‌های TWRP
├── device.mk                   ← کپی فایل‌های رم‌دیسک و ماژول‌ها
├── twrp_a14m.mk                ← محصول twrp_a14m
├── vendorsetup.sh
├── recovery.fstab              ← fstab مخصوص TWRP (فرمت v2)
├── prebuilt/
│   ├── kernel                  ← Image.gz استوک
│   ├── dtb.img                 ← DTB پایهٔ استوک
│   ├── dtbo.img                ← DTBO استوک
│   └── modules/                ← ۱۹۸ ماژول کرنل استوک + وابستگی‌ها
├── decrypt/                    ← بخش نرم‌افزاری رمزگشایی /data
│   ├── Android.bp              ← تعریف langsdorff_decrypt و gk_verify
│   ├── langsdorff_decrypt.cpp  ← بازکردن FBE v2 + متادیتا با KeyMint
│   └── gk_verify.cpp           ← تأیید رمز با gatekeeper هیدل ۱.۰
├── patches/                    ← پچ‌های سورس TWRP (۰۰۰۱ تا ۰۰۱۷)
├── recovery/root/
│   ├── init.recovery.mt6768.rc ← USB، TEE، سرویس decrypt، diag
│   ├── init.recovery.samsung.rc← آماده‌سازی efs
│   ├── sbin/twrp-diag.sh       ← جمع‌آوری لاگ تشخیصی
│   ├── system/bin/             ← decrypt.sh، data_release.sh،
│   │                             fstab_crypto.sh، rebootrecovery.sh، …
│   ├── system/etc/init/        ← فایل‌های rc استوک (dsms, snapuserd, …)
│   ├── system/etc/twrp.flags   ← ورودی‌های اختیاری (USB-OTG)
│   └── system/tee/             ← پشتهٔ TEE سامسونگ برای تلاش رمزگشایی
└── tools/
    ├── extract_from_recovery.sh← استخراج مجدد prebuiltها
    └── stock_recovery.fstab    ← fstab استوک برای مقایسه
```

فایل‌های `recovery/root/...` با `PRODUCT_COPY_FILES` به
`out/target/product/a14m/recovery/root/...` کپی می‌شوند و داخل رم‌دیسک
قرار می‌گیرند. ماژول‌ها در `recovery/root/lib/modules/` می‌نشینند؛ همان
مسیری که init در حالت ریکاوری برای `modules.load.recovery` جست‌وجو می‌کند.

پچ‌ها عمداً داخل خود ریپازیتوری هستند؛ ورک‌فلو پیش از ساخت آن‌ها را روی
سورس TWRP اعمال می‌کند و لازم نیست نسخهٔ دستی‌کاری‌شدهٔ TWRP نگه‌داری شود.

---

## ۵) ساخت با GitHub Actions (روش اصلی)

ورک‌فلو آماده در `.github/workflows/build-twrp.yml` قرار دارد و همان روشی
است که همهٔ بیلدهای تست‌شده با آن ساخته شده‌اند.

مراحل:

1. ریپازیتوری را باز کنید → تب **Actions** → workflow
   **Build TWRP (a14m)**.
2. **Run workflow** را بزنید و ورودی‌ها را انتخاب کنید:
   - `variant`: `eng` (پیش‌فرض) یا `userdebug`
   - `target`: `recoveryimage` (برای این گوشی) یا `bootimage`
3. پس از پایان (تقریباً ۱ تا ۲ ساعت، سقف ۳۵۰ دقیقه) از بخش
   **Artifacts** این فایل‌ها را دانلود کنید:
   - `recovery.img` — تصویر خام
   - `twrp_a14m.tar.md5` — بستهٔ آمادهٔ Odin (اسلات AP)
   - `MD5SUMS.txt` و `SHA256SUMS.txt`

نام Artifact به شکل `twrp-a14m-<شمارهٔ اجرا>` است؛ شمارهٔ اجرای بیلد
تست‌شده **۲۰** است.

آنچه ورک‌فلو انجام می‌دهد:

- آماده‌سازی وابستگی‌های AOSP، `repo` و فضای دیسک
- `repo init/sync` روی منیفست
  `minimal-manifest-twrp/platform_manifest_twrp_aosp` شاخهٔ `twrp-12.1`
  (نسخهٔ `--depth=1`)
- کپی درخت دستگاه به `device/samsung/a14m`
- اعمال **همهٔ** `patches/*.patch` روی `bootable/recovery`:

  ```bash
  patch -p1 --forward --fuzz=3 -d bootable/recovery < patches/0001-....patch
  ```

- ساخت با `lunch twrp_a14m-eng` و `mka recoveryimage`
- ساخت پکیج Odin (tar + MD5) و آپلود Artifact

نکات:

- کش `ccache` عمداً استفاده نمی‌شود؛ در رانر GitHub روی
  `~/.ccache/tmp` خطای `Read-only file system` می‌داد.
- اگر تگ `v*` پوش کنید، علاوه بر Artifact یک **GitHub Release** هم ساخته
  می‌شود:
  ```bash
  git tag v1.0.0 && git push origin v1.0.0
  ```
- در صورت شکست بیلد، Artifactی به نام `build-logs-<run>` شامل
  `verbose.log.gz` و `error.log` آپلود می‌شود.
- اجرای خودکار روی هر push به‌صورت پیش‌فرض خاموش است (هر اجرا از سهمیهٔ
  Actions کم می‌کند)؛ برای فعال‌کردن، بلوک `push.branches` را در فایل
  workflow از کامنت خارج کنید.

---

## ۶) ساخت محلی (اختیاری)

```bash
mkdir -p ~/twrp && cd ~/twrp

repo init --depth=1 \
  -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git \
  -b twrp-12.1
repo sync -j"$(nproc)" --force-sync --no-clone-bundle --no-tags

ln -s /root/device/samsung/a14m device/samsung/a14m

# پچ‌ها را دستی اعمال کنید (ورک‌فلو این کار را خودکار انجام می‌دهد)
shopt -s nullglob
for p in device/samsung/a14m/patches/*.patch; do
  echo "--- $p"
  patch -p1 --forward --fuzz=3 -d bootable/recovery < "$p"
done

. build/envsetup.sh
lunch twrp_a14m-eng
mka recoveryimage -j"$(nproc)"
```

خروجی: `out/target/product/a14m/recovery.img`

پیش‌نیازها: لینوکس ۶۴ بیتی، حدود ۱۰۰ گیگ فضای آزاد، ۸ تا ۱۶ گیگ رم،
و `git`, `repo`, `python3`, `lz4`, `cpio`, `openjdk-11`.

---

## ۷) نصب روی گوشی

### ۷.۱ آماده‌سازی

1. حساب سامسونگ و قفل صفحه را بردارید.
2. `OEM unlocking` را در Developer options فعال کنید.
3. گوشی را به اینترنت وصل کنید تا **KG State = Checking** و
   **RMM State = Normal** شود؛ در غیر این صورت Odin فلش را بلاک می‌کند
   و ممکن است ۷ روز انتظار لازم باشد.
4. با `Volume Down + Volume Up` + کابل USB وارد **Download Mode** شوید و
   قفل بوت‌لودر را باز کنید (همهٔ داده‌ها پاک می‌شود).
5. یک بار وارد سیستم شوید و Developer options را دوباره بررسی کنید.

### ۷.۲ غیرفعال کردن AVB — اجباری

`recovery.img` استوک با کلید سامسونگ امضا شده و `vbmeta` گوشی هشِ همان
تصویر را نگه می‌دارد. تصویری که این درخت می‌سازد با **کلید تست AOSP**
امضا می‌شود؛ تا وقتی `vbmeta` استوک روی گوشی است، بوت‌لودر تصویر را رد
می‌کند و نتیجه لوگوی سامسونگ و ریبوت است.

روش مطمئن برای سامسونگ (بدون نیاز به fastboot):

1. فریمور کامل و **دقیقاً همان بیلد** گوشی را دانلود کنید
   (`AP_...tar.md5` از SamFW / SamMobile).
2. اپ **Magisk** را روی گوشی نصب کنید.
3. در Magisk: `Install` → `Select and Patch a File` → فایل
   `AP_....tar.md5` را انتخاب کنید تا `boot.img` و `vbmeta.img` پچ شوند.
4. فایل خروجی `magisk_patched-....tar` را با Odin در اسلات **AP** فلش
   کنید و `Auto Reboot` را بردارید.
5. بعد از `PASS`، بلافاصله با `Volume Up + Power` وارد ریکاوری شوید.

اگر روت نمی‌خواهید: از همان خروجی فقط `vbmeta.img` را بیرون بکشید و
تنها همان را در یک tar فلش کنید.

### ۷.۳ فلش ریکاوری

فایل `twrp_a14m.tar.md5` که Artifact تولید می‌کند مستقیماً آمادهٔ Odin است:

```
Odin → Options: Auto Reboot را بردارید
Odin → AP: twrp_a14m.tar.md5 → Start
```

اگر خودتان می‌خواهید بسازید:

```bash
tar -cf twrp_a14m.tar recovery.img
md5sum twrp_a14m.tar >> twrp_a14m.tar
mv twrp_a14m.tar twrp_a14m.tar.md5
```

> بعد از فلش، **بلافاصله** با `Volume Up + Power` (کابل جدا) وارد
> ریکاوری شوید تا سیستم استوک فرصت بازنویسی ریکاوری را پیدا نکند.
> در اولین ورود `Swipe to Allow Modifications` را بزنید.

### ۷.۴ به‌روزرسانی TWRP

برای نصب نسخهٔ بعدی لازم نیست Odin را دوباره به کار ببرید؛ فایل
`recovery.img` را روی MicroSD کپی کنید و داخل TWRP از
**Install → Install Image → Recovery** استفاده کنید. سپس
**Reboot → Recovery** را بزنید (بخش ۸.۴).

### ۷.۵ بازگشت به استوک

`recovery.img` استوک را از همان `AP_...tar.md5` بیرون بکشید (یا از بکاپ
خود TWRP) و با Odin در اسلات AP فلش کنید. فلش `boot`/`lk`/`preloader`
لازم نیست و توصیه نمی‌شود.

---

## ۸) امکانات و رفتار پارتیشن‌ها

### ۸.۱ پارتیشن‌های منطقی `super`

هشت پارتیشن منطقی در `recovery.fstab` تعریف شده‌اند:

`system`, `vendor`, `product`, `odm`, `system_ext`, `vendor_dlkm`,
`system_dlkm`, `odm_dlkm`

هر ورودی این فلگ‌ها را دارد:

```
flags=display=<name>;logical;backup=1;flashimg=1;fsflags=ro;wipeingui
```

- **`fsflags=ro` الزامی است.** سامسونگ این پارتیشن‌ها را در متادیتای
  `super` با اتریبیوت فقط‌خواندنی (`liblp attr=0x1`) علامت زده است؛
  دستگاه‌های `dm-*` فقط‌خواندنی‌اند و مانت بدون `MS_RDONLY` با
  `EACCES (Permission denied)` شکست می‌خورد.
- **`flashimg=1`** اجازه می‌دهد با `Install Image` یک ایمیج خام
  (`system.img`, `vendor.img`, …) مستقیم روی همان پارتیشن منطقی نوشته
  شود؛ پچ ۰۰۰۸ اندازهٔ ایمیج (ساده یا sparse) را بررسی و آن را روی
  `dm` مربوطه می‌نویسد.
- **`wipeingui`** باعث می‌شود پارتیشن در **Advanced Wipe** دیده شود.
  TWRP هنگام پارس fstab هر پارتیشن `Is_Super` را «غیرقابل پاک‌کردن»
  می‌کند و بعدتر فلگ‌ها را اعمال می‌کند؛ پچ ۰۰۱۲ این رفتار را فقط وقتی
  تغییر می‌دهد که خود fstab صریحاً `wipeingui` خواسته باشد
  (`Wipe_Available_in_GUI`). بکاپ برای این پارتیشن‌ها همچنان بسته است
  (`Set_Can_Be_Backed_Up(false)`) و در منوی Backup ظاهر نمی‌شوند.
- **پاک‌کردن فایل‌سیستم** روی `super` فقط وقتی موفق می‌شود که متادیتای
  `super` قابل نوشتن باشد؛ در این گوشی نیست. برای بازگرداندن یک پارتیشن
  از `Install Image` استفاده کنید، نه Wipe.
- خود پارتیشن `/super` هم توسط TWRP به‌صورت یک ورودی جداگانه اضافه
  می‌شود (پچ ۰۰۰۲ اندازهٔ آن را از روی بلوک‌دستگاه می‌خواند) و برای
  dd/بکاپ خام در دسترس است.

### ۸.۲ تصاویر بوت و ریکاوری

`boot`, `recovery`, `init_boot`, `vendor_boot`, `dtbo` با `flashimg=1`
و `backup=1` تعریف شده‌اند؛ می‌توانید بکاپ ایمیج بگیرید یا ایمیج جدید
بنویسید. `misc` فقط برای نمایش/خواندن است و عمداً `backup` ندارد تا
BCB ریکاوری اشتباهی بازگردانی نشود.

### ۸.۳ Advanced Wipe و پارتیشن‌های حساس

- قابل پاک‌کردن: `/data`, `/cache`, `/metadata`, `/external_sd` و
  پارتیشن‌های منطقی (با محدودیت بخش ۸.۱).
- **هرگز** روی `efs`, `persist`, `nvdata` گزینهٔ wipe فعال نشده است؛
  این‌ها IMEI، کالیبراسیون رادیو و دادهٔ سنسورها را نگه می‌دارند و پس از
  پاک‌شدن قابل بازیابی نیستند. این پارتیشن‌ها فقط برای بکاپ و مانت
  فقط‌خواندنی (`fsflags=ro`) در fstab هستند.
- `/prism`, `/optics`, `/md1img`, `/spmfw`, `/scp1`, `/sspm_1` فقط
  برای نمایش/بکاپ تعریف شده‌اند.
- `/efs` در زمان تلاش رمزگشایی به‌صورت موقت `remount,rw` می‌شود، چون
  TEEGRIS و gatekeeper روی استوک هم روی همین پارتیشن‌ها می‌نویسند؛ این
  کار فقط داخل `decrypt_stack.sh` انجام می‌شود و روی رفتار منوی Wipe
  اثری ندارد.

### ۸.۴ مکانیزم `Reboot → Recovery`

در این گوشی `Reboot → Recovery` با مسیر معمول init کار **نمی‌کرد**:
TWRP فایل `/etc/recovery.fstab` را با فرمت خودش (نه `fs_mgr`) جایگزین
می‌کند، بنابراین `read/write_bootloader_message()` در init شکست می‌خورد،
init بدون ریبوت برمی‌گردد و چون سرویس `recovery` در
`init.recovery.service.rc` گزینهٔ `oneshot` ندارد، init دوباره همان TWRP
را اجرا می‌کند؛ نتیجه «ریبوت نرم» بدون لوگوی سامسونگ بود.

اصلاح (پچ ۰۰۱۳ + اسکریپت):

1. `rebootrecovery.sh` خودش BCB را در `/dev/block/by-name/misc` می‌نویسد:
   `command[32]` و `status[32]` صفر می‌شوند و رشتهٔ `boot-recovery`
   نوشته می‌شود؛ سپس با `od` بررسی و در `/tmp/rebootrecovery.log`
   ثبت می‌شود.
2. `tw_reboot(rb_recovery)` به‌جای تکیه بر init، مستقیماً
   `syscall(__NR_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
   LINUX_REBOOT_CMD_RESTART2, "recovery")` را صدا می‌زند.
3. اگر syscall رد شود، به `property_set(ANDROID_RB_PROPERTY, "reboot,")`
   برمی‌گردد؛ BCB نوشته‌شده همچنان بوت‌لودر را به ریکاوری می‌فرستد.

شاهد این عملیات در نشست بعدی در
`/sdcard/twrp-diag/rebootrecovery.log` (یا `/external_sd/twrp-diag/` و
`/cache/twrp-diag/`) موجود است.

### ۸.۵ ریبوت به Fastboot، دمای CPU، ویبره و Dalvik

**`Reboot → Fastboot`** (پچ ۰۰۱۴): init برای هدف `fastboot` هم باید BCB
بنویسد و همان مشکل بخش ۸.۴ را دارد؛ پس دوباره «ریبوت نرم» می‌شد.
fastbootd داخل همین باینری `recovery` است و فقط آرگومان `--fastboot`
می‌خواهد؛ بنابراین TWRP به‌جای تکیه بر init، خودش را با
`execl("/system/bin/recovery", "recovery", "--fastboot")` دوباره اجرا
می‌کند. کرنل عوض نمی‌شود، init همان PID را زنده می‌بیند و مستقیم وارد
صفحهٔ Fastboot می‌شوید.

**دمای CPU** (پچ ۰۰۱۶): TWRP به‌طور پیش‌فرض `/sys/class/thermal/thermal_zone0/temp`
را می‌خواند؛ در این گوشی zone0 همان `mtk-master-charger` است و همیشه ۰
برمی‌گرداند. پچ حالا بین همهٔ `thermal_zone*` دنبال `type` برابر
`mtktscpu` (و بعد `mtkcput`/`cpu`/هر چیزی که `cpu` دارد) می‌گردد و مسیر
درست را برمی‌گرداند، پس شمارهٔ زون مهم نیست و دمای واقعی (مثلاً ۵۱°C)
نمایش داده می‌شود.

**ویبره** (پچ ۰۰۱۷): فایل‌های `duration`، `activate` و `state` مربوط به
تریگر LED با نام `transient` هستند، نه خود درایور
`regulator-vibrator`. اندروید در بوت عادی با lights HAL این تریگر را
انتخاب می‌کند، ولی در ریکاوری هیچ‌کس انتخاب نمی‌کند؛ در نتیجه این
فایل‌ها اصلاً وجود ندارند و TWRP بی‌صدا هیچ چیز نمی‌نوشت. پچ پیش از
نوشتن، تریگر `transient` را انتخاب می‌کند و اگر در دسترس نبود به
`/sys/class/timed_output/vibrator/enable` و سپس به `brightness` برمی‌گردد.

**Dalvik / ART Cache** (پچ ۰۰۱۵): تابع `Wipe_Dalvik_Cache()` با شکست
مانت `/data` کل عملیات را `false` برمی‌گرداند و فقط پیام کلی
«Failed to wipe dalvik» می‌داد. حالا ابتدا مسیرهای `/cache/recovery/…`
پاک می‌شوند و اگر `/data` مانت نشود، پیام دقیق «Unable to mount /data»
نمایش داده می‌شود و بقیهٔ عملیات Wipe ادامه پیدا می‌کند. خودِ
`dalvik-cache` داخل `/data` رمزنگاری‌شده است و تا وقتی ریکاوری نمی‌تواند
`/data` را باز کند (بخش ۹) قابل پاک‌کردن نیست؛ پاک‌کردن کامل آن فقط از
داخل اندروید (با root) یا پس از فعال‌شدن رمزگشایی ممکن است.

### ۸.۶ حافظهٔ داخلی و MicroSD

- MicroSD روی `/external_sd` مانت می‌شود و با exFAT، vfat و ext4 کار
  می‌کند؛ TWRP هنگام مانت خودش فایل‌سیستم را تشخیص می‌دهد.
- `/sdcard` به `/data/media/0` نگاشت می‌شود
  (`RECOVERY_SDCARD_ON_DATA := true`) و فقط وقتی `/data` مانت شده باشد
  در دسترس است. بکاپ‌ها را روی MicroSD بگذارید.

### ۸.۷ ابزارهای همراه

`fastbootd`, `repacktools`, `lptools`, `resetprop`/`libresetprop`,
`ntfs-3g` و `TW_EXCLUDE_TWRPAPP` در `BoardConfig.mk` فعال/غیرفعال
شده‌اند. APEX loader عمداً حذف شده است، چون روی کرنل ۶.۶ این دستگاه با
خطای `Value too large for defined data type` شکست می‌خورد و
`twrp.apex.loaded=false` تولید می‌کرد؛ هیچ‌چیز در این ریکاوری به
کتابخانه‌های APEX نیاز ندارد.

### ۸.۸ لاگ تشخیصی

سرویس `twrpdiag` (oneshot، از `init.recovery.mt6768.rc`) اسکریپت
`/sbin/twrp-diag.sh` را اجرا می‌کند. حدود ۴۵ ثانیه پس از بوت، این
فایل‌ها در اولین مقصد قابل نوشتن ذخیره می‌شوند:

| مسیر | توضیح |
|---|---|
| `/sdcard/twrp-diag/` | فقط اگر `/data` مانت شده باشد |
| `/external_sd/twrp-diag/` | MicroSD (پایدارترین) |
| `/cache/twrp-diag/` | پارتیشن cache |
| `/metadata/twrp-diag/` | `md_udc`، بدون رمز و پایدار |
| `/tmp/twrp-diag/` | فقط همین نشست |

فایل‌های مهم:

- `diag.txt` — dmesg، ماژول‌های لودشده، دستگاه‌های ورودی/i2c، مانت‌ها،
  وضعیت TEE و رمزگشایی، همهٔ زون‌های حرارتی، وضعیت ویبره (تریگر و
  `duration`/`activate`/`state`)، تنظیمات هپتیک/دمای TWRP، و ۱۲۸ بایت
  اول `misc`/`boot_para`/`para`
- `recovery.log` — لاگ خود TWRP
- `last_kmsg.txt` — لاگ کرنل نشست قبل (برای بررسی ریبوت)
- `rebootrecovery.log` — شاهد نوشتن BCB
- `decrypt.log`, `fstab_crypto.log` — جزئیات تلاش رمزگشایی
- `SAVED-TO.txt` — فهرست مقاصدی که فایل‌ها در آن‌ها ذخیره شده‌اند

برای ارسال، معمولاً همان `diag.txt` کافی است؛ اگر خالی نبود
`recovery.log` هم مفید است.

---

## ۹) محدودیت رمزگشایی `/data`

اندروید ۱۵ سامسونگ برای `/data` هم **FBE v2** و هم **رمزنگاری متادیتا**
(`dm-default-key`) دارد: کل بلوک‌های خام `userdata` با کلیدی رمز شده‌اند
که در `/metadata` (`md_udc`, p29) نگه‌داری می‌شود. برای بازکردن آن باید
پشتهٔ امنیتی سامسونگ (TEEGRIS، KeyMint، gatekeeper) بالا بیاید.

درخت این پشته را همراه دارد و تلاش می‌کند آن را از پارتیشن `recovery`
اجرا کند:

- `decrypt/langsdorff_decrypt.cpp` — بازکردن KeyMint و ساخت
  `dm-default-key` روی `userdata`
- `decrypt/gk_verify.cpp` — تأیید رمز با gatekeeper هیدل ۱.۰
- `recovery/root/system/bin/decrypt.sh`, `decrypt_stack.sh`,
  `fstab_crypto.sh`, `data_release.sh`
- `recovery/root/system/tee/` — کتابخانه‌ها و باینری‌های TEE

اما شواهد لاگ‌ها نشان می‌دهد **بوت‌لودر در حالت ریکاوری عمداً TEE را
بالا نمی‌آورد**:

```
BOOTPROF: ... lk=6183, tfa=0, sec_os=0, gz=0
log_store: bootmode: 0x2
[rpmb] Recovery or Charging boot. Do not run TEEgris RPMB
TZDEV ERR tz_iwsock_connect(624): Failed to connect socket root_task, error=-111
```

یعنی `tfa=0` و `sec_os=0` و پیام صریح «در بوت ریکاوری TEEGRIS را اجرا
نکن». نتیجه این است که KeyMint/gatekeeper در دسترس نیستند و هیچ
تغییری در کرنل یا رم‌دیسک نمی‌تواند این را جبران کند؛ محدودیت در
پارتیشن `lk` (بوت‌لودر) است.

پیامدها:

- TWRP نمی‌تواند `/data` رمزنگاری‌شده را باز کند؛ `/sdcard` هم در
  دسترس نیست.
- برای بکاپ از **MicroSD** (`/external_sd`) یا USB-OTG استفاده کنید.
- اگر داده‌ها مهم نیستند، `Format Data` بزنید تا `/data` با کلید تازه
  قابل استفاده شود.
- تنها مسیر فنی ممکن برای رمزگشایی، اجرای TWRP از پارتیشن `boot` در
  بوت عادی است (که TEE بالا می‌آید) یا تغییر `lk`؛ هیچ‌کدام در این
  نسخه انجام نشده و ریسک خودشان را دارند.

---

## ۱۰) عیب‌یابی

| نشانه | علت احتمالی | کار |
|---|---|---|
| لوگوی سامسونگ و ریبوت | `vbmeta` استوک | بخش ۷.۲ |
| صفحه سیاه ولی `adb devices` جواب می‌دهد | روشنایی/پنل یا ماژول | `diag.txt` و `TW_BRIGHTNESS_PATH` را بررسی کنید |
| تاچ کار نمی‌کند | پنل/تاچ نسخهٔ دیگر | `diag.txt` و جایگزینی ماژول‌های همان فریمور |
| `Reboot → Recovery` بدون لوگو و سریع | BCB نوشته نشده | `misc` را در `diag.txt` ببینید؛ نسخهٔ دارای پچ ۰۰۱۳ را فلش کنید |
| `Reboot → Fastboot` باز TWRP را بالا می‌آورد | init/BCB و فست‌بوت‌د | نسخهٔ دارای پچ ۰۰۱۴ را فلش کنید |
| دمای CPU همیشه ۰ | خواندن `thermal_zone0` (شارژر) | پچ ۰۰۱۶؛ `diag.txt` را ببینید |
| ویبره در ریکاوری کار نمی‌کند | تریگر `transient` انتخاب نشده | پچ ۰۰۱۷؛ مقدار `trigger` را در `diag.txt` ببینید |
| Dalvik پاک نمی‌شود یا «Failed to wipe dalvik» | `/data` مانت نمی‌شود | پچ ۰۰۱۵؛ `dalvik-cache` داخل `/data` رمزنگاری‌شده بدون رمزگشایی در دسترس نیست |
| `/data` مانت نمی‌شود | رمزنگاری متادیتا | طبیعی است؛ بخش ۹ |
| پارتیشن منطقی در Wipe نیست | `wipeingui` یا پچ ۰۰۱۲ | نسخهٔ بیلد ۲۰ به بعد را فلش کنید |
| `E:Unhandled flag: 'inlinecrypt'` | توکن ناشناخته در fstab | `inlinecrypt` را به `/data` اضافه نکنید |
| Odin روی `FAIL` می‌ماند | KG/RMM یا `vbmeta`/مدل اشتباه | بخش ۷.۱ |

اگر TWRP بالا می‌آید ولی مشکلی هست، اول `diag.txt` را از MicroSD
بردارید؛ تقریباً همهٔ سؤال‌های «چرا» در همان یک فایل جواب دارند.

---

## ۱۱) فهرست پچ‌ها

پچ‌ها روی `bootable/recovery` (شاخهٔ `android-12.1`) اعمال می‌شوند.
شماره‌های ۰۰۰۴ و ۰۰۰۶ حذف شده‌اند؛ محتوایشان در پچ‌های بعدی ادغام شد.

| پچ | موضوع |
|---|---|
| `0001-decrypt-through-ce-unlock` | هدایت رمز به `decrypt_user.sh` و پشتهٔ TEE به‌جای keymaster 4 HIDL |
| `0002-super-partition-size` | نمایش اندازهٔ واقعی `/super` در صفحهٔ بکاپ |
| `0003-data-on-decrypted-mapper` | مانت `/data` روی `/dev/block/mapper/userdata` پس از رمزگشایی |
| `0005-format-data-raw-partition` | آزادکردن `dm-default-key` پیش از فرمت `/data` |
| `0007-storage-path-after-late-data-mount` | اصلاح `/sdcard` وقتی `/data` دیر مانت می‌شود |
| `0008-flash-image-to-logical-partitions` | نوشتن ایمیج خام/sparse روی پارتیشن‌های منطقی |
| `0009-wait-for-decrypt-during-splash` | صبر برای `decrypt.sh` در اسپلش و تنظیم وضعیت رمز |
| `0010-fscrypt-policies-through-decrypt-refs` | نگاشت policyهای fscrypt v2 در backup/restore |
| `0011-remount-data-under-stale-sdcard-bind` | رفع bind کهنهٔ `/sdcard` روی `/data` |
| `0012-keep-logical-wipe-flags` | احترام به `wipeingui` برای پارتیشن‌های `super` |
| `0013-direct-reboot-recovery` | `LINUX_REBOOT_CMD_RESTART2` مستقیم برای Reboot→Recovery |
| `0014-direct-fastboot-restart` | اجرای مجدد `recovery --fastboot` در همان PID برای Reboot→Fastboot |
| `0015-dalvik-without-data` | پاک‌کردن Dalvik بدون شکست وقتی `/data` مانت نیست |
| `0016-autodetect-cpu-temp-zone` | پیدا کردن زون حرارتی CPU با `type` به‌جای `thermal_zone0` |
| `0017-enable-leds-vibrator-trigger` | انتخاب تریگر `transient` و fallbackهای ویبره |

---

## ۱۲) تغییرات

### بیلد ۲۱ — `75e9a52`

- پچ ۰۰۱۴: **Reboot → Fastboot** با اجرای مجدد `recovery --fastboot`
  در همان PID درست شد؛ دیگر ریبوت نرم به TWRP نداریم.
- پچ ۰۰۱۵: **Wipe Dalvik** دیگر با نبود `/data` کل عملیات را fail
  نمی‌کند؛ مسیرهای `/cache` پاک می‌شوند و پیام دقیق «Unable to mount
  /data» نمایش داده می‌شود.
- پچ ۰۰۱۶: دمای CPU با تشخیص زون `mtktscpu` (و fallbackهای نام‌محور)
  به‌جای `thermal_zone0` نمایش داده می‌شود.
- پچ ۰۰۱۷: ویبره با انتخاب تریگر LED `transient` در ریکاوری کار
  می‌کند؛ fallback به `timed_output` و `brightness`.
- `twrp-diag.sh`: افزودن زون‌های حرارتی، وضعیت ویبره/تریگر، ماژول‌های
  ویبره و تنظیمات هپتیک و دمای TWRP به `diag.txt`.
- خروجی تأییدشده (GitHub Actions run `43210526874`):
  `recovery.img` = `385a68bf44011c9190b621e9c2297d4f`،
  `twrp_a14m.tar.md5` = `cda7490defa69f6c86a1218cbc6ed5d3`.

### بیلد ۲۰ — `363347a`

- پچ ۰۰۱۲: پارتیشن‌های منطقی با `wipeingui` در **Advanced Wipe** دیده
  می‌شوند (بکاپ همچنان مدیریت‌شده).
- پچ ۰۰۱۳: **Reboot → Recovery** با نوشتن BCB و `RESTART2` مستقیم
  درست شد؛ دیگر «ریبوت نرم» به خود TWRP نداریم.
- `rebootrecovery.sh`: پاک‌کردن command/status، نوشتن `boot-recovery`،
  بررسی با `od` و کپی شاهد در `/sdcard`, `/external_sd`, `/cache`.
- `twrp-diag.sh`: افزودن dump پارتیشن‌های `misc`, `boot_para`, `para`
  و کپی `/proc/last_kmsg` و `/tmp/rebootrecovery.log`.
- فلگ `flashimg=1` برای هر هشت پارتیشن منطقی.

### بیلد ۱۹ — `6fae5cf`

- مانت فقط‌خواندنی پارتیشن‌های `super` (`fsflags=ro`) و اصلاح فلگ‌های
  fstab؛ حذف ورودی‌های مرده.
- `efs`/`sec_efs` در زمان رمزگشایی موقتاً read-write می‌شوند.
- بهبود تشخیص و ذخیرهٔ `twrp-diag` روی `/metadata` و MicroSD (exFAT).

### بیلد ۱۸ — `e4e351b` و پیش از آن

- حذف APEX برای رفع خطاهای `twrp.apex.loaded=false`.
- افزودن `flashimg` و تلاش برای نوشتن روی پارتیشن‌های منطقی.
- ساخت پشتهٔ رمزگشایی (KeyMint AIDL + TEEGRIS + gatekeeper) و کشف
  اینکه بوت‌لودر در حالت ریکاوری TEE را اجرا نمی‌کند.

---

## ۱۳) استخراج مجدد prebuiltها

اگر فریمور گوشی را آپدیت کردید:

```bash
cd device/samsung/a14m
./tools/extract_from_recovery.sh /path/to/recovery.img
```

اسکریپت هدر بوت v2 را می‌خواند، آفست‌ها را با page size حساب می‌کند،
`prebuilt/kernel`, `dtbo.img`, `dtb.img` را بیرون می‌کشد، رم‌دیسک را
(gzip/lz4/xz/lzma/bzip2) باز می‌کند و `lib/modules/*` را در
`prebuilt/modules/` می‌ریزد، فایل‌های rc را به‌روز می‌کند و MD5ها را
چاپ می‌کند. پیش‌نیاز: `python3` و ابزار فشرده‌سازی متناظر.

---

## ۱۴) هشدارها

- هرگز `preloader`, `lk`, `tee1` یا `tzar` را فلش نکنید؛ ریسک بریک سخت
  دارد. این درخت فقط `recovery` را هدف می‌گیرد.
- بازکردن بوت‌لودر `Warranty Bit` را برای همیشه ۱ می‌کند (Knox تریپ).
- `PLATFORM_SECURITY_PATCH` روی `2099-12-31` است تا anti-rollback جلوی
  بوت تصویر کاستوم را نگیرد.
- قبل از هر کاری از داده‌های مهم بکاپ بگیرید و فایل‌های استوک فریمور
  خودتان (`AP`, `BL`, `CSC`) را نگه دارید.

---

## ۱۵) مراجع

- منیفست: `minimal-manifest-twrp/platform_manifest_twrp_aosp` شاخهٔ `twrp-12.1`
- سورس TWRP: `TeamWin/android_bootable_recovery` شاخهٔ `android-12.1`
- fstab و نام پارتیشن‌ها: `system/etc/recovery.fstab` داخل رم‌دیسک استوک
  (`tools/stock_recovery.fstab` برای مقایسه)
- نام پنل/تاچ/بک‌لایت: `dtbo.img` و ماژول‌های استوک
- درخت‌های مشابه (فقط برای مقایسه، نه کپی): `twrpdtgen/android_device_samsung_a14m`,
  `forforksake/recovery_device_samsung_a14m`

---

## مجوز

```
SPDX-License-Identifier: Apache-2.0
```

فایل‌های prebuilt (کرنل، DTB/DTBO و ماژول‌ها) متعلق به سامسونگ/مدیاتک
هستند و تحت مجوز استوک فریمور توزیع می‌شوند.
