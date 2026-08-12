/// `architecture/solution.md` §4 Boundaries And Ownership — the client
/// contract model for the viewer-aware `love-contracts` backend
/// (ADR-019c/ADR-019d). `fromJson` must never throw: every field falls back
/// to a defensive default for a `null` body, an unknown `viewerRole`, a
/// missing `clauses` key, or a missing timestamp.
enum ContractViewerRole { requester, partner }

enum ContractSignStatus { unsigned, signedByMe, partnerAlreadySigned, bothSigned }

class LoveContract {
  const LoveContract({
    required this.id,
    required this.clauses,
    required this.viewerRole,
    required this.signedAtRequester,
    required this.signedAtPartner,
  });

  factory LoveContract.fromJson(Map<String, dynamic> json) {
    return LoveContract(
      id: json['id'] as String? ?? '',
      clauses: _clausesFromJson(json['clauses']),
      viewerRole: _viewerRoleFromJson(json['viewerRole']),
      signedAtRequester: _timestampFromJson(json['signedAtRequester']),
      signedAtPartner: _timestampFromJson(json['signedAtPartner']),
    );
  }

  final String id;
  final List<String> clauses;
  final ContractViewerRole viewerRole;
  final DateTime? signedAtRequester;
  final DateTime? signedAtPartner;

  /// `contract-summary.md` §Client Derivation Rule (ADR-019c) — derived from
  /// the two timestamps relative to [viewerRole]. The raw `status` string is
  /// never read for client state.
  ContractSignStatus get status {
    final viewerSigned = viewerRole == ContractViewerRole.requester
        ? signedAtRequester
        : signedAtPartner;
    final otherSigned = viewerRole == ContractViewerRole.requester
        ? signedAtPartner
        : signedAtRequester;
    if (viewerSigned == null && otherSigned == null) {
      return ContractSignStatus.unsigned;
    }
    if (viewerSigned != null && otherSigned != null) {
      return ContractSignStatus.bothSigned;
    }
    return viewerSigned != null
        ? ContractSignStatus.signedByMe
        : ContractSignStatus.partnerAlreadySigned;
  }

  static List<String> _clausesFromJson(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList(growable: false);
  }

  static ContractViewerRole _viewerRoleFromJson(Object? raw) {
    switch (raw) {
      case 'partner':
        return ContractViewerRole.partner;
      case 'requester':
      default:
        return ContractViewerRole.requester;
    }
  }

  static DateTime? _timestampFromJson(Object? raw) {
    if (raw is! String) return null;
    return DateTime.tryParse(raw);
  }
}
