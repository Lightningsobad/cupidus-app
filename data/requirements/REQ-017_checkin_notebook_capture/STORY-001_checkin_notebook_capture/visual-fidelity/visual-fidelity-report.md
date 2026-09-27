# Visual Fidelity Report: REQ-017 / STORY-001 — khối hỏi phụ trong check-in 23h

VISUAL_FIDELITY: PASS

Lane: mobile · Ngày: 2026-09-28 · Tác giả: Alex-Mobile-Dev
Phạm vi: phase P3 (`coding-plan/phase-P3-checkin-capture-block.md`).

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
