/// The fields of the `User` schema that the account screens use.
class Profile {
  const Profile({required this.name, required this.phone, this.avatarUrl});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    name: json['name'] as String?,
    phone: json['phone'] as String,
    avatarUrl: json['avatar_url'] as String?,
  );

  final String? name;
  final String phone;
  final String? avatarUrl;

  /// The first letter of the name, for the avatar.
  String get initial {
    final text = name?.trim() ?? '';
    return text.isEmpty ? '' : String.fromCharCode(text.runes.first);
  }
}
