# Review Report — STORY-001 (REQ-016) Danh sách việc-cần-làm / Activity Card Hub

Outcome: BLOCKED

Mã chặn: `REVIEW_EVIDENCE_GAP_UNREVIEWED_PATCH_ROUND`

- Review type: `final-synthesis` (Tier 3, ngữ cảnh mới, không nối tiếp slice nào)
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-001`
- BaseHead: `9207f7296a64cd37ca60e432939469ca96860762` · HEAD: `8f44d3c`
- Ngày: 2026-09-08 · Story: `Complexity: complex`, `Story-Class: shared-foundation`
- Bản này thay bản `PATCH_REQUIRED` của lượt S8 (commit `e3a504f`).

## Vì sao lượt này không thể ra phán quyết đóng story

Lượt S8 để lại **6 phát hiện chặn B-1..B-6**. Thứ duy nhất được coi là đóng
chúng là commit `c92fd1b` *"patch round 2 — hub mount (B-1), P8 field-write path
(B-2), DI fix (B-4), quick-entry render…"*: **20 file, +1391 / −298**, gồm
`activity_card_repository.dart`, `activity_card_repository_impl.dart`,
`activity_card_detail_cubit.dart` (+244), `activity_card_hub_view.dart` (+199)
và 2 file test từng chứng nhận lỗi AC-15.

**Không slice nào review commit đó.** `slice-p9-p10-delta.md` tự ghi baseline
thực dụng của nó là `c92fd1b..d4852f5` (dòng 17-18) — tức nó bắt đầu **sau**
vòng vá và cố ý loại vòng vá ra ngoài. `slice-p9-pair-gate-shell.md` chỉ phủ 3
file P9. 7 slice S1-S7 đều có trước `c92fd1b`. Kết quả: đường ghi trường mới,
hợp đồng repository đổi chữ ký (`Future<void>` → `Future<int>`), và bản viết lại
2 test AC-15 **chưa từng qua mắt reviewer nào**.

Bằng chứng duy nhất cho vòng vá là hồ sơ tự khai của lane
(`test-results.md:933-1187`). Đó là đầu vào của một lượt review, không phải kết
quả của nó. Cổng review tồn tại chính là để không nhận lời tự khai của lane làm
bằng chứng đóng phát hiện chặn do chính cổng đó nêu.

Ngoài khoảng hở quy trình trên, còn **một mục chặn đã xác minh là vẫn mở** — B-5
nửa hồ sơ (xem dưới). Vì vậy không có đường nào tới `CLEAN` hay `DEFERRED_ONLY`
ở lượt này; và `PATCH_REQUIRED` cũng sai vì nó sẽ chỉ mobile-dev đi làm lại việc
đã làm, đồng thời ngầm nhận B-1/B-2/B-4/B-6 là đã đóng mà không ai kiểm.

## Đối soát toàn bộ finding id

### Chặn từ lượt S8

| id | Trạng thái | Bằng chứng |
|---|---|---|
| B-1 hub không mount P5/P6 (rule 12e1) | **VÁ RỒI, XÁC MINH MỘT PHẦN** | Vá trong `c92fd1b`, chưa review mã. Chứng cứ độc lập một phần: `slice-p9-p10-delta.md` mục 13 — reviewer **tự mở ảnh** `screen2.png` (bản dựng thật vào thẳng hub solo, 4 tab) và `screen5.png` (màn chi tiết P6 đủ thành phần). Chưa ai xác minh `MinuteOneEmptyState` mount ở nhánh `storeCount == 0` |
| B-2 không có đường ghi trường, AC-15 vỡ | **VÁ RỒI, CHƯA XÁC MINH** | `c92fd1b` thêm `updateCardDetails` + `ActivityCardEdit`, mọi mutator qua `_persist`, `updateStatus`/`clearScheduledDate` trả row count. Không slice nào đọc mã hay 2 test đã viết lại. **Đây là lỗ hổng sâu nhất còn lại** |
| B-3 B-1 và B-2 phải cùng landing | **ĐẠT về cấu trúc** | Cả hai nằm trong đúng một commit `c92fd1b`; ràng buộc trình tự không bị vi phạm |
| B-4 3 test đỏ `app_shell_test.dart` bị quy sai cho nợ cũ | **VÁ RỒI, CHƯA XÁC MINH** | `c92fd1b` đăng ký `ActivityCardRepository` vào harness + sửa assertion theo AC-22; lane ghi 11/11 xanh. Không có xác nhận độc lập |
| B-5 `VISUAL_FIDELITY: FAIL` + delta trong vùng chưa ghi | **CÒN MỞ — đã xác minh** | Nửa mã đã vá (gỡ `_QuickEntryStrip` rỗng). Nửa hồ sơ **chưa**: `visual-fidelity/visual-fidelity-report.md:1` vẫn nguyên `VISUAL_FIDELITY: FAIL`; mục cuối cùng vẫn là `## 8. Round 6`, không có vòng nào ghi lại bản sửa dải quick-entry; §5 vẫn chưa ghi delta S7-F-1 |
| B-6 gói dịp hết hạn 2027-12-24 | **VÁ RỒI MỘT NỬA, CHƯA XÁC MINH** | `c92fd1b` ẩn CTA chết khi nội dung hết hạn (nửa mã). Cách đóng rẻ nhất mà S8 chỉ ra — **bản ghi bền vững về chủ nội dung + ngày làm mới** — vẫn không thấy ở `req_master.md`, `requirements.md`, hay phase file. Chưa review |

### Quyết định cần ra (rulings)

| id | Trạng thái | Bằng chứng |
|---|---|---|
| R-1 CTA đúng nhãn nhưng trơ có chấp nhận được dưới AC-11 | **CÒN MỞ** | Không có phán quyết product-owner nào trong lịch sử commit từ `e3a504f` tới `8f44d3c` |
| R-2 rule 12g bắt buộc hay `NOT_APPLICABLE` | **ĐÓNG** | Tech Lead phán `REQUIRED` (`4940e26`), thi hành ở lần chạy 12g thứ 3, `slice-p9-p10-delta.md` mục 13 xác minh 4/4 điều kiện với ảnh đã tự mở |

### Mục hồ sơ M-1..M-6

| id | Trạng thái | Bằng chứng |
|---|---|---|
| M-1 nhãn AC trong `scope-gate.md` § Query Keys sai | **CÒN MỞ** | `scope-gate.md` chưa được sửa (đọc lại lượt này) |
| M-2 phân loại/viện dẫn delta `visual-fidelity-report.md` | **CÒN MỞ** | Cùng bằng chứng B-5: cấu trúc báo cáo không đổi |
| M-3 Design Ruling Log `req_master.md` (D-8 không tồn tại, D-5 mâu thuẫn) | **CHƯA XÁC MINH** | Không có commit product-owner nào chạm `req_master.md` sau `e3a504f` |
| M-4 thiếu 2 mục bằng chứng bắt buộc | **ĐÓNG** | `test-results.md:1239` `## Story Runtime Startup Smoke`, `:1306` `## Entry Point Reachability`, cả hai có nội dung thật và trỏ vào `coding-plan/evidence/rule-12g-r2-run3/` trong repo |
| M-5 P2 không có mục bằng chứng | **CÒN MỞ — đã xác minh** | Danh sách tiêu đề `## ` của `test-results.md` có P1, P3, P4 (3 vòng), P7, P5, P6, P8, P10, P9 — **không có P2** |
| M-6 trôi viện dẫn AC trong comment/tên test | **CHƯA XÁC MINH** | Ngoài phạm vi mọi slice đã chạy |

### Vòng P9/P10 (S9-F-*, S9B-F-*)

| id | Trạng thái | Bằng chứng |
|---|---|---|
| S9-F-1 thiếu `phase-P9-unpaired-root-to-solo-surface.md` | **ĐÓNG** | File tồn tại, 7.4K, vá ở `edf2523` |
| S9-F-2 thiếu mục bằng chứng test/analyze vòng P9 | **ĐÓNG** | `test-results.md:1320` `## P9`: analyze toàn cây 0 error, 26/26 test P9 xanh, tiêu đề chuẩn đã đúng, ảnh/logcat đã chuyển từ `/tmp` vào `coding-plan/evidence/` |
| S9-F-3 tên test lạc hậu | **ĐÓNG** | `test-results.md:1327` ghi vòng vá đổi tên; tên mới `…unpaired routes into the solo surface, never the couple dashboard` |
| S9-F-4 3 file P9 ngoài phạm vi slice | **ĐÓNG** | `slice-p9-pair-gate-shell.md`: 10/10 dòng phán quyết PASS với §8.4/§8.5/§8.6/§8.7 rule 1-3, 9/9 test xanh, 0 error 0 warning |
| S9-F-5 hồi quy số test toàn cây | **ĐÓNG** | `880541d`: 1882/4/22 → 1889/4/15; hai nguyên nhân đều thuộc harness (thiếu đăng ký DI, mặc định của fake HTTP adapter); không chạm khẳng định hay file sản phẩm |
| S9-F-6 xung đột semantics `splash_screen_test.dart:208` | **ĐÓNG** | Phán quyết Tech Lead `b7202e0` (§8.12) + thi hành nguyên văn `b8c4bef`: 1889/4/15 → 1890/4/14 |
| S9B-F-1 3 đường dẫn trong handoff đều sai (INFO) | **GHI NHẬN** | Chủ: Scrum Master — lấy đường dẫn từ `git diff --name-only`, không gõ tay |
| S9B-F-2 3 tham số constructor `PairGateShell` nhận rồi bỏ | **HOÃN** | §8.11 dòng 489-491 đã lường trước cả hai kết cục; gỡ sẽ phá harness bị §8.11 ghim |
| S9B-F-3 doc comment viện dẫn §8.7 rule 4 đã bị thay | **HOÃN** | Sửa một dòng comment, không đổi hành vi |

### Bảng deferred của lượt S8

Toàn bộ bảng deferred trong bản `e3a504f` (S1-F-1, S1-F-2, S1-F-4, S1-F-5,
S2-F2-1..S2-F2-5, S2-F2-8, S3-F-3, S3-F-4, S3-F-5, S4-F-3..S4-F-8, S5-F-3,
S5-F-4, S5-F-5, S6-F-2, S6-F-4, S6-F-6, S7-F-2, S7-F-6) **giữ nguyên phân loại
hoãn và giữ nguyên chủ**. Sáu mục trong đó từng được lệnh gộp vào vòng vá B-1/B-2
— S2-F2-1, S2-F2-3, S4-F-3, S4-F-4/S6-F-2, S5-F-4, S6-F-6 — nay nằm trong đúng
`c92fd1b`, nên chúng chia chung tình trạng **chưa xác minh** với B-2.

Còn 14 test đỏ toàn cây sau S9-F-6, đã liệt kê đích danh trong `test-results.md`,
thuộc mục theo dõi riêng BUG-20260907-001 và **ngoài WriteScope story này** —
không tính vào phán quyết trên.

## Điều kiện gỡ chặn

Một lượt `Mode: scoped-slice` duy nhất, **không** phải review lại cả story:

1. Diff `4940e26..c92fd1b` — đúng 20 file. Trọng tâm theo thứ tự rủi ro: hợp đồng
   `activity_card_repository.dart` (đổi chữ ký, ảnh hưởng 11 story sau),
   `activity_card_detail_cubit.dart` `_persist` ghi-rồi-emit, và **hai test AC-15
   đã viết lại** — S8 xếp chúng là mục phải sửa vì bản cũ chứng nhận lỗi là đúng;
   bản mới phải khẳng định lưu thật, không chỉ đổi tên.
2. B-1 phần chưa phủ: `MinuteOneEmptyState` có mount ở nhánh `storeCount == 0`
   không (ảnh 12g chỉ chứng minh hub có thẻ và mở được chi tiết).
3. B-5 nửa hồ sơ + M-2: cập nhật `visual-fidelity-report.md` cho vòng vá dải
   quick-entry, ghi delta S7-F-1 vào §5, phân loại lại các delta M-2 nêu, rồi
   đánh giá lại token đầu file. **Token còn là `FAIL` thì story không qua được
   cổng dù mọi mục khác xanh.**
4. B-6: hoặc bản ghi bền vững chủ nội dung + ngày làm mới trước 2027-12-25, hoặc
   xác minh nhánh ẩn CTA đã vá có test phủ.
5. R-1 lấy phán quyết product-owner; M-3, M-5, M-6 đóng ở lane tương ứng.

Chủ dispatch: **Scrum Master**. Không cần lặp lại S1, S3, và nửa P7 của S2 —
`c92fd1b` không chạm file nào của chúng.

## Khuyến nghị trạng thái

- **KHÔNG** tick `Review (Reviewer)` trong `story_master.md`.
- **KHÔNG** đánh dấu story `DONE`: kết quả này không phải `CLEAN` cũng không phải
  `DEFERRED_ONLY`.
- Nhánh story **chưa đủ điều kiện merge** vào
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`.
- Quyết định vòng đời story/requirement thuộc Scrum Master, không thuộc lượt này.

REVIEW_COMPLETE: YES

---

## Slice A4-CTA-D18-D19 — 2026-09-08

Lượt `Mode: scoped-slice`, chỉ phủ diff `f5e69b2..dedd45b` (3 file, +273/−43).
Kết quả lượt này: **PARTIAL_SLICE_ONLY**. Nó **không** đổi dòng phán quyết cuối
của story ở đầu file; phần đó thuộc lượt final-synthesis sau.

- Review type: `scoped-slice`
- BaseHead: `f5e69b2602df17ae5c8b1eeef6e11d88e8491b5a` · HEAD: `dedd45b`
- File trong phạm vi:
  `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`,
  `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart`,
  `coding-plan/test-results.md` (mục `### A4-CTA-D18-D19`)

### 1. AC-11/AC-13 (đã vá) và uiux-spec §2 — ĐẠT

Văn bản cho phép nằm ở commit `26427f2`, đọc bằng `git show` (xem A4-F-1).
Đối chiếu nguyên văn:

| Ràng buộc | Nguồn | Mã | Kết luận |
|---|---|---|---|
| *Mới nghĩ ra* → "Chốt ngày đi thôi" | AC-13 ngoại lệ A4 (D-18) | `_screenPrimaryActionLabel` case `idea` | Khớp từng ký tự |
| *Đã thành kỷ niệm* → "Đọc lại · rủ đi lần nữa" | AC-13 ngoại lệ A4 (D-18) | case `memory` | Khớp từng ký tự |
| 2 chuỗi còn lại không bị AC ràng buộc | AC-13 chỉ nêu "ví dụ" | `scheduled`/`done` cùng giọng | Trong quyền |
| Dòng phụ ví dụ "hoặc soạn lời rủ cho ngọt · để dành hôm khác" | AC-11 ngoại lệ A4 (D-19) | `_screenSecondaryLine` case `idea` | Khớp từng ký tự |
| **Đúng một** dòng phụ, đặt **dưới** CTA | AC-11 ngoại lệ A4 | `Column(stretch)` → `Semantics>GestureDetector` rồi `SizedBox` rồi `Text` | Đúng cấu trúc, một `Text` duy nhất |
| Không nền `--grad`/pill, không ngang hàng CTA | AC-11 ngoại lệ A4 + uiux-spec §2 | `Text` trần, không `Container`/`BoxDecoration`, khác hàng | ĐẠT |
| Không được chọn/tính như hành động chính | AC-11 | không `GestureDetector`, không `Semantics(button)`, không key CTA | ĐẠT |
| `type.caption` + màu mờ | uiux-spec §2 | `type.caption.copyWith(color: colors.colorTextMuted)` | ĐẠT |
| Hành vi bấm + chuyển trạng thái vẫn theo SC-4 | AC-13 ngoại lệ A4 | `action = primaryActionFor(status)` → `_runPrimaryAction(context, action, cubit)` | ĐẠT, xem mục 2 |

Xác minh bằng cây widget/test, không chỉ bằng prose: test `the one secondary
line sits below the CTA, inert (D-19)` khẳng định `findsNothing` cho
`find.descendant(of: cta, matching: secondary)`, `getTopLeft(secondary).dy >
getBottomLeft(cta).dy − 1`, và `find.ancestor(of: secondary, matching:
find.byType(GestureDetector))` `findsNothing`, cho cả 4 trạng thái.

### 2. P4 / `activityPrimaryActionLabel` / `primaryActionFor` / `_runPrimaryAction` — KHÔNG ĐỔI, đã kiểm trực tiếp

- `git diff --name-only f5e69b2..dedd45b` trả **đúng 3 file**; file `lib` duy
  nhất là `activity_card_detail_screen.dart`. Widget thẻ rút gọn P4 và file
  định nghĩa `activityPrimaryActionLabel`/`primaryActionFor` không nằm trong
  diff.
- Trong file bị sửa, `Future<void> _runPrimaryAction(` chỉ xuất hiện ở dòng
  ngữ cảnh cuối hunk `@@ -771,49 +774,140 @@`, không có dòng `+`/`−` nào chạm
  thân hàm.
- `primaryActionFor` vẫn là nguồn duy nhất của `action` và của nhánh
  `outlined`; D-18 chỉ thay đối số `Text`.
- `/usr/bin/grep -rln 'card_detail_primary_action|card_detail_secondary_line'
  lib test` chỉ trả về đúng 2 file trong phạm vi — không test nào khác đang
  khẳng định nhãn CTA của A4, nên không có hồi quy ẩn.

### 3. `Flexible` + `FittedBox(scaleDown)` — chấp nhận được, có một rủi ro tồn đọng

Hợp lý và đủ hẹp: chỉ bọc `Text` bên trong `Row` của CTA.

- **Vùng chạm**: `Container(height: 54)`, `HitTestBehavior.opaque`,
  `GestureDetector`, `onTap` — không đổi một byte. `FittedBox` nằm *bên trong*
  vùng chạm nên không thu nhỏ nó.
- **Semantics**: `Semantics(button: true)` giữ nguyên vị trí bọc ngoài
  `GestureDetector`. Nhãn trợ năng vẫn suy ra từ `Text` con — nay là chữ D-18,
  đúng chủ ý của phán quyết. `FittedBox` chỉ đổi tỉ lệ vẽ, không đổi cây
  semantics.
- **Layout tương đương**: `Column` mới dùng `crossAxisAlignment.stretch`, còn
  `Column` cha (dòng 232) là `.start`. Trước vá, pill đã chiếm hết bề ngang nhờ
  `Row` mặc định `mainAxisSize.max`; sau vá, `stretch` cho cùng kết quả. Dòng
  phụ `textAlign.center` nằm giữa dưới pill. Không có thay đổi bề rộng ngoài ý.
- Xem A4-F-3 cho rủi ro tồn đọng.

### 4. Test có khẳng định đúng thứ `test-results.md` khai — ĐẠT, một chỗ hẹp hơn spec

- Hai bảng hằng `_screenCtaText` / `_screenSecondaryText` phủ **đủ 4** giá trị
  `ActivityCardStatus`; cả hai test lặp qua `.entries` nên không trạng thái nào
  bị bỏ.
- Khẳng định bị **đảo** chứ không bị làm yếu: `find.text(
  activityPrimaryActionLabel(context, primaryActionFor(...)))` từ
  `findsOneWidget` → `findsNothing`. Đảo chiều này là *siết chặt* — nó chủ động
  chứng minh nhãn SC-4 cố định đã rời khỏi CTA của A4, đúng tinh thần D-18.
- Khẳng định `find.text('Xem lại')` → `find.text('Đọc lại · rủ đi lần nữa')`
  là cập nhật bắt buộc, không phải né kiểm tra.
- Không có test nào bị đổi tên để mất nội dung: `every status shows one CTA`
  vẫn giữ `expect(cta, findsOneWidget)` và **thêm** khẳng định nội dung.

### 5. Chạy lại độc lập trong Worktree — TRÙNG KHỚP báo cáo lane

- `flutter test test/.../activity_card_detail_screen_test.dart --reporter
  expanded` → **7 pass, 1 skip** (`renders the visual-fidelity evidence
  frames`, skip có sẵn từ trước). Reporter `expanded` liệt kê đích danh cả hai
  test mới D-18 và D-19 — chúng tồn tại và thực sự chạy.
- `flutter analyze --no-fatal-infos --no-fatal-warnings <2 file bị sửa>` →
  **No issues found!**
- `flutter analyze --no-fatal-infos --no-fatal-warnings
  lib/features/activity_cards test/features/activity_cards` → **7 issue, toàn
  bộ `info` `prefer_initializing_formals`** trong `data/`, `domain/`,
  `*_cubit.dart` có sẵn; **0 issue** trong hai file vòng vá này chạm. Khớp
  chính xác con số lane khai.

### Phát hiện

| id | Loại | Nội dung | Chủ |
|---|---|---|---|
| A4-F-1 | INFO — không chặn, không cần vá | Bản vá AC của Product Owner (`26427f2`) nằm trên `main`, **không** có trong nhánh story: `git merge-base --is-ancestor 26427f2 HEAD` → NO. Bản `requirements.md`/`uiux-spec.md` *trong worktree* vẫn là bản chưa vá, nơi AC-11 còn ghi "Bốn nhãn CTA ở trên **không đổi** (D-2)" — đọc trong nhánh sẽ thấy mã mâu thuẫn với chính AC của nó. Đã kiểm rủi ro merge: `git diff main...HEAD` cho hai file đó **rỗng**, nhánh chưa từng chạm chúng, nên merge sẽ giữ bản vá của `main`, không revert, không xung đột. | Ghi nhận cho lượt final-synthesis: đọc AC-11/AC-13 từ control checkout / `main`, không từ worktree, nếu không sẽ kết luận sai là vi phạm AC-11 |
| A4-F-2 | HOÃN — độ phủ test hẹp hơn spec | Test D-19 chứng minh "không phải CTA thứ hai" bằng `fontWeight isNot(FontWeight.w700)` + không có `GestureDetector` tổ tiên. Nó **không** khẳng định `type.caption` (cỡ chữ) hay `colorTextMuted`, cũng không khẳng định vắng mặt `BoxDecoration`/`gradientHot` — đúng ba điều uiux-spec §2 nêu đích danh. Mã hiện tại đúng; chỉ là nếu ai đó sau này đổi style dòng phụ thành pill mờ thì test vẫn xanh. | mobile-dev, nếu Scrum Master mở vòng vá khác chạm file test này |
| A4-F-3 | HOÃN — rủi ro tồn đọng trợ năng | `FittedBox(fit: BoxFit.scaleDown)` không có sàn tỉ lệ. Nó nuốt cả phần chữ dài của D-18 (lane đo tràn 21px/59px ở 415pt) **lẫn** cỡ chữ do người dùng phóng to trong cài đặt hệ thống: bật font lớn, chữ CTA sẽ bị co lại về đúng chỗ cũ thay vì to lên. Đây là đánh đổi có ý thức của lane (co còn hơn cắt) và không vi phạm AC nào đang mở, nhưng nó là hành vi text-scaling đáng ghi. | ui-ux-designer/mobile-dev, ngoài phạm vi lượt này |
| A4-F-4 | GHI NHẬN — lane đã tự khai | `visual-fidelity/implemented-*.png` của A4 nay đã lệch vì khu CTA đổi chữ và thêm một dòng. Lane không chụp lại do thư mục ngoài WriteScope vòng vá. Điều này **cộng thêm** vào B-5 đang mở ở phần đầu báo cáo (`visual-fidelity-report.md` vẫn `VISUAL_FIDELITY: FAIL`). | Scrum Master — cần cấp scope chụp lại trước khi cổng visual fidelity đọc lại |

### Ảnh hưởng tới các mục đang mở ở đầu báo cáo

- **R-1** ("CTA đúng nhãn nhưng trơ có chấp nhận được dưới AC-11", CÒN MỞ vì
  thiếu phán quyết product-owner): nay đã có phán quyết người dùng D-18/D-19 và
  bản vá AC `26427f2`. Vòng vá này **không** làm CTA hết trơ — nó vẫn gọi
  `_runPrimaryAction` như cũ — nên R-1 chưa đóng bằng lượt này, nhưng khoảng
  trống "không có phán quyết nào" thì đã được lấp.
- **B-1, B-2, B-4, B-5, B-6, M-1, M-3, M-5, M-6** không bị lượt này chạm tới và
  giữ nguyên trạng thái.
- Nhánh story vẫn **chưa đủ điều kiện merge**; lượt này không đổi khuyến nghị
  trạng thái ở mục "Khuyến nghị trạng thái".

Kết luận lượt: 5/5 mục xác minh trong handoff đều ĐẠT, không có phát hiện chặn,
4 mục ghi nhận/hoãn ở trên.

---

## Slice P2-PATCH-ROUND-2 — 2026-09-08

Lượt `Mode: scoped-slice`, phủ **đúng** diff `4940e26..c92fd1b` (20 file,
+1391/−298) — vòng vá mà lượt `final-synthesis` xác định là chưa slice nào đọc.
Kết quả lượt này: **PARTIAL_SLICE_ONLY**. Nó **không** đổi dòng `Outcome:` ở đầu
file; phán quyết đóng story thuộc lượt final-synthesis sau.

- Review type: `scoped-slice`
- BaseHead: `4940e26` · HEAD của slice: `c92fd1b`
- 20/20 file trong diff đều đã đọc (diff, không full-read). Hai file
  `activity_card_detail_screen.dart` / `..._test.dart` nằm trong danh sách
  "Do Not Re-read" của handoff nhưng **có** trong diff này (+94/−29 và +9/−6) —
  xem P2-F-3; tôi đọc diff của chúng, không full-read lại file.

### 1. Phán quyết theo từng finding

| id | Phán quyết | Bằng chứng đã tự kiểm |
|---|---|---|
| **B-1** hub không mount P5/P6 | **ĐÓNG** | `activity_card_hub_view.dart:144` `cards.isEmpty` → `_EmptyPane`; `:233` `storeCount == 0` → `MinuteOneEmptyState(repository, onCardCreated)`. `minuteOne` (`!loading && storeCount == 0`) tắt strip + `QuickCaptureAddAction` + filter dính, đúng §4a. Mọi affordance trên thẻ (`GestureDetector` bọc ngoài, `onPrimaryAction`, overflow "Sửa"/"Chuyển trạng thái") đều vào `_openDetail` → `ActivityCardDetailScreen` rồi `cubit.load()` khi quay lại. Test `B-1: an empty store mounts the real Minute-1 surface, not a placeholder slot` **xanh trong lần tôi tự chạy** — đây chính là khoảng hở lượt final-synthesis nêu |
| **B-2** không có đường ghi trường, AC-15 vỡ | **ĐÓNG** | Hợp đồng: `updateCardDetails(String, ActivityCardEdit) → Future<int>`; `ActivityCardEdit` phơi **đúng 11 cột** người dùng sửa được, `id`/`ownerKey`/`status`/`origin`/`createdAt` không có cửa vào. Ngữ nghĩa full-snapshot khai rõ trong doc và **được test chứng minh**, không chỉ khai. 9 mutator trường của cubit đổi `void` → `Future<void>` và đi qua `_persist`: ghi trước, `emit` sau, `rows == 0` → `failed: true` và **không** emit. `scheduleDate` ghi ngày trước, status sau, và dừng hẳn nếu ngày không vào — `expect(repository.calls, ['updateCardDetails:card-1', 'updateStatus:card-1:scheduled'])` + `lastEdit.scheduledOn == '2026-10-01'` |
| **B-2** — 2 test AC-15 viết lại | **ĐÓNG, khẳng định bị SIẾT chứ không nới** | Bản cũ `expect(calls, ['updateStatus:card-1:scheduled'])` (chứng nhận ngày bị rơi là "đúng"). Bản mới bắt **cả hai** lệnh ghi đúng thứ tự **và** nội dung `ActivityCardEdit` đã ghi. Test "9 sửa 9 ghi" thay `expect(calls, isEmpty)` bằng `hasLength(9)` + `everyElement(...)` + đối chiếu 9 trường trong `lastEdit`; nhánh xoá thêm `hasLength(14)` + 5 trường `isNull`. Thêm **3 test âm mới** (`rowsWritten: 0`) mà bản cũ không thể có vì hợp đồng cũ trả `void` |
| **B-3** B-1/B-2 cùng landing | **ĐÓNG** | Cả hai trong đúng `c92fd1b`, đã xác nhận bằng `git diff --name-only` |
| **B-4** 3 test đỏ `app_shell_test.dart` | **ĐÓNG** | `_harness` đăng ký `CupidDatabase(NativeDatabase.memory())` + `ActivityCardRepositoryImpl` vào `getIt` (in-memory, không chạm đĩa/mạng). Đổi khẳng định là **siết**, không phải né: `solo_stage_one_shell` `findsOneWidget` **cộng** `home_screen_ready_signal` `findsNothing` — vắng mặt khoá couple là điều AC-22/D-3 yêu cầu, và test nêu đích danh nó thay vì im lặng. `shellTabBar` lọc theo `key != solo_stage_one_tab_bar` để giữ nguyên phép đếm 4 InkWell. **37/37 xanh trong lần tôi tự chạy** |
| **B-6** gói dịp hết hạn (nửa mã) | **ĐÓNG** | `if (prompt != null)` bọc `_InviteCard` dịp; nhánh snackbar "Sắp có" trong `_revealSuggestions` bị **xoá** thay vì để lại — không còn đường nào mời rồi từ chối. Test `B-6: once the occasion package runs out…` khẳng định invite dịp `findsNothing`, invite link vẫn `findsOneWidget`, `_invites` còn đúng 1, và strip + tiêu đề Minute-1 **vẫn còn** (không biến thành stub). Xanh trong lần tôi tự chạy |
| **B-6** bản ghi bền vững chủ nội dung + ngày làm mới | **CÒN MỞ** | Không file artifact nào trong 20 file diff mang bản ghi đó. Ngoài phạm vi mã — chủ: Product Owner / Scrum Master |
| **B-5** nửa mã | **ĐÓNG (xác nhận lại)** | `_QuickEntryStrip` giả (ô rỗng) bị xoá khỏi `activity_card_hub_view.dart`, thay bằng `QuickEntryStrip` thật. Kèm S5-F-4: `LayoutBuilder` + `kQuickEntryMinCellWidth = 104`, dưới ngưỡng thì cuộn ngang thay vì bóp nhãn. Nửa hồ sơ đã đóng ở vòng 7 (`637269a`) — **không** nêu lại ở đây theo handoff |

### 2. Chạy lại độc lập trong Worktree

Cả 5 lệnh chạy trong `<Worktree>/mobile`, không lệnh nào lọc output:

| Lệnh | Kết quả |
|---|---|
| `flutter test .../card_lifecycle_ui_test.dart .../activity_card_repository_test.dart .../minute_one_empty_state_test.dart` | **37 pass, 1 skip** (skip `renders the visual-fidelity evidence frame`, có sẵn từ trước) |
| `flutter test .../activity_card_repository_test.dart` (chạy riêng để chắc chắn) | **10/10 pass** — gồm 3 test `updateCardDetails` đánh vào **SQLite thật** (`NativeDatabase.memory` + drift), không phải fake |
| `flutter test test/core/navigation/app_shell_test.dart .../activity_card_hub_view_test.dart` | **37 pass** |
| `flutter test .../timeline_entry_point_test.dart .../quick_capture_sheet_test.dart` | **12 pass** |
| `flutter analyze --no-fatal-infos --no-fatal-warnings lib/features/activity_cards test/features/activity_cards lib/main_preview.dart test/core/navigation/app_shell_test.dart` | **10 issue: 8 `info prefer_initializing_formals` + 2 `warning unused_import`** (`main_preview.dart:119`, `app_shell_test.dart:23`). **Không issue nào rơi vào dòng vòng vá này chạm** — cả 10 đều có trước `4940e26` |

Sáu file implementer giả của hợp đồng (`main_preview.dart`, 5 file test) đều đã
cập nhật chữ ký `Future<int>`, nên cây nguồn biên dịch sạch — đây là điều
`master-plan.md` ghi là chưa làm được lúc lập kế hoạch §7.9.

### 3. Phát hiện

| id | Loại | Nội dung | Chủ |
|---|---|---|---|
| P2-F-1 | HOÃN — rủi ro tồn đọng, **không** chặn | Ghi full-snapshot không có khoá tuần tự: `_persist` chụp `state.card` **đồng bộ** trước `await`, rồi ghi cả 11 cột. Hai mutator chồng nhau (ví dụ blur-commit một ô chữ rồi chạm chip trong cùng cử chỉ) cùng dựng từ một ảnh chụp cũ, và lệnh ghi thứ hai lặng lẽ ghi đè lệnh thứ nhất — cả trong store lẫn trên màn. Không có version/rowversion, không có hàng đợi. **Không xếp là chặn** vì trước vòng này sửa trường không được lưu chút nào, nên đây là cải thiện có lỗ dư, không phải hồi quy; và cửa sổ chồng lấn hẹp (Flutter không tự bỏ focus khi chạm ra ngoài). | mobile-dev / tech-lead, nếu có story sau thêm ô nhập đồng thời |
| P2-F-2 | **CẦN VÁ ở vòng sau — bằng chứng mỏng nhất của vòng này** | Đường ghi *người dùng thật sự đi* trong `activity_card_detail_screen.dart` — 5 `FocusNode` + `_commitOnBlur` + `onSubmitted`, và quy tắc S6-F-6 "tiêu đề rỗng thì trả field về giá trị store đang giữ" — **không có một test widget nào**. `activity_card_detail_screen_test.dart` trong diff này chỉ sửa chữ ký fake. B-2 được chứng minh ở tầng cubit bằng fake, không ở tầng màn hình. Seam do chính vòng vá này tạo ra là seam duy nhất chưa ai đo. | mobile-dev |
| P2-F-3 | INFO — khiếm khuyết handoff, cần sửa trước lượt sau | Dòng `Do Not Re-read` của dispatch ghi `activity_card_detail_screen.dart` và `activity_card_detail_screen_test.dart` là "unaffected by this diff scope". Sai: cả hai **có** trong `4940e26..c92fd1b` (+94/−29 và +9/−6) và mang toàn bộ nửa giao diện của B-2. Nếu lượt sau tin dòng đó, đường ghi của `c92fd1b` lại đi qua mà không ai đọc — đúng thất bại mà lượt final-synthesis vừa bắt được. | Scrum Master — dựng `Do Not Re-read` từ `git diff --name-only` của **chính slice đó**, không từ slice khác |
| P2-F-4 | HOÃN — hành vi có chủ ý, đáng ghi | `updateStatus` chỉ ghi cột `status`, **không** chạm `updated_at`, trong khi `updateCardDetails` luôn đặt `updatedAt: DateTime.now()`. Test repository ghim chủ ý này (`…without touching other columns or updated_at`). Hệ quả: một lần chuyển trạng thái để `updated_at` cũ, nên bất kỳ sắp xếp "mới nhất" nào sau này sẽ xếp sai thẻ vừa đổi trạng thái. | tech-lead, khi có story sắp xếp theo thời gian |
| P2-F-5 | HOÃN — nhỏ | `_withEdits` giữ nguyên `updatedAt` cũ sau một `_persist` thành công, nên `state.card.updatedAt` lệch với store cho tới lần đọc lại. Test `card_lifecycle_ui_test` **ghim** độ lệch này (`expect(card.updatedAt, DateTime(2026, 9, 8))` sau 4 lần ghi). Vô hại hôm nay; sẽ lộ nếu màn detail hiển thị "cập nhật lúc". | mobile-dev |
| P2-F-6 | GHI NHẬN — đã đóng ở nơi khác | `master-plan.md` sau vòng vá tự khai P8 còn treo gate cấp story (`flutter analyze lib test`, `flutter test`, startup smoke R-2) tại thời điểm `c92fd1b`. Các gate đó đã được các vòng P9/P10 sau đó phủ (S9-F-2, S9-F-5 đều **ĐÓNG** ở phần đầu báo cáo). Không mở lại ở đây. | — |

### 4. Ảnh hưởng tới trạng thái story

- Nguyên nhân chặn `REVIEW_EVIDENCE_GAP_UNREVIEWED_PATCH_ROUND` **đã được gỡ**:
  `c92fd1b` nay đã qua mắt reviewer, với chứng cứ tự chạy chứ không phải hồ sơ
  tự khai của lane. **B-1, B-2, B-4, B-3 và B-6 nửa mã: ĐÓNG.**
- Sáu mục deferred từng bị gộp vào vòng vá này (S2-F2-1, S2-F2-3, S4-F-3,
  S4-F-4/S6-F-2, S5-F-4, S6-F-6) không còn ở trạng thái "chưa xác minh" chung
  với B-2. S5-F-4 đã xác minh ĐÓNG (fallback cuộn ngang). S6-F-6 đã hiện thực
  (`_commitTitle` khôi phục tiêu đề) nhưng **chưa có test** — xem P2-F-2.
- **Vẫn CÒN MỞ, ngoài phạm vi lượt này**: B-6 nửa bản ghi bền vững, R-1, M-1,
  M-3, M-5, M-6.
- Lượt này **một mình không** làm story đủ điều kiện merge, và cũng **không**
  còn là thứ ngăn nó: dòng `Outcome:` ở đầu file thuộc một lượt final-synthesis
  mới, lượt đó nay có đủ chứng cứ cho toàn bộ nhánh B-* và chỉ còn phải xử các
  mục M-*/R-1 cùng nửa bản ghi của B-6.
- Không phát hiện nào của lượt này xếp loại chặn.

REVIEW_COMPLETE: YES
