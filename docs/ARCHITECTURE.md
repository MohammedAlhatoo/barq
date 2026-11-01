# البنية التقنية — برق

هذا الملف بيحدد **شكل المشروع والأسماء المتفق عليها**. أي اسم كلاس أو دالة مكتوب هون **ثابت** — لا تغيّره بدون نقاش مع الفريق.

---

## 1) شكل المستودع (monorepo)

```
barq/
├─ AGENTS.md                 ← قواعد Claude Code (وأي مساعد ذكي)
├─ CLAUDE.md                 ← بيحوّل Claude Code لـ AGENTS.md
├─ apps/
│  ├─ customer/              ← تطبيق الزبون
│  └─ driver/                ← تطبيق السائق (برق كابتن)
├─ packages/
│  ├─ barq_ui/               ← الشكل: ألوان، خطوط، أيقونات، widgets (جاهزة ✅)
│  └─ barq_core/             ← المنطق المشترك: API، الدخول، الإعدادات، الرفع، التحديث الدوري، عرض الحالة
└─ docs/
   ├─ design/screens  html  overlay
   ├─ api/            openapi.json · postman · API_NOTES.md
   ├─ PLAN.md         ← ترتيب التنفيذ (مراحل)
   ├─ notes/          ← شرح كل مرحلة بالعربي للفريق
   └─ tasks/          مواصفات كل جزء (01…04)
```

## 2) الحزم المستخدمة (بتنضاف بالمرحلة 0)

| الحزمة | لشو | وين |
|---|---|---|
| `flutter_bloc` | إدارة الحالة (Cubit فقط) | التطبيقين |
| `go_router` | التنقل | التطبيقين |
| `dio` | الطلبات | barq_core |
| `flutter_secure_storage` | حفظ التوكن | barq_core |
| `shared_preferences` | كاش الإعدادات + السلة | barq_core / customer |
| `uuid` | Idempotency-Key | barq_core |
| `connectivity_plus` | كشف انقطاع النت | barq_core |
| `image_picker` | الكاميرا وصورة الملف | التطبيقين |
| `flutter_map` + `latlong2` | الخريطة (مجانية بدون مفتاح) | التطبيقين |
| `geolocator` | موقع السائق والزبون | التطبيقين |
| `url_launcher` | فتح المالحة والاتصال | التطبيقين |
| `share_plus` | مشاركة رابط التتبع | customer |
| `flutter_localizations` + `intl` | العربي/الإنجليزي | التطبيقين |

> ممنوع أي حزمة جديدة بدون نقاش مع الفريق.

## 3) شكل كل تطبيق (feature-first)

```
apps/customer/lib/
├─ main.dart
├─ app/
│  ├─ app.dart               ← MaterialApp + الثيم + اللغة
│  ├─ router.dart            ← كل المسارات
│  └─ di.dart                ← إنشاء ApiClient والمستودعات
├─ l10n/                     ← app_ar.arb · app_en.arb
└─ features/
   ├─ auth/              splash · onboarding · phone · otp · welcome
   ├─ account/           account · edit profile · delete · addresses · add address
   ├─ system/            no internet · force update · maintenance · session expired
   ├─ browse/            home · category · search · vendor · all vendors · product
   ├─ assistant/         مساعد برق: قراءة القائمة · مطابقة المنتجات · المحادثة
   ├─ cart/              cart · compare · no single store · empty cart
   ├─ checkout/          confirm order · quote expired · out of zone
   ├─ offer/             store price offer · offer expired
   ├─ orders/            waiting · tracking · cancel · delivered+rate · my orders · receipt · share link
   └─ notifications/       

كل feature جواها:
   data/    xxx_repository.dart     ← بينادي ApiClient ويرجع models
   state/   xxx_cubit.dart + xxx_state.dart
   ui/      xxx_screen.dart + widgets/
```

تطبيق السائق نفس الفكرة: `apps/driver/lib/features/{auth, jobs, task, delivery, earnings, history, profile, notifications}`.

## 4) عقد `barq_core` (الأسماء الثابتة)

هالأشياء بتنبني بالمرحلة 1 من `docs/PLAN.md`، وكل التطبيقين بيستخدموها.

```dart
import 'package:barq_core/barq_core.dart';

// ── الإعداد ──
enum BarqAppKind { customer, driver }
class BarqEnv {
  static const baseUrl = 'https://masar.toldpath.com/api/v1';
  static const projectKey = String.fromEnvironment('BARQ_PROJECT_KEY'); // لا يُكتب بالكود
  static const devMember  = String.fromEnvironment('BARQ_DEV');         // اسم يظهر بلوحة المشروع
}

// ── الطلبات ──
class ApiClient {
  Future<dynamic> get(String path, {Map<String, dynamic>? query});
  Future<dynamic> post(String path, {Object? body, String? idempotencyKey});
  Future<dynamic> put(String path, {Object? body});
  Future<dynamic> delete(String path);
  Future<Paged<dynamic>> getPaged(String path, {Map<String, dynamic>? query}); // data + meta
  // بيرجع "data" من الرد مباشرة. بيضيف تلقائيًا: X-Project-Key, Authorization,
  // Accept-Language, X-App-Version, X-Dev-Member. أي خطأ → ApiException.
  Stream<ApiException> get systemErrors;  // تحديث إجباري وصيانة من أي طلب
}
String newIdempotencyKey();  // UUID جديد لهيدر Idempotency-Key
class Paged<T> { final List<T> items; final int? nextPage; final int? total; }

class ApiException implements Exception {
  final int status;          // 401, 404, 409, 422, 426, 503…
  final String code;         // already_taken, out_of_zone, quote_expired, invalid_transition…
  final String messageAr;    // جاهز للعرض (من hint.ar أو message)
  final Map<String, dynamic>? details;
  String get userMessage;    // للعرض: أول رسالة من details.fields، وإلا messageAr
  bool get isNetwork;        // انقطاع نت / timeout
  bool get isUpdateRequired; // app_update_required
  bool get isMaintenance;    // maintenance · project_frozen
}

// ── الدخول ──
class AuthStore extends ChangeNotifier {
  String? get token; bool get isLoggedIn;
  Future<void> save(String token); Future<void> clear();
  Stream<void> get sessionExpired;  // بيطلق لما أي طلب يرجع 401
}

// ── الإعدادات ──
class ConfigStore extends ChangeNotifier {
  Future<void> load();                         // GET /app/config + كاش + ETag
  AppConfig get config;
}
class AppConfig {
  final String deliveryConfirmation;           // "photo" حاليًا
  final List<String> paymentMethods;           // ["cash_on_delivery"]
  final List<StatusInfo> statuses;
  StatusInfo status(String key);               // label + color + icon + step + isTerminal
  final PollingConfig polling;                 // trackingSeconds, eventsSeconds, availableOrdersSeconds…
  final DriverConfig? driver;                  // radiusKm, locationMinIntervalSeconds…
  final String currencySymbol;                 // ₪
  final String? minAppVersion;                 // أقدم نسخة مسموحة → شاشة "تحديث إجباري"
  bool hasModule(String m);                    // basket_compare, coupons, public_tracking…
  bool requiresUpdate(String appVersion);      // النسخة أقدم من minAppVersion
  final String? supportPhone;                  // project.support_phone
  final String? termsUrl;                      // terms_url
}
// الصيانة ما إلها حقل بالإعدادات: بتيجي كخطأ ApiException(code: 'maintenance')،
// والتحديث الإجباري كمان ممكن ييجي كخطأ 426 app_update_required.

// ── الرفع ──
class UploadService { Future<int> upload(File file, {required String purpose}); } // يرجع upload_id

// ── الشبكة ── (في barq_core/lib/src/network/)
class NetworkMonitor { Future<bool> isOnline(); Stream<bool> get onlineChanges; }

// ── التحديث الدوري ── (في barq_core/lib/src/polling/)
class Poller {  // بيوقف لحاله لما التطبيق بالخلفية
  Poller({required Future<int?> Function() tick, required int defaultSeconds});
  void start(); void stop();  // tick بترجع next_poll_seconds إذا السيرفر رجعه
}

// ── الإشعارات ──

// ── عرض الحالة ── (في barq_core/lib/src/status/ ويستخدم BarqPill/BarqTimeline)
class OrderStatusPill extends StatelessWidget { const OrderStatusPill(String statusKey); }
class OrderStatusTimeline extends StatelessWidget { const OrderStatusTimeline({required keys, required current}); } // keys من OrderTimelines
abstract final class OrderTimelines { static const waiting = [...]; static const tracking = [...]; } // الاستثناء الوحيد للقاعدة 4

// ── موديلات مشتركة ──
class Money { final int amount; final String formatted; }   // اعرض formatted دائمًا
```

## 5) المستودعات (Repository)
كل مستودع إله واجهة ونسخة حقيقية، ونسخة Fake للتجربة بدون نت إذا احتجنا:
```dart
abstract class CartRepository { Future<BasketComparison> compare(...); }
class ApiCartRepository implements CartRepository { ... }   // الحقيقي
class FakeCartRepository implements CartRepository { ... }  // بيانات من التصميم
```
وبـ `di.dart` بتختار أي وحدة تستخدم.

## 6) Git
- `main` = نسخة مستقرة. الشغل اليومي على `dev`.
- كل مرحلة من `docs/PLAN.md` بفرع: `phase-1-core` → Pull Request على `dev` → الفريق بيراجع ويناقش → دمج.
- رسالة الـ commit: `phase-1: ApiClient + ApiException` (المرحلة + وصف قصير بالإنجليزي).
- لما تخلص مرحلة ومستقرة: دمج `dev` على `main`.
- ممنوع ترفع: مفتاح المشروع، `build/`، `.dart_tool/`، ملفات `.env`.

## 7) التشغيل
```
flutter run --dart-define=BARQ_PROJECT_KEY=pk_test_xxx --dart-define=BARQ_DEV=barq
```
(المفتاح ما بينكتب بأي ملف مرفوع. بأندرويد ستوديو: Run ← Edit Configurations ← Additional run args.)
