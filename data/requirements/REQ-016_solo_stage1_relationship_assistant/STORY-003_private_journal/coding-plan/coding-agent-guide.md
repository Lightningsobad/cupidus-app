# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
This story has no blocking OQ (`../requirements/requirements.md` →
`## Open Question Impact`: NONE), so no OQ read is required.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane (mọi phase ở đây là Mobile Developer).
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Escalate if the assigned work requires a decision the phase does not resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Toolchain Facts For This Repo

- Flutter SDK không nằm trên PATH của máy này. Resolve qua
  `FLUTTER_SDK_PATH` (mặc định `$HOME/flutter`) như runtime registry
  `mobile-app` mô tả; đừng giả định lệnh `flutter` trần chạy được.
- Trong một worktree mới, chạy sinh l10n trước khi analyze/test, nếu không
  `AppLocalizations` chưa tồn tại và analyze sẽ đỏ hàng loạt.
- `flutter analyze` phải giới hạn phạm vi `lib test`; analyze toàn repo kéo vào
  package sinh tự động và cho nhiễu không liên quan story.
- Sau khi đổi bảng Drift, phải chạy `build_runner` để sinh lại
  `cupid_database.g.dart` trước khi test.
- Chạy test theo đường dẫn của phase, không chạy toàn bộ test suite: repo đang
  có test đỏ có sẵn không thuộc story này, và một lần chạy gộp đỏ sẽ khoá cổng
  bằng chứng của cả phase.

## 6. Story-Wide Prohibitions

Áp cho mọi phase, không lặp lại trong từng file phase:

- Không thêm endpoint, DTO, field OpenAPI, hay bất kỳ lời gọi mạng nào. Story
  này không chạm `backend/`.
- Trong `mobile/lib/features/journal/**` và `mobile/lib/core/journal/**`: không
  import `share_plus`, `dio`, `cupid_api`, `RealtimeCoordinator`,
  `cached_network_image`, `hydrated_bloc`, hay `Clipboard`.
- Không đăng ký `JournalDao` vào `CupidSession.registerScopedStore`.
- Không cột `deletedAt`, không bảng thùng rác, không lưu bản nháp ra đĩa, không
  snackbar "hoàn tác" giữ bản sao.
- Không streak, không mục tiêu ngày, không đếm chuỗi, không tổng số mục hiển thị.
- Không sinh nội dung tự động vào mục nhật ký; câu mồi viết là chuỗi tĩnh.
