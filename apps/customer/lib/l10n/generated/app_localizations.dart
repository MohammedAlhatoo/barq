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

  /// No description provided for @homeMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get homeMorning;

  /// No description provided for @homeEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get homeEvening;

  /// No description provided for @homeAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get homeAll;

  /// No description provided for @homeBestSellers.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر طلبًا'**
  String get homeBestSellers;

  /// No description provided for @homeSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get homeSeeAll;

  /// No description provided for @homeNearStores.
  ///
  /// In ar, this message translates to:
  /// **'متاجر قريبة'**
  String get homeNearStores;

  /// No description provided for @homeStores.
  ///
  /// In ar, this message translates to:
  /// **'المتاجر'**
  String get homeStores;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن منتج أو متجر'**
  String get searchHint;

  /// No description provided for @soldOut.
  ///
  /// In ar, this message translates to:
  /// **'نفدت الكمية'**
  String get soldOut;

  /// No description provided for @browseEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات هنا بعد'**
  String get browseEmpty;

  /// No description provided for @searchRecent.
  ///
  /// In ar, this message translates to:
  /// **'عمليات بحث سابقة:'**
  String get searchRecent;

  /// No description provided for @searchCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نتيجة'**
  String searchCount(int count);

  /// No description provided for @searchNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا نتائج'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsBody.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة ثانية أو تأكد من الإملاء.'**
  String get searchNoResultsBody;

  /// No description provided for @distanceKm.
  ///
  /// In ar, this message translates to:
  /// **'{km} كم'**
  String distanceKm(String km);

  /// No description provided for @vendorOpen.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get vendorOpen;

  /// No description provided for @vendorClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get vendorClosed;

  /// No description provided for @vendorPrep.
  ///
  /// In ar, this message translates to:
  /// **'تحضير {minutes} د'**
  String vendorPrep(int minutes);

  /// No description provided for @viewCart.
  ///
  /// In ar, this message translates to:
  /// **'عرض السلة'**
  String get viewCart;

  /// No description provided for @cartCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتجات'**
  String cartCount(int count);

  /// No description provided for @productTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المنتج'**
  String get productTitle;

  /// No description provided for @productAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get productAvailable;

  /// No description provided for @productUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get productUnavailable;

  /// No description provided for @productRequired.
  ///
  /// In ar, this message translates to:
  /// **'(إجباري)'**
  String get productRequired;

  /// No description provided for @productDescription.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get productDescription;

  /// No description provided for @addToCart.
  ///
  /// In ar, this message translates to:
  /// **'أضف للسلة'**
  String get addToCart;

  /// No description provided for @addToCartPrice.
  ///
  /// In ar, this message translates to:
  /// **'أضف للسلة · {price}'**
  String addToCartPrice(String price);

  /// No description provided for @otherStoreTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفريغ السلة؟'**
  String get otherStoreTitle;

  /// No description provided for @otherStoreBody.
  ///
  /// In ar, this message translates to:
  /// **'سلتك فيها منتجات من متجر ثاني، والطلب بيكون من متجر واحد. نفرّغها ونضيف هذا المنتج؟'**
  String get otherStoreBody;

  /// No description provided for @otherStoreConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تفريغ وإضافة'**
  String get otherStoreConfirm;

  /// No description provided for @commonKeepCart.
  ///
  /// In ar, this message translates to:
  /// **'إبقاء السلة'**
  String get commonKeepCart;

  /// No description provided for @cartLimitTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصلت للحد المسموح'**
  String get cartLimitTitle;

  /// No description provided for @cartLimitBody.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إضافة المزيد إلى السلة.'**
  String get cartLimitBody;

  /// No description provided for @commonOk.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get commonOk;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلتي'**
  String get cartTitle;

  /// No description provided for @cartClearTitle.
  ///
  /// In ar, this message translates to:
  /// **'إفراغ السلة؟'**
  String get cartClearTitle;

  /// No description provided for @cartClearBody.
  ///
  /// In ar, this message translates to:
  /// **'بنحذف كل المنتجات من سلتك.'**
  String get cartClearBody;

  /// No description provided for @cartClearConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إفراغ السلة'**
  String get cartClearConfirm;

  /// No description provided for @cartCompareTitle.
  ///
  /// In ar, this message translates to:
  /// **'قارن سلتك بمتاجر منطقتك'**
  String get cartCompareTitle;

  /// No description provided for @cartCompareBody.
  ///
  /// In ar, this message translates to:
  /// **'نشوف إذا في متجر أرخص بيوصّلك'**
  String get cartCompareBody;

  /// No description provided for @cartTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get cartTotal;

  /// No description provided for @cartDelivery.
  ///
  /// In ar, this message translates to:
  /// **'التوصيل'**
  String get cartDelivery;

  /// No description provided for @cartAtCheckout.
  ///
  /// In ar, this message translates to:
  /// **'يُحسب عند تأكيد الطلب'**
  String get cartAtCheckout;

  /// No description provided for @cartContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الطلب'**
  String get cartContinue;

  /// No description provided for @cartContinueTotal.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الطلب · {total}'**
  String cartContinueTotal(String total);

  /// No description provided for @cartEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلتك فارغة'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف منتجات من متاجر منطقتك، وبرق يقارن لك الأسعار قبل ما تطلب.'**
  String get cartEmptyBody;

  /// No description provided for @cartBrowse.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح المتاجر'**
  String get cartBrowse;

  /// No description provided for @compareTitle.
  ///
  /// In ar, this message translates to:
  /// **'السلة الأوفر'**
  String get compareTitle;

  /// No description provided for @compareZone.
  ///
  /// In ar, this message translates to:
  /// **'متاجر منطقتك: {zone}'**
  String compareZone(String zone);

  /// No description provided for @compareBody.
  ///
  /// In ar, this message translates to:
  /// **'قارنّا منتجات سلتك ({count}) بالمتاجر اللي بتوصّل لعنوانك بس.'**
  String compareBody(int count);

  /// No description provided for @compareBest.
  ///
  /// In ar, this message translates to:
  /// **'الأوفر'**
  String get compareBest;

  /// No description provided for @compareAvailable.
  ///
  /// In ar, this message translates to:
  /// **'{available} من {total} متوفرة'**
  String compareAvailable(int available, int total);

  /// No description provided for @compareOthers.
  ///
  /// In ar, this message translates to:
  /// **'متاجر أخرى بمنطقتك'**
  String get compareOthers;

  /// No description provided for @comparePickBest.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الأوفر · {price}'**
  String comparePickBest(String price);

  /// No description provided for @comparePick.
  ///
  /// In ar, this message translates to:
  /// **'اختيار {store} · {price}'**
  String comparePick(String store, String price);

  /// No description provided for @compareMissing.
  ///
  /// In ar, this message translates to:
  /// **'ناقص {count} · {detail}'**
  String compareMissing(int count, String detail);

  /// No description provided for @compareNotEnough.
  ///
  /// In ar, this message translates to:
  /// **'الكمية غير كافية'**
  String get compareNotEnough;

  /// No description provided for @noStoreBadge.
  ///
  /// In ar, this message translates to:
  /// **'ناقص أصناف'**
  String get noStoreBadge;

  /// No description provided for @noStoreTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما في متجر عنده كل سلتك'**
  String get noStoreTitle;

  /// No description provided for @noStoreBody.
  ///
  /// In ar, this message translates to:
  /// **'كل متاجر {zone} ناقصها صنف أو أكثر. اختار متجر وبنكمّل بالمتوفر، أو عدّل السلة.'**
  String noStoreBody(String zone);

  /// No description provided for @noStoreContinue.
  ///
  /// In ar, this message translates to:
  /// **'أكمل من {store}'**
  String noStoreContinue(String store);

  /// No description provided for @noStoreEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل السلة'**
  String get noStoreEdit;

  /// No description provided for @noStoresTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما في متاجر بتوصّل لعنوانك حاليًا'**
  String get noStoresTitle;

  /// No description provided for @outOfZoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا نوصل لهذا العنوان بعد'**
  String get outOfZoneTitle;

  /// No description provided for @outOfZoneBody.
  ///
  /// In ar, this message translates to:
  /// **'عنوانك خارج مناطق خدمة برق حاليًا. اختر عنوانًا آخر داخل منطقة التوصيل.'**
  String get outOfZoneBody;

  /// No description provided for @outOfZoneChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير العنوان'**
  String get outOfZoneChange;

  /// No description provided for @noAddressTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك عنوان توصيل'**
  String get noAddressTitle;

  /// No description provided for @noAddressBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف عنوانك عشان نقارن سلتك بالمتاجر اللي بتوصّلك.'**
  String get noAddressBody;

  /// No description provided for @noAddressAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنوان'**
  String get noAddressAdd;

  /// No description provided for @checkoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get checkoutTitle;

  /// No description provided for @compareWithDelivery.
  ///
  /// In ar, this message translates to:
  /// **'شامل التوصيل'**
  String get compareWithDelivery;

  /// No description provided for @compareDeliveryLater.
  ///
  /// In ar, this message translates to:
  /// **'التوصيل يُحسب لاحقًا'**
  String get compareDeliveryLater;

  /// No description provided for @scopeShoppingFrom.
  ///
  /// In ar, this message translates to:
  /// **'تتسوّق من: {store}'**
  String scopeShoppingFrom(String store);

  /// No description provided for @scopeCartStore.
  ///
  /// In ar, this message translates to:
  /// **'متجر سلتك'**
  String get scopeCartStore;

  /// No description provided for @scopeAllStores.
  ///
  /// In ar, this message translates to:
  /// **'كل المتاجر'**
  String get scopeAllStores;

  /// No description provided for @scopeOnlyMine.
  ///
  /// In ar, this message translates to:
  /// **'متجر سلتي فقط'**
  String get scopeOnlyMine;

  /// No description provided for @vendorsTitle.
  ///
  /// In ar, this message translates to:
  /// **'كل المتاجر'**
  String get vendorsTitle;

  /// No description provided for @vendorsOpenNow.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح الآن'**
  String get vendorsOpenNow;

  /// No description provided for @vendorsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد متاجر حاليًا'**
  String get vendorsEmpty;

  /// No description provided for @vendorNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get vendorNew;

  /// No description provided for @vendorCategoryGrocery.
  ///
  /// In ar, this message translates to:
  /// **'بقالة'**
  String get vendorCategoryGrocery;

  /// No description provided for @vendorCallFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح الاتصال'**
  String get vendorCallFailed;

  /// No description provided for @cartWithDelivery.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي مع التوصيل'**
  String get cartWithDelivery;

  /// No description provided for @compareCurrentCart.
  ///
  /// In ar, this message translates to:
  /// **'سلتك الحالية'**
  String get compareCurrentCart;

  /// No description provided for @compareCurrentIsBest.
  ///
  /// In ar, this message translates to:
  /// **'متجرك الحالي هو الأوفر بين أقرب المتاجر'**
  String get compareCurrentIsBest;

  /// No description provided for @compareKeepCart.
  ///
  /// In ar, this message translates to:
  /// **'متابعة بسلتي الحالية'**
  String get compareKeepCart;

  /// No description provided for @compareSave.
  ///
  /// In ar, this message translates to:
  /// **'وفّر {price}'**
  String compareSave(String price);

  /// No description provided for @accountTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get accountTitle;

  /// No description provided for @accountOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلب'**
  String get accountOrders;

  /// No description provided for @accountAddresses.
  ///
  /// In ar, this message translates to:
  /// **'عناوين'**
  String get accountAddresses;

  /// No description provided for @accountNoName.
  ///
  /// In ar, this message translates to:
  /// **'بدون اسم'**
  String get accountNoName;

  /// No description provided for @accountMyAddresses.
  ///
  /// In ar, this message translates to:
  /// **'عناويني'**
  String get accountMyAddresses;

  /// No description provided for @accountNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get accountNotifications;

  /// No description provided for @accountLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get accountLanguage;

  /// No description provided for @accountLanguageName.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get accountLanguageName;

  /// No description provided for @accountHelp.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get accountHelp;

  /// No description provided for @accountLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get accountLogout;

  /// No description provided for @accountLogoutBody.
  ///
  /// In ar, this message translates to:
  /// **'بنمسح سلتك وعمليات البحث من هذا الجهاز.'**
  String get accountLogoutBody;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get profileName;

  /// No description provided for @profilePhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get profilePhone;

  /// No description provided for @profilePhoneHelper.
  ///
  /// In ar, this message translates to:
  /// **'لتغيير الرقم تواصل مع الدعم'**
  String get profilePhoneHelper;

  /// No description provided for @profileLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get profileLanguage;

  /// No description provided for @profileAddressesBody.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة بتتحدد من موقع العنوان'**
  String get profileAddressesBody;

  /// No description provided for @profileSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get profileSave;

  /// No description provided for @profileDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get profileDelete;

  /// No description provided for @deleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب نهائيًا؟'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذه الخطوة.'**
  String get deleteBody;

  /// No description provided for @deleteNameAddresses.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف اسمك وعناوينك المحفوظة'**
  String get deleteNameAddresses;

  /// No description provided for @deleteOrders.
  ///
  /// In ar, this message translates to:
  /// **'لن تتمكن من رؤية طلباتك السابقة'**
  String get deleteOrders;

  /// No description provided for @deleteActive.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الجارية يجب أن تنتهي أولًا'**
  String get deleteActive;

  /// No description provided for @deleteUnderstand.
  ///
  /// In ar, this message translates to:
  /// **'أفهم أن حذف الحساب نهائي'**
  String get deleteUnderstand;

  /// No description provided for @deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteConfirm;

  /// No description provided for @addressesTitle.
  ///
  /// In ar, this message translates to:
  /// **'عناويني'**
  String get addressesTitle;

  /// No description provided for @addressesDefault.
  ///
  /// In ar, this message translates to:
  /// **'الافتراضي'**
  String get addressesDefault;

  /// No description provided for @addressesAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنوان جديد'**
  String get addressesAdd;

  /// No description provided for @addressesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك عناوين محفوظة'**
  String get addressesEmpty;

  /// No description provided for @addressesEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف عنوانك عشان نعرض لك المتاجر اللي بتوصّلك.'**
  String get addressesEmptyBody;

  /// No description provided for @addressDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا العنوان؟'**
  String get addressDeleteTitle;

  /// No description provided for @addressDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات السابقة تحتفظ بنسخة منه.'**
  String get addressDeleteBody;

  /// No description provided for @addressDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف العنوان'**
  String get addressDeleteConfirm;

  /// No description provided for @addressUnnamed.
  ///
  /// In ar, this message translates to:
  /// **'عنوان'**
  String get addressUnnamed;

  /// No description provided for @addressPickerTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر عنوان التوصيل'**
  String get addressPickerTitle;

  /// No description provided for @addressFormTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العنوان'**
  String get addressFormTitle;

  /// No description provided for @addressMapHint.
  ///
  /// In ar, this message translates to:
  /// **'حرّك الخريطة لتحديد الموقع'**
  String get addressMapHint;

  /// No description provided for @addressHome.
  ///
  /// In ar, this message translates to:
  /// **'البيت'**
  String get addressHome;

  /// No description provided for @addressWork.
  ///
  /// In ar, this message translates to:
  /// **'العمل'**
  String get addressWork;

  /// No description provided for @addressOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get addressOther;

  /// No description provided for @addressOtherHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم العنوان (مثل: بيت أهلي)'**
  String get addressOtherHint;

  /// No description provided for @addressDetailsHint.
  ///
  /// In ar, this message translates to:
  /// **'الشارع، أقرب معلم، العمارة، الطابق'**
  String get addressDetailsHint;

  /// No description provided for @addressZoneUnknown.
  ///
  /// In ar, this message translates to:
  /// **'نتحقق من المنطقة عند الحفظ'**
  String get addressZoneUnknown;

  /// No description provided for @addressZoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'موقع العنوان'**
  String get addressZoneLabel;

  /// No description provided for @addressInZone.
  ///
  /// In ar, this message translates to:
  /// **'داخل الخدمة'**
  String get addressInZone;

  /// No description provided for @addressOutOfZone.
  ///
  /// In ar, this message translates to:
  /// **'خارج الخدمة'**
  String get addressOutOfZone;

  /// No description provided for @addressMakeDefault.
  ///
  /// In ar, this message translates to:
  /// **'اجعله العنوان الافتراضي'**
  String get addressMakeDefault;

  /// No description provided for @addressSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ العنوان'**
  String get addressSave;

  /// No description provided for @addressLocateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد موقعك. حرّك الخريطة يدويًا.'**
  String get addressLocateFailed;

  /// No description provided for @addressMapCredit.
  ///
  /// In ar, this message translates to:
  /// **'© OpenStreetMap'**
  String get addressMapCredit;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @checkoutNoAddressBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف عنوانك عشان نحسب سعر الطلب والتوصيل.'**
  String get checkoutNoAddressBody;

  /// No description provided for @checkoutCash.
  ///
  /// In ar, this message translates to:
  /// **'نقدًا عند الاستلام'**
  String get checkoutCash;

  /// No description provided for @checkoutSubstitutions.
  ///
  /// In ar, this message translates to:
  /// **'إذا نفد صنف'**
  String get checkoutSubstitutions;

  /// No description provided for @subCallMe.
  ///
  /// In ar, this message translates to:
  /// **'اتصلوا بي'**
  String get subCallMe;

  /// No description provided for @subSimilar.
  ///
  /// In ar, this message translates to:
  /// **'بديل مشابه'**
  String get subSimilar;

  /// No description provided for @subSkip.
  ///
  /// In ar, this message translates to:
  /// **'احذفوه'**
  String get subSkip;

  /// No description provided for @checkoutCouponHint.
  ///
  /// In ar, this message translates to:
  /// **'كود الخصم'**
  String get checkoutCouponHint;

  /// No description provided for @checkoutCouponApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get checkoutCouponApply;

  /// No description provided for @checkoutCouponApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم تطبيقه'**
  String get checkoutCouponApplied;

  /// No description provided for @checkoutNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة للمتجر أو السائق'**
  String get checkoutNoteHint;

  /// No description provided for @checkoutTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get checkoutTotal;

  /// No description provided for @checkoutChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get checkoutChange;

  /// No description provided for @checkoutPriceHeld.
  ///
  /// In ar, this message translates to:
  /// **'السعر محجوز لك لمدة'**
  String get checkoutPriceHeld;

  /// No description provided for @quoteExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية السعر'**
  String get quoteExpiredTitle;

  /// No description provided for @quoteExpiredChanged.
  ///
  /// In ar, this message translates to:
  /// **'طلبنا تسعيرة جديدة، وهاي الأسعار اللي تغيّرت:'**
  String get quoteExpiredChanged;

  /// No description provided for @quoteExpiredSame.
  ///
  /// In ar, this message translates to:
  /// **'طلبنا تسعيرة جديدة، والأسعار ما تغيّرت.'**
  String get quoteExpiredSame;

  /// No description provided for @quoteExpiredNewTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي الجديد'**
  String get quoteExpiredNewTotal;

  /// No description provided for @quoteExpiredContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة بالسعر الجديد'**
  String get quoteExpiredContinue;

  /// No description provided for @quoteExpiredReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة السلة'**
  String get quoteExpiredReview;

  /// No description provided for @offerTitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض السعر'**
  String get offerTitle;

  /// No description provided for @offerNotReadyTitle.
  ///
  /// In ar, this message translates to:
  /// **'المتجر لسا ما سعّر طلبك'**
  String get offerNotReadyTitle;

  /// No description provided for @offerNotReadyBody.
  ///
  /// In ar, this message translates to:
  /// **'رح يوصلك العرض هون فور تجهيزه.'**
  String get offerNotReadyBody;

  /// No description provided for @offerPricedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تسعير طلبك'**
  String get offerPricedTitle;

  /// No description provided for @offerPricedBody.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات بالوزن تُسعّر بعد التجهيز'**
  String get offerPricedBody;

  /// No description provided for @offerUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get offerUnavailable;

  /// No description provided for @offerItemsTotal.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get offerItemsTotal;

  /// No description provided for @offerDelivery.
  ///
  /// In ar, this message translates to:
  /// **'التوصيل'**
  String get offerDelivery;

  /// No description provided for @offerActionRefused.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا ننفّذ هاد الطلب. جرّب مرة ثانية أو تواصل مع الدعم.'**
  String get offerActionRefused;

  /// No description provided for @offerApprove.
  ///
  /// In ar, this message translates to:
  /// **'الموافقة على العرض'**
  String get offerApprove;

  /// No description provided for @offerExpiredPill.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المهلة'**
  String get offerExpiredPill;

  /// No description provided for @offerExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية العرض'**
  String get offerExpiredTitle;

  /// No description provided for @offerExpiredBodyPlain.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم الموافقة على عرض السعر، فأُلغي الطلب تلقائيًا. لم يُخصم أي مبلغ.'**
  String get offerExpiredBodyPlain;

  /// No description provided for @offerExpiredReorder.
  ///
  /// In ar, this message translates to:
  /// **'اطلب نفس السلة من جديد'**
  String get offerExpiredReorder;

  /// No description provided for @offerExpiredHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get offerExpiredHome;

  /// No description provided for @reorderReplaceTitle.
  ///
  /// In ar, this message translates to:
  /// **'في سلة حاليًا'**
  String get reorderReplaceTitle;

  /// No description provided for @reorderReplaceBody.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الطلب رح تستبدل سلتك الحالية.'**
  String get reorderReplaceBody;

  /// No description provided for @reorderReplaceConfirm.
  ///
  /// In ar, this message translates to:
  /// **'استبدال السلة'**
  String get reorderReplaceConfirm;

  /// No description provided for @orderSandboxAdvance.
  ///
  /// In ar, this message translates to:
  /// **'تجربة: خطوة المتجر التالية'**
  String get orderSandboxAdvance;

  /// No description provided for @checkoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب · {total}'**
  String checkoutConfirm(String total);

  /// No description provided for @checkoutDistance.
  ///
  /// In ar, this message translates to:
  /// **'{km} كم'**
  String checkoutDistance(String km);

  /// No description provided for @quoteExpiredPassed.
  ///
  /// In ar, this message translates to:
  /// **'مرّت {minutes} دقيقة على التسعيرة'**
  String quoteExpiredPassed(int minutes);

  /// No description provided for @lineWithQty.
  ///
  /// In ar, this message translates to:
  /// **'{name} × {qty}'**
  String lineWithQty(String name, int qty);

  /// No description provided for @offerUnitPrice.
  ///
  /// In ar, this message translates to:
  /// **'{price} للوحدة'**
  String offerUnitPrice(String price);

  /// No description provided for @offerSubstitute.
  ///
  /// In ar, this message translates to:
  /// **'البديل: {name} · {price} للوحدة'**
  String offerSubstitute(String name, String price);

  /// No description provided for @offerStoreNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة المتجر: {note}'**
  String offerStoreNote(String note);

  /// No description provided for @offerDeadline.
  ///
  /// In ar, this message translates to:
  /// **'إذا لم توافق خلال {minutes} دقيقة، يُلغى الطلب تلقائيًا.'**
  String offerDeadline(int minutes);

  /// No description provided for @offerExpiredBody.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم الموافقة على عرض السعر خلال {minutes} دقيقة، فأُلغي الطلب تلقائيًا. لم يُخصم أي مبلغ.'**
  String offerExpiredBody(int minutes);

  /// No description provided for @offerExpiredSummary.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج · كان الإجمالي {total}'**
  String offerExpiredSummary(int count, String total);

  /// No description provided for @orderTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب {code}'**
  String orderTitle(String code);

  /// No description provided for @reorderMissing.
  ///
  /// In ar, this message translates to:
  /// **'{count} من الأصناف ما عادت متوفرة بالمتجر.'**
  String reorderMissing(int count);

  /// No description provided for @orderWaitingBody.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا طلبك لـ {store}، ورح نخبرك بكل جديد.'**
  String orderWaitingBody(String store);

  /// No description provided for @orderWaitingBodyPlain.
  ///
  /// In ar, this message translates to:
  /// **'وصل طلبك، ورح نخبرك بكل جديد.'**
  String get orderWaitingBodyPlain;

  /// No description provided for @orderCancelledBody.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء هذا الطلب. لم يُخصم أي مبلغ.'**
  String get orderCancelledBody;

  /// No description provided for @orderNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get orderNow;

  /// No description provided for @orderPhotoNote.
  ///
  /// In ar, this message translates to:
  /// **'عند التسليم، السائق بيصوّر الطلب على بابك كإثبات استلام.'**
  String get orderPhotoNote;

  /// No description provided for @trackingPhotoNote.
  ///
  /// In ar, this message translates to:
  /// **'السائق بيصوّر الطلب عند بابك كإثبات تسليم'**
  String get trackingPhotoNote;

  /// No description provided for @trackingEta.
  ///
  /// In ar, this message translates to:
  /// **'يصل خلال {minutes} دقيقة'**
  String trackingEta(int minutes);

  /// No description provided for @trackingNoDriver.
  ///
  /// In ar, this message translates to:
  /// **'رح يظهر السائق هون فور ما يقبل الطلب.'**
  String get trackingNoDriver;

  /// No description provided for @trackingShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة رابط التتبع'**
  String get trackingShare;

  /// No description provided for @trackingCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get trackingCancel;

  /// No description provided for @shareLinkBody.
  ///
  /// In ar, this message translates to:
  /// **'أي شخص معه الرابط بيقدر يتابع حالة الطلب بدون تسجيل دخول.'**
  String get shareLinkBody;

  /// No description provided for @shareLinkSend.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الرابط'**
  String get shareLinkSend;

  /// No description provided for @shareLinkStop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف الرابط'**
  String get shareLinkStop;

  /// No description provided for @mapCredit.
  ///
  /// In ar, this message translates to:
  /// **'© OpenStreetMap'**
  String get mapCredit;

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

  /// No description provided for @cancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب؟'**
  String get cancelTitle;

  /// No description provided for @cancelBody.
  ///
  /// In ar, this message translates to:
  /// **'ممكن تلغي قبل ما يستلم السائق الطلب'**
  String get cancelBody;

  /// No description provided for @cancelWhy.
  ///
  /// In ar, this message translates to:
  /// **'ليش بدك تلغي؟'**
  String get cancelWhy;

  /// No description provided for @cancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإلغاء'**
  String get cancelConfirm;

  /// No description provided for @cancelBack.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get cancelBack;

  /// No description provided for @rateDeliveredTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصل طلبك، بالهنا والشفا!'**
  String get rateDeliveredTitle;

  /// No description provided for @rateDeliveredAt.
  ///
  /// In ar, this message translates to:
  /// **'تم التوصيل {time}'**
  String rateDeliveredAt(String time);

  /// No description provided for @ratePaid.
  ///
  /// In ar, this message translates to:
  /// **'دفعت {total}'**
  String ratePaid(String total);

  /// No description provided for @rateSaved.
  ///
  /// In ar, this message translates to:
  /// **'وفّرت {amount}'**
  String rateSaved(String amount);

  /// No description provided for @rateTitle.
  ///
  /// In ar, this message translates to:
  /// **'قيّم تجربتك'**
  String get rateTitle;

  /// No description provided for @rateDriver.
  ///
  /// In ar, this message translates to:
  /// **'السائق'**
  String get rateDriver;

  /// No description provided for @rateStore.
  ///
  /// In ar, this message translates to:
  /// **'المتجر'**
  String get rateStore;

  /// No description provided for @rateComment.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقك (اختياري)'**
  String get rateComment;

  /// No description provided for @rateSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get rateSend;

  /// No description provided for @rateSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي'**
  String get rateSkip;

  /// No description provided for @ordersTabCurrent.
  ///
  /// In ar, this message translates to:
  /// **'الحالية'**
  String get ordersTabCurrent;

  /// No description provided for @ordersTabCurrentCount.
  ///
  /// In ar, this message translates to:
  /// **'الحالية ({count})'**
  String ordersTabCurrentCount(int count);

  /// No description provided for @ordersTabPast.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get ordersTabPast;

  /// No description provided for @ordersEmptyCurrent.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك طلبات حالية'**
  String get ordersEmptyCurrent;

  /// No description provided for @ordersEmptyPast.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك طلبات سابقة'**
  String get ordersEmptyPast;

  /// No description provided for @ordersItems.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتجات · {total}'**
  String ordersItems(int count, String total);

  /// No description provided for @ordersFollow.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الطلب'**
  String get ordersFollow;

  /// No description provided for @ordersReorder.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الطلب'**
  String get ordersReorder;

  /// No description provided for @receiptTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة'**
  String get receiptTitle;

  /// No description provided for @receiptPaidCash.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع نقدًا'**
  String get receiptPaidCash;

  /// No description provided for @receiptCashOnDelivery.
  ///
  /// In ar, this message translates to:
  /// **'الدفع عند الاستلام'**
  String get receiptCashOnDelivery;

  /// No description provided for @receiptTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get receiptTotal;

  /// No description provided for @receiptReorder.
  ///
  /// In ar, this message translates to:
  /// **'إعادة نفس الطلب'**
  String get receiptReorder;

  /// No description provided for @receiptShareText.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة طلب {code}: {total}'**
  String receiptShareText(String code, String total);

  /// No description provided for @notificationsReadAll.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الكل'**
  String get notificationsReadAll;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في إشعارات'**
  String get notificationsEmpty;

  /// No description provided for @notificationsToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get notificationsYesterday;

  /// No description provided for @notificationsEarlier.
  ///
  /// In ar, this message translates to:
  /// **'أقدم'**
  String get notificationsEarlier;

  /// No description provided for @timeNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get timeNow;

  /// No description provided for @timeMinutes.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} د'**
  String timeMinutes(int count);

  /// No description provided for @timeHours.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} س'**
  String timeHours(int count);

  /// No description provided for @timeDays.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} يوم'**
  String timeDays(int count);
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
