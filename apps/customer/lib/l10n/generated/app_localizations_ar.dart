// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'برق';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'الأقسام';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get navAccount => 'حسابي';

  @override
  String get navCart => 'السلة';

  @override
  String get placeholderSoon => 'هذه الشاشة قيد البناء';

  @override
  String get splashTagline => 'احتياجات بيتك بسرعة البرق';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get onboardingSkip => 'تخطّي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ الآن';

  @override
  String get onboardingShopPill => 'توصيل خلال 30 د';

  @override
  String get onboardingShopTitle => 'تسوّق احتياجاتك اليومية بسهولة';

  @override
  String get onboardingShopBody =>
      'خضار، لحوم، ألبان ومخبوزات من متاجر منطقتك، في أي وقت ومن أي مكان.';

  @override
  String get onboardingCompareTitle => 'قارن الأسعار ووفّر في كل طلب';

  @override
  String get onboardingCompareBody =>
      'برق يقارن سلتك بين المتاجر القريبة ويقترح عليك الأرخص تلقائيًا.';

  @override
  String get onboardingCompareStoreA => 'سوبرماركت الأمانة';

  @override
  String get onboardingCompareStoreB => 'ميني ماركت النور';

  @override
  String get onboardingCompareStoreC => 'بقالة البركة';

  @override
  String get onboardingCompareItems => '8 منتجات';

  @override
  String get onboardingCompareBest => 'الأوفر · وفّر ₪9';

  @override
  String get onboardingComparePriceA => '₪52';

  @override
  String get onboardingComparePriceB => '₪43';

  @override
  String get onboardingComparePriceC => '₪49';

  @override
  String get onboardingDeliveryPill => 'تتبّع مباشر';

  @override
  String get onboardingDeliveryTitle => 'من المتجر لباب بيتك بسرعة البرق';

  @override
  String get onboardingDeliveryBody =>
      'تابع السائق على الخريطة لحظة بلحظة لحد باب بيتك.';

  @override
  String get loginTitle => 'أدخل رقم جوالك';

  @override
  String get loginBody =>
      'سنرسل لك رمز تحقق برسالة نصية لتسجيل الدخول أو إنشاء حساب جديد.';

  @override
  String get loginPhoneLabel => 'رقم الجوال';

  @override
  String get loginPhoneHint => '059 912 3456';

  @override
  String get loginCountryCode => '+970';

  @override
  String get loginSend => 'إرسال الرمز';

  @override
  String get loginAgreePrefix => 'بالمتابعة أنت توافق على ';

  @override
  String get loginTerms => 'الشروط';

  @override
  String get loginAnd => ' و';

  @override
  String get loginPrivacy => 'سياسة الخصوصية';

  @override
  String get otpTitle => 'أدخل رمز التحقق';

  @override
  String otpSentTo(int length) {
    return 'أرسلنا رمزًا من $length أرقام إلى ';
  }

  @override
  String get otpEditPhone => 'تعديل الرقم';

  @override
  String get otpResendIn => 'إعادة الإرسال بعد ';

  @override
  String get otpResend => 'إعادة الإرسال';

  @override
  String get otpConfirm => 'تأكيد';

  @override
  String get welcomeVerified => 'تم التحقق';

  @override
  String get welcomeTitle => 'أهلًا بك في برق';

  @override
  String get welcomeBody =>
      'خطوة أخيرة: عرّفنا عليك وحدّد موقعك، لنعرض لك المتاجر اللي بتوصّل لمنطقتك.';

  @override
  String get welcomeNameLabel => 'الاسم';

  @override
  String get welcomeNameHint => 'محمد أحمد';

  @override
  String get welcomeLocationLabel => 'موقع التوصيل';

  @override
  String get welcomeAddressLabel => 'موقعي';

  @override
  String get welcomeNoLocation => 'لم تحدد موقعك بعد';

  @override
  String get welcomeInZone => 'داخل منطقة الخدمة';

  @override
  String get welcomeOutOfZone => 'خارج منطقة الخدمة';

  @override
  String get welcomeLocate => 'تحديد موقعي';

  @override
  String get welcomeLocationOff =>
      'شغّل خدمة الموقع في جهازك ثم حاول مرة أخرى.';

  @override
  String get welcomeLocationDenied =>
      'اسمح لبرق بالوصول إلى موقعك من إعدادات الجهاز ثم حاول مرة أخرى.';

  @override
  String get welcomeNotifications => 'إشعارات الطلبات';

  @override
  String get welcomeNotificationsBody => 'نخبرك عند قبول طلبك ووصوله';

  @override
  String get welcomeStart => 'ابدأ التسوّق';

  @override
  String get offlineTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get offlineBody =>
      'تأكد من الاتصال وأعد المحاولة. طلبك الحالي محفوظ ولم يتأثر.';

  @override
  String get updateTitle => 'نسخة جديدة من برق';

  @override
  String get updateBody =>
      'حدّث التطبيق لتكمل الطلب. النسخة الجديدة أسرع وفيها إصلاحات مهمة.';

  @override
  String updateVersion(String version) {
    return 'نسخة $version';
  }

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get maintenanceTitle => 'برق تحت الصيانة';

  @override
  String get maintenanceBody =>
      'نحسّن الخدمة وراجعين قريبًا. طلباتك الحالية محفوظة ولن تُلغى.';

  @override
  String get maintenanceRefresh => 'تحديث الصفحة';

  @override
  String get maintenanceContact => 'للاستفسار: ';

  @override
  String get sessionTitle => 'سجّل الدخول من جديد';

  @override
  String get sessionBody =>
      'انتهت جلستك لحماية حسابك. أدخل رقمك وسنرسل لك رمزًا جديدًا.';

  @override
  String get sessionLogin => 'تسجيل الدخول';

  @override
  String get homeMorning => 'صباح الخير';

  @override
  String get homeEvening => 'مساء الخير';

  @override
  String get homeAll => 'الكل';

  @override
  String get homeBestSellers => 'الأكثر طلبًا';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeNearStores => 'متاجر قريبة';

  @override
  String get homeStores => 'المتاجر';

  @override
  String get searchHint => 'ابحث عن منتج أو متجر';

  @override
  String get soldOut => 'نفدت الكمية';

  @override
  String get browseEmpty => 'لا توجد منتجات هنا بعد';

  @override
  String get searchRecent => 'عمليات بحث سابقة:';

  @override
  String searchCount(int count) {
    return '$count نتيجة';
  }

  @override
  String get searchNoResults => 'لا نتائج';

  @override
  String get searchNoResultsBody => 'جرّب كلمة ثانية أو تأكد من الإملاء.';

  @override
  String distanceKm(String km) {
    return '$km كم';
  }

  @override
  String get vendorOpen => 'مفتوح';

  @override
  String get vendorClosed => 'مغلق';

  @override
  String vendorPrep(int minutes) {
    return 'تحضير $minutes د';
  }

  @override
  String get viewCart => 'عرض السلة';

  @override
  String cartCount(int count) {
    return '$count منتجات';
  }

  @override
  String get productTitle => 'تفاصيل المنتج';

  @override
  String get productAvailable => 'متوفر';

  @override
  String get productUnavailable => 'غير متوفر';

  @override
  String get productRequired => '(إجباري)';

  @override
  String get productDescription => 'الوصف';

  @override
  String get addToCart => 'أضف للسلة';

  @override
  String addToCartPrice(String price) {
    return 'أضف للسلة · $price';
  }

  @override
  String get otherStoreTitle => 'تفريغ السلة؟';

  @override
  String get otherStoreBody =>
      'سلتك فيها منتجات من متجر ثاني، والطلب بيكون من متجر واحد. نفرّغها ونضيف هذا المنتج؟';

  @override
  String get otherStoreConfirm => 'تفريغ وإضافة';

  @override
  String get commonKeepCart => 'إبقاء السلة';

  @override
  String get cartLimitTitle => 'وصلت للحد المسموح';

  @override
  String get cartLimitBody => 'لا يمكن إضافة المزيد إلى السلة.';

  @override
  String get commonOk => 'حسنًا';

  @override
  String get cartTitle => 'سلتي';

  @override
  String get cartClearTitle => 'إفراغ السلة؟';

  @override
  String get cartClearBody => 'بنحذف كل المنتجات من سلتك.';

  @override
  String get cartClearConfirm => 'إفراغ السلة';

  @override
  String get cartCompareTitle => 'قارن سلتك بمتاجر منطقتك';

  @override
  String get cartCompareBody => 'نشوف إذا في متجر أرخص بيوصّلك';

  @override
  String get cartTotal => 'المجموع';

  @override
  String get cartDelivery => 'التوصيل';

  @override
  String get cartAtCheckout => 'يُحسب عند تأكيد الطلب';

  @override
  String get cartContinue => 'متابعة الطلب';

  @override
  String cartContinueTotal(String total) {
    return 'متابعة الطلب · $total';
  }

  @override
  String get cartEmptyTitle => 'سلتك فارغة';

  @override
  String get cartEmptyBody =>
      'أضف منتجات من متاجر منطقتك، وبرق يقارن لك الأسعار قبل ما تطلب.';

  @override
  String get cartBrowse => 'تصفّح المتاجر';

  @override
  String get compareTitle => 'السلة الأوفر';

  @override
  String compareZone(String zone) {
    return 'متاجر منطقتك: $zone';
  }

  @override
  String compareBody(int count) {
    return 'قارنّا منتجات سلتك ($count) بالمتاجر اللي بتوصّل لعنوانك بس.';
  }

  @override
  String get compareBest => 'الأوفر';

  @override
  String compareAvailable(int available, int total) {
    return '$available من $total متوفرة';
  }

  @override
  String get compareOthers => 'متاجر أخرى بمنطقتك';

  @override
  String comparePickBest(String price) {
    return 'اختيار الأوفر · $price';
  }

  @override
  String comparePick(String store, String price) {
    return 'اختيار $store · $price';
  }

  @override
  String compareMissing(int count, String detail) {
    return 'ناقص $count · $detail';
  }

  @override
  String get compareNotEnough => 'الكمية غير كافية';

  @override
  String get noStoreBadge => 'ناقص أصناف';

  @override
  String get noStoreTitle => 'ما في متجر عنده كل سلتك';

  @override
  String noStoreBody(String zone) {
    return 'كل متاجر $zone ناقصها صنف أو أكثر. اختار متجر وبنكمّل بالمتوفر، أو عدّل السلة.';
  }

  @override
  String noStoreContinue(String store) {
    return 'أكمل من $store';
  }

  @override
  String get noStoreEdit => 'تعديل السلة';

  @override
  String get noStoresTitle => 'ما في متاجر بتوصّل لعنوانك حاليًا';

  @override
  String get outOfZoneTitle => 'لا نوصل لهذا العنوان بعد';

  @override
  String get outOfZoneBody =>
      'عنوانك خارج مناطق خدمة برق حاليًا. اختر عنوانًا آخر داخل منطقة التوصيل.';

  @override
  String get outOfZoneStoreBody =>
      'هذا المتجر ما بيوصّل لعنوانك. قارن سلتك بالمتاجر اللي بتوصّلك، أو اختر عنوانًا آخر.';

  @override
  String get outOfZoneCompare => 'مقارنة السلة بالمتاجر القريبة';

  @override
  String get outOfZoneChange => 'تغيير العنوان';

  @override
  String get noAddressTitle => 'ما عندك عنوان توصيل';

  @override
  String get noAddressBody =>
      'أضف عنوانك عشان نقارن سلتك بالمتاجر اللي بتوصّلك.';

  @override
  String get noAddressAdd => 'إضافة عنوان';

  @override
  String get checkoutTitle => 'تأكيد الطلب';

  @override
  String get compareWithDelivery => 'شامل التوصيل';

  @override
  String get compareDeliveryLater => 'التوصيل يُحسب لاحقًا';

  @override
  String scopeShoppingFrom(String store) {
    return 'تتسوّق من: $store';
  }

  @override
  String get scopeCartStore => 'متجر سلتك';

  @override
  String get scopeAllStores => 'كل المتاجر';

  @override
  String get scopeOnlyMine => 'متجر سلتي فقط';

  @override
  String get vendorsTitle => 'كل المتاجر';

  @override
  String get vendorsOpenNow => 'مفتوح الآن';

  @override
  String get vendorsEmpty => 'لا توجد متاجر حاليًا';

  @override
  String get vendorNew => 'جديد';

  @override
  String get vendorCategoryGrocery => 'بقالة';

  @override
  String get vendorCallFailed => 'تعذّر فتح الاتصال';

  @override
  String get cartWithDelivery => 'الإجمالي مع التوصيل';

  @override
  String get compareCurrentCart => 'سلتك الحالية';

  @override
  String get compareCurrentIsBest => 'متجرك الحالي هو الأوفر بين أقرب المتاجر';

  @override
  String get compareKeepCart => 'متابعة بسلتي الحالية';

  @override
  String compareSave(String price) {
    return 'وفّر $price';
  }

  @override
  String get accountTitle => 'حسابي';

  @override
  String get accountOrders => 'طلب';

  @override
  String get accountAddresses => 'عناوين';

  @override
  String get accountNoName => 'بدون اسم';

  @override
  String get accountMyAddresses => 'عناويني';

  @override
  String get accountNotifications => 'الإشعارات';

  @override
  String get accountLanguage => 'اللغة';

  @override
  String get accountLanguageName => 'العربية';

  @override
  String get accountHelp => 'المساعدة والدعم';

  @override
  String get accountLogout => 'تسجيل الخروج';

  @override
  String get accountLogoutBody => 'بنمسح سلتك وعمليات البحث من هذا الجهاز.';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileName => 'الاسم';

  @override
  String get profilePhone => 'رقم الجوال';

  @override
  String get profilePhoneHelper => 'لتغيير الرقم تواصل مع الدعم';

  @override
  String get profileLanguage => 'لغة التطبيق';

  @override
  String get profileAddressesBody => 'المنطقة بتتحدد من موقع العنوان';

  @override
  String get profileSave => 'حفظ التغييرات';

  @override
  String get profileDelete => 'حذف الحساب';

  @override
  String get deleteTitle => 'حذف الحساب نهائيًا؟';

  @override
  String get deleteBody => 'لا يمكن التراجع عن هذه الخطوة.';

  @override
  String get deleteNameAddresses => 'سيُحذف اسمك وعناوينك المحفوظة';

  @override
  String get deleteOrders => 'لن تتمكن من رؤية طلباتك السابقة';

  @override
  String get deleteActive => 'الطلبات الجارية يجب أن تنتهي أولًا';

  @override
  String get deleteUnderstand => 'أفهم أن حذف الحساب نهائي';

  @override
  String get deleteConfirm => 'حذف الحساب';

  @override
  String get addressesTitle => 'عناويني';

  @override
  String get addressesDefault => 'الافتراضي';

  @override
  String get addressesAdd => 'إضافة عنوان جديد';

  @override
  String get addressesEmpty => 'ما عندك عناوين محفوظة';

  @override
  String get addressesEmptyBody =>
      'أضف عنوانك عشان نعرض لك المتاجر اللي بتوصّلك.';

  @override
  String get addressDeleteTitle => 'حذف هذا العنوان؟';

  @override
  String get addressDeleteBody => 'الطلبات السابقة تحتفظ بنسخة منه.';

  @override
  String get addressDeleteConfirm => 'حذف العنوان';

  @override
  String get addressUnnamed => 'عنوان';

  @override
  String get addressPickerTitle => 'اختر عنوان التوصيل';

  @override
  String get addressFormTitle => 'تفاصيل العنوان';

  @override
  String get addressMapHint => 'حرّك الخريطة لتحديد الموقع';

  @override
  String get addressHome => 'البيت';

  @override
  String get addressWork => 'العمل';

  @override
  String get addressOther => 'أخرى';

  @override
  String get addressOtherHint => 'اسم العنوان (مثل: بيت أهلي)';

  @override
  String get addressDetailsHint => 'الشارع، أقرب معلم، العمارة، الطابق';

  @override
  String get addressZoneUnknown => 'نتحقق من المنطقة عند الحفظ';

  @override
  String get addressZoneLabel => 'موقع العنوان';

  @override
  String get addressInZone => 'داخل الخدمة';

  @override
  String get addressOutOfZone => 'خارج الخدمة';

  @override
  String get addressMakeDefault => 'اجعله العنوان الافتراضي';

  @override
  String get addressSave => 'حفظ العنوان';

  @override
  String get addressLocateFailed => 'تعذّر تحديد موقعك. حرّك الخريطة يدويًا.';

  @override
  String get addressMapCredit => '© OpenStreetMap';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get checkoutNoAddressBody =>
      'أضف عنوانك عشان نحسب سعر الطلب والتوصيل.';

  @override
  String get checkoutCash => 'نقدًا عند الاستلام';

  @override
  String get checkoutSubstitutions => 'إذا نفد صنف';

  @override
  String get subCallMe => 'اتصلوا بي';

  @override
  String get subSimilar => 'بديل مشابه';

  @override
  String get subSkip => 'احذفوه';

  @override
  String get checkoutCouponHint => 'كود الخصم';

  @override
  String get checkoutCouponApply => 'تطبيق';

  @override
  String get checkoutCouponApplied => 'تم تطبيقه';

  @override
  String get checkoutNoteHint => 'ملاحظة للمتجر أو السائق';

  @override
  String get checkoutTotal => 'الإجمالي';

  @override
  String get checkoutChange => 'تغيير';

  @override
  String get checkoutPriceHeld => 'السعر محجوز لك لمدة';

  @override
  String get quoteExpiredTitle => 'انتهت صلاحية السعر';

  @override
  String get quoteExpiredChanged =>
      'طلبنا تسعيرة جديدة، وهاي الأسعار اللي تغيّرت:';

  @override
  String get quoteExpiredSame => 'طلبنا تسعيرة جديدة، والأسعار ما تغيّرت.';

  @override
  String get quoteExpiredNewTotal => 'الإجمالي الجديد';

  @override
  String get quoteExpiredContinue => 'متابعة بالسعر الجديد';

  @override
  String get quoteExpiredReview => 'مراجعة السلة';

  @override
  String get offerTitle => 'عرض السعر';

  @override
  String get offerNotReadyTitle => 'المتجر لسا ما سعّر طلبك';

  @override
  String get offerNotReadyBody => 'رح يوصلك العرض هون فور تجهيزه.';

  @override
  String get offerPricedTitle => 'تم تسعير طلبك';

  @override
  String get offerPricedBody => 'المنتجات بالوزن تُسعّر بعد التجهيز';

  @override
  String get offerUnavailable => 'غير متوفر';

  @override
  String get offerItemsTotal => 'المنتجات';

  @override
  String get offerDelivery => 'التوصيل';

  @override
  String get offerActionRefused =>
      'ما قدرنا ننفّذ هاد الطلب. جرّب مرة ثانية أو تواصل مع الدعم.';

  @override
  String get offerApprove => 'الموافقة على العرض';

  @override
  String get offerExpiredPill => 'انتهت المهلة';

  @override
  String get offerExpiredTitle => 'انتهت صلاحية العرض';

  @override
  String get offerExpiredBodyPlain =>
      'لم تتم الموافقة على عرض السعر، فأُلغي الطلب تلقائيًا. لم يُخصم أي مبلغ.';

  @override
  String get offerExpiredReorder => 'اطلب نفس السلة من جديد';

  @override
  String get offerExpiredHome => 'العودة للرئيسية';

  @override
  String get reorderReplaceTitle => 'في سلة حاليًا';

  @override
  String get reorderReplaceBody => 'إعادة الطلب رح تستبدل سلتك الحالية.';

  @override
  String get reorderReplaceConfirm => 'استبدال السلة';

  @override
  String get orderSandboxAdvance => 'تجربة: خطوة المتجر التالية';

  @override
  String checkoutConfirm(String total) {
    return 'تأكيد الطلب · $total';
  }

  @override
  String checkoutDistance(String km) {
    return '$km كم';
  }

  @override
  String quoteExpiredPassed(int minutes) {
    return 'مرّت $minutes دقيقة على التسعيرة';
  }

  @override
  String lineWithQty(String name, int qty) {
    return '$name × $qty';
  }

  @override
  String offerUnitPrice(String price) {
    return '$price للوحدة';
  }

  @override
  String offerSubstitute(String name, String price) {
    return 'البديل: $name · $price للوحدة';
  }

  @override
  String offerStoreNote(String note) {
    return 'ملاحظة المتجر: $note';
  }

  @override
  String offerDeadline(int minutes) {
    return 'إذا لم توافق خلال $minutes دقيقة، يُلغى الطلب تلقائيًا.';
  }

  @override
  String offerExpiredBody(int minutes) {
    return 'لم تتم الموافقة على عرض السعر خلال $minutes دقيقة، فأُلغي الطلب تلقائيًا. لم يُخصم أي مبلغ.';
  }

  @override
  String offerExpiredSummary(int count, String total) {
    return '$count منتج · كان الإجمالي $total';
  }

  @override
  String orderTitle(String code) {
    return 'طلب $code';
  }

  @override
  String reorderMissing(int count) {
    return '$count من الأصناف ما عادت متوفرة بالمتجر.';
  }

  @override
  String orderWaitingBody(String store) {
    return 'أرسلنا طلبك لـ $store، ورح نخبرك بكل جديد.';
  }

  @override
  String get orderWaitingBodyPlain => 'وصل طلبك، ورح نخبرك بكل جديد.';

  @override
  String get orderCancelledBody => 'تم إلغاء هذا الطلب. لم يُخصم أي مبلغ.';

  @override
  String get orderNow => 'الآن';

  @override
  String get orderPhotoNote =>
      'عند التسليم، السائق بيصوّر الطلب على بابك كإثبات استلام.';

  @override
  String get trackingPhotoNote => 'السائق بيصوّر الطلب عند بابك كإثبات تسليم';

  @override
  String trackingEta(int minutes) {
    return 'يصل خلال $minutes دقيقة';
  }

  @override
  String get trackingNoDriver => 'رح يظهر السائق هون فور ما يقبل الطلب.';

  @override
  String get trackingShare => 'مشاركة رابط التتبع';

  @override
  String get trackingCancel => 'إلغاء الطلب';

  @override
  String get shareLinkBody =>
      'أي شخص معه الرابط بيقدر يتابع حالة الطلب بدون تسجيل دخول.';

  @override
  String get shareLinkSend => 'مشاركة الرابط';

  @override
  String get shareLinkStop => 'إيقاف الرابط';

  @override
  String get mapCredit => '© OpenStreetMap';

  @override
  String get vehicleMotorcycle => 'دراجة نارية';

  @override
  String get vehicleCar => 'سيارة';

  @override
  String get vehicleBicycle => 'دراجة هوائية';

  @override
  String get vehicleVan => 'فان';

  @override
  String get vehicleTukTuk => 'توك توك';

  @override
  String get vehicleOnFoot => 'مشيًا';

  @override
  String get cancelTitle => 'إلغاء الطلب؟';

  @override
  String get cancelBody => 'ممكن تلغي قبل ما يستلم السائق الطلب';

  @override
  String get cancelWhy => 'ليش بدك تلغي؟';

  @override
  String get cancelConfirm => 'تأكيد الإلغاء';

  @override
  String get cancelBack => 'تراجع';

  @override
  String get rateDeliveredTitle => 'وصل طلبك، بالهنا والشفا!';

  @override
  String rateDeliveredAt(String time) {
    return 'تم التوصيل $time';
  }

  @override
  String ratePaid(String total) {
    return 'دفعت $total';
  }

  @override
  String rateSaved(String amount) {
    return 'وفّرت $amount';
  }

  @override
  String get rateTitle => 'قيّم تجربتك';

  @override
  String get rateDriver => 'السائق';

  @override
  String get rateStore => 'المتجر';

  @override
  String get rateComment => 'اكتب تعليقك (اختياري)';

  @override
  String get rateSend => 'إرسال التقييم';

  @override
  String get rateSkip => 'تخطّي';

  @override
  String get ordersTabCurrent => 'الحالية';

  @override
  String ordersTabCurrentCount(int count) {
    return 'الحالية ($count)';
  }

  @override
  String get ordersTabPast => 'السابقة';

  @override
  String get ordersEmptyCurrent => 'ما عندك طلبات حالية';

  @override
  String get ordersEmptyPast => 'ما عندك طلبات سابقة';

  @override
  String ordersItems(int count, String total) {
    return '$count منتجات · $total';
  }

  @override
  String get ordersFollow => 'متابعة الطلب';

  @override
  String get ordersReorder => 'إعادة الطلب';

  @override
  String get receiptTitle => 'الفاتورة';

  @override
  String get receiptPaidCash => 'مدفوع نقدًا';

  @override
  String get receiptCashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get receiptTotal => 'الإجمالي';

  @override
  String get receiptReorder => 'إعادة نفس الطلب';

  @override
  String receiptShareText(String code, String total) {
    return 'فاتورة طلب $code: $total';
  }

  @override
  String get notificationsReadAll => 'قراءة الكل';

  @override
  String get notificationsEmpty => 'ما في إشعارات';

  @override
  String get notificationsToday => 'اليوم';

  @override
  String get notificationsYesterday => 'أمس';

  @override
  String get notificationsEarlier => 'أقدم';

  @override
  String get timeNow => 'الآن';

  @override
  String timeMinutes(int count) {
    return 'منذ $count د';
  }

  @override
  String timeHours(int count) {
    return 'منذ $count س';
  }

  @override
  String timeDays(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get homeAssistantTitle => 'اطلب بسرعة مع مساعد برق';

  @override
  String get homeAssistantBody => 'اكتب قائمتك وبنلاقيلك أوفر متجر';

  @override
  String get assistantTitle => 'مساعد برق';

  @override
  String get assistantGreeting =>
      'أهلًا! أنا مساعد برق. اكتبلي قائمتك، وبلاقيلك أوفر متجر بيوصّل لعنوانك.';

  @override
  String get assistantHint =>
      'اكتب كل صنف مع كميته، مثلًا: كيلو بندورة وكيلو بطاطا ولتر حليب';

  @override
  String get assistantInputHint => 'اكتب قائمتك هون…';

  @override
  String get assistantChipVegetables => 'خضار وفواكه';

  @override
  String get assistantChipBreakfast => 'طلبات الفطور';

  @override
  String get assistantChipReorder => 'أعد آخر طلب';

  @override
  String get assistantChipWrite => 'اكتب قائمتك';

  @override
  String get assistantListVegetables =>
      'كيلو بندورة وكيلو خيار وكيلو بطاطا وكيلو موز';

  @override
  String get assistantListBreakfast => 'ربطة خبز وطبق بيض ولتر حليب وعلبة لبنة';

  @override
  String get assistantFound => 'هاد اللي لقيته:';

  @override
  String get assistantNothingFound => 'ما لقيت ولا صنف من قائمتك:';

  @override
  String assistantLine(String name, int qty) {
    return '$name × $qty';
  }

  @override
  String assistantNotFound(String name) {
    return 'مش لاقي $name';
  }

  @override
  String assistantNotFoundPick(String name) {
    return 'مش لاقي $name. يمكن بدك:';
  }

  @override
  String assistantSoldByKilo(String name, int qty) {
    String _temp0 = intl.Intl.pluralLogic(
      qty,
      locale: localeName,
      other: '$qty كيلو',
      two: 'كيلوين',
      one: 'كيلو',
    );
    return '$name بتنباع بالكيلو، حطيتلك $_temp0';
  }

  @override
  String assistantSoldByLiter(String name, int qty) {
    String _temp0 = intl.Intl.pluralLogic(
      qty,
      locale: localeName,
      other: '$qty لتر',
      two: 'لترين',
      one: 'لتر',
    );
    return '$name بتنباع باللتر، حطيتلك $_temp0';
  }

  @override
  String assistantRounded(String name, int qty) {
    return 'قرّبت كمية $name لـ $qty، لأن الطلب بالأعداد الكاملة بس.';
  }

  @override
  String assistantCapped(String name, int qty) {
    return 'كمية $name صارت $qty، وهاد أعلى حد مسموح.';
  }

  @override
  String assistantTooMany(int count) {
    return 'تركت آخر $count من القائمة، لأن السلة وصلت للحد المسموح.';
  }

  @override
  String get assistantCompare => 'تمام، قارن المتاجر';

  @override
  String get assistantNotUnderstood =>
      'ما فهمت القائمة. اكتبها زي: كيلو بندورة وكيلو بطاطا';

  @override
  String assistantBest(String store) {
    return 'أوفر متجر لقائمتك: $store';
  }

  @override
  String get assistantNoFullStore =>
      'ما في متجر عنده كل القائمة. هدول أقرب المتاجر إلها، وبنكمّل بالمتوفر:';

  @override
  String assistantContinue(String total) {
    return 'أكمل الطلب · $total';
  }

  @override
  String get assistantNoStores =>
      'ما في متجر بيوصّلك عنده أصناف من هاي القائمة.';

  @override
  String get assistantNoLastOrder =>
      'لسا ما عندك طلبات سابقة. اكتبلي قائمتك وبنبدأ.';

  @override
  String get assistantReplaceTitle => 'استبدال السلة؟';

  @override
  String get assistantReplaceBody =>
      'سلتك الحالية بتنحذف، وبتصير فيها أصناف هاي القائمة.';

  @override
  String get assistantReplaceConfirm => 'استبدال السلة';

  @override
  String get activeOrderOffer => 'وصلك عرض السعر';

  @override
  String get activeOrderTracking => 'تابع طلبك على الخريطة';

  @override
  String get activeOrderWaiting => 'رح نخبرك بكل جديد';
}
