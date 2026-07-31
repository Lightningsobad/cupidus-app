import 'pet_mood.dart';

/// The three adoptable species, matching `PetSpecies` in
/// `backend/src/modules/pets/entities/pet.entity.ts` exactly.
enum PetSpecies {
  cat,
  dog,
  bunny;

  static PetSpecies fromJson(String value) => switch (value) {
        'cat' => PetSpecies.cat,
        'dog' => PetSpecies.dog,
        'bunny' => PetSpecies.bunny,
        _ => throw FormatException('Unknown pet species: $value'),
      };

  /// The backend enum string for this species (`entities/pet.entity.ts`).
  String get wireValue => name;
}

/// The couple's pet row, mirroring `GET /pets` /
/// `backend/src/modules/pets/entities/pet.entity.ts`.
class Pet {
  const Pet({
    required this.id,
    required this.coupleId,
    required this.species,
    required this.name,
    required this.happiness,
    required this.level,
    required this.totalInteractions,
    required this.lastInteraction,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: json['id'] as String,
        coupleId: json['coupleId'] as String,
        species: PetSpecies.fromJson(json['species'] as String),
        name: json['name'] as String,
        happiness: json['happiness'] as int,
        level: json['level'] as int,
        totalInteractions: json['totalInteractions'] as int,
        lastInteraction: json['lastInteraction'] == null
            ? null
            : DateTime.parse(json['lastInteraction'] as String),
      );

  final String id;
  final String coupleId;
  final PetSpecies species;
  final String name;
  final int happiness;
  final int level;
  final int totalInteractions;
  final DateTime? lastInteraction;
}

/// The derived view from `GET /pets/status`
/// (`pets.service.ts` `getStatus`).
class PetStatus {
  const PetStatus({
    required this.pet,
    required this.mood,
    required this.decayedHappiness,
    required this.milestone,
    required this.nextMilestone,
  });

  factory PetStatus.fromJson(Map<String, dynamic> json) => PetStatus(
        pet: Pet.fromJson(json['pet'] as Map<String, dynamic>),
        mood: PetMood.fromWire(json['mood'] as String?),
        decayedHappiness: json['decayedHappiness'] as int,
        milestone: json['milestone'] as String?,
        nextMilestone: json['nextMilestone'] as int,
      );

  final Pet pet;
  final PetMood mood;
  final int decayedHappiness;

  /// Raw backend copy (English-only, e.g. `"50 interactions!"`).
  /// Display-forbidden: never render this directly. Use
  /// [interactionsTowardNextMilestone] to build a localized caption instead.
  final String? milestone;
  final int nextMilestone;

  /// Progress within the current level, per `pets.service.ts` level math
  /// (`floor(totalInteractions / 50) + 1`). Do not reimplement level math;
  /// this only derives the fractional remainder for a progress bar.
  double get levelProgress => (pet.totalInteractions % 50) / 50;

  /// `(totalInteractions, nextMilestone)` for a localized
  /// "{totalInteractions}/{nextMilestone}" caption. Do not reimplement the
  /// backend's milestone list; this only forwards the two numbers.
  (int, int) get interactionsTowardNextMilestone =>
      (pet.totalInteractions, nextMilestone);
}

/// Whether the current user is paired, derived from `GET /users/me`. This is
/// the only reliable pairing signal for AC3 (`GET /pets` and
/// `GET /pets/status` both return an empty body for "unpaired" and for
/// "paired but no pet yet").
class PetPairing {
  const PetPairing({required this.isPaired});

  factory PetPairing.fromJson(Map<String, dynamic> json) {
    final partnerId = json['partnerId'] as String?;
    return PetPairing(isPaired: partnerId != null && partnerId.isNotEmpty);
  }

  final bool isPaired;
}
