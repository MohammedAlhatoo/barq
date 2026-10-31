/// Turns what the user typed next to the +970 pill into the server format.
abstract final class PhoneNumber {
  static const _countryCode = '+970';
  static const minDigits = 9;

  /// The digits left for the local part, so the full number stays within the
  /// server limit of 15 digits. One more is allowed for the leading 0.
  static const maxDigits = 13;

  /// "0599123456" and "599123456" both become "+970599123456".
  static String normalize(String typed) =>
      '$_countryCode${typed.replaceFirst(RegExp(r'^0+'), '')}';

  static bool isValid(String typed) =>
      RegExp('^[0-9]{$minDigits,$maxDigits}\$').hasMatch(typed) &&
      RegExp(r'^\+?[0-9]{9,15}$').hasMatch(normalize(typed));

  /// "+970599123456" becomes "059 912 3456", as the design shows it.
  static String display(String phone) {
    final local = '0${phone.replaceFirst(_countryCode, '')}';
    if (local.length != 10) return phone;
    return '${local.substring(0, 3)} ${local.substring(3, 6)} '
        '${local.substring(6)}';
  }
}
