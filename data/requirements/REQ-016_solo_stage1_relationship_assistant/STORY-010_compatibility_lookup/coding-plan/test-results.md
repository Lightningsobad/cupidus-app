# Test Results – STORY-010 Bảng tra ăn khớp

## Phase Status

| Phase | Owner | Status | Build Gate | Test Gate |
|-------|-------|--------|------------|-----------|
| P1 | Mobile Developer | COMPLETE | PASS | PASS (35/35) |
| P2 | Mobile Developer | NOT_STARTED | — | — |
| P3 | Mobile Developer | NOT_STARTED | — | — |
| P4 | Mobile Developer | NOT_STARTED | — | — |
| P5 | Mobile Developer | NOT_STARTED | — | — |
| P6 | Mobile Developer | NOT_STARTED | — | — |

## P1 – Lược đồ gói nội dung và cổng nhập

### Commands Run

Chạy với `cwd` là `<worktree>/mobile`, `PATH` có prefix
`${FLUTTER_SDK_PATH:-$HOME/flutter}/bin`. Không nối ống.

| Command | Source | Result |
|---|---|---|
| `flutter --version` | — | Flutter 3.44.1 · Dart 3.12.1 |
| `flutter gen-l10n` | coding-agent-guide §3 | OK (dùng `l10n.yaml`) |
| `flutter test test/features/compatibility_lookup/compat_content_gate_test.dart` | runtime registry `mobile-app.testCommand` | **All tests passed!** — 35 passed, 0 failed |
| `flutter build apk --debug` | runtime registry `mobile-app.buildCommand` | **PASS** — `build/app/outputs/flutter-apk/app-local-debug.apk` (task `assembleLocalDebug`, 69.8s) |

`flutter analyze` không chạy làm bằng chứng cổng: baseline repo là 222 cảnh báo
có sẵn nên lệnh này không thể trả về 0 (coding-agent-guide §3).

Runtime startup smoke: NOT_APPLICABLE (phase file §9).

### Files Delivered

| File | Kind |
|---|---|
| `mobile/lib/features/compatibility_lookup/domain/compat_content.dart` | model + parser + `lookupCell` |
| `mobile/lib/features/compatibility_lookup/domain/compat_content_gate.dart` | cổng nhập |
| `mobile/assets/data/req016/compat_bands.v1.json` | 3 nhãn DẢI |
| `mobile/assets/data/req016/compat_zodiac.v1.json` | trục 2 (`aries`, `taurus`) + 4 ô |
| `mobile/assets/data/req016/compat_mbti.v1.json` | trục 2 (`intj`, `enfp`) + 4 ô |
| `mobile/test/features/compatibility_lookup/compat_content_gate_test.dart` | 35 test |

`pubspec.yaml` không bị sửa (thư mục asset đã khai báo từ STORY-004).

### AC Coverage

| AC | Cưỡng chế bằng | Test |
|---|---|---|
| AC-12 (bộ bốn đầy đủ) | 4 trường bắt buộc + luật rỗng-sau-trim | `every shipped cell carries the full quartet and asks at the end`; `a whitespace-only friction point`; `a whitespace-only activity` |
| AC-13 / AC-37(b) (luôn có điểm cọ xát) | `friction` bắt buộc → thiếu là **lỗi parse** | `a cell without a friction point is a parse error, not a variant` |
| AC-36 (trục suy từ dữ liệu, không hằng số) | độ phủ tính `n * n` với `n` = số item `kind: axis_value`; quét literal `12/16/144/256` trong `lib/features/compatibility_lookup` | `no Dart file in the feature hardcodes an axis size`; `widening the axis needs no code change`; `the literal scan itself can tell a count from an asset key` |
| AC-37(a) (hành vi / tần suất người kia) | `InvariantRule.recipientBehaviour` + **chỉ** `NotebookBoundaryRule.frequencyProbe` | `a recipient-behaviour indicator (AC-37a)`; `a how-often claim about the other person is a violation`; `the judgement-probe terms are the legitimate subject here` |
| AC-37(c) (số / %, điểm, hạng) | `percentDisplay` + `scoreOrRatio` **+ cấu trúc**: quét đệ quy mọi JSON value, gặp `num` là vi phạm | `a numeric field on a cell`; `a number nested inside a list`; `an ordering field on a band…`; `a percentage figure`; `a score or ranking` |
| AC-37(d) (streak / chuỗi ngày) | `InvariantRule.streakDisplay` | `a streak (AC-37d)` |
| AC-37(e) (kết bằng câu để hỏi) | `question` bắt buộc + phải kết bằng `?` sau `trim()` | `a closing line that states a verdict instead of asking`; `a cell missing the closing question is a parse error` |
| AC-38 (phủ 100%, không ô trống/dự phòng) | mọi cặp có thứ tự phải có đúng một ô; thừa/thiếu/trùng đều là `coverage_gap` | `each shipped pack covers every ordered pair of its own axis`; `a missing ordered pair…`; `a cell pointing at an axis value the pack never declares`; `two cells claiming the same ordered pair…` |
| BR-2 (ô **có hướng**) | `lookupCell` khớp `(self, partner)` theo thứ tự; id ô phải bằng `<self>__<partner>` | `a pair is ordered: the two directions are different cells (BR-2)`; `a cell id that does not match its own ordered pair` |
| BR-4 (hai trục độc lập) | hai schema id riêng; gói sai schema bị từ chối lúc nạp | `a pack under another schema id is rejected at load` |
| R-15a/R-15b (nội dung thay được, không chuỗi cứng) | quét toàn bộ `lib/**.dart` + `lib/**.arb` tìm chữ của ô | `no cell wording is written into a Dart or l10n file` |
| R-15c (một bản denylist duy nhất) | gate `import` `core/content/invariant_terms.dart`; không có danh sách từ thứ hai trong feature | `the shared invariant rules fire on compat packs too` (7 test) |

### Cổng chứng minh được, không chỉ chạy được

24 trong 35 test là **ca âm tính** dựng gói trong bộ nhớ: mỗi luật có ít nhất
một ca chứng minh nó **thật sự bắt** vi phạm, cộng một test baseline
(`the fixture baseline is clean`) để mọi ca đỏ bên dưới chỉ đỏ vì đúng một
nguyên nhân.

### Trạng thái trục (bàn giao cho P5/P6)

Mỗi gói tra cứu hiện ship **2 giá trị trục / 4 ô**, hợp lệ y như gói đầy đủ vì
cổng suy `n` từ dữ liệu. Giá trị trục dùng id thật (`aries`/`taurus`,
`intj`/`enfp`) nên P5/P6 chỉ **thêm** item, không phải viết lại. Bộ seed chưa
qua kiểm duyệt lớp 2 (AC-35/D-15) — P5/P6 ghi vết duyệt.

## Findings For Scrum Master / Tech Lead

### 1. AC id trong file phase P1 lệch với `requirements.md` (đã sửa khi dùng)

Kiểm chứng trực tiếp bằng `requirements.md` và `architecture/solution.md`
section 1 Key Discovery 2/4. Code và test dùng id **đúng**:

| Chỗ trích trong `phase-P1-…md` §6.3 | AC file phase ghi | AC thật |
|---|---|---|
| luật **Phủ kín** `n²` | AC-36 | **AC-38** (AC-36 chỉ nói `n` suy từ dữ liệu; cả hai đều được trích trong code) |
| luật **Không số** | AC-32 | **AC-37(c)** |

`AC-32` thật là *"không có ngôn ngữ tiên tri, vận mệnh, số phận"* (R-10);
`AC-34` thật là cổng cứng *"người kia chưa từng tham gia"*, không phải luật
phân giải id giữa các gói. Ánh xạ `AC-37 (a)/(c)/(d)` và `AC-37e` trong file
phase là **đúng**, đã dùng nguyên.

### 2. AC-32 (ngôn ngữ tiên tri / vận mệnh) chưa có chủ ở tầng dữ liệu

Bảy nhóm luật của P1 **không** chứa luật nào chặn từ vựng tiên tri
(`vận mệnh`, `số phận`, `định mệnh`, `tử vi`, `bói`…), và
`core/content/invariant_terms.dart` cũng không có nhóm đó. P1 không tự thêm:
thêm một danh sách từ cục bộ là đúng kiểu vi phạm R-15c mà story này tồn tại
để chặn, và mở rộng phạm vi phase. **Đề nghị quyết định**: hoặc bổ sung một
`InvariantRule` mới vào `invariant_terms.dart` (một bản duy nhất, dùng chung),
hoặc gán AC-32 cho một phase sau. Hiện tại AC-32 chỉ được bảo đảm bằng biên
tập, không bằng cổng.

### 3. Chữ ký `lookupCell` khác file phase — hình dạng hợp đồng thắng

File phase §5 ghi
`lookupCell(ContentPackage<CompatCell> pack, …)`. Không dựng được: theo
`contract-summary.md` §3 một gói tra cứu chứa **cả** item `kind: axis_value`
**và** `kind: cell` trong cùng `items`, nên tham số kiểu không thể là
`CompatCell`. Chữ ký đã ship (nguồn sự thật cho P3/P4):

```dart
CompatCell? lookupCell(
  ContentPackage<CompatItem> pack, {
  required String selfId,
  required String partnerId,
});
```

`CompatItem` là `sealed`, hai nhánh `CompatAxisValue` và `CompatCell`.
Parser cho cả gói là `compatItemFromJson`, `expectedSchemaId` là
`compatZodiacSchemaId` / `compatMbtiSchemaId`.

### 4. Mỗi item giữ lại `rawJson` — đây là điều kiện để luật cấm số chạy được

Luật AC-37(c) quét **đệ quy mọi JSON value**, mà một model đã typed thì xoá
sạch đúng những con số nó cần tìm (`weight`, `order`, `score` không nằm trong
trường nào cả). Vì vậy `CompatBand`, `CompatAxisValue`, `CompatCell` đều mang
`Map<String, Object?> rawJson` bất biến, và parser **không** từ chối khoá lạ —
khoá lạ mang số được báo là vi phạm **kèm id ô** (AC-37 đòi *"kèm id ô vi
phạm"*), thay vì ném lỗi parse không có id. P3/P4 không cần đọc `rawJson`.

### 5. `frequencyProbe` áp cho cả bốn trường, không riêng `question` — rủi ro cho P5/P6

AC-37(a) lấy ví dụ *"hay trả lời chậm"*, *"ít nhắn tin"* — đó là văn **mô tả**
trong `fit`/`friction`, không phải câu hỏi. Nên cổng quét `frequencyProbe` trên
cả bốn trường. Hệ quả cần biết trước: `thường xuyên` và `đều đặn` nằm trong
danh sách đó và là từ tiếng Việt rất thông dụng. Người soạn 400 ô ở P5/P6 sẽ
gặp chúng và phải viết lại câu. Đây là hành vi **đúng theo AC**, không phải
lỗi — ghi ra đây để P5/P6 không mất thời gian tưởng là cổng hỏng. Không nới
luật, không chép denylist.

MOBILE_IMPLEMENTATION_COMPLETE
