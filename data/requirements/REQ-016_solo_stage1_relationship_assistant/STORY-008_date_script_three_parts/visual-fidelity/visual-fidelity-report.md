VISUAL_FIDELITY: PASS
Design-Screen: 9-kich-ban-buoi-hen
Design-Screen-Alias: s1:datescript

# STORY-008 — Kịch bản buổi hẹn 3 phần, màn (9): đối chiếu thị giác

- Story: REQ-016 / STORY-008, hậu kiểm sau review `Outcome: BLOCKED` (2026-09-17)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Ngày: 2026-09-17

## Giải quyết id màn thiết kế — `s1:datescript` không render được, và đó là đúng

`coding-plan/test-results.md` P4 deviation 9, `review/review-report.md` F-1 và
handoff đều ghi `Design-Screen: s1:datescript`. Id đó **có thật**, nhưng nó nằm
trên canvas `cupid-app` (`Cupid App.dc.html`) — không phải canvas mà requirement
này neo vào. `req_master.md:13` ghi `Design-Surface: cupid-ch-ng-1`, nên
`.claude/hooks/guard-design-render-surface.sh` chặn thẳng
`--surface=cupid-app`:

```
DESIGN RENDER SURFACE GUARD BLOCKED [GENERIC]: this render targets
`--surface=cupid-app` but the story resolves to `cupid-ch-ng-1`
```

Trên canvas đã neo (`Cupid Chặng 1.dc.html`, `screens_from: frames`,
`platforms: ["ios"]`), khung tương ứng của màn (9) là **`9-kich-ban-buoi-hen`** —
liệt kê bằng `--list-screens`, và là khung duy nhất trong danh sách vẽ bề mặt
này. Đây đúng cùng kiểu xử lý mà STORY-006 đã ghi lại cho `sb-211-truoc-gio-di`.

Vậy `s1:datescript` là **bí danh lịch sử**, `9-kich-ban-buoi-hen` là id có hiệu
lực. Scrum Master nên chép id này sang `story_master.md` (đã ghi sẵn ở đó).

Lệnh tái lập bản tham chiếu:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --surface=cupid-ch-ng-1 \
  --screen=9-kich-ban-buoi-hen --platform=ios \
  --out=data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/visual-fidelity
→ DESIGN_CANVAS: OK …/design-reference-9-kich-ban-buoi-hen-ios.png 415x900 (exit 0)
```

Không dùng `--label`: `validate-dev-design-render.sh` đọc **tên file** để lấy id
màn, nên mọi nhãn tuỳ ý (ví dụ `screen-...-truoc`) đều bị coi là id không tồn tại
trên surface và chặn lane. Giữ nguyên tên mặc định `design-reference-<id>-<platform>.png`.

`VISUAL_RUNTIME_MISSING` mà P4 gặp **không còn tái lập được** trong worktree này
(xem `coding-plan/devops-visual-runtime-fix.md`); render chạy sạch, PNG thật
178.9 KB.

## Các màn được đối chiếu

| Trạng thái | Nền tảng | Bản thiết kế | Bản cài đặt |
| --- | --- | --- | --- |
| Đoạn "Trước" | ios | `design-reference-9-kich-ban-buoi-hen-ios.png` (415x900) | `implemented-9-kich-ban-buoi-hen-truoc-ios.png` (415x900) |
| Đoạn "Trong" | ios | cùng bản tham chiếu (canvas chỉ có một khung tĩnh, `toggles: []`) | `implemented-9-kich-ban-buoi-hen-trong-ios.png` (415x900) |
| Hỏi tại chỗ, sổ tay trống | ios | cùng bản tham chiếu | `implemented-9-kich-ban-buoi-hen-so-tay-trong-ios.png` (415x900) |
| Ba cửa ra hiện đủ | ios | cùng bản tham chiếu | `implemented-9-ba-cua-ra-ios.png` (415x900) |

Canvas không có toggle/biến thể trạng thái cho khung này, nên một bản tham chiếu
phục vụ cả bốn trạng thái cài đặt.

Bốn ảnh `implemented-*` là **chính những ảnh review đã tự mở và xác nhận hợp
lệ**, chỉ được `git mv` từ `mobile/test/features/date_script/visual-fidelity/`
sang đây và thêm hậu tố `-ios` cho khớp quy ước STORY-003/STORY-006. Không chụp
lại, không sửa nội dung ảnh.

Lượt khắc phục F-4 (2026-09-24) `git mv` thêm một lần nữa để bỏ token `screen-`
thừa còn sót từ tên cũ: `implemented-screen-9-…` → `implemented-9-…`. Gate lấy
id màn là token đứng ngay sau tiền tố `implemented-`/`design-reference-`, nên
tên cũ cho id `screen` còn bản tham chiếu cho id `9` và hai phía không ghép cặp
được. Nội dung ảnh không đổi ở lần này.

## Cách bốn ảnh cài đặt được tạo ra

Không phải ảnh chụp thiết bị. Màn (9) chỉ tới được qua một thẻ *Đã hẹn ngày*
đang chạy, nên nó được dựng bằng `RepaintBoundary.toImage` ngay trong widget
test của story (`mobile/test/features/date_script/date_script_screen_test.dart`,
`date_script_exits_test.dart`), ở viewport iOS 415x900 — đúng cơ chế dự phòng
mà STORY-003/STORY-006 đã dùng cho bề mặt không tới được theo yêu cầu.

Harness nạp đủ bốn họ font trong `pubspec` cộng `MaterialIcons-Regular.otf` của
framework (`_loadDesignFonts`, cùng file, dòng ~226).

### Sai khác do harness — không phải lỗi sản phẩm

- **Không có thanh trạng thái iOS, không có khung máy, không có home indicator.**
  Bản thiết kế render cả device chrome (`9:41`, sóng/wifi/pin); một widget render
  trực tiếp thì không.
- **Không có chevron quay lại ở header.** `date_script_screen.dart:138` đặt
  `onBack: Navigator.of(context).canPop() ? … : null`. Trong harness màn được
  pump làm route gốc nên `canPop()` là `false` và `CupidHeader` không dựng
  leading. Trên đường đi thật (push từ sheet "Chuẩn bị") nút quay lại có mặt.
- **Vùng trống lớn giữa nội dung và thanh cửa ra** ở ba ảnh đầu: nội dung preset
  ngắn trong khung 900px, không phải khoảng trắng do layout hỏng.

## Đã soi tận mắt, không tin token

- Cả bốn ảnh `implemented-*` và bản `design-reference-*` đều được mở và xem.
- Dấu tiếng Việt đủ và đúng ở mọi nhãn ("Kịch bản buổi hẹn", "Trước/Trong/Sau",
  "Xuất lời mời", "Tạo thẻ mới", "Ghi vào nhật ký", "Bỏ qua").
- **Glyph `menu_book` ở caption đoạn "Trong" đã được kiểm riêng.** Ở tỉ lệ 1:1 nó
  trông như một ô vuông nhỏ và dễ bị kết luận nhầm là tofu. Phóng 6x vùng đó cho
  thấy một glyph sách mở đúng nghĩa. Kiểm chéo bằng cmap: `CupidIcons.menuBook`
  là `0xea19`, và `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` có
  glyph cho `0xea19` (GID 2698). Không có tofu ở bất kỳ ảnh nào.

## Khớp với bản thiết kế

- Khung tham chiếu iOS 415x900, đúng bảng màu tối phân lớp của canvas.
- **Segmented control 3 đoạn "Trước / Trong / Sau"** ngay dưới header, đúng thứ
  tự, chọn-một, đoạn đang chọn có pill đặc nổi bật còn hai đoạn kia là pill viền.
- **Đúng ba hành động ở đáy màn, đúng thứ tự trái→phải** như canvas: canvas ghi
  `Soạn lời rủ` / `Thêm điều mới` / `Ghi nhật ký`, bản cài đặt ghi
  `Xuất lời mời` / `Tạo thẻ mới` / `Ghi vào nhật ký` (nhãn do AC-17 chốt, xem
  mục xung đột bên dưới) — cùng vị trí, cùng số lượng, cùng thứ tự ngữ nghĩa.
- Bo góc pill (`radiusButton`), chữ thân `body`, caption `colorTextMuted`.
- **Không có bộ đếm giờ, không đồng hồ, không nút "bắt đầu buổi hẹn"** ở cả hai
  phía — canvas cũng không vẽ, AC-14/AC-15 cũng cấm.

## Đo đạc biên ngang — kiểm Deferred Finding D-1

Review hoãn D-1: pill "Ghi vào nhật ký" *có vẻ* dính sát mép phải ở khung 415dp,
và không có assert `rect.right <= view.width`.

**D-1 không tái lập được.** Quét pixel trên chính
`implemented-9-ba-cua-ra-ios.png`:

| Phần tử | Bản cài đặt | Bản thiết kế |
| --- | --- | --- |
| Hàng ba cửa ra (nét viền hồng), dải y 836..883 | x = 16 .. 398 → lề trái 16dp, **lề phải 16dp** | ô "LÀM GÌ TIẾP", y 620..639: x = 21 .. 393 → lề 21dp/21dp |
| Segmented control, y 72..119 | pill thứ ba kết thúc ở x = 398 → lề phải 16dp | pill thứ ba kết thúc ở x = 393 → lề phải 21dp |

Lề hai bên **đối xứng** ở cả hai bản; không có phần tử nào bị cắt ở mép. Cảm
giác "dính mép" trong review đến từ việc nhìn ảnh ở tỉ lệ nhỏ.

Sai khác thật sự là **lề ngang 16dp (`CupidSpacing.md`) so với 21dp của canvas**
— chênh 5dp, đối xứng, và là hằng số token dùng chung toàn app chứ không phải
quyết định riêng của màn (9). Ghi nhận ở mức thông tin; sửa nó là việc của
design-system, không phải của story này.

Đề xuất giữ nguyên cho STORY-009/010 khi họ thêm liên kết vào màn này: thêm
assert `rect.right <= view.width` cho hàng cửa ra là rẻ và chặn được hồi quy khi
màn có thêm phần tử; hiện tại không có gì để sửa.

## Thẩm quyền khi canvas và AC không khớp

Theo tiền lệ STORY-006 (mục "Authority note") và quyết định neo thiết kế của
REQ-016: canvas neo **trên câu chữ của `ux/uiux-spec.md`**, nhưng **không** ghi
đè một acceptance criterion hay một mục Out of Scope. Các khác biệt dưới đây rơi
vào trường hợp đó, được ghi là `DESIGN_SPEC_CONFLICT`: chúng **không** phải lỗ
hổng hiện thực và **không được** "sửa về phía canvas" nếu chưa có phán quyết của
Product Owner.

## DESIGN_SPEC_CONFLICT — canvas trái với artifact ràng buộc

1. **Tiêu đề màn và dòng eyebrow.** Canvas ghi eyebrow `từ thẻ · CN 14/9` và
   tiêu đề `Chuẩn bị buổi hẹn`. `requirements/requirements.md:56` (In Scope 1)
   đặt tên màn (9) là **"Kịch bản buổi hẹn"**, và `ux/uiux-spec.md` §1 khoá
   chính chuỗi đó làm nhãn hàng cửa vào trong khu vực Chuẩn bị. Bản cài đặt
   dùng "Kịch bản buổi hẹn" (`date_script_screen.dart:137`).

2. **Nhãn ba cửa ra.** Canvas: `Soạn lời rủ` / `Thêm điều mới` / `Ghi nhật ký`.
   **AC-17** đòi đúng ba cửa ra "xuất lời mời" · "tạo thẻ mới" · "ghi vào nhật
   ký", và `ux/uiux-spec.md` §2.5 viết nguyên văn ba nhãn đã ship. AC thắng.

3. **Kiểu nút cửa ra: ô đặc có icon vs pill viền.** Canvas dựng ba ô nền đặc,
   mỗi ô một icon màu, dưới nhãn khu vực `LÀM GÌ TIẾP`, nằm trong dòng chảy nội
   dung. `ux/uiux-spec.md` §2.5 yêu cầu **pill viền, sticky ở đáy**, và nêu rõ
   lý do: nền `--grad` đặc dành riêng cho hành động chính cấp thẻ, dùng lại ở
   đây sẽ tạo cảm giác có hành động chính cấp thẻ thứ hai — đúng điều **AC-6**
   (và SC-4, STORY-001 AC-11) cấm. Bản cài đặt theo spec.

4. **Hai thẻ điều hướng "Xem chân dung theo cách bạn nhìn" và "Xem hai người dễ
   hợp / dễ va ở đâu".** Canvas vẽ chúng ngay giữa màn. Đó là màn (8) và màn
   (10), nằm ở **Out of Scope** dòng 84-85 của `requirements.md` ("STORY-009 /
   STORY-010 **thêm** liên kết đi ra từ màn này về sau; story này không xây
   chúng"), và dòng 82 cấm "cửa ra thứ tư" trong phạm vi story này.
   `ux/uiux-spec.md` §5 chừa sẵn chỗ cho chúng. Không dựng ở đây là **đúng
   phạm vi**, không phải thiếu sót.

5. **Dữ liệu cứng trong canvas.** `TRƯỚC · 3 VIỆC` với ba mục cụ thể
   ("19:00 mình đón ở cổng nhà nha", "tháng 9 hay mưa · có quán cà phê cách
   300m", "sổ tay: tuần này Cún có buổi bảo vệ đồ án") là nội dung minh hoạ.
   **AC-8/AC-9/AC-10** buộc nội dung sinh tất định từ preset + mad-libs theo
   trường của **chính thẻ nguồn** và sổ tay STORY-004, nên số mục lẫn câu chữ
   là thuộc tính của gói nội dung, không phải hằng số thiết kế. Ảnh cài đặt cho
   thấy đúng cơ chế đó đang chạy với dữ liệu thẻ thật ("Có vụ xem phim Dune vào
   Chủ Nhật 20/9").

## DESIGN_ANCHOR_OPEN — một điểm cần Product Owner phán quyết

**Hình thái trình bày nội dung mỗi đoạn: đoạn văn liền vs thẻ danh sách đánh
số.** Canvas dựng nội dung đoạn "Trước" thành một **thẻ có tiêu đề khu vực và ba
mục đánh số 1/2/3**, mỗi mục có một dòng phụ giải thích. Bản cài đặt dựng **một
đoạn văn mad-libs liền 2-4 câu**, theo `ux/uiux-spec.md` §2.3.

- Đây **không** phải trường hợp AC chốt sẵn: `requirements.md` In Scope 2 chỉ
  chốt "preset + mad-libs, tất định"; hình thái trình bày do spec quyết.
- Nó cũng **không** bị AC cấm: canvas dùng số thứ tự, không dùng checkbox, nên
  không chạm điều cấm "checklist thời gian thực" (Out of Scope dòng 73-75,
  AC-14).
- Nên nó rơi đúng vào vùng "canvas neo trên câu chữ spec" của quyết định thiết
  kế REQ-016, và **báo cáo này không tự phán quyết**: `ux/uiux-spec.md` là một
  artifact ràng buộc của story, được duyệt trước khi canvas Chặng 1 được nhận
  diện lại (spec ghi rõ `DESIGN_SOURCE_NOT_DETECTED` là bình thường ở thời điểm
  viết).

Verdict của mục này: **không chặn ship**. Nội dung ba phần, tính tất định, và
mọi AC nhóm B vẫn đạt ở cả hai hình thái; thay đổi hình thái là một yêu cầu UX
mới, không phải sửa lỗi. Nếu Product Owner chọn theo canvas thì đó là một story
rework có phạm vi riêng, cần sửa cả `ux/uiux-spec.md` §2.3 lẫn lược đồ gói nội
dung (mỗi đoạn thành N mục có dòng phụ), không phải một patch giao diện.

## Verdict theo từng trạng thái

| Trạng thái | Verdict | Delta cụ thể |
| --- | --- | --- |
| Đoạn "Trước" | PASS | Segmented đúng thứ tự/kiểu chọn; lề 16dp vs 21dp; hình thái nội dung = `DESIGN_ANCHOR_OPEN`; tiêu đề = conflict #1 |
| Đoạn "Trong" | PASS | Thêm caption bắt buộc "Đọc trước khi đi — không phải nhắc trong lúc hẹn" + icon `menu_book` mà canvas không có: đây là hàng rào BR-3/AC-14 do `ux/uiux-spec.md` §2.3 bắt buộc, có mặt là đúng |
| Hỏi tại chỗ (sổ tay trống) | PASS | Canvas không vẽ trạng thái này; ô hỏi một câu + "Bỏ qua" cùng khối đúng AC-23/AC-24/AC-25 và cơ chế STORY-004 |
| Ba cửa ra | PASS | Đủ ba, đúng thứ tự, pill viền sticky; nhãn/kiểu = conflict #2, #3; lề trái/phải đối xứng 16dp, **D-1 không tái lập** |

## Lệnh đã chạy trong lượt khắc phục thị giác (2026-09-17)

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --surface=cupid-ch-ng-1 --list-screens            → exit 0
node .ai-team-bundle/runtime/tools/render-design-canvas.js … --screen=9-kich-ban-buoi-hen --platform=ios …                                      → exit 0
cd mobile && flutter test test/features/date_script/ test/features/activity_cards/ test/features/invite_composer/                               → +465 ~4, All tests passed!, exit 0
```

Chạy hồi quy ở trên tái hiện đúng P4 deviation 10: nhóm chụp ảnh của STORY-002
ghi đè `STORY-002_invite_message_composer/visual-fidelity/implemented-11-chuan-bi-chon-hanh-dong-ios.png`
dù không bật `--dart-define=CAPTURE_VISUALS`. File ngoài WriteScope của story
này nên đã `git checkout --` trả lại bản đã commit. Việc cần sửa vẫn thuộc
STORY-002.

## Gate re-run sau đổi tên (khắc phục F-4, 2026-09-24)

`verify-story-visual-fidelity-gate.sh` chạy im lặng khi thiếu ngữ cảnh phiên,
nên lượt này gọi thẳng bộ kiểm nó dùng — `.claude/hooks/lib/visual_fidelity.py`:

```
python3 .claude/hooks/lib/visual_fidelity.py --dir <story-dir> --project <worktree> \
  --stage review --stack mobile --lane mobile   → không output, exit 0  (PASS)
python3 .claude/hooks/lib/visual_fidelity.py --dir <story-dir> --project <worktree> \
  --stage done   --stack mobile --lane mobile   → không output, exit 0  (PASS)
```

Đối chứng trên một bản sao tạm ở `/tmp` giữ nguyên tên cũ
`implemented-screen-9-*` (ảnh và báo cáo y hệt, chỉ khác tên file) cho đúng lỗi
đã chặn ở lượt 2, exit 1:

```
no screen has BOTH renders, so nothing was actually compared:
running-app renders exist for ['screen'] and design renders for ['9']
```

Tức là cổng thực sự có chạy và chính việc bỏ token `screen-` là thứ gỡ chặn:
cả hai phía giờ cùng cho id màn `9`. Không ảnh nào bị chụp lại, không mã sản
phẩm hay mã test nào bị đổi trong lượt này.

**Gate re-run sau đổi tên: PASS — 2026-09-24.**
