import 'pet_mood.dart';

/// The six adoptable species in the Cupid design system (`Cupid Screens.dc.html`,
/// `Pet Sprite.dc.html`, and `backend/src/modules/pets/entities/pet.entity.ts`).
enum PetSpecies {
  cat,
  dog,
  bunny,
  bear,
  chick,
  panda;

  static PetSpecies fromJson(String value) => switch (value.toLowerCase()) {
        'cat' || 'bun' => PetSpecies.cat,
        'dog' || 'shiba' || 'bo' => PetSpecies.dog,
        'bunny' || 'sua' => PetSpecies.bunny,
        'bear' || 'mochi' => PetSpecies.bear,
        'chick' || 'xoai' => PetSpecies.chick,
        'panda' || 'kem' => PetSpecies.panda,
        _ => throw FormatException('Unknown pet species: $value'),
      };

  /// The backend enum string for this species (`entities/pet.entity.ts`).
  String get wireValue => name;

  /// The character ID in the design canvas (`PETS` array in `Cupid Screens.dc.html`).
  String get characterId => switch (this) {
        PetSpecies.cat => 'bun',
        PetSpecies.dog => 'bo',
        PetSpecies.bunny => 'sua',
        PetSpecies.bear => 'mochi',
        PetSpecies.chick => 'xoai',
        PetSpecies.panda => 'kem',
      };

  /// The canonical character name from the design system.
  String get defaultName => switch (this) {
        PetSpecies.cat => 'Bún',
        PetSpecies.dog => 'Bơ',
        PetSpecies.bunny => 'Sữa',
        PetSpecies.bear => 'Mochi',
        PetSpecies.chick => 'Xoài',
        PetSpecies.panda => 'Kem',
      };

  /// The kind label in Vietnamese (`Cupid Screens.dc.html`).
  String get kindVi => switch (this) {
        PetSpecies.cat => 'mèo',
        PetSpecies.dog => 'shiba',
        PetSpecies.bunny => 'thỏ',
        PetSpecies.bear => 'gấu',
        PetSpecies.chick => 'gà con',
        PetSpecies.panda => 'gấu trúc',
      };

  /// The kind label in English (`Cupid Screens.dc.html`).
  String get kindEn => switch (this) {
        PetSpecies.cat => 'cat',
        PetSpecies.dog => 'shiba',
        PetSpecies.bunny => 'bunny',
        PetSpecies.bear => 'bear',
        PetSpecies.chick => 'chick',
        PetSpecies.panda => 'panda',
      };
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
    this.streak = 0,
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
        streak: json['streak'] as int? ?? 0,
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
  final int streak;
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
    this.streak = 0,
    this.badgesCount = 1,
  });

  factory PetStatus.fromJson(Map<String, dynamic> json) => PetStatus(
        pet: Pet.fromJson(json['pet'] as Map<String, dynamic>),
        mood: PetMood.fromWire(json['mood'] as String?),
        decayedHappiness: json['decayedHappiness'] as int,
        milestone: json['milestone'] as String?,
        nextMilestone: json['nextMilestone'] as int,
        streak: json['streak'] as int? ??
            ((json['pet'] as Map<String, dynamic>?)?['streak'] as int? ?? 0),
        badgesCount: json['badgesCount'] as int? ?? 1,
      );

  final Pet pet;
  final PetMood mood;
  final int decayedHappiness;

  /// Raw backend copy (English-only, e.g. `"50 interactions!"`).
  /// Display-forbidden: never render this directly. Use
  /// [interactionsTowardNextMilestone] to build a localized caption instead.
  final String? milestone;
  final int nextMilestone;
  final int streak;
  final int badgesCount;

  /// Progress within the current level, per `pets.service.ts` level math
  /// (`floor(totalInteractions / 50) + 1`). Do not reimplement level math;
  /// this only derives the fractional remainder for a progress bar.
  double get levelProgress => (pet.totalInteractions % 50) / 50;

  /// `(totalInteractions, nextMilestone)` for a localized
  /// "{totalInteractions}/{nextMilestone}" caption. Do not reimplement the
  /// backend's milestone list; this only forwards the two numbers.
  (int, int) get interactionsTowardNextMilestone =>
      (pet.totalInteractions, nextMilestone);

  /// Formatted interaction count (e.g. 1200 -> "1.2k", 950 -> "950").
  String get formattedInteractions {
    final count = pet.totalInteractions;
    if (count >= 1000) {
      final double inK = count / 1000;
      final String formatted = inK.toStringAsFixed(1);
      return formatted.endsWith('.0') ? '${inK.toInt()}k' : '${formatted}k';
    }
    return '$count';
  }
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
