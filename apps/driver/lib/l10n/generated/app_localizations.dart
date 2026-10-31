import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'برق كابتن'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In ar, this message translates to:
  /// **'جاهز لطلبات اليوم؟'**
  String get splashTagline;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @offlineTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من الاتصال وأعد المحاولة. مهمتك الحالية محفوظة ولم تتأثر.'**
  String get offlineBody;

  /// No description provided for @updateTitle.
  ///
  /// In ar, this message translates to:
  /// **'نسخة جديدة من برق كابتن'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In ar, this message translates to:
  /// **'حدّث التطبيق لتكمل العمل. النسخة الجديدة أسرع وفيها إصلاحات مهمة.'**
  String get updateBody;

  /// No description provided for @updateVersion.
  ///
  /// In ar, this message translates to:
  /// **'نسخة {version}'**
  String updateVersion(Object version);

  /// No description provided for @updateNow.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الآن'**
  String get updateNow;

  /// No description provided for @maintenanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'برق تحت الصيانة'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceBody.
  ///
  /// In ar, this message translates to:
  /// **'نحسّن الخدمة وراجعين قريبًا. مهامك الحالية محفوظة.'**
  String get maintenanceBody;

  /// No description provided for @maintenanceRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الصفحة'**
  String get maintenanceRefresh;

  /// No description provided for @maintenanceContact.
  ///
  /// In ar, this message translates to:
  /// **'للاستفسار: '**
  String get maintenanceContact;

  /// No description provided for @sessionTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول من جديد'**
  String get sessionTitle;

  /// No description provided for @sessionBody.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك لحماية حسابك. أدخل رقمك وكلمة المرور.'**
  String get sessionBody;

  /// No description provided for @sessionLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get sessionLogin;

  /// No description provided for @navJobs.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get navJobs;

  /// No description provided for @navEarnings.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get navEarnings;

  /// No description provided for @navHistory.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get navHistory;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @loginCaptain.
  ///
  /// In ar, this message translates to:
  /// **'كابتن'**
  String get loginCaptain;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك كسائق'**
  String get loginTitle;

  /// No description provided for @loginBody.
  ///
  /// In ar, this message translates to:
  /// **'استخدم رقم الجوال وكلمة المرور اللي أعطاك إياهم فريق برق.'**
  String get loginBody;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'059 000 0000'**
  String get loginPhoneHint;

  /// No description provided for @loginCountryCode.
  ///
  /// In ar, this message translates to:
  /// **'+970'**
  String get loginCountryCode;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPasswordLabel;

  /// No description provided for @loginShowPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get loginHidePassword;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginButton;

  /// No description provided for @loginFootnote.
  ///
  /// In ar, this message translates to:
  /// **'حسابات السائقين يفعّلها فريق برق فقط'**
  String get loginFootnote;

  /// No description provided for @locationServiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'برق كابتن'**
  String get locationServiceTitle;

  /// No description provided for @locationServiceBody.
  ///
  /// In ar, this message translates to:
  /// **'موقعك يُرسل طالما أنت متصل'**
  String get locationServiceBody;

  /// No description provided for @locationDenied.
  ///
  /// In ar, this message translates to:
  /// **'اسمح للتطبيق باستخدام موقعك من الإعدادات لتصبح متصلًا.'**
  String get locationDenied;

  /// No description provided for @locationServiceOff.
  ///
  /// In ar, this message translates to:
  /// **'شغّل خدمة الموقع في الهاتف لتصبح متصلًا.'**
  String get locationServiceOff;

  /// No description provided for @locationUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديد موقعك. اخرج لمكان مفتوح وحاول مرة أخرى.'**
  String get locationUnavailable;

  /// No description provided for @statusOnline.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get statusOffline;

  /// No description provided for @greetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get greetingMorning;

  /// No description provided for @greetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get greetingEvening;

  /// No description provided for @jobsTodayEarnings.
  ///
  /// In ar, this message translates to:
  /// **'أرباح اليوم'**
  String get jobsTodayEarnings;

  /// No description provided for @jobsOrdersStat.
  ///
  /// In ar, this message translates to:
  /// **'طلبات'**
  String get jobsOrdersStat;

  /// No description provided for @jobsRatingStat.
  ///
  /// In ar, this message translates to:
  /// **'تقييم'**
  String get jobsRatingStat;

  /// No description provided for @jobsNearby.
  ///
  /// In ar, this message translates to:
  /// **'طلبات قريبة ({count})'**
  String jobsNearby(int count);

  /// No description provided for @jobsAutoRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث تلقائي'**
  String get jobsAutoRefresh;

  /// No description provided for @jobsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات قريبة الآن'**
  String get jobsEmptyTitle;

  /// No description provided for @jobsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'ابقَ متصلًا، والطلبات الجديدة بتظهر هون.'**
  String get jobsEmptyBody;

  /// No description provided for @jobsTaken.
  ///
  /// In ar, this message translates to:
  /// **'سبقك سائق آخر لهذا الطلب'**
  String get jobsTaken;

  /// No description provided for @jobTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى {place}'**
  String jobTo(Object place);

  /// No description provided for @distanceKm.
  ///
  /// In ar, this message translates to:
  /// **'{distance} كم'**
  String distanceKm(Object distance);

  /// No description provided for @jobItems.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منتج واحد} =2{منتجان} few{{count} منتجات} many{{count} منتج} other{{count} منتج}}'**
  String jobItems(int count);

  /// No description provided for @jobYourFare.
  ///
  /// In ar, this message translates to:
  /// **'أجرتك'**
  String get jobYourFare;

  /// No description provided for @jobCollect.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل {amount}'**
  String jobCollect(Object amount);

  /// No description provided for @jobAccept.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get jobAccept;

  /// No description provided for @offlineJobsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل'**
  String get offlineJobsTitle;

  /// No description provided for @offlineJobsBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط الزر لتبدأ باستقبال طلبات منطقتك.'**
  String get offlineJobsBody;

  /// No description provided for @offerTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب جديد!'**
  String get offerTitle;

  /// No description provided for @offerPickup.
  ///
  /// In ar, this message translates to:
  /// **'الاستلام'**
  String get offerPickup;

  /// No description provided for @offerPickupDistance.
  ///
  /// In ar, this message translates to:
  /// **'الاستلام · {distance} كم منك'**
  String offerPickupDistance(Object distance);

  /// No description provided for @offerDropoff.
  ///
  /// In ar, this message translates to:
  /// **'التسليم'**
  String get offerDropoff;

  /// No description provided for @offerDropoffDistance.
  ///
  /// In ar, this message translates to:
  /// **'التسليم · {distance} كم'**
  String offerDropoffDistance(Object distance);

  /// No description provided for @offerCollect.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل من الزبون'**
  String get offerCollect;

  /// No description provided for @offerCash.
  ///
  /// In ar, this message translates to:
  /// **'{amount} نقدًا'**
  String offerCash(Object amount);

  /// No description provided for @offerAccept.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get offerAccept;

  /// No description provided for @offerIgnore.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get offerIgnore;

  /// No description provided for @cashLimitTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصلت للحد الأعلى للنقد'**
  String get cashLimitTitle;

  /// No description provided for @cashLimitBody.
  ///
  /// In ar, this message translates to:
  /// **'معك {amount} نقدًا. سدّدها في مكتب برق لتستقبل طلبات جديدة.'**
  String cashLimitBody(Object amount);

  /// No description provided for @cashLimitCollected.
  ///
  /// In ar, this message translates to:
  /// **'النقد المحصّل'**
  String get cashLimitCollected;

  /// No description provided for @cashLimitMax.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأعلى {amount}'**
  String cashLimitMax(Object amount);

  /// No description provided for @cashLimitSupport.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get cashLimitSupport;

  /// No description provided for @taskHeading.
  ///
  /// In ar, this message translates to:
  /// **'{status} · {target}'**
  String taskHeading(Object status, Object target);

  /// No description provided for @taskToStore.
  ///
  /// In ar, this message translates to:
  /// **'توجّه للمتجر'**
  String get taskToStore;

  /// No description provided for @taskToCustomer.
  ///
  /// In ar, this message translates to:
  /// **'توجّه للزبون'**
  String get taskToCustomer;

  /// No description provided for @taskNavigate.
  ///
  /// In ar, this message translates to:
  /// **'الملاحة'**
  String get taskNavigate;

  /// No description provided for @taskCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get taskCall;

  /// No description provided for @taskItem.
  ///
  /// In ar, this message translates to:
  /// **'{name} × {qty}'**
  String taskItem(Object name, int qty);

  /// No description provided for @taskMoreItems.
  ///
  /// In ar, this message translates to:
  /// **'+ {count} منتج آخر'**
  String taskMoreItems(int count);

  /// No description provided for @taskPhotoHint.
  ///
  /// In ar, this message translates to:
  /// **'هاي الخطوة بتطلب صورة'**
  String get taskPhotoHint;

  /// No description provided for @taskNoStep.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار تحديث الطلب من السيرفر.'**
  String get taskNoStep;

  /// No description provided for @taskEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك مهمة حالية'**
  String get taskEmptyTitle;

  /// No description provided for @taskEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'اقبل طلبًا من القائمة لتبدأ.'**
  String get taskEmptyBody;

  /// No description provided for @photoTitle.
  ///
  /// In ar, this message translates to:
  /// **'صوّر الطلب'**
  String get photoTitle;

  /// No description provided for @photoBody.
  ///
  /// In ar, this message translates to:
  /// **'صورة واضحة للأكياس قبل الاستلام، مطلوبة لتأكيد الخطوة.'**
  String get photoBody;

  /// No description provided for @photoShutter.
  ///
  /// In ar, this message translates to:
  /// **'التقاط'**
  String get photoShutter;

  /// No description provided for @photoRetake.
  ///
  /// In ar, this message translates to:
  /// **'اضغط الزر لإعادة التصوير'**
  String get photoRetake;

  /// No description provided for @photoCameraFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الكاميرا. اسمح للتطبيق باستخدامها من الإعدادات.'**
  String get photoCameraFailed;

  /// No description provided for @tooFarStore.
  ///
  /// In ar, this message translates to:
  /// **'أنت بعيد عن المتجر'**
  String get tooFarStore;

  /// No description provided for @tooFarCustomer.
  ///
  /// In ar, this message translates to:
  /// **'أنت بعيد عن الزبون'**
  String get tooFarCustomer;

  /// No description provided for @tooFarDistance.
  ///
  /// In ar, this message translates to:
  /// **'على بعد {meters} م من الموقع'**
  String tooFarDistance(int meters);

  /// No description provided for @tooFarBody.
  ///
  /// In ar, this message translates to:
  /// **'زر «{label}» بيشتغل بس لما تكون ضمن {meters} متر من {place}.'**
  String tooFarBody(Object label, int meters, Object place);

  /// No description provided for @tooFarNavigate.
  ///
  /// In ar, this message translates to:
  /// **'افتح الملاحة'**
  String get tooFarNavigate;

  /// No description provided for @tooFarRetry.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tooFarRetry;

  /// No description provided for @deliverTitle.
  ///
  /// In ar, this message translates to:
  /// **'{status} · سلّم الطلب'**
  String deliverTitle(Object status);

  /// No description provided for @deliverHelp.
  ///
  /// In ar, this message translates to:
  /// **'مساعدة'**
  String get deliverHelp;

  /// No description provided for @deliverCollect.
  ///
  /// In ar, this message translates to:
  /// **'حصّل من الزبون نقدًا'**
  String get deliverCollect;

  /// No description provided for @deliverIncludesFee.
  ///
  /// In ar, this message translates to:
  /// **'شامل التوصيل'**
  String get deliverIncludesFee;

  /// No description provided for @deliverPhotoTitle.
  ///
  /// In ar, this message translates to:
  /// **'صوّر الطلب عند الباب'**
  String get deliverPhotoTitle;

  /// No description provided for @deliverPhotoTaken.
  ///
  /// In ar, this message translates to:
  /// **'تم التقاط الصورة'**
  String get deliverPhotoTaken;

  /// No description provided for @deliverPhotoProof.
  ///
  /// In ar, this message translates to:
  /// **'الصورة إثبات التسليم للزبون'**
  String get deliverPhotoProof;

  /// No description provided for @deliverTakePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقاط الصورة'**
  String get deliverTakePhoto;

  /// No description provided for @deliverRetake.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التصوير'**
  String get deliverRetake;

  /// No description provided for @periodDay.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر'**
  String get periodMonth;

  /// No description provided for @earningsOfDay.
  ///
  /// In ar, this message translates to:
  /// **'أرباح اليوم'**
  String get earningsOfDay;

  /// No description provided for @earningsOfWeek.
  ///
  /// In ar, this message translates to:
  /// **'أرباح الأسبوع'**
  String get earningsOfWeek;

  /// No description provided for @earningsOfMonth.
  ///
  /// In ar, this message translates to:
  /// **'أرباح الشهر'**
  String get earningsOfMonth;

  /// No description provided for @earningsOrders.
  ///
  /// In ar, this message translates to:
  /// **'{count} طلب'**
  String earningsOrders(int count);

  /// No description provided for @cashOnHand.
  ///
  /// In ar, this message translates to:
  /// **'النقد اللي معك'**
  String get cashOnHand;

  /// No description provided for @cashRemaining.
  ///
  /// In ar, this message translates to:
  /// **'باقي لك {amount} قبل الحد'**
  String cashRemaining(Object amount);

  /// No description provided for @cashUnsettled.
  ///
  /// In ar, this message translates to:
  /// **'{count} طلبات لسا ما تسوّت'**
  String cashUnsettled(int count);

  /// No description provided for @historyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل المهام'**
  String get historyTitle;

  /// No description provided for @historyAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get historyAll;

  /// No description provided for @historyDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get historyDelivered;

  /// No description provided for @historyCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get historyCancelled;

  /// No description provided for @historyToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم · {count} مهام · {amount}'**
  String historyToday(int count, Object amount);

  /// No description provided for @historyCash.
  ///
  /// In ar, this message translates to:
  /// **'نقد {amount}'**
  String historyCash(Object amount);

  /// No description provided for @historyEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما في مهام هون'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'مهامك المنتهية بتظهر هون.'**
  String get historyEmptyBody;

  /// No description provided for @accountRating.
  ///
  /// In ar, this message translates to:
  /// **'{rating} ({count})'**
  String accountRating(Object rating, int count);

  /// No description provided for @accountNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get accountNotifications;

  /// No description provided for @accountSupport.
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get accountSupport;

  /// No description provided for @accountLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get accountLogout;

  /// No description provided for @settingsVehicle.
  ///
  /// In ar, this message translates to:
  /// **'نوع المركبة'**
  String get settingsVehicle;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get settingsSave;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @vehicleMotorcycle.
  ///
  /// In ar, this message translates to:
  /// **'دراجة نارية'**
  String get vehicleMotorcycle;

  /// No description provided for @vehicleCar.
  ///
  /// In ar, this message translates to:
  /// **'سيارة'**
  String get vehicleCar;

  /// No description provided for @vehicleBicycle.
  ///
  /// In ar, this message translates to:
  /// **'دراجة هوائية'**
  String get vehicleBicycle;

  /// No description provided for @vehicleVan.
  ///
  /// In ar, this message translates to:
  /// **'فان'**
  String get vehicleVan;

  /// No description provided for @vehicleTukTuk.
  ///
  /// In ar, this message translates to:
  /// **'توك توك'**
  String get vehicleTukTuk;

  /// No description provided for @vehicleOnFoot.
  ///
  /// In ar, this message translates to:
  /// **'مشيًا'**
  String get vehicleOnFoot;

  /// No description provided for @notificationsReadAll.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الكل'**
  String get notificationsReadAll;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الجديدة والتحديثات بتظهر هون.'**
  String get notificationsEmptyBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
