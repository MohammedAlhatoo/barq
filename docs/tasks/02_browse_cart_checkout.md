# التصفح + السلة + إنشاء الطلب (مرجع P2)

> 📌 **ملف مواصفات** لهاد الجزء من المشروع. **ترتيب التنفيذ بـ `docs/PLAN.md`**. أرقام المهام (P1-xx، P2-xx…) أرقام مرجعية بس، وكلمة «الشخص N» قديمة: كل الشغل بيعمله Claude Code واحد.

**المجلدات:** `apps/customer/lib/features/{browse, cart, checkout, offer}/`
**الشاشات (14):** `02_browse_01…05` · `03_checkout_01…05` · `04_order_status_02, 03` · `07_states_01, 02`
**HTML:** `docs/design/html/02_browse.html` · `03_checkout.html` · `04_order_status.html` · `07_states.html`

> مسارك مرتبط بالمال. **لا تحسب أي سعر بالتطبيق** — السيرفر بيسعّر وأنت بتعرض `formatted`.
> لحد ما يجهز `barq_core` (يوم 2–4): اشتغل بـ Fake repositories (شوف `docs/ARCHITECTURE.md` القسم 5).

---

## المهام بالترتيب

### P2-01 · الموديلات والبيانات الوهمية
**برومبت:**
```
اقرأ AGENTS.md و docs/ARCHITECTURE.md.
اعمل في apps/customer/lib/features/browse/data/ و cart/data/ الموديلات: Category, Product (مع options/choices),
VendorSummary, BasketComparison, BasketStore, Quote, Offer — الحقول من components.schemas في docs/api/openapi.json،
بس الحقول اللي بتظهر بالتصميم. الأسعار نوعها Money من barq_core.
واعمل BrowseRepository و CartRepository (abstract) + نسخة Fake فيها بيانات من صور التصميم
(ميني ماركت النور، بندورة بلدية ₪7…). لا تعمل شاشات بهالمهمة.
```

### P2-02 · حالة السلة (CartCubit)
- سلة **متجر واحد**: `vendorId` + أسطر (`product_id`, `qty`, الخيارات، الاسم والصورة للعرض فقط).
- محفوظة بـ `shared_preferences` (ترجع لو انسكر التطبيق).
- `count` للـ badge على زر السلة بشريط التنقل.
- دالة `rebuildFromOrder(Order order)` — P3 بيستخدمها لزر "إعادة الطلب".
- الحدود من `config.modules_config.catalog.cart` (`max_lines` 50، `max_qty` 99).

### P2-03 · الرئيسية — `02_browse_01`
`GET /categories` · `GET /vendors` · `GET /products` (بدون تسجيل دخول). البانر البرتقالي `BarqBanner`، كروت المنتجات `BarqProductTile`.

**تعديل بعد المراجعة (بيلغي التصميم بهالجزء):** المنتجات بصف أفقي بدل الشبكة والكاروسيل. تحته قسم «متاجر قريبة» مع «عرض الكل»: صف أفقي من كروت المتاجر (الشعار، الاسم، `distance_km`، `prep_minutes`، التقييم) من `GET /vendors` مع `lat` و `lng` للعنوان الافتراضي.

**الموقع والمنتجات بالرئيسية:** «الأقرب» بيتقاس من العنوان الافتراضي، وإذا ما في عنوان من GPS الجهاز (`UserLocation`). السلة فاضية = منتجات أقرب متجر مفتوح. السلة فيها منتجات = منتجات متجر السلة. بدون موقع، أو إذا أقرب متجر ما عنده منتجات = كل المنتجات.

### P2-03ب · كل المتاجر (بدون تصميم)
بتفتح من «عرض الكل». مبنية من barq_ui بنفس شكل القوائم الثانية.
- `GET /vendors` مع `lat` و `lng` وترقيم صفحات.
- Chips: «الكل» و «مفتوح الآن» (`open_now=1`. لازم 1، السيرفر بيرجع 422 لـ `true`).
- كل صف: الشعار، الاسم، القسم، التقييم، `prep_minutes`، `distance_km`، pill مفتوح/مغلق.
- حالات تحميل وفراغ وخطأ. الضغط على متجر بيفتح صفحة المتجر.

### P2-04 · منتجات القسم — `02_browse_02`
`GET /products?category=…` + ترقيم صفحات (تحميل عند آخر القائمة). Chips الأقسام الفرعية `BarqChipsRow`. نفس الشاشة بتفتح من تبويب **«الأقسام»**.

### P2-05 · نتائج البحث — `02_browse_03`
`GET /products?q=…` مع **debounce 400ms**. حالة "لا نتائج".

### P2-06 · صفحة المتجر — `02_browse_04`
`GET /vendors/{id}` + منتجاته بـ `GET /products?vendor={id}`.
الهيدر: الرجوع يمين (RTL)، وعلى اليسار مشاركة (`share_plus`: اسم المتجر + العنوان) واتصال (`tel:`، بيختفي إذا ما في رقم).

### P2-07 · تفاصيل المنتج — `02_browse_05`
`GET /products/{id}` — الخيارات (options/choices) + `BarqQtyStepper` + "أضف للسلة". إذا السلة من متجر ثاني → `showBarqSheet` يسأل "تفريغ السلة؟".

### P2-08 · السلة + السلة فارغة — `03_checkout_01` · `07_states_02`
محلية (من CartCubit). زر "قارن سلتك بمتاجر منطقتك" → P2-09. المجموع هون للعرض فقط ("التوصيل يُحسب عند تأكيد الطلب").

### P2-09 · السلة الأوفر + لا يوجد متجر بكل الأصناف + خارج المنطقة — `03_checkout_02` · `03_checkout_03` · `07_states_01`
`POST /baskets/compare` بـ `cart: [{product_id, qty}]` + `dropoff_address_id`.
- `cheapest_vendor_id` = الكرت الأخضر "الأوفر".
- `stores[].complete=false` → "ناقص N" + أسماء الناقص (`not_sold` / `not_enough_stock`).
- **إذا ولا متجر `complete`** → شاشة `03_checkout_03` (جديدة): "أكمل من …" أو "تعديل السلة".
- خطأ `out_of_zone` → شاشة `07_states_01`.
- اختيار متجر = تبديل vendor بالسلة للمتوفر عنده.
- **المقارنة بين أقرب 3 متاجر كاملة** (المسافة من `GET /vendors`، لأن compare ما بيرجعها). لكل واحد `POST /orders/quote` بـ `vendor_id` و `store_product_id` تبعه، والترتيب و«الأوفر» حسب `total` من السيرفر (منتجات + توصيل). الـ quote الفاشل بيعرض سعر المنتجات مع «التوصيل يُحسب لاحقًا». المتاجر الناقصة بتظهر بس بشاشة `03_checkout_03` لما ما يكون في ولا متجر كامل.

### P2-10 · تأكيد الطلب — `03_checkout_04`
- العنوان: **`AddressPickerSheet` من P1** (إذا لسا مش جاهز، Fake).
- الدفع: "نقدًا عند الاستلام" فقط (`payment_methods`).
- "إذا نفد صنف": `BarqSegmented` → `fields.substitutions`.
- الكوبون: `POST /coupons/validate`.
- `POST /orders/quote` → اعرض `breakdown` و `total` كما هي + عدّاد من **`expires_in`** ("السعر محجوز لك لمدة 07:12").

### P2-11 · انتهت صلاحية السعر — `03_checkout_05`
لما العداد يخلص أو خطأ `quote_expired`: quote جديد → اعرض القديم مقابل الجديد لكل سطر تغيّر.

### P2-12 · إنشاء الطلب
`POST /orders` بـ `quote_token` + `note` + `fields`، و **`Idempotency-Key`**:
- مفتاح UUID جديد لما المستخدم يضغط "تأكيد الطلب" أول مرة.
- **نفس المفتاح** لو أعاد المحاولة بعد انقطاع النت (عشان ما يتكرر الطلب).
- بعد النجاح: فرّغ السلة → `context.go('/orders/{id}')` (شاشة P3 "بانتظار المتجر").

### P2-13 · عرض السعر من المتجر — `04_order_status_02`
للمنتجات بالوزن (الطلب بحالة `priced`). `GET /orders/{id}/offer` — **404 يعني لسا ما تسعّر** (مش خطأ). موافقة/رفض: `…/offer/approve` · `…/offer/reject`. العدّاد من `expires_at`.

### P2-14 · انتهى عرض السعر — `04_order_status_03`
حالة `expired`. زر "اطلب نفس السلة" → `CartCubit.rebuildFromOrder` → السلة.

---

## برومبت كل شاشة (غيّر اللي بين الأقواس)
```
اقرأ AGENTS.md و docs/ARCHITECTURE.md. المهمة [P2-09] من docs/tasks/02_browse_cart_checkout.md (اقرأها كاملة).
التصميم: الصور المرفقة + قسم "[السلة الأوفر]" في docs/design/html/[03_checkout].html.
الـ API: [POST /baskets/compare] — الحقول بالضبط من docs/api/openapi.json.
اشتغل داخل apps/customer/lib/features/[cart]/ فقط: data/ + state/ (Cubit) + ui/.
مكونات barq_ui فقط (packages/barq_ui/README.md القسم 4). الأسعار من formatted.
لف الشاشة بـ DesignOverlay(image: 'design/[03_checkout_02].png').
حالات: تحميل + فراغ + خطأ. بالآخر flutter analyze.
```
**مساراتك بالـ router:** اطلب من القائد (أو PR صغير): `/home` `/categories` `/search` `/vendor/:id` `/product/:id` `/cart` `/cart/compare` `/checkout` `/orders/:id/offer`.

## بتسلّم لـ
- **P3:** `order_id` بعد إنشاء الطلب + `CartCubit.rebuildFromOrder`.
## بتعتمد على
- **P1:** `ApiClient` + `AddressPickerSheet` (شرط لتأكيد الطلب).

## خلصت لما
- من الرئيسية لحد إنشاء طلب حقيقي بنجاح (بالـ sandbox).
- إعادة المحاولة بعد انقطاع النت ما بتكرر الطلب.
- انتهاء السعر، انتهاء العرض، خارج المنطقة، السلة الفارغة، ولا متجر كامل — كلها شغالة.
