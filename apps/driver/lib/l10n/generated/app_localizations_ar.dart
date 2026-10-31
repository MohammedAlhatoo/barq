// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'برق كابتن';

  @override
  String get splashTagline => 'جاهز لطلبات اليوم؟';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get offlineTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get offlineBody =>
      'تأكد من الاتصال وأعد المحاولة. مهمتك الحالية محفوظة ولم تتأثر.';

  @override
  String get updateTitle => 'نسخة جديدة من برق كابتن';

  @override
  String get updateBody =>
      'حدّث التطبيق لتكمل العمل. النسخة الجديدة أسرع وفيها إصلاحات مهمة.';

  @override
  String updateVersion(Object version) {
    return 'نسخة $version';
  }

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get maintenanceTitle => 'برق تحت الصيانة';

  @override
  String get maintenanceBody =>
      'نحسّن الخدمة وراجعين قريبًا. مهامك الحالية محفوظة.';

  @override
  String get maintenanceRefresh => 'تحديث الصفحة';

  @override
  String get maintenanceContact => 'للاستفسار: ';

  @override
  String get sessionTitle => 'سجّل الدخول من جديد';

  @override
  String get sessionBody => 'انتهت جلستك لحماية حسابك. أدخل رقمك وكلمة المرور.';

  @override
  String get sessionLogin => 'تسجيل الدخول';

  @override
  String get navJobs => 'الطلبات';

  @override
  String get navEarnings => 'الأرباح';

  @override
  String get navHistory => 'السجل';

  @override
  String get navAccount => 'حسابي';

  @override
  String get loginCaptain => 'كابتن';

  @override
  String get loginTitle => 'سجّل دخولك كسائق';

  @override
  String get loginBody =>
      'استخدم رقم الجوال وكلمة المرور اللي أعطاك إياهم فريق برق.';

  @override
  String get loginPhoneLabel => 'رقم الجوال';

  @override
  String get loginPhoneHint => '059 000 0000';

  @override
  String get loginCountryCode => '+970';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginShowPassword => 'إظهار';

  @override
  String get loginHidePassword => 'إخفاء';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginFootnote => 'حسابات السائقين يفعّلها فريق برق فقط';

  @override
  String get locationServiceTitle => 'برق كابتن';

  @override
  String get locationServiceBody => 'موقعك يُرسل طالما أنت متصل';

  @override
  String get locationDenied =>
      'اسمح للتطبيق باستخدام موقعك من الإعدادات لتصبح متصلًا.';

  @override
  String get locationServiceOff => 'شغّل خدمة الموقع في الهاتف لتصبح متصلًا.';

  @override
  String get locationUnavailable =>
      'تعذر تحديد موقعك. اخرج لمكان مفتوح وحاول مرة أخرى.';

  @override
  String get statusOnline => 'متصل';

  @override
  String get statusOffline => 'غير متصل';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get jobsTodayEarnings => 'أرباح اليوم';

  @override
  String get jobsOrdersStat => 'طلبات';

  @override
  String get jobsRatingStat => 'تقييم';

  @override
  String jobsNearby(int count) {
    return 'طلبات قريبة ($count)';
  }

  @override
  String get jobsAutoRefresh => 'تحديث تلقائي';

  @override
  String get jobsEmptyTitle => 'لا توجد طلبات قريبة الآن';

  @override
  String get jobsEmptyBody => 'ابقَ متصلًا، والطلبات الجديدة بتظهر هون.';

  @override
  String get jobsTaken => 'سبقك سائق آخر لهذا الطلب';

  @override
  String jobTo(Object place) {
    return 'إلى $place';
  }

  @override
  String distanceKm(Object distance) {
    return '$distance كم';
  }

  @override
  String jobItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      many: '$count منتج',
      few: '$count منتجات',
      two: 'منتجان',
      one: 'منتج واحد',
    );
    return '$_temp0';
  }

  @override
  String get jobYourFare => 'أجرتك';

  @override
  String jobCollect(Object amount) {
    return 'تحصيل $amount';
  }

  @override
  String get jobAccept => 'قبول';

  @override
  String get offlineJobsTitle => 'أنت غير متصل';

  @override
  String get offlineJobsBody => 'اضغط الزر لتبدأ باستقبال طلبات منطقتك.';

  @override
  String get offerTitle => 'طلب جديد!';

  @override
  String get offerPickup => 'الاستلام';

  @override
  String offerPickupDistance(Object distance) {
    return 'الاستلام · $distance كم منك';
  }

  @override
  String get offerDropoff => 'التسليم';

  @override
  String offerDropoffDistance(Object distance) {
    return 'التسليم · $distance كم';
  }

  @override
  String get offerCollect => 'تحصيل من الزبون';

  @override
  String offerCash(Object amount) {
    return '$amount نقدًا';
  }

  @override
  String get offerAccept => 'قبول الطلب';

  @override
  String get offerIgnore => 'تجاهل';

  @override
  String get cashLimitTitle => 'وصلت للحد الأعلى للنقد';

  @override
  String cashLimitBody(Object amount) {
    return 'معك $amount نقدًا. سدّدها في مكتب برق لتستقبل طلبات جديدة.';
  }

  @override
  String get cashLimitCollected => 'النقد المحصّل';

  @override
  String cashLimitMax(Object amount) {
    return 'الحد الأعلى $amount';
  }

  @override
  String get cashLimitSupport => 'تواصل مع الدعم';

  @override
  String taskHeading(Object status, Object target) {
    return '$status · $target';
  }

  @override
  String get taskToStore => 'توجّه للمتجر';

  @override
  String get taskToCustomer => 'توجّه للزبون';

  @override
  String get taskNavigate => 'الملاحة';

  @override
  String get taskCall => 'اتصال';

  @override
  String taskItem(Object name, int qty) {
    return '$name × $qty';
  }

  @override
  String taskMoreItems(int count) {
    return '+ $count منتج آخر';
  }

  @override
  String get taskPhotoHint => 'هاي الخطوة بتطلب صورة';

  @override
  String get taskNoStep => 'بانتظار تحديث الطلب من السيرفر.';

  @override
  String get taskEmptyTitle => 'ما عندك مهمة حالية';

  @override
  String get taskEmptyBody => 'اقبل طلبًا من القائمة لتبدأ.';

  @override
  String get photoTitle => 'صوّر الطلب';

  @override
  String get photoBody =>
      'صورة واضحة للأكياس قبل الاستلام، مطلوبة لتأكيد الخطوة.';

  @override
  String get photoShutter => 'التقاط';

  @override
  String get photoRetake => 'اضغط الزر لإعادة التصوير';

  @override
  String get photoCameraFailed =>
      'تعذر فتح الكاميرا. اسمح للتطبيق باستخدامها من الإعدادات.';

  @override
  String get tooFarStore => 'أنت بعيد عن المتجر';

  @override
  String get tooFarCustomer => 'أنت بعيد عن الزبون';

  @override
  String tooFarDistance(int meters) {
    return 'على بعد $meters م من الموقع';
  }

  @override
  String tooFarBody(Object label, int meters, Object place) {
    return 'زر «$label» بيشتغل بس لما تكون ضمن $meters متر من $place.';
  }

  @override
  String get tooFarNavigate => 'افتح الملاحة';

  @override
  String get tooFarRetry => 'حاول مرة أخرى';

  @override
  String deliverTitle(Object status) {
    return '$status · سلّم الطلب';
  }

  @override
  String get deliverHelp => 'مساعدة';

  @override
  String get deliverCollect => 'حصّل من الزبون نقدًا';

  @override
  String get deliverIncludesFee => 'شامل التوصيل';

  @override
  String get deliverPhotoTitle => 'صوّر الطلب عند الباب';

  @override
  String get deliverPhotoTaken => 'تم التقاط الصورة';

  @override
  String get deliverPhotoProof => 'الصورة إثبات التسليم للزبون';

  @override
  String get deliverTakePhoto => 'التقاط الصورة';

  @override
  String get deliverRetake => 'إعادة التصوير';

  @override
  String get periodDay => 'اليوم';

  @override
  String get periodWeek => 'الأسبوع';

  @override
  String get periodMonth => 'الشهر';

  @override
  String get earningsOfDay => 'أرباح اليوم';

  @override
  String get earningsOfWeek => 'أرباح الأسبوع';

  @override
  String get earningsOfMonth => 'أرباح الشهر';

  @override
  String earningsOrders(int count) {
    return '$count طلب';
  }

  @override
  String get cashOnHand => 'النقد اللي معك';

  @override
  String cashRemaining(Object amount) {
    return 'باقي لك $amount قبل الحد';
  }

  @override
  String cashUnsettled(int count) {
    return '$count طلبات لسا ما تسوّت';
  }

  @override
  String get historyTitle => 'سجل المهام';

  @override
  String get historyAll => 'الكل';

  @override
  String get historyDelivered => 'تم التسليم';

  @override
  String get historyCancelled => 'ملغاة';

  @override
  String historyToday(int count, Object amount) {
    return 'اليوم · $count مهام · $amount';
  }

  @override
  String historyCash(Object amount) {
    return 'نقد $amount';
  }

  @override
  String get historyEmptyTitle => 'ما في مهام هون';

  @override
  String get historyEmptyBody => 'مهامك المنتهية بتظهر هون.';

  @override
  String accountRating(Object rating, int count) {
    return '$rating ($count)';
  }

  @override
  String get accountNotifications => 'الإشعارات';

  @override
  String get accountSupport => 'الدعم';

  @override
  String get accountLogout => 'تسجيل الخروج';

  @override
  String get settingsVehicle => 'نوع المركبة';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsSave => 'حفظ';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

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
  String get notificationsReadAll => 'قراءة الكل';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notificationsEmptyBody => 'الطلبات الجديدة والتحديثات بتظهر هون.';
}
