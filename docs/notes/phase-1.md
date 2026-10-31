# المرحلة 1 — الأساس `barq_core`

## شو انعمل
بنينا الطبقة المشتركة اللي التطبيقين بيعتمدوا عليها: الاتصال بالسيرفر، حفظ الدخول، الإعدادات، رفع الملفات، التحديث الدوري، عرض حالة الطلب، والإشعارات.

| الخطوة | الملف | شو بيعمل |
|---|---|---|
| P1-05 | `lib/src/api/` | `ApiClient` و `ApiException` و `BarqEnv` و `Paged` |
| P1-06 | `lib/src/auth/auth_store.dart` | بيحفظ التوكن، وبيعلن انتهاء الجلسة |
| P1-07 | `lib/src/config/` و `lib/src/models/money.dart` | الإعدادات والكاش و `Money` و `StatusInfo` |
| P1-08 | `lib/src/uploads/upload_service.dart` | بيرفع ملف وبيرجع `upload_id` |
| P3-01 | `lib/src/polling/poller.dart` | تحديث دوري بيوقف لما التطبيق بالخلفية |
| P3-02 | `lib/src/status/` | `OrderStatusPill` و `OrderStatusTimeline` |
| P1-09 | `lib/src/push/` | كود الإشعارات، وربط Firebase مؤجّل |

وكمان:
- `apps/customer/lib/core_check_screen.dart`: شاشة **مؤقتة** بتعرض الإعدادات والحالات من السيرفر. بتنشال بالمرحلة 2.
- `packages/barq_core/test/`: الاختبارات. `live_api_test.dart` بيكلم السيرفر الحقيقي.
- `BarqPill` بـ `barq_ui` صار يقبل `color`، ومثاله موجود بـ `BarqGallery`.

## ليش مبني هيك
- **كل الطلبات من `ApiClient`:** الهيدرات وتحويل الأخطاء مكتوبين بمكان واحد، فالشاشات ما بتكرر إشي.
- **كل خطأ بيصير `ApiException`:** الشاشة بتعرض `messageAr` بس. وإذا ما وصل رد من السيرفر، `status` بيكون 0 و `isNetwork` بتكون `true`.
- **الحالات من السيرفر:** ولا اسم حالة مكتوب بالكود. لو السيرفر غيّر اسم أو لون، التطبيق بيتغيّر لحاله.
- **الإعدادات من الكاش أولًا:** الشاشة بتلاقي بيانات حتى لو النت مقطوع. الـ ETag بيوفر تنزيل نفس البيانات مرة ثانية.
- **`ConfigScope`:** بيوصّل الإعدادات لـ `OrderStatusPill` بدون ما نمررها من شاشة لشاشة، وبدون حزمة جديدة (`InheritedNotifier` من Flutter نفسه).

## كيف البيانات بتتحرك
```
الشاشة ← Cubit ← Repository ← ApiClient ← السيرفر
                                 │
                                 ├─ نجاح → بيرجع "data"
                                 └─ فشل → ApiException
                                          └─ 401 مع توكن → AuthStore بيمسح التوكن
                                                          → sessionExpired
```
الإعدادات: `ConfigStore.load()` بيقرأ الكاش، بعدين بيطلب `GET /app/config` مع `If-None-Match`:
- 304: الكاش صحيح، وما بيتغير إشي.
- 200: بيحدّث الإعدادات والكاش.
- انقطاع نت مع وجود كاش: بيكمل عادي.
- صيانة أو تحديث إجباري: بيرمي الخطأ حتى لو في كاش، عشان التطبيق يعرض الشاشة الصح.

## قرارات لازم تعرفوها
- **إضافات على عقد `ARCHITECTURE.md`** (الأسماء القديمة ما تغيرت): `AuthStore.load()` و `AuthStore.expireSession()` و `ApiClient.getWithEtag()` و `ConfigStore.isLoaded` و `AppConfig.timeline()` و `AppConfig.timelineIndex()` و `OrderTimelines` و `ConfigScope`.
- **`OrderStatusTimeline` بياخد `keys` و `current`:** `keys` قائمة من `OrderTimelines`.
- **401 بدون توكن ما بينهي الجلسة:** لو كلمة سر السائق غلط، لازم يشوف الخطأ بنفس الشاشة، مش "انتهت الجلسة".
- **الخط الزمني:** السيرفر بيرجع 11 حالة والتصميم فيه 5 صفوف، والإعدادات ما فيها إشي بيحدد الخمسة. قرار الفريق: قوائم المفاتيح لكل شاشة بـ `OrderTimelines` بـ `barq_core`، والاسم واللون بيضلوا من الإعدادات. هاد الاستثناء الوحيد للقاعدة 4 بـ `AGENTS.md`.
- **حالة مش بالقائمة:** بتضل على الصف اللي قبلها حسب `step`، مثلًا `accepted` بشاشة الانتظار. والطلب الملغي بياخد مكان آخر صف، عشان ما يبان إنه وصل.
- **أيقونة الحالة:** أسماء السيرفر (مثل `chef-hat`) بنحولها لأقرب أيقونة بـ `barq_ui`، وأي اسم جديد بيصير `clock`.
- **`X-App-Version`:** مكتوب `1.0.0` بـ `main.dart` مؤقتًا، لأن قراءته من التطبيق بتحتاج حزمة جديدة. لازم يضل مطابق للـ `pubspec` لحد ما نقرر.
- **رسائل الشبكة بـ `ApiException` بالعربي داخل الكود:** `barq_core` ما عنده ملفات `.arb`. باقي النصوص لازم تكون بالـ `.arb`.
- **`getToken` قديمة بـ `firebase_messaging`:** استخدمنا `register()` و `onRegistered` البديلة.

## اللي تأكد من السيرفر الحقيقي
- `GET /app/config` بيرجع 200، و`If-None-Match` بيرجع 304.
- مفتاح غلط بيرجع `invalid_project_key`.
- `polling` حقوله الخمسة صحيحة.
- `meta` شكله `{ page, per_page, total, last_page }`.

## لسا مش مؤكد
- **التشغيل على الإيميوليتر:** لسا ما اشتغل عليه. اللي تأكد: `flutter build apk --debug` نجح.
- **رفع ملف وتسجيل توكن FCM:** بيحتاجوا دخول، فبنجربهم بعد المرحلة 2.

## التشغيل
حطوا المفتاح الحقيقي بملف `keys.json` بجذر المشروع. الملف بـ `.gitignore`، وما بينرفع.
```
cd apps/customer
flutter run --dart-define-from-file=../../keys.json

cd packages/barq_core
flutter test --dart-define-from-file=../../keys.json
```

## ربط Firebase لاحقًا
1. نعمل Firebase project.
2. نشغّل `flutterfire configure` بـ `apps/customer` و `apps/driver`.
3. ما بيتغير كود `PushService`. لحد هداك الوقت، `init()` بيسجل رسالة وبيكمل التطبيق عادي.

## أسئلة لازم الفريق يقدر يجاوب عليها
1. ليش `ApiClient` بيرجع `data` بس؟ ووين راحت باقي حقول الرد؟
2. شو بيصير خطوة بخطوة لما طلب يرجع 401؟ وليش منفحص إذا في توكن؟
3. ليش `load()` بيكمل عادي لما النت مقطوع، بس بيرمي خطأ بالصيانة؟
4. شو بيعمل `Poller` لو `tick` أخد وقت أطول من المدة؟ وليش الحد الأدنى 5 ثواني؟
5. كيف `OrderStatusPill` بيعرف اللون والاسم بدون ما نمرر الإعدادات إله؟
