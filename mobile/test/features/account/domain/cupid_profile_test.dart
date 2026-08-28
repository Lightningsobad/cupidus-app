import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CupidProfile.fromJson', () {
    // Shape mirrors the real `GET /users/me` response, i.e. the serialized
    // `backend/src/modules/users/entities/user.entity.ts` row -- including
    // `role` and `firebaseUid`, which the model must ignore (AC4).
    final realPayload = <String, dynamic>{
      'id': 'user-1',
      'email': 'alex@example.com',
      'firebaseUid': 'firebase-uid-1',
      'displayName': 'Alex',
      'photoUrl': 'https://api.example.com/uploads/alex.jpg',
      'birthday': '1996-05-15',
      'relationshipStartDate': '2023-02-14',
      'zodiacSign': 'Taurus',
      'language': 'vi',
      'partnerId': 'user-2',
      'partnerDisplayName': 'Linh',
      'partnerPhotoUrl': 'https://api.example.com/uploads/linh.jpg',
      'coupleType': 'DATING',
      'vowTaken': true,
      'isGhostModeEnabled': false,
      'role': 'admin',
      'createdAt': '2023-01-01T00:00:00.000Z',
      'updatedAt': '2023-01-01T00:00:00.000Z',
    };

    test('maps every profile field', () {
      final profile = CupidProfile.fromJson(realPayload);

      expect(profile.id, 'user-1');
      expect(profile.email, 'alex@example.com');
      expect(profile.displayName, 'Alex');
      expect(profile.photoUrl, 'https://api.example.com/uploads/alex.jpg');
      expect(profile.birthday, DateTime.parse('1996-05-15'));
      expect(
        profile.relationshipStartDate,
        DateTime.parse('2023-02-14'),
      );
      expect(profile.zodiacSign, 'Taurus');
      expect(profile.language, 'vi');
      expect(profile.partnerId, 'user-2');
      expect(profile.partnerDisplayName, 'Linh');
      expect(profile.partnerPhotoUrl, 'https://api.example.com/uploads/linh.jpg');
      expect(profile.coupleType, 'DATING');
      expect(profile.vowTaken, true);
      expect(profile.isGhostModeEnabled, false);
    });

    test('tolerates null optional fields', () {
      final profile = CupidProfile.fromJson(<String, dynamic>{
        'id': 'user-1',
        'email': 'alex@example.com',
        'displayName': null,
        'photoUrl': null,
        'birthday': null,
        'relationshipStartDate': null,
        'zodiacSign': null,
        'language': 'vi',
        'partnerId': null,
        'partnerDisplayName': null,
        'coupleType': null,
        'vowTaken': false,
        'isGhostModeEnabled': true,
      });

      expect(profile.displayName, isNull);
      expect(profile.birthday, isNull);
      expect(profile.zodiacSign, isNull);
      expect(profile.partnerDisplayName, isNull);
    });

    // A backend that drops or renames `partnerDisplayName` must degrade to
    // AC3's self-name-only title, not throw on the profile read.
    test('an absent partnerDisplayName key reads as null', () {
      final profile = CupidProfile.fromJson(<String, dynamic>{
        'id': 'user-1',
        'email': 'alex@example.com',
        'displayName': 'Alex',
        'language': 'vi',
        'partnerId': 'user-2',
        'vowTaken': false,
        'isGhostModeEnabled': true,
      });

      expect(profile.partnerDisplayName, isNull);
      expect(profile.displayName, 'Alex');
    });
  });
}
