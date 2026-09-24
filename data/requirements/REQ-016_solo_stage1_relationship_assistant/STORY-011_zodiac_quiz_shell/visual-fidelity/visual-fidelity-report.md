VISUAL_FIDELITY: PASS
Design-Screen: 7-vo-hoang-dao-3-viec
Design-Screen: tab-y-tuong-hub-cua-vao
Design-Screen: man-goc-muon-lam
Design-Screen: phut-1-kho-trong

# STORY-011 — Vỏ hoàng đạo / trắc nghiệm, màn (7) + cửa vào, visual fidelity

- Story: REQ-016 / STORY-011, phase P3 (màn 7) và phase P4 (cửa vào)
  (`coding-plan/phase-P3-result-surface-screens.md` §7,
  `coding-plan/phase-P4-entry-point-wiring.md` §6)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-24

Phần §1-§7 và Deferred bên dưới là audit của P3 (màn 7) và không đổi. Audit
của P4 (dải lối-vào-nhanh trên hub) nằm ở §P4 cuối tệp.

## Screens under audit

| Design screen id | Platform | Design reference | Implemented |
| --- | --- | --- | --- |
| `7-vo-hoang-dao-3-viec` | ios | `design-reference-7-vo-hoang-dao-3-viec-ios.png` (415x900) | `implemented-7-vo-hoang-dao-3-viec-md.png` (415x900) |
| `7-vo-hoang-dao-3-viec` (màn chọn lát) | — | không có frame tương ứng | `implemented-7-vo-hoang-dao-3-viec-md-chon-lat.png` (415x1100) |

Hậu tố `-md` là platform dựng thật của ảnh: bản dựng chụp ở Material, trong khi
frame tham chiếu của canvas chỉ có bản `ios`. Tên theo quy ước
`implemented-<screen>-<platform>[-<biến thể>].png` mà
`verify-story-visual-fidelity-gate.sh` nhận diện, và mà STORY-001/002/003/004/
006/010 đã dùng.

Design source resolution: `data/devops/system/design-fidelity-config.json` khai
4 nguồn; surface mang màn này là `cupid-ch-ng-1` (entry `Cupid Chặng 1.dc.html`,
`screens_from: "frames"`, `platforms: ["ios"]`). Danh sách frame lấy bằng
`node .ai-team-bundle/runtime/tools/render-design-canvas.js --list-screens
--surface=cupid-ch-ng-1`, và `7-vo-hoang-dao-3-viec` là frame duy nhất vẽ màn
này. Id trên canvas này là slug, nên lệnh render dùng `--screen=<slug>` và
không bao giờ dùng `--label`.

Lệnh render reference:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=cupid-ch-ng-1 --screen=7-vo-hoang-dao-3-viec --platform=ios \
  --out=<visual-fidelity dir>
```

`ux/uiux-spec.md` mở đầu bằng `DESIGN_SOURCE_NOT_DETECTED` — lúc viết spec chưa
dò ra nguồn thiết kế, nhưng nay frame có thật, nên audit này so với frame chứ
không chỉ so với luật đo được trong spec.

`story_master.md` không có dòng `Design-Screen:` và nằm ngoài write scope của
phase này; id được ghi tại đây để Scrum Master chép sang.

## Ảnh "implemented" được tạo thế nào — và vì sao không phải ảnh chụp thiết bị

Không có thiết bị Android/iOS nào gắn vào máy chạy phase này (`adb devices`
trống, `flutter devices` chỉ liệt kê macOS và Chrome), nên đường chụp thiết bị
của `capture-mobile-screen.sh` không dùng được. Màn (7) cũng chưa có lối vào:
ô 3 của dải lối-vào-nhanh là việc của P4, nên ở SHA này không route nào dẫn tới
nó trên một bản build chạy thật.

Vì vậy dùng đúng fallback đã thiết lập của repo cho một surface chưa tới được
(giống STORY-003 P3, STORY-006 P2, STORY-010 P4): chụp `RepaintBoundary.toImage`
ngay trong widget test của story, dựng `ZodiacShellScreen` thật — không phải
harness thay thế — với `buildCupidTheme` thật, `CupidAppBackground`, gói nội
dung đọc thẳng từ đĩa, và 4 họ font trong pubspec cộng
`MaterialIcons-Regular.otf` của framework nạp qua `FontLoader`.

- Harness: `mobile/test/features/zodiac_shell/zodiac_shell_screen_test.dart`
  (`_loadDesignFonts`, `_captureScreen`, group `bằng chứng visual-fidelity`)
- Lệnh: `flutter test test/features/zodiac_shell/zodiac_shell_screen_test.dart --dart-define=CAPTURE_VISUALS=true`
- Không bật cờ thì 2 test chụp ảnh `skip`, nên suite thường ngày vẫn kín và
  không ghi file.
- Chụp ở platform Material chứ không phải iOS: `CupidHeader` bản iOS là một
  `BackdropFilter`, mà ảnh chụp offscreen không có nền phía sau để lấy mẫu,
  nên tiêu đề sẽ bị xoá trắng trong mọi bản chụp iOS.
- Khung 415x900 — **đúng khung của reference**, nên hai ảnh so được trực tiếp
  từng khối. Ảnh màn chọn lát để 415x1100 vì 10 lát không nằm vừa một khung
  điện thoại; audit của nó là về chữ trên thẻ, không phải về chỗ gãy trang.
- Bản chụp kết quả chạy bộ `set.quiz_phong_doan.v1`: đây là bộ duy nhất mà mọi
  mapping đều rơi vào outcome `about_other`, nên một khung ảnh mang đủ ba thứ
  spec có luật: xuất xứ phỏng đoán, câu để hỏi, và 3 thẻ.

Đã soi mắt cả hai ảnh: chữ tiếng Việt đủ dấu (Ỗ, Ữ, Ằ, ệ, ỏi đều tới nơi),
không ô tofu, icon `auto_awesome`/`chevron_right`/`help`/`local_activity`/`add`
đều hiện đúng hình chứ không phải ô notdef.

## Đối chiếu từng luật đo được (`ux/uiux-spec.md` §2-§4)

| Luật | AC | Kết quả |
| --- | --- | --- |
| Màn chọn: danh sách thẻ đơn giản, mỗi thẻ 1-2 dòng mô tả | §2.1 | PASS — 10 thẻ, tiêu đề + blurb 1-2 dòng, không gì khác |
| Mọi lựa chọn luôn mở, không mục "hôm nay mới mở khoá" | AC-18 | PASS — không khoá, không badge; test quét mọi `Text` trên màn chọn tìm "mở khoá"/"chuỗi"/dạng `n/m` |
| Chơi ngay, không bước điền hồ sơ trước | AC-2 | PASS — chạm thẻ là vào thẳng câu hỏi |
| Bỏ dở rồi quay lại: bắt đầu lại sạch, không đếm lần bỏ dở, không trách móc | AC-3 | PASS — "Để khi khác" về màn chọn, state xoá `set`/`question`/`result`; vào lại ra câu mới |
| Kết quả + đúng 3 thẻ trên **một** màn, **một** lượt cuộn | AC-5/AC-6, BR-2 | PASS — một `ListView`, test khẳng định đúng 1 `Scrollable` và 3 thẻ là con của nó, cho **cả 27 outcome** |
| Không nút "xem gợi ý", không "xem thêm" đóng sẵn che 3 thẻ | AC-5/AC-6 | PASS — không `ExpansionTile`/`ExpansionPanelList` ở bất kỳ outcome nào |
| Thứ tự: nhận định (`body`) → (khối "câu để hỏi" nếu nhắc người kia) → tiêu đề phụ ngăn cách → 3 thẻ dọc | §3.1, R-1g | PASS — kiểm bằng toạ độ `getTopLeft().dy`, không phải bằng mắt |
| Khối "câu để hỏi" dùng đúng kiểu STORY-009 §3.4 khi đoạn nhắc tới người kia | R-1g/AC-15 | PASS — `colorSurfaceAlt` tách lớp, icon `help` line 20, tiêu đề caption IN HOA, thân `body w500` — cùng treatment `compat_question_block.dart` |
| Khối "câu để hỏi" chỉ xuất hiện khi outcome nói về người kia | AC-12/AC-15 | PASS — test chạy cả 27 outcome: có ở đúng 3 outcome `about_other`, vắng ở 24 outcome còn lại |
| Thẻ đề xuất dùng style dùng chung STORY-004/005: khối `--r-sm` + 1 hành động chính | §3.1/§5 | PASS — `radiusSmall`, viền `colorLine`, đúng một hành động mỗi thẻ |
| "Thêm vào kho của tôi" tạo thẻ ngay, trạng thái *Mới nghĩ ra*, không hộp thoại chặn | AC-7, §3.2 | PASS — `origin: zodiacShell`, `status: idea`, không `AlertDialog` |
| Snackbar hoàn tác 5 giây | AC-2, §3.2 | PASS — `duration` đo được đúng `Duration(seconds: 5)`, có `SnackBarAction` |
| Chọn tiếp thẻ khác trên cùng màn, không giới hạn 1 lựa chọn | §3.2 | PASS — cả 3 thẻ vào kho từ một bề mặt, thứ tự giữ nguyên |
| Không chọn thẻ nào và rời màn: không hệ quả, không nhắc lại | AC-10 | PASS — "Chọn lát khác" về màn chọn, kho rỗng, không snackbar |
| Chuyển màn tức thời, không hiệu ứng gõ chữ dần, không spinner "đang tính" | R-7 | PASS — stage `loading` trả `SizedBox.shrink()`; không `CircularProgressIndicator`/`LinearProgressIndicator` ở bất kỳ outcome nào |
| Không DẢI, %, điểm số, chỉ số ăn khớp nào ở màn này | AC-13/AC-14 | PASS — test quét mọi `Text` của cả 27 outcome tìm ký tự `%`, và cấm `Slider`/progress |
| Không streak, đếm lần chơi, huy hiệu, "vận mệnh hôm nay" | AC-18/AC-19/AC-20 | PASS — state không mang trường nào điền được các thứ đó (P2), màn không vẽ |
| Không ngôn ngữ tiên tri/vận mệnh ở tiêu đề và đoạn nhận định | AC-17 | PASS — chữ đến từ gói nội dung đã qua cổng P1; màn thêm dòng định vị "Cung chỉ là cái vỏ cho vui, không phải phán quyết." |
| Không định nghĩa biến thể thẻ thứ ba cho nút "thêm" | §5 | PASS — nút tròn `(+)` outline 44x44 + `Semantics(label:)` lấy nguyên xi từ `compat_activity_block.dart` |
| Không chữ nội dung nào của kho nằm trong Dart | R-15b, BR-12 | PASS — cổng P1 (`zodiac_shell_content_gate_test.dart`) quét nguồn feature; `.arb` chỉ thêm 11 chuỗi chrome |

## Chênh lệch so với design reference — và lý do

1. **Đầu thẻ kết quả**: canvas vẽ một chip avatar cung + tên cặp
   "Sư Tử × Cự Giải" dưới eyebrow "BẠN TỰ ĐIỀN". Bản dựng **không** có cặp
   cung: outcome của story này đến từ câu trả lời trắc nghiệm (gói
   `req016.zodiac_quiz.v1`), không từ một cặp nhãn cung, nên không tồn tại
   giá trị nào điền vào "Sư Tử × Cự Giải". Eyebrow được giữ đúng vai trò xuất
   xứ và mang đúng xuất xứ có thật: "DỰA TRÊN PHỎNG ĐOÁN CỦA BẠN" (AC-12).
   Đây là chênh lệch do mô hình nội dung, không phải do bỏ qua canvas.
2. **Tiêu đề phụ ngăn cách**: canvas ghi "3 ĐIỀU LÀM ĐƯỢC TỪ ĐÂY";
   `ux/uiux-spec.md` §3.1 nêu ví dụ "Thử ngay". Theo neo thiết kế của REQ-016
   (canvas thắng spec khi hai bên chỉ khác cách diễn đạt), bản dựng theo
   canvas. Con số 3 trong chuỗi là hợp đồng bố cục BR-2 cố định, không phải N
   của gói nội dung, nên không phạm R-15b.
3. **Icon đầu mỗi thẻ đề xuất**: canvas vẽ icon khác nhau cho từng thẻ (nốt
   nhạc, cây, cuộn phim). `ZodiacSuggestion` (P1) không có trường icon và
   phase này không được sửa gói nội dung, nên cả 3 thẻ dùng chung glyph
   `local_activity` — đúng glyph dẫn của thẻ hoạt động ở STORY-001. Xem
   Deferred.
4. **Dòng meta dưới tiêu đề thẻ**: canvas có "~150k · 3 tiếng · cần đặt
   trước". Bản dựng vẽ `suggestion.note` khi gói có, bỏ trống khi không — gói
   hiện tại phần lớn không khai `note`, nên nhiều thẻ chỉ có tiêu đề. Đây là
   dữ liệu thiếu, không phải bố cục lệch.
5. **Hành động "Chọn lát khác" dưới đáy màn kết quả**: canvas không vẽ. Bản
   dựng **thêm** vì AC-10 đòi một đường rời màn không hệ quả, và màn (7) là
   một route ba trạng thái chứ không phải ba route — không có nút quay lại nào
   khác để về màn chọn. Trung tính, không trách móc.
6. **Nút quay lại của header**: không thấy chevron trong ảnh vì màn được pump
   như `home` của harness nên `Navigator.canPop` là false. Trên luồng thật
   (push từ ô 3 dải lối-vào-nhanh, P4) `CupidHeader` hiện nút quay lại.
7. **Màn chọn lát**: canvas không có frame cho nó. Bản dựng theo luật đo được
   ở `ux/uiux-spec.md` §2 và mượn ngôn ngữ thẻ của chính canvas (khối
   `--r-sm`, icon dẫn, chevron phải).

## Deferred

- Icon riêng cho từng thẻ đề xuất (mục 3 ở trên): cần thêm một trường icon vào
  schema `req016.zodiac_outcomes.v1` và điền cho mọi gợi ý trong gói. Nằm ngoài write
  scope của P3 (gói nội dung và cổng của nó là P1) và không đổi được luật nào
  ở trên.
- Frame canvas cho màn chọn lát và cho màn câu hỏi: chưa có, nên hai bề mặt đó
  chỉ audit được theo luật đo được. Cần UI/UX bổ sung frame nếu muốn audit
  pixel.

---

# §P4 — Cửa vào: ô thứ 3 của dải lối-vào-nhanh

- Phase: P4 `entry-point-wiring`, §6 "Per-story visual fidelity: REQUIRED"
- Bề mặt audit: **dải lối-vào-nhanh trên hub**, không phải màn (7) — màn (7)
  đã audit ở §1-§7.
- Date: 2026-09-24

## P4.1 Ảnh đã chụp

| Design screen id | Platform | Design reference | Implemented |
| --- | --- | --- | --- |
| `tab-y-tuong-hub-cua-vao` | ios | `design-reference-tab-y-tuong-hub-cua-vao-ios.png` (415x900) | — (xem P4.3: frame vẽ ba lối vào ở dạng danh sách dọc trong tab Ý tưởng) |
| `man-goc-muon-lam` | ios | `design-reference-man-goc-muon-lam-ios.png` (415x900) | `implemented-man-goc-muon-lam-md-quick-entry.png` (415x900) |
| `phut-1-kho-trong` | ios | `design-reference-phut-1-kho-trong-ios.png` (415x900) | `implemented-phut-1-kho-trong-md-quick-entry.png` (415x900) |

Hai ảnh implemented chụp bằng `RepaintBoundary` trong chính test của phase
(`test/features/zodiac_shell/zodiac_shell_entry_point_test.dart`, nhóm "bằng
chứng visual-fidelity", `skip: !kCaptureVisuals`), cùng harness mà P3 đã dùng:
không có thiết bị nào gắn vào máy (`adb devices` trống), nên đường chụp thật
bằng `capture-mobile-screen.sh` không khả dụng và đây là đường dự phòng đã có
tiền lệ. Lệnh chụp:

```
flutter test test/features/zodiac_shell/zodiac_shell_entry_point_test.dart \
  --dart-define=CAPTURE_VISUALS=true
```

Hai ảnh phủ **cả hai** trạng thái hub mang dải: hub đã có thẻ
(`man-goc-muon-lam`) và Phút-1 kho trống (`phut-1-kho-trong`) — đúng hai bề mặt
mà `_openQuickEntryCell` phải định tuyến giống hệt nhau.

Render tham chiếu dùng slug id, không dùng `--label`:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=cupid-ch-ng-1 --screen=<slug> --platform=ios --out=<thư mục này>
```

## P4.2 Soi mắt: dấu tiếng Việt và glyph icon

Đã mở từng PNG và đọc trực tiếp, không chỉ dựa vào test xanh.

- Nhãn ba ô, đủ dấu, không tofu: **"Gợi ý quà"**, **"Mồi chuyện"**,
  **"Vỏ hoàng đạo"** — dấu hỏi trên `ỏ`, dấu huyền trên `à`/`ồ`, dấu nặng trên
  `ạ`/`ệ`, `ĩ` của "nghĩ" đều hiện đúng.
- Chữ xung quanh trong cùng khung hình cũng đúng dấu: "Tất cả", "Mới nghĩ ra",
  "Đã hẹn ngày", "Đi ăn quán Huế mới mở", "Xem phim cuối tuần", "Hẹn ngày",
  "Chuẩn bị", "Bắt đầu từ một điều nhỏ nhé.", "Dán cái link vừa thấy".
- Glyph icon là glyph thật, không phải ô vuông trống: hộp quà (`redeem`) ở ô 1,
  mặt cười (`mood`) ở ô 2, **chùm sao lấp lánh đặc (`auto_awesome`) ở ô 3**,
  cộng dấu `+` của FAB, icon nhãn ngày, và icon mắt xích của thẻ dán link ở
  Phút-1.
- Không có ổ khoá, không có huy hiệu "Sắp có", không có lớp phủ mờ trên ô 3 ở
  **cả hai** ảnh.

## P4.3 So với canvas

Frame canvas mang ba lối vào là `tab-y-tuong-hub-cua-vao` ("Ý tưởng — Ba lối
vào"), không phải hai frame hub. Hai frame hub (`man-goc-muon-lam`,
`phut-1-kho-trong`) **không vẽ dải lối-vào-nhanh** — dựng ra mới thấy.

Ba chỗ lệch, cả ba đều có sẵn từ trước P4:

1. **Hình dạng và chỗ đặt**: canvas vẽ ba lối vào là danh sách dọc ba hàng có
   chevron phải, nằm trong tab Ý tưởng. Bản dựng ship một dải ngang ba ô trên
   hub Muốn làm. Đây là hình dạng do STORY-001 dựng và STORY-004/005 đã lấp ô 1
   và ô 2 vào; P4 chỉ nối đích cho ô 3 và không được sửa thứ tự ô,
   `kQuickEntryCellCount`, hay key `activity_quick_entry_strip`. Không phải
   khuyết điểm của P4 — ghi nhận để UI/UX phân xử ở cấp requirement nếu muốn.
2. **Nhãn ô 3**: hàng canvas ghi "Cung & trắc nghiệm"; ô dải ghi "Vỏ hoàng
   đạo". Không đổi: "Vỏ hoàng đạo" là nhãn do AC-28 quy định cho ô, còn "Cung &
   trắc nghiệm" là **tiêu đề màn (7)** — và màn (7) đang dựng đúng tiêu đề đó
   (§1-§7). Theo phán quyết neo-thiết-kế của requirement, canvas thắng spec ở
   tranh chấp canvas-vs-spec, nhưng mục do AC quy định thì giữ nguyên.
3. **Dòng phụ của hàng**: canvas có "Vui thôi — nhưng cuối cùng vẫn ra 3 điều
   làm thật" dưới tên. Ô dải ngang không có chỗ cho dòng phụ theo hình dạng của
   STORY-001. Cùng gốc với mục 1.

Khớp với canvas: glyph chùm sao cho lối vào thứ ba, thứ tự ba lối vào (quà →
mồi chuyện → cung), và việc **không lối vào nào có điều kiện mở khoá** — canvas
cũng không vẽ ổ khoá hay huy hiệu trả phí trên hàng nào.

## P4.4 Phán quyết

`VISUAL_FIDELITY: PASS` cho bề mặt P4 sở hữu. Thứ P4 phải chứng minh bằng ảnh —
ô 3 luôn hiện, đúng nhãn "Vỏ hoàng đạo", đúng glyph `auto_awesome` đặc, không
biến thể khoá, ở cả hub đầy lẫn Phút-1 — đều thấy được trong hai ảnh và đều
đúng. Ba chỗ lệch ở P4.3 là lệch cấu trúc có sẵn của dải, nằm ngoài write scope
của P4.

## P4 Deferred

- Phân xử canvas-vs-bản dựng cho **hình dạng** ba lối vào (dải ngang trên hub
  Muốn làm so với danh sách dọc trong tab Ý tưởng, mục 1 và 3 ở P4.3). Đổi được
  thì phải đổi ở `quick_entry_strip.dart` và ở cả hai trạng thái hub — tức là
  scope của STORY-001, không phải của STORY-011. Cần UI/UX xác nhận frame
  `tab-y-tuong-hub-cua-vao` có còn là thiết kế hiện hành cho ba lối vào không.
