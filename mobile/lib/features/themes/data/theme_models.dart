export 'package:cupid_mobile/design_system/tokens/theme_catalog.dart';

/// State of the couple's theme ownership and sync.
class CoupleThemeState {
  const CoupleThemeState({
    required this.coupleId,
    required this.activeThemeId,
    required this.ownedThemeIds,
    required this.heartsBalance,
    this.pendingThemeId,
    this.pendingRequestedBy,
    this.pendingRequestedAt,
    this.wishlistThemeId,
    this.wishlistSavedBy,
  });

  final String coupleId;
  final String activeThemeId;
  final List<String> ownedThemeIds;
  final int heartsBalance;
  final String? pendingThemeId;
  final String? pendingRequestedBy;
  final DateTime? pendingRequestedAt;
  final String? wishlistThemeId;
  final String? wishlistSavedBy;

  bool isOwned(String themeId) => ownedThemeIds.contains(themeId);
  bool isActive(String themeId) => activeThemeId == themeId;
  bool isPending(String themeId) => pendingThemeId == themeId;

  factory CoupleThemeState.fromJson(Map<String, dynamic> json) {
    return CoupleThemeState(
      coupleId: json['coupleId'] as String? ?? '',
      activeThemeId: json['activeThemeId'] as String? ?? 'nebula',
      ownedThemeIds: (json['ownedThemeIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>['nebula'],
      heartsBalance: json['heartsBalance'] as int? ?? 1240,
      pendingThemeId: json['pendingThemeId'] as String?,
      pendingRequestedBy: json['pendingRequestedBy'] as String?,
      pendingRequestedAt: json['pendingRequestedAt'] != null
          ? DateTime.tryParse(json['pendingRequestedAt'].toString())
          : null,
      wishlistThemeId: json['wishlistThemeId'] as String?,
      wishlistSavedBy: json['wishlistSavedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coupleId': coupleId,
        'activeThemeId': activeThemeId,
        'ownedThemeIds': ownedThemeIds,
        'heartsBalance': heartsBalance,
        'pendingThemeId': pendingThemeId,
        'pendingRequestedBy': pendingRequestedBy,
        'pendingRequestedAt': pendingRequestedAt?.toIso8601String(),
        'wishlistThemeId': wishlistThemeId,
        'wishlistSavedBy': wishlistSavedBy,
      };
}
