# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
`../architecture/contract-summary.md` là lược đồ của story này — đọc hết trước
khi viết gói nội dung hoặc bất kỳ thứ gì tiêu thụ nó. Tên biến mad-libs, id
schema, và tên hằng nằm ở §2; gõ sai một cái là gói ship không parse được.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.

## 4. Story-Specific Hard Stops

- **Không đặt tên route cho màn (9).** Đẩy màn bằng `MaterialPageRoute` vô danh
  từ `openDateScriptScreen`, giống `gift_ideas_entry_point.dart`. Không đăng ký
  route name, không deep link, không mục menu chính, không tab bar — SC-6 / R-13
  / BR-1a. `card` là tham số vị trí bắt buộc để "mở màn (9) mà không có thẻ
  nguồn" là lỗi biên dịch, không phải lỗi runtime.
- **Không ghi gì xuống DB.** Không bảng mới, không cột mới, không bump
  `CupidDatabase.schemaVersion`, không migration. Con trỏ xoay vòng preset sống
  trong Cubit và chết khi màn đóng (AC-22 cấm lịch sử kịch bản).
- **Không touchpoint trong lúc hẹn (J7).** Không `Timer`, không
  `flutter_local_notifications`, không countdown, không nút "bắt đầu buổi hẹn",
  không bất cứ thứ gì đọc `scheduledOn` để kích hoạt. `scheduledOn` chỉ là một
  giá trị mad-libs. AC-13..AC-16, BR-3.
- **Caption "Trong" là nhãn của widget, không phải nội dung gói.** Nó phải nằm
  trong Dart để không CMS nào xoá được (BR-3). Đây là ngoại lệ duy nhất của luật
  "chuỗi hiển thị nằm trong gói".
- **Không chép danh sách từ cấm.** Tầng từ vựng gọi `invariantHitsIn` /
  `notebookBoundaryHitsIn` trong `mobile/lib/core/content/invariant_terms.dart`.
  Doc comment ở đó cấm bản sao thứ hai. Cổng của story chỉ thêm luật **cấu
  trúc**.
- **Không dùng `String.hashCode` làm nguồn tất định.** Nó không được bảo đảm ổn
  định giữa các phiên bản Dart và giữa các nền tảng. Tự định nghĩa một hàm băm
  ổn định trong `domain/` (FNV-1a 32-bit hoặc tương đương) và test nó bằng
  vector cố định.
- **Không gọi mạng, không AI runtime.** Preset + mad-libs, hết.
- **Chỉ import file `*_entry_point.dart` của feature khác.** Không với tay vào
  `features/<x>/presentation/**` hay `features/<x>/data/**` từ `date_script`.
  Ngoại lệ duy nhất đã được duyệt: P3 sửa `prepare_actions_sheet.dart` vì đó
  chính là điểm mở rộng mà STORY-002 đã chừa sẵn cho STORY-008.
- **Không chia sẻ / sao chép link trên màn (9).** Không nút share, không
  copy-link. Cửa ra "xuất lời mời" mới là nơi duy nhất nội dung rời app.
- **Không giả định số lượng preset.** Xoay vòng modulo `length`; không có trạng
  thái "đã hết", không dead-end, không thanh tiến độ (R-15b, AC-35).

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place; ghi bằng chứng
  test vào `coding-plan/test-results.md`.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
