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
