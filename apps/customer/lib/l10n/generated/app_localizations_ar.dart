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
}
