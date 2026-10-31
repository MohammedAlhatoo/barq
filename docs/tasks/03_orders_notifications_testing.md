# متابعة الطلب + الإشعارات + الاختبار الشامل (مرجع P3)

> 📌 **ملف مواصفات** لهاد الجزء من المشروع. **ترتيب التنفيذ بـ `docs/PLAN.md`**. أرقام المهام (P1-xx، P2-xx…) أرقام مرجعية بس، وكلمة «الشخص N» قديمة: كل الشغل بيعمله Claude Code واحد.

**المجلدات:** `apps/customer/lib/features/{orders, notifications}/` + `packages/barq_core/lib/src/{polling, status}/`
**الشاشات (8):** `04_order_status_01, 04` · `05_after_order_01…05` · `06_account_06`
**HTML:** `docs/design/html/04_order_status.html` · `05_after_order.html` · `06_account.html`

> شاشاتك أقل بس فيها التحدي: **التحديث الدوري والخريطة**. وأنت الوحيد اللي بتشوف الرحلة كاملة، فأنت **مسؤول الاختبار الشامل** (القسم الأخير).
> ⚠️ **ما في رمز استلام (delivery_code) بتطبيق الزبون.** التسليم بالصورة: السائق بيصوّر الطلب عند الباب. (حتى لو الـ API بيرجع `delivery_code` لا تعرضه.)

---

## المهام بالترتيب

### P3-01 · مدير التحديث الدوري (Poller) — بيستخدمه الكل
**برومبت:**
```
اقرأ AGENTS.md و docs/ARCHITECTURE.md (القسم 4: Poller).
ابنِ packages/barq_core/lib/src/polling/poller.dart :
- Poller(tick, defaultSeconds): ينادي tick كل N ثانية. إذا tick رجّع رقم (next_poll_seconds) يستخدمه للمرة الجاية.
- يوقف تلقائيًا لما التطبيق بالخلفية (WidgetsBindingObserver / AppLifecycleListener) ويرجع لما يرجع.
- ما يشغّل tick جديد قبل ما يخلص القديم. حد أدنى 5 ثواني.
- start() / stop() / dispose(). صدّره من barq_core.dart.
```

### P3-02 · عرض الحالة (للكل)
`OrderStatusPill('on_the_way')` و `OrderStatusTimeline(current: …)` في `packages/barq_core/lib/src/status/`.
الاسم واللون والترتيب من `ConfigStore.config.statuses` (`label`, `color`, `step`, `is_terminal`) — **ولا اسم حالة مكتوب بالكود**. مبنيين على `BarqPill` و `BarqStepProgress` / `BarqTimeline` من barq_ui.

### P3-03 · المستودع + Fake
`OrdersRepository` (abstract) + `ApiOrdersRepository` + `FakeOrdersRepository` (بيانات من التصميم: #B-1042، ميني ماركت النور…). الموديلات: `Order`, `OrderSummary`, `Tracking`, `Receipt`, `ShareLink`, `AppNotification` — الحقول من `docs/api/openapi.json`.

### P3-04 · بانتظار المتجر / السائق — `04_order_status_01`
- `GET /orders/{id}` مرة، بعدين `GET /orders/{id}/events?since=…` كل `polling.events_seconds`.
- `OrderStatusTimeline` + النص حسب الحالة.
- زر **إلغاء الطلب** يظهر بس إذا `available_actions` فيها `cancel`.
- الحالة `priced` → روح لشاشة عرض السعر (P2): `/orders/{id}/offer`.
- الحالة `accepted` أو بعدها → روح لشاشة التتبع.
- الملاحظة بالتصميم: "عند التسليم، السائق بيصوّر الطلب على بابك كإثبات استلام."

### P3-05 · تتبّع الطلب — `04_order_status_04`
- `GET /orders/{id}/tracking` بالـ Poller: **احترم `next_poll_seconds`** (مش أسرع من 5 ثواني).
- خريطة `flutter_map` (OpenStreetMap): دبوس السائق `BarqMapPin(style: dark)`، دبوس البيت `BarqMapPin(style: orange)`، و `path_tail` كخط.
- `eta_minutes` ("يصل خلال 12 دقيقة")، بيانات السائق (الاسم، المركبة، التقييم) + زر اتصال `tel:` بـ `url_launcher`.
- `delivered` → شاشة التقييم.

### P3-06 · إلغاء الطلب — `05_after_order_01`
`GET /cancel-reasons` → `BarqRadio` لكل سبب → `POST /orders/{id}/cancel` (`reason`, `note`). كـ `showBarqSheet`.

### P3-07 · تم التوصيل والتقييم — `05_after_order_02`
`POST /orders/{id}/rate` (`stars`, `comment`, `vendor_stars`, `vendor_comment`). `BarqStars` + زر "تخطّي".

### P3-08 · طلباتي — `05_after_order_03`
تبويب **الحالية** = `GET /orders?scope=active` · **السابقة** = `scope=completed` بعدين `scope=cancelled` (قائمتين تحت بعض أو Chips). ترقيم صفحات.
زر "إعادة الطلب" → `CartCubit.rebuildFromOrder` (من P2) → السلة.

### P3-09 · الفاتورة — `05_after_order_04`
`GET /orders/{id}/receipt`. "تحميل PDF": افحص الرد — إذا في رابط PDF افتحه، وإلا **أجّلها** (مش أولوية) وخبّر القائد.

### P3-10 · رابط التتبّع العام — `05_after_order_05`
- `POST /orders/{id}/share-link` → `url` → شاركه بـ `share_plus`. إيقاف: `DELETE /orders/{id}/share-link`.
- الصفحة نفسها (بدون تسجيل دخول) **بيعرضها السيرفر** على `url`. افتح الرابط بالمتصفح وتأكد. إذا ما في صفحة جاهزة → احكي للقائد (بننفذها لاحقًا).

### P3-11 · الإشعارات — `06_account_06`
`GET /notifications` · `POST /notifications/read-all` · `POST /notifications/{id}/opened`. ضغط إشعار → يفتح الطلب.
ومن `PushService.onOpen` (P1): إشعار FCM فيه order id → `context.go('/orders/{id}')`.

---

## برومبت كل شاشة
```
اقرأ AGENTS.md و docs/ARCHITECTURE.md. المهمة [P3-05] من docs/tasks/03_orders_notifications_testing.md (اقرأها كاملة).
التصميم: الصورة المرفقة + قسم "[تتبّع الطلب]" في docs/design/html/[04_order_status].html.
الـ API: [GET /orders/{id}/tracking] — الحقول من docs/api/openapi.json.
اشتغل داخل apps/customer/lib/features/[orders]/ فقط. مكونات barq_ui فقط.
التحديث الدوري بـ Poller من barq_core، والحالات بـ OrderStatusTimeline/OrderStatusPill.
لف الشاشة بـ DesignOverlay(image: 'design/[04_order_status_04].png').
حالات: تحميل + خطأ. بالآخر flutter analyze.
```
**مساراتك:** `/orders` `/orders/:id` `/orders/:id/track` `/orders/:id/rate` `/orders/:id/receipt` `/notifications`.

---

## P3-12 · الاختبار الشامل (أسبوع 3) — أنت المسؤول
مع P4 (السائق) و P2. استخدموا مفتاح `pk_test_`. خطوات المتجر بتنعمل بـ `POST /sandbox/orders/{id}/advance` (من Postman).
سجّل كل خطأ بملف `docs/test-report.md`: الخطوة، شو صار، شو المتوقع، صورة، مين المسؤول.

- [ ] زبون جديد يسجّل بالرقم و OTP ويدخل اسمه (P1)
- [ ] يضيف عنوان جديد (P1)
- [ ] يتصفح ويضيف للسلة ويقارن بين المتاجر (P2)
- [ ] يؤكد الطلب — وإعادة الضغط/انقطاع النت ما بيكرر الطلب (P2)
- [ ] خطوات المتجر بالـ sandbox advance لحد `pending` (P3)
- [ ] السائق يدخل (هاتف + كلمة مرور)، يصير متصل، يشوف الطلب ويقبله؛ سائق ثاني يجرب → `already_taken` (P4)
- [ ] الزبون يشوف اسم السائق وموقعه على الخريطة (P3)
- [ ] السائق: عند المتجر → **صورة الطلب** → في الطريق → وصلت (P4)
- [ ] السائق **يصوّر التسليم** ويؤكد ويحصّل المبلغ (P4)
- [ ] الزبون يقيّم ويشوف الفاتورة والطلب بـ "السابقة" (P3)
- [ ] السائق يشوف الأرباح والنقد والسجل (P4)

**حالات خاصة:**
- [ ] عنوان خارج منطقة الخدمة (`out_of_zone`)
- [ ] انتهاء صلاحية السعر بشاشة تأكيد الطلب
- [ ] انتهاء مهلة عرض السعر (طلب بالوزن) → يُلغى تلقائيًا
- [ ] إلغاء من الزبون قبل استلام السائق
- [ ] السائق بعيد عن النطاق عند تأكيد الاستلام
- [ ] السائق وصل حد النقد (`cash_limit_reached`)، والتسوية بـ `POST /driver/sandbox/settle-cash`
- [ ] انقطاع النت ورجوعه (خصوصًا مواقع السائق المتراكمة)
- [ ] انتهاء الجلسة (401) بأي شاشة

## خلصت لما
- الزبون بيتابع طلبه من الإنشاء للتسليم بدون ما يطلع من الشاشة.
- التتبع بيتحدث وبيوقف بالخلفية (ما بيستهلك بطارية).
- الرحلة الكاملة فوق اشتغلت من أولها لآخرها.
