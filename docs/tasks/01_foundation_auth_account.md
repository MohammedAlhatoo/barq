# الأساس + الدخول + الحساب (مرجع P1)

> 📌 **ملف مواصفات** لهاد الجزء من المشروع. **ترتيب التنفيذ بـ `docs/PLAN.md`**. أرقام المهام (P1-xx، P2-xx…) أرقام مرجعية بس، وكلمة «الشخص N» قديمة: كل الشغل بيعمله Claude Code واحد.

**المجلدات:** `packages/barq_core/` · `apps/customer/lib/{app, features/auth, features/account, features/system}` · `packages/barq_ui/`
**الشاشات (16):** `01_auth_01…07` · `06_account_01…05` · `07_states_03…06`

> أولويتك: **الأساس بسرعة** (حتى لو بسيط) لأن الكل بيعتمد عليه. الشاشات بعدين.
> الترتيب: A (يوم 1) ← B (يوم 2–4) ← C (الشاشات).

---

## A · يوم 1 — تجهيز المشروع (بدون Gemini، بإيدك)

### P1-01 · إنشاء المستودع
1. اعمل repo على GitHub اسمه `barq` (Private) وضيف الثلاثة كـ Collaborators.
2. على جهازك:
   ```
   mkdir barq && cd barq && git init
   ```
3. فك ضغط `barq_ui_package.zip` و `barq_team_docs.zip` بجذر المجلد. لازم يصير عندك:
   `AGENTS.md`, `CLAUDE.md`, `packages/barq_ui/`, `docs/…`
4. اعمل التطبيقين:
   ```
   flutter create --org com.barq --project-name barq_customer --platforms android,ios apps/customer
   flutter create --org com.barq --project-name barq_driver   --platforms android,ios apps/driver
   flutter create --template=package packages/barq_core
   ```
5. انسخ الـ `.gitignore` الموجود بـ `docs/setup/gitignore.txt` لجذر المشروع باسم `.gitignore`.
6. أول commit على `main`، بعدين:
   ```
   git checkout -b dev && git push -u origin main dev
   ```
   بإعدادات GitHub: Branches → احمِ `main` و `dev` (Require pull request).

### P1-02 · ربط الحزم
1. بـ `apps/customer/pubspec.yaml` و `apps/driver/pubspec.yaml` تحت `dependencies`:
   ```yaml
   barq_ui:
     path: ../../packages/barq_ui
   barq_core:
     path: ../../packages/barq_core
   ```
   وبـ `packages/barq_core/pubspec.yaml` (لأن عرض الحالة بيستخدم مكونات barq_ui):
   ```yaml
   barq_ui:
     path: ../barq_ui
   ```
2. الحزم (شوف `docs/ARCHITECTURE.md` القسم 2):
   ```
   cd packages/barq_core
   flutter pub add dio flutter_secure_storage shared_preferences uuid connectivity_plus firebase_core firebase_messaging
   cd ../../apps/customer
   flutter pub add flutter_bloc go_router image_picker flutter_map latlong2 geolocator url_launcher share_plus intl
   flutter pub add flutter_localizations --sdk=flutter
   cd ../driver
   flutter pub add flutter_bloc go_router image_picker flutter_map latlong2 geolocator url_launcher intl
   flutter pub add flutter_localizations --sdk=flutter
   ```
3. صور المطابقة: انسخ `docs/design/overlay/customer/*` لـ `apps/customer/design/` و `docs/design/overlay/driver/*` لـ `apps/driver/design/`، وضيف بكل pubspec:
   ```yaml
   flutter:
     assets:
       - design/
   ```
4. `flutter pub get` بكل مجلد، و `flutter analyze` بـ `packages/barq_ui` (لازم يطلع نظيف).

### P1-03 · فحص barq_ui
1. مؤقتًا خلي `apps/customer/lib/main.dart`:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:barq_ui/barq_ui.dart';
   void main() => runApp(MaterialApp(theme: barqLightTheme(), locale: const Locale('ar'),
       supportedLocales: const [Locale('ar')], localizationsDelegates: const [
         GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
       home: const BarqGallery()));
   ```
   (ضيف `import 'package:flutter_localizations/flutter_localizations.dart';`)
2. شغّل وتأكد: الخط Rubik ظاهر، الأيقونات ظاهرة، زر الوضع الغامق شغّال. صوّر الشاشة وابعتها بالجروب.
3. commit: `P1-03: project setup + barq_ui check` → push على `dev`.

### P1-04 · اجتماع البداية (30 دقيقة)
- كل واحد يعمل clone ويشغّل الـ Gallery عنده.
- اعطِ كل واحد مفتاح `pk_test_…` على الخاص + ملف Postman environment.
- كل واحد يجرب بـ Postman: `GET /app/config` و endpoint من مهامه.
- اتفقوا: كل واحد بيبدأ بشاشاته بـ **Fake data** وما حدا بيستنى حدا.

---

## B · يوم 2–4 — `barq_core` (العقد في `docs/ARCHITECTURE.md` القسم 4 — التزم بالأسماء حرفيًا)

### P1-05 · ApiClient + ApiException
**برومبت Gemini:**
```
اقرأ AGENTS.md و docs/ARCHITECTURE.md (القسم 4) و docs/api/API_NOTES.md.
ابنِ داخل packages/barq_core/lib/src/api/ :
- BarqEnv و BarqAppKind كما في العقد.
- ApiClient بـ dio: baseUrl من BarqEnv، interceptor يضيف X-Project-Key و Authorization (من AuthStore)
  و Accept-Language و X-App-Version و X-Dev-Member. الدوال get/post/put/delete/getPaged ترجع "data" من الرد.
  post يقبل idempotencyKey ويرسله كهيدر Idempotency-Key.
- ApiException من شكل الخطأ في openapi (components.schemas.Error): status, code, messageAr (hint.ar أو message), details, isNetwork.
- أي 401 → AuthStore.clear() وإطلاق sessionExpired.
- ملف packages/barq_core/lib/barq_core.dart يصدّر كل شي.
لا تضيف حزم غير الموجودة بالـ pubspec. بالآخر flutter analyze.
```
**خلصت لما:** `GET /app/config` بيرجع data، وطلب بمفتاح غلط بيرجع `ApiException(code: invalid_project_key)`.

### P1-06 · AuthStore
تخزين التوكن بـ `flutter_secure_storage`، `isLoggedIn`، `sessionExpired` stream.
**برومبت:** «ابنِ AuthStore في packages/barq_core/lib/src/auth/ حسب العقد في docs/ARCHITECTURE.md. اربطه بـ ApiClient.»

### P1-07 · ConfigStore + AppConfig + Money + StatusInfo
**برومبت:**
```
ابنِ في packages/barq_core/lib/src/config/ : ConfigStore و AppConfig و StatusInfo و PollingConfig و DriverConfig،
وفي src/models/money.dart : Money. الحقول من components.schemas.AppConfig في docs/api/openapi.json —
بس الحقول المذكورة بالعقد. ConfigStore.load(): يقرأ الكاش من shared_preferences أولًا، بعدين GET /app/config
مع If-None-Match (ETag)؛ 304 = خلي الكاش. StatusInfo.color يتحول من hex لـ Color.
```
**مهم:** `project.colors` من السيرفر **ما نستخدمه** (الألوان من barq_ui).

### P1-08 · UploadService
`upload(File, purpose)` → `POST /uploads` (multipart: `file`, `purpose`) → يرجع `upload_id`. حد 10MB.
(P4 بيستخدمه للصور بـ `purpose: proof_photo`، وأنت لصورة الملف بـ `purpose: avatar`.)

### P1-09 · PushService (FCM)
1. اعمل Firebase project، و `flutterfire configure` للتطبيقين (`apps/customer` و `apps/driver`).
2. `PushService.init()` (صلاحية الإشعارات) + `registerToken()` → `PUT /me/fcm-token` للزبون و `PUT /driver/me/fcm-token` للسائق (حسب `BarqAppKind`).
3. `onOpen` stream لما المستخدم يضغط إشعار (P3 و P4 بيستخدموه للتنقل).

### P1-10 · هيكل تطبيق الزبون
**برومبت:**
```
اقرأ AGENTS.md و docs/ARCHITECTURE.md (القسم 3).
ابنِ apps/customer/lib/app/ : app.dart (MaterialApp.router + barqLightTheme + ar/en + RTL)،
di.dart (إنشاء ApiClient و AuthStore و ConfigStore مرة وحدة وتوفيرهم بـ RepositoryProvider)،
router.dart بـ go_router: /splash ثم /onboarding /login /otp /welcome، وShell فيه BarqNavBar بـ 4 تبويبات
(الرئيسية /home، الأقسام /categories، طلباتي /orders، حسابي /account) + زر السلة في المنتصف /cart مع badge.
الشاشات اللي مش جاهزة حط مكانها Placeholder مكتوب عليه اسمها. التصميم: docs/design/screens/02_browse_01.png (الشريط السفلي).
ملفات l10n: lib/l10n/app_ar.arb و app_en.arb.
```
**بعدها:** ابعت للفريق: "الهيكل جاهز — كل واحد يضيف مساراته بـ router.dart بـ PR صغير".

### P1-11 · شاشات النظام (`07_states_03…06`)
لا يوجد إنترنت (connectivity_plus + زر إعادة المحاولة) · تحديث إجباري (`min_app_version` أو 426) · صيانة (code `maintenance` أو `project_frozen`) · انتهت الجلسة (من `sessionExpired`).
كلها بـ `BarqStateView`. **برومبت:** استخدم البرومبت العام بـ `docs/README.md` مع الصور الأربع وقسم "States" بـ `docs/design/html/07_states.html`.

✅ **نهاية B:** ابعت بالجروب: "barq_core جاهز" — الكل بيبدّل الـ Fake بالحقيقي.

---

## C · الشاشات (كل وحدة = مهمة + PR)

| المهمة | الشاشة | الصورة | الـ API | ملاحظات |
|---|---|---|---|---|
| P1-12 | شاشة البداية | `01_auth_01` | `GET /app/config` | فحص التحديث/الصيانة. في توكن → /home، لا → /onboarding |
| P1-13 | التعريف ×3 | `01_auth_02…04` | — | PageView + "تخطّي" + مبدّل ع/EN |
| P1-14 | رقم الجوال | `01_auth_05` | `POST /auth/send-otp` | تحقق 9–15 رقم |
| P1-15 | رمز التحقق | `01_auth_06` | `POST /auth/verify-otp` | `BarqCodeInput(length: 4)`، عدّاد إعادة الإرسال، `is_new_user` → /welcome |
| P1-16 | أهلًا بك | `01_auth_07` | `PUT /me` + `POST /addresses` | الاسم بـ PUT /me. "موقع التوصيل" = أول عنوان (geolocator) |
| P1-17 | حسابي | `06_account_01` | `GET /me` · `POST /auth/logout` | |
| P1-18 | تعديل الملف | `06_account_02` | `PUT /me` · `POST /uploads` | `avatar_upload_id` |
| P1-19 | حذف الحساب | `06_account_03` | `DELETE /me` | تأكيد مزدوج |
| P1-20 | عناويني | `06_account_04` | `GET /addresses` · `DELETE /addresses/{id}` | **اعمل `AddressPickerSheet` قابل لإعادة الاستخدام** — P2 بيحتاجه |
| P1-21 | إضافة عنوان | `06_account_05` | `POST /addresses` · `PUT /addresses/{id}` | خريطة flutter_map لاختيار lat/lng |

**برومبت لكل شاشة** (غيّر اللي بين الأقواس):
```
اقرأ AGENTS.md. المهمة [P1-15] من docs/tasks/01_foundation_auth_account.md.
التصميم: الصورة المرفقة + قسم "[رمز التحقق]" في docs/design/html/[01_auth].html.
الـ API: [POST /auth/verify-otp] — الحقول من docs/api/openapi.json.
اشتغل داخل apps/customer/lib/features/[auth]/ فقط: data/ (repository) + state/ (Cubit) + ui/ (screen).
مكونات barq_ui فقط. لف الشاشة بـ DesignOverlay(image: 'design/[01_auth_06].png').
حالات: تحميل + خطأ (ApiException.messageAr). بالآخر flutter analyze.
```

---

## مسؤوليات مستمرة (القائد)
- **مراجعة الـ PRs يوميًا.** ارفض أي PR فيه ألوان/أحجام مكتوبة بالإيد، أو تعديل برا مجلد صاحبه.
- **barq_ui:** أي طلب مكون جديد بيجيك. ضيفه هناك + مثال بـ `BarqGallery`. (محمد عنده Claude Code — ممكن تبعتله الطلب.)
- احكي لصاحب الـ API النقاط بـ `docs/api/API_NOTES.md` القسم 6.

## خلصت لما
- التطبيق بيفتح، بيحمّل الـ config، بيدخل برقمه وبيطلع من الحساب.
- أي 401 بيودي لشاشة "انتهت الجلسة".
- P2 و P3 و P4 استخدموا `ApiClient` بدون ما يعدلوا عليه.
