import 'package:shared_preferences/shared_preferences.dart';

/// Mốc mở app gần nhất của chặng 1 (`contract-summary.md` §2).
///
/// Không có getter nào trả `DateTime`, `Duration`, hay số ngày: AC-20 cấm mọi
/// API public mang giá trị đó ra khỏi lớp này, nên câu hỏi duy nhất hỏi được là
/// câu hỏi boolean [absentAtLeast]. Chỉ một khoá duy nhất được ghi — không đếm
/// lần mở app, không lưu lịch sử các lần vắng (BR-7).
class Stage1LastOpenedStore {
  Stage1LastOpenedStore({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  static const String preferenceKey = 'req016.last_opened_at';

  final Future<SharedPreferences> Function() _preferences;

  /// `false` khi chưa từng ghi mốc nào, để lần cài mới không bị coi là vắng mặt.
  Future<bool> absentAtLeast(Duration threshold, {required DateTime now}) async {
    final SharedPreferences prefs = await _preferences();
    final int? storedEpochMs = prefs.getInt(preferenceKey);
    if (storedEpochMs == null) {
      return false;
    }
    final DateTime last = DateTime.fromMillisecondsSinceEpoch(storedEpochMs);
    return now.difference(last) >= threshold;
  }

  Future<void> recordOpened(DateTime now) async {
    final SharedPreferences prefs = await _preferences();
    await prefs.setInt(preferenceKey, now.millisecondsSinceEpoch);
  }
}
