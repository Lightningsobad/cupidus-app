# Story Requirements: STORY-003 Nhật ký riêng

- Requirement: REQ-016
- Story: STORY-003
- Complexity: standard
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: NONE (giao song song được với STORY-001)
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules`, `## Out of Scope`,
  `## Open Questions`; `../../requirements/requirements.md` →
  `## Open Question Triage`, `## Scope Decision`, `## Story Order And Dependencies`

## Business Outcome

Người dùng ghi lại được cảm xúc và ảnh của riêng mình, **chắc chắn không ai đọc
được**, để họ dám viết thật.

Đây là một trong bốn màn KHO của chặng 1 và là cửa ra "hướng vào trong" (J8) mà
STORY-007 (lời cảm ơn sau hẹn) và STORY-008 (kịch bản buổi hẹn) sẽ dùng lại. Ở
story này, nhật ký đứng độc lập hoàn toàn.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Nhật ký viết cho chính người dùng. Không AC nào cần người kia
tham gia, biết tới, hay tồn tại trong hệ thống.

## Scope

### In Scope

1. Màn nhật ký độc lập: viết, sửa, xoá một mục (chữ + ảnh).
2. Riêng tư mặc định (R-12): không chế độ chia sẻ, không nút xuất, không liên
   kết ra ngoài.
3. Xoá được: xoá từng mục và xoá toàn bộ nhật ký, không giữ bản sao ẩn.
4. Điểm nhận nội dung để STORY-007/STORY-008 đẩy sang sau này (story này giao
   **màn và điểm nhận**, không giao cửa vào của các story đó).
5. Trạng thái rỗng trung tính, không thúc giục, không streak.

### Out of Scope

- Nhắc nhở "23h vừa về tới nhà chưa?" (SB-85) — STORY-012.
- Ký ức/ảnh gắn với thẻ *Đã thành kỷ niệm* — thuộc tính thẻ ở STORY-001.
- Đính ảnh từ nhật ký vào lời cảm ơn — STORY-007.
- Cửa ra "ghi vào nhật ký" từ kịch bản buổi hẹn — STORY-008.
- Mọi hình thức chia sẻ, xuất file, hoặc backup ra ngoài thiết bị mà người dùng
  không chủ động bật.
- **Sổ tay người yêu và hồ sơ kỹ năng** — STORY-004. Nhật ký **không phải** sổ
  tay; hai thực thể tách rời (xem BR-3).

## Acceptance Criteria

### Nhóm A — Viết và giữ

**AC-1.** Given người dùng mở màn nhật ký lần đầu, when màn hiện ra, then trạng
thái rỗng **trung tính**: không mục tiêu viết hằng ngày, không streak, không đếm
chuỗi ngày, không huy hiệu, không câu thúc giục viết (R-1 cấm (f)).

**AC-2.** Given người dùng viết một mục nhật ký kèm một hoặc nhiều ảnh, when họ
lưu, then mục được giữ lại và chỉ hiển thị trong màn nhật ký của chính họ.

**AC-3.** Given một mục đã lưu, when người dùng mở lại và sửa nội dung chữ hoặc
ảnh, then bản sửa được lưu và thay thế bản cũ, không tạo bản sao song song.

**AC-4.** Given người dùng viết một mục, when họ lưu, then app **không** yêu cầu
gắn mục đó với một thẻ, một người, hay một sự kiện nào — nhật ký viết được mà
không cần bất kỳ dữ liệu nào khác trong app.

**AC-5.** Given người dùng có nhiều mục, when họ xem màn nhật ký, then các mục
liệt kê theo thời gian và mở lại đọc được toàn văn.

### Nhóm B — Riêng tư mặc định (R-12)

**AC-6.** Given một mục nhật ký bất kỳ, when người dùng tìm cách chia sẻ hoặc
xuất nó, then app **không** cung cấp bất kỳ chức năng chia sẻ, xuất file, sao
chép ra Share Sheet, hay tạo link nào.

**AC-7.** Given toàn bộ nội dung nhật ký, when bất kỳ bề mặt nào khác của app
hiển thị (màn danh sách thẻ, lời mời, widget, chân dung, bảng tra), then
**không** bề mặt nào trong số đó hiển thị, trích, xem trước, hay tham chiếu nội
dung nhật ký.

**AC-8.** Given một mục nhật ký được lưu, when nó được lưu, then mặc định là
riêng tư — **không** có công tắc chuyển sang chế độ công khai/chia sẻ ở bất kỳ
đâu trong app.

**AC-9.** Given app có bất kỳ cơ chế sao lưu hoặc đồng bộ nào, when nhật ký được
xử lý, then nội dung nhật ký và ảnh đính kèm **chỉ** rời thiết bị khi người dùng
chủ động bật, và mặc định là **không** bật.

**AC-10.** Given nội dung nhật ký, when app xử lý nó ở bất kỳ đường đi nào, then
nội dung **không** được gửi tới dịch vụ AI, API phân tích, hay dịch vụ bên thứ
ba nào (R-7 và R-12 cộng lại).

### Nhóm C — Xoá sạch

**AC-11.** Given một mục nhật ký, when người dùng xoá và xác nhận, then mục biến
mất và **không truy hồi được** từ trong app.

**AC-12.** Given người dùng chọn "xoá toàn bộ nhật ký", when họ xác nhận, then
**toàn bộ** mục và **toàn bộ ảnh đính kèm** bị xoá trong **một thao tác**.

**AC-13.** Given người dùng đã xoá một mục hoặc toàn bộ nhật ký, when việc xoá
hoàn tất, then app **không** giữ bản sao ẩn: không thùng rác ẩn, không cache
nội dung, không bản nháp còn sót, không file ảnh mồ côi trên thiết bị.

**AC-14.** Given người dùng xoá nhật ký, when app phản hồi, then app **không**
kịch tính hoá, **không** trách móc, **không** hỏi lý do, và không cố giữ chân
người dùng lại (R-1c/R-1d).

### Nhóm D — Ranh giới với các story khác

**AC-15.** Given STORY-007 và STORY-008 sau này cần đẩy nội dung vào nhật ký,
when story này được giao, then nó cung cấp một **điểm nhận** để tạo một mục mới
từ nội dung bên ngoài, nhưng **không** ship cửa vào nào từ hai story đó.

**AC-16.** Given người dùng chỉ cài chặng 1 với đúng story này, when họ dùng màn
nhật ký, then **mọi** AC ở trên vẫn đạt được mà không cần STORY-001 hay bất kỳ
story nào khác tồn tại.

**AC-17.** Given nhật ký và sổ tay người yêu cùng tồn tại sau khi STORY-004
ship, when người dùng dùng app, then chúng là **hai thực thể tách rời**: nhật ký
là cảm xúc riêng tư viết cho chính mình, sổ tay là sở thích và sự kiện của người
kia. Story này **không** trộn hai thứ và không tạo bề mặt chung.

## Business Rules

- **BR-1 (R-12 — riêng tư mặc định, xoá được).** Đây là ràng buộc sản phẩm cứng,
  không phải tuỳ chọn cấu hình. Không tồn tại đường nào biến một mục nhật ký
  thành nội dung chia sẻ được.
- **BR-2 (không có chức năng xuất/chia sẻ).** Vắng mặt tính năng là **yêu cầu**,
  không phải thiếu sót. Thêm nút chia sẻ sau này là vi phạm requirement.
- **BR-3 (R-1f — ranh giới với sổ tay).** R-1f là luật của **sổ tay** (chỉ ghi
  sở thích và sự kiện, không ghi đánh giá con người, không có xuất/chia sẻ).
  Nhật ký là thực thể khác: nó **được** chứa cảm xúc và đánh giá riêng tư của
  người dùng, vì nó viết cho chính người dùng và không bao giờ ra khỏi máy.
  **Không gộp luật của hai thực thể.** Điểm chung duy nhất là cả hai đều không
  có chức năng xuất/chia sẻ.
- **BR-4 (R-1 cấm (f) — không streak).** Không streak, không mục tiêu viết hằng
  ngày, không chuỗi ngày, không huy hiệu, không bảng xếp hạng. Đây là bề mặt dễ
  bị thêm "cho vui" nhất trong cả requirement.
- **BR-5 (R-1b).** Nhật ký **không** ghi và **không** suy ra bất kỳ đại lượng
  hành vi nào của người kia. Người dùng tự viết gì là quyền của họ; app không tự
  sinh, không tự chèn, không tự tổng hợp nhận định về người kia vào nhật ký.
- **BR-6 (SC-1' — một kho).** Nhật ký **không** cạnh tranh với kho thẻ của màn
  (1). Nó là màn KHO thứ hai với mục đích khác (cảm xúc riêng tư, không phải ý
  tưởng hoạt động), và không được biến thành danh sách việc-cần-làm thứ hai.
- **BR-7 (SC-5 — không ngõ cụt).** Màn nhật ký, kể cả ở trạng thái rỗng, luôn có
  đường đi tiếp: viết một mục, hoặc rời màn.
- **BR-8 (R-7 — không AI ở runtime).** Không gợi ý viết bằng AI, không tóm tắt
  tâm trạng, không phân tích cảm xúc. Nếu có gợi ý mồi viết, nó là preset tĩnh.
- **BR-9 (R-14 — không paywall lõi).** Nhật ký là phần lõi; không giới hạn số
  mục, không giới hạn ảnh sau paywall.
- **BR-10 (R-10 — định vị).** Giọng của màn là trung tính, riêng tư. Không giọng
  bói toán, không giọng huấn luyện viên tình cảm.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** NO — màn mới, độc lập.
- **Điểm vào:** đường vào **trực tiếp từ menu chính** (nhóm KHO, màn (4)).
- **Không phải màn khoá vị trí.** R-13 chỉ áp cho STORY-009 và STORY-010.
- **Hợp đồng cho story sau:** điểm nhận tạo-mục-từ-nội-dung-ngoài là bề mặt mà
  STORY-007 và STORY-008 sẽ gọi. Chúng chỉ **thêm cửa vào**, không sửa hành vi
  của story này (`../../requirements/requirements.md` →
  `## Story Order And Dependencies`).
- **Tích hợp bên ngoài:** chỉ **image picker của OS** để đính ảnh. Không dịch vụ
  lưu trữ ngoài, không AI, không API phân tích, không đồng bộ mặc định.
- **Song song hoá:** không phụ thuộc STORY-001, giao song song được.

## Open Question Impact

### Scope Items BLOCKED in this story

- **KHÔNG CÓ.** Story này không có câu hỏi mở nào. Không hạng mục nào trong phạm
  vi bị chặn; story vào delivery ngay được.
  - OQ-3 (duyệt kho nội dung preset) **không** áp cho story này: nhật ký không
    có kho preset nội dung. Nếu implementation muốn thêm "câu mồi viết" dạng
    preset, hạng mục đó nằm **ngoài phạm vi** story này chứ không phải bị OQ-3
    chặn.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). **Vẫn không chạm story này**: nhật ký không có kho preset nội dung,
  nên ràng buộc R-15 (schema + id bền, N là thuộc tính dữ liệu, cổng nhập chạy
  được) không thêm phạm vi cho story này. Ghi nhận để truy vết; xử lý ở
  STORY-002 và các story có preset.
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03). Story này không chịu tải định
  vị "kho tài sản"; ba story chịu tải là STORY-001, 012, 013.
- **OQ-2 (một ngăn hay nhiều ngăn) — ĐÓNG ở tầng sản phẩm** và chỉ áp cho màn
  (1). Nhật ký không có ngăn lọc trong phạm vi story này.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này.
- **Chi tiết trình bày** (bố cục danh sách mục, cách đính nhiều ảnh, vị trí nút
  "xoá toàn bộ" và mức độ ma sát của bước xác nhận) — giao **UI/UX Designer
  trong phạm vi story này**. Là quyết định UX, không phải câu hỏi sản phẩm còn
  mở. Ràng buộc sản phẩm duy nhất: xoá toàn bộ phải hoàn tất trong **một thao
  tác** (AC-12).
- **Chặng 1.5, feed tin thật, Zalo Mini App, thương mại quà, J7** — binding out
  of scope ở tầng requirement, không chạm story này.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1 | R-1 cấm (f) — không streak |
| AC-2..AC-5 | Màn (4) nhóm KHO, viết/sửa độc lập |
| AC-6..AC-10 | R-12 riêng-tư-mặc-định, R-7 không AI ở runtime |
| AC-11..AC-14 | R-12 xoá được, R-1c/R-1d không kịch tính hoá |
| AC-15..AC-16 | SC-2 cửa ra J8, cổng cứng |
| AC-17 | R-1f — ranh giới nhật ký / sổ tay |
