# Review Report: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

Outcome: PATCH_REQUIRED

Lượt S10 · `full-story-review` · tái review sau `PATCH_REQUIRED` của S9
Scope gate: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`)
Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
Mốc diff dùng thật: `802b3fa6..HEAD` (`6ee190eb`) — lượt sửa đúng hai commit
`6496c4f5` + `6ee190eb`: **1 tệp source**, 3 tệp artefact, 12 đường ảnh.

## Lý do outcome, trong một đoạn

Phần thực chất của lượt sửa đạt, và tôi kiểm bằng phép đo của chính mình chứ
không đọc lại lời khai: B-1a kiểm bằng diff + **mở ảnh chụp lại ra soi** — đóng.
N-7 đóng, và đóng theo cách đáng ghi nhận — mục ghi bù tự khai mình là dựng lại
từ hiện vật, không giả vờ là một lượt đo mới. Chất lượng hình khối của ô 1 nay
khớp canvas.

Nhưng B-7 chỉ **đóng một nửa**, và nửa còn lại là một khoản chặn mới: **B-8**.
Lượt sửa đã lật được nửa *ghép cặp ảnh* của cổng (tôi tự dựng đối chứng tên
cũ/tên mới và xác nhận), nhưng nửa *giải id màn* thì đỏ — và nửa này chưa từng
bị đụng tới ở S9 nên không ai thấy. Dòng `Design-Screen:` của
`story_master.md:17-24`, do chính commit `802b3fa6` của lượt sửa viết ra, đã
biến một trường máy đọc thành văn xuôi: ngoặc `(alias: …)`, một câu tiếng Việt,
và một tham chiếu markdown nằm ngay trong giá trị. Cổng
`verify-story-visual-fidelity-gate.sh` cắt theo dấu phẩy nên nhận id đầu tiên là
`ngan-da-hen-ngay-dang-doi (alias: hub-waiting, hub-upcoming)` — một chuỗi không
nguồn design nào có, và nó **chặn story ở cổng DONE**.

Sửa là một dòng, nhưng ở `story_master.md` — ngoài WriteScope của tôi (`review`)
và bị reviewer SKILL rule 7 cấm. Nên tôi không tự sửa: `PATCH_REQUIRED`, một
khoản chặn, chủ là Scrum Master. Tập hoãn kế thừa vẫn còn nguyên (N-1..N-6, N-8,
N-9, N-2 của DevOps, R-2/D-\* của S7) và lượt này thêm **N-10**, **N-11**.

## Ba khoản của S9 — kiểm chứng độc lập

### B-1a · Chip hành động phụ — **ĐÓNG**

Diff `phase_status_line.dart` (+42/−24): `_PhaseStatusAction` bỏ `Padding(left:
md)` + `Text` trần, thay bằng `DecoratedBox(color: colors.colorSurface,
borderRadius: BorderRadius.circular(platform.radiusButton), border:
Border.all(color: colors.colorLine))` bọc `Padding(horizontal: md, vertical:
sm)`, caption `w700`, chữ `colors.colorText`. `Center(widthFactor: 1)` giữ chip
ôm sát nhãn; `ConstrainedBox(minHeight: platform.tapTarget)` và
`phaseStatusLineActionKey` giữ nguyên, nên vùng chạm và đích chạm không đổi.

**Soi ảnh, không nhận trên lời khai** (rule 12e3). Mở
`implemented-ngan-da-hen-ngay-dang-doi-waiting.png` cạnh
`design-reference-ngan-da-hen-ngay-dang-doi-ios.png`: chip `Chọn trước một chỗ`
nay là **viên thuốc bo tròn có nền tối và viền mảnh**, nằm sát mép trái trong
khối `Chuẩn bị dần cho buổi tới` — cùng một cách đọc với chip `Chọn quán dự
phòng` của canvas: nền `--surf` đặt trên nền khối `--surf2`, viền hairline, chữ
gần trắng đậm. Đây chính là thứ S9 nói không có. Dấu tiếng Việt đủ, không tofu.

Ba lệch cố ý mà S9 đã phân xử **vẫn giữ nguyên hướng**, không bị "sửa nhầm":
một chip chứ không hai (AC-6/AC-7), nhãn từ gói nội dung (D-8), chạm mở màn chi
tiết A4 (AC-4).

Hai điều chỉnh kèm theo đều có căn cứ viết tại chỗ và tôi chấp nhận: bỏ thụt lề
`md` (thuộc cách đọc text-button mà vá B-1 đã thay), và `colorAccentPink` →
`colorText` (canvas dùng `--tx`; hồng ở cỡ caption dưới ngưỡng AA theo ADR-004b).
Chip vẫn đứng dưới CTA `Hẹn ngày` một bậc — D-2 không bị phá.

### B-7 · Cổng thị giác — **ĐÓNG NỬA GHÉP CẶP, ĐỎ NỬA GIẢI ID (→ B-8)**

Tôi tự chạy hai lượt, không đọc bảng của lane mobile:

```
python3 .claude/hooks/lib/visual_fidelity.py --dir <story dir> --stage review --stack mobile
→ exit 0, không in gì

cp -R visual-fidelity/ /tmp/vfctl-s10/ ; phục hồi đúng 10 tên cũ ; chạy lại
→ exit 1, "no screen has BOTH renders … running-app renders exist for
   ['evening','hub','quiet','widget'] and design renders for
   ['23h','j12','man','ngan']"
```

Đối chứng của tôi trùng từng chữ với thông điệp tôi gặp ở S9, và hai lượt chỉ
khác nhau ở tên file. Nên cổng **không** xanh một cách rỗng: chính việc đổi tên
là thứ lật nó. Tôi không dùng `verify-story-visual-fidelity-gate.sh` — gọi tay
nó trả exit 0 im lặng bất kể bằng chứng ra sao.

Đổi tên khớp bảng §8b của `architecture/solution.md` từng dòng. `git diff -M
--name-status` báo **9 rename R100** (byte y hệt) + 1 xoá/1 thêm cho ô 1 được
chụp lại. Không tệp `design-reference-*` nào bị đổi tên hay nhân bản, không
tệp cổng nào bị sửa — đúng ràng buộc Tech Lead đặt. Bảng "Đặt cặp ảnh" ở đầu
báo cáo thị giác đã cập nhật, và các mục lịch sử "Lượt patch #1..#4" được ghi
chú rõ là giữ tên tại thời điểm chạy, không phải đường dẫn còn sống — đúng cách
xử lý biên bản cũ.

**Nửa còn lại của cổng thì đỏ.** `visual_fidelity.py` chỉ trả lời câu hỏi "mỗi
màn có đủ hai phía ảnh và ghép được cặp không". Cổng đầy đủ còn hỏi thêm một câu
thứ hai: "những id màn story khai có thật trên bề mặt design không". Câu thứ hai
đỏ — chi tiết ở **B-8** dưới đây. Ở S9 câu này chưa từng được chạy (S8 chấm AC9
`FAIL`, S9 chấm `PATCH_REQUIRED`, nên cổng chỉ kích hoạt khi outcome đạt), vì
vậy đây không phải hồi quy do lượt sửa làm hỏng một thứ đang xanh — nó là một
nửa cổng lần đầu được soi tới.

### B-8 · `Design-Screen:` không giải được id — **MỞ, CHẶN** (mới)

Đây là khoản chặn duy nhất của lượt này. Cổng stop
`verify-story-visual-fidelity-gate.sh` trả `BLOCKED [GENERIC]` với nguyên văn:
id `ngan-da-hen-ngay-dang-doi (alias: hub-waiting, hub-upcoming)` "which this
design source `cupid-ch-ng-1` does not have — an invented or stale id means the
comparison targeted nothing real".

Nguyên nhân là dạng của trường, không phải id. `story_master.md:17-24` hiện là:

```
Design-Screen: ngan-da-hen-ngay-dang-doi (alias: hub-waiting, hub-upcoming),
  man-goc-muon-lam (alias: hub-date_day, hub-quiet),
  … Id canvas là id màn chuẩn duy nhất (Design Ruling Log hàng B-7,
  `req_master.md`); nhãn bản dựng ở trên chỉ là alias mô tả trạng thái, xem
  `architecture/solution.md` §8.
```

`Design-Screen:` là trường **máy đọc**, cắt theo dấu phẩy. Ba thứ vừa được nhồi
vào trong giá trị đều làm nó không giải được: ngoặc `(alias: …)` — mà bản thân
nó lại chứa dấu phẩy nên còn tự cắt mình thành nhiều mảnh giả, một câu tiếng
Việt, và một tham chiếu markdown. Mảnh đầu tiên vì thế thành
`ngan-da-hen-ngay-dang-doi (alias: hub-waiting, hub-upcoming)`.

`git log -L 16,24` chỉ rõ dạng này do commit `802b3fa6`
("Tech Lead B-7 naming-convention ruling + Design-Screen id fix") của **chính
lượt sửa này** đưa vào; trước đó trường là danh sách nhãn bản dựng trần
(`hub-waiting, hub-upcoming, …`) — cũng không phải id canvas, tức trường này
chưa bao giờ giải được, chỉ là chưa bao giờ bị hỏi.

Nội dung ngữ nghĩa mà lượt sửa muốn diễn đạt **là đúng** theo phân xử §8 (id
canvas là id chuẩn duy nhất, nhãn bản dựng chỉ là alias). Lỗi chỉ là đặt phần
diễn giải vào trong một trường máy đọc. Bản đồ alias đã có nguyên vẹn ở
`architecture/solution.md` §8/§8b và Design Ruling Log hàng B-7 của
`req_master.md`, nên rút nó khỏi trường **không mất thông tin nào**.

**Sửa đề nghị** (một dòng, chủ: Scrum Master — `story_master.md` ngoài WriteScope
`review` của tôi và bị reviewer SKILL rule 7 cấm reviewer sửa):

```
Design-Screen: ngan-da-hen-ngay-dang-doi, man-goc-muon-lam, 23h-vua-ve-j8,
  j12-nhan-ra-cot-moc, sb-84-widget-bon-pha
```

rồi để câu diễn giải alias thành một dòng văn xuôi **riêng, ngoài trường**.

**Giới hạn của kiểm chứng này, nói thẳng:** tôi **không** xác nhận được cả năm
id bare đều hợp lệ. Tập id hợp lệ do `.claude/hooks/**` tính ra (tôi bị cấm đọc);
cả hai entrypoint `.sh` (`verify-story-visual-fidelity-gate.sh`,
`validate-dev-design-render.sh`) đều trả exit 0 im lặng khi tôi gọi tay nên không
liệt kê được; và các id là slug không xuất hiện nguyên văn trong
`cupid-app-design-system/Cupid Chặng 1.dc.html` (tôi đã thử cả năm, đều 0 khớp).
Danh sách hợp lệ mà cổng tự in ra thì **bị cắt** ở `chi-tiet-th…` theo thứ tự
chữ cái, nên nó chỉ chứng thực `23h-vua-ve-j8`; bốn id còn lại bắt đầu bằng
j/m/n/s, tức nằm sau chỗ cắt. Cổng cũng chỉ báo id sai **đầu tiên**. Vậy lượt vá
phải **chạy lại cổng** sau khi sửa dòng, và nếu còn id bị từ chối thì đối chiếu
với danh sách hợp lệ cổng in ra. Tôi khẳng định chắc chắn một điều: dạng hiện tại
sai và chặn; tôi **không** khẳng định rằng chỉ cần bỏ ngoặc là cổng sẽ xanh.

### N-7 · Mục "Lượt patch #4" — **ĐÓNG**

`coding-plan/test-results.md` +134 dòng, có `## Lượt patch #4` với sáu khoản
B-1..B-6, diff thật của `a8aa1ff4`, và bằng chứng test. Đáng ghi nhận: mục này
**tự khai nguồn** — "dựng lại từ ba hiện vật đã tồn tại, không phải từ một lượt
chạy lại", và nói rõ không con số nào do lượt #5 đo. Đó là cách đúng để ghi bù
một khoảng hở tài liệu mà không chế ra bằng chứng. Con số S9 nêu sai (`+226`)
cũng được sửa thành `+225/−2` theo `--numstat`; tôi xác nhận phép sửa này đúng.

## Không hồi quy — kiểm bằng phép đo, không bằng suy luận

| Khoản | Cách kiểm | Kết |
|---|---|---|
| B-2..B-6 | `git diff --name-only 802b3fa6..HEAD`: **không** tệp native Android/iOS nào bị chạm; 4 ảnh widget là rename R100 byte y hệt | không thể hồi quy |
| AC1–AC8 | delta chỉ chạm `phase_status_line.dart` (hình khối); suite của chính nó xanh gồm AC-5, AC-6/AC-7, AC-14, AC-15, AC-37/BR-15 | giữ `PASS` của S8 |
| Chiều cao khối tăng (`SizedBox(height: sm)` mới + đệm chip) | đây là rủi ro hồi quy thật của thay đổi này — một hàng mới có thể đẩy widget khác ra ngoài khung 800×600 và làm `tap()` của test khác trượt. Tôi chạy suite liền kề: `flutter test test/features/activity_cards` → **+213 ~2, 0 đỏ** | không hồi quy |

## Cổng bằng chứng

| Cổng | Kết | Bằng chứng |
|---|---|---|
| **Design fidelity (12e2/12e3)** | **PASS** | Bảy ô. Ô 1 chụp lại và tôi tự soi; ô 2–7 là rename byte-y-hệt của ảnh S9 đã soi. `VISUAL_FIDELITY: PASS` ở `visual-fidelity-report.md:3`, kèm bảng thuộc-tính-theo-thuộc-tính, không phải token trần |
| **Script ghép cặp `visual_fidelity.py`** | **PASS (exit 0)** | Tự chạy + đối chứng tên cũ exit 1 — xem B-7 |
| **Cổng stop `verify-story-visual-fidelity-gate.sh`** | **FAIL (BLOCKED [GENERIC])** | **B-8**. Cổng từ chối `Design-Screen:` của `story_master.md:17-24`: mảnh id đầu tiên thành `ngan-da-hen-ngay-dang-doi (alias: hub-waiting, hub-upcoming)`, không nguồn design nào có. Tôi tự gặp nguyên văn thông điệp này ở cổng stop của chính lượt review |
| Design-Screen đã giải, đúng màn | **FAIL** | **Sửa lại khẳng định tôi đã viết ở bản nháp đầu của báo cáo này.** Tôi đã ghi dòng này `PASS` vì thấy `visual-fidelity-report.md:29-30` và trường đều mang id canvas đúng — đó là đọc **ngữ nghĩa**. Máy đọc trường thì không giải được vì ngoặc alias nằm trong giá trị: xem **B-8**. Reference tôi mở bằng mắt vẫn đúng là màn của story, nhưng việc đó **không** thay được truy vết máy kiểm được |
| Test widget (hồi quy có mục tiêu) | **PASS** | Tôi tự chạy `flutter test test/features/phase_status/phase_status_line_test.dart` → **+17 ~4**, trùng đúng con số lane mobile khai |
| Suite liền kề | **PASS** | `test/features/activity_cards` → +213 ~2 |
| Static analysis mobile | **PASS** | Tôi tự chạy `flutter analyze lib/features/phase_status` → 6 issue, **toàn bộ mức `info`, 0 error / 0 warning**, và cả 6 nằm ở `phase_content.dart`/`phase_status_cubit.dart` — hai tệp lượt này **không** chạm. `phase_status_line.dart` sạch. Khai "0 error/0 warning" của lane mobile đúng |
| Entry point reachability (12e1) | **PASS** | Kế thừa S8. Delta không chạm điều hướng; chip dùng lại `_openDetail` đã chứng minh |
| Runtime startup smoke (12g) | **PASS** | Kế thừa lượt patch #4 (cài + chạy APK thật, `adb logcat -d` sạch). Delta là một widget Dart, không chạm khởi động |
| Build native Android | **PASS** | Kế thừa lượt patch #4. Delta không thêm tài nguyên native nào |
| Hợp đồng `action_label` + cổng bất biến AC-39 | **PASS** | Kế thừa S9 (đã `PASS` phần dữ liệu). Delta không chạm `phase_content.dart` hay gói nội dung |
| Configuration guide (12a) | **PASS** | Delta không thêm bước cài đặt hay biến môi trường |
| Vệ sinh cây làm việc | **PASS (sau khi tôi tự dọn)** | Không ảnh nào của STORY-012 bị ghi đè. Nhưng lượt `test/features/activity_cards` **của tôi** đã làm bẩn 2 PNG của STORY-002 (`implemented-11-chuan-bi-chon-hanh-dong-ios.png`, `implemented-chi-tiet-the-da-hen-ngay-ios-cho-hen.png`) — suite đó ghi ảnh ngay cả khi không bật `CAPTURE_VISUALS`. Tôi đã `git checkout --` phục hồi cả hai; `git status` cuối cùng chỉ còn hai tệp `review/` của chính lượt này. Ghi lại vì đây là bẫy có thật cho lượt sau — xem **N-11** |
| Playwright / e2e trình duyệt | `NOT_APPLICABLE` | lane `mobile` |

## AC-by-AC (chỉ ghi phần S10 đổi)

| AC | Kết | Căn cứ |
|---|---|---|
| AC1–AC8 | **PASS** | Không đổi so với S8. Delta không chạm hành vi nào |
| **AC9** bảy design screen khớp canvas `cupid-ch-ng-1` | **PASS phần hình, CHƯA CHỨNG NHẬN** | Phần nội dung đạt: ô 1 `hub-waiting` lật `FAIL` → `PASS` (hình khối chip đã đúng canvas, tôi tự soi ảnh), ô 2–7 giữ `PASS` của S9 (ảnh byte y hệt), cả bảy ô đủ hai phía và ghép cặp được. Nhưng AC9 nói "khớp canvas `cupid-ch-ng-1`", và trường khai story trỏ vào canvas nào thì máy không giải được (**B-8**). Nên tôi **không** chứng nhận AC9 ở lượt này: mắt tôi thấy khớp, còn truy vết tự động thì chưa tồn tại. Chứng nhận AC9 treo đến khi B-8 được vá và cổng chạy lại xanh |

## Finding không chặn

| Id | Mức | Nội dung |
|---|---|---|
| **N-10** (mới) | MEDIUM (bằng chứng, có hẹn giờ) | Hai harness chụp sinh tên file **bằng mã**: `mobile/test/features/phase_status/phase_status_line_test.dart:627` nối `'implemented-hub-${phase.wireValue}.png'`, và harness widget của P12 ghi `implemented-widget-<pha>.png`. Lượt #5 chụp dưới tên cũ rồi `git mv`, vì `mobile/test/**` ngoài WriteScope. Hệ quả: lần kế bật `CAPTURE_VISUALS=true` sẽ sinh lại **tên cũ bên cạnh** tên mới và cổng đỏ trở lại. Không chặn story này theo định tuyến của Scrum Master, nhưng **là một quả mìn hẹn giờ**: nó nổ ở lượt chụp kế tiếp của bất kỳ ai, không phải ở lượt này. Cần một lượt nhỏ với WriteScope `mobile/test/**`. Lane mobile **đúng** khi không tự mở scope và khi tự khai khoản này thay vì để nó chìm |
| **N-11** (mới) | LOW (vệ sinh test) | Chạy `flutter test test/features/activity_cards` **ghi đè 2 PNG visual-fidelity của STORY-002** mà không cần bật `CAPTURE_VISUALS` — tức suite đó có harness chụp chạy vô điều kiện. Không ảnh hưởng AC nào của STORY-012 và tôi đã phục hồi bằng `git checkout --`, nhưng bất kỳ ai chạy suite này rồi `git add -A` sẽ commit đè bằng chứng của một story đã DONE mà không nhận ra. Cùng họ vấn đề với N-10 và nên gộp vào cùng lượt dọn harness chụp. Chủ: mobile-dev qua định tuyến Scrum Master |
| **N-6** | INFO | **Vẫn mở, xác nhận lại bằng mắt ở ảnh mới**: `implemented-ngan-da-hen-ngay-dang-doi-waiting.png` còn dải DEBUG đỏ góc trên phải. Harness nên đặt `debugShowCheckedModeBanner: false` |
| **N-1** | MEDIUM | Vẫn mở. Ô bảng "Nhãn-mí" của ô 7 nên ghi "lệch có chủ đích, xem D-13(1)" thay vì "KHỚP" |
| **N-2** | MEDIUM (ops) | Vẫn mở. `mobile-app.buildCommand` thiếu `--flavor local`. Ngoài WriteScope story. Chủ: DevOps |
| **N-3** | MEDIUM (hợp đồng) | Vẫn mở. `home_widget` 0.9.4 ghi vào `HomeWidgetPreferences`, không như `contract-summary.md` §1 mô tả. Chủ: Tech Lead |
| **N-4**, **N-5** | LOW | Vẫn mở, không đổi |
| **N-8** | LOW (thị giác) | Vẫn mở. Khoảng trắng sau cụm số phóng to ở `implemented-sb-84-widget-bon-pha-upcoming.png` gần như bị nuốt |
| **N-9** | LOW (thị giác) | Vẫn mở. Nền gradient đậm hơn thẻ canvas; quyết định ở tầng token, không phải việc STORY-012 |

**Còn hiệu lực từ S7/S8, lượt này không chạm:** R-2 và D-A, D-B, D-C, D-D, D-F,
D-G, D-H, D-I, D-J, D-K, D-L, D-N. Giữ nguyên phân loại và chủ sở hữu.

## Ghi nhận về chất lượng lượt sửa

Ba điểm đáng giữ lại vì chúng nên lặp lại:

1. **Bằng chứng đối chứng thay vì một lần xanh.** Lane mobile tự dựng bản copy
   tên cũ để chứng minh cổng thật sự phân biệt được — thay vì nộp một exit 0 và
   để người review tự đoán nó có rỗng hay không. Tôi dựng lại độc lập và ra
   cùng kết quả. Đây là cách duy nhất đúng để chứng minh một cổng im lặng.
2. **Tự khai nguồn của mục ghi bù.** Mục "Lượt patch #4" nói thẳng nó dựng lại
   từ hiện vật cũ, không phải đo mới. Một mục ghi bù giả vờ là bằng chứng tươi
   nguy hiểm hơn hẳn một khoảng hở tài liệu.
3. **Tự khai N-10 thay vì im lặng.** Khoản hằng-tên trong harness nằm ngoài
   WriteScope, không ai phát hiện ra ở lượt này, và nó chỉ nổ ở lượt chụp sau.
   Lane mobile ghi nó ra và định tuyến lên — thay vì lặng lẽ mở scope hoặc để
   nó trôi.

## Khuyến nghị trạng thái

- Giữ tick `Implementation (Development)` (`[x]` hiện tại là đúng). Phần mã của
  lượt sửa đạt; B-8 là khoản artefact, không phải khoản mã.
- **Chưa** tick `Review (Reviewer)`.
- Story status: **`PATCH_REQUIRED`**. Chưa đủ điều kiện gộp vào
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`.
- **B-8 là việc của Scrum Master, một dòng.** Sửa `Design-Screen:` ở
  `story_master.md:17-24` thành danh sách id canvas trần (xem dạng đề nghị ở mục
  B-8), đưa câu diễn giải alias ra ngoài trường, rồi **chạy lại cổng**. Tôi
  không tự sửa: tệp nằm ngoài WriteScope `review` của tôi và reviewer SKILL
  rule 7 cấm reviewer sửa `story_master.md`. Đây là lượt vá artefact thuần, không
  cần mở lại lane mobile và không cần chụp lại ảnh nào.
- Sau khi cổng xanh, khoản chặn duy nhất hết hiệu lực và lượt review kế tiếp có
  thể là một lượt **cực hẹp**: chỉ xác nhận dòng `Design-Screen:` và kết quả
  cổng. Mọi kết luận thực chất khác của S10 (B-1a, N-7, không hồi quy, các cổng
  test/analyze/smoke) giữ nguyên hiệu lực, không cần dựng lại.
- **N-10 phải được xếp hàng, không được đóng theo story.** Đề nghị Scrum Master
  mở một lượt độc lập WriteScope `mobile/test/**` sửa hằng tên trong hai harness
  chụp. Nếu nó không được xếp hàng, lượt bật `CAPTURE_VISUALS` kế tiếp của bất
  kỳ story nào sẽ làm đỏ lại cổng fidelity của STORY-012 **sau khi** story đã
  DONE — và lúc đó không ai còn nhớ vì sao.
- Gộp **N-11** vào chính lượt đó: suite `test/features/activity_cards` ghi đè
  PNG của STORY-002 mà không cần cờ `CAPTURE_VISUALS`. Cùng một họ vấn đề —
  harness chụp không được rào bằng cờ và không được đặt tên bằng hằng.
- N-2 tách sang DevOps. N-1/N-3 giữ chủ sở hữu cũ.
- Golden test bốn pha: nay đã đủ điều kiện đặt (ô 1 đạt), nếu vẫn muốn.

## Đếm finding

- Chặn: **1** (B-8 — `Design-Screen:` không giải được id, chủ: Scrum Master)
- Đóng ở lượt này: **2** (B-1a, N-7)
- Đóng một nửa: **1** (B-7 — nửa ghép cặp đóng, nửa giải id chuyển thành B-8)
- Không chặn mới: **2** (N-10, N-11)
- Không chặn kế thừa, vẫn mở: **8** (N-1..N-6, N-8, N-9) + 13 khoản R-2/D-\*
