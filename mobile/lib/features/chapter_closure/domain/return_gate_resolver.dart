import '../data/stage1_last_opened_store.dart';

/// Ngưỡng vắng mặt duy nhất của chặng 1 (`contract-summary.md` §2, AC-19).
///
/// Một hằng số, một bậc. Không có bậc thứ hai, không leo thang theo thời gian.
const Duration kReturnAbsenceThreshold = Duration(days: 30);

/// Quyết định màn quay lại có hiện hay không.
///
/// Toàn bộ bề mặt public trả `bool` hoặc `void`: số ngày vắng, mốc mở app trước
/// đó, và `Duration` so sánh đều không rời khỏi lớp này (AC-19, AC-20). Điều
/// kiện duy nhất là sự vắng mặt của chính người dùng — trạng thái thẻ, việc bạn
/// đời chưa vào, hay bất cứ tín hiệu nào khác đều không tham gia (AC-23).
class ReturnGateResolver {
  ReturnGateResolver({
    required Stage1LastOpenedStore store,
    DateTime Function() clock = DateTime.now,
  }) : _store = store,
       _clock = clock;

  final Stage1LastOpenedStore _store;
  final DateTime Function() _clock;

  Future<bool> shouldShow() {
    return _store.absentAtLeast(kReturnAbsenceThreshold, now: _clock());
  }

  Future<void> markOpened() => _store.recordOpened(_clock());
}
