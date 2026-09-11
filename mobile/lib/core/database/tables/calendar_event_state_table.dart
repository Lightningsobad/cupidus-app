import 'package:drift/drift.dart';

/// Trạng thái xử lý của một sự kiện lịch trong gói nội dung mồi chuyện.
///
/// Bảng chỉ ghi *người dùng đã làm gì với gợi ý* — không có cột đếm số lần
/// hiện, không có mốc thời gian hành vi của người kia (R-1b / AC-12 / AC-25).
/// Khoá chính gộp (`ownerKey`, `eventId`) làm việc ghi lại cùng một sự kiện
/// trở thành cập nhật tại chỗ thay vì dòng thứ hai.
@DataClassName('CalendarEventStateRow')
class CalendarEventState extends Table {
  @override
  String get tableName => 'calendar_event_state';

  TextColumn get ownerKey => text()();

  TextColumn get eventId => text()();

  /// `converted` | `dismissed`.
  TextColumn get state => text()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ownerKey, eventId};
}
