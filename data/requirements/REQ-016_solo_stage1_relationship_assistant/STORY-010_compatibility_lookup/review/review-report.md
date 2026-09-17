# Review Report — REQ-016 / STORY-010 Bảng tra ăn khớp

Outcome: PATCH_REQUIRED

- Review type: `compact-story-review`
- Lane: mobile (không có làn backend/frontend — `architecture/solution.md` §1 Key Discovery 1)
- Baseline diff: `git -C <worktree> diff b58afbe0` (8 commit, worktree sạch, HEAD `47233dac`)
- Blocking findings: 6 · Deferred: 4

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

**Review type:** compact-story-review (parallel-story, Story-Class standard)

**Source/Test Files In Scope**
- `mobile/lib/features/compatibility_lookup/compatibility_lookup_entry_point.dart`
- `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart` (hunk cửa vào)
- `mobile/lib/core/database/cupid_database.dart` (hunk schemaVersion + onUpgrade)
- `mobile/test/core/database/migration_v5_test.dart`
- `mobile/test/core/database/context_notebook_migration_test.dart`

**Evidence Files In Scope**
- `coding-plan/test-results.md` (Phase Status; P2 §Commands/§10; P4 toàn phần; P5/P6 §Commands/§Files/§ghim seed)
- `visual-fidelity/visual-fidelity-report.md`
- `visual-fidelity/10-bang-tra-an-khop.png`, `visual-fidelity/design-reference-10-bang-tra-an-khop-ios.png`
- `story_master.md`, `requirements/requirements.md` (AC-16/AC-17/AC-35/AC-36/AC-38), `req_master.md` bảng phán quyết canvas

**Query Keys**
`AC-16`, `AC-17`, `AC-38`, `AC-35`, `schemaVersion`, `relationship_labels`, `openCompatibilityLookup`, `Entry Point Reachability`, `Runtime startup smoke`, `VISUAL_FIDELITY`, `implemented-*.png`

**Ghi chú phạm vi (gửi Scrum Master):** diff chứa **57 file** thay đổi, vượt xa trần 8 file của `compact-story-review`. Không dừng bằng `REVIEW_SCOPE_TOO_BROAD` vì phần lớn là dữ liệu seed sinh sẵn (3 JSON), `.g.dart` sinh máy, và 8 file test chỉ đổi con số `schemaVersion`. Phần logic thật được review qua diff + đọc có phạm vi đúng 5 file nguồn/test ở trên. Story này khai `Complexity: complex`; theo bậc review của `AGENTS.md` đáng lẽ là `full-story-review`.

## Bề mặt rủi ro và cổng tới hạn

| Bề mặt rủi ro (12b) | Cổng tới hạn | Kết quả |
|---|---|---|
| persistence/schema/migration (v6→v7, bảng `relationship_labels`) | test đường nâng cấp | **THIẾU** — F-3 |
| typed/generated contract (`cupid_database.g.dart`, `relationship_labels_dao.g.dart`) | `build_runner` + `git status` sạch | PASS (test-results P2 §Commands) |
| local storage/offline | 19/19 test repository, nhóm ranh giới lưu trữ AC-30/31/33 | PASS |
| mobile interaction (màn 10, 5 khối kết quả) | 5 test hành vi + 4 test widget kết quả | PASS |
| mobile navigation/discoverability (khoá vị trí AC-1) | 7 test khoá vị trí + đọc mã cửa vào | PASS mã nguồn, **THIẾU mục bằng chứng** — F-1 |
| app lifecycle / khởi động | runtime startup smoke | **THIẾU** — F-2 |
| nội dung dạng dữ liệu (400 ô, AC-36/37/38) | cổng nhập 35 test + 8+8 test ghim seed | PASS |
| build/type-check | `flutter build apk --debug` PASS ở P2/P4/P5/P6 | PASS |

`flutter analyze` đúng là không dùng làm cổng được (baseline 222 cảnh báo có sẵn) — chấp nhận.

## Blocking findings

**F-1 · Thiếu mục `## Entry Point Reachability` trong `coding-plan/test-results.md`** (quy tắc 12e1, không được miễn).
Phần thực chất thì ĐẠT: đã tự kiểm mã và xác nhận `gift_ideas_screen.dart` `_GuessRow.onTap` gọi `openCompatibilityLookup(context, from: CompatibilityEntry.giftIdeas)`, tức một hàng chạm được, có sẵn trên màn (5), không phải route gõ tay. Nhưng mục bằng chứng bắt buộc không tồn tại; §"Khoá vị trí" chỉ chứng minh chiều ngược lại (KHÔNG tới được từ menu/tab/route).
→ Thêm mục `## Entry Point Reachability` với `Reachable: YES` và đường đi cụ thể (màn 5 gợi ý quà → hàng đoán dấu → màn 10).

**F-2 · Không có runtime startup smoke, cũng không có miễn trừ hợp lệ** (quy tắc 12g).
P4/P5/P6 đều ghi `Runtime startup smoke: NOT_APPLICABLE (phase file §9)`. `story_master.md` **không** có dòng `Runtime-Smoke: WAIVED — <lý do>`, và file phase không phải nơi cấp miễn trừ đó. Story này thêm một bảng DB mới, hai đăng ký `service_locator`, và một asset 148 KB nạp lúc chạy — đúng loại thay đổi làm app chết lúc khởi động. Tiền lệ trong chính REQ-016: STORY-003 và STORY-006 đều ship `runtime-smoke-main-first-screen-emulator-5554.png`.
→ Chạy smoke khởi động app trên thiết bị/emulator đã cấp, ghi mục `## Story Runtime Startup Smoke`; hoặc để Scrum Master ghi `Runtime-Smoke: WAIVED — <lý do>` vào `story_master.md`. Cổng DONE kiểm mục này độc lập.

**F-3 · Bước migration v6→v7 không có test nào phủ.**
`mobile/lib/core/database/cupid_database.dart` thêm `if (from < 7) { await m.createTable(relationshipLabels); }`. Ba file test migration bị chạm (`migration_v5_test.dart:96,159`, `context_notebook_migration_test.dart:101,161`, `activity_card_migration_test.dart`) **chỉ đổi con số khẳng định** 6→7; danh sách `containsAll(...)` của `tableNames(upgraded)` không được nối thêm `'relationship_labels'`. 19 test repository chạy trên DB v7 dựng mới (đường `onCreate`), nên đường **nâng cấp** hoàn toàn chưa được chứng minh — đúng thứ làm mất dữ liệu người dùng thật đã cài bản cũ. Mọi lần thêm bảng trước đó trong repo này đều có khẳng định nâng cấp riêng.
→ Nối `'relationship_labels'` vào `containsAll` của `context_notebook_migration_test.dart:101` (hoặc thêm test v6→v7 riêng), chạy lại `flutter test test/core/database`.

**F-4 · Ảnh visual-fidelity đặt sai quy ước tên.**
Story ship `10-bang-tra-an-khop.png` và `10-bang-tra-an-khop-chua-co-nhan.png`. Cổng `verify-story-visual-fidelity-gate.sh` nhận diện ảnh theo tiền tố `implemented-*.png`, và cả 6 story khác của REQ-016 đều theo quy ước `implemented-<screen>-<device>.png` (STORY-001/002/003/004/006).
→ Đổi tên thành `implemented-10-bang-tra-an-khop-md.png` và `implemented-10-bang-tra-an-khop-md-chua-co-nhan.png` (hậu tố `-md` vì ảnh chụp ở platform Material, đúng như report giải thích), rồi sửa hai dòng bảng trong `visual-fidelity-report.md`.

**F-5 · Bảng `## Phase Status` của `test-results.md` mâu thuẫn với chính thân file.**
Dòng 11-12 ghi P5 và P6 `NOT_STARTED`, `Build Gate —`, `Test Gate —`; trong khi §P5/§P6 bên dưới ghi đầy đủ lệnh, kết quả xanh và build PASS, `master-plan.md` đánh cả sáu phase `COMPLETE`, và `story_master.md` đã tích ô Implementation.
→ Cập nhật hai dòng đó về `COMPLETE / PASS / PASS`.

**F-6 · `VISUAL_FIDELITY: PASS` được ghi trong khi chính báo cáo liệt kê 8 chênh lệch so với design reference, và làn Mobile tự phân xử 3 trong số đó.**
Đã mở cả hai ảnh (ảnh thật, đúng màn của story, tiếng Việt đủ dấu, không ô tofu, không khung lỗi) — nhưng chúng **không** đọc ra là cùng một màn. Ba mục sau là tranh chấp **canvas vs `uiux-spec.md`** thuần tuý, đúng lớp mà bảng phán quyết của `req_master.md` (D-1…D-19, tất cả đều kết luận "Design canvas thắng") dành cho user/Scrum Master quyết, chứ không cho báo cáo tự quyết:
- tiêu đề khối: canvas dùng caption IN HOA ("CHỖ DỄ HỢP"/"CHỖ DỄ VA"); bản dựng dùng tiêu đề phụ sentence-case theo spec §3.2/§3.3
- hành động của "1 hoạt động nên thử": canvas là nút tròn `(+)` icon-only; bản dựng là outline chip có chữ theo spec §3.4
- tiêu đề màn: canvas dùng tên cặp ("Sư Tử × Cự Giải"); bản dựng dùng tiêu đề tĩnh + dòng xuất xứ
→ Cần một dòng phán quyết `D-xx` trong `req_master.md` (Scrum Master/user sở hữu) cho ba mục này, rồi hoặc rework theo canvas hoặc vá spec — giống hệt cách D-1…D-19 đã được xử. Trước khi có dòng đó, `VISUAL_FIDELITY: PASS` chưa có cơ sở.

## Deferred

**D-1 · Frame canvas `10-bang-tra-an-khop` đang vẽ một UI vi phạm AC của chính story.** Canvas vẽ "HAI ĐỨA HỢP TỚI ĐÂU" là thanh gradient 3 mốc + nhãn "khá hợp"; AC-16/AC-17, `uiux-spec.md` §3.1 và R-8 cấm tuyệt đối mọi thành phần trả lời được "đầy bao nhiêu phần". Bản dựng làm đúng (chip chữ tĩnh "Khác nhịp, bù nhau") — **đây là mục do AC chi phối, không rework**. Cần UI/UX sửa frame; ngoài write scope của làn Mobile. Không chặn story.

**D-2 · Kiểm duyệt lớp 2 (AC-35 / D-15) chưa được cấp.** Cả 400 ô seed đã sẵn sàng nhưng chưa được user duyệt để vào bản dựng người dùng thật. P5/P6 ghi vết đúng và không tự phê duyệt. Scrum Master cần đưa bộ seed cho user duyệt trước khi phát hành.

**D-3 · Ba test đỏ có sẵn ở `test/features/love_contracts`.** Đã được chứng minh là có trước bằng cách `git stash` asset P6 và chạy lại (`+80 -3`, đúng ba test đó). Ngoài phạm vi story.

**D-4 · Findings 1/2/5/7/9 của `test-results.md`** (lệch AC id trong file phase P1; AC-32 chưa có chủ ở tầng dữ liệu; `frequencyProbe` áp cả bốn trường; gỡ khoá `gift_ideas_guess_coming_soon` cần đối soát với STORY-009; quy ước giọng của `question`) — đều đã ghi vết rõ, không mục nào phá AC đã duyệt của story này.

## Truy vết AC

AC-1 khoá vị trí: PASS (7 test khoá vị trí đọc cả cây `lib/` + đã tự đọc mã cửa vào; không `routeName`, không `settings.name`, không `pushNamed`). AC-2 bộ bốn đủ mục: PASS (test ghim seed khẳng định `fit`/`friction`/`activity`/`question` không rỗng, khác nhau trong cùng ô, trên cả 400 ô). AC-3 luôn có điểm cọ xát: PASS (cùng nguồn). AC-4/AC-16/AC-17 không %/điểm/thanh: PASS (cổng nội dung 35 test + test "không có thang đo" + đã tự soi ảnh). AC-5 hỏi tại chỗ: PASS (`label_capture_card.dart`, ảnh `…-chua-co-nhan` không chip nào chọn sẵn). AC-6 đẩy thẻ: PASS (origin `compatibility_lookup` thêm vào `activity_card.dart`, 315 test hồi quy activity_cards xanh). AC-7 ngoại tuyến/tất định: PASS (gói tĩnh trên đĩa, không lời gọi mạng). AC-38 phủ 100%: PASS (144 + 256, cổng so `cells.length` với `axisIds.length²`).

## Khuyến nghị trạng thái

- Bỏ tích `Implementation (Development)`; để trống `Review (Reviewer)`; đặt story về `IN_PROGRESS`.
- Trả về làn Mobile: F-1, F-2, F-3, F-4, F-5.
- Scrum Master/user xử: F-6 (dòng phán quyết `D-xx`), D-1 (định tuyến UI/UX sửa frame), D-2 (duyệt lớp 2).
- Không có cổng nào bị chặn bởi môi trường/quyền/phụ thuộc, nên không mục nào là `BLOCKED`.

## Ghi chú cấu hình

Không phát hiện tác động setup/configuration: story không chạm Docker, Compose, registry runtime, biến môi trường, hay script môi trường cục bộ. Không yêu cầu `deployment/configuration-guide.md`.
