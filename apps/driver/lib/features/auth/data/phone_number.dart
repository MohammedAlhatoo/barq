/// Turns what the driver typed next to the +970 pill into the server format.
///
/// Driver accounts are saved as "0599…": login with "+970599…" is refused,
/// unlike the customer login.
abstract final class PhoneNumber {
  static const minDigits = 9;
  static const maxDigits = 10;

  /// "599123456" and "0599123456" both become "0599123456".
  static String normalize(String typed) =>
      typed.startsWith('0') ? typed : '0$typed';

  static bool isValid(String typed) =>
      RegExp('^[0-9]{$minDigits,$maxDigits}\$').hasMatch(typed);
}
