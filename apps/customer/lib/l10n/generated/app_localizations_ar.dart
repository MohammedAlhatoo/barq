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
  String get compareCurrentIsBest => 'متجرك الحالي هو الأوفر';

  @override
  String get compareKeepCart => 'متابعة بسلتي الحالية';

  @override
  String compareSave(String price) {
    return 'وفّر $price';
  }
}
