# STORY-007 — Review slice P3: danh mục preset "cảm ơn sau buổi hẹn"

Outcome: PARTIAL_SLICE_ONLY

Kết luận slice: **PASS — không có phát hiện chặn.** 5 mục advisory bên dưới,
trong đó **A3 cần Scrum Master xử lý trước khi story đóng** (không phải lỗi mã).

- Ngày review: 2026-09-24
- Slice: 3/5 (chỉ phạm vi P3; P1/P2 đã review riêng, P4/P5 chưa)
- BaseHead diff: `bfe231aa`
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`

## 1. Phạm vi file đã xác nhận qua diff

`git diff --name-only bfe231aa` cho thấy cổng nội dung **không** nằm ở
`activity_cards/thank_you/domain/` như bản giao việc phỏng đoán, mà là file
gốc của STORY-002:

| File | Trạng thái | Thay đổi |
|---|---|---|
| `mobile/lib/features/invite_composer/domain/preset_content_gate.dart` | sửa | +30 / -4 |
| `mobile/assets/data/req016/presets.thank_you_after_date.v1.json` | mới | +159 |
| `mobile/test/features/invite_composer/preset_content_gate_test.dart` | sửa | +172 / -65 |

Tham chiếu tiêu thụ (đọc để kiểm "không có engine mới", không review sâu vì
thuộc lát khác): `thank_you/presentation/widgets/thanks_section.dart`.

## 2. Kết quả từng mục kiểm bắt buộc

### 2.1 Dữ liệu preset là phần thêm, id ổn định, không đụng id cũ (R-15/R-15a)

ĐẠT. Gói mới có `id` = `presets.thank_you_after_date`, 10 khung, mọi id mang
tiền tố danh mục `thank_you_after_date.*`; gói `presets.invite.v1.json` dùng
tiền tố `invite.*` và **không có trong diff** (byte-identical so với
`bfe231aa`), nên không tồn tại khả năng trùng hay tái dụng id. `version` và
`locale` giữ đúng quy ước của gói cũ.

`N = 10` không xuất hiện ở bất kỳ file Dart nào. Nơi duy nhất ghim con số là
danh sách tên file danh mục trong test (AC-22), đúng ngoại lệ mà R-15b cho
phép. Lời văn preset cũng không bị chép vào Dart — có test quét toàn bộ `lib/`
đối chiếu từng `frame`/`clause.text` để chặn (`preset_content_gate_test.dart`
dòng 167-193).

### 2.2 `decline_door` thực sự theo phạm vi danh mục, không phải công tắc toàn cục

ĐẠT, và đúng nguyên văn lối (A) của ruling 2026-09-23.

- `_declineDoorCategories = {inviteCategoryId}` (dòng 57) liệt kê danh mục
  **nợ** cửa từ chối. Danh mục mới không bị nêu tên trong file gate → thoả
  AC-36 ("không nhánh `if category == 'thank_you_after_date'`"). Xác nhận bằng
  tìm kiếm: chuỗi `thank_you_after_date` chỉ xuất hiện ở `thanks_section.dart`
  (khai báo hằng) và trong test, không có trong `preset_content_gate.dart` hay
  bất kỳ file engine nào.
- Nhánh lời mời giữ nguyên độ chặt: `doors.length != 1` — vẫn là "đúng một",
  không nới thành "≤ 1". Nhánh còn lại chỉ nới phần *thiếu*, vẫn chặn *thừa*
  (`doors.length > 1`).
- `categoryId` là tham số **bắt buộc** do phía gọi cấp, có chú thích nói rõ
  không đọc từ `package.id` để một gói không thể tự khai danh mục nhằm thoát
  luật. Đây là lựa chọn đúng về an toàn.
- Mọi luật còn lại vẫn toàn cục, không bị phạm vi hoá lây: cửa từ chối gắn
  biến (`declineDoorConditional`, dòng 102-116), `editorial_review` hai lớp,
  và toàn bộ denylist từ vựng (chống nịnh, `%`, chuỗi ngày, điểm số, đo hành
  vi người nhận, giọng thao túng) — dòng 118-135. Không có đường nào để danh
  mục mới né các luật R-1b/R-1g.
- Dữ liệu ship nhất quán với BR-6: 8/10 khung không có cửa từ chối; 2 khung có
  lời rủ nhúng kèm (`ru_tiep_nhe`, `hen_lan_sau`) mỗi khung mang **đúng một**
  cửa từ chối với `requires: []` — nên vẫn qua `declineDoorConditional`.

### 2.3 Không có engine/cổng thứ hai

ĐẠT. Không có file gate hay renderer mad-libs nào được thêm. `thanks_section.dart`
mở đúng sheet của STORY-002 qua `showInviteComposerSheet(...)` và dựng
`InviteComposerCubit` với `categoryId` khác — cả hai file đó **không nằm trong
diff**, tức seam `createCubit` đã có sẵn từ trước, không phải mới đục ra cho
story này. Engine render (`invite_preset.dart`, `invite_composer_cubit.dart`)
không bị chạm, thoả AC của phase "diff không chạm file engine render".

`validatePresetPack` vẫn chỉ được gọi từ test (cổng dựng, không phải cổng
runtime) — đúng thiết kế sẵn có ở `bfe231aa`, không phải thay đổi của P3.

### 2.4 Bằng chứng test

ĐẠT. `coding-plan/test-results.md` §P3 (dòng 488-611) ghi Result PASS kèm lệnh
và dòng kết quả thật: `test/features/invite_composer` `+123`,
`test/features/activity_cards/thank_you` `+82 ~1`, cùng bảng 10 id preset đã
ship (khoá truy vết duyệt nội dung, đúng Planned Outputs mục 5).

Reviewer chạy lại đúng file test của lát này:

```
flutter test test/features/invite_composer/preset_content_gate_test.dart --reporter failures-only
+22: All tests passed!
```

Test phủ **cả hai chiều** của ruling trên cùng một fixture (dòng 213-225): cùng
gói thiếu cửa từ chối thì danh mục lời mời vẫn `declineDoorMissing`, danh mục
`thank_you_after_date` thì rỗng. Thêm một test giữ chiều "hai cửa vẫn là vi
phạm kể cả ở danh mục không phải lời mời" (dòng 240-252). Test quét thư mục
asset thật nên một gói vi phạm làm đỏ bản dựng chứ không đến tay người đọc.

Không có test nào trong `test/design_system/` bị chạm ở lần chạy này, nên
`BUG-20260924-001` không phát sinh trong phạm vi lát P3.

### 2.5 Hình dạng schema khớp gói cũ

ĐẠT. Đối chiếu cấu trúc với `presets.invite.v1.json`: cùng khoá mức gói
(`id`, `version`, `schema_id`, `locale`, `items`), cùng khoá mức khung (`id`,
`frame`, `clauses`, `editorial_review`), cùng khoá mức mệnh đề (`text`,
`requires`, `targets`, `role` tuỳ chọn). Dùng chung `schema_id` =
`req016.presets.v1`, **không fork** sang `req016.presets.thanks.v1` — có test
khẳng định schema id lạ bị từ chối ngay ở lớp nạp (AC-29).

## 3. Advisory (không chặn)

**A1 — `_declineDoorCategories` là allowlist, nên mặc định là "mở".** Một danh
mục *mới mang ngữ nghĩa lời mời* trong tương lai (ví dụ `invite_again`) sẽ mặc
định **không** bị buộc cửa từ chối, tức luật an toàn R-1c/AC-10 fail-open thay
vì fail-closed. Hiện chỉ có 2 danh mục nên không có rủi ro thực tế, và test
ghim danh sách tên file danh mục (AC-22) buộc người thêm danh mục phải sửa test
đó — nơi người review sẽ nhìn thấy. Đề xuất cho requirement sau: gắn ghi chú
"thêm danh mục lời mời thì phải thêm tên vào `_declineDoorCategories`" ngay tại
test ghim đó.

**A2 — Test quét đĩa tự suy lại luật.** Dòng 135 dùng
`_categoryOf(file) == inviteCategoryId` thay vì đọc `_declineDoorCategories`
(vốn private). Đây là oracle độc lập nên chấp nhận được, và nếu tập danh mục
đổi thì test sẽ đỏ *to tiếng* chứ không âm thầm nới — hướng hỏng an toàn.
Ghi nhận để pass final-synthesis không hiểu nhầm là trùng lặp thừa.

**A3 — CẦN SCRUM MASTER: căn cứ ruling chưa được commit.** Chú thích trong
`preset_content_gate.dart` (dòng 50-56) viện dẫn "hàng `## Design Ruling Log`
của `req_master.md` ngày 2026-09-23". Hàng đó (`CONTENT_GATE_CATEGORY_COUPLING`,
dòng 221) hiện **chỉ tồn tại dưới dạng sửa đổi chưa commit ở control checkout**
(`git status` → ` M .../req_master.md`, `+2` dòng). Bản `req_master.md` trong
worktree của story có **0** lần xuất hiện chuỗi `CONTENT_GATE_CATEGORY_COUPLING`
hay `2026-09-23`. Đây là căn cứ **duy nhất** cho phép P3 sửa file thuộc
STORY-002 ngoài write-scope gốc; nếu sửa đổi này không được commit, phần mã đã
ship sẽ trỏ tới một hàng ruling không tồn tại trong repo. Không phải lỗi mã —
cần Scrum Master commit hàng ruling.

**A4 — `_categoryOf()` giả định hậu tố `.v1.json`.** Biểu thức tên file
(`^presets\..+\.json$`) nhận mọi phiên bản, nhưng `_categoryOf()` cắt cứng
`.v1.json`. Một gói `.v2.json` sau này sẽ sinh category id méo. Không ảnh hưởng
hiện tại (cả 2 gói đều `.v1`).

**A5 — BaseHead trong evidence khác BaseHead review.** `test-results.md` §P3
ghi BaseHead `5fa0e972` (mốc nội bộ của phase), trong khi lát review dùng
`bfe231aa`. Cùng loại ghi chú sổ sách như mục 3 của slice P1; không phải sai
lệch nội dung.

## 4. Đã kiểm nhưng nằm ngoài phạm vi lát này

P1 (sổ kích hoạt), P2 (khung khối + điểm gắn), P4 (đính ảnh), P5 (chốt việc kế
tiếp) không được đánh giá ở đây. Việc `R-15c` là id trích dẫn sai đã do slice P1
ghi nhận, không xét lại.
