# ملاحظات الـ API — برق (config_version 3)

المرجع الكامل: `docs/api/openapi.json`. للتجربة: `docs/api/postman/` (القائد بيعطيكم ملف الـ environment فيه المفتاح على الخاص).

## 1) أساسيات كل طلب
- العنوان: `https://masar.toldpath.com/api/v1` + المسار (مثلًا `/orders`).
- هيدرات: `X-Project-Key` (دائمًا) · `Authorization: Bearer <token>` (بعد الدخول) · `Accept-Language: ar|en` · `X-App-Version` · `X-Dev-Member: p2` (اسمك، بيسهّل تتبع طلباتك بلوحة المشروع).
  **كلها بيضيفها `ApiClient` تلقائيًا — ما تضيفها بإيدك.**
- شكل الرد الناجح: `{ success, message, data, meta?, request_id }` → `ApiClient` بيرجعلك `data`.
- الأسعار: `Money { amount (بالأغورة), formatted ("8.90 ₪") }` → **اعرض `formatted` بس**.
- ما في WebSocket: التحديث بالـ polling (المدد من `config.polling`) والإشعارات بـ FCM.

## 2) الأخطاء
شكل الخطأ: `{ success:false, message, error:{ code, details, hint:{ar,en} }, request_id }` → بيصير `ApiException`.

| الكود | الحالة | شو بتعمل |
|---|---|---|
| `unauthenticated` (401) | أي شاشة | `AuthStore` بيمسح التوكن → شاشة "انتهت الجلسة" (P1) |
| `out_of_zone` (422) | compare / quote | شاشة "خارج منطقة الخدمة" (P2) |
| `quote_expired` / `quote_used` | إنشاء الطلب | إعادة التسعير وعرض الفرق (P2) |
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
