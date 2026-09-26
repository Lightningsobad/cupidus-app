import '../../../core/database/cupid_database.dart';

/// Điều người dùng đã làm với một gợi ý sự kiện lịch.
enum CalendarEventHandledState {
  /// Đã biến gợi ý thành một thẻ hoạt động.
  converted('converted'),

  /// Đã bỏ qua gợi ý.
  dismissed('dismissed');

  const CalendarEventHandledState(this.wireValue);

  final String wireValue;

  static CalendarEventHandledState? fromWireValue(String value) {
    for (final CalendarEventHandledState state
        in CalendarEventHandledState.values) {
      if (state.wireValue == value) {
        return state;
      }
    }
    return null;
  }
}

/// Đọc/ghi trạng thái xử lý sự kiện lịch cho một `ownerKey`.
///
/// Mọi truy vấn đều lọc theo `ownerKey`: không có đường đọc không lọc, vì một
/// truy vấn quên lọc sẽ để người dùng thứ hai trên cùng thiết bị thấy trạng
/// thái của người thứ nhất.
class CalendarEventStateRepository {
  CalendarEventStateRepository(this._db);

  final CupidDatabase _db;

  /// Id của những sự kiện đã được xử lý (chuyển thẻ hoặc bỏ qua).
  Future<Set<String>> handledEventIds(String ownerKey) async {
    final List<CalendarEventStateRow> rows =
        await (_db.select(_db.calendarEventState)
              ..where((t) => t.ownerKey.equals(ownerKey)))
            .get();
    return rows.map((row) => row.eventId).toSet();
  }

  /// Ghi đè trạng thái của một sự kiện. Khoá chính gộp làm lần ghi thứ hai cho
  /// cùng `eventId` trở thành cập nhật tại chỗ, không sinh dòng mới.
  Future<void> markHandled({
    required String ownerKey,
    required String eventId,
    required CalendarEventHandledState state,
    DateTime? updatedAt,
  }) =>
      _db.into(_db.calendarEventState).insertOnConflictUpdate(
            CalendarEventStateCompanion.insert(
              ownerKey: ownerKey,
              eventId: eventId,
              state: state.wireValue,
              updatedAt: updatedAt ?? DateTime.now(),
            ),
          );
}
