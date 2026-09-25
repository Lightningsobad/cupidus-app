# Review Report: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

Outcome: PATCH_REQUIRED

Lượt S8 · `full-story-review` · tái review sau rework P9–P12
Scope gate: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`)
Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
Mốc diff dùng thật: `322c4276..HEAD` (delta rework, 51 tệp / 20 tệp
source-test-config) — xem scope gate để biết vì sao không dựng lại toàn bộ
`b58afbe0..HEAD` (107 tệp).

## Lý do outcome, trong một đoạn

Rework P9–P12 đã đóng **mọi** finding chặn của lượt S7 trừ đúng một:
`visual-fidelity/visual-fidelity-report.md:3` vẫn ghi `VISUAL_FIDELITY: FAIL`.
Đây không phải thiếu bằng chứng mà là verdict thật, và tôi đã tự mở bốn ảnh
widget cùng ảnh `hub-waiting` ra soi: những lệch mà báo cáo nêu **có thật, nhìn
thấy được**. AC9 đòi bảy design screen "không lệch thấy được về bố cục, khoảng
cách, màu sắc, và typography", nên AC9 `FAIL` kéo theo outcome này (SKILL rule
12e2/12e3 + rule 14).

Không dùng `BLOCKED`: từng khoản còn mở đều có chủ sở hữu trong pipeline và
đều sửa được, không khoản nào bị chặn bởi môi trường, credential hay một quyết
định người dùng chưa có. Hai khoản **từng** được treo chờ Reviewer phân xử
(R-4, D-13 mục 1) được tôi đóng ngay trong báo cáo này, không đẩy lên user.

## Những gì tôi tự kiểm, không nhận trên lời khai

| Kiểm | Kết quả |
|---|---|
| Mở `implemented-widget-date-day.png` | Thật: ảnh launcher Android, thẻ widget trên nền tường. Tia chớp hồng + `PHA 3 · ĐÚNG NGÀY HẸN` + dòng chính đậm + dòng phụ. Không splash, không tofu, không màn lỗi |
| Mở `design-reference-sb-84-widget-bon-pha-ios.png` | Đúng screen `sb-84-widget-bon-pha` của surface `cupid-ch-ng-1`: tờ spec bốn thẻ pha, đúng bề mặt story này nói tới |
| Đối chiếu hai ảnh | **Mâu thuẫn với chữ "KHỚP" ở một dòng bảng — xem N-1.** Các lệch R-6/R-7/R-8/R-3 thì đúng y như báo cáo mô tả |
| Mở `implemented-hub-waiting.png` | Khối hướng-chuẩn-bị nay nằm **trong** thẻ, có mặt bo góc (D-1 đóng thật), nhãn-mí `● MỚI NGHĨ RA` có (D-2 đóng thật). Hai chip hành động hiện là `Hẹn ngày` + `…` — R-1 có thật |
| `dot_today_bolt.xml` hiện trạng | Chú thích dòng 3 đã là `dot_today`, XML hợp lệ. Sửa ở `4a52b37c` |
| `mobile/ios/Runner/Info.plist:25-37` | `CFBundleURLTypes` → `cupidapp` **có mặt**. C-3 đóng |
| `deployment/configuration-guide.md` | Có mục "Register the `cupidapp` URL scheme on Runner", nêu cả bẫy `flutter create .` ghi đè. Rule 12a thoả |

## Ba finding chặn của S7 — trạng thái hôm nay

| Id S7 | Trạng thái | Bằng chứng |
|---|---|---|
| **C-1** `VISUAL_FIDELITY: FAIL` (10 delta cài đặt) | **ĐÓNG một phần** — D-1..D-5, D-7..D-9, D-11(iOS), D-12 đóng ở lượt patch #2; D-10 đóng ở P9 (hợp đồng payload 5→6 khoá, thêm `eyebrow_line`, chấm màu tra theo `phase_id`). Phần còn lại chuyển thành B-1..B-6 dưới đây | `visual-fidelity-report.md` mục "Lượt patch #2", "Lượt patch #3 — D-10" |
| **C-2** cần quyết định trước (D-6, D-10) | **ĐÓNG** — D-6 đã có quyết định Scrum Master (canvas thắng, dựng bản toàn màn); D-10 đã dựng xong cả hai nền tảng | `evening_check_in_sheet.dart` (+479), P9 §7 |
| **C-3** scheme `cupidapp` chưa đăng ký iOS | **ĐÓNG** — đã có trong plist **và** trong configuration guide | `Info.plist:25-37` |

## Cổng bằng chứng

| Cổng | Kết | Bằng chứng |
|---|---|---|
| Entry point reachability (12e1) | **PASS** | `test-results.md` §Entry Point Reachability (4 bề mặt). Kiểm độc lập trên thiết bị ở P12 §4: `dumpsys appwidget` thấy provider `zombie=false`; đặt widget bằng thao tác UI thật; chạm → `ResumedActivity: com.snapsofts.cupid/...MainActivity` |
| Runtime startup smoke (12g) | **PASS** | iOS: build → `simctl install`/`launch` → ảnh màn đầu. Android: `flutter build apk --debug --flavor local --split-per-abi` xanh → `adb install -r` → app chạy, `adb logcat` không exception. Khoản nợ D-E của S7 đóng |
| Build native Android | **PASS sau khi sửa hồi quy** | P12 lượt 1 đỏ `ANDROID_RESOURCE_PARSE_FAILED` (chuỗi `--` trong chú thích XML làm **toàn bộ** app không dựng được); sửa 1 dòng ở `4a52b37c`; lượt 2 xanh, sinh 3 APK |
| `ContextCompat` (rủi ro treo từ P11) | **ĐÓNG** | `:app:compileLocalDebugKotlin` chạy qua ở lượt 2; `androidx.core` tới qua phụ thuộc bắc cầu của Flutter embedding. Không cần sửa `build.gradle.kts` |
| Test đơn vị/widget | **PASS** | `test/features/activity_cards` `+213 ~2`; `test/features/phase_status` `+235 ~6`; `native_copy_scan_test.dart` 38/38 ở P12. Các skip đều thuộc nhóm `CAPTURE_VISUALS` |
| Hợp đồng payload 5→6 khoá | **PASS** | Round-trip đọc lại trên thiết bị: đủ 6 khoá, dấu tiếng Việt và `·` (U+00B7) nguyên vẹn. Chuỗi hiện ra khớp từng chữ với `phase_content.v1.json` → AC-37/BR-15 giữ được |
| **Design fidelity (12e2/12e3)** | **FAIL** → outcome | `visual-fidelity-report.md:3`, xác nhận bằng mắt |
| Configuration guide (12a) | **PASS** | +29 dòng cho scheme `cupidapp` |
| Playwright / e2e trình duyệt | `NOT_APPLICABLE` | lane `mobile` |

## Phân xử của Reviewer (hai khoản bằng chứng giao lại cho tôi)

### A-1 · R-4 "Để sau" trên màn 23h — **KHÔNG phải delta, giữ nguyên**

`visual-fidelity-report.md:409` treo khoản này chờ Reviewer. Canvas
`23h-vua-ve-j8` không vẽ nút thoát nào; bản dựng giữ nút "Để sau" dưới CTA.
AC-17 đòi "bỏ qua" phải là một cái kết **một chạm**; trên một bề mặt toàn màn,
bỏ nút đi thì chỉ còn cử chỉ back của hệ thống, tức là AC-17 hỏng. Tiền lệ
design-anchor của REQ-016 ("canvas thắng") chỉ phân xử spec-prose vs canvas;
khoản do AC quản thì AC thắng. **Giữ nút. Không patch. Đóng R-4.**

### A-2 · D-13 mục 1 — ngữ nghĩa "PHA n": **KHÔNG phải delta, và không phải việc phải hỏi user**

Canvas đánh số pha theo trạng thái thẻ và hai trong bốn nhãn nói thẳng về
người kia ("PHA 2 · ĐANG ĐỢI CÚN TRẢ LỜI"). AC-11/AC-12/BR-11 cấm widget nhắc
người kia, và AC2 của story liệt kê đúng bốn pha *đang đợi · sắp hẹn · đúng
ngày hẹn · khoảng lặng* — thứ tự mà bản dựng theo. Bản dựng thoả AC; **canvas
là bên mâu thuẫn với AC**. Không leo thang thành `BLOCKED: DESIGN_SPEC_CONFLICT`
vì khoản này đã được chính các AC phân xử rồi, không còn gì để user chọn.
**Ghi rõ để không lượt nào "sửa cho khớp canvas" về sau — làm thế là phá AC-11.**

## Finding chặn (phải đóng trước khi DONE)

Tất cả đều là delta thị giác thật, đều nằm trên bề mặt AC9 liệt kê.

| Id | Mức | Nội dung | Chỗ sửa | Chủ |
|---|---|---|---|---|
| **B-1** (R-1) | BLOCKING | `hub-waiting`: canvas vẽ hai chip hành động có nhãn trong khối hướng-chuẩn-bị; bản dựng chỉ có `Hẹn ngày` + `…`. Chuỗi phải đến từ gói nội dung (AC-37/BR-15), không được nghĩ chữ trong mã | `phase_content.v1.json` (thêm chuỗi) rồi `activity_card_tile.dart` (dựng chip) | Product Owner → mobile-dev |
| **B-2** (R-6) | BLOCKING | Nền widget phẳng `#241B42` cho cả bốn pha; canvas cho thẻ pha hôm nay một gradient hồng→tím riêng. Đã soi ảnh: đúng vậy | `cupid_phase_widget.xml:17` cần drawable gradient theo pha | Tech Lead → mobile-dev |
| **B-3** (R-7) | BLOCKING | Dòng phụ bị cắt "…" ở ô mặc định 3×1. Đã soi ảnh: `Mang theo máy ảnh nếu bạn muốn c…` | `cupid_phase_widget.xml:85` (`maxLines=1`) — chọn giữa nới `maxLines`, ô mặc định 4×1, hay rút chuỗi trong pack | UI/UX → mobile-dev |
| **B-4** (R-8) | BLOCKING | `@mipmap/ic_launcher` dựng thành một ô gần như trắng đục bên trái thẻ; canvas không vẽ biểu tượng ứng dụng nào. Đã soi ảnh: đây là phần tử chói nhất trong thẻ | `cupid_phase_widget.xml:22-27` — bỏ hẳn, hoặc bản đơn sắc nền trong | UI/UX + Tech Lead → mobile-dev |
| **B-5** (R-3) | BLOCKING | Không có xử lý chữ số cỡ display cho pha `upcoming` trên Android; canvas vẽ "4" cỡ lớn cạnh "ngày nữa". iOS đã có (D-11 đóng nửa) | `CupidPhaseWidgetProvider.kt` (`SpannableString`) | Tech Lead mở scope → mobile-dev |
| **B-6** (D-13 mục 2) | BLOCKING | Chỉ báo `date_day` là tia chớp **hồng** `#FF7FB6`; canvas vẽ tia chớp sáng gần trắng | `architecture/contract-summary.md` §3a khoá vai trò `--dot-today` → cần quyết định vai trò/màu trước khi sửa mã | UI/UX + Tech Lead |

**Ràng buộc thứ tự cho lượt rework:** B-2 và B-6 phải đi cùng nhau. Hôm nay tia
chớp hồng đọc được **chỉ vì** nền đang phẳng và tối (B-2). Thêm gradient hồng
mà không đổi màu chỉ báo là dựng lại đúng vấn đề "hồng trên hồng" mà D-13 đã
cảnh báo — lúc đó cả hai đều đã "xong" mà kết quả lại tệ hơn hôm nay.

## Finding không chặn

| Id | Mức | Nội dung |
|---|---|---|
| **N-1** | MEDIUM (độ chính xác bằng chứng) | Bảng đối chiếu ô 7 (`visual-fidelity-report.md:597`) chấm dòng "Nhãn-mí" là **KHỚP**, nhưng ảnh bản dựng đọc `PHA 3 · ĐÚNG NGÀY HẸN` còn thẻ canvas được ghép cặp đọc `PHA 4 · HÔM NAY, TRƯỚC GIỜ ĐI`. Kiểu chữ khớp, **chữ thì không**. Lệch đó là khoản A-2 đã phân xử (canvas thua), nên không phải lỗi dựng — nhưng ô bảng nên ghi "lệch có chủ đích, xem D-13(1)" thay vì "KHỚP". Một chữ "KHỚP" đặt nhầm chỗ là cách một PASS sai sinh ra ở lượt sau |
| **N-2** | MEDIUM (ops) | `data/devops/system/runtime-command-registry.json` `mobile-app.buildCommand` là `flutter build apk --debug`, không chạy được vì module khai hai flavor `local`/`prod`. Ngoài WriteScope story. Chủ: DevOps |
| **N-3** | MEDIUM (hợp đồng) | `home_widget` 0.9.4 ghi vào file prefs riêng `HomeWidgetPreferences` (hằng `HomeWidgetPlugin.PREFERENCES`), không phải prefs mặc định của app như `architecture/contract-summary.md` §1 mô tả. Tài liệu lệch mã. Chủ: Tech Lead |
| **N-4** | LOW | Chặng điều hướng **trong app** từ deep link widget tới đúng thẻ `card_id` chưa kiểm chứng được (API local không chạy, app dừng ở "Không thể kết nối máy chủ"). Điểm vào thì đã chứng minh thật — intent tới được MainActivity. Không chặn 12e1 |
| **N-5** | LOW | §3.5 iOS của P12 (chụp widget WidgetKit trên máy ảo iOS) `SKIPPED` theo diện tuỳ chọn; ô 7 đã đóng bằng ảnh Android |
| **N-6** | INFO | `implemented-hub-waiting.png` vẫn còn dải DEBUG góc trên phải — trùng D-M của S7. Harness nên đặt `debugShowCheckedModeBanner: false` |

**Còn hiệu lực từ S7, rework không chạm tới:** R-2 (`ActivityCard` không mang
trường giờ nên "19:20"/"rủ từ 14:02" không dựng được — đã được chấp nhận là
lệch, chủ Tech Lead/PO nếu muốn mở hợp đồng dữ liệu), và D-A, D-B, D-C, D-D,
D-F, D-G, D-H, D-I, D-J, D-K, D-L, D-N. Không khoản nào trong số đó chặn; giữ
nguyên phân loại và chủ sở hữu của S7.

## Ghi nhận về chất lượng hồ sơ

Hai điểm đáng giữ lại, vì chúng là lý do lượt này kiểm được nhanh:

1. P12 **tự khai** một khiếm khuyết của P11 làm hỏng toàn bộ bản dựng Android
   thay vì lách qua, và ghi rõ vì sao bộ test canh ASCII không thể bắt được nó
   (nó tước chú thích **trước** khi quét). Đó là loại ghi chép làm review có
   giá trị.
2. Verdict `FAIL` được giữ nguyên qua ba lượt patch dù áp lực đóng story rất
   rõ, và mỗi khoản mở đều có tên chủ sở hữu. Không có chữ ký khống nào.

## AC-by-AC

| AC | Kết | Căn cứ |
|---|---|---|
| AC1 SB-83 hướng sang việc chuẩn bị, không suy đoán người kia | **PASS** | Khối hướng-chuẩn-bị nằm trong thẻ (ảnh `hub-waiting`); đã soi toàn ảnh, không ký tự số chờ, không chỉ báo về người kia |
| AC2 widget đổi nội dung theo pha, pha 4 phản chiếu "Trước giờ đi" | **PASS về hành vi** | Bốn ảnh thiết bị thật chứng minh nhánh chọn hình + màu chạy đúng cho `waiting`/`upcoming`/`date_day`/`quiet`. Phần **thị giác** của nó rơi vào AC9 |
| AC3 đếm ngược tới ngày hẹn trên thẻ *Đã hẹn ngày* | **PASS** | D-4 đóng (`_CountdownBlock`), ô 2 lật PASS ở lượt patch #2 |
| AC4 nhắc 23h → cất ảnh / viết một câu, bỏ qua thì không nhắc lại | **PASS** | P6 + P10; blocker chéo REQ-002/STORY-021 đã được user quyết 2026-09-17. Lưu ý D-C (S7) vẫn treo: nhắc chỉ tồn tại nếu app được mở trong chính ngày hẹn — không chặn, cần PO xác nhận cách đọc AC4 |
| AC5 bộ đếm "của cải đang lớn" | **PASS** | Ô 6 `quiet-surfaces` PASS |
| AC6 không streak / chuỗi ngày / bảng xếp hạng | **PASS** | Ô 1 và ô 6 đã soi toàn ảnh, không chữ số chuỗi nào |
| AC7 tắt thông báo thì app vẫn dùng được bình thường | **PASS** | `notification_settings_screen_test.dart` (+219), `EveningCheckInScheduler.setEnabled(false)`. Kèm D-H (S7, LOW): `cancelAll()` sẽ thành lỗi chéo khi có producer thứ hai |
| AC8 không nội dung trách móc / đếm ngày vắng | **PASS** | Cổng bất biến nội dung + `native_copy_scan_test.dart` 38/38 |
| **AC9 bảy design screen khớp canvas `cupid-ch-ng-1`, không lệch thấy được** | **FAIL** | `VISUAL_FIDELITY: FAIL`. Ô 1 `hub-waiting` FAIL (B-1); ô 7 `widget-phases` FAIL (B-2..B-6). Ô 2–6 PASS |

## Khuyến nghị trạng thái

- Bỏ tick `Implementation (Development)` trong `story_master.md`.
- Để trống `Review (Reviewer)`.
- Story status: `IN_PROGRESS`.
- Định tuyến: **Product Owner trước** (B-1 cần chuỗi trong
  `phase_content.v1.json`), **Tech Lead + UI/UX** cho B-2/B-3/B-4/B-6 (ba
  khoản đòi quyết định thiết kế hoặc mở hợp đồng token trước khi có mã), rồi
  **mobile-dev một lượt** dựng B-1..B-5 và chụp lại ô 1 + ô 7.
- Mở WriteScope cho `CupidPhaseWidgetProvider.kt`,
  `cupid_phase_widget.xml`, một drawable gradient mới, `phase_content.v1.json`,
  `activity_card_tile.dart`, và `architecture/contract-summary.md` §3a nếu B-6
  đổi vai trò token.
- Golden test bốn pha: vẫn **chưa** đặt. Đúng thứ tự — `--update-goldens` chỉ
  chạy sau khi đối chiếu thị giác đạt, nếu không sẽ đóng băng vĩnh viễn đúng
  những lệch đang phải sửa.
- N-2 tách sang DevOps, độc lập với story này.

## Đếm finding

- Chặn: **6** (B-1..B-6)
- Không chặn ghi ở lượt này: **6** (N-1..N-6)
- Kế thừa từ S7, vẫn mở, không chặn: **13** (R-2 + D-A..D-N trừ D-E đã đóng)
- Đã đóng ở lượt này: C-2, C-3, D-E, R-4, R-5, D-10, D-13(1), và hồi quy
  `ANDROID_RESOURCE_PARSE_FAILED`
