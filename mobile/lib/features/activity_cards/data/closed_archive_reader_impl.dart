import '../../../core/database/cupid_database.dart';
import '../../../core/database/daos/activity_card_dao.dart';
import '../../../core/database/daos/chapter_closure_dao.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../domain/activity_card.dart';
import '../domain/activity_card_repository.dart';
import 'activity_card_repository_impl.dart';

/// Drift-backed [ClosedArchiveReader].
///
/// It reads the ledger through [ChapterClosureDao] rather than through
/// `ChapterClosureGate` so that `features/activity_cards/` keeps depending only
/// on `core/`, the same direction every other reader in this feature points.
class ClosedArchiveReaderImpl implements ClosedArchiveReader {
  ClosedArchiveReaderImpl({
    required ActivityCardDao dao,
    required ChapterClosureDao closureDao,
    required BackendUserIdStore ownerKeyStore,
  })  : _dao = dao,
        _closureDao = closureDao,
        _ownerKeyStore = ownerKeyStore;

  final ActivityCardDao _dao;
  final ChapterClosureDao _closureDao;
  final BackendUserIdStore _ownerKeyStore;

  @override
  Future<bool> hasAnyClosure() async => await _closureDao.closureCount() > 0;

  @override
  Future<List<ActivityCard>> closedCards({
    required int limit,
    int offset = 0,
  }) async {
    final String ownerKey = await _requireOwnerKey();
    final List<ActivityCardRow> rows = await _dao.closedCards(
      ownerKey: ownerKey,
      limit: limit,
      offset: offset,
    );
    return rows.map(activityCardFromRow).toList(growable: false);
  }

  @override
  Future<int> closedCardCount() async =>
      _dao.closedCardCount(await _requireOwnerKey());

  Future<String> _requireOwnerKey() async {
    final String? ownerKey = await _ownerKeyStore.resolve();
    if (ownerKey == null || ownerKey.isEmpty) {
      throw StateError(
        'ClosedArchiveReader used before a backend user id resolved.',
      );
    }
    return ownerKey;
  }
}
