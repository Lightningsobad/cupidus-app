# Cross-Lane Contract — REQ-016 STORY-004 Kho ngữ cảnh + gợi ý quà

Authoritative source: `mobile/` (STORY-004).
Consumers: `mobile/` STORY-005 (mồi chuyện), STORY-008 (kịch bản), STORY-009
(chân dung), STORY-010 (bảng tra) — cả bốn **đọc** kho ngữ cảnh và **tái dùng
nguyên** cơ chế hỏi-tại-chỗ. Hợp đồng này tự chứa: consumer không cần mở
`solution.md` hay đọc source để cài đặt theo nó.

## 1. Envelope

Hai envelope, không có envelope thứ ba. Không HTTP, không backend, không API
nội dung, không mô hình AI ở bất kỳ đường đi nào (R-7, AC-28).

**(A) Gói nội dung — Flutter asset JSON.** Tái dùng nguyên vẹn
`ContentPackage`/`ContentPackageLoader`
(`mobile/lib/core/content/content_package.dart`, do STORY-001 giao). Năm gói,
mỗi gói **một `schema_id` riêng** vì hình dạng item khác hẳn nhau — đây là một
**họ gói mới**, không phải một danh mục mới của họ `req016.presets.v1`
(STORY-002 §6 cấm thêm danh mục preset với schema id riêng; ràng buộc đó áp cho
họ preset mad-libs, không áp cho họ khác). Thư mục `assets/data/req016/` đã khai
báo sẵn trong `pubspec.yaml`: thêm gói **không** sửa `pubspec.yaml`, **không**
sửa engine.

**(B) Kho ngữ cảnh — API Dart trong tiến trình + bảng Drift cục bộ.** Không wire
protocol. Sai khớp tên trường là **lỗi biên dịch Dart**, không mất dữ liệu âm
thầm.

## 2. Identifiers — copy exactly

| Mục đích | Định danh | Ràng buộc |
|---|---|---|
| Gói ý tưởng quà | `req016.gifts.v1` | `assets/data/req016/gifts.v1.json` |
| Gói bảng tra chỉ mục quà | `req016.gift_index.v1` | `assets/data/req016/gift_index.v1.json` |
| Gói phân loại quà (nhánh + thang công sức) | `req016.gift_taxonomy.v1` | `assets/data/req016/gift_taxonomy.v1.json` |
| Gói mồi kỹ năng | `req016.skill_seeds.v1` | `assets/data/req016/skill_seeds.v1.json` |
| Gói câu hỏi tại chỗ | `req016.ask_questions.v1` | `assets/data/req016/ask_questions.v1.json` |
| Loại mục sổ tay | `interest` · `event` | cột `notebook_entries.kind`; enum đóng, R-1f |
| Đích của một câu hỏi | `notebook.interest` · `notebook.event` · `skill` | `ask_questions[].target` **và** `neededFieldIds` |
| Nhánh quà (giá trị bản đầu) | `by_occasion` · `no_cost` · `handmade` | item `kind: branch` của gói taxonomy — **là dữ liệu**, không phải enum Dart |
| Nguồn ghi một mục | `ask_on_the_spot` · `manual` | cột `source` của cả hai bảng |
| Bốn mồi kỹ năng mềm bắt buộc | `skill.nho_dai.v1` · `skill.biet_cho_an_ngon.v1` · `skill.goi_qua_dep.v1` · `skill.chon_nhac_hop_canh.v1` | cổng nhập từ chối gói thiếu bất kỳ id nào (AC-11) |
| Cửa vào gọi hỏi-tại-chỗ | `gift_ideas` · `skill_profile` | append-only; STORY-005/008/009/010 thêm **giá trị**, không thêm cơ chế |
| Nguồn sinh thẻ | `gift_suggestion` | đã dành sẵn ở `STORY-001/architecture/contract-summary.md` §2 |

Quy tắc cho phía tiêu thụ:

- `items[].id` của mọi gói là **id bền**: append-only, không đổi tên, không tái
  dùng, không xoá một id đã ship (hàng sổ tay/kỹ năng trỏ ngược vào nó).
- Chỉ số trong `items` **không bao giờ** là định danh.
- Nhánh và bậc thang công sức là **item dữ liệu**, không phải enum Dart. Viết
  `switch` trên một danh sách nhánh cứng trong code là vi phạm R-15a/AC-34.

## 3. Cơ chế hỏi-tại-chỗ — API dùng chung (BR-15)

```dart
// mobile/lib/features/context_notebook/context_notebook_entry_point.dart
Future<void> openNotebookScreen(BuildContext context);
Future<void> openSkillProfileScreen(BuildContext context);

abstract interface class ContextNotebookReader {
  Future<List<NotebookEntry>> entries({NotebookKind? kind});
  Future<List<SkillEntry>> skills();
}

class AskOnTheSpotSlot extends StatelessWidget {
  const AskOnTheSpotSlot({
    required this.entryPointId,      // §2, ví dụ 'gift_ideas'
    required this.neededFieldIds,    // §2 target ids, theo thứ tự ưu tiên
    required this.onContextChanged,  // luồng gọi lại chính nó, tại chỗ
  });
}
```

- `AskOnTheSpotSlot` dựng **thẻ hỏi inline**, không dialog, không route mới.
  Nó tự trả `SizedBox.shrink()` khi không thiếu trường nào, khi câu đã được trả
  lời, khi câu vừa bị bỏ qua trong phiên hiện tại, **và khi một slot khác đã
  dựng trên cùng một route** — "đúng một câu một lần" (AC-2/BR-2) là bất biến
  của widget này, không phải kỷ luật của phía gọi.
- Trả lời ghi thẳng vào `notebook_entries`/`skill_profile_entries` rồi gọi
  `onContextChanged`. **Không** toast, **không** màn xác nhận, **không** nút
  "Lưu vào hồ sơ" (AC-1).
- "Bỏ qua" luôn tiếp tục luồng với kết quả rộng hơn (AC-3/BR-3).

## 4. Bảng Drift — cột

`notebook_entries`: `id` TEXT PK (uuid v4) · `owner_key` TEXT NOT NULL (backend
`User.id`, mọi truy vấn lọc theo cột này) · `kind` TEXT NOT NULL (`interest` |
`event`) · `value` TEXT NOT NULL · `detail` TEXT NULL (ghi chú **bên trong**
chính mục đó, không phải nhóm thứ ba — AC-6) · `event_on` TEXT NULL (ngày dân
dụng `YYYY-MM-DD`, chỉ có nghĩa khi `kind == event`) · `source` TEXT NOT NULL ·
`question_id` TEXT NULL (id bền của câu hỏi đã sinh ra mục) · `created_at` /
`updated_at` DATETIME NOT NULL.

`skill_profile_entries`: `id` TEXT PK · `owner_key` TEXT NOT NULL · `label` TEXT
NOT NULL · `seed_id` TEXT NULL (id bền của chip mồi; NULL = người dùng tự gõ) ·
`source` TEXT NOT NULL · `created_at` / `updated_at` DATETIME NOT NULL.

`ask_prompt_state`: PK gộp (`owner_key`, `question_id`) · `state` TEXT NOT NULL
(`answered` | `skipped`) · `updated_at` DATETIME NOT NULL.

- Chuẩn hoá và mặc định thuộc repository, không thuộc UI.
- **Cột bị cấm vĩnh viễn** (R-1b/AC-12/AC-25, cưỡng chế ở test): mọi cột mức độ,
  sao, điểm, hạng, `proficiency`, `level` trên `skill_profile_entries`; mọi cột
  đo hành vi người kia trên `notebook_entries` (`partner_*`, `seen_*`,
  `reply_*`, `frequency_*`). `ask_prompt_state` không được thêm cột đếm.

## 5. Deploy / rollout order

Một binary duy nhất mang cả engine, gói nội dung, và schema — không có thứ tự
triển khai đa phía. Hai thứ tự có thật:

1. **Cổng nhập nội dung chạy trước khi bản dựng ra đời.** Test quét
   `assets/data/req016/*.v1.json` từ đĩa và chạy validator tương ứng; gói vi
   phạm → test đỏ → **bản dựng hỏng** (AC-35/AC-36/BR-18). Không có nhánh nào
   để vi phạm lọt tới người đọc.
2. **Migration cộng thêm.** Ba bảng ở §4 là DDL mới nên `schemaVersion` +1.
   Đọc giá trị thật trên nhánh tích hợp lúc cài đặt rồi cộng một — **không**
   chép một con số từ tài liệu này. Chỉ `CREATE TABLE`; huỷ-tạo-lại bị cấm
   tuyệt đối cho mọi bảng dữ liệu gốc.

## 6. Phía tiêu thụ KHÔNG được làm

- Không vẽ lại thẻ hỏi. STORY-005/008/009/010 dựng `AskOnTheSpotSlot`, không
  dựng dialog/màn hỏi riêng (`ux/uiux-spec.md` Phần A).
- Không mở đường ghi thứ hai vào sổ tay/kỹ năng ngoài `AskOnTheSpotSlot` và nút
  "+ tự thêm" của màn (2)/(3) — mọi luồng điền-trước là vi phạm SC-3/BR-1.
- Không thêm chức năng xuất/chia sẻ/copy-toàn-bộ sổ tay dưới bất kỳ tên nào
  (R-1f/AC-7). `ContextNotebookReader` là API nội bộ, không phải cửa xuất.
- Không đặt câu chữ quà/mồi kỹ năng/câu hỏi vào widget, l10n, hay hằng Dart.
  Ngược lại: **luật** bất biến chỉ sống trong Dart, không bao giờ trong asset —
  nếu không, CMS ngoài repo tự nới luật của chính nó (R-15c).
- Không giả định số mục của một gói. `ContentPackage.length` là dữ liệu; hết-tập
  là quay vòng modulo `length`. Cấm "đã hết ý tưởng", màn ngõ cụt, và mọi chỉ
  báo tiến độ/phần trăm/đếm số (AC-33/BR-17).
- Không tạo bảng/danh sách "quà đã lưu" (SC-1'/AC-22) và không lưu con trỏ
  xoay vòng xuống DB — nó sống trong Cubit, đúng một vòng đời màn.
