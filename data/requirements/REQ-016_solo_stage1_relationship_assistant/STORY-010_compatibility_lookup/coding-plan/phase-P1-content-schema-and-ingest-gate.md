# Phase P1 – Lược đồ gói nội dung và cổng nhập

## 1. Phase Metadata

- Phase Id: P1
- Owner: Mobile Developer
- Lane: Mobile
- Depends On: None
- Parallelizable: YES (chạy song song P2)
- Status: NOT_STARTED
- Runtime Registry Id: `mobile-app`
- Build Command Source: runtime registry `mobile-app.buildCommand`
- Startup Smoke: NOT_APPLICABLE

## 2. Goal

Dựng lược đồ ba gói `req016.compat_*`, bộ parser, và **cổng nhập nội dung** —
validator biến nội dung sai luật thành bản dựng đỏ. Kết thúc phase này, ba gói
đã hợp lệ và đầy đủ về mặt cấu trúc nhưng **trục còn nhỏ** (2 giá trị mỗi hệ,
đủ 4 ô mỗi gói), để P5/P6 mở rộng sau mà không bao giờ để cây đỏ.

Đây là phase contract-first của story: P3, P4, P5, P6 đều đọc hình dạng do phase
này chốt.

## 3. Primary Inputs

- `../architecture/contract-summary.md` section 2 (ba gói) và section 3 (hình
  dạng item, bộ bốn bắt buộc, luật cấm số)
- `../requirements/requirements.md` — AC-32, AC-34, AC-36, AC-37, AC-38
- `mobile/lib/core/content/content_package.dart` — `ContentPackage.parse<T>`,
  `ContentPackageLoader`, các helper `requireContentString` /
  `optionalContentString` / `requireContentObjectList`
- `mobile/lib/core/content/invariant_terms.dart` — `InvariantRule`,
  `NotebookBoundaryRule`, `invariantHitsIn`, `notebookBoundaryTerms`
- `mobile/lib/features/gift_ideas/domain/gift_content_gate.dart` — **mẫu để
  chép cấu trúc**: enum luật, lớp violation, hàm `validate*Packs` thuần
- `mobile/test/features/gift_ideas/` — mẫu test cổng đọc asset từ đĩa
- `../coding-plan/coding-agent-guide.md`

## 4. Write Scope

- `mobile/lib/features/compatibility_lookup/domain/compat_content.dart`
- `mobile/lib/features/compatibility_lookup/domain/compat_content_gate.dart`
- `mobile/assets/data/req016/compat_bands.v1.json`
- `mobile/assets/data/req016/compat_zodiac.v1.json`
- `mobile/assets/data/req016/compat_mbti.v1.json`
- `mobile/test/features/compatibility_lookup/compat_content_gate_test.dart`

`mobile/assets/data/req016/` đã được khai báo trong `pubspec.yaml` từ STORY-004;
**không** sửa `pubspec.yaml` trong phase này.

## 5. Planned Outputs

- `CompatBand`, `CompatAxisValue`, `CompatCell` implement `ContentItem`, cùng
  `compatBandsSchemaId` / `compatZodiacSchemaId` / `compatMbtiSchemaId` ghim
  cứng.
- Hàm tra thuần `CompatCell? lookupCell(ContentPackage<CompatCell> pack, {required String selfId, required String partnerId})` — BR-3.
- `enum CompatGateRule` + `class CompatViolation` + hàm thuần
  `List<CompatViolation> validateCompatPacks({...})`.
- Ba file JSON hợp lệ, trục 2 giá trị, đủ `2² = 4` ô mỗi gói.
- Test đọc ba asset **từ đĩa** và fail build khi có vi phạm.

## 6. Implementation Steps

1. Định nghĩa model theo `contract-summary.md` section 3. Item có
   `kind: axis_value | cell`. Ô mang `id` (`<self>__<partner>`), `self_id`,
   `partner_id`, `band_id`, và bộ bốn `fit`, `friction`, `activity`, `question`
   — cả bốn **bắt buộc**, không có trường nào nullable.
2. Viết `lookupCell` có hướng: `(self, partner)` là cặp **có thứ tự** (BR-2).
   `lookupCell(pack, selfId: 'aries', partnerId: 'pisces')` và bản đảo ngược là
   hai ô khác nhau. Viết test khẳng định điều này, vì đây là lỗi dễ mắc nhất.
3. Viết cổng nhập. Bảy nhóm luật, mỗi nhóm một giá trị `CompatGateRule`:
   - **Phủ kín**: đếm item `kind: axis_value` ra `n`, rồi khẳng định có đúng
     `n * n` ô và mọi cặp `(self, partner)` đều có mặt, không thiếu không thừa
     (AC-36). **Không hardcode `n`.**
   - **Không số**: duyệt đệ quy mọi giá trị JSON của mọi item trong cả ba gói;
     gặp `num` là vi phạm (AC-32). Đây là hàng rào chặn "DẢI hoá thành thang
     đo" ở tầng dữ liệu, mạnh hơn mọi review bằng mắt.
   - **Bộ bốn**: bốn trường phải có mặt và không rỗng sau `trim()`. `question`
     phải kết thúc bằng `?` (AC-37e).
   - **Band hợp lệ**: mọi `band_id` của ô phải tồn tại trong `compat_bands.v1`.
   - **Denylist sẵn có**: chạy `invariantHitsIn` trên bốn trường văn bản. Ánh xạ
     AC-37: (a) → `recipientBehaviour`; (c) → `percentDisplay` +
     `scoreOrRatio`; (d) → `streakDisplay`. Xem
     `../architecture/solution.md` section 1 Key Discovery 2 cho bảng đầy đủ.
   - **Ranh giới sổ tay**: chỉ đọc
     `notebookBoundaryTerms[NotebookBoundaryRule.frequencyProbe]`. **Không** gọi
     `notebookBoundaryHitsIn` nguyên khối — nó gộp cả `judgementProbe`, vốn
     chứa `tính cách` / `điểm mạnh` / `điểm yếu`, tức chính chủ đề hợp pháp của
     một ô ăn khớp. Gọi nguyên khối là biến cổng thành bất khả thi.
   - **Id ô khớp thành phần**: `id` phải bằng `'${self_id}__${partner_id}'`.
4. Soạn ba JSON trục nhỏ. Dùng giá trị trục thật (ví dụ `aries`/`taurus` và
   `intj`/`enfp`) để P5/P6 chỉ **thêm**, không phải viết lại. Nội dung bốn ô
   phải là văn thật đạt luật, không phải `lorem`.
5. Viết test cổng: nạp ba file bằng `rootBundle`-free I/O (đọc thẳng từ đĩa như
   test cổng của gift_ideas), gọi `validateCompatPacks`, khẳng định danh sách
   vi phạm **rỗng**, và in ra chi tiết khi không rỗng. Thêm các ca âm tính dựng
   gói trong bộ nhớ để chứng minh từng luật **thật sự bắt được** vi phạm — một
   cổng chỉ có ca dương tính là một cổng chưa được chứng minh.

## 7. Test Scope

- `mobile/test/features/compatibility_lookup/compat_content_gate_test.dart`

Chạy: `flutter test test/features/compatibility_lookup/compat_content_gate_test.dart`
với `cwd` là `<worktree>/mobile`.

Ngoài phạm vi: e2e, chạy trên thiết bị, kịch bản đầu-cuối, script gate ở gốc
repo, runtime startup smoke.

## 8. Build Gate

`flutter build apk --debug` (nguồn: runtime registry `mobile-app.buildCommand`).
Chạy trực tiếp, **không nối ống**, `cwd` là `<worktree>/mobile`.

## 9. Runtime Startup Gate

NOT_APPLICABLE.

## 10. Completion Criteria

- Sáu file trong Write Scope tồn tại và biên dịch.
- Test cổng xanh, gồm cả các ca âm tính.
- Không có chuỗi `12`, `16`, `144`, `256` nào trong file `lib/` của phase này.
- Build gate xanh.

## 11. Stop Rule

Dừng với `DATA_GATE_BLOCKED` nếu không tìm được cách để cổng vừa chặn lời khen
suông vừa cho nội dung hợp lệ đi qua — chẳng hạn khi denylist sẵn có bắn nhầm
vào từ vựng ăn khớp hợp pháp. Báo đúng từ nào, luật nào, ô nào. **Không** nới
luật, **không** chép denylist ra bản thứ hai để sửa riêng.
