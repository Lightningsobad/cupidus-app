# Coding Agent Guide

## 1. Start Here

Luôn đọc:

- `master-plan.md`
- file `phase-Px-*.md` được giao

## 2. Context Loading Rule

Chỉ đọc các artifact nguồn được nêu trong `Primary Inputs` của phase hiện tại.
Không nạp thêm UX, architecture, hay system memory không liên quan.
Nếu phase nêu shared interface, đọc `../architecture/contract-summary.md` trước.
Nếu phase nêu ràng buộc OQ, đọc `../requirements/requirements.md` mục
`## Open Question Impact` trước khi code và không hiện thực phần đang bị chặn.

## 3. Execution Rule

1. Chỉ làm phase có dependency đã `DONE`.
2. Chỉ chạy phase thuộc lane của bạn.
3. Cập nhật status ngay khi nó đổi.
4. Dừng khi phase actionable kế tiếp thuộc chủ sở hữu khác.
5. Không mở rộng phạm vi phase sang migration, rollout, hay vùng hợp đồng chưa
   được giao cho lane của bạn.
6. Dừng và báo lên nếu công việc cần một quyết định OQ chưa giải mà phase không
   tự giải được.

## 4. Plan Update Rule

- Cập nhật status, ghi chú thuộc phase, và bằng chứng test tại chỗ.
- Không thiết kế lại toàn bộ plan trong lúc hiện thực.
- Báo lên nếu plan sai về bản chất.

## 5. Story-Specific Toolchain Notes

Flutter SDK **không** nằm trên PATH của máy này. Mọi lệnh chạy từ thư mục
`mobile/` trong worktree của story, với SDK giải theo runtime registry
(`flutter on PATH` → `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`):

- sinh mã Drift sau mỗi thay đổi bảng/DAO:
  `dart run build_runner build --delete-conflicting-outputs`
- trong worktree mới, chạy `flutter gen-l10n` trước lần build/test đầu tiên
- test có mục tiêu: `flutter test test/<đường dẫn cụ thể>`
- build/type-check: `flutter build apk --debug` (giá trị từ runtime registry)

`flutter analyze` ở repo này **không bao giờ** thoát 0: có sẵn hàng trăm warning
cũ và 0 error. Cổng đúng là **0 error mới** trên `flutter analyze lib test`, so
với nền hiện có — không dùng exit code làm bằng chứng.

Không bao giờ pipe đầu ra lệnh build. Một lệnh build bị pipe có thể kẹt vĩnh
viễn và khi đó không còn cách xác định nguyên nhân.
