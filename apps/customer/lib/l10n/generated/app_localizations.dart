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
  /// **'برق'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get navCategories;

  /// No description provided for @navOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get navOrders;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @navCart.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get navCart;

  /// No description provided for @placeholderSoon.
  ///
  /// In ar, this message translates to:
  /// **'هذه الشاشة قيد البناء'**
  String get placeholderSoon;

  /// No description provided for @splashTagline.
  ///
  /// In ar, this message translates to:
  /// **'احتياجات بيتك بسرعة البرق'**
  String get splashTagline;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @onboardingSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboardingStart;

  /// No description provided for @onboardingShopPill.
  ///
  /// In ar, this message translates to:
  /// **'توصيل خلال 30 د'**
  String get onboardingShopPill;

  /// No description provided for @onboardingShopTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسوّق احتياجاتك اليومية بسهولة'**
  String get onboardingShopTitle;

  /// No description provided for @onboardingShopBody.
  ///
  /// In ar, this message translates to:
  /// **'خضار، لحوم، ألبان ومخبوزات من متاجر منطقتك، في أي وقت ومن أي مكان.'**
  String get onboardingShopBody;

  /// No description provided for @onboardingCompareTitle.
  ///
  /// In ar, this message translates to:
  /// **'قارن الأسعار ووفّر في كل طلب'**
  String get onboardingCompareTitle;

  /// No description provided for @onboardingCompareBody.
  ///
  /// In ar, this message translates to:
  /// **'برق يقارن سلتك بين المتاجر القريبة ويقترح عليك الأرخص تلقائيًا.'**
  String get onboardingCompareBody;

  /// No description provided for @onboardingCompareStoreA.
  ///
  /// In ar, this message translates to:
  /// **'سوبرماركت الأمانة'**
  String get onboardingCompareStoreA;

  /// No description provided for @onboardingCompareStoreB.
  ///
  /// In ar, this message translates to:
  /// **'ميني ماركت النور'**
  String get onboardingCompareStoreB;

  /// No description provided for @onboardingCompareStoreC.
  ///
  /// In ar, this message translates to:
  /// **'بقالة البركة'**
  String get onboardingCompareStoreC;

  /// No description provided for @onboardingCompareItems.
  ///
  /// In ar, this message translates to:
  /// **'8 منتجات'**
  String get onboardingCompareItems;

  /// No description provided for @onboardingCompareBest.
  ///
  /// In ar, this message translates to:
  /// **'الأوفر · وفّر ₪9'**
  String get onboardingCompareBest;

  /// No description provided for @onboardingComparePriceA.
  ///
  /// In ar, this message translates to:
  /// **'₪52'**
  String get onboardingComparePriceA;

  /// No description provided for @onboardingComparePriceB.
  ///
  /// In ar, this message translates to:
  /// **'₪43'**
  String get onboardingComparePriceB;

  /// No description provided for @onboardingComparePriceC.
  ///
  /// In ar, this message translates to:
  /// **'₪49'**
  String get onboardingComparePriceC;

  /// No description provided for @onboardingDeliveryPill.
  ///
  /// In ar, this message translates to:
  /// **'تتبّع مباشر'**
  String get onboardingDeliveryPill;

  /// No description provided for @onboardingDeliveryTitle.
  ///
  /// In ar, this message translates to:
  /// **'من المتجر لباب بيتك بسرعة البرق'**
  String get onboardingDeliveryTitle;

  /// No description provided for @onboardingDeliveryBody.
  ///
  /// In ar, this message translates to:
  /// **'تابع السائق على الخريطة لحظة بلحظة لحد باب بيتك.'**
  String get onboardingDeliveryBody;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم جوالك'**
  String get loginTitle;

  /// No description provided for @loginBody.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل لك رمز تحقق برسالة نصية لتسجيل الدخول أو إنشاء حساب جديد.'**
  String get loginBody;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'059 912 3456'**
  String get loginPhoneHint;

  /// No description provided for @loginCountryCode.
  ///
  /// In ar, this message translates to:
  /// **'+970'**
  String get loginCountryCode;

  /// No description provided for @loginSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get loginSend;

  /// No description provided for @loginAgreePrefix.
  ///
  /// In ar, this message translates to:
  /// **'بالمتابعة أنت توافق على '**
  String get loginAgreePrefix;

  /// No description provided for @loginTerms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط'**
  String get loginTerms;

  /// No description provided for @loginAnd.
  ///
  /// In ar, this message translates to:
  /// **' و'**
  String get loginAnd;

  /// No description provided for @loginPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get loginPrivacy;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمزًا من {length} أرقام إلى '**
  String otpSentTo(int length);

  /// No description provided for @otpEditPhone.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الرقم'**
  String get otpEditPhone;

  /// No description provided for @otpResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد '**
  String get otpResendIn;

  /// No description provided for @otpResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get otpResend;

  /// No description provided for @otpConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get otpConfirm;

  /// No description provided for @welcomeVerified.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق'**
  String get welcomeVerified;

  /// No description provided for @welcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بك في برق'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In ar, this message translates to:
  /// **'خطوة أخيرة: عرّفنا عليك وحدّد موقعك، لنعرض لك المتاجر اللي بتوصّل لمنطقتك.'**
  String get welcomeBody;

  /// No description provided for @welcomeNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get welcomeNameLabel;

  /// No description provided for @welcomeNameHint.
  ///
  /// In ar, this message translates to:
  /// **'محمد أحمد'**
  String get welcomeNameHint;

  /// No description provided for @welcomeLocationLabel.
  ///
  /// In ar, this message translates to:
  /// **'موقع التوصيل'**
  String get welcomeLocationLabel;

  /// No description provided for @welcomeAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'موقعي'**
  String get welcomeAddressLabel;

  /// No description provided for @welcomeNoLocation.
  ///
  /// In ar, this message translates to:
  /// **'لم تحدد موقعك بعد'**
  String get welcomeNoLocation;

  /// No description provided for @welcomeInZone.
  ///
  /// In ar, this message translates to:
  /// **'داخل منطقة الخدمة'**
  String get welcomeInZone;

  /// No description provided for @welcomeOutOfZone.
  ///
  /// In ar, this message translates to:
  /// **'خارج منطقة الخدمة'**
  String get welcomeOutOfZone;

  /// No description provided for @welcomeLocate.
  ///
  /// In ar, this message translates to:
  /// **'تحديد موقعي'**
  String get welcomeLocate;

  /// No description provided for @welcomeLocationOff.
  ///
  /// In ar, this message translates to:
  /// **'شغّل خدمة الموقع في جهازك ثم حاول مرة أخرى.'**
  String get welcomeLocationOff;

  /// No description provided for @welcomeLocationDenied.
  ///
  /// In ar, this message translates to:
  /// **'اسمح لبرق بالوصول إلى موقعك من إعدادات الجهاز ثم حاول مرة أخرى.'**
  String get welcomeLocationDenied;

  /// No description provided for @welcomeNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الطلبات'**
  String get welcomeNotifications;

  /// No description provided for @welcomeNotificationsBody.
  ///
  /// In ar, this message translates to:
  /// **'نخبرك عند قبول طلبك ووصوله'**
  String get welcomeNotificationsBody;

  /// No description provided for @welcomeStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوّق'**
  String get welcomeStart;

  /// No description provided for @offlineTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من الاتصال وأعد المحاولة. طلبك الحالي محفوظ ولم يتأثر.'**
  String get offlineBody;

  /// No description provided for @updateTitle.
  ///
  /// In ar, this message translates to:
  /// **'نسخة جديدة من برق'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In ar, this message translates to:
  /// **'حدّث التطبيق لتكمل الطلب. النسخة الجديدة أسرع وفيها إصلاحات مهمة.'**
  String get updateBody;

  /// No description provided for @updateVersion.
  ///
  /// In ar, this message translates to:
  /// **'نسخة {version}'**
  String updateVersion(String version);

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
  /// **'نحسّن الخدمة وراجعين قريبًا. طلباتك الحالية محفوظة ولن تُلغى.'**
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
  /// **'انتهت جلستك لحماية حسابك. أدخل رقمك وسنرسل لك رمزًا جديدًا.'**
  String get sessionBody;

  /// No description provided for @sessionLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get sessionLogin;
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
