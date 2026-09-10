# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
`../architecture/contract-summary.md` là hợp đồng dùng chung của story này và
được viết để tự đủ — đọc nó thay vì đọc `solution.md` khi chỉ cần contract.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane (story này chỉ có lane Mobile).
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Mobile Toolchain Notes

- Flutter SDK không nằm trên PATH mặc định của máy này: dùng
  `FLUTTER_SDK_PATH` (mặc định `$HOME/flutter`) như runtime registry `mobile-app`
  mô tả, hoặc prefix PATH trước khi chạy lệnh.
- Trong worktree mới, chạy `flutter gen-l10n` trước `flutter analyze`/`flutter
  test`, nếu không các file l10n sinh ra sẽ thiếu và analyze báo lỗi giả.
- Scope static analysis là `flutter analyze lib test`, không phải toàn repo.
- Runtime registry id cho mọi phase của story này: `mobile-app`.

## 6. Story Guardrails (không phase nào được vi phạm)

- Không sửa bất kỳ file nào dưới `backend/`; story này không có bề mặt backend.
- Không thêm lời gọi mạng, dependency HTTP mới, hay mô hình AI ở runtime.
- Không đăng ký DAO thẻ làm `SessionScopedStore` (đăng xuất sẽ xoá sạch kho).
- Không tạo `@DriftDatabase` thứ hai và không đặt bảng Drift trong `features/`.
- Không thêm bất kỳ cột nào trong danh sách cấm ở `contract-summary.md` §4.
- Không đổi 4 nhãn hành động chính và không thêm hành động chính thứ hai.
- Không hard-code chuỗi nội dung preset trong Dart; không giả định số mục cố định.
