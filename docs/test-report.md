# تقرير الاختبار · المرحلة 8

**التاريخ:** 2026-11-01، الساعة 00:30 تقريبًا · **الفرع:** `phase-8-e2e` · **Flutter:** 3.47.7

## الخلاصة
- الاختبارات الآلية نجحت كلها، ما عدا 3 اختبارات حية فشلت لأن متاجر الـ sandbox كانت مسكّرة وقت التشغيل.
- **الرحلة الكاملة على الـ sandbox ما انجرّبت بهالمرحلة.** ناقصها متاجر مفتوحة وبيانات دخول سائق.
- **مطابقة الشاشات مع التصميم ما انعملت**، لأن المطلوب كان عدم تشغيل المحاكي.
- `flutter analyze` نظيف بالحزم الأربع، والـ APK تبع التطبيقين انبنوا (التفاصيل تحت).

## نتائج `flutter test`
شغّلناها كلها مع `--dart-define-from-file=keys.json` (مفتاح `pk_test_`).

| الحزمة | نجح | فشل | تخطّى |
|---|---|---|---|
| `packages/barq_core` | 40 | 0 | 0 |
| `packages/barq_ui` | 2 | 0 | 0 |
| `apps/customer` | 201 | 3 | 0 |
| `apps/driver` | 40 | 0 | 2 |

### الاختبارات اللي فشلت
| الاختبار | الخطأ | السبب |
|---|---|---|
| `live_browse_test.dart` | `422 vendor_closed` | المتاجر مسكّرة |
| `live_checkout_test.dart` | `Bad state: No element` (سطر 72) | ما في متجر `is_open_now` |
| `live_orders_test.dart` | `Bad state: No element` (سطر 49) | ما في متجر `is_open_now` |

تأكدنا من السبب: `GET /vendors` رجّع 24 متجر، و `is_open_now = true` لصفر منهم، والساعة كانت 00:38. هاد نفس السلوك المكتوب بـ `API_NOTES.md`. **بس هالثلاثة ما انعادوا وقت الدوام، فلسا مش مثبت إنهم بينجحوا بعد حذف Firebase.** أعيدوهم بين 07:00 و 23:00:

```
cd apps/customer
flutter test test/live_browse_test.dart test/live_checkout_test.dart test/live_orders_test.dart --dart-define-from-file=../../keys.json
```

### الاختبارات اللي انتخطت
`live_driver_test.dart` و `live_job_test.dart` بيحتاجوا دخول سائق، و `keys.json` ما فيه. وحتى لو توفر، `live_job_test` بيحتاج متاجر مفتوحة.

## الرحلة الكاملة (P3-12)
| الخطوة | FakeServer | Sandbox بهالتشغيل |
|---|---|---|
| تسجيل زبون بالرقم و OTP وإدخال الاسم | ✅ | ✅ |
| إضافة عنوان | ✅ | ✅ |
| التصفح والسلة والمقارنة | ✅ | ❌ فشل (متاجر مسكّرة) |
| تأكيد الطلب بدون تكرار | ✅ | ❌ فشل (متاجر مسكّرة) |
| خطوات المتجر بـ `sandbox advance` | ما إلها اختبار | ❌ فشل (متاجر مسكّرة) |
| السائق يدخل ويقبل، وسائق ثاني `already_taken` | ✅ | ⏭️ ما انجرّب |
| الزبون يشوف السائق على الخريطة | ✅ | ⏭️ ما انجرّب |
| صور الاستلام والتسليم | ✅ | ⏭️ ما انجرّب |
| الزبون يقيّم ويشوف الفاتورة والسابقة | ✅ | ⏭️ ما انجرّب |
| السائق يشوف الأرباح والنقد والسجل | ✅ | ⏭️ ما انجرّب |

ملاحظة: `docs/notes/phase-7.md` بيقول إن رحلة السائق انجربت يدويًا بالمرحلة 7. هاد قبل هالتعديلات، ومش جزء من هالتشغيل.

## الحالات الخاصة
كلها مغطاة باختبارات FakeServer بس، وما انجربت بهالتشغيل على سيرفر حقيقي.

| الحالة | الاختبار |
|---|---|
| خارج المنطقة | `browse_cart_test`: `compare out_of_zone opens the out-of-zone screen` |
| انتهاء السعر | `checkout_test`: `quote_expired shows the new price and goes on with it` |
| انتهاء عرض السعر | `checkout_test`: `offer_expired while approving shows the expired view` |
| إلغاء الزبون | `orders_test`: `cancelling sends the chosen reason` |
| السائق بعيد عن النطاق | `delivery_flow_test`: `too far opens the screen; retry never uploads twice` |
| حد النقد | `jobs_flow_test`: `cash_limit_reached opens the cash screen with server money` |
| انقطاع النت | `checkout_test`: `a retry after no internet repeats the exact request` · `location_tracker_test`: `keeps points with no network, and sends them after` |
| انتهاء الجلسة 401 | `system_screens_test`: `401 during a session shows session expired, then login` |

**مش مؤكد:** كود خطأ «السائق بعيد» مش موثق، و `isTooFar` مبني على توقع (`API_NOTES.md`)، فهاد أول إشي لازم ينجرب مع سائق حقيقي.

## المشاكل
| الخطوة | شو صار | المتوقع | الحالة |
|---|---|---|---|
| حذف Firebase | تسجيل الخروج كان لسا بيبعت `PUT /me/fcm-token` | ما في توكن أصلًا | انحل، الطلب انحذف |
| اسم التطبيق | اسم تطبيق الزبون على الجوال كان `barq_customer` | «برق» | انحل بـ `AndroidManifest.xml` |
| شاشة «أهلًا بك» | مفتاح الإشعارات لسا بينحفظ، بس ما في إشي بيقرأه | قرار من الفريق | مفتوح، يا إما نخفيه أو نخليه |
| توقيع الـ APK | موقّع بمفتاح debug | مناسب للتجربة، مش لـ Google Play | مفتوح |

## المطابقة مع التصميم
ما انعملت. لازم الفريق يعملها على جهاز: رجّعوا `design/` للـ pubspec مؤقتًا، شغّلوا كل شاشة، وقارنوها بزر «تصميم».

## APK
الناتج بـ `apps/<app>/build/app/outputs/flutter-apk/app-release.apk`، و `build/` مش بالـ git. المفتاح `pk_test_` مبني جوا الـ APK، فما تنشروه برا الفريق.

| التطبيق | الملف | الحجم | صور `design/` | ملفات Firebase | اسم التطبيق |
|---|---|---|---|---|---|
| الزبون | `apps/customer/build/app/outputs/flutter-apk/app-release.apk` | 58.2 MB | 0 | 0 | برق |
| السائق | `apps/driver/build/app/outputs/flutter-apk/app-release.apk` | 56.9 MB | 0 | 0 | برق كابتن |

زر «خطوة المتجر» بشاشة الانتظار بيظهر بنسخة debug بس. مع الـ APK، حرّكوا الطلب بـ `POST /sandbox/orders/{id}/advance` من Postman.

ما انجرّب أي APK على جهاز، فـ «التطبيق بيشتغل بدون Firebase» مثبت بالبناء والاختبارات بس.
