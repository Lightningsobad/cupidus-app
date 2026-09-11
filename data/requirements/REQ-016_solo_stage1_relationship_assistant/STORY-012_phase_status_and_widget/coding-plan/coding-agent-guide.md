# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding and do not implement blocked
scope.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Story-Specific Standing Rules

These hold in **every** phase of this story and are not repeated per phase:

- **Không sửa `mobile/lib/features/activity_cards/domain/`.** Không thêm cột
  Drift, không bump `CupidDatabase.schemaVersion` (BR-12/AC-4). Trạng thái riêng
  của story sống trong `SharedPreferences`.
- **Không sao chép** `invariantDeniedTerms` hay `notebookBoundaryTerms` ra khỏi
  `mobile/lib/core/content/invariant_terms.dart`. Bản sao thứ hai bị chú thích
  thư viện ở đó cấm tường minh.
- **Không chuỗi nội dung hiển thị trong mã Dart, Swift, Kotlin, hay XML.** Mọi
  câu chữ người dùng đọc đến từ ba gói asset ở `contract-summary.md` §4
  (AC-37/BR-15).
- **Không tiến trình nền**, không `workmanager`, không job định kỳ.
- **Không lời gọi mạng, không mô hình AI** trên bất kỳ đường đi nào của story
  (AC-34/BR-13).
- Rỗng là trạng thái đúng, không phải lỗi: không thẻ, không ý tưởng quà, kho
  nhỏ giọt cạn — không vẽ trạng thái lỗi và không đặt CTA vào chỗ trống
  (AC-21/AC-38/BR-2).
- `flutter` không nằm trên PATH máy này. Dùng lối giải SDK trong
  `data/devops/system/runtime-command-registry.json` → `mobile-app.sdk`
  (`FLUTTER_SDK_PATH`, mặc định `$HOME/flutter`).
- Trong worktree mới, chạy `flutter pub get` rồi `flutter gen-l10n` trước khi
  chạy test hay analyze.
- `flutter analyze lib test` **không bao giờ** exit 0 ở repo này (warning tồn dư
  từ trước, 0 error). Đánh giá theo số *error*, không theo exit code.
- Không pipe output của lệnh build. Chạy trực tiếp và đọc nguyên văn.
- Bạn **không** commit. Sửa file trong `Write Scope` rồi giao lại cho Scrum
  Master.
