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
  String get splashTagline => 'Delivered at lightning speed';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get comingSoon => 'Coming soon';

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
  String get taskDeliverNext => 'The photo delivery step is coming next.';

  @override
  String get taskEmptyTitle => 'No current job';

  @override
  String get taskEmptyBody => 'Accept an order from the list to start.';
}
