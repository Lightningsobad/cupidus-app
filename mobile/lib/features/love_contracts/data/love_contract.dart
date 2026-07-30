/// `architecture/solution.md` §4 Boundaries And Ownership — the client
/// contract model for the frozen `love-contracts` backend (ADR-006b/ADR-006c).
/// `fromJson` must never throw: every field falls back to a defensive default
/// for a `null` body, an unknown `status`, a missing `clauses` key, or a
/// missing timestamp.
enum ContractSignStatus { unsigned, signedByMe, awaitingPartner }

class LoveContract {
  const LoveContract({
    required this.id,
    required this.clauses,
    required this.status,
    required this.signedAtRequester,
  });

  factory LoveContract.fromJson(Map<String, dynamic> json) {
    return LoveContract(
      id: json['id'] as String? ?? '',
      clauses: _clausesFromJson(json['clauses']),
      status: _statusFromJson(json['status']),
      signedAtRequester: _timestampFromJson(json['signedAtRequester']),
    );
  }

  final String id;
  final List<String> clauses;
  final ContractSignStatus status;
  final DateTime? signedAtRequester;

  static List<String> _clausesFromJson(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList(growable: false);
  }

  static ContractSignStatus _statusFromJson(Object? raw) {
    switch (raw) {
      case 'signed_requester':
        return ContractSignStatus.signedByMe;
      case 'signed_partner':
        return ContractSignStatus.awaitingPartner;
      case 'created':
      default:
        return ContractSignStatus.unsigned;
    }
  }

  static DateTime? _timestampFromJson(Object? raw) {
    if (raw is! String) return null;
    return DateTime.tryParse(raw);
  }
}
