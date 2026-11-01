# ملاحظات الـ API — برق (config_version 3)

المرجع الكامل: `docs/api/openapi.json`. للتجربة: `docs/api/postman/` (القائد بيعطيكم ملف الـ environment فيه المفتاح على الخاص).

## 1) أساسيات كل طلب
- العنوان: `https://masar.toldpath.com/api/v1` + المسار (مثلًا `/orders`).
- هيدرات: `X-Project-Key` (دائمًا) · `Authorization: Bearer <token>` (بعد الدخول) · `Accept-Language: ar|en` · `X-App-Version` · `X-Dev-Member: p2` (اسمك، بيسهّل تتبع طلباتك بلوحة المشروع).
  **كلها بيضيفها `ApiClient` تلقائيًا — ما تضيفها بإيدك.**
- شكل الرد الناجح: `{ success, message, data, meta?, request_id }` → `ApiClient` بيرجعلك `data`.
- الأسعار: `Money { amount (بالأغورة), formatted ("8.90 ₪") }` → **اعرض `formatted` بس**.
- ما في WebSocket: التحديث بالـ polling (المدد من `config.polling`). الإشعارات قائمة داخل التطبيق من الـ API، وما في إشعارات فورية (FCM) بقرار من المدرّس.

## 2) الأخطاء
شكل الخطأ: `{ success:false, message, error:{ code, details, hint:{ar,en} }, request_id }` → بيصير `ApiException`.

| الكود | الحالة | شو بتعمل |
|---|---|---|
| `unauthenticated` (401) | أي شاشة | `AuthStore` بيمسح التوكن → شاشة "انتهت الجلسة" (P1) |
| `out_of_zone` (422) | compare / quote | شاشة "خارج منطقة الخدمة" (P2) |
| `quote_expired` / `quote_used` (410) | إنشاء الطلب | إعادة التسعير وعرض الفرق (P2) |
| `conflict` (409) `quote_payload_mismatch` | إنشاء الطلب | `fields` لازم تطابق الـ quote، فأي تغيير بيطلب quote جديد |
| `idempotency_mismatch` (409) | إعادة طلب | نفس المفتاح لازم يروح مع نفس الجسم بالضبط |
| `already_taken` (409) | قبول طلب سائق | شاشة "سبقك سائق" (P4) |
| `cash_limit_reached` | قبول طلب | شاشة "حد النقد" (P4) |
| `invalid_transition` (422) | خطوة سائق | `details` فيها الحالات المسموحة؛ حدّث المهمة (P4) |
| `app_update_required` (426) | أي طلب | شاشة "تحديث إجباري" (P1) |
| `maintenance` · `project_frozen` | أي طلب | شاشة "صيانة" (P1) |
| `too_many_requests` (429) | أي طلب | خفف التكرار (خصوصًا الموقع والـ polling) |
| `validation_failed` (422) | نماذج | اعرض الخطأ تحت الحقل من `details` |
| 404 على `/orders/{id}/offer` | قبل التسعير | طبيعي: الطلب لسا ما تسعّر |

## 3) الإعدادات الحالية (من `GET /app/config`)
- `delivery_confirmation: "photo"` → **التسليم بالصورة** (تفاصيل تحت).
- `payment_methods: ["cash_on_delivery"]` → الدفع عند الاستلام فقط.
- `polling`: tracking 30ث · events 5ث · available_orders 10ث · notifications 10ث · config 300ث. (اقرأها من الإعدادات، الأرقام هون للتوضيح).
- `driver`: radius_km 10 · location_min_interval_seconds 3 · online_requires_location_minutes 5.
- `modules`: approval, attachments, basket_compare, catalog, coupons, public_tracking, vendors.
- `min_app_version: "1.0.0"`.
- `statuses`: أسماء وألوان الحالات — **من هون فقط**.

## 4) رحلة التسليم بالصورة (مهم للجميع)
1. السائق بيقبل → `accepted` → بيروح للمتجر.
2. عند المتجر: `next_action.to = picked_up` و `requires` بتقول شو المطلوب (صورة / موقع ضمن النطاق) → السائق بيصوّر الطلب → `POST /uploads` (`purpose: proof_photo`) → `POST /driver/orders/{id}/transition` مع `to` و `upload_ids`.
3. `on_the_way` → `arrived` بنفس الطريقة (الزر من `next_action`).
4. عند الزبون: `next_action.action = deliver` → السائق بيصوّر التسليم → `POST /uploads` → `POST /driver/orders/{id}/deliver` مع `upload_ids` (+ `note` اختياري). وبيحصّل المبلغ من `payment.collect.formatted`.
5. **الزبون ما بيشوف ولا بيعطي أي رمز.** ما في `delivery_code` بتطبيق الزبون.

## 5) تصحيحات على "خطة توزيع المهام" (PDF)
الخطة انكتبت قبل آخر تحديث للـ API. هاي النقاط **بتلغي** اللي بالخطة:
| بالخطة | الصح الآن |
|---|---|
| P3: "عرض delivery_code للزبون" | ❌ ملغية — التسليم بالصورة |
| P4: "إدخال رمز الاستلام OTP من الزبون" | ❌ بدالها: صورة التسليم + `upload_ids` |
| P4: دخول السائق "رمز تحقق" بالتصميم | ✅ التصميم انعدّل: هاتف + كلمة مرور |
| P2: 13 شاشة | 14 شاشة — انضافت "لا يوجد متجر بكل الأصناف" (`03_checkout_03`) |
| عدد الشاشات 51 | 52 شاشة (+ صفحة الهوية) |
| القسم 6: "السائق يدخل رمز الاستلام" | السائق يصوّر التسليم ويؤكد |
| الألوان من `project.colors` | لا — الألوان من `barq_ui` (السيرفر لسا بيرجع `#CCE2EA` القديم) |

## 6) نقاط لازم تنحكى لصاحب الـ API
- تغيير لون المشروع بالإعدادات لـ `#FF7A21`.
- إحداثيات منطقة "جلاء" بالـ zones فيها خطأ — لازم تتصحح.
- رقم اللوحة: `PUT /driver/me` ما بيقبله → بنعرضه للقراءة فقط.
- حقل المنطقة بشاشة "أهلًا بك": `PUT /me` ما بيقبله → المنطقة بتتحدد من أول عنوان.
- إعادة الطلب: ما إله endpoint → بنعيد بناء السلة من بنود الطلب ونعمل quote جديد.
- وحدة القياس («/ كغ»): ما إلها حقل بالمنتج، فالشاشات ما بتعرضها (الاسم نفسه فيه «١ كغ»).
- نسبة الخصم («−25%»): السيرفر ما بيرجعها، والقاعدة بتمنع الحساب، فبنعرض السعر المشطوب بس.
- المفضلة: ما إلها endpoint → القلب مخفي.
- الترتيب («الأرخص أولًا» و«الأكثر طلبًا»): `GET /products` ما عنده `sort`، فالقوائم بترتيب السيرفر.
- `POST /baskets/compare` ما بياخد `options`، ومتجر السلة ممكن ما يطلع بالمقارنة إذا مش بيوصّل لعنوان المستخدم. فما في مصدر مضمون لمجموع السلة قبل التسعير.
- `POST /orders/quote`: رسوم التوصيل على الـ sandbox ثابتة لكل منطقة (7.00 ₪ للنصيرات)، فترتيب «الأوفر» شامل التوصيل بيطلع نفس ترتيب سعر المنتجات حاليًا.
- `POST /orders/quote`: الوصف بيقول التوكن صالح 10 دقائق، والسيرفر بيرجع `expires_in` قريب من 3600. اعتمدنا الرقم من الرد.
- `GET /vendors`: `open_now` نوعه boolean بالـ openapi، بس السيرفر بيقبل `1` وبيرجع 422 لـ `true`. و `page` شغال ومش مكتوب.
- `POST /baskets/compare` ما بيرجع المسافة، فأقرب المتاجر بتنحسب من `distance_km` بـ `GET /vendors`.
- `GET /vendors` بيرتّب المفتوحة أولًا ثم الأقرب، فمتجر مغلق قريب بييجي بعد مفتوح بعيد.
- `category` بالمتجر مفتاح زي `grocery` مش نص للعرض، فالترجمة بالتطبيق.
- `POST /orders/quote` بيسعّر متجر مش بيوصّل لمنطقة العنوان (مجرّب: متاجر غزة مع عنوان بالنصيرات)، مع إن `/baskets/compare` ما بيرجعها. و `POST /orders` كمان بيقبلها (مجرّب على متجر 7). لازم صاحب الـ API يقرر إذا هاد مقصود. التطبيق بيحمي نفسه: `CheckoutCubit` بيعمل compare قبل الـ quote وبيوقف إذا متجر السلة مش بالنتيجة. الحماية بالتطبيق بس، فأي عميل ثاني للـ API لسا بيقدر يطلب.
- السيرفر بيقبل `page` بـ `GET /products` (مجرّب على الـ sandbox) بس مش مكتوب بـ `openapi.json`.
- «وفّرت» بشاشة حسابي: السيرفر ما بيرجعها وممنوع نحسبها، فمخفية.
- اسم المنطقة و«داخل الخدمة» قبل الحفظ: ما في endpoint بيفحص نقطة بدون ما يحفظها، فالتطبيق بيعرف النتيجة بس من رد `POST /addresses` أو `PUT /addresses/{id}`. ولهيك كمان عنوان القائمة بيعرض `details` بدون اسم المنطقة.
- `GET /app/config`: شكل `zones[].polygon` مش موضّح بـ `openapi.json` (`additionalProperties: true`).
- مش موضّح بـ `openapi.json`: شو بيصير للافتراضي لما ينحذف العنوان الافتراضي، ولما المستخدم يبعت `is_default: false` على عنوانه الوحيد. `test/live_account_test.dart` بيطبع الأول.
- `DELETE /me`: `openapi.json` ما بيذكر كود الخطأ لما يكون في طلب جاري، مع إن التصميم بيقول «الطلبات الجارية يجب أن تنتهي أولًا». التطبيق بيعرض `messageAr` لأي رفض.
- `POST /orders/{id}/offer/approve`: انحلت مشكلة `invalid_transition`، ومجرّب بالمرحلة 6: الطلب بيروح من `priced` لـ `pending` مباشرة. لسا `openapi.json` ما بيذكر `offer_id` المطلوب بالـ body.
- كل الطلبات بتبدأ بـ `awaiting_pricing` (حتى لو كل المنتجات `price_mode: fixed`)، مش بس منتجات الوزن. وما لقينا أي منتج بالوزن بأول 5 صفحات من `GET /products`.
- `Offer` ما فيه خصم، مع إن `total` شامل الكوبون، فالتطبيق بياخد سطر الخصم من `order.price.breakdown`.
- `breakdown`: سطر الخصم `amount` موجب و `formatted` سالب. و `discount.formatted` بالرد موجب.
- `payment_methods` بترجع `cash_on_delivery`، و `POST /orders/quote` بيرجع `payment_method: "cash"`.
- `GET /orders/{id}` لسا بيرجع `delivery_code`، والتطبيق ما بيعرضه.
- `POST /orders/{id}/offer/reject` على عرض مسكّر بيرجع `invalid_transition` مع `to: pending`.
- `config_version` صار 4 على الـ sandbox، و `AGENTS.md` بيقول 3. مش ملاحظين فرق بالحقول اللي بنستخدمها.
- كوبون `BARQ5` تبع التصميم مش موجود بالـ sandbox. للتجربة: `WELCOME10` (10% لأول طلب، حد أدنى 30.00 ₪).
- `POST /orders/quote` ما بيرجع سعر لكل منتج، فشاشة انتهاء السعر بتقارن من `GET /products/{id}`.
- `currency.minor_units` هو عدد الوحدات الصغيرة بالوحدة الكبيرة (100 أغورة بالشيكل)، مش عدد الخانات العشرية. `openapi.json` بيقول `integer` بس بدون شرح.
- `GET /orders/{id}/events`: `meta` فيها `next_since` و `has_more` و `status` و `next_poll_seconds`. مكتوب بالوصف `next_since` بس.
- `GET /notifications`: `meta.unread` فيها عدد غير المقروءة، و `data` فيها `order_id` و `status` و `type`. مش مكتوبين بـ `openapi.json`.
- `OrderSummary` ما فيه اسم المتجر ولا `eta_minutes` ولا `available_actions`، مع إن شاشة طلباتي بالتصميم بتعرضهم.
- `Receipt` ما فيه اسم المتجر ولا رابط PDF، و `items` بدون سعر، فالفاتورة بتجيب المتجر من `GET /orders/{id}` وزر PDF مخفي.
- `GET /cancel-reasons` بيرجع 11 سبب، منها أسباب للسائق زي «تعطل المركبة»، والتصميم فيه 5. التطبيق بيعرض اللي بيرجع.
- `POST /orders/{id}/rate` قبل التوصيل بيرجع `409 conflict` مع `reason: not_delivered`.
- `POST /sandbox/orders/{id}/advance` بعد `pending` بيرجع `409 conflict`، مش `nothing_to_do` زي الوصف.
- `Tracking` ما فيه المسافة المتبقية، فملصق «2.1 كم» مخفي. وما في API لمحادثة السائق.
- `payment.status` بيرجع `cash_on_delivery` حتى بعد الإلغاء، فملصق «مدفوع نقدًا» بنعرضه للطلب الموصّل بس.
- `config_version` صار 5 على الـ sandbox.
- دخول السائق: `POST /driver/auth/login` بيقبل الرقم بالشكل المحلي بس (`059…`)، وبيرفض `+970…` بـ `422`، عكس دخول الزبون. التطبيق بيعرض ملصق +970 وبيبعت الرقم بصفر بالأول.
- رد كلمة المرور الغلط `422 validation_failed` مع السبب بـ `details.fields.phone`، و `hint.ar` نص للمطورين، فالتطبيق بيعرض `userMessage`.
- `PUT /driver/status` بدون موقع حديث بيرجع `422 validation_failed` على `is_online`، مش كود خاص.
- `POST /orders/quote` بيرجع `422 vendor_closed` خارج ساعات الدوام، مع إن `details.is_open = true`. الحقل الصح هو `is_open_now`. متاجر الـ sandbox بتسكّر الساعة 23:00، فما بتقدر تعمل طلب تجريبي بالليل.
- عرض الطلب للسائق ما إله مهلة بالـ API، فعدّاد «0:21» بالتصميم مخفي.
- ساعات العمل بشاشة «غير متصل» ما إلها حقل، فبنعرض عدد طلبات اليوم بدالها.
- مكتب برق (الموقع وساعات الدوام) ما إله API، فبشاشة حد النقد زر «الذهاب للمكتب» وصف المكتب مخفيين، والطريق هو «تواصل مع الدعم».
- `requires` بـ `next_action`: قيمها مش موثقة بـ `openapi.json`.
- `openapi.json` ما بيحدد كود الخطأ لما السائق يكون خارج `geofence_meters`، ولا مكان المسافة بـ `details`. التطبيق بيعتبر الرفض «بعيد» لما يكون `422` مع `out_of_zone` أو مفتاح فيه `distance` بـ `details`. لازم يتأكد على الـ sandbox.
- `OrderSummary` بسجل السائق ما فيه اسم المتجر ولا أجرة السائق ولا سبب الإلغاء، فالسطر بيعرض مكان التسليم والوقت والرمز والنقد.
- `Earnings` ما فيه مقارنة بالفترة الماضية، فملصق «+12%» مخفي.
- `Driver` ما فيه عدد المهام، و `zone_id` رقم بدون اسم، فملصقا «326 مهمة» و«المنطقة الوسطى» مخفيين. و `rating.count` عدد التقييمات، مش المهام.
- `GET /driver/notifications`: `event` مش موثقة قيمه، فكل الإشعارات بأيقونة الجرس.
- `GET /products?q=` بيطابق النص حرفيًا: `بندوره` و `البندورة` و `ارز` بيرجعوا صفر، و `بندورة` و `أرز` بيرجعوا 24. فمساعد برق بيجرب إملاءات بديلة، والبحث العادي بالتطبيق لسا ما بيجربها. مفيد لو السيرفر يوحّد الحروف.
- `GET /products?q=` بالإنجليزي: الأسماء مش موحّدة بين المتاجر (`Cucumber 1kg` و `Cucumbers 1 kg`)، فـ `cucumbers` بيرجع 1 و `cucumber` بيرجع 24. والاسم بالرد بيتبع `Accept-Language`.
- ولا منتج بالـ sandbox فيه `options`، فاستخدام خيار الوزن بمساعد برق مجرّب على `FakeServer` بس. وبيفترض إن مفتاح الخيار نفسه بكل نسخ المنتج بالمتاجر، وهاد مش مكتوب بـ `openapi.json`.
- كتالوج الـ sandbox 12 منتج بس، كل واحد بـ 24 نسخة (نسخة لكل متجر، بـ `id` مختلف). `POST /baskets/compare` بيربط النسخ ببعض، حتى لو الـ `product_id` من متجر خارج المنطقة. طريقة الربط مش مكتوبة بـ `openapi.json`.
