/// Immutable read model over the `GET /users/me` response
/// (`backend/src/modules/users/entities/user.entity.ts`,
/// `coding-plan/master-plan.md` §6.2 P1). Deliberately excludes `role`: it is
/// an admin-only field and mapping it here would make it reachable from
/// account UI, which AC4 forbids.
class CupidProfile {
  const CupidProfile({
    required this.id,
    required this.email,
    required this.language,
    required this.vowTaken,
    required this.isGhostModeEnabled,
    this.displayName,
    this.photoUrl,
    this.birthday,
    this.relationshipStartDate,
    this.zodiacSign,
    this.partnerId,
    this.partnerDisplayName,
    this.partnerPhotoUrl,
    this.partnerVowTaken = false,
    this.coupleType,
  });

  factory CupidProfile.fromJson(Map<String, dynamic> json) {
    return CupidProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      language: json['language'] as String? ?? 'vi',
      vowTaken: json['vowTaken'] as bool? ?? false,
      isGhostModeEnabled: json['isGhostModeEnabled'] as bool? ?? true,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      birthday: _parseDate(json['birthday']),
      relationshipStartDate: _parseDate(json['relationshipStartDate']),
      zodiacSign: json['zodiacSign'] as String?,
      partnerId: json['partnerId'] as String?,
      partnerDisplayName: json['partnerDisplayName'] as String?,
      partnerPhotoUrl: json['partnerPhotoUrl'] as String?,
      partnerVowTaken: json['partnerVowTaken'] as bool? ?? false,
      coupleType: json['coupleType'] as String?,
    );
  }

  final String id;
  final String email;
  final String language;
  final bool vowTaken;
  final bool isGhostModeEnabled;
  final String? displayName;
  final String? photoUrl;
  final DateTime? birthday;
  final DateTime? relationshipStartDate;
  final String? zodiacSign;
  final String? partnerId;
  final String? partnerDisplayName;
  final String? partnerPhotoUrl;
  final bool partnerVowTaken;
  final String? coupleType;

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
