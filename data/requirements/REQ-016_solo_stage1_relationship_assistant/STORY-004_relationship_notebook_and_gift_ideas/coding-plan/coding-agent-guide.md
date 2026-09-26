# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first —
`../architecture/contract-summary.md` is written to be self-contained, so read it
instead of `../architecture/solution.md` for any field, id, or column question.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding and do not implement blocked scope.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision that
   the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Record every test/build run in `test-results.md`; the `MOBILE_COMPLETE: YES`
  marker gates on evidence there.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Story-Specific Invariants

These hold in every phase. Breaking one is a review failure regardless of which
phase introduced it.

- **Luật bất biến sống trong Dart, câu chữ sống trong asset.** Không bao giờ đặt
  một quy tắc R-1b/R-1f/R-1g/R-11 vào file JSON, và không bao giờ đặt một câu nội
  dung vào widget, l10n, hay hằng Dart (R-15a/R-15c).
- **Không chép danh sách từ cấm.** Chỉ có một `core/content/invariant_terms.dart`.
- **Không hằng số N.** Không `10`, không "còn lại k mục", không thanh tiến độ,
  không "đã hết ý tưởng". Hết-tập là quay vòng modulo `ContentPackage.length`.
- **Không VNĐ ở bất kỳ đâu trên luồng quà** — không `₫`, không khoảng giá, không
  nhãn rẻ/đắt, không link mua/tên shop. `price_vnd` của thẻ để `null` vĩnh viễn.
- **Không cột mức độ/sao/điểm/hạng** trên hồ sơ kỹ năng, và không cột đo hành vi
  người kia ở bất kỳ bảng nào.
- **Không chức năng xuất/chia sẻ/copy-toàn-bộ sổ tay**, kể cả trong menu "..."
  của từng mục (chỉ Sửa/Xoá).
- **Không kho thứ hai.** `features/gift_ideas` không có bảng, không có DAO, không
  lưu con trỏ xoay vòng.
- **Không mạng, không AI runtime.** Không thêm import HTTP client hay SDK mô hình
  vào hai module mới.

## 6. Local Toolchain

Flutter SDK không nằm trên PATH của máy này (runtime registry `mobile-app.sdk`).
Prefix mọi lệnh:

    export PATH="$HOME/flutter/bin:$PATH"

Trong một worktree mới, chạy `flutter pub get` **và** `flutter gen-l10n` trước
lần `flutter analyze` đầu tiên, nếu không các symbol l10n sinh ra sẽ báo thiếu.
Giới hạn phân tích vào phạm vi story: `flutter analyze lib test`.

Lệnh chuẩn lấy từ runtime registry `mobile-app`:
`flutter pub get` · `flutter test` · `flutter build apk --debug`.
