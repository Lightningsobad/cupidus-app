import 'package:cupid_mobile/features/conversation_starters/domain/event_date_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('eventDateLabel', () {
    test('mỗi thứ trong tuần ra đúng tên tiếng Việt', () {
      // 2026-08-17 là thứ Hai; bảy ngày liên tiếp phủ hết vòng tuần.
      expect(eventDateLabel('2026-08-17'), 'thứ Hai 17/08');
      expect(eventDateLabel('2026-08-18'), 'thứ Ba 18/08');
      expect(eventDateLabel('2026-08-19'), 'thứ Tư 19/08');
      expect(eventDateLabel('2026-08-20'), 'thứ Năm 20/08');
      expect(eventDateLabel('2026-08-21'), 'thứ Sáu 21/08');
      expect(eventDateLabel('2026-08-22'), 'thứ Bảy 22/08');
      expect(eventDateLabel('2026-08-23'), 'Chủ nhật 23/08');
    });

    test('ngày và tháng một chữ số vẫn có số 0 dẫn đầu', () {
      expect(eventDateLabel('2026-01-05'), 'thứ Hai 05/01');
      expect(eventDateLabel('2026-09-09'), 'thứ Tư 09/09');
    });

    test('nhãn là hàm thuần của chuỗi vào, không đọc đồng hồ', () {
      expect(eventDateLabel('2026-08-22'), eventDateLabel('2026-08-22'));
      // Tuyệt đối, không tương đối: không có "này"/"tuần sau" trong đầu ra.
      expect(eventDateLabel('2026-08-22'), isNot(contains('này')));
      expect(eventDateLabel('2026-08-22'), isNot(contains('tuần')));
    });

    test('ngày nhuận và cuối năm không phải trường hợp riêng', () {
      expect(eventDateLabel('2028-02-29'), 'thứ Ba 29/02');
      expect(eventDateLabel('2026-12-31'), 'thứ Năm 31/12');
    });

    test('chuỗi không phải ngày bị từ chối ngay', () {
      expect(() => eventDateLabel('16/08/2026'), throwsFormatException);
      expect(() => eventDateLabel(''), throwsFormatException);
    });
  });
}
