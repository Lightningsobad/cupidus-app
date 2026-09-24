# STORY-007 — Review slice P4: đính ảnh (photo attach)

Outcome: PARTIAL_SLICE_ONLY

**Kết luận thật của slice: PASS — 0 phát hiện chặn.** Dòng `Outcome:` phía trên
là literal bắt buộc của chế độ `scoped-slice` (giống P1/P2/P3), không phải phán
quyết story. Phán quyết story thuộc pass final-synthesis sau khi P5 trả kết quả.

- Review type: `scoped-slice` (slice 4/5)
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`
- BaseHead: `bfe231aa`
- Ngày: 2026-09-24

## Phạm vi đã kiểm (đúng danh sách file của handoff)

| File | Vai trò trong P4 |
|---|---|
| `mobile/lib/features/activity_cards/thank_you/data/attachable_photos.dart` | kiểu chiếu + hợp nhất hai nguồn ảnh |
| `mobile/lib/features/activity_cards/thank_you/presentation/widgets/photo_attach_section.dart` | phần 2 (UI hàng ảnh) |
| `.../widgets/thank_you_block.dart` | chỉ phần nạp ảnh + khe `photo` + `_selectedPhotos` |
| `.../presentation/thank_you_block_cubit.dart` | kiểm: P4 **không** thêm gì (xem A2) |
| `.../widgets/thanks_section.dart` | chữ ký `ThankYouComposerOpener` + `thankYouShareParams` |
| `mobile/lib/features/journal/data/journal_repository.dart` | `photoFilePathsForOrigin` |
| `mobile/lib/features/journal/journal_entry_point.dart` | `journalPhotoPathsForOrigin` (hàm chiếu duy nhất) |
| `mobile/test/.../thank_you/photo_attach_test.dart` | 15 test, suite chính của P4 |
| `mobile/test/.../thank_you/thank_you_block_test.dart` | 16 test khe ảnh + đấu nối chia sẻ (nhận claim từ P2 A4) |
| `mobile/test/.../thank_you/thanks_section_test.dart` | 4 closure `openComposer` theo chữ ký mới |

Không kiểm P1/P2/P3/P5. `mobile/test/core/database/journal_dao_test.dart` chỉ
spot-check: đúng một dòng `expect(database.schemaVersion, 9 → 10)` — thuần ripple
phiên bản, khớp những gì slice P1 đã ghi; không mở phát hiện mới.

## Kết quả theo tiêu chí

| Mục | Nguồn ràng buộc | Kết quả | Bằng chứng |
|---|---|---|---|
| Hiện phần 2 khi có ảnh, trỏ đúng ảnh | AC-14 (`requirements/requirements.md:156-158`) | PASS | `attachable_photos.dart:45-55` gộp `ActivityCardDao.photosForCard` + `journalPhotoPathsForOrigin`; `thank_you_block.dart:254-260`; test `gộp hai nguồn ảnh (AC-14)`, `ô đã chạm đi cùng lời cảm ơn (AC-14)` (`thank_you_block_test.dart:670-704`) |
| Không ảnh → phần 2 biến mất hẳn, khối vẫn dùng được | AC-15 (`:160-163`), BR-9 (`:313-316`) | PASS | `thank_you_block.dart:255-256` trả `null` cho khe (không widget rỗng); `thank_you_block_test.dart:620-622` kiểm cả 3 key vắng mặt; ảnh chụp `state-khong-anh-...png` (đã soi mắt) không có header/hàng xám/CTA thúc chụp ảnh |
| Đính là hành động rõ ràng từng ảnh, không chọn sẵn | AC-16 (`:165-168`) | PASS | `photo_attach_section.dart:44,46-52` khởi tạo rỗng, chỉ đổi khi `_toggle`; `thank_you_block_test.dart:639-668` "chưa chạm ô nào thì lời cảm ơn đi một mình" → `handed` rỗng; ảnh chụp không tấm nào có tick |
| Chỉ ảnh rời nhật ký, không chữ/ngày giờ/siêu dữ liệu | AC-17 (`:170-173`), BR-8 (`:308-312`) | PASS | `AttachablePhoto` chỉ có `final String filePath` (`attachable_photos.dart:22`); `photoFilePathsForOrigin` select bảng ảnh, join bảng entry **chỉ để lọc**, trả `List<String>` đường dẫn; `_Thumbnail` vẽ ảnh + tick của app, không caption/ngày; test `hàm đọc chỉ trả đường dẫn...`, `hàng ảnh không kèm chữ nào của nhật ký (AC-17)` |
| Nhật ký vẫn riêng-tư-mặc-định, không bản sao ngoài quyền xoá | AC-18 (`:175-178`) | PASS | `thankYouShareParams` (`thanks_section.dart:68-75`) tạo `XFile(path)` từ đường dẫn gốc, không staging copy; không có đường ghi ngược nào vào `journalEntries`; test `xoá mục nhật ký thì app không giữ lại bản sao nào (AC-18)` |
| Hợp đồng nhật ký một chiều (chỉ thêm đúng một hàm chiếu chỉ-đọc) | ruling `JOURNAL_SOURCE_CONTRACT_CLOSED` 2026-09-23, lối (A) | PASS | `journal_entry_point.dart` 3 → 4 khai báo; hàm mới nhận `originRef` và trả `List<String>`; không liệt kê/đếm/tìm/xem trước; test `entry point vẫn chỉ có bốn khai báo...` và `không có hàm liệt kê, đếm, tìm hay xem trước` fail nếu bề mặt nới ra |
| Không FK / không phụ thuộc ngược `journal` → `activity_cards` | cùng ruling | PASS | `originRef` là cột `text` có sẵn (`journal_entries.dart` **không** nằm trong diff `bfe231aa`); `journal_repository.dart` không import gì từ `features/activity_cards`; chiều phụ thuộc duy nhất là `attachable_photos.dart` → `journal_entry_point.dart` |
| Không đổi schema / không migration trong P4 | phạm vi P1 | PASS | `git diff --name-only bfe231aa -- mobile/lib/core/database/` chỉ có `cupid_database.dart`, `.g.dart`, `thank_you_activations_table.dart` (đều của P1) |
| Không mở đích điều hướng thứ hai | AC-7, tiền lệ `sb-212` của P2 | PASS | Phần 2 không có `Navigator`/`push`/`showModalBottomSheet`; `onTap` chỉ chạy `_toggle`; đường ra duy nhất vẫn là sheet soạn thảo có sẵn của STORY-002 qua `showInviteComposerSheet` |
| Nguồn ảnh hỏng không làm mất cả khối | AC-25 | PASS | `thank_you_block.dart:179-185` nuốt lỗi loader về danh sách rỗng; test `kho ảnh hỏng thì mất khe phần 2, không mất cả khối (AC-25)` |
| Chống trùng + file đã mất | AC-14/AC-15 | PASS | `mergeAttachablePhotos` dedup theo đường dẫn (`Set`), bỏ file `!existsSync()` nên không sinh ô ảnh vỡ; test `cùng một file ở hai nguồn chỉ hiện một lần`, `file đã biến mất thì bị bỏ` |
| Bằng chứng test P4 | `coding-plan/test-results.md` §P4 (dòng 613-735) | PASS | Ghi nhận `photo_attach_test.dart` +15, `thank_you/` +102, `journal/` +67, `activity_cards/ + invite_composer/` +460, analyze hẹp 13 issue / 0 error |
| Chạy lại độc lập (reviewer) | quy tắc 18 | PASS | `flutter test test/features/activity_cards/thank_you/ test/features/journal/ --reporter=failures-only` → `+169 ~6: All other tests passed!`; 6 test skip đều là nhóm `skip: !kCaptureVisuals`; `git status --porcelain` sạch sau khi chạy (không ghi đè PNG story khác) |
| Visual fidelity phần 2 | skill 12e2/12e3, `visual-fidelity/visual-fidelity-report.md:137-192` | PASS (có delta đã ghi) | Đã **mở cả 3 PNG**: `implemented-...png` hiện đúng hàng 3 thumbnail vuông cuộn ngang dưới header `KÈM ẢNH · KHÔNG BẮT BUỘC`, không tick, không chữ đè, đủ dấu tiếng Việt (không tofu); `state-khong-anh-...png` vắng hẳn phần 2; `design-reference-sb-212-...png` đúng màn hình sb-212 |

## Ghi chú advisory (không chặn)

- **A1 — handoff dẫn sai id AC.** Bản giao việc nêu "AC-4/AC-5" là AC chi phối
  phần 2. Sai: AC-4 (`requirements.md:105`) và AC-5 (`:110`) nói về lượt kích
  hoạt khi thẻ đổi trạng thái — thuộc P1. AC chi phối phần 2 là **AC-14..AC-18 +
  BR-8/BR-9** (`:154-178`, `:308-316`), đúng như code tự trích dẫn. Review này
  chấm theo AC thật. Scrum Master nên sửa ở handoff P5/final-synthesis.
- **A2 — `thank_you_block_cubit.dart` không có phần thêm nào của P4.** Handoff
  mô tả "photo-selection state/logic P4 layered on top"; thực tế cubit vẫn đúng
  bề mặt P2 (`isVisible`/`resolve`/`dismiss`). Trạng thái chọn ảnh nằm ở
  `ValueNotifier<List<String>> _selectedPhotos` trong `_ThankYouSectionState`
  (`thank_you_block.dart:146`). Không phải lỗi — thiết kế này giữ cubit khỏi
  trạng thái UI thuần; chỉ ghi lại để final-synthesis không đi tìm thứ không tồn
  tại.
- **A3 — `Image.file` không có `errorBuilder`** (`photo_attach_section.dart:140`).
  Sự tồn tại của file được kiểm ở lúc nạp (`attachable_photos.dart:74`), nhưng
  nếu file biến mất giữa lúc nạp và lúc vẽ thì Flutter dựng widget lỗi ngay
  trong hàng ảnh. Cửa sổ race hẹp và không thuộc AC nào; DEFERRED.
- **A4 — `existsSync()` đồng bộ trên mỗi đường dẫn** khi gộp. Ở khối lượng hiện
  tại (vài ảnh/thẻ) không đáng kể, và nó chạy trong `await` trước `setState`;
  chỉ đáng xem lại nếu nguồn ảnh về sau lớn lên. DEFERRED.
- **A5 — đóng advisory A4 của slice P2.** `thank_you_block_test.dart` (16 test)
  trước đó chưa thuộc danh sách file của slice nào; slice này nhận nó làm bằng
  chứng test chính của P4 và đã kiểm nội dung (khe ảnh, chọn/bỏ chọn, đấu nối
  vào `openComposer`).
- **A6 — lệch BaseHead trong test-results, giống hệt điều P1 đã nêu.** §P4 ghi
  BaseHead `3a824d4a` (mốc nền của riêng pha) trong khi BaseHead review là
  `bfe231aa`. Không phải lỗi, nhưng là mẫu lặp lại lần thứ hai trong story.

## Chuyển tiếp cho pass final-synthesis (không tái tranh luận ở đây)

1. Hai mục `DESIGN_SPEC_CONFLICT` của P4 đã được **kiểm chứng là thật**, không
   phải delta cài nhãn: mở `design-reference-sb-212-...png` thấy đúng (a) một
   hàng full-width `Kèm một ảnh tối qua` + phụ đề `lấy từ tối qua bạn lưu lúc
   23h` — siêu dữ liệu nhật ký trên màn hình có thể chia sẻ, ngược AC-17/BR-8;
   và (b) chevron cuối hàng — hàm ý đích điều hướng thứ hai, ngược AC-7. Cả hai
   trích dẫn AC song song với phần tử thiết kế, đúng chuẩn 12e2. Tiền lệ "theo
   AC/spec, không theo canvas" đã áp dụng ở P2 và STORY-006 P2; slice này giữ
   nguyên, không mở lại.
2. `visual-fidelity-report.md` dòng 1 ghi `VISUAL_FIDELITY: PASS` **đồng thời**
   mang mục `DESIGN_SPEC_CONFLICT`. Final-synthesis cần xử lý cặp này một cách
   có chủ ý theo tiền lệ đã có, vì cổng 12e2 mặc định muốn
   `BLOCKED: DESIGN_SPEC_CONFLICT` còn cấu hình/tiền lệ story này lại đã chốt
   phía AC. Đây là điểm duy nhất của P4 cần một quyết định ở tầng story.
3. Khoảng trống đã biết và được chấp nhận: chưa caller nào ghi `originRef` từ
   thẻ (STORY-008 mới là caller), nên nhánh nhật ký trả rỗng trên bản build hiện
   tại. Đường code đã được kiểm bằng hàng gieo thẳng qua `saveEntry(..., originRef:)`
   và đúng/an toàn khi caller xuất hiện. Không tính là khuyết tật (theo ruling).

## Khuyến nghị trạng thái

Không đổi trạng thái story ở slice này. P4 không đóng góp phát hiện chặn nào;
story chờ slice P5 rồi tới final-synthesis.
