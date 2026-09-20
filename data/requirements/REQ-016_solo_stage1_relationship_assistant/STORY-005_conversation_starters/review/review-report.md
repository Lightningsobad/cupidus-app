# Review Report — STORY-005 Mồi chuyện (compact story review)

Reviewer: Iris-QC · Date: 2026-09-17 · Mode: compact-story-review
Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-005_conversation_starters`
Worktree HEAD: `5be5a4df` · Diff baseline used: `b58afbe0` (merge-base with
`codex/REQ-016_solo_stage1_relationship_assistant-integration`)

Outcome: DEFERRED_ONLY

## Scope Gate

- Lane: mobile-only, đúng `story_master.md` và `architecture/solution.md` §1
  Key Discovery 1. Không có lane backend — nhất quán với AC-15/AC-16.
- Diff chạm 45 đường dẫn: 2 asset pack, 14 file `mobile/lib`, 15 file
  `mobile/test`, phần còn lại là artifact story. Không file nào nằm ngoài
  `mobile/` hoặc ngoài thư mục story.
- `git status` trong worktree sạch; không có PNG của story khác bị ghi đè.
- **Lệch handoff (không chặn):** `BaseHead: 3ff29be4` trong handoff là commit
  P4, không phải điểm rẽ nhánh. Diff từ giá trị đó chỉ ra `story_master.md`.
  Review này dùng merge-base thật `b58afbe0`. Scrum Master nên sửa `BaseHead`
  trong run file trước vòng review kế tiếp.
- Không đụng `pubspec.yaml`, không thêm dependency, không thêm route vào shell
  điều hướng (màn push bằng `MaterialPageRoute` từ ô lối-vào-nhanh).

## Risk Surface → Critical Gate

| Risk surface (`master-plan.md` §3A) | Gate | Kết quả |
|---|---|---|
| Cổng nhập nội dung R-15c (AC-29) | `starter_content_gate_test.dart` đọc 2 pack thật trên đĩa; 12 `StarterGateRule` đều có ≥1 ca âm | `+38 All tests passed!` — ĐẠT (xem F-1) |
| Hết-vòng với mọi N (AC-27/AC-28) | `starter_selector_test.dart` tham số hoá N ∈ {1,2,3,4,10,137}, chu kỳ suy ra từ `n ~/ gcd(perPage,n)`; widget test bảng bấm→id với N=2 và N=12 | ĐẠT |
| Tất định (AC-17) | hai lần gọi cùng đầu vào trả đúng cùng `id`+`text`; `stableContentKey` không dựa `String.hashCode`; domain không gọi `DateTime.now()` | ĐẠT |
| Không mạng / không AI (AC-15/AC-16) | chạy trọn luồng dưới `HttpClient` ném lỗi nếu bị mở; không import HTTP trong feature tree; không dependency lịch âm | ĐẠT |
| Ghi thẻ đúng hợp đồng STORY-001 (AC-11/AC-12) | thẻ `status=idea`, `origin=conversationStarter`, `scheduledOn` = ngày sự kiện; bấm hai lần chỉ 1 thẻ; `fromWireValue` vẫn đọc 4 giá trị cũ, giá trị mới append cuối | ĐẠT |
| Migration Drift 6→7 | 6 test migration; 5 bảng client-owned giữ nguyên hàng qua upgrade; nhánh `if (from < 7)` chỉ `CREATE TABLE`, không `DROP`; 11 điểm hằng số `schemaVersion` sửa cùng commit | ĐẠT |
| Visual fidelity màn (6) | `VISUAL_FIDELITY: PASS`, ảnh đã mở ra nhìn (dấu tiếng Việt đúng, `content_copy`/`close` không tofu), đối chiếu 13 mục `uiux-spec` §2 | ĐẠT (xem F-3) |

## Build / Analyze / Test Evidence

| Gate | Lệnh | Kết quả |
|---|---|---|
| Build | `flutter build apk --debug` (nguồn: runtime registry `mobile-app.buildCommand`) | `✓ Built .../app-local-debug.apk` 51.9s |
| Static analysis | `flutter analyze lib test` | exit 1, **0 error**, 35 warning, 198 info. Nền repo phi-zero có sẵn (đã xác lập ở các story trước); 0 error là gate đúng. Không warning nào rơi vào file của story |
| Analyze thu hẹp | `flutter analyze --no-fatal-infos --no-fatal-warnings` trên file đã đụng (P1, P2, P3) | `No issues found!` (P1, P2); P3 còn 4 `info` thuộc nhóm lint có sẵn, 0 error/warning |
| Unit/widget | P1 `+38`, P2 `+13`, P3 `+41`, P4 `+103 ~1` | tất cả xanh |
| Hồi quy | `test/core/database + activity_cards + conversation_starters` `+346 ~2`; `conversation_starters + activity_cards + gift_ideas + context_notebook` `+508 ~8` | xanh, skip là nợ có sẵn |
| Capture thị giác | `conversation_starters_screen_test.dart --dart-define=CAPTURE_VISUALS=true` | `+19: All tests passed!` |

3 test đỏ ở `test/design_system` được khai là nợ có sẵn. Đã đối chiếu: cả 7+2
đường dẫn bị tố (`activity_card_detail_screen.dart`,
`reminder_schedule_screen.dart`, `skill_profile_screen.dart`,
`quick_capture_sheet.dart`, `gift_ideas_screen.dart`, `service_locator.dart`,
màn chat…) **không** nằm trong diff của story. Khai báo nhất quán với diff —
chấp nhận. Guard này đã bắt đúng một chỗ do P4 gây ra
(`conversation_starters_screen.dart:204`) và chỗ đó đã sửa.

## AC Coverage

Có bằng chứng trực tiếp: AC-1..AC-9, AC-11..AC-18, AC-20..AC-22, AC-26..AC-30.
AC-19/AC-23/AC-24 phủ gián tiếp bằng test cấm-chuỗi/cấm-widget của AC-27
(không `%`, `đã hết`, `còn lại`, `streak`, `chuỗi ngày`, `điểm`; không
`Checkbox`/`Switch`/`Slider`/progress) cộng với việc không tồn tại đường mạng
nào — đủ cho compact tier, không cần ca kiểm riêng.

AC-25 (kiểm duyệt hai lớp SB-123) là quy trình biên tập trước bản build người
dùng thật, không phải cổng chạy được của story này — đúng nguyên văn AC-25 sau
khi D-15 tách hai vai trò. Không tính là thiếu bằng chứng.

## OQ Decisions

- **OQ-3 ĐÃ ĐÓNG 2026-09-06 bằng D-15 → R-15.** Cả ba nhánh đều được tôn trọng:
  R-15a (hai gói asset có `schema_id` + `id` bền từng mục, không chuỗi nội dung
  trong Dart/l10n — có test quét `lib/**`), R-15b (không hằng số đếm seed ở đâu;
  N suy ra từ dữ liệu), R-15c (cổng nhập chạy được làm đỏ suite).
- **OQ-2** không thuộc story này (STORY-001) — không có dấu vết vi phạm.
- SB-144/145/146 (trò "đoán") **không** ship — đúng `story_master.md` Out of
  Scope. Bản B feed tin thật cũng không có phiên bản rút gọn nào (AC-19/BR-7).

## Findings

**F-1 — DEFERRED (AC-29, mệnh đề "nội dung do CMS ngoài repo cấp").**
`validateStarterPacks` chỉ được gọi từ `starter_content_gate_test.dart`; đường
nạp runtime (`ConversationStartersCubit.load` → `ContentPackageLoader`) chỉ
parse cấu trúc, không chạy cổng bất biến. Với build hiện tại điều này **không
phải lỗi**: AC-15/AC-16 cấm mọi nguồn nội dung ngoài asset ship kèm, nên không
tồn tại đường CMS để lọt qua, và `validateStarterPacks` là hàm thuần nhận
`ContentPackage` nên đã gọi được trên bất kỳ nguồn nào. Ghi lại để story/
requirement nào mở nguồn nội dung ngoài repo phải nối cổng này vào đường nạp
trước khi render. Không chặn STORY-005.

**F-2 — DEFERRED, cần phán quyết cấp requirement (AC-18).**
`master-plan.md` §6 note A-1 chốt rằng AC-18 ("ngày lịch âm **tính** tất định
trên thiết bị") được thoả bằng ngày dân dụng chốt sẵn trong
`calendar_events.v1.json` (`"calendar": "lunar"` chỉ là provenance), theo quy
ước `occasions.v1.json` STORY-001 đã ship. Đọc theo nghĩa đen, AC-18 đòi một
**phép tính**; cài đặt hiện tại thoả "tất định" và "không lấy từ dịch vụ ngoài"
nhưng không thoả "tính". Đây là lệch câu chữ AC, không phải lỗi cài đặt — thuộc
Design/Requirement Ruling của Product Owner, cùng hạng với D-series trong
`req_master.md` `## Design Ruling Log`. Hệ quả dữ liệu: gói chỉ ship 2 lần xuất
hiện mỗi sự kiện (tới 2028), cạn lịch sau đó là thuộc tính dữ liệu theo AC-30.

**F-3 — DEFERRED, 8 điểm `DESIGN_SPEC_CONFLICT` chờ ruling.**
`visual-fidelity/visual-fidelity-report.md` §6 ghi 8 điểm canvas `(6) Mồi
chuyện A / A+` lệch `uiux-spec.md`/`requirements.md`. Mobile-dev đã làm đúng
việc: ship theo spec/AC và **không** tự sửa về phía canvas. Phân loại lại để
Scrum Master định tuyến:
- Điểm 1 (tab "Đoán thử", "Tuần này có gì"), 4 (dòng trấn an), 6 (nút bỏ qua),
  7 (dòng lý do), 8 (ô hỏi tại chỗ): **AC quyết định, đã đóng.** Không cần
  ruling — SB-144/145/146 hoãn, bản B out of scope, AC-27 cấm gợi ý "còn lại",
  AC-14 và AC-6 đòi đúng thứ đã ship.
- Điểm 2 (hero + cặp phụ vs 3 dòng ngang hàng), 3 (nhãn "Chép để nhắn" + icon
  `refresh`), 5 (nhãn khối/nút): **thuần spec-vs-canvas, chưa có AC nào chạm
  tới.** Tiền lệ D-1/D-2/D-3/D-18/D-19 trong `req_master.md` là "Design canvas
  thắng" khi user chọn anchor-on-design. Ba điểm này cần một phán quyết của
  user/PO chứ không phải của Reviewer, và nếu canvas thắng thì đó là phạm vi
  implementation mới, không phải lỗi của STORY-005.
- `Design-Screen: 6-moi-chuyen-a-a` là **suy ra**, chưa liệt kê xác nhận, vì
  trình dựng canvas trả `VISUAL_RUNTIME_MISSING` (install defect của runtime,
  ngoài lane Mobile). Cần DevOps cấp lại trình dựng rồi xác nhận id; không phải
  nợ của Mobile.

**F-4 — DEFERRED, sai trích dẫn artifact trong tài liệu.**
`coding-plan/test-results.md` mục P4 khai nhãn "Xem câu khác" đến từ **cả**
`ux/uiux-spec.md` §2.2 **và** `requirements/requirements.md`. Grep cho đúng một
match trong toàn bộ thư mục story — nhãn chỉ nằm ở `uiux-spec.md`. Quyết định
ship không đổi (uiux-spec là artifact ràng buộc của story); chỉ sửa câu trích
dẫn khi có dịp chạm vào file này. Không chặn.

## Residual Risks

- Gói sự kiện cạn lịch sau 2028; AC-30 đã đặt đó là thuộc tính dữ liệu, nhưng
  chưa có cơ chế nhắc cập nhật gói. Thuộc vận hành nội dung, không thuộc story.
- `handledEventIds` không phân biệt `converted` và `dismissed`; P4 hiện không
  cần, nhưng STORY-007 (đọc lại kho mồi) có thể cần — đã ghi rõ trong ghi chú
  hợp đồng P2→P3.
- Badge ngày chỉ hiện `dd/mm`, không năm. Với gói hiện tại mọi sự kiện đều
  trong vòng ~16 tháng nên không mơ hồ; nếu gói mở rộng nhiều năm thì cần xem
  lại theo AC-10.

## Recommendation

Story đạt cổng review. Mọi risk surface được `master-plan.md` §3A đặt tên đều
có cổng tới hạn tương ứng chạy xanh, có build gate và analyze gate từ runtime
registry, và không có phát hiện nào cần vá code trước khi merge. Bốn phát hiện
đều là nợ hoãn được: F-1 là ràng buộc cho story mở nguồn CMS, F-2 và F-3 cần
phán quyết cấp requirement của Product Owner/user, F-4 là đính chính câu chữ.

Đề nghị Scrum Master:
1. Cho phép merge story branch vào `codex/REQ-016_solo_stage1_relationship_assistant-integration`.
2. Sửa `BaseHead` trong run file STORY-005 sang merge-base thật.
3. Đưa F-2 và các điểm 2/3/5 của F-3 vào hàng đợi Design/Requirement Ruling của
   REQ-016; không mở lại trước khi có quyết định của user.
4. Ghi `VISUAL_RUNTIME_MISSING` thành việc của DevOps để xác nhận
   `Design-Screen:` và dựng lại được ảnh design reference.

REVIEW_SLICE_COMPLETE: NOT_APPLICABLE (compact tier, không chia slice)
