# Coding Agent Guide — STORY-011 Vỏ hoàng đạo / trắc nghiệm

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

Lane duy nhất của story này là **Mobile**. Không có phase backend, không có
phase devops.

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding and do not implement blocked
scope.

Riêng story này:

- `../architecture/contract-summary.md` là nguồn tự chứa cho hình dạng hai gói
  nội dung. Không cần mở `solution.md` để implement P1/P2.
- `solution.md` chỉ cần khi phase của bạn nêu một hàng trong bảng risk surface.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.

## 4. Story Guardrails

Các luật dưới đây áp cho **mọi** phase; vi phạm là lý do trả về, không phải góp
ý review:

- Không sửa `CupidDatabase.schemaVersion` và không thêm bảng Drift.
- Không đặt nội dung (câu hỏi, nhận định, văn bản thẻ gợi ý) vào `.arb` hay vào
  widget. Nội dung sống trong hai gói asset.
- Không hằng số đếm mục trong code; mọi số lượng đọc từ dữ liệu.
- Không `DateTime.now`, không `Random`, không xoay nội dung theo ngày.
- Không điểm số, phần trăm, DẢI, thanh tiến độ, streak, huy hiệu, số lần chơi.
- Không ghi vào sổ tay ngữ cảnh — quan hệ là **chỉ đọc**.
- Không import `http`/`dio`/API client/SDK AI trong `features/zodiac_shell`.
- `ActivityCardOrigin` là append-only; thêm giá trị mới vào cuối.
- Không nút gửi/chia sẻ trên màn kết quả.

## 5. Build And Test Commands

- Runtime registry id: `mobile-app`
  (`data/devops/system/runtime-command-registry.json`)
- Test: `flutter test <đường dẫn nhắm đích>` — **không** chạy bare
  `flutter test` cho toàn suite; baseline của repo đang đỏ và một lần chạy đỏ
  khoá cổng build cả phiên.
- Static analysis: `flutter analyze lib test`. Baseline của repo khác 0; chỉ so
  sánh delta, không dùng exit code 0 làm bằng chứng.
- Sau khi sửa `.arb`: chạy `flutter gen-l10n` trước `flutter test`.
- Không pipe output của lệnh build; chạy trực tiếp.
- Chạy test nhắm đích **trước** khi phát completion marker.

## 6. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- `Status` hợp lệ: `NOT_STARTED`, `IN_PROGRESS`, `DONE`, `SKIPPED`, `DEFERRED`,
  `WAIVED`, `N/A`. **`COMPLETE` không hợp lệ** — cổng test từ chối nó. Cập nhật
  cả file phase lẫn bảng Phases Overview trong `master-plan.md`.
- Ghi bằng chứng test vào `coding-plan/test-results.md`.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
