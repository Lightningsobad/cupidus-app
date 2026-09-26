# STORY-007 — Slice P5: gợi ý "chốt việc kế tiếp"

Outcome: PARTIAL_SLICE_ONLY

**Kết luận slice P5: PASS — không có phát hiện chặn.** Đây là phán quyết của
riêng slice 5/5; phán quyết cấp story thuộc về pass final-synthesis.

- Review type: `scoped-slice` (slice 5 trên 5)
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`
- BaseHead: `bfe231aa` · HEAD lúc review: `8dbf2806`
- Ngày: 2026-09-24

## 1. Phạm vi đã soi

| File | Vai trò trong P5 |
|---|---|
| `mobile/lib/features/activity_cards/thank_you/domain/next_plan_suggestion_service.dart` (+132) | nguồn gợi ý, `accept`/`undo`, nạp gói |
| `mobile/lib/features/activity_cards/thank_you/presentation/next_plan_cubit.dart` (+81) | state phần 3, không cờ loading |
| `mobile/lib/features/activity_cards/thank_you/presentation/widgets/next_plan_section.dart` (+176) | header + chip + snackbar hoàn tác |
| `mobile/test/features/activity_cards/thank_you/next_plan_test.dart` (+422) | 13 test của P5 |
| `mobile/lib/features/activity_cards/domain/activity_card.dart` (+3/-1) | **P5 nhận là bằng chứng của mình** (mục 3) |

Đọc thêm để đối chiếu hợp đồng (không thuộc phạm vi phán quyết P5):
`activity_card_repository.dart`, phần nối dây phần 3 trong
`thank_you_block.dart` (`_resolve()` / `_block()`),
`requirements/requirements.md` mục AC-19..AC-36 và BR-11..BR-18,
`coding-plan/test-results.md` §P5.

## 2. Đối chiếu AC (văn bản AC đã đọc trực tiếp từ `requirements/requirements.md`, không lấy từ handoff)

| AC / BR | Yêu cầu | Kết quả | Bằng chứng |
|---|---|---|---|
| AC-19 | 2-3 gợi ý, tất định, không AI/API ngoài | PASS | `suggest()` là `static` + đồng bộ, thuần theo (gói, today, slots); sort theo `date` rồi `id` nên thứ tự gói không đổi kết quả (`next_plan_suggestion_service.dart:87-90`); `maxNextPlanSuggestions = 3`; test `cùng gói và cùng ngày thì trả về đúng một tập, đúng một thứ tự`, `hai dịp trùng ngày vẫn có thứ tự cố định` |
| AC-19 (nguồn) | "kho mồi STORY-005 **hoặc** dịp lịch âm gần nhất" | PASS | Chọn nhánh **gói dịp**, giải ngày bằng chính `nearestUpcomingDate` của STORY-005 chứ không tự tính lịch âm. Lý do ghi trong `next_plan_suggestion_service.dart:38-53` và `test-results.md` §P5 "Nguồn gợi ý đã chọn". AC dùng chữ "hoặc", nên đây là lựa chọn hợp lệ, không phải thay thế AC |
| AC-20 | Chạm → thẻ *Mới nghĩ ra* qua đúng hợp đồng STORY-001, không phải đường tạo thẻ thứ hai | PASS | `accept()` gọi `ActivityCardRepository.createCard` (`:101-109`); `NewActivityCard` **không có** trường `status` (`activity_card.dart:243-256`) nên không có đường nào ghi status khác `idea`; không có lời gọi DAO nào trong `thank_you/` cho thẻ. Test `chạm một chip tạo ngay thẻ *Mới nghĩ ra* trong kho chung` khẳng định `status == idea` **và** đọc qua `repository.cardsByStatus(idea)` (kho chung, không phải danh sách riêng) |
| AC-20 (xác nhận) | "chọn một gợi ý **và xác nhận**" | PASS | Chạm chip *là* bước xác nhận, không dialog; bù lại bằng snackbar hoàn tác 5 giây (`next_plan_section.dart:142-162`). Đọc cùng AC-23 ("bỏ qua không tốn thao tác nào") thì thêm một dialog xác nhận mới là thứ AC-23 cấm |
| AC-21 | Thẻ mang sẵn ngày của dịp, sửa được ngay | PASS | `scheduledOn: suggestion.date` (`:105`); test `ngày điền sẵn ... vẫn sửa được như mọi thẻ khác (AC-21)` sửa thật qua `updateCardDetails` và đọc lại `2026-10-06` |
| AC-22 | Không chọn gì → không thẻ, không nhắc lại, không dấu chưa-hoàn-thành | PASS | Test `đóng khối mà không chọn chip nào thì không tạo gì (AC-22)`: sau khi đóng, `ideas()` rỗng và khe phần 3 biến mất. Không có cờ pending nào trong `NextPlanState` (`next_plan_cubit.dart:17-28`) |
| AC-23 | Trình bày là **tuỳ chọn**, không chặn, không hỏi lại | PASS | Header ghi thẳng `HẸN NHAU LẦN TỚI · KHÔNG BẮT BUỘC` (`next_plan_section.dart:48-52`); không route chặn, không dialog; chip giữ nguyên bậc hành động phụ (viền `colorLine`, nền `colorSurface`, không gradient) |
| AC-24 | Thẻ mang nguồn sinh đọc được theo STORY-001 AC-9, không bao giờ hiện như chỉ số đánh giá | PASS | `ActivityCardOrigin.nextPlanAfterDate('next_plan_after_date')`; enum tự ghi "internal only and never rendered as a metric" và P5 không thêm chỗ render nào cho `origin` |
| AC-25 / AC-28 | Không trách móc, không streak/bộ đếm/huy hiệu | PASS | Chip không biến mất sau khi chạm và không có dấu "đã chốt"; dòng phụ duy nhất là `_countdown` — đếm ngày **tới một dịp**, không đếm hành vi người dùng (`next_plan_section.dart:166-175`) |
| AC-29 / AC-30 | Ngoại tuyến vẫn chạy; không AI, không dịch vụ nội dung ngoài | PASS | `loadPackage` chỉ đi qua `ContentPackageLoader` (asset), không HTTP client, không model call trên đường này; `NextPlanState` cố ý không có cờ `loading` nên không có bề mặt nào để cắm một lần gọi mạng vào |
| AC-35 | N nhỏ → render phần có sẵn, không ô trống, không màn rỗng; N rất lớn → không đổi, không bước tải mới | PASS | N=1 → 1 chip; N=0 → **khe** phần 3 vắng hẳn khỏi cây widget (không phải header trống) — `thank_you_block.dart` `_block()` truyền `nextPlan: null` khi `state.suggestions.isEmpty`; N=500 → vẫn 3 chip đầu, hàm đồng bộ nên không có `await` để treo spinner. Test `gói rất lớn không đổi kết quả và không thêm bước chờ nào` |
| AC-36 / BR-18 | Câu dẫn có giọng điệu do phần 3 sinh ra phải qua cổng nhập của STORY-002 | N/A theo cấu trúc | P5 **không sinh câu dẫn nào**: chữ trên chip là `event.name` đọc nguyên văn khỏi gói, phần còn lại là chrome giao diện. Không có nhánh cổng thứ hai được dựng (đúng yêu cầu "story này không thêm nhánh cổng riêng") |
| BR-11 | Tạo thẻ qua đúng một đường, vào kho chung duy nhất | PASS | Như AC-20; không có "danh sách việc kế tiếp" thứ hai — phần 3 không giữ state thẻ nào sau khi ghi |
| BR-16 | Cấm chuỗi **preset** nằm trong widget/code | PASS | Chuỗi cứng trong `next_plan_section.dart` chỉ là chrome (nhãn mục, "Hoàn tác", "còn N ngày"); mọi chữ mang nội dung đều đọc khỏi gói. BR-16 ràng buộc danh mục preset (phần 1), không ràng buộc chrome |
| BR-17 | Dải 2-3 là tham số bố cục, không ràng buộc lên N | PASS | `maxNextPlanSuggestions` là hằng bố cục có tài liệu; `slots` là tham số truyền được; không AC nào của P5 suy ra từ số mục seed |

## 3. Hai mục mở trong handoff — phán quyết

**(1) `mobile/test/features/before_you_go/before_you_go_block_test.dart` (+16):
KHÔNG thuộc P5. Thuộc P1 (sổ kích hoạt).**

Toàn bộ diff là đăng ký `CupidDatabase(NativeDatabase.memory())` vào `getIt` ở
`setUp`, cộng `tearDown` reset/close. Comment đi kèm nói rõ lý do: thẻ *Đã đi
rồi* nay chạm vào sổ kích hoạt của STORY-007 **qua composition root**. Nguyên
nhân là P1 bọc `ActivityCardRepository` bằng `ThankYouActivationAwareCardRepository`
trong `service_locator.dart`, khiến test của STORY-006 cần một database đăng ký.
Không có ký tự nào liên quan tới next-plan. Đây là nới harness do P1 gây ra, đã
đóng được mục advisory mà P2 nêu.

**(2a) `mobile/lib/core/di/service_locator.dart` (+34/-3): KHÔNG thuộc P5.
Thuộc trọn vẹn P1.**

Diff chỉ gồm: import 6 file `thank_you/…activation…`, đăng ký
`ThankYouActivationRepository` / `ThankYouActivationService` /
`ThankYouActivationCardStatusListener`, và bọc `ActivityCardRepository`. **Không
có một dòng nào đăng ký `NextPlanSuggestionService` hay `NextPlanCubit`** —
đúng như thiết kế: cả hai được dựng tại chỗ trong `thank_you_block.dart`
`_resolve()` và lấy kho thẻ qua `getIt<ActivityCardRepository>()` đã đăng ký
sẵn. P5 không thêm hàng nào vào composition root.

**(2b) `mobile/lib/features/activity_cards/domain/activity_card.dart` (+3/-1):
THUỘC P5 — P5 nhận làm bằng chứng của mình.**

Đúng một giá trị enum thêm vào cuối: `nextPlanAfterDate('next_plan_after_date')`.
Đây là hiện thực trực tiếp của AC-24 và không có đường vòng: `NewActivityCard.origin`
có kiểu `ActivityCardOrigin`, không nhận chuỗi. Giá trị nằm **đúng cuối**, đúng
luật append-only mà enum tự ghi. Không cần migration: cột `origin` là `text()`
thuần, không CHECK constraint — đã đối chiếu và đồng ý với lập luận ở
`test-results.md` §P5 "Sai lệch so với handoff". P5 sửa một file ngoài WriteScope
của phase; Scrum Master cần ghi nhận, nhưng đây **không** phải phát hiện chặn.

## 4. Bằng chứng test — lệnh thật, kết quả thật

```
cd <Worktree>/mobile && PATH="$HOME/flutter/bin:$PATH" \
  flutter test test/features/activity_cards/thank_you/next_plan_test.dart --reporter expanded
00:00 +7: phần 3 trong khối — tạo thẻ qua đúng một cửa (AC-20, AC-21) chạm một chip tạo ngay thẻ *Mới nghĩ ra* trong kho chung
00:01 +8: phần 3 trong khối — tạo thẻ qua đúng một cửa (AC-20, AC-21) ngày điền sẵn của thẻ vẫn sửa được như mọi thẻ khác (AC-21)
00:01 +9: phần 3 trong khối — tạo thẻ qua đúng một cửa (AC-20, AC-21) chạm chip xong có snackbar hoàn tác, và hoàn tác xoá sạch thẻ
00:01 +10: phần 3 trong khối — tạo thẻ qua đúng một cửa (AC-20, AC-21) đóng khối mà không chọn chip nào thì không tạo gì (AC-22)
00:01 +11: phần 3 trong khối — tạo thẻ qua đúng một cửa (AC-20, AC-21) gói không còn dịp nào thì khe phần 3 vắng hẳn khỏi cây widget
00:01 +12: phần 3 trong khối — tạo thẻ qua đúng một cửa (AC-20, AC-21) nhiều dịp thì các chip cùng cỡ, không chip nào được nhấn mạnh
00:01 +13: All tests passed!
```

13/13 xanh. Reporter `expanded` được dùng có chủ ý: tổng `+13` không chứng minh
tên test nào tồn tại, danh sách liệt kê thì có. Mọi test P5 khai trong
`test-results.md` §P5 đều thật sự tồn tại và chạy.

`git status --porcelain` trong worktree sau lần chạy: **rỗng** — không PNG
visual-fidelity của story nào bị ghi đè, không file nào bị bẩn.

## 5. Đỏ có sẵn — đã có bug, KHÔNG phải hồi quy của P5

`calendar_event_service_test.dart:390` ghim `ActivityCardOrigin.values` đúng **5**
phần tử. Tôi đã tự kiểm chứng tại **BaseHead của review này** (không dùng lại
con số của implementer, người trích BaseHead `d684c7e5` khác):

```
git show bfe231aa:mobile/lib/features/activity_cards/domain/activity_card.dart
  manual, pastedLink, occasionSuggestion, giftSuggestion,
  conversationStarter, compatibilityLookup   → 6 phần tử
```

6 ≠ 5 ⇒ test đã đỏ **trước** P5. P5 làm danh sách thành 7, nhưng kiểu hỏng không
đổi và bất biến mà test định bảo vệ ("giá trị mới nằm cuối") vẫn giữ nguyên.
Đã có hàng `BUG-20260923-002_conversation_starters_enum_pinned_assertion_lag`
trong `data/bugs/master_bugs_list.md` trỏ đúng `calendar_event_service_test.dart:390`.
**Không mở bug mới.** Theo luật triage (vấn đề có sẵn là DEFERRED trừ khi story
làm nặng thêm), đây là DEFERRED, không chặn.

## 6. Advisory (không chặn, chuyển cho final-synthesis / Scrum Master)

| # | Nội dung | Mức |
|---|---|---|
| A1 | `NextPlanCubit.load()` nạp gói không có `try/catch`. Gói asset hỏng/thiếu sẽ ném lỗi bất đồng bộ **không ai bắt** (chuỗi `unawaited(_resolve())` từ `initState`). Giao diện vẫn "an toàn" (khe phần 3 vắng), nhưng P4 đã bọc `try/catch` cho đường nạp ảnh với lý do AC-25 — đường nạp gói ở P5 nên đối xứng. Không test nào phủ ca này | Low — đề xuất cải thiện |
| A2 | `unawaited(_accept(context, cubit))` ở `next_plan_section.dart:90`: nếu `createCard` ném lỗi thì không snackbar, không thông báo, lỗi rơi vào unhandled async. Xác suất thấp (ghi local SQLite) nhưng là đường ghi duy nhất của phần 3 | Low |
| A3 | P5 sửa `activity_card.dart` **ngoài WriteScope của phase** (xem mục 3). Lý do chính đáng và đã tự khai trong `test-results.md`, nhưng cần Scrum Master ghi nhận chính thức | Ghi nhận |
| A4 | BR-14 ("văn bản gợi ý ở phần 3 nói về người kia phải kết bằng câu hỏi") không có test nào ở P5. Theo cấu trúc thì không áp dụng được — chữ trên chip là tên dịp đọc khỏi gói STORY-005, không phải câu nói về người kia — nhưng chuỗi bảo đảm này nằm ở cổng nhập của STORY-005, P5 không kiểm chứng lại | Info |
| A5 | Cổng entry-point và visual-fidelity của phần 3 nằm trong bằng chứng của P2/P4 (ảnh `implemented-sb-212-…-ios.png` có ba chip phần 3, `VISUAL_FIDELITY: PASS` kèm ba delta đã chấp nhận). P5 **không** phán quyết lại; cặp `PASS` + `DESIGN_SPEC_CONFLICT` mà P4 nêu vẫn là việc của final-synthesis | Chuyển tiếp |

## 7. Khuyến nghị

Slice P5 không chặn. Không có việc nào phải quay lại lane hiện thực vì P5.
Ba delta thiết kế của phần 3 (ba hàng thay vì hai; dấu `+` đặc thay vì `⊕`
viền; mọi hàng đều có dòng ngày) đã được ghi trong `visual-fidelity-report.md`
và hàng đầu trong số đó là **hệ quả trực tiếp của AC-35** (dải 2-3 là tham số
bố cục) — final-synthesis nên đọc nó cùng phán quyết `DESIGN_SPEC_CONFLICT` của
P4 thay vì như một delta riêng lẻ.
