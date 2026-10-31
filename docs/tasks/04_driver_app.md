# تطبيق السائق — برق كابتن (مرجع P4)

> 📌 **ملف مواصفات** لهاد الجزء من المشروع. **ترتيب التنفيذ بـ `docs/PLAN.md`**. أرقام المهام (P1-xx، P2-xx…) أرقام مرجعية بس، وكلمة «الشخص N» قديمة: كل الشغل بيعمله Claude Code واحد.

**المجلد:** `apps/driver/` كامل
**الشاشات (14):** `08_driver_jobs_01…07` · `09_driver_delivery_01…07`
**HTML:** `docs/design/html/08_driver_jobs.html` · `09_driver_delivery.html` · الثيم: `barqDarkTheme()`

> تطبيقك مستقل، وفيه أثقل منطق: الموقع المستمر، خطوات المهمة، والقيود (النطاق والنقد).
> **الزر التالي دائمًا من `next_action`** (`action`, `to`, `label`, `style`, `requires`, `geofence_meters`, `confirm`) — ولا خطوة مكتوبة ثابتة.
> **التسليم بالصورة** (`delivery_confirmation = photo`): ما في OTP من الزبون.

---

## المهام بالترتيب

| المهمة | الشاشة | الصورة | الـ API |
|---|---|---|---|
| P4-01 | هيكل التطبيق | — | `GET /app/config` |
| P4-02 | دخول السائق | `08_driver_jobs_01` | `POST /driver/auth/login` |
| P4-03 | خدمة الموقع | — | `POST /driver/location` |
| P4-04 | الطلبات القريبة · متصل + غير متصل | `08_driver_jobs_02, 03` | `PUT /driver/status` · `GET /driver/orders/available` · `GET /driver/earnings?period=day` |
| P4-05 | طلب جديد | `08_driver_jobs_04` | `POST /driver/orders/{id}/accept` · `…/reject` |
| P4-06 | حد النقد / سبقك سائق | `09_driver_delivery_07` | أخطاء `already_taken` · `cash_limit_reached` |
| P4-07 | المهمة الحالية | `08_driver_jobs_05` | `GET /driver/orders/current` · `POST …/transition` |
| P4-08 | تصوير الطلب | `08_driver_jobs_06` | `POST /uploads` · `POST …/transition` |
| P4-09 | خارج نطاق الموقع | `08_driver_jobs_07` | خطأ 422 من transition |
| P4-10 | التسليم للزبون | `09_driver_delivery_01` | `POST /uploads` · `POST …/deliver` |
| P4-11 | الأرباح والنقد | `09_driver_delivery_02` | `GET /driver/earnings` · `GET /driver/cash` |
| P4-12 | سجل المهام | `09_driver_delivery_03` | `GET /driver/orders/history` |
| P4-13 | حساب السائق | `09_driver_delivery_04` | `GET /driver/me` · `POST /driver/auth/logout` |
| P4-14 | المركبة واللغة | `09_driver_delivery_05` | `PUT /driver/me` |
| P4-15 | إشعارات السائق | `09_driver_delivery_06` | `GET /driver/notifications` · `…/read-all` · `…/{id}/opened` · `PUT /driver/me/fcm-token` |

## تفاصيل مهمة
- **P4-01:** `MaterialApp.router` + `barqDarkTheme()` + ar/en. `BarqNavBar` بـ 4 تبويبات: الطلبات · الأرباح · السجل · حسابي. `ApiClient(app: BarqAppKind.driver)`. Splash: في توكن → الطلبات، لا → الدخول.
- **P4-02:** هاتف + كلمة مرور + `device_name`. نص "حسابات السائقين يفعّلها فريق برق فقط".
- **P4-03 خدمة الموقع:** `geolocator` stream. حد أدنى بين الطلبات من `config.driver.location_min_interval_seconds` (3ث). بدون نت → خزّن النقاط وابعتها بعدين كـ `points[]` (حتى 100 بالطلب). Android: foreground service + إشعار ثابت + صلاحيات (`ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `FOREGROUND_SERVICE_LOCATION`). بتشتغل لما السائق **متصل** وبتوقف لما يصير غير متصل.
- **P4-04:** قبل `is_online: true` ابعت موقع (السيرفر بيطلب موقع خلال `online_requires_location_minutes`). القائمة بالـ Poller كل `polling.available_orders_seconds`. "تحديث تلقائي".
- **P4-05:** "تجاهل" = `reject` = إخفاء فقط (ما بيلغي الطلب). اعرض `earning` و `payment.collect` و `distance_to_pickup_km`.
- **P4-07:** `BarqStepProgress` (تم القبول ← الاستلام ← في الطريق ← وصلت ← التسليم). الزر = `next_action.label`. إذا `confirm` موجود → `showBarqSheet` بالسؤال قبل الإرسال. إذا `requires` فيها صورة → P4-08. `422 invalid_transition` → أعد تحميل المهمة.
- **P4-08:** `image_picker` (كاميرا فقط، جودة ~70%) → `UploadService.upload(file, purpose: 'proof_photo')` → `transition` بـ `to: next_action.to` + `upload_ids`.
- **P4-09:** المسافة من `details` و `geofence_meters` من `next_action`. "افتح الملاحة" → `url_launcher` لـ `google.navigation:q=lat,lng` (أو رابط Google Maps).
- **P4-10:** اعرض `payment.collect.formatted` ("حصّل من الزبون نقدًا"). صوّر عند الباب → upload → `POST /driver/orders/{id}/deliver` بـ `upload_ids` (+ `note`). "إعادة التصوير". تأكيد بالسؤال من `confirm`.
- **P4-11:** `BarqSegmented` اليوم/الأسبوع/الشهر → `period=day|week|month`؛ الرسم من `series`. النقد: `cash_on_hand` مقابل `max_cash` و `remaining`.
- **P4-12:** فلتر الكل / تم التسليم / ملغاة (بالتطبيق، الـ endpoint ما فيه فلتر). ترقيم صفحات.
- **P4-14:** `PUT /driver/me` بيقبل `vehicle_type` و `locale` و `avatar_upload_id` بس. **رقم اللوحة للقراءة فقط.**

---

## برومبت Claude Code (لكل مجموعة)
```
Read AGENTS.md, docs/ARCHITECTURE.md, docs/api/API_NOTES.md and docs/tasks/04_driver_app.md.
Task: [P4-07 + P4-08 + P4-09]. Design: docs/design/screens/[08_driver_jobs_05..07].png (look at them)
and the matching sections in docs/design/html/08_driver_jobs.html for exact texts and sizes.
Endpoints: check exact fields in docs/api/openapi.json.
Work only inside apps/driver/. UI only from barq_ui. Wrap each screen with DesignOverlay.
When done: flutter analyze clean, run on the emulator, screenshot each screen and compare with the PNG, fix differences.
```

## بتسلّم لـ
- **P3:** سائق جاهز يقبل الطلبات بالاختبار الشامل، وموقعه بيوصل لخريطة الزبون.
## بتعتمد على
- **P1:** `ApiClient`, `UploadService`, `PushService`. (لحد ما يجهزوا: اشتغل بـ Fake أو اعملهم بنفسك حسب العقد وسلّمهم للقائد.)

## خلصت لما
- السائق بيدخل، بيصير متصل، بيشوف طلب ويقبله، وبيمر بكل الخطوات لحد التسليم بالصورة.
- الموقع بيوصل للزبون (P3 بيشوفه على الخريطة)، وبيتجمّع وقت انقطاع النت.
- القبول المرفوض، حد النقد، والنطاق الجغرافي كلها معالجة.
