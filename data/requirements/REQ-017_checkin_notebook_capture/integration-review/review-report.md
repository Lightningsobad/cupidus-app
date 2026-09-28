# Requirement Integration Review: REQ-017_checkin_notebook_capture

Review type: `requirement-integration-review` (pass 2 — `completion/resume` hẹp trên F-I1 + F-I2)
Outcome: DEFERRED_ONLY

Scope gate: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-017_checkin_notebook_capture/data/requirements/REQ-017_checkin_notebook_capture/integration-review/scope-gate.md`
Branch: `codex/REQ-017_checkin_notebook_capture-integration` @ `646ec1efc51f6cd8c19892c7a6e6052b34029b71`
BaseHead: `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1`
Reviewed: 2026-09-28 (pass 1 `PATCH_REQUIRED` @ `a15bde4f`; pass 2 re-verify @ `646ec1ef`)

## Outcome và lý do

Pass 1 chốt `PATCH_REQUIRED` vì thiếu đúng hai gate cấp đóng-requirement. Cả hai nay đã có bằng
chứng thật, đã kiểm lại trực tiếp, và **đều đóng**:

- **F-I1 — ĐÓNG.** `integration-review/build-runtime-evidence.md` (commit `cdbbb1f0`) có mục
  `## Integration Build & Runtime` với build thật và smoke khởi chạy thật, **cài đè lên dữ liệu v10
  có sẵn** đúng như pass 1 yêu cầu.
- **F-I2 — ĐÓNG.** `integration-review/mobile-visual-audit.md` + `mobile-screenshots/` (commit
  `646ec1ef`) là audit cross-screen thật trên thiết bị, 8 khung hình chụp từ app đang chạy.

Không phát sinh finding chặn nào. Phần code tầng integration đã sạch từ pass 1 và không đổi kể từ đó.
Các hạng mục còn lại đều là deferred/informational, nên `DEFERRED_ONLY` (không phải `CLEAN`: có ghi
chú cần giữ lại, trong đó **D-I3 nên xử lý trước khi chạy DONE gate**).

## Re-verification — F-I1 (rule 12g3)

Đọc `build-runtime-evidence.md` trực tiếp, không tin verdict token:

| Điểm kiểm | Kết quả |
|---|---|
| Mục `## Integration Build & Runtime` tồn tại | **PASS** — `build-runtime-evidence.md:13` |
| Verdict build + verdict runtime trong **cùng một file** | **PASS** — :15, :30 (build), :36 (runtime/smoke) |
| `- Runtime/Smoke: PASS — …` đúng dạng literal | **PASS** — :36, verdict là từ đầu tiên sau dấu hai chấm |
| `Runtime: NOT_APPLICABLE` có bị dùng thay pass không | **KHÔNG** — :82-85 nói rõ có thiết bị thật (`emulator-5554`) và đã chạy tiến trình thật |
| Build thật trên nhánh integration | **PASS** — `flutter build apk --debug --split-per-abi` ở cả `0198e32d` (v10, scratch worktree riêng) và `c41c1556` (v11, worktree được giao); ba APK split-ABI mỗi lần; chỉ warning Gradle/KGP tiền tồn |
| Smoke là **cài đè giữ data**, không phải cài sạch | **PASS** — :41-44 `adb install -r`, không `uninstall`, không `--uninstall-only`; :89-92 nói rõ vì sao cài sạch sẽ che mất đúng rủi ro |
| Migration 10 → 11 **thực sự chạy** | **PASS** — :117-124 `PRAGMA user_version` = `10` trước; :145-152 = **`11`** sau. Đây là bằng chứng migration chạy, không phải "không thấy lỗi trong log" |
| Dữ liệu sống sót qua migration | **PASS** — `journal_entries` 1 dòng và `notebook_entries` 1 dòng khớp đúng số trước/sau |
| Dữ liệu v10 là do app tự ghi, không phải sqlite chế tay | **PASS** — :94-116 seed session qua `POST /auth/register` + OTP từ mailpit, rồi tạo mục bằng thao tác UI thật; :118-119 trích DB ra từ `app_flutter/cupid.sqlite` |
| Quét crash | **PASS** — :61-78, 37 dòng `*:E` được phân loại hết (ashmem, `flutter_facebook_auth` chưa cấu hình, `HwcComposer` của emulator); zero `FATAL EXCEPTION`/`AndroidRuntime`, zero dòng nhắc `drift`/`onUpgrade`/`schema` |
| Tắt sạch | **PASS** — :79-80 `am force-stop` theo `shutdownCommand` của registry |
| Bằng chứng còn áp cho HEAD hiện tại không | **PASS** — build chạy ở `c41c1556`; `git diff --name-only c41c1556..646ec1ef -- mobile` **rỗng** (tôi tự chạy lại): không byte nào dưới `mobile/` đổi kể từ lần build đó, hai commit sau chỉ thêm file `data/` |

Ghi chú về `Status: timeout` của `am start -W` (:45-56): không phải launch fail, và lời giải thích
kiểm được — vòng poll `dumpsys activity activities` khớp `ResumedActivity` ngay lần poll đầu (~2s),
cộng hai ảnh màn (spinner → home đã render). Một app crash lúc migration sẽ không bao giờ đạt
`ResumedActivity` rồi render home. Diễn giải này nhất quán với chứng cứ, không phải bào chữa.

## Re-verification — F-I2 (rule 12g2)

Theo rule 12e3, tôi **không chụp lại** (device lifecycle không thuộc Reviewer) nhưng **phải mở ảnh ra
nhìn**, vì đếm file là việc của stop gate chứ không phải review. Tôi mở 4/8 khung, gồm cả hai màn đã
đổi:

| Khung đã mở | Thấy gì | Có mâu thuẫn verdict không |
|---|---|---|
| `23h-vua-ve-j8-capture-block-empty.png` | Màn check-in thật (app thật, cờ DEBUG). Khối hỏi "Hôm nay biết thêm gì về người ấy?" + "Tuỳ chọn" nằm **sau** thẻ ảnh và **sau** khối "Một câu để giữ tối nay". Ô nhập rỗng, không điền sẵn. Hai chip mô tả STORY-012 ("+ ghi vào sổ tay", "chỉ mình đọc") còn nguyên | Không — khớp AC-1, AC-2, AC-6, AC-7 |
| `23h-vua-ve-j8-capture-block-filled.png` | Đã gõ chữ; đúng **hai** chip "Sở thích"/"Sự kiện", một chip đang chọn. Không loại thứ ba, không trường chấm điểm, không câu hỏi thứ hai | Không — khớp AC-3, AC-17 |
| `2-so-tay-nguoi-yeu-origin-label-grouped.png` | Màn "Sổ tay người yêu". Mục từ check-in nằm trong nhóm "Sở thích" kèm dòng phụ "từ buổi hẹn Ca phe sach Ho Tay"; **ngay dưới** là mục thủ công `smoke_test_entry` **không có nhãn**. Chỉ hai nhóm, không nhóm thứ ba. Cả hai mục đều có "..." | Không — khớp AC-4, AC-9, BR-11, và chứng minh nhãn là thuộc tính **cộng thêm** |
| `shell-nav-hub-bottom-nav-no-new-route.png` | Hub thật, bottom nav đúng 4 đích "Muốn làm / Ý tưởng / Sổ tay / Nhật ký", không tab/tile/route mới cho REQ-017 | Không — khớp khai báo "không thêm điểm vào nào" |

Không khung nào là màn lỗi, spinner, placeholder, hay nhầm màn. Chữ sản phẩm hiển thị đủ dấu tiếng
Việt ở mọi khung tôi mở ("Sở thích", "Sự kiện", "từ buổi hẹn", "Tuỳ chọn", "Nhật ký") — không ô tofu.
Điều này khớp với `L-1` mà audit tự khai: chỉ **dữ liệu người kiểm tự gõ** là ASCII không dấu
(`Ca phe sach Ho Tay`), do `adb shell input text` ném NPE với dấu tiếng Việt; chữ của sản phẩm nạp từ
content pack nên không bị ảnh hưởng. Khai báo này đúng với những gì nhìn thấy.

Hai điểm khác đã kiểm:
- Audit chụp ở `cdbbb1f0`, HEAD hiện tại là `646ec1ef`; chênh lệch giữa hai commit chỉ là chính các
  file audit (`git diff --name-status` tôi tự chạy). Bản dựng đang chạy trên máy là source-identical
  với HEAD được audit.
- Tên file cố ý tránh tiền tố `implemented-` / `design-reference-` (:166-170) nên gate ghép đôi
  visual-fidelity cấp story không nhận nhầm các khung cross-screen này thành bằng chứng fidelity của
  story. Đây là quyết định đúng, không phải né gate.

## Integration gates (giữ nguyên từ pass 1, đã tái xác nhận)

| # | Gate | Kết quả |
|---|---|---|
| 1 | merge nhập trọn vẹn | **PASS** — `git diff dd46d89d..HEAD` rỗng tại merge; cây merge trùng khít cây story tip |
| 2 | không divergence với `main` trên file cùng chạm | **PASS** — `zodiac_shell_resolver.dart` (giao điểm BUG-20260927-001/BR-16) giống hệt bản vá của `main` |
| 3 | schema/migration cộng thêm, tuần tự | **PASS** — `cupid_database.dart:86` `schemaVersion => 11` (bản `main` là `10`); bước nâng ở `:153`. Nay có thêm bằng chứng **chạy thật** từ F-I1 |
| 4 | asset/pack mới phân giải được lúc chạy | **PASS** — `pubspec.yaml` thêm đúng một dòng `assets/data/req017/`; `checkin_capture_content.dart:9` khớp |
| 5 | luồng end-to-end còn nguyên sau merge | **PASS** — đọc code ở pass 1 (`evening_check_in_sheet.dart:369-380`, `:753`; `context_notebook_entry_point.dart:85-90`); nay có thêm xác nhận **bằng ảnh** ở F-I2 |
| 6 | configuration guide (rule 12a) | **NOT_REQUIRED — đúng** |
| 7 | `## Integration Build & Runtime` (rule 12g3) | **PASS — F-I1 đóng** |
| 8 | `mobile-visual-audit.md` cấp requirement (rule 12g2) | **PASS — F-I2 đóng** |
| 9 | visual fidelity per story (12e2/12e3) | **PASS — không mở lại** |

## Blocking findings

Không có.

## Deferred findings

### D-I3 — nhãn dòng `- Build:` lệch dạng literal mà rule 12g3 trích (nên xử lý TRƯỚC khi chạy DONE gate)

Rule 12g3 trích nguyên văn hai dòng bắt buộc: `- Build: PASS — <command + result>` và
`- Runtime/Smoke: PASS — <startup smoke command + result>`. Trong `build-runtime-evidence.md`:

- dòng runtime đúng literal: `- Runtime/Smoke: PASS — …` (:36)
- hai dòng build lại chèn ngoặc **trước** dấu hai chấm:
  `- Build (pre-migration baseline, schemaVersion 10): PASS —` (:15) và
  `- Build (this Worktree's actual HEAD, schemaVersion 11): PASS —` (:30)

Về **nội dung** thì đạt và còn vượt yêu cầu (hai lần build thay vì một), và verdict vẫn là từ đầu
tiên sau dấu hai chấm — nên đây **không** phải "thiếu bằng chứng build/runtime", và không kích hoạt
`PATCH_REQUIRED` của 12g3. Rủi ro là ở chỗ khác: DONE gate cưỡng chế 12g3 **độc lập**, và hook trong
repo này nhiều lần được đo là khớp **chuỗi nhãn cố định** chứ không hiểu nghĩa. Nếu
`validate-done-gate.sh` khớp tiền tố literal `- Build: PASS`, dạng có ngoặc sẽ vô hình với nó và
requirement sẽ bị chặn ở bước đóng.

Tôi **không đo được** điều này: Reviewer không được đọc `.claude/hooks/**`, nên đây là rủi ro đã nhận
diện chứ không phải lỗi đã đo. Cách gỡ rẻ nhất là một dòng: thêm vào cùng mục
`## Integration Build & Runtime` một dòng đúng literal, ví dụ
`- Build: PASS — flutter build apk --debug --split-per-abi, hai lần (v10 baseline và v11 HEAD), chi tiết hai gạch đầu dòng dưới đây`,
giữ nguyên hai dòng hiện có. Chủ sở hữu file là lane đã tạo nó (mobile-dev/devops); ngoài WriteScope
của Reviewer nên báo cáo này không tự sửa. Làm trước khi chạy DONE gate thì mất một dòng; bỏ qua thì
rủi ro mất một vòng chặn ở DONE.

### D-I1 — bản sửa dòng registry nằm sai nhánh (nguy cơ xung đột ở `land-integration`)

Pass 1 nêu dòng STORY-001 trong `req_master.md` `## User Stories` bị kẹt ở `TODO`. Bản sửa **đã tồn
tại nhưng ở nhánh khác**, và đây mới là điểm cần lưu ý:

- control checkout (`cupid-apps/`, trên `main`, **chưa commit**), `req_master.md:19`:
  `| STORY-001 | … | standard | IN_PROGRESS (review DEFERRED_ONLY, merged vào integration branch — chờ Integration Review) | … |`
- worktree integration (`codex/REQ-017_…-integration` @ `646ec1ef`), **cùng dòng 19**:
  `| STORY-001 | … | standard | TODO | … |`

Hai phiên bản khác nhau trên **đúng cùng một dòng** của cùng một file. Vì
`land-integration` là merge thật (xem D-I2, không fast-forward), dòng 19 này là ứng viên xung đột
merge duy nhất mà tôi thấy trong toàn requirement — hoặc tệ hơn, `TODO` từ nhánh integration ghi đè
bản sửa nếu giải xung đột theo hướng "lấy nhánh đang merge". Nên commit/stash bản sửa ở control
checkout một cách có chủ đích **trước** khi land, và kiểm lại dòng 19 **sau** khi land. Scrum Master
sở hữu cả file lẫn thao tác merge (rule 17).

### D-I2 — topology merge-về-main (từ pass 1, thông tin)

`main` tip `70ddb8b8` không phải ancestor của integration HEAD (nhánh cắt từ `908d22d8`), nhưng nội
dung bản vá `70ddb8b8` có mặt nguyên văn trong cây. Merge về `main` sẽ là merge thật chứ không
fast-forward, và theo nội dung thì không có xung đột phải giải. Ghi lại để lần merge đó không bị đọc
nhầm là divergence.

### A-1 — chip loại bị CTA ghim che một phần (thông tin, không phán quyết ở pass này)

Do mobile-dev nêu trong `mobile-visual-audit.md:99-109` dưới dạng advisory, và Scrum Master đã nêu rõ
đây không phải việc pass này phán quyết. Tôi có mở khung
`23h-vua-ve-j8-capture-block-kind-chips-occluded.png`: mô tả **khớp** với ảnh — hàng chip bị nút ghim
"Lưu vào nhật ký" cắt mất phần dưới nhưng nhãn vẫn đọc được và phần trên vẫn chạm được, đúng là
advisory chứ không phải defect bị nói giảm. Ghi lại ở đây để nó không rơi mất, theo dõi như quan sát
UX deferred trên màn check-in, không mở lại STORY-001.

### Carry-forward cấp story (giữ nguyên trạng, không mở lại)

R-1 (AC-8(i) sub-frame dedup latch, tuỳ chọn), F-2 (migration `else if` maintainability), F-5 (gate
asymmetry required-id), P3-U1, P3-U2, O-4, O-5, và ghi chú prose ở
`coding-plan/phase-P4-notebook-origin-label.md` §4:86. Deviation AC-5 "đổi loại" là deviation user
chấp thuận (Option B) — không mở lại.

## Traceability

- **Merged story / merge ref**: STORY-001_checkin_notebook_capture (`standard`), story review verdict
  `DEFERRED_ONLY`; merge `a15bde4f` (parents `908d22d8` ⊕ `dd46d89d`). Requirement một
  story nên không có bề mặt cross-story; AC-1..AC-17 đã có verdict ở story review và pass này không
  chấm lại (rule 16a).
- **Integration evidence**: `integration-review/build-runtime-evidence.md` (F-I1);
  `integration-review/mobile-visual-audit.md` + `integration-review/mobile-screenshots/` (F-I2,
  8 khung, 4 khung đã được Reviewer mở xem); git diff/ancestry nêu trong bảng gate.
- **Runtime/configuration**: `req_master.md` `## Configuration Documentation` `NOT_REQUIRED` — đúng
  với phạm vi (thay đổi cấu hình duy nhất là một dòng asset dir). `## Deployment Status` vẫn
  `NOT_DEPLOYED`/`NOT_REQUESTED`, phù hợp.
- **Cross-requirement contracts**: BR kế thừa REQ-016 — R-1f (không xuất/chia sẻ), SC-3 (không điền
  sẵn), R-15 (nội dung có id bền), BR-12 (không ghi vào thẻ) — đã do story review chốt PASS; tầng
  integration xác nhận merge không phá chúng (gate 2, gate 4), và audit F-I2 xác nhận bằng ảnh rằng
  không có nhóm/route/trường mới nào xuất hiện.
- **OQ discipline**: OQ-1, OQ-2, A-5 đều RESOLVED 2026-09-27 trong `req_master.md`
  `## User Decisions`; không phạm vi nào bị chặn. Không lỗi OQ (rule 12).

## Action items

1. **[mobile-dev hoặc devops — một dòng]** D-I3: thêm một dòng đúng dạng literal `- Build: PASS — …`
   vào mục `## Integration Build & Runtime` của `build-runtime-evidence.md`, giữ nguyên hai dòng
   build chi tiết hiện có. Nên làm **trước** khi Scrum Master chạy DONE gate.
2. **[Scrum Master]** D-I1: xử lý bản sửa dòng 19 `req_master.md` đang treo chưa commit ở control
   checkout **trước** khi chạy `land-integration`, và kiểm lại dòng đó **sau** khi land — đây là
   dòng duy nhất trong requirement có hai nội dung khác nhau ở hai nhánh sắp merge.
3. **[Scrum Master]** A-1: ghi nhận như quan sát UX deferred trên màn check-in (không mở lại
   STORY-001), để nó vào đúng hàng đợi thay vì nằm lại trong file audit.
4. **[không bắt buộc]** dọn nợ prose đã ghi nhận: `phase-P4-notebook-origin-label.md` §4:86 và O-4.

## Khuyến nghị trạng thái

- `Implementation (Development)`: giữ tick.
- `Review (Reviewer)` cấp requirement: **có thể tick** — `DEFERRED_ONLY`.
- Requirement status: **`DONE`** được, sau khi D-I3 xử lý xong (một dòng) và Scrum Master xác nhận
  báo cáo này. Scrum Master sở hữu việc chuyển trạng thái (rule 17).
- Không story nào cần trả về lane nào; không cần rework code.
