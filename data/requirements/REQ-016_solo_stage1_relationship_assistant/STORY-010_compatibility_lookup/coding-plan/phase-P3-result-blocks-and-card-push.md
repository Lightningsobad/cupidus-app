# Phase P3 – Khối trình bày kết quả

## 1. Phase Metadata

- Phase Id: P3
- Owner: Mobile Developer
- Lane: Mobile
- Depends On: P1
- Parallelizable: YES (chạy song song P5, P6)
- Status: COMPLETE
- Runtime Registry Id: `mobile-app`
- Build Command Source: runtime registry `mobile-app.buildCommand`
- Startup Smoke: NOT_APPLICABLE

## 2. Goal

Dựng các widget thuần hiển thị một ô ăn khớp: chip DẢI, khối "chỗ hợp"/"chỗ dễ
va", khối hoạt động kèm nút đẩy sang kho, khối câu hỏi. Widget nhận
`CompatCell` + `CompatBand` qua tham số và **không** biết gì về database, cubit,
hay điều hướng. Nhờ vậy P3 chạy song song với nhánh nội dung P5/P6.

## 3. Primary Inputs

- `../ux/uiux-spec.md` — bố cục, thứ tự khối, ngôn ngữ thị giác
- `../requirements/requirements.md` — AC-32, AC-33, AC-34
- P1: `mobile/lib/features/compatibility_lookup/domain/compat_content.dart`
- `mobile/lib/features/gift_ideas/presentation/` — mẫu widget, mẫu theming
- `mobile/lib/l10n/app_vi.arb`, `mobile/lib/l10n/app_en.arb`
- `../coding-plan/coding-agent-guide.md`

## 4. Write Scope

- `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_band_chip.dart`
- `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_facet_block.dart`
- `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_activity_block.dart`
- `mobile/lib/features/compatibility_lookup/presentation/widgets/compat_question_block.dart`
- `mobile/lib/l10n/app_vi.arb`, `mobile/lib/l10n/app_en.arb` (sửa)
- `mobile/test/features/compatibility_lookup/compat_result_widgets_test.dart`

## 5. Planned Outputs

- `CompatBandChip` hiển thị **nhãn** DẢI, không gì khác.
- `CompatFacetBlock` — **một** widget duy nhất dựng được cả hai mặt.
- `CompatActivityBlock` phát `VoidCallback? onAddToMyStore`.
- `CompatQuestionBlock`.
- Chuỗi nhãn khối trong cả hai ARB.
- Ảnh chụp `RepaintBoundary` làm bằng chứng thị giác.

## 6. Implementation Steps

1. `CompatBandChip` chỉ nhận `CompatBand` và vẽ `band.label`. **Không** tham số
   nào mang nghĩa thứ hạng, mức độ, màu-theo-điểm, hay vị trí trên thang. DẢI là
   nhãn rút từ từ vựng đóng; nếu chip nhận thêm một `double` hay một `index`
   thì thang đo đã lẻn vào và AC-32 vỡ. Màu, nếu có, tra từ `band.id` qua bảng
   ánh xạ rời rạc — không nội suy.
2. `CompatFacetBlock` là chỗ AC-33 sống hay chết. Ký tự:
   `CompatFacetBlock({required CompatFacetKind kind, required String text})`
   với `kind` là `fit | friction`. Màn dựng **cùng** widget này hai lần. Chỉ
   những gì `kind` quyết định (tiêu đề, biểu tượng) được khác; padding, cỡ chữ,
   độ dày, bo góc, khoảng cách đều lấy từ cùng một nguồn. Tuyệt đối không tạo
   `CompatFitBlock` và `CompatFrictionBlock` riêng — hai bản song sinh sẽ lệch
   ở lần sửa thứ ba và không ai nhận ra.
3. `CompatActivityBlock` vẽ `cell.activity` và một nút gọi `onAddToMyStore`.
   Widget **không** tự tạo thẻ; nó chỉ phát tín hiệu. Việc tạo thẻ thuộc P4.
4. `CompatQuestionBlock` vẽ `cell.question` như một câu hỏi mở, không phải một
   ô nhập. Story này không thu câu trả lời (AC-31).
5. Thêm chuỗi ARB cho tiêu đề bốn khối và nhãn nút. Chạy `flutter gen-l10n`
   trước khi test.
6. Test widget:
   - Dựng `CompatFacetBlock` hai lần với `kind` khác nhau, rồi khẳng định các
     thuộc tính hình học **bằng nhau**. Đây là test khoá đối xứng; nó là lý do
     phase này tồn tại.
   - Khẳng định cây widget của kết quả **không** chứa `LinearProgressIndicator`,
     `CircularProgressIndicator` ở vai trò hiển thị mức độ, `Slider`, hay bất kỳ
     `Text` nào khớp `%`/`/10`/`điểm`.
   - Nhấn nút hoạt động gọi đúng một lần `onAddToMyStore`.
7. Bằng chứng thị giác: bọc khối kết quả trong `RepaintBoundary` ngay trong
   file test này và chụp. Bố cục chụp phải bọc `CupidAppBackground` và nạp font
   `MaterialIcons` của framework, nếu không ảnh ra nền trắng kèm ô vuông. **Mở
   ảnh ra nhìn**: chữ tiếng Việt có dấu phải hiện đúng dấu, không phải ô vuông
   tofu. Một lần chạy xanh không chứng minh ảnh đúng.

## 7. Test Scope

- `mobile/test/features/compatibility_lookup/compat_result_widgets_test.dart`

Nếu một `tap()` trượt vì widget nằm ngoài khung, hãy **nới kích thước khung
test**, đừng đổi bố cục sản phẩm cho vừa khung 800x600 mặc định.

Ngoài phạm vi: e2e, chạy trên thiết bị, script gate ở gốc repo, runtime startup
smoke.

## 8. Build Gate

`flutter build apk --debug` (nguồn: runtime registry `mobile-app.buildCommand`).
Không nối ống.

## 9. Runtime Startup Gate

NOT_APPLICABLE.

## 10. Completion Criteria

- Bốn widget tồn tại, thuần, không phụ thuộc cubit/database/điều hướng.
- Test đối xứng `fit`/`friction` xanh.
- Test "không có thang đo" xanh.
- Ảnh `RepaintBoundary` đã chụp **và** đã được mở ra kiểm bằng mắt.
- Build gate xanh.

## 11. Stop Rule

Dừng với `VISUAL_FIDELITY_BLOCKED` nếu không dựng được ảnh chụp đọc được, hoặc
nếu `uiux-spec.md` đòi một cách trình bày DẢI mà không thể tách khỏi nghĩa thang
đo. Báo đúng phần spec và đúng AC xung đột; đừng tự chọn bên.
