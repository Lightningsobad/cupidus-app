# Test Results – STORY-009 Chân dung "theo cách BẠN nhìn"

## Phase P1 – Ba gói nội dung chân dung và cổng nhập chạy được

- Status: COMPLETE
- Lane: Mobile
- Last updated: 2026-09-11
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-009_your_view_portrait`
- Flutter resolution: `FLUTTER_SDK_PATH` default `$HOME/flutter` (không có
  `flutter` trần trên PATH máy này); `flutter gen-l10n` chạy trước mọi lệnh khác
  trong worktree mới.

### Commands run

| # | Command (cwd `mobile/`) | Result |
|---|---|---|
| 1 | `flutter gen-l10n` | OK (dùng `l10n.yaml`) |
| 2 | `flutter test test/features/your_view_portrait/portrait_content_gate_test.dart` | `+48: All tests passed!` |
| 3 | `flutter test ... --plain-name "the packs on disk report no violation"` sau khi **cố ý làm hỏng** một clause thật trong `portrait_sections.v1.json` | `+0 -1: Some tests failed.` `EXIT=1` — cổng bắt được `assertive_claim` và `illegal_opening_frame` (bằng chứng đỏ có chủ đích) |
| 4 | `flutter test test/features/your_view_portrait/ test/features/context_notebook/ test/features/before_you_go/ test/features/gift_ideas/ test/features/invite_composer/` | `+446 ~7: All other tests passed!` `EXIT=0` (7 skip có sẵn từ trước) |
| 5 | `flutter analyze <7 đường dẫn đã chạm>` | `1 issue found` — đúng một `info • prefer_initializing_formals` **đã có sẵn** ở `lib/core/content/content_package.dart:208`, file P1 không sửa. 0 error, 0 cảnh báo mới. Nền của repo khác 0 nên tiêu chí là "không lỗi mới", không phải exit code. |

Lệnh đỏ ở dòng 3 được chạy trên asset thật rồi hoàn nguyên; nội dung trên đĩa
hiện tại là bản sạch đã qua dòng 2 và dòng 4.

### Deliberate red run – exact gate output

```
'req016.portrait_sections/portrait.section.own_days.v1 [assertive_claim]: text uses the denylisted term "người ấy là"',
'req016.portrait_sections/portrait.section.own_days.v1 [illegal_opening_frame]: clause "Người ấy là kiểu giữ {ngay_rieng} cho riêng mình." does not open with one of the legal frames'
```

Một chuỗi hỏng trong **gói asset thật** làm đỏ bản dựng, không chỉ làm đỏ một
fixture — đúng yêu cầu AC-36/AC-37/BR-17.

### AC coverage – Phase P1

| AC / BR | Cách phủ | Bằng chứng |
|---|---|---|
| AC-31 (a) cổng nhập chạy được | `validatePortraitPacks(...)` + test quét đĩa | lệnh 2, 3 |
| AC-31 (b) truy vết duyệt theo id bền | `editorial_review` trên mọi item của cả ba gói; `PortraitEditorialReview` parse theo id | lệnh 2 |
| AC-33 gói có lược đồ + id bền | ba `schema_id` riêng, `ContentPackage.parse` chốt `expectedSchemaId`; test tham chiếu chéo `ask_id`/`question_id` | lệnh 2 |
| AC-34 N là thuộc tính dữ liệu | nhóm test "pack size is data" chạy gate trên gói 1 mục và gói 7 mục, cùng kết quả | lệnh 2 |
| AC-35 app không tự khẳng định | luật mới `assertiveClaim` + `illegalOpeningFrame` trên MỌI clause | lệnh 2, 3 |
| AC-36 cổng ĐẦU RA làm hỏng bản dựng | 7 luật `InvariantRule` chạy trên prompt/chips/heading/clause/ask | lệnh 2, 3 |
| AC-37 cổng ĐẦU VÀO của bộ câu hỏi | `NotebookBoundaryRule` chạy trên câu hỏi có `target` là `notebook.*`; test chứng minh phạm vi (câu `portrait.guess` không bị chặn) | lệnh 2 |
| AC-22 tiền đề (ranh giới sổ tay) | không câu `notebook.*` nào hỏi tần suất/hành vi/phán xét — cưỡng chế ở cổng, không phải quy ước | lệnh 2 |
| AC-13 / BR-4 khuôn câu mở đầu | `portraitLegalOpeningFrames` là hằng Dart; test khẳng định gói KHÔNG khai lại danh sách khung | lệnh 2 |
| AC-19 / R-1g mỗi phần kết bằng câu để hỏi | `sectionWithoutAsk` + `unknownAskId`; parse từ chối `ask_ids` rỗng | lệnh 2 |
| BR-15 / R-15a nội dung là dữ liệu | test quét `lib/**` `.dart`/`.arb` tìm mọi chuỗi đã soạn; 0 offender | lệnh 2 |
| BR-16 / R-15b không mã nào suy ra N | không hằng số đếm trong `portrait_content*.dart`; gate không đọc `length` để quyết định gì | lệnh 2, 5 |
| BR-17 / R-15c luật chỉ sống trong Dart | test "only invariant_terms.dart declares the assertive-claim terms" quét toàn `lib` | lệnh 2 |
| AC-29/AC-30 tất định + offline | P1 không có lời gọi mạng, không nguồn ngẫu nhiên; asset đọc qua `ContentPackageLoader` | lệnh 2, 5 |

### Ripple absorbed inside P1

Thêm `InvariantRule.assertiveClaim` vào `core/content/invariant_terms.dart` làm
đỏ hai test anh em ngay lập tức (`before_you_go` và `context_notebook` đều
khẳng định `InvariantRule.values ⊆ <Family>GateRule`), và làm
`_ruleFor(wireValue).firstWhere` của bốn gate cũ ném `StateError` nếu luật mới
kích hoạt. P1 hấp thụ trọn ripple: `ContextGateRule`, `BeforeYouGoGateRule`,
`GiftGateRule`, `PresetGateRule` đều nhận thêm `assertiveClaim('assertive_claim')`.
Denylist mới được đối chiếu trước với toàn bộ asset/lib/test đang có — không
cụm nào trùng, nên không gói đã ship nào chuyển sang vi phạm (lệnh 4 xác nhận).

`pubspec.yaml` KHÔNG đổi: `assets/data/req016/` đã được khai báo từ trước.

### Later-phase schedulability

P2..P5 **không** phase nào schedule song song được lúc này. Kế hoạch của Tech
Lead nối tiếp theo dữ liệu: P2 cần hình dạng gói của P1, P3 cần P1+P2, P4 cần
P2+P3, P5 cần P4. Phase actionable kế tiếp đúng một cái: **P2**
(`phase-P2-answer-store-and-notebook-door.md`), cùng lane Mobile.
