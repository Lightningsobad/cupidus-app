# Test Results – STORY-002 Xuất lời mời

## Phase P1 – Engine render tất định + bộ biến mad-libs

- Ngày: 2026-09-10
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`
- Lệnh chạy từ `mobile/`, prefix `PATH="$HOME/flutter/bin:$PATH"`.

### Targeted tests

`flutter test test/features/invite_composer/ --reporter expanded`

```
00:00 +26: All tests passed!
```

26/26 pass, 0 fail. Tên từng case (reporter expanded):

- `mad_libs_test.dart` (11): MadLibsVariable is a closed set of exactly five
  variables · rejects a name outside the set · MadLibsValues drops null, empty,
  and whitespace-only sources · trims a present value · exposes an unmodifiable
  map · fromCard resolves the card-backed variables · fromCard is deterministic
  for the same card · fromCard omits variables whose source field is null ·
  fromCard omits an activity whose title is blank · fromCard renders every
  time-of-day slot in lower case · domain purity no domain file reaches the
  network or a non-deterministic source
- `invite_renderer_test.dart` (15): parses the contract example shape · rejects
  targets "recipient" · rejects an unknown clause role · rejects a requires
  entry outside the closed variable set · rejects a placeholder outside the
  closed variable set · rejects a placeholder that is not gated by requires ·
  rejects a missing mandatory field instead of defaulting · ignores unknown keys
  at clause level · renderInvite is deterministic across repeated renders ·
  fills every placeholder when all five variables are present · drops the whole
  clause when place is missing · reads cleanly for every subset of the five
  variables · keeps the decline door for every subset · renders nothing but the
  decline door when every variable is absent · keeps clause order and does not
  edit case or punctuation

### Regression / contract coverage

`flutter test test/core/content/ --reporter failures-only`

```
+15: All tests passed!
```

15/15 pass, 0 fail. `core/content/` không bị sửa một dòng nào ở phase này.

### Static analysis

`flutter analyze --no-fatal-infos --no-fatal-warnings lib/features/invite_composer test/features/invite_composer`

```
Analyzing 2 items...
No issues found! (ran in 1.6s)
```

`flutter analyze lib test` → `201 issues found`, exit 1. Chạy lại cùng phạm vi
với `--no-fatal-infos --no-fatal-warnings` → **exit 0**, tức **0 error**. 201
issue còn lại là nhiễu `info`/`warning` có sẵn từ trước (unused_import,
unnecessary_import, deprecated `withOpacity`, `prefer_initializing_formals`),
không có cái nào thuộc file của phase này.

### Ma trận thiếu trường (AC-6/AC-9/AC-10)

Test `reads cleanly for every subset of the five variables` và `keeps the
decline door for every subset` duyệt **cả 32 tổ hợp** của bộ 5 biến (đủ 5,
thiếu 1, thiếu 4, thiếu tất cả nằm trong đó). Mỗi tổ hợp khẳng định chuỗi kết
quả: không chứa `{`, không chứa `}`, không có khoảng trắng đôi, không có khoảng
trắng đầu/cuối, không rỗng, và luôn còn nguyên câu cửa từ chối.

### Per-story visual fidelity

NOT_APPLICABLE — phase P1 không dựng màn UI nào.

### Ghi chú bàn giao

`MadLibsValues.fromCard` hiện giải được 4 biến: `activity` ← `title`, `date` ←
`formatLongViDate(scheduled_on)`, `time` ← từ khung giờ viết thường, `duration`
← `formatDurationMinutes(duration_minutes)`. Biến `place` chưa có trường nguồn:
`ActivityCard.location` mới ra đời ở P3. Xem mục "Lệch write scope" ở
`phase-P1-mad-libs-render-engine.md` §7.
