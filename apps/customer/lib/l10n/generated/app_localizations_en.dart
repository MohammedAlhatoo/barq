// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Barq';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navOrders => 'My orders';

  @override
  String get navAccount => 'Account';

  @override
  String get navCart => 'Cart';

  @override
  String get placeholderSoon => 'This screen is being built';

  @override
  String get splashTagline => 'Your home needs at lightning speed';

  @override
  String get commonRetry => 'Try again';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingShopPill => 'Delivery in 30 min';

  @override
  String get onboardingShopTitle => 'Shop your daily needs with ease';

  @override
  String get onboardingShopBody =>
      'Vegetables, meat, dairy and bakery from stores near you, anytime and anywhere.';

  @override
  String get onboardingCompareTitle => 'Compare prices and save on every order';

  @override
  String get onboardingCompareBody =>
      'Barq compares your cart across nearby stores and suggests the cheapest one.';

  @override
  String get onboardingCompareStoreA => 'Al-Amana Supermarket';

  @override
  String get onboardingCompareStoreB => 'Al-Nour Minimarket';

  @override
  String get onboardingCompareStoreC => 'Al-Baraka Grocery';

  @override
  String get onboardingCompareItems => '8 items';

  @override
  String get onboardingCompareBest => 'Best price · Save ₪9';

  @override
  String get onboardingComparePriceA => '₪52';

  @override
  String get onboardingComparePriceB => '₪43';

  @override
  String get onboardingComparePriceC => '₪49';

  @override
  String get onboardingDeliveryPill => 'Live tracking';

  @override
  String get onboardingDeliveryTitle =>
      'From the store to your door at lightning speed';

  @override
  String get onboardingDeliveryBody =>
      'Follow your driver on the map, moment by moment, right to your door.';

  @override
  String get loginTitle => 'Enter your mobile number';

  @override
  String get loginBody =>
      'We will text you a verification code to log in or create a new account.';

  @override
  String get loginPhoneLabel => 'Mobile number';

  @override
  String get loginPhoneHint => '059 912 3456';

  @override
  String get loginCountryCode => '+970';

  @override
  String get loginSend => 'Send code';

  @override
  String get loginAgreePrefix => 'By continuing you agree to the ';

  @override
  String get loginTerms => 'Terms';

  @override
  String get loginAnd => ' and ';

  @override
  String get loginPrivacy => 'Privacy Policy';

  @override
  String get otpTitle => 'Enter the verification code';

  @override
  String otpSentTo(int length) {
    return 'We sent a $length-digit code to ';
  }

  @override
  String get otpEditPhone => 'Edit number';

  @override
  String get otpResendIn => 'Resend in ';

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpConfirm => 'Confirm';

  @override
  String get welcomeVerified => 'Verified';

  @override
  String get welcomeTitle => 'Welcome to Barq';

  @override
  String get welcomeBody =>
      'One last step: tell us your name and set your location to see the stores that deliver to you.';

  @override
  String get welcomeNameLabel => 'Name';

  @override
  String get welcomeNameHint => 'Your full name';

  @override
  String get welcomeLocationLabel => 'Delivery location';

  @override
  String get welcomeAddressLabel => 'My location';

  @override
  String get welcomeNoLocation => 'You have not set your location yet';

  @override
  String get welcomeInZone => 'In the service area';

  @override
  String get welcomeOutOfZone => 'Outside the service area';

  @override
  String get welcomeLocate => 'Use my location';

  @override
  String get welcomeLocationOff =>
      'Turn on location services on your device and try again.';

  @override
  String get welcomeLocationDenied =>
      'Allow Barq to use your location in the device settings and try again.';

  @override
  String get welcomeNotifications => 'Order notifications';

  @override
  String get welcomeNotificationsBody =>
      'We tell you when your order is accepted and arrives';

  @override
  String get welcomeStart => 'Start shopping';

  @override
  String get offlineTitle => 'No internet connection';

  @override
  String get offlineBody =>
      'Check your connection and try again. Your current order is safe.';

  @override
  String get updateTitle => 'A new version of Barq';

  @override
  String get updateBody =>
      'Update the app to continue. The new version is faster and has important fixes.';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String get updateNow => 'Update now';

  @override
  String get maintenanceTitle => 'Barq is under maintenance';

  @override
  String get maintenanceBody =>
      'We are improving the service and will be back soon. Your current orders are safe.';

  @override
  String get maintenanceRefresh => 'Refresh';

  @override
  String get maintenanceContact => 'Questions: ';

  @override
  String get sessionTitle => 'Log in again';

  @override
  String get sessionBody =>
      'Your session ended to protect your account. Enter your number and we will send a new code.';

  @override
  String get sessionLogin => 'Log in';

  @override
  String get homeMorning => 'Good morning';

  @override
  String get homeEvening => 'Good evening';

  @override
  String get homeAll => 'All';

  @override
  String get homeBestSellers => 'Most ordered';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeDeal => 'Today\'s deal';

  @override
  String get searchHint => 'Search for a product or store';

  @override
  String get soldOut => 'Sold out';

  @override
  String get browseEmpty => 'No products here yet';

  @override
  String get searchRecent => 'Recent searches:';

  @override
  String searchCount(int count) {
    return '$count results';
  }

  @override
  String get searchNoResults => 'No results';

  @override
  String get searchNoResultsBody => 'Try another word or check the spelling.';

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String get vendorOpen => 'Open';

  @override
  String get vendorClosed => 'Closed';

  @override
  String vendorPrep(int minutes) {
    return '$minutes min prep';
  }

  @override
  String get viewCart => 'View cart';

  @override
  String cartCount(int count) {
    return '$count items';
  }

  @override
  String get productTitle => 'Product details';

  @override
  String get productAvailable => 'In stock';

  @override
  String get productUnavailable => 'Unavailable';

  @override
  String get productRequired => '(required)';

  @override
  String get productDescription => 'Description';

  @override
  String get addToCart => 'Add to cart';

  @override
  String addToCartPrice(String price) {
    return 'Add to cart · $price';
  }

  @override
  String get otherStoreTitle => 'Empty your cart?';

  @override
  String get otherStoreBody =>
      'Your cart has products from another store, and an order comes from one store. Empty it and add this product?';

  @override
  String get otherStoreConfirm => 'Empty and add';

  @override
  String get commonKeepCart => 'Keep my cart';

  @override
  String get cartLimitTitle => 'Limit reached';

  @override
  String get cartLimitBody => 'You can\'t add more to the cart.';

  @override
  String get commonOk => 'OK';

  @override
  String get cartTitle => 'My cart';

  @override
  String get cartClearTitle => 'Empty your cart?';

  @override
  String get cartClearBody => 'All products will be removed from your cart.';

  @override
  String get cartClearConfirm => 'Empty cart';

  @override
  String get cartCompareTitle => 'Compare your cart with nearby stores';

  @override
  String get cartCompareBody =>
      'We\'ll check if a store that delivers to you is cheaper';

  @override
  String get cartTotal => 'Total';

  @override
  String get cartDelivery => 'Delivery';

  @override
  String get cartAtCheckout => 'Calculated at checkout';

  @override
  String get cartContinue => 'Continue';

  @override
  String cartContinueTotal(String total) {
    return 'Continue · $total';
  }

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyBody =>
      'Add products from stores in your area, and Barq compares prices before you order.';

  @override
  String get cartBrowse => 'Browse stores';

  @override
  String get compareTitle => 'Best basket';

  @override
  String compareZone(String zone) {
    return 'Stores in your area: $zone';
  }

  @override
  String compareBody(int count) {
    return 'We compared your cart items ($count) with the stores that deliver to your address only.';
  }

  @override
  String get compareBest => 'Best price';

  @override
  String get compareForItems => 'for products';

  @override
  String compareAvailable(int available, int total) {
    return '$available of $total available';
  }

  @override
  String get compareOthers => 'Other stores in your area';

  @override
  String get compareNote => 'Prices exclude delivery, shown in the next step';

  @override
  String comparePickBest(String price) {
    return 'Choose best · $price';
  }

  @override
  String comparePick(String store, String price) {
    return 'Choose $store · $price';
  }

  @override
  String compareMissing(int count, String detail) {
    return '$count missing · $detail';
  }

  @override
  String get compareNotEnough => 'Not enough stock';

  @override
  String get noStoreBadge => 'Items missing';

  @override
  String get noStoreTitle => 'No store has your whole cart';

  @override
  String noStoreBody(String zone) {
    return 'All stores in $zone are missing an item or more. Pick a store to continue with what\'s available, or edit your cart.';
  }

  @override
  String noStoreContinue(String store) {
    return 'Continue with $store';
  }

  @override
  String get noStoreEdit => 'Edit cart';

  @override
  String get noStoresTitle => 'No stores deliver to your address yet';

  @override
  String get outOfZoneTitle => 'We don\'t deliver here yet';

  @override
  String get outOfZoneBody =>
      'Your address is outside Barq\'s service areas. Choose another address inside the delivery area.';

  @override
  String get outOfZoneChange => 'Change address';

  @override
  String get noAddressTitle => 'You have no delivery address';

  @override
  String get noAddressBody =>
      'Add your address so we can compare your cart with stores that deliver to you.';

  @override
  String get noAddressAdd => 'Add address';

  @override
  String get checkoutTitle => 'Confirm order';
}
