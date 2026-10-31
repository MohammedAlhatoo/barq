/// Answer of `POST /auth/send-otp`. Passed from the phone to the OTP screen.
class OtpTicket {
  const OtpTicket({
    required this.phone,
    required this.expiresIn,
    required this.length,
  });

  factory OtpTicket.fromJson(Map<String, dynamic> json) => OtpTicket(
    phone: json['phone'] as String,
    expiresIn: json['expires_in'] as int,
    length: json['length'] as int,
  );

  final String phone;

  /// Seconds the code stays valid. Also the wait before asking for a new one.
  final int expiresIn;

  /// How many digits the code has.
  final int length;
}

/// Answer of `POST /auth/verify-otp`.
class AuthSession {
  const AuthSession({
    required this.token,
    required this.isNewUser,
    required this.name,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    token: json['token'] as String,
    isNewUser: json['is_new_user'] as bool,
    name: (json['user'] as Map)['name'] as String?,
  );

  final String token;
  final bool isNewUser;
  final String? name;

  /// True when the welcome screen still has to ask for the name.
  bool get needsProfile => isNewUser || (name?.trim().isEmpty ?? true);
}

/// The `Address` schema.
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    this.details,
    this.isDefault = false,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] as int,
    label: json['label'] as String?,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    details: json['details'] as String?,
    isDefault: json['is_default'] as bool? ?? false,
  );

  final int id;
  final String? label;
  final double lat;
  final double lng;
  final String? details;
  final bool isDefault;
}
