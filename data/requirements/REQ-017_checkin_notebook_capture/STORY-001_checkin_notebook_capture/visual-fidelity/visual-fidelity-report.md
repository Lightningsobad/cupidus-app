# Visual Fidelity Report: REQ-017 / STORY-001 — ghi nhanh vào sổ tay từ check-in

VISUAL_FIDELITY: PASS

Lane: mobile · Ngày: 2026-09-28 · Tác giả: Alex-Mobile-Dev
Phạm vi: phase P3 (`coding-plan/phase-P3-checkin-capture-block.md`) và phase P4
(`coding-plan/phase-P4-notebook-origin-label.md`).

Phần I dưới đây là P3 (màn 23h). Phần II là P4 (màn Sổ tay người yêu).

# Phần I — P3: khối hỏi phụ trong check-in 23h

## Design-Surface / Design-Screen đã giải

Design-Surface: `cupid-ch-ng-1` (`Cupid Chặng 1.dc.html`, `surface: mobile`,
`platforms: ["ios"]`, `screens_from: frames`)

Design-Screen: `23h-vua-ve-j8` (id canvas, không dùng `--label`)

Lệnh dựng phía thiết kế:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --surface=cupid-ch-ng-1 \
  --screen=23h-vua-ve-j8 --out=<visual-fidelity dir>
```

→ `DESIGN_CANVAS: OK ... design-reference-23h-vua-ve-j8-ios.png 415x900`

## Khung ảnh

| | Khung | Nguồn |
| --- | --- | --- |
| implemented-* | 412×915, dpr 1, nền `CupidColorTokens.dark()` | `RepaintBoundary` trong `test/features/phase_status/checkin_capture_block_test.dart` (`--dart-define=CAPTURE_VISUALS=true`) |
| design-reference-* | 415×900, khung iOS | `render-design-canvas.js --surface=cupid-ch-ng-1` |

Màn 23h chỉ tới được từ thông báo 23h, không có route nào trong app dẫn tới nó,
nên ảnh implemented dựng thẳng từ cây widget trong chính widget test của phase
này — không lái theo luồng thật (đúng quy tắc "render trực tiếp, không drive").

## Đặt cặp ảnh

| implemented | design-reference | id canvas |
| --- | --- | --- |
| `implemented-23h-vua-ve-j8-capture-block.png` | `design-reference-23h-vua-ve-j8-ios.png` | `23h-vua-ve-j8` |

Tên `implemented-*` mở đầu bằng đúng id canvas `23h-vua-ve-j8`; cổng fidelity
ghép cặp bằng token đầu tiên sau tiền tố, nên mọi tên bắt đầu bằng mô tả (ví dụ
`implemented-check-in-*`) sẽ không ghép được.

## DESIGN_SPEC_CONFLICT — canvas có trước khối hỏi phụ

Canvas `23h-vua-ve-j8` vẽ trạng thái cuối của REQ-016: tiêu đề "Về tới nhà rồi
chứ?", khối bối cảnh, 3 ô ảnh, trường "Một câu để giữ tối nay", hai chip
"+ ghi vào sổ tay" / "chỉ mình đọc", CTA và dòng trấn an. Canvas **không** vẽ
khối hỏi phụ mà REQ-017 thêm vào.

Phán quyết: đây là phần thêm mới do UX Phần A.2 quy định, không phải lệch so với
thiết kế. Neo thiết kế cho phần đã có trên canvas vẫn là canvas; phần mới chấm
theo UX Phần A.2. Cách xếp trong ảnh implemented khớp cả hai:

- mọi thành phần REQ-016 giữ nguyên vị trí và chữ (đối chiếu bằng mắt với
  design-reference: tiêu đề, khối bối cảnh, 3 ô ảnh, "Đính ảnh", trường câu,
  hai chip, CTA, "Để sau", dòng trấn an)
- khối mới nằm sau khối nhật ký và trước CTA, ngăn bằng một `Divider` chứ không
  phải một thẻ nền riêng (UX A.2: "một khối phụ, không phải một bước nữa")
- câu hỏi + nhãn "Tuỳ chọn" trên một hàng, một trường một dòng, rồi nhóm hai lựa
  chọn "Sở thích" / "Sự kiện" **không tô sẵn cái nào** (AC-3)

## Soi bằng mắt

Ảnh `implemented-23h-vua-ve-j8-capture-block.png` đã mở ra xem trực tiếp:

- không có ô tofu; dấu tiếng Việt đủ ở mọi chuỗi ("Tuỳ chọn", "Sở thích",
  "Sự kiện", "Hôm nay biết thêm gì về người ấy?")
- nền đục, không lộ alpha của `RepaintBoundary`
- icon ô ảnh (font `MaterialIcons` của framework) hiện đúng hình, không phải ô
  vuông rỗng
- nhóm hai lựa chọn hiển thị trạng thái "chưa chọn gì": cả hai nhãn đều ở màu
  chữ mờ, không ô nào có nền nổi

## Chạy cổng

```
python3 .claude/hooks/lib/visual_fidelity.py \
  --dir <visual-fidelity dir> --stage review --stack mobile
```

## Verdict

| # | Ảnh implemented | Trạng thái AC được chấm | Verdict |
| --- | --- | --- | --- |
| 1 | `implemented-23h-vua-ve-j8-capture-block.png` | AC-1 (khối phụ trong màn 23h), AC-3 (không tô sẵn loại), AC-7 (không thêm bước/màn), AC-17 (một dòng, không ngày/chi tiết) | PASS |

Không có khoản nào mở.

# Phần II — P4: nhãn xuất xứ trên màn Sổ tay người yêu

## Design-Surface / Design-Screen đã giải

Design-Surface: `cupid-ch-ng-1` (`Cupid Chặng 1.dc.html`, `surface: mobile`,
`platforms: ["ios"]`, `screens_from: frames`)

Design-Screen: `2-so-tay-nguoi-yeu` (id canvas, không dùng `--label`)

Lệnh dựng phía thiết kế:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --surface=cupid-ch-ng-1 \
  --screen=2-so-tay-nguoi-yeu --platform=ios --out=<visual-fidelity dir>
```

→ `DESIGN_CANVAS: OK ... design-reference-2-so-tay-nguoi-yeu-ios.png 415x900`

`--theme=dark` bị từ chối trên canvas này (`DESIGN_CANVAS_TOGGLE_MISSING:
Available toggles: (none)`) — canvas vốn đã ở nền tối, nên bỏ cờ đó.

## Khung ảnh

| | Khung | Nguồn |
| --- | --- | --- |
| implemented-* | 415×900, dpr 1, `CupidAppBackground(enableEffectsOverride: false)` | `RepaintBoundary` trong `test/features/context_notebook/origin_label_visual_capture_test.dart` (`--dart-define=CAPTURE_VISUALS=true`) |
| design-reference-* | 415×900, khung iOS | `render-design-canvas.js --surface=cupid-ch-ng-1` |

Cùng viewport 415×900 nên cặp ảnh so được mà không phải co giãn ảnh nào.

Chụp bằng `RepaintBoundary` trong widget test của chính phase này, không dùng
thiết bị: trạng thái cần chấm là một sổ tay đã có mục do check-in ghi vào, mà
đường tới trạng thái đó phải đi qua thông báo 23h rồi chờ sang màn Sổ tay. Hai
biến thể `--platform` được chụp vì dải tiêu đề iOS của `CupidHeader` là
`BackdropFilter`: chụp ngoài màn hình không có nền để lấy mẫu nên tiêu đề nhạt
đi; bản `-md` là bằng chứng cho dải tiêu đề.

Tệp riêng, không dùng chung `visual_capture_test.dart`: tệp đó ghi vào thư mục
bằng chứng của REQ-016 STORY-004, chạy lại nó sẽ ghi đè ảnh của story khác.

## Đặt cặp ảnh

| implemented | design-reference | id canvas |
| --- | --- | --- |
| `implemented-2-so-tay-nguoi-yeu-origin-ios.png` | `design-reference-2-so-tay-nguoi-yeu-ios.png` | `2-so-tay-nguoi-yeu` |
| `implemented-2-so-tay-nguoi-yeu-origin-md.png` | `design-reference-2-so-tay-nguoi-yeu-ios.png` | `2-so-tay-nguoi-yeu` |

Tên `implemented-*` mở đầu bằng đúng id canvas `2-so-tay-nguoi-yeu`.

## DESIGN_SPEC_CONFLICT — canvas không vẽ nhãn xuất xứ

Canvas `2-so-tay-nguoi-yeu` vẽ màn sổ tay ở dạng REQ-016 hình dung ban đầu: đếm
số trong tiêu đề nhóm ("SỞ THÍCH · 21"), nhóm chip cho sở thích, thẻ ngày cho sự
kiện, cặp tab "Về Cún / Về mình", thẻ giải thích cuối màn và thanh tab dưới.
Bản đã ship của màn này là kết quả REQ-016 STORY-004 đã qua review: hàng-thẻ
thay cho chip, tiêu đề nhóm **không** đếm số (AC-25 của REQ-016 cấm hẳn con
đếm), không tab "Về Cún / Về mình", và thanh tab dưới thuộc vỏ điều hướng chứ
không thuộc màn.

Phán quyết: những khác biệt đó là quyết định đã chốt và đã merge của REQ-016,
không phải lệch do P4 gây ra; P4 không được phép sửa chúng (ngoài phạm vi ghi).
Phần P4 thêm vào — dòng nhãn xuất xứ — canvas **không** vẽ, nên chấm theo UX
Phần D và AC-4/AC-5/AC-9:

- nhãn là một dòng caption mờ (`type.caption` + `colors.colorGhost`) nằm ngay
  dưới dòng nội dung/ghi chú trong cùng thẻ, không phải chip/badge/viền/nền riêng
- không icon, không mũi tên, không vùng bấm: nhãn không dẫn đi đâu (AC-15)
- chỉ mục do check-in ghi mới có nhãn; mục tự thêm giữ nguyên như trước (AC-11)
- không có nhóm thứ ba: mục sự kiện từ check-in nằm trong nhóm "Sự kiện" sẵn có

## Soi bằng mắt

Cả hai ảnh `implemented-*` đã mở ra xem trực tiếp:

- không có ô tofu; dấu tiếng Việt đủ ở mọi chuỗi ("Sổ tay người yêu", "Sở
  thích", "Sự kiện", "Phim kinh dị Hàn", "Kỷ niệm quen nhau", "+ tự thêm")
- hai nhánh nhãn hiện đúng trên cùng một màn: "từ buổi hẹn Đi cà phê tối" dưới
  "Cà phê muối" (thẻ còn dò được) và "từ một buổi hẹn" dưới "Phim kinh dị Hàn"
  (thẻ không còn dò được) — nhánh suy biến không để lại tên thẻ "Xem phim khuya"
- "Đi bộ ven hồ" (tự thêm) không có dòng nhãn nào
- nhãn mờ hơn hẳn dòng nội dung và cùng cỡ với dòng ghi chú "15/05", đúng là
  caption chứ không phải chip
- icon "..." (font `MaterialIcons` của framework) hiện đúng hình, không phải ô
  vuông rỗng
- nền đục, không lộ alpha của `RepaintBoundary`
- bản `-ios` nhạt dải tiêu đề đúng như đã ghi ở trên; bản `-md` cho thấy tiêu đề
  "Sổ tay người yêu" đầy đủ

## Chạy cổng

```
python3 .claude/hooks/lib/visual_fidelity.py \
  --dir <visual-fidelity dir> --stage review --stack mobile
```

## Verdict

| # | Ảnh implemented | Trạng thái AC được chấm | Verdict |
| --- | --- | --- | --- |
| 2 | `implemented-2-so-tay-nguoi-yeu-origin-ios.png` | AC-4 (mục vào đúng nhóm sẵn có), AC-5 (ảnh chụp tên thẻ), AC-9 (nhãn suy biến), AC-11 (mục tự thêm không đổi) | PASS |
| 3 | `implemented-2-so-tay-nguoi-yeu-origin-md.png` | AC-4, AC-5, AC-9, AC-15 (nhãn không phải liên kết) | PASS |

Không có khoản nào mở.
