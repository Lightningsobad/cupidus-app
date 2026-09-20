# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
`../architecture/contract-summary.md` is the lược đồ for this story — read it in
full before writing the content pack or anything that consumes it.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.

## 4. Story-Specific Hard Stops

- Không thêm cột `activity_cards`, không sửa `CupidDatabase`, không bump
  `schemaVersion`. Trạng thái đóng khối sống trong `SharedPreferences`.
- Không sửa `prepare_actions_sheet.dart` và không thêm hành động chính cấp thẻ
  thứ hai. Khối gắn inline dưới `_primaryAction(...)`, không vào bottom sheet —
  lý do ở `../architecture/solution.md` §1 Key Discovery điểm 1.
- Không gọi mạng trên bất kỳ đường đi nào: không thời tiết, không bản đồ, không
  giao thông, không AI. Miền suy tất định từ bảng alias trong gói.
- Không hardcode nhãn checklist, icon, hay ngưỡng khoảng cách trong Dart. Nếu
  thấy mình gõ một chuỗi tiếng Việt của một dòng checklist vào `.dart`, dừng lại.
- Không `DateTime.now()` trong resolver/cubit — ngày luôn là tham số tiêm được.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place; ghi bằng chứng
  test vào `coding-plan/test-results.md`.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
