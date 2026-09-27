# Story Master: STORY-001 Ghi điều mới biết về người ấy vào sổ tay ngay trên màn check-in 23h

Status: TODO
Complexity: standard
Story-Class: standard
Implementation Lane: shared (mobile-only trên thực tế; màn check-in REQ-016 STORY-012, màn Sổ tay REQ-016 STORY-004 và kho sổ tay đều nằm trong app Flutter `mobile/`; không có lane backend nào chạy trong story này, không có backend đọc/ghi sổ tay)
Requirement: REQ-017
Screen: màn check-in modal 23h (REQ-016 STORY-012 AC-16) · Sổ tay người yêu — màn (2) (REQ-016 STORY-004). Không màn mới.
Design-Surface: cupid-ch-ng-1
Design-Screen: 23h-vua-ve-j8 (khối hỏi phụ trên màn check-in, surface cupid-ch-ng-1 theo REQ-016 STORY-012; UI/UX xác nhận), 2-so-tay-nguoi-yeu (nhãn xuất xứ trên màn Sổ tay, canvas id từ REQ-016 STORY-004 story_master.md; UI/UX xác nhận)
Spec reference: `data/requirements/REQ-017_checkin_notebook_capture/requirements/requirements.md`

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md` (story-level; breakdown requirement-level ở `../requirements/requirements.md`)
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md` + `coding-plan/` (master-plan, coding-agent-guide, P1-P4)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE trong REQ-017.
- Ngoài requirement: REQ-016 STORY-003, STORY-004, STORY-012 (đều DONE).

## User Story
Là người vừa về sau một buổi hẹn, tôi muốn ghi lại ngay trên màn check-in một
điều mới biết về người ấy (một sở thích hay một sự kiện/dịp), để nó nằm sẵn
trong sổ tay mà tôi không phải mở màn khác, và để các gợi ý sau này hợp với
người ấy hơn.

## In Scope
1. Trên màn check-in 23h, một lời hỏi-tại-chỗ **tuỳ chọn** "Hôm nay biết thêm gì
   về người ấy?" (O-1b), là khối phụ đứng sau phần ảnh và câu nhật ký.
2. Người dùng gõ một ý ngắn và **tự chọn** loại: sở thích hoặc sự kiện/dịp.
3. Khi lưu check-in, ý đó thành **một** mục sổ tay STORY-004 mang xuất xứ "từ
   buổi hẹn <tên thẻ>" (O-2).
4. Trong màn Sổ tay sẵn có: mục hiện đúng nhóm, có nhãn xuất xứ, sửa/xoá bằng
   đúng thao tác của mọi mục khác (O-3).
5. Mục từ check-in được gợi ý quà, mồi chuyện, kịch bản buổi hẹn dùng như mọi mục
   sổ tay khác.
6. Câu hỏi và nhãn xuất xứ là dữ liệu có id bền, qua cổng nhập R-15c.

## Out of Scope
- Sao chép, trích, hay điền sẵn câu nhật ký sang sổ tay (O-1a, loại).
- Tự đề xuất mục hay tự đoán loại mục từ chữ người dùng gõ (O-1c, hoãn).
- Màn mới, route mới; mở lại check-in sau khi đóng; sửa mục trên màn check-in.
- Ghi vào hồ sơ kỹ năng từ check-in.
- Nhiều mục sổ tay trong một lần check-in.
- Lọc/sắp xếp sổ tay theo xuất xứ; xuất xứ cho mục không đến từ check-in.
- Đổi nội dung thông báo 23h, đổi luật không-nhắc-lại (STORY-012 AC-17), đổi thẻ.
- Gắn ảnh check-in vào mục sổ tay.
- Xuất/chia sẻ sổ tay; đánh giá buổi hẹn hay đánh giá người kia.

## Acceptance Criteria
1. Given màn check-in 23h mở cho buổi hẹn hôm nay, when màn hiện ra, then có một
   lời hỏi-tại-chỗ **tuỳ chọn** "Hôm nay biết thêm gì về người ấy?" đứng sau phần
   ảnh và câu nhật ký; thông báo 23h và câu hỏi chính của màn vẫn hướng vào người
   dùng như STORY-012 AC-19 (OQ-1).
2. Given người dùng để trống lời hỏi, when họ lưu hoặc đóng check-in, then ảnh và
   câu nhật ký lưu như trước, không có mục sổ tay nào được tạo, app không trách,
   không hỏi lại về buổi hẹn đó.
3. Given người dùng gõ một ý vào lời hỏi, when họ chuẩn bị lưu, then họ phải tự
   chọn đúng một loại — **sở thích** hoặc **sự kiện/dịp** — và app không tự đoán
   loại từ chữ đã gõ; không có loại thứ ba, không có trường đánh giá hay chấm điểm.
4. Given người dùng đã lưu check-in có một ý kèm loại, when họ mở màn Sổ tay, then
   mục nằm trong đúng nhóm "Sở thích" hoặc "Sự kiện", mang nhãn xuất xứ "từ buổi
   hẹn <tên thẻ>", và sửa/xoá được bằng đúng thao tác của mọi mục khác, không qua
   màn mới.
5. Given người dùng sửa nội dung hoặc đổi loại của một mục từ check-in, when lưu
   sửa, then thay đổi có hiệu lực ngay và nhãn xuất xứ giữ nguyên; xoá mục thì mục
   biến mất, không kịch tính hoá (STORY-004 AC-9).
6. Given người dùng viết câu nhật ký trên check-in, when họ lưu, then câu đó
   **không bao giờ** xuất hiện trong sổ tay: ô hỏi bắt đầu trống, không được điền
   sẵn, không có đề xuất mục nào dựng từ chữ của câu nhật ký.
7. Given màn check-in trước khi lưu, when người dùng nhìn màn, then họ phân biệt
   được rõ phần nào lưu vào nhật ký (chỉ mình đọc) và phần nào lưu vào sổ tay; hai
   chip mô tả của STORY-012 AC-16 giữ nguyên nghĩa.
8. Given một lần check-in, when người dùng lưu, then lần check-in đó tạo **tối
   đa một** mục sổ tay; thao tác lưu lặp lại hay chạm hai lần không tạo mục trùng.
9. Given tên buổi hẹn không đọc được lúc check-in, hoặc thẻ sau đó bị xoá hay
   đóng ngăn, when người dùng lưu hoặc xem mục, then lưu không bị chặn và nhãn xuất
   xứ suy biến thành "từ một buổi hẹn"; mục vẫn còn và vẫn sửa/xoá được. Check-in
   không ghi gì vào thẻ và không đổi trạng thái thẻ (BR-12).
10. Given một mục sổ tay đến từ check-in, when gợi ý quà (hoặc mồi chuyện, kịch
    bản buổi hẹn) đọc sổ tay, then mục đó được dùng như mọi mục sổ tay khác, ví dụ
    gợi ý quà hiện "từ sổ tay: <sở thích>" khi khớp.
11. Given người dùng xoá một mục nhật ký hoặc xoá toàn bộ nhật ký, when xoá xong,
    then mục sổ tay ghi từ cùng lần check-in vẫn còn; và xoá mục sổ tay không đụng
    nhật ký hay ảnh. Ảnh check-in không bao giờ gắn vào mục sổ tay.
12. Given phần ghi sổ tay thất bại khi lưu check-in, when lỗi xảy ra, then người
    dùng thấy rõ ý đó chưa được ghi và có thể thử lại; ảnh và câu nhật ký đã lưu
    không bị mất và không bị ghi đôi.
13. Given widget hoặc thông báo của STORY-012, when chúng hiển thị sau một lần
    check-in có ghi sổ tay, then không có nội dung sổ tay nào xuất hiện ở đó
    (STORY-012 BR-11).
14. Given câu hỏi "Hôm nay biết thêm gì về người ấy?" và nhãn xuất xứ, when bản
    dựng nạp nội dung, then chúng là mục dữ liệu có id bền trong gói nội dung
    hỏi-tại-chỗ và đi qua cổng nhập của STORY-004 AC-36; không có chuỗi cứng trong
    code (R-15a/c).
15. Given một mục sổ tay đến từ check-in, when người dùng tìm cách đưa nó ra ngoài,
    then không có chức năng xuất/chia sẻ nào (R-1f, STORY-004 AC-7).
16. Given người dùng đã gõ một ý nhưng chưa chọn loại, when họ lưu check-in, then
    ý đó không được ghi thành mục sổ tay khi chưa có loại; app cho họ chọn loại
    hoặc bỏ ý đó, và việc này không bao giờ chặn việc lưu ảnh và câu nhật ký.
17. Given lời hỏi trên check-in, when người dùng trả lời, then app chỉ xin một ý +
    một loại, không hỏi thêm ngày/chi tiết/câu thứ hai (STORY-004 BR-2); ý chỉ có
    khoảng trắng coi như để trống; luật hợp lệ nội dung giống "+ tự thêm"; ngày
    và chi tiết bổ sung ở màn Sổ tay.

## Business Rules
- BR-1..BR-9 của `../requirements/requirements.md` áp nguyên cho story này.
- BR-10 (tách lưu), BR-11 (xuất xứ là thuộc tính thêm), BR-12 (tối đa một mục
  mỗi lần check-in): xem `requirements/requirements.md` `## Business Rules`.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — màn check-in modal 23h (REQ-016 STORY-012)
  và màn Sổ tay (REQ-016 STORY-004).
- Điểm vào: không thêm điểm vào nào. Lời hỏi được phát hiện trên màn check-in,
  vốn chỉ tới được từ nhắc 23h. Mục đã ghi được thấy ở màn Sổ tay qua đường vào
  sẵn có (nhóm KHO / tab Sổ tay). Direct URL: N/A.

## Dependencies
- Depends on: NONE trong REQ-017; REQ-016 STORY-003, STORY-004, STORY-012 (DONE).
- Không yêu cầu story tương lai: xác nhận.

## Open Question Impact

### Scope Items BLOCKED in this story
- Không có. Không phạm vi nào của story này bị chặn bởi câu hỏi mở.

### Scope Items NOT BLOCKED in this story
- Toàn bộ AC1-17, kể cả câu chữ/vị trí khối hỏi của AC1.
- OQ-1 (STORY-012 AC-19 so với lời hỏi về người ấy): RESOLVED 2026-09-27, user
  chấp nhận diễn giải BR-8/AC1 như viết (nguồn: `../req_master.md`
  `## User Decisions`).
- OQ-2 (ưu tiên): RESOLVED 2026-09-27, giữ MEDIUM, chạy sau REQ-016 (cùng nguồn).
- A-5 (chỉ một ý + một loại, ngày/chi tiết bổ sung ở Sổ tay): CONFIRMED
  2026-09-27 (cùng nguồn), viết thành AC17.
- Giả định A-1..A-4 trong `../requirements/requirements.md` đã được viết thành
  AC4, AC8, AC9 và Out of Scope. User ghi đè được, không chặn.
- Ghi chú theo dõi ngoài REQ-017 (không chặn): REQ-016 STORY-012 AC-19 cần bản
  vá truy vết `ac-patch`; Helen-SC phụ trách.
