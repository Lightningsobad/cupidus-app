part of 'dream_jar.dart';

class Contribution {
  const Contribution({
    required this.id,
    required this.dreamJarId,
    required this.userId,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String dreamJarId;
  final String userId;
  final num amount;
  final String? note;
  final DateTime createdAt;

  factory Contribution.fromJson(Map<String, dynamic> json) => Contribution(
    id: json['id'] as String,
    dreamJarId: json['dreamJarId'] as String,
    userId: json['userId'] as String,
    amount: _parseAmount(json['amount']),
    note: json['note'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
