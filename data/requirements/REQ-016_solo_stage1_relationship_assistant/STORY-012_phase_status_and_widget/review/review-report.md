# Review Report: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

Outcome: PATCH_REQUIRED

Lượt S9 · `full-story-review` · tái review sau `PATCH_REQUIRED` của S8
Scope gate: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`)
Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
Mốc diff dùng thật: `5d23250f..HEAD` (`63a15bb0`) — 31 tệp, 15 tệp
source/test/config. Xem scope gate để biết vì sao không dựng lại `b58afbe0..HEAD`.

## Lý do outcome, trong một đoạn

Năm trong sáu finding chặn của S8 **đóng thật** — tôi mở ảnh ra soi, không nhận
trên lời khai. B-1 đóng đúng **một nửa**: hợp đồng dữ liệu (`action_label`,
ngân sách 28 grapheme, cổng AC-39) làm đúng và làm tốt, nhưng **hình khối** của
chip thì không. `ux/uiux-spec.md` §1, chính bản vá B-1 ngày 2026-09-26, chốt
nguyên văn "chip bo tròn, **không phải text button trần**"; bản dựng lại giao
đúng text button trần, và tự viện dẫn bảng action-tier cũ mà bản vá đó vừa thay
thế. Đây là lệch thấy được trên bề mặt AC9 liệt kê, nên AC9 vẫn `FAIL`
(rule 12e2 + rule 14). Thêm B-7: cổng bằng chứng thị giác `visual_fidelity.py`
hiện **exit 1** trên chính bộ ảnh này, nên dù mọi delta đóng hết thì story vẫn
không qua được cổng DONE.

Không dùng `BLOCKED`: cả hai khoản đều có chủ trong pipeline và đều sửa được.
Không dùng `DESIGN_SPEC_CONFLICT` cho B-1a — ở đây canvas và UX spec **đồng ý
với nhau**, chỉ bản dựng đứng một mình.

## Sáu finding chặn của S8 — trạng thái hôm nay

| Id S8 | Trạng thái | Bằng chứng tôi tự kiểm |
|---|---|---|
| **B-1** nhãn hành động phụ trên `hub-waiting` | **ĐÓNG NỬA → mở lại thành B-1a** | Dữ liệu: `phase_content.v1.json` khai `"action_label": "Chọn trước một chỗ"` cho `phase.waiting.prepare.v1`; `PhaseContentItem.actionLabel` vào thẳng `displayStrings` nên cổng AC-39 đo nó (`phase_content_gate_test.dart:378` quét toàn bộ `invariantDeniedTerms`). **Hình khối: lệch** — xem B-1a |
| **B-2** nền theo pha | **ĐÓNG** | Mở `implemented-widget-date-day.png`: gradient hồng→tím thật. Mở `-waiting` và `-upcoming` chụp **sau** nó: nền đã về `#241B42` phẳng, gradient không đọng lại. `backgroundFor()` đẩy drawable ở **cả hai** nhánh qua `setBackgroundResource` — đúng lý do `RemoteViews.reapply` mà §3b nêu |
| **B-3** dòng phụ bị cắt "…" | **ĐÓNG** | Bốn ảnh widget: không ảnh nào còn dấu "…". `minWidth` 180dp → **250dp** đã sửa thật trong `cupid_phase_widget_info.xml` (commit `a8aa1ff4`) — xem mục "Ba khoản định tuyến", khoản 1. Ngân sách 28 grapheme ép ở `phaseContentItemFromJson` bằng `ContentPackageFormatException`, đúng tầng lược đồ §4a chốt, không thêm cơ chế cổng thứ hai |
| **B-4** ô vuông `@mipmap/ic_launcher` | **ĐÓNG** | `ImageView` gỡ hẳn khỏi layout; bốn ảnh widget không còn phần tử sáng nào bên trái. Cột chữ bắt đầu sát lề đệm, đúng canvas |
| **B-5** số cỡ display trên Android | **ĐÓNG** | `implemented-widget-upcoming.png`: "4" cỡ lớn màu hồng trong cùng một dòng chảy. `displaySizedNumeral()` đặt span lên **chuỗi payload**, không tách `TextView`, không bỏ/đổi thứ tự ký tự nào → AC-37/BR-15 giữ nguyên. Luật là "có cụm chữ số hay không", không rẽ theo `phase_id` — đúng parity iOS §3c |
| **B-6** tia chớp hồng chìm | **ĐÓNG** | `implemented-widget-date-day.png`: tia chớp gần trắng trên nền gradient, đọc rõ. `DOT_TODAY = ON_ACCENT` khai tường minh ở **cả hai** palette native, không alias lên `TEXT` — đúng yêu cầu hợp đồng |

**Ràng buộc thứ tự B-2 + B-6 đã được tôn trọng**: cả hai vào cùng commit
`a8aa1ff4`. Không có cửa sổ nào tồn tại trạng thái "hồng trên hồng" hay
"gần-trắng trên nền phẳng".

## Finding chặn (phải đóng trước khi DONE)

### B-1a · Chip hành động phụ giao sai hình khối

| | |
|---|---|
| Mức | BLOCKING (AC9) |
| Chỗ | `mobile/lib/features/phase_status/presentation/phase_status_line.dart` — `_PhaseStatusAction` |
| Chủ | mobile-dev (quyết định đã có sẵn, không cần vòng UX/Tech Lead mới) |

Ba nguồn chi phối đều nói cùng một điều, và bản dựng nói điều khác:

1. `ux/uiux-spec.md` §1, vá 2026-09-26 (B-1): *"hình khối theo canvas
   `cupid-ch-ng-1` màn `hub-waiting` (**chip bo tròn, không phải text button
   trần**)"*. Bản vá này **thay thế** câu cũ ở chính dòng đó ("text button,
   không nền đặc, `caption 13pt`").
2. Canvas `ngan-da-hen-ngay-dang-doi`: trong khối hướng-chuẩn-bị, chip
   `Chọn quán dự phòng` là một **viên thuốc bo tròn có viền và có mặt nền**
   riêng, chiếm khoảng nửa bề rộng khối.
3. `implemented-hub-waiting.png`: `Chọn trước một chỗ` là **chữ hồng trần** —
   không viền, không nền, không hình khối nào — thụt lề `md` và đọc như một
   dòng caption thứ ba của khối, không như một affordance.

`_PhaseStatusAction` dựng `Text` trong `GestureDetector`, không `Container`
trang trí nào, và dartdoc của nó viện dẫn
`ux/requirement-ux-survey.md` §4 — đúng cái bảng action-tier mà bản vá B-1 vừa
thay thế cho phần tử này. Bảng verdict "Lượt patch #4" (`visual-fidelity-report.md:782`)
cũng chấm ô 1 `PASS` với cùng lý lẽ đã lỗi thời, nên `PASS` đó không đứng vững.

Ba chi tiết cố ý khác giữa bản dựng và canvas ở chính khối này thì **đúng** và
không phải sửa — ghi ra để lượt sau không "sửa nhầm hướng":

- chỉ **một** chip: chip thứ hai `Rủ lại kiểu khác` đã bị PO bác (AC-6/AC-7);
- chữ `Chọn trước một chỗ` thay `Chọn quán dự phòng`: tiền lệ D-8, canvas là
  nội dung mẫu;
- chạm chip mở màn chi tiết A4 của chính thẻ, không route mới: AC-4.

Yêu cầu sửa: cho chip mặt nền/viền bo tròn theo canvas, giữ nguyên nhãn, nguồn
nhãn, đích chạm, và vùng chạm ≥44dp đã có. Rồi chụp lại **ô 1**.

### B-7 · Cổng bằng chứng thị giác exit 1 trên chính bộ ảnh này

| | |
|---|---|
| Mức | BLOCKING (chặn đóng story, không phải lỗi bản dựng) |
| Chủ | Tech Lead (chốt quy ước) — không phải mobile-dev |

Tôi tự chạy, không suy từ báo cáo:

```
python3 .claude/hooks/lib/visual_fidelity.py --dir <story dir> --stage review --stack mobile
→ exit 1
"no screen has BOTH renders, so nothing was actually compared:
 running-app renders exist for ['evening','hub','quiet','widget']
 and design renders for ['23h','j12','man','ngan']"
```

Đây **không** phải nghi ngờ về việc đối chiếu có xảy ra hay không: bảng ghép
cặp ở `visual-fidelity-report.md:85-93` là rõ ràng, ảnh đều thật, và tôi đã tự
mở bốn cặp ra soi. Vấn đề thuần tuý là hai cổng đòi hai quy ước tên:
`visual_fidelity.py` ghép theo token `<screen>` đầu tiên sau tiền tố, còn
`validate-dev-design-render.sh` cấm gắn nhãn vào tên export của canvas.
`story_master.md:17` khai `Design-Screen` bằng **nhãn bản dựng**
(`hub-waiting`, `widget-phases`…), còn canvas `cupid-ch-ng-1` đặt tên bằng
**slug nội dung** (`ngan-da-hen-ngay-dang-doi`, `sb-84-widget-bon-pha`) — hai
từ vựng, và ở REQ-016 còn là quan hệ nhiều-một (một frame canvas phục vụ hai
trạng thái bản dựng).

Lane mobile **đúng** khi không tự đổi tên, không nhân bản ảnh kèm nhãn, và
không sửa cổng. Nhưng khoản này không thể để "ghi nhận rồi đi tiếp": cổng DONE
chạy đúng script này một cách độc lập, nên chừng nào nó còn exit 1 thì không
lượt review nào có thể trả `CLEAN` và không ai đóng được story. Phải chốt
trước hoặc cùng lượt rework B-1a.

## Ba khoản định tuyến handoff giao lại — phân xử

**1. `cupid_phase_widget_info.xml` `minWidth` 180dp → 250dp: đã sửa rồi, tiền
đề của handoff là cũ.** Thay đổi nằm trong commit `a8aa1ff4`, cùng lượt
mobile-dev, kèm ghi chú lưới launcher `70n-30`. Không còn việc gì cho khoản
này; không cần mở WriteScope.

**2. Xung đột quy ước tên giữa hai cổng: có chặn.** Nâng thành **B-7** ở trên.
Nó không chặn *việc chứng minh* AC9 (tôi đã chứng minh bằng mắt), nhưng nó
chặn *việc đóng* story. Hai khoản đó khác nhau và khoản thứ hai mới là khoản
quyết định lộ trình.

**3. N-2 (registry `buildCommand` thiếu `--flavor local`): DEFERRED, chủ
DevOps.** Ngoài WriteScope story, không ảnh hưởng bất kỳ AC nào của STORY-012,
và lệnh dựng thật đã chạy xanh với flavor đúng. Giữ nguyên phân loại S8.

## Cổng bằng chứng

| Cổng | Kết | Bằng chứng |
|---|---|---|
| Entry point reachability (12e1) | **PASS** | Kế thừa S8, delta không chạm điều hướng. Chip mới dùng lại `_openDetail` đã có |
| Runtime startup smoke (12g) | **PASS** | Lượt patch #4 cài + chạy APK thật để chụp bốn ảnh widget; `adb logcat -d` không exception `com.snapsofts.cupid` |
| Build native Android | **PASS** | `flutter build apk --debug --flavor local --split-per-abi` xanh sau khi thêm hai drawable + span. Hai XML mới **không** chứa chuỗi `--` trong comment — bẫy đã làm vỡ bản dựng ở P11 không lặp lại |
| Test đơn vị/widget | **PASS (bằng chứng gián tiếp)** | `native_copy_scan_test.dart` 38/38 ghi trong báo cáo thị giác; `+103 ~4` ghi ở `story_master.md:31` và thông điệp commit `a8aa1ff4`, do Scrum Master chạy độc lập. Không chạy lại (rule 18). Khoảng hở tài liệu: **N-7** |
| Hợp đồng `action_label` + ngân sách 28 | **PASS** | Ép ở `phaseContentItemFromJson`; `action_label` trên `surface: widget` là lỗi nạp, không bị bỏ qua; `phase_content_repository_test.dart` +138 dòng fixture |
| Cổng bất biến AC-39 phủ nhãn chip | **PASS** | `actionLabel` nằm trong `displayStrings`; test quét toàn bộ `invariantDeniedTerms` + `percentDisplay` |
| **Design fidelity (12e2/12e3)** | **FAIL** | Ô 1 lệch hình khối chip (B-1a). Ô 7 nay **PASS** thật |
| **Script cổng `visual_fidelity.py`** | **FAIL (exit 1)** | B-7 |
| Configuration guide (12a) | **PASS** | Delta không thêm bước cài đặt/biến môi trường nào |
| Playwright / e2e trình duyệt | `NOT_APPLICABLE` | lane `mobile` |

## Finding không chặn

| Id | Mức | Nội dung |
|---|---|---|
| **N-7** (mới) | MEDIUM (bằng chứng) | `coding-plan/test-results.md` **không** có mục nào cho lượt patch #4, dù lượt đó đổi mã native, thêm hai drawable, và sửa 4 tệp test (+226 dòng). Bằng chứng test chỉ sống ở thông điệp commit, `story_master.md`, và báo cáo thị giác. Gộp vào lượt rework B-1a: thêm một mục `## Lượt patch #4` với lệnh và kết quả thật |
| **N-8** (mới) | LOW (thị giác) | `implemented-widget-upcoming.png`: khoảng trắng sau cụm số phóng to gần như bị nuốt — đọc thành "Còn 4ngày tới". Hệ quả của `RelativeSizeSpan` trên một `TextView`; chuỗi payload không bị đổi nên AC-37 vẫn nguyên. Cân nhắc mở rộng span thêm một ký tự trắng, hoặc chấp nhận |
| **N-9** (mới) | LOW (thị giác, không chặn có chủ ý) | Nền gradient bản dựng đọc **đậm và bão hoà hơn** thẻ pha tương ứng của canvas, vốn là một lớp hồng-tím trầm trên nền tối. Không nâng thành delta chặn: giá trị hex đến từ token `gradientHot` mà D-12 và §3b đã chốt, còn thẻ canvas được vẽ ở ~1/3 cỡ trong khung máy tối. Nếu UX muốn nền trầm hơn thì đó là quyết định ở tầng token, không phải việc STORY-012 tự chọn |
| **N-1** | MEDIUM (độ chính xác bằng chứng) | **Vẫn mở.** Bảng ô 7 lượt patch #4 (`visual-fidelity-report.md:773`) tiếp tục chấm "Nhãn-mí" là KHỚP, trong khi bản dựng đọc `PHA 3 · ĐÚNG NGÀY HẸN` còn thẻ canvas ghép cặp đọc `PHA 4 · HÔM NAY, TRƯỚC GIỜ ĐI`. Lệch này **đã được phân xử** (S8 mục A-2: canvas thua vì AC-11/AC-12/BR-11), nên không phải lỗi dựng — nhưng ô bảng nên ghi "lệch có chủ đích, xem D-13(1)". Một chữ "KHỚP" đặt nhầm chỗ là cách một PASS sai sinh ra ở lượt sau |
| **N-2** | MEDIUM (ops) | Vẫn mở. `mobile-app.buildCommand` thiếu `--flavor local`. Ngoài WriteScope story. Chủ: DevOps |
| **N-3** | MEDIUM (hợp đồng) | Vẫn mở. `home_widget` 0.9.4 ghi vào `HomeWidgetPreferences`, không phải prefs mặc định như `contract-summary.md` §1 mô tả. Chủ: Tech Lead |
| **N-4** | LOW | Vẫn mở. Chặng điều hướng trong app từ deep link tới đúng `card_id` chưa kiểm chứng được (API local không chạy). Điểm vào đã chứng minh thật |
| **N-5** | LOW | Vẫn mở. §3.5 iOS của P12 `SKIPPED` theo diện tuỳ chọn; ô 7 đóng bằng ảnh Android |
| **N-6** | INFO | Vẫn mở. `implemented-hub-waiting.png` còn dải DEBUG đỏ góc trên phải. Harness nên đặt `debugShowCheckedModeBanner: false` |

**Còn hiệu lực từ S7/S8, rework không chạm tới, không khoản nào chặn:** R-2 và
D-A, D-B, D-C, D-D, D-F, D-G, D-H, D-I, D-J, D-K, D-L, D-N. Giữ nguyên phân
loại và chủ sở hữu.

## AC-by-AC (chỉ ghi phần S9 đổi)

| AC | Kết | Căn cứ |
|---|---|---|
| AC1–AC8 | **PASS** | Không đổi so với S8. Delta không chạm hành vi nào của AC1–AC8; bốn chuỗi `secondary` mới vẫn qua cổng bất biến và không thêm suy đoán/đếm ngày nào |
| **AC9** bảy design screen khớp canvas `cupid-ch-ng-1`, không lệch thấy được về bố cục, khoảng cách, màu sắc, typography, **và trạng thái** | **FAIL** | Ô 7 `widget-phases` lật **PASS** ở lượt này (B-2..B-6 đóng, soi ảnh xác nhận). Ô 1 `hub-waiting` vẫn **FAIL**: hình khối chip (B-1a). Ô 2–6 PASS |

## Ghi nhận về chất lượng lượt sửa

Đáng giữ lại, vì chúng là lý do lượt này kiểm được nhanh và vì chúng nên lặp
lại:

1. Tech Lead **đo** thay vì phán: `#FF7FB6` trên `gradientHot` cho 1.00:1 /
   1.11:1, `#F7EEFB` cho 2.07:1 / 2.30:1. Và **tự khai phần hụt** — 2.07:1 vẫn
   dưới 3:1 — thay vì tuyên bố đạt AA. Đó là cách ghi một khoản nợ đúng chỗ.
2. `backgroundFor()` đẩy drawable ở cả nhánh phẳng, kèm lý do `RemoteViews.reapply`
   viết ngay tại chỗ. Đây là loại lỗi chỉ hiện sau khi người dùng đổi pha lần
   đầu, tức là loại lỗi review không bắt được — nó được xử lý trước.
3. B-5 được mở rộng đúng hướng: S8 nêu `upcoming` vì đó là pha được chụp, Tech
   Lead nhận ra iOS rẽ theo "có chữ số hay không" và bắt Android theo cùng luật
   thay vì vá đúng pha bị nêu tên.
4. Mobile-dev **không** tự đổi tên ảnh design để làm cổng xanh. Đó là lựa chọn
   đúng và nó là lý do B-7 còn nhìn thấy được thay vì bị che.

## Khuyến nghị trạng thái

- Bỏ tick `Implementation (Development)` trong `story_master.md` (hiện đang
  `[x]`).
- Để trống `Review (Reviewer)`.
- Story status: `IN_PROGRESS`.
- Định tuyến, theo thứ tự:
  1. **Tech Lead** chốt B-7 (quy ước ghép tên giữa `visual_fidelity.py` và
     `validate-dev-design-render.sh`). Không mã sản phẩm. Phải xong trước hoặc
     cùng bước 2, nếu không lượt review kế tiếp vẫn không trả `CLEAN` được.
  2. **mobile-dev một lượt nhỏ**: B-1a (hình khối chip), N-7 (ghi
     `## Lượt patch #4` vào `test-results.md`), tuỳ chọn N-8, N-6; chụp lại
     **ô 1**; sửa ô bảng N-1 trong báo cáo thị giác.
- WriteScope cần mở cho bước 2: `phase_status_line.dart`,
  `coding-plan/test-results.md`, `visual-fidelity/`. **Không** cần
  `phase_content.v1.json`, `activity_card_tile.dart`, hay
  `cupid_phase_widget_info.xml` — ba tệp đó đã đúng.
- Golden test bốn pha: vẫn **chưa** đặt, và vẫn đúng thứ tự — `--update-goldens`
  chỉ chạy sau khi ô 1 đạt.
- N-2 tách sang DevOps, độc lập với story này.

## Đếm finding

- Chặn: **2** (B-1a, B-7)
- Đóng ở lượt này: **5** (B-2, B-3, B-4, B-5, B-6) + nửa dữ liệu của B-1
- Không chặn mới ghi ở lượt này: **3** (N-7, N-8, N-9)
- Không chặn kế thừa, vẫn mở: **6** (N-1..N-6) + 13 khoản R-2/D-* của S7
