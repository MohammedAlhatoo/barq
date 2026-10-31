// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Barq Captain';

  @override
  String get splashTagline => 'Ready for today\'s orders?';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get offlineTitle => 'No internet connection';

  @override
  String get offlineBody =>
      'Check your connection and try again. Your current job is safe.';

  @override
  String get updateTitle => 'A new Barq Captain version';

  @override
  String get updateBody =>
      'Update the app to keep working. The new version is faster, with important fixes.';

  @override
  String updateVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get updateNow => 'Update now';

  @override
  String get maintenanceTitle => 'Barq is under maintenance';

  @override
  String get maintenanceBody =>
      'We are improving the service and will be back soon. Your jobs are safe.';

  @override
  String get maintenanceRefresh => 'Refresh';

  @override
  String get maintenanceContact => 'Questions: ';

  @override
  String get sessionTitle => 'Log in again';

  @override
  String get sessionBody =>
      'Your session ended to protect your account. Enter your number and password.';

  @override
  String get sessionLogin => 'Log in';

  @override
  String get navJobs => 'Orders';

  @override
  String get navEarnings => 'Earnings';

  @override
  String get navHistory => 'History';

  @override
  String get navAccount => 'Account';

  @override
  String get loginCaptain => 'Captain';

  @override
  String get loginTitle => 'Log in as a driver';

  @override
  String get loginBody =>
      'Use the mobile number and password the Barq team gave you.';

  @override
  String get loginPhoneLabel => 'Mobile number';

  @override
  String get loginPhoneHint => '059 000 0000';

  @override
  String get loginCountryCode => '+970';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginShowPassword => 'Show';

  @override
  String get loginHidePassword => 'Hide';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginFootnote => 'Only the Barq team activates driver accounts';

  @override
  String get locationServiceTitle => 'Barq Captain';

  @override
  String get locationServiceBody =>
      'Sending your location while you are online';

  @override
  String get locationDenied =>
      'Allow location access in settings to go online.';

  @override
  String get locationServiceOff => 'Turn on location services to go online.';

  @override
  String get locationUnavailable =>
      'Could not find your location. Move to an open area and try again.';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get jobsTodayEarnings => 'Today\'s earnings';

  @override
  String get jobsOrdersStat => 'Orders';

  @override
  String get jobsRatingStat => 'Rating';

  @override
  String jobsNearby(int count) {
    return 'Nearby orders ($count)';
  }

  @override
  String get jobsAutoRefresh => 'Auto refresh';

  @override
  String get jobsEmptyTitle => 'No nearby orders right now';

  @override
  String get jobsEmptyBody => 'Stay online. New orders will appear here.';

  @override
  String get jobsTaken => 'Another driver took this order first';

  @override
  String jobTo(Object place) {
    return 'To $place';
  }

  @override
  String distanceKm(Object distance) {
    return '$distance km';
  }

  @override
  String jobItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get jobYourFare => 'Your fare';

  @override
  String jobCollect(Object amount) {
    return 'Collect $amount';
  }

  @override
  String get jobAccept => 'Accept';

  @override
  String get offlineJobsTitle => 'You are offline';

  @override
  String get offlineJobsBody =>
      'Press the button to start receiving orders in your area.';

  @override
  String get offerTitle => 'New order!';

  @override
  String get offerPickup => 'Pickup';

  @override
  String offerPickupDistance(Object distance) {
    return 'Pickup · $distance km from you';
  }

  @override
  String get offerDropoff => 'Drop-off';

  @override
  String offerDropoffDistance(Object distance) {
    return 'Drop-off · $distance km';
  }

  @override
  String get offerCollect => 'Collect from customer';

  @override
  String offerCash(Object amount) {
    return '$amount cash';
  }

  @override
  String get offerAccept => 'Accept order';

  @override
  String get offerIgnore => 'Ignore';

  @override
  String get cashLimitTitle => 'You reached the cash limit';

  @override
  String cashLimitBody(Object amount) {
    return 'You hold $amount in cash. Settle it at the Barq office to receive new orders.';
  }

  @override
  String get cashLimitCollected => 'Cash collected';

  @override
  String cashLimitMax(Object amount) {
    return 'Limit $amount';
  }

  @override
  String get cashLimitSupport => 'Contact support';

  @override
  String taskHeading(Object status, Object target) {
    return '$status · $target';
  }

  @override
  String get taskToStore => 'head to the store';

  @override
  String get taskToCustomer => 'head to the customer';

  @override
  String get taskNavigate => 'Navigate';

  @override
  String get taskCall => 'Call';

  @override
  String taskItem(Object name, int qty) {
    return '$name × $qty';
  }

  @override
  String taskMoreItems(int count) {
    return '+ $count more';
  }

  @override
  String get taskPhotoHint => 'This step needs a photo';

  @override
  String get taskNoStep => 'Waiting for the order to update.';

  @override
  String get taskEmptyTitle => 'No current job';

  @override
  String get taskEmptyBody => 'Accept an order from the list to start.';

  @override
  String get photoTitle => 'Photo of the order';

  @override
  String get photoBody =>
      'A clear photo of the bags before pickup, needed to confirm this step.';

  @override
  String get photoShutter => 'Take photo';

  @override
  String get photoRetake => 'Press the button to retake';

  @override
  String get photoCameraFailed =>
      'Could not open the camera. Allow it in settings.';

  @override
  String get tooFarStore => 'You are far from the store';

  @override
  String get tooFarCustomer => 'You are far from the customer';

  @override
  String tooFarDistance(int meters) {
    return '$meters m from the place';
  }

  @override
  String tooFarBody(Object label, int meters, Object place) {
    return 'The “$label” button works only within $meters meters of $place.';
  }

  @override
  String get tooFarNavigate => 'Open navigation';

  @override
  String get tooFarRetry => 'Try again';

  @override
  String deliverTitle(Object status) {
    return '$status · hand over the order';
  }

  @override
  String get deliverHelp => 'Help';

  @override
  String get deliverCollect => 'Collect in cash from the customer';

  @override
  String get deliverIncludesFee => 'Delivery included';

  @override
  String get deliverPhotoTitle => 'Photo at the door';

  @override
  String get deliverPhotoTaken => 'Photo taken';

  @override
  String get deliverPhotoProof => 'The photo proves the delivery';

  @override
  String get deliverTakePhoto => 'Take photo';

  @override
  String get deliverRetake => 'Retake';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get earningsOfDay => 'Today\'s earnings';

  @override
  String get earningsOfWeek => 'This week\'s earnings';

  @override
  String get earningsOfMonth => 'This month\'s earnings';

  @override
  String earningsOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String get cashOnHand => 'Cash on hand';

  @override
  String cashRemaining(Object amount) {
    return '$amount left before the limit';
  }

  @override
  String cashUnsettled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders not settled',
      one: '1 order not settled',
      zero: 'All orders settled',
    );
    return '$_temp0';
  }

  @override
  String get historyTitle => 'Job history';

  @override
  String get historyAll => 'All';

  @override
  String get historyDelivered => 'Delivered';

  @override
  String get historyCancelled => 'Cancelled';

  @override
  String historyToday(int count, Object amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs',
      one: '1 job',
    );
    return 'Today · $_temp0 · $amount';
  }

  @override
  String historyCash(Object amount) {
    return 'Cash $amount';
  }

  @override
  String get historyEmptyTitle => 'No jobs here';

  @override
  String get historyEmptyBody => 'Your finished jobs will appear here.';

  @override
  String accountRating(Object rating, int count) {
    return '$rating ($count)';
  }

  @override
  String get accountNotifications => 'Notifications';

  @override
  String get accountSupport => 'Support';

  @override
  String get accountLogout => 'Log out';

  @override
  String get settingsVehicle => 'Vehicle type';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSave => 'Save';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get vehicleMotorcycle => 'Motorcycle';

  @override
  String get vehicleCar => 'Car';

  @override
  String get vehicleBicycle => 'Bicycle';

  @override
  String get vehicleVan => 'Van';

  @override
  String get vehicleTukTuk => 'Tuk-tuk';

  @override
  String get vehicleOnFoot => 'On foot';

  @override
  String get notificationsReadAll => 'Read all';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyBody =>
      'New orders and updates will appear here.';

  @override
  String get accountVehicle => 'Vehicle';
}
