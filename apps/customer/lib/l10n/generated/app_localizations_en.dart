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
  String get homeNearStores => 'Nearby stores';

  @override
  String get homeStores => 'Stores';

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
  String compareAvailable(int available, int total) {
    return '$available of $total available';
  }

  @override
  String get compareOthers => 'Other stores in your area';

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

  @override
  String get compareWithDelivery => 'Delivery included';

  @override
  String get compareDeliveryLater => 'Delivery calculated later';

  @override
  String scopeShoppingFrom(String store) {
    return 'Shopping from: $store';
  }

  @override
  String get scopeCartStore => 'your cart\'s store';

  @override
  String get scopeAllStores => 'All stores';

  @override
  String get scopeOnlyMine => 'My cart\'s store only';

  @override
  String get vendorsTitle => 'All stores';

  @override
  String get vendorsOpenNow => 'Open now';

  @override
  String get vendorsEmpty => 'No stores right now';

  @override
  String get vendorNew => 'New';

  @override
  String get vendorCategoryGrocery => 'Grocery';

  @override
  String get vendorCallFailed => 'Couldn\'t start the call';

  @override
  String get cartWithDelivery => 'Total with delivery';

  @override
  String get compareCurrentCart => 'Your current cart';

  @override
  String get compareCurrentIsBest =>
      'Your current store is the cheapest of the nearest stores';

  @override
  String get compareKeepCart => 'Continue with my cart';

  @override
  String compareSave(String price) {
    return 'Save $price';
  }

  @override
  String get accountTitle => 'My account';

  @override
  String get accountOrders => 'Orders';

  @override
  String get accountAddresses => 'Addresses';

  @override
  String get accountNoName => 'No name';

  @override
  String get accountMyAddresses => 'My addresses';

  @override
  String get accountNotifications => 'Notifications';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountLanguageName => 'English';

  @override
  String get accountHelp => 'Help & support';

  @override
  String get accountLogout => 'Log out';

  @override
  String get accountLogoutBody =>
      'Your cart and searches will be removed from this phone.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileName => 'Name';

  @override
  String get profilePhone => 'Phone number';

  @override
  String get profilePhoneHelper => 'To change your number, contact support';

  @override
  String get profileLanguage => 'App language';

  @override
  String get profileAddressesBody =>
      'Your area comes from the address location';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileDelete => 'Delete account';

  @override
  String get deleteTitle => 'Delete your account for good?';

  @override
  String get deleteBody => 'This cannot be undone.';

  @override
  String get deleteNameAddresses =>
      'Your name and saved addresses will be deleted';

  @override
  String get deleteOrders => 'You will no longer see your past orders';

  @override
  String get deleteActive => 'Running orders must finish first';

  @override
  String get deleteUnderstand =>
      'I understand that deleting my account is final';

  @override
  String get deleteConfirm => 'Delete account';

  @override
  String get addressesTitle => 'My addresses';

  @override
  String get addressesDefault => 'Default';

  @override
  String get addressesAdd => 'Add a new address';

  @override
  String get addressesEmpty => 'You have no saved addresses';

  @override
  String get addressesEmptyBody =>
      'Add your address so we can show the stores that deliver to you.';

  @override
  String get addressDeleteTitle => 'Delete this address?';

  @override
  String get addressDeleteBody => 'Past orders keep their own copy.';

  @override
  String get addressDeleteConfirm => 'Delete address';

  @override
  String get addressUnnamed => 'Address';

  @override
  String get addressPickerTitle => 'Choose a delivery address';

  @override
  String get addressFormTitle => 'Address details';

  @override
  String get addressMapHint => 'Move the map to set the location';

  @override
  String get addressHome => 'Home';

  @override
  String get addressWork => 'Work';

  @override
  String get addressOther => 'Other';

  @override
  String get addressOtherHint => 'Address name (e.g. Parents\' home)';

  @override
  String get addressDetailsHint => 'Street, landmark, building, floor';

  @override
  String get addressZoneUnknown => 'We check the area when you save';

  @override
  String get addressZoneLabel => 'Address location';

  @override
  String get addressInZone => 'In service area';

  @override
  String get addressOutOfZone => 'Out of service area';

  @override
  String get addressMakeDefault => 'Make this my default address';

  @override
  String get addressSave => 'Save address';

  @override
  String get addressLocateFailed =>
      'Could not find your location. Move the map by hand.';

  @override
  String get addressMapCredit => '© OpenStreetMap';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get checkoutNoAddressBody =>
      'Add your address so we can price the order and delivery.';

  @override
  String get checkoutCash => 'Cash on delivery';

  @override
  String get checkoutSubstitutions => 'If an item runs out';

  @override
  String get subCallMe => 'Call me';

  @override
  String get subSimilar => 'Similar item';

  @override
  String get subSkip => 'Remove it';

  @override
  String get checkoutCouponHint => 'Discount code';

  @override
  String get checkoutCouponApply => 'Apply';

  @override
  String get checkoutCouponApplied => 'Applied';

  @override
  String get checkoutNoteHint => 'Note for the store or driver';

  @override
  String get checkoutTotal => 'Total';

  @override
  String get checkoutChange => 'Change';

  @override
  String get checkoutPriceHeld => 'Price reserved for';

  @override
  String get quoteExpiredTitle => 'The price has expired';

  @override
  String get quoteExpiredChanged =>
      'We asked for a new price, and these changed:';

  @override
  String get quoteExpiredSame =>
      'We asked for a new price, and nothing changed.';

  @override
  String get quoteExpiredNewTotal => 'New total';

  @override
  String get quoteExpiredContinue => 'Continue with the new price';

  @override
  String get quoteExpiredReview => 'Review cart';

  @override
  String get offerTitle => 'Price offer';

  @override
  String get offerNotReadyTitle => 'The store has not priced your order yet';

  @override
  String get offerNotReadyBody => 'The offer will show here once it is ready.';

  @override
  String get offerPricedTitle => 'Your order is priced';

  @override
  String get offerPricedBody => 'Weighed items are priced after preparation';

  @override
  String get offerUnavailable => 'Unavailable';

  @override
  String get offerItemsTotal => 'Items';

  @override
  String get offerDelivery => 'Delivery';

  @override
  String get offerActionRefused =>
      'We could not do that. Try again or contact support.';

  @override
  String get offerApprove => 'Approve the offer';

  @override
  String get offerExpiredPill => 'Time is up';

  @override
  String get offerExpiredTitle => 'The offer has expired';

  @override
  String get offerExpiredBodyPlain =>
      'The offer was not approved, so the order was cancelled. Nothing was charged.';

  @override
  String get offerExpiredReorder => 'Order the same cart again';

  @override
  String get offerExpiredHome => 'Back to home';

  @override
  String get reorderReplaceTitle => 'You already have a cart';

  @override
  String get reorderReplaceBody =>
      'Ordering again will replace your current cart.';

  @override
  String get reorderReplaceConfirm => 'Replace cart';

  @override
  String get orderSandboxAdvance => 'Test: next store step';

  @override
  String checkoutConfirm(String total) {
    return 'Confirm order · $total';
  }

  @override
  String checkoutDistance(String km) {
    return '$km km';
  }

  @override
  String quoteExpiredPassed(int minutes) {
    return '$minutes minutes passed since the price';
  }

  @override
  String lineWithQty(String name, int qty) {
    return '$name × $qty';
  }

  @override
  String offerUnitPrice(String price) {
    return '$price per unit';
  }

  @override
  String offerSubstitute(String name, String price) {
    return 'Substitute: $name · $price per unit';
  }

  @override
  String offerStoreNote(String note) {
    return 'Store note: $note';
  }

  @override
  String offerDeadline(int minutes) {
    return 'If you do not approve within $minutes minutes, the order is cancelled.';
  }

  @override
  String offerExpiredBody(int minutes) {
    return 'The offer was not approved within $minutes minutes, so the order was cancelled. Nothing was charged.';
  }

  @override
  String offerExpiredSummary(int count, String total) {
    return '$count items · the total was $total';
  }

  @override
  String orderTitle(String code) {
    return 'Order $code';
  }

  @override
  String reorderMissing(int count) {
    return '$count of the items are no longer in the store.';
  }

  @override
  String orderWaitingBody(String store) {
    return 'We sent your order to $store and will keep you posted.';
  }

  @override
  String get orderWaitingBodyPlain =>
      'We received your order and will keep you posted.';

  @override
  String get orderCancelledBody =>
      'This order was cancelled. Nothing was charged.';

  @override
  String get orderNow => 'Now';

  @override
  String get orderPhotoNote =>
      'At delivery, the driver takes a photo of the order at your door as proof.';

  @override
  String get trackingPhotoNote =>
      'The driver photographs the order at your door as proof of delivery';

  @override
  String trackingEta(int minutes) {
    return 'Arrives in $minutes min';
  }

  @override
  String get trackingNoDriver =>
      'The driver will show here once the order is accepted.';

  @override
  String get trackingShare => 'Share tracking link';

  @override
  String get trackingCancel => 'Cancel order';

  @override
  String get shareLinkBody =>
      'Anyone with this link can follow the order without logging in.';

  @override
  String get shareLinkSend => 'Share link';

  @override
  String get shareLinkStop => 'Stop the link';

  @override
  String get mapCredit => '© OpenStreetMap';

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
  String get cancelTitle => 'Cancel the order?';

  @override
  String get cancelBody =>
      'You can cancel before the driver picks up the order';

  @override
  String get cancelWhy => 'Why do you want to cancel?';

  @override
  String get cancelConfirm => 'Confirm cancellation';

  @override
  String get cancelBack => 'Go back';

  @override
  String get rateDeliveredTitle => 'Your order arrived, enjoy!';

  @override
  String rateDeliveredAt(String time) {
    return 'Delivered $time';
  }

  @override
  String ratePaid(String total) {
    return 'You paid $total';
  }

  @override
  String rateSaved(String amount) {
    return 'You saved $amount';
  }

  @override
  String get rateTitle => 'Rate your experience';

  @override
  String get rateDriver => 'Driver';

  @override
  String get rateStore => 'Store';

  @override
  String get rateComment => 'Write a comment (optional)';

  @override
  String get rateSend => 'Send rating';

  @override
  String get rateSkip => 'Skip';

  @override
  String get ordersTabCurrent => 'Current';

  @override
  String ordersTabCurrentCount(int count) {
    return 'Current ($count)';
  }

  @override
  String get ordersTabPast => 'Past';

  @override
  String get ordersEmptyCurrent => 'You have no current orders';

  @override
  String get ordersEmptyPast => 'You have no past orders';

  @override
  String ordersItems(int count, String total) {
    return '$count items · $total';
  }

  @override
  String get ordersFollow => 'Follow order';

  @override
  String get ordersReorder => 'Reorder';

  @override
  String get receiptTitle => 'Receipt';

  @override
  String get receiptPaidCash => 'Paid in cash';

  @override
  String get receiptCashOnDelivery => 'Cash on delivery';

  @override
  String get receiptTotal => 'Total';

  @override
  String get receiptReorder => 'Order the same again';

  @override
  String receiptShareText(String code, String total) {
    return 'Receipt for order $code: $total';
  }

  @override
  String get notificationsReadAll => 'Read all';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get timeNow => 'Just now';

  @override
  String timeMinutes(int count) {
    return '$count min ago';
  }

  @override
  String timeHours(int count) {
    return '$count h ago';
  }

  @override
  String timeDays(int count) {
    return '$count d ago';
  }
}
