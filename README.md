# TWRP Device Tree — Samsung Galaxy A14 4G (SM-A145P / `a14m`)

درخت دستگاه (device tree) اختصاصی برای ساخت **TWRP 12.1** روی
**Samsung Galaxy A14 4G — SM-A145P**، بر پایهٔ فایل ریکاوری استوک خودِ گوشی.

> **وضعیت:** بیلد روی GitHub Actions با موفقیت انجام می‌شود و فایل
> `recovery.img`/`twrp_a14m.tar.md5` تولید می‌شود. مشکل فعلی **بوت نشدن**
> تصویر روی گوشی است (لوگوی سامسونگ ~۱۰ ثانیه و سپس ریبوت). دو علت اصلی
> در بخش ۶.۴ توضیح داده شده است: `vbmeta` غیرفعال‌نشده و نبودِ ماژول‌های
> کرنل در رم‌دیسک (این نسخه هر دو اصلاح شده است).

---

## ۱) مشخصات دستگاه

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
| پارتیشن ریکاوری | `80,740,352` بایت (باینری نهایی باید کوچک‌تر باشد) |

نمایشگر: پنل‌های `BOE / TXD / INX / JDI` با درایورهای `hx83112f`, `jd9522t`,
`nl9922c`, `td4375`.
تاچ: `himax HX83112`، `jadard JD9522T`، `chipone` و `focaltech`.

---

## ۲) منبع تمام فایل‌های prebuilt

همهٔ فایل‌های زیر **از `recovery.img` استوک خودِ گوشی** استخراج شده‌اند
(نه از اینترنت و نه از دستگاه مشابه). بنابراین کرنل و ماژول‌ها دقیقاً با
سخت‌افزار همین گوشی هم‌خوان هستند.

| فایل | اندازه | MD5 | توضیح |
|---|---:|---|---|
| `prebuilt/kernel` | 13,975,532 | `933b3c79216a10cd47b5c93ce16e10e9` | `Image.gz` استوک (gzip) |
| `prebuilt/dtb.img` | 182,127 | `ab5bacb2fe7589c25026e21ab718e5ef` | DTB پایهٔ MT6768 از خود `recovery.img` |
| `prebuilt/dtbo.img` | 79,837 | `08eba6a650cffcad2e8209398b135364` | DTBO برد `A14M MEA OPEN 00` از `recovery.img` |
| `prebuilt/modules/` | 25 MB | — | ۱۹۸ فایل `.ko` + `modules.alias`, `modules.dep`, `modules.softdep`, `modules.load.recovery` |

جزئیات هدر بوت استوک:

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

> ماژول‌ها **باید** با `prebuilt/kernel` هم‌نسل باشند؛ اگر کرنل را عوض کنید
> (مثلاً کرنل کاستوم)، این ماژول‌ها دیگر لود نمی‌شوند و نمایشگر، تاچ،
> ذخیره‌سازی و USB از کار می‌افتند.

---

## ۳) ساختار درخت

```
device/samsung/a14m/
├── .github/workflows/build-twrp.yml ← ورک‌فلو GitHub Actions
├── .gitignore
├── Android.bp
├── Android.mk
├── AndroidProducts.mk
├── BoardConfig.mk              ← تنظیمات کرنل، پارتیشن‌ها، AVB و TWRP
├── device.mk                   ← کپی فایل‌های ریکاوری و ماژول‌ها
├── twrp_a14m.mk                ← محصول twrp_a14m
├── vendorsetup.sh
├── recovery.fstab              ← fstab مخصوص TWRP
├── prebuilt/
│   ├── kernel                  ← Image.gz استوک
│   ├── dtb.img                 ← DTB پایهٔ استوک
│   ├── dtbo.img                ← DTBO استوک
│   └── modules/                ← ۱۹۸ ماژول کرنل استوک
├── recovery/root/
│   ├── init.recovery.mt6768.rc ← USB / init مخصوص MTK
│   ├── init.recovery.samsung.rc← آماده‌سازی efs
│   ├── system/etc/init/         ← فایل‌های rc استوک (dsms, snapuserd, ...)
│   └── system/etc/twrp.flags   ← ورودی‌های اختیاری (USB-OTG)
└── tools/
    └── extract_from_recovery.sh← استخراج مجدد همهٔ فایل‌ها از recovery.img
```

فایل‌های `recovery/root/...` توسط `PRODUCT_COPY_FILES` به
`out/target/product/a14m/recovery/root/...` کپی می‌شوند و سپس داخل
رم‌دیسک ریکاوری قرار می‌گیرند. ماژول‌ها در نهایت در
`recovery/root/lib/modules/` قرار می‌گیرند؛ همان مسیری که `init`
در حالت ریکاوری جست‌وجو می‌کند (`modules.load.recovery`).

---

## ۴) پیش‌نیاز ساخت

- لینوکس ۶۴ بیتی، حداقل ~۱۰۰ گیگ فضای آزاد، ۸ گیگ رم (۱۶ گیگ توصیه می‌شود)
- ابزارهای `repo`, `git`, `python3`, `lz4`, `cpio`, `openjdk-17`
- منیفست مینیمال TWRP شاخهٔ `twrp-12.1`

```bash
sudo apt install -y git curl python3 lz4 cpio openjdk-17-jdk \
    build-essential zip unzip rsync bc ccache
```

---

## ۵) دستورهای ساخت (اجرا نشده‌اند)

```bash
mkdir -p ~/twrp && cd ~/twrp

repo init --depth=1 \
  -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git \
  -b twrp-12.1
repo sync -j"$(nproc)" --force-sync --no-clone-bundle --no-tags

# اتصال این درخت به سورس
ln -s /root/device/samsung/a14m device/samsung/a14m

. build/envsetup.sh
lunch twrp_a14m-eng
mka recoveryimage -j"$(nproc)"
```

خروجی:

```
out/target/product/a14m/recovery.img
```

اگر می‌خواهید بدون سینک کامل AOSP فقط درخت را اعتبارسنجی کنید، حداقل
`BoardConfig.mk` و `recovery.fstab` را با `mka` واقعی نمی‌توان تست کرد؛
برای تست ساخت به منیفست بالا نیاز است.

### ۵.۱) ساخت با GitHub Actions (بدون نیاز به سیستم شخصی)

ورک‌فلو آماده در `.github/workflows/build-twrp.yml` قرار دارد.

مراحل:

1. کل پوشهٔ `device/samsung/a14m` را (همراه با `.github`) در یک ریپازیتوری
   گیت‌هاب پوش کنید. نام پیشنهادی مخزن: `android_device_samsung_a14m`.
2. در گیت‌هاب به تب **Actions** بروید و workflow
   **Build TWRP (a14m)** را انتخاب کنید.
3. **Run workflow** را بزنید و ورودی‌ها را انتخاب کنید:
   - `variant`: `eng` (یا `userdebug`)
   - `target`: `recoveryimage` (برای این گوشی) یا `bootimage`
4. پس از پایان کار، از بخش **Artifacts** این فایل‌ها را دانلود کنید:
   - `recovery.img` — تصویر خام ریکاوری
   - `twrp_a14m.tar.md5` — بستهٔ آمادهٔ Odin (اسلات AP)
   - `MD5SUMS.txt` و `SHA256SUMS.txt`

نکات:

- ورک‌فلو خودش JDK 11، ابزار `repo`، وابستگی‌های AOSP و فضای دیسک لازم را
  آماده می‌کند؛ منیفست `twrp-12.1` را `--depth=1` سینک می‌کند و درخت را
  داخل `device/samsung/a14m` قرار می‌دهد.
- زمان تقریبی اجرا ۱ تا ۲ ساعت است (سقف ۶ ساعت).
- از `ccache` عمداً استفاده نمی‌شود؛ کش `actions/cache` روی رانر خراب می‌شد
  (`Read-only file system` روی `~/.ccache/tmp`) و چون فقط در بیلد موفق
  ذخیره می‌شد، کمکی نمی‌کرد.
- اگر یک تگ مثل `v1.0.0` پوش کنید:
  ```bash
  git tag v1.0.0 && git push origin v1.0.0
  ```
  علاوه بر Artifact، یک **GitHub Release** هم با همان فایل‌ها ساخته می‌شود.
- اگر بیلد شکست خورد، Artifactی به نام `build-logs-<run>` شامل
  `verbose.log.gz` و `error.log` را دانلود کنید.
- به‌صورت پیش‌فرض بیلد فقط با `workflow_dispatch` و تگ اجرا می‌شود.
  برای اجرا روی هر push، بلوک `push.branches` را در فایل workflow از حالت
  کامنت خارج کنید (هر اجرا از سهمیهٔ Actions کم می‌کند).
- خروجی با کلید تست AOSP امضا می‌شود؛ همچنان به `vbmeta` غیرفعال‌شده روی
  گوشی نیاز دارید (بخش ۶.۲).

---

## ۶) نصب روی گوشی

### ۶.۱ آماده‌سازی (مهم)

1. حساب سامسونگ و قفل صفحه را بردارید.
2. `OEM unlocking` را در Developer options فعال کنید.
3. گوشی را به اینترنت وصل کنید تا **KG State = Checking** و
   **RMM State = Normal** شود (در غیر این صورت فلش بلاک می‌شود و ممکن است
   ۷ روز انتظار لازم باشد).
4. با `Volume Down + Volume Up` + کابل USB وارد **Download Mode** شوید و
   قفل بوت‌لودر را باز کنید (پس از آن همهٔ داده‌ها پاک می‌شود).
5. پس از باز شدن قفل، حتماً یک بار وارد سیستم شوید و Developer options را
   دوباره بررسی کنید.

### ۶.۲ غیرفعال کردن AVB — اجباری (علت اصلی بوت‌نشدن)

`recovery.img` استوک با کلید سامسونگ امضا شده و `vbmeta` گوشی نیز هشِ همان
تصویر استوک را نگه می‌دارد. تصویری که این درخت می‌سازد با **کلید تست AOSP**
امضا می‌شود؛ بنابراین تا وقتی `vbmeta` استوک روی گوشی است، بوت‌لودر هش را
رد می‌کند و نتیجه دقیقاً همان چیزی است که مشاهده شد:

```
لوگوی سامسونگ  →  حدود ۱۰ ثانیه  →  ریبوت (بدون ورود به ریکاوری)
```

روش مطمئن برای سامسونگ (بدون نیاز به fastboot):

1. فریمور کامل و **دقیقاً همان بیلد** گوشی را دانلود کنید
   (`AP_...tar.md5` از SamFW / SamMobile).
2. اپ **Magisk** را روی گوشی نصب کنید.
3. در Magisk: `Install` → `Select and Patch a File` → فایل
   `AP_....tar.md5` را انتخاب کنید. Magisk هم `boot.img` و هم `vbmeta.img`
   را پچ می‌کند (فلگ‌های verity/verification غیرفعال می‌شوند).
4. فایل خروجی `magisk_patched-....tar` را با Odin در اسلات **AP** فلش کنید.
   در Odin گزینهٔ `Auto Reboot` را بردارید.
5. بعد از `PASS`، بلافاصله با `Volume Up + Power` وارد ریکاوری شوید
   (نگذارید گوشی به سیستم استوک بوت شود).

اگر روت نمی‌خواهید: از همان فایل پچ‌شده فقط `vbmeta.img` را بیرون بکشید،
تنها همان را در یک tar بگذارید و در اسلات AP فلش کنید. در این حالت سیستم
استوک با هستهٔ استوک بالا می‌آید و فقط قفل AVB غیرفعال می‌شود.

> اگر قبلاً گوشی را با Magisk روت کرده‌اید، `vbmeta` از قبل پچ شده و این
> مرحله را می‌توانید رد کنید. ولی اگر مطمئن نیستید، همین روش را انجام دهید؛
> خطرش فقط تریپ‌شدن Knox است که با آنلاک‌کردن بوت‌لودر در هر حال رخ داده.

### ۶.۳ فلش ریکاوری

روش Odin (رایج‌ترین برای سامسونگ):

```bash
tar -cf twrp_a14m.tar recovery.img
# در Odin: AP = twrp_a14m.tar  →  Start
```

روش fastboot (در صورت پشتیبانی):

```bash
fastboot flash recovery recovery.img
```

> پس از فلش، **بلافاصله** با `Volume Up + Power` (کابل جدا) وارد ریکاوری
> شوید تا سیستم استوک فرصت بازنویسی ریکاوری را پیدا نکند.
> در اولین ورود، `Swipe to Allow Modifications` را بزنید.

### ۶.۴ اگر باز هم روی لوگو ماند

ترتیب بررسی:

1. **اول `vbmeta`**: تایید کنید که پچ‌شده فلش شده است. اگر `vbmeta` استوک
   باشد، هیچ تصویر غریبه‌ای (حتی سالم) بوت نمی‌شود.
2. **ماژول‌ها**: در رم‌دیسک باید `/lib/modules/modules.load.recovery` و ۱۹۸
   فایل `.ko` وجود داشته باشد. این نسخهٔ درخت با `PRODUCT_COPY_FILES` و
   `find-copy-subdir-files` آن‌ها را داخل رم‌دیسک می‌گذارد. برای بررسی
   خروجی بدون باز کردن گوشی:
   ```bash
   # بعد از دانلود recovery.img از Artifact
   python3 - <<'PY'
   import struct
   d = open('recovery.img','rb').read()
   ks, = struct.unpack_from('<I', d, 8)
   rs, = struct.unpack_from('<I', d, 16)
   off = 4096 + ((ks + 4095)//4096)*4096
   open('/tmp/r.ramdisk','wb').write(d[off:off+rs])
   PY
   lz4 -dc /tmp/r.ramdisk | cpio -t 2>/dev/null | grep -c '^lib/modules/.*\.ko$'
   # باید 198 چاپ شود
   ```
3. **لاگ**: اگر TWRP بالا آمد ولی صفحه سیاه بود، با کابل به PC وصل کنید و
   `adb devices` بزنید. اگر دستگاه دیده شد، `adb shell dmesg` و
   `adb shell cat /tmp/recovery.log` را ذخیره کنید.
4. اگر اصلاً adb نیامد و فقط لوگو بود، مشکل در کرنل/init اولیه است؛ در آن
   صورت خروجی `recovery.img` را با مقدارهای هدر استوک مقایسه کنید (بخش ۲).

---

## ۷) محدودیت‌ها و هشدارها

### رمزگشایی (Decryption) — غیرفعال

اندروید ۱۵ سامسونگ از FBE با کلیدهای سخت‌افزاری (KeyMint/TEE) استفاده
می‌کند. برای رمزگشایی در TWRP به باینری‌ها و کتابخانه‌های اختصاصی سامسونگ
(`keymaster`, `keymint`, `tee`, …) نیاز است که در رم‌دیسک ریکاوری استوک
موجود نیستند. به همین دلیل در `BoardConfig.mk` این گزینه‌ها عمداً
کامنت شده‌اند:

```
# TW_INCLUDE_CRYPTO := true
# TW_INCLUDE_CRYPTO_FBE := true
# TW_INCLUDE_FBE_METADATA_DECRYPT := true
```

روی این گوشی `/data` علاوه بر FBE، **رمزنگاری متادیتا** هم دارد
(`dm-default-key`): کل بلوک‌های خام `userdata` با کلیدی که در پارتیشن
`/metadata` (`md_udc`, p29) ذخیره شده رمز شده‌اند. به همین دلیل حتی
`sblkid` هم روی `/dev/block/mmcblk0p52` نمی‌تواند سوپر‌بلوک f2fs را
تشخیص دهد (خودِ سوپر‌بلوک رمز است).

نتیجه: TWRP نمی‌تواند `/data` رمزنگاری‌شده را باز کند. برای بکاپ از
**MicroSD** (`/external_sd`) یا USB-OTG استفاده کنید. اگر داده‌ها برایتان
مهم نیست، `Format Data` بزنید (همهٔ اطلاعات پاک می‌شود) تا `/data` قابل
استفاده شود.

### مانت شدن پارتیشن‌ها

پارتیشن‌های منطقی داخل `super` (`system`, `vendor`, `product`, `odm`,
`system_ext`, `*_dlkm`) در متادیتای super سامسونگ با اتریبیوت «فقط‌خواندنی»
(liblp `attr=0x1`) علامت خورده‌اند. بنابراین دستگاه‌های `dm-*` که TWRP
می‌سازد فقط‌خواندنی‌اند و تلاش برای مانت با `mount(2)` بدون `MS_RDONLY`
با خطای `EACCES` (`Permission denied`) شکست می‌خورد.

به همین دلیل در `recovery.fstab` به همهٔ این ورودی‌ها `fsflags=ro` اضافه
شده است تا TWRP با `MS_RDONLY` مانت کند. اگر خواستید داخل این پارتیشن‌ها
بنویسید، باید متادیتای super بازنویسی شود (خطرناک است و توصیه نمی‌شود).
همچنین پرچم قدیمی و نامعتبر `wipeing`/`wipeing=1` با پرچم درست TWRP یعنی
`wipeingui` جایگزین شده است.

### AVB / Knox

- این درخت `Knox` را تریپ نمی‌کند اما باز کردن بوت‌لودر به‌هرحال
  `Warranty Bit` را ۱ می‌کند (برگشت‌ناپذیر).
- تصویر تولیدی با کلید تست امضا می‌شود؛ بدون vbmeta پچ‌شده بوت نمی‌شود.
- `PLATFORM_SECURITY_PATCH` روی `2099-12-31` تنظیم شده تا anti-rollback
  جلوی بوت را نگیرد.

### تاچ و نمایشگر

ماژول‌های تاچ/پنل از همان ریکاوری استوک آمده‌اند، پس روی نسخهٔ سخت‌افزاری
همین بیلد باید کار کنند. اگر گوشی شما پنل/تاچ با نسخهٔ دیگر دارد
(مثلاً `focaltech` به‌جای `himax`)، ممکن است تاچ پاسخ ندهد؛ در آن صورت
`recovery/root/lib/modules` را با ماژول‌های همان فریمور جایگزین کنید.

روشنایی از `mediatek,lcd-backlight` با بازهٔ `0x00..0xFF` خوانده می‌شود:

```
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS   := 255
```

### MTK / Preloader

- هرگز `preloader` یا `lk` را فلش نکنید؛ ریسک بریک سخت (hard brick) دارد.
- این درخت فقط پارتیشن `recovery` را هدف می‌گیرد و به `boot`، `init_boot`
  یا `super` دست نمی‌زند.

### ریسک کلی

ساخت و فلش ریکاوری کاستوم روی سامسونگ/MTK بدون ضمانت است. قبل از هر
کاری از داده‌های مهم بکاپ بگیرید و از فایل‌های استوک فریمور خودتان
(`AP`, `BL`, `CSC`) نگه‌داری کنید.

---

## ۸) استخراج مجدد از فایل استوک

اگر فریمور گوشی را آپدیت کردید و خواستید همهٔ prebuiltها را از
`recovery.img` جدید دوباره بسازید:

```bash
cd device/samsung/a14m
./tools/extract_from_recovery.sh /path/to/recovery.img
```

اسکریپت این کارها را انجام می‌دهد:

1. خواندن هدر Android boot v2 و محاسبهٔ آفست‌ها با page size.
2. استخراج `prebuilt/kernel`, `prebuilt/dtbo.img`, `prebuilt/dtb.img`.
3. باز کردن رم‌دیسک (gzip / lz4 / xz / lzma / bzip2) و استخراج
   `lib/modules/*` به `prebuilt/modules/`.
4. به‌روزرسانی `recovery/root/init.recovery.mt6768.rc` و
   `init.recovery.samsung.rc`.
5. چاپ MD5 فایل‌های تولیدشده برای مقایسه.

پیش‌نیاز اسکریپت: `python3` و یکی از `lz4`/`xz`/`gzip` بسته به نوع
فشرده‌سازی رم‌دیسک.

---

## ۹) فایل‌های مرجع

- منیفست: `minimal-manifest-twrp/platform_manifest_twrp_aosp` شاخهٔ `twrp-12.1`
- fstab و نام پارتیشن‌ها: `system/etc/recovery.fstab` داخل رم‌دیسک استوک
- نام پنل/تاچ/بک‌لایت: `dtbo.img` (۱۶۴ فرگمنت) و ماژول‌های استوک
- درخت‌های مشابه (فقط برای مقایسه، نه کپی): `twrpdtgen/android_device_samsung_a14m`,
  `forforksake/recovery_device_samsung_a14m`

---

## مجوز

```
SPDX-License-Identifier: Apache-2.0
```

فایل‌های prebuilt (کرنل، DTB/DTBO و ماژول‌ها) متعلق به سامسونگ/مدیاتک
هستند و تحت مجوز استوک فریمور توزیع می‌شوند.
