# Cross-Lane Contract — REQ-016 Điểm nhận của Nhật ký riêng

Authoritative source: `mobile/lib/features/journal/` (STORY-003).
Consumers: `mobile/` STORY-007 (đính ảnh từ nhật ký vào lời cảm ơn) và STORY-008
(cửa ra "ghi vào nhật ký" từ kịch bản buổi hẹn) — hai story đó **chỉ thêm cửa
vào**, không sửa hành vi của STORY-003 (AC-15).

## 1. Envelope

Không có transport, không có endpoint, không có event. Hợp đồng là **một lời
gọi Dart trong cùng process**, do STORY-003 export ở đúng một file
`mobile/lib/features/journal/journal_entry_point.dart`:

```dart
Future<String?> openJournalComposer(
  BuildContext context, {
  JournalComposerSeed seed = const JournalComposerSeed(),
});

class JournalComposerSeed {
  const JournalComposerSeed({
    this.seedText,
    this.seedPhotoPaths = const <String>[],
    this.originRef,
  });
  final String? seedText;             // văn bản mồi, người dùng sửa được
  final List<String> seedPhotoPaths;  // đường dẫn file cục bộ caller đang sở hữu
  final String? originRef;            // thẻ xuất xứ mờ, không hiển thị
}
```

Trả về `id` của mục vừa tạo, hoặc `null` nếu người dùng huỷ. Khớp nối là **kiểu
tĩnh**: sai tên/kiểu là lỗi biên dịch, không phải mất âm thầm lúc chạy.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---|---|---|
| Điểm nhận duy nhất **để tạo mục** | `openJournalComposer` | `features/journal/journal_entry_point.dart` |
| Điểm mở **màn nhật ký** (điều hướng, không tạo mục) | `openJournalScreen` | cùng file trên |
| Kiểu dữ liệu mồi | `JournalComposerSeed` | cùng file trên |
| Nguồn gốc mục | `origin` = `manual` \| `external` | cột `JournalEntries.origin` |

`openJournalScreen(BuildContext)` là **cửa duy nhất** mở `JournalScreen` từ bên
ngoài feature (`coding-plan/phase-P5-journal-entry-point-and-menu.md` §3). Nó
chỉ điều hướng: không nhận seed, không tạo mục, không trả về gì. Lane gọi vẫn
không được dựng `JournalScreen` trực tiếp.

Rules for the consumer side:

- Chỉ import đúng `journal_entry_point.dart`. **Không** import `JournalDao`,
  `JournalEntries`, `JournalPhotos`, `JournalMediaStore`, cubit, hay bất kỳ
  widget nào của feature — kể cả khi phân tích tĩnh cho phép.
- `origin` là chuỗi cố định; `external` viết thường, không phải `EXTERNAL`,
  không phải `external_story_007`.
- Không tạo route có tên riêng cho màn nhật ký ở phía gọi; điều hướng đi qua
  đúng hàm trên.

## 3. `JournalComposerSeed` fields

| Order | Key | Rendered/exposed as | Value contract |
|---|---|---|---|
| 1 | `seedText` | text điền sẵn trong ô nhập, người dùng sửa/xoá được | nullable; `null` = ô trống |
| 2 | `seedPhotoPaths` | ảnh đã đính sẵn trong composer | đường dẫn file cục bộ đọc được ngay tại thời điểm gọi; rỗng = không có ảnh |
| 3 | `originRef` | **không hiển thị ở đâu cả** | chuỗi mờ do caller đặt; nhật ký chỉ lưu, không parse, không dựng link |

- Nhật ký **sao chép** mỗi file trong `seedPhotoPaths` vào media root của chính
  nó rồi mới lưu. Sau lời gọi, mục nhật ký không còn tham chiếu file của caller:
  caller xoá ảnh của mình thì mục nhật ký vẫn nguyên, và xoá mục nhật ký thì ảnh
  gốc của caller vẫn nguyên. Đây là điều kiện để AC-12/AC-13 đúng ở cả hai phía.
- Key thừa hoặc `seedPhotoPaths` chứa đường dẫn không đọc được: bỏ qua ảnh đó,
  composer vẫn mở. Không ném exception ra phía caller.

## 4. Deploy / rollout order

Một binary, không có thứ tự triển khai. STORY-003 phải merge trước; STORY-007/008
build được ngay khi `journal_entry_point.dart` tồn tại. Gọi trước khi có file =
lỗi biên dịch (ồn ào, đúng ý), không phải mất dữ liệu âm thầm.

## 5. What the consumer must NOT do

- **Không được tạo mục nhật ký trực tiếp.** Không có API ghi thẳng. Mọi mục
  `external` vẫn phải đi qua composer và một hành động "Lưu" của người dùng —
  app không tự viết vào nhật ký hộ người dùng (BR-5).
- **Không được đọc ngược.** Hợp đồng là một chiều: không có hàm liệt kê, đếm,
  tìm kiếm, hay xem trước mục nhật ký cho lane gọi. Không bề mặt nào ngoài màn
  nhật ký được hiển thị, trích, hay tham chiếu nội dung nhật ký (AC-7).
- Không thêm nút chia sẻ/xuất ở phía gọi cho nội dung có nguồn từ nhật ký, và
  không đọc file trong media root của nhật ký (AC-6, BR-2).
- Không dùng `originRef` để dựng deep link hay khôi phục ngữ cảnh hiển thị.
