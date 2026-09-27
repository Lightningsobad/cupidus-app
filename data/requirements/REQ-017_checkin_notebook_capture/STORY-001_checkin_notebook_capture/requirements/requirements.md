# Story Requirements: REQ-017 STORY-001 Ghi điều mới biết về người ấy vào sổ tay ngay trên màn check-in 23h

## Source Artifacts

- Story: `data/requirements/REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture/story_master.md`,
  `story_brief.md`.
- Breakdown cấp requirement: `data/requirements/REQ-017_checkin_notebook_capture/requirements/requirements.md`
  → `## User Decisions (binding)`, `## Open Question Triage`, `### Business Rules And Guardrails`.
- Màn check-in: REQ-016 `STORY-012_phase_status_and_widget/requirements/requirements.md`
  → AC-16 (vá 2026-09-17, ghi chú chip "+ ghi vào sổ tay"), AC-17, AC-19, BR-11, BR-12.
- Sổ tay + hỏi-tại-chỗ: REQ-016 `STORY-004_relationship_notebook_and_gift_ideas/requirements/requirements.md`
  → AC-1..AC-9, AC-36, BR-1..BR-4, BR-15..BR-18.
- `data/intake/bootstrap/conflicts_open_questions.md`: không có mục nào về
  REQ-017, sổ tay hay check-in.

## Actor And Outcome

- Actor: người dùng solo chặng 1, vừa về sau một buổi hẹn, đang ở màn check-in
  modal 23h.
- Outcome: ghi một điều mới biết về người ấy (một sở thích hoặc một sự kiện/dịp)
  mà không phải mở màn khác; sau đó thấy nó trong Sổ tay, biết nó đến từ buổi
  hẹn nào, sửa/xoá được, và các gợi ý đọc sổ tay dùng được nó.

## Acceptance Criteria

Số AC trùng với danh sách trong `story_master.md` (AC-N ở đây = mục N ở đó).
AC-16 và AC-17 là bổ sung của bước story-requirements.

### Nhóm A — Lời hỏi trên màn check-in

**AC-1.** Given màn check-in 23h mở cho buổi hẹn hôm nay, when màn hiện ra, then
có một lời hỏi-tại-chỗ **tuỳ chọn** "Hôm nay biết thêm gì về người ấy?" đứng
**sau** phần ảnh và câu nhật ký, không phải thứ đầu tiên người dùng thấy. Nội dung
thông báo 23h và câu hỏi chính của màn vẫn hướng vào người dùng như STORY-012
AC-19. (Diễn giải của OQ-1, user chấp nhận 2026-09-27, xem BR-8.)

**AC-2.** Given người dùng để trống lời hỏi, when họ lưu hoặc đóng check-in, then
ảnh và câu nhật ký lưu như trước, không có mục sổ tay nào được tạo, app không
trách, và không hỏi lại về buổi hẹn đó (STORY-012 AC-17, STORY-004 AC-3).

**AC-3.** Given người dùng gõ một ý vào lời hỏi, when họ chuẩn bị lưu, then họ phải
tự chọn đúng một loại — **sở thích** hoặc **sự kiện/dịp** — và app không tự đoán
loại từ chữ đã gõ, không chọn sẵn loại nào. Không có loại thứ ba, không có trường
đánh giá, nhận xét hay chấm điểm (R-1f, STORY-004 AC-6).

**AC-6.** Given người dùng viết câu nhật ký trên check-in, when họ lưu, then câu đó
**không bao giờ** xuất hiện trong sổ tay: ô hỏi bắt đầu trống, không được điền
sẵn, không có đề xuất mục nào dựng từ chữ của câu nhật ký (O-1a loại, O-1c hoãn).

**AC-7.** Given màn check-in trước khi lưu, when người dùng nhìn màn, then họ phân
biệt được rõ phần nào lưu vào nhật ký (chỉ mình đọc) và phần nào lưu vào sổ tay;
hai chip mô tả của STORY-012 AC-16 giữ nguyên nghĩa và vẫn chỉ nói về câu nhật ký.

**AC-16.** Given người dùng đã gõ một ý nhưng chưa chọn loại, when họ lưu check-in,
then ý đó **không** được ghi thành mục sổ tay khi chưa có loại; app cho họ chọn
loại hoặc bỏ ý đó, và việc này **không bao giờ** chặn việc lưu ảnh và câu nhật ký.
App không tự gán loại để "cứu" ý đó.

**AC-17.** Given lời hỏi trên check-in, when người dùng trả lời, then app chỉ xin
**một ý + một loại**; không hỏi thêm ngày, chi tiết, hay câu thứ hai trong cùng
lần check-in (STORY-004 BR-2). Ý chỉ gồm khoảng trắng được coi là để trống
(AC-2). Giới hạn độ dài và luật hợp lệ của nội dung giống mục thêm bằng
"+ tự thêm" ở màn Sổ tay. Mục "sự kiện/dịp" ghi từ check-in được phép không có
ngày; người dùng bổ sung ngày hay chi tiết bằng thao tác sửa sẵn có ở màn Sổ tay.

### Nhóm B — Ghi và lưu

**AC-8.** Given một lần check-in, when người dùng lưu, then lần check-in đó tạo
**tối đa một** mục sổ tay; lưu lặp lại hay chạm hai lần không tạo mục trùng.

**AC-12.** Given phần ghi sổ tay thất bại khi lưu check-in, when lỗi xảy ra, then
người dùng thấy rõ ý đó chưa được ghi và thử lại được; ảnh và câu nhật ký đã lưu
không bị mất và không bị ghi đôi; thử lại thành công vẫn chỉ tạo một mục (AC-8).

**AC-9.** Given tên buổi hẹn không đọc được lúc check-in, hoặc thẻ sau đó bị xoá
hay bị đóng ngăn (STORY-013), when người dùng lưu hoặc xem mục, then lưu không bị
chặn và nhãn xuất xứ suy biến thành "từ một buổi hẹn"; mục vẫn còn và vẫn
sửa/xoá được. Check-in không ghi gì vào thẻ và không đổi trạng thái thẻ (BR-6,
STORY-012 BR-12).

**AC-11.** Given người dùng xoá một mục nhật ký hoặc xoá toàn bộ nhật ký, when xoá
xong, then mục sổ tay ghi từ cùng lần check-in vẫn còn; xoá mục sổ tay không đụng
nhật ký hay ảnh. Ảnh check-in không bao giờ gắn vào mục sổ tay.

### Nhóm C — Màn Sổ tay sẵn có

**AC-4.** Given người dùng đã lưu check-in có một ý kèm loại, when họ mở màn Sổ
tay, then mục nằm đúng nhóm "Sở thích" hoặc "Sự kiện" (loại "sự kiện/dịp" ánh xạ
vào nhóm "Sự kiện" có sẵn), mang nhãn xuất xứ "từ buổi hẹn <tên thẻ>", và sửa/xoá
được bằng đúng thao tác của mọi mục khác, không qua màn mới.

**AC-5.** Given người dùng sửa nội dung hoặc đổi loại của một mục từ check-in, when
lưu sửa, then thay đổi có hiệu lực ngay và nhãn xuất xứ giữ nguyên; xoá mục thì mục
biến mất, không kịch tính hoá (STORY-004 AC-9).

**AC-15.** Given một mục sổ tay đến từ check-in, when người dùng tìm cách đưa nó
ra ngoài, then không có chức năng xuất/chia sẻ nào (R-1f, STORY-004 AC-7).

### Nhóm D — Người đọc sổ tay và bề mặt công cộng

**AC-10.** Given một mục sổ tay đến từ check-in, when gợi ý quà (hoặc mồi chuyện,
kịch bản buổi hẹn) đọc sổ tay, then mục đó được dùng như mọi mục sổ tay khác; ví
dụ gợi ý quà hiện "từ sổ tay: <sở thích>" khi khớp. Không bên đọc nào phải biết
riêng về xuất xứ để dùng mục.

**AC-13.** Given widget hoặc thông báo của STORY-012, when chúng hiển thị sau một
lần check-in có ghi sổ tay, then không có nội dung sổ tay nào xuất hiện ở đó, kể
cả tên mục hay nhãn xuất xứ (STORY-012 BR-11).

### Nhóm E — Nội dung là dữ liệu

**AC-14.** Given câu hỏi "Hôm nay biết thêm gì về người ấy?" và nhãn xuất xứ (cả
dạng "từ buổi hẹn <tên thẻ>" và dạng suy biến "từ một buổi hẹn"), when bản dựng
nạp nội dung, then chúng là mục dữ liệu có id bền trong gói nội dung hỏi-tại-chỗ
và đi qua cổng nhập của STORY-004 AC-36; một câu hỏi vi phạm R-1f ở tầng đầu vào
làm hỏng bản dựng; không có chuỗi nội dung cứng trong code (R-15a/c).

## Business Rules

BR-1..BR-9 lấy nguyên từ `../../requirements/requirements.md`
`### Business Rules And Guardrails`. BR-10..BR-12 là luật cấp story.

- **BR-1 (R-1f).** Mục chỉ là sở thích hoặc sự kiện/dịp. Không trường đánh giá
  con người, không nhận xét, không xuất/chia sẻ. → AC-3, AC-15.
- **BR-2 (SC-3 / STORY-004 BR-1..BR-3).** Lời hỏi là hỏi-tại-chỗ, tuỳ chọn, một
  mục một lần. Bỏ qua không chặn gì, không hỏi lại, không trách. → AC-1, AC-2,
  AC-8, AC-17.
- **BR-3 (O-1a, riêng tư nhật ký).** Câu nhật ký không bao giờ đi vào sổ tay dưới
  bất kỳ hình thức nào: không sao chép, không điền sẵn, không trích đoạn. Xoá nhật
  ký không đụng sổ tay và ngược lại. → AC-6, AC-7, AC-11.
- **BR-4 (R-7, O-1c).** Tất định, không AI, không API ngoài. App không suy ra loại
  hay nội dung mục từ chữ người dùng gõ; người dùng tự chọn loại. → AC-3, AC-6,
  AC-16.
- **BR-5 (R-15).** Câu hỏi và nhãn xuất xứ là dữ liệu có id bền trong gói nội dung
  hỏi-tại-chỗ, qua cổng nhập STORY-004 AC-36. Không chuỗi cứng trong code. → AC-14.
- **BR-6 (STORY-012 BR-12).** Thẻ chỉ đọc. Check-in chỉ đọc tên thẻ để làm xuất
  xứ; không thêm trường thẻ, không đổi trạng thái thẻ. Đọc không được thì suy
  biến, không chặn. → AC-9.
- **BR-7 (STORY-012 BR-11).** Widget và thông báo không bao giờ hiện nội dung sổ
  tay, kể cả mục vừa ghi từ check-in. → AC-13.
- **BR-8 (STORY-012 AC-19, OQ-1).** Thông báo 23h và câu hỏi chính của màn giữ
  hướng vào trong. Lời hỏi O-1b là khối phụ, tuỳ chọn, đứng sau ảnh + nhật ký,
  chỉ xin sở thích/sự kiện, không bao giờ xin đánh giá. → AC-1. User đã xác nhận
  2026-09-27 (OQ-1 RESOLVED, `req_master.md` `## User Decisions`).
- **BR-9 (O-3).** Không màn mới, không route mới. Sửa/xoá dùng đúng thao tác sẵn
  có của màn Sổ tay. → AC-4, AC-5.
- **BR-10 (tách lưu).** Việc ghi mục sổ tay không bao giờ là điều kiện để lưu ảnh
  và câu nhật ký. Ý chưa đủ (chưa có loại) hay ghi lỗi chỉ ảnh hưởng phần sổ tay,
  và người dùng luôn biết phần đó đã ghi hay chưa. → AC-12, AC-16.
- **BR-11 (xuất xứ là thuộc tính thêm).** Mục từ check-in là mục sổ tay bình
  thường (giả định A-4): chịu mọi luật STORY-004 và STORY-013. Xuất xứ là thuộc
  tính bổ sung, không phải loại mục mới, không làm đổi nghĩa phần dữ liệu sổ tay
  mà STORY-005/008/009/010 đang đọc (STORY-004 BR-15). Nhãn xuất xứ không bao
  giờ là chỉ số hay tín hiệu chất lượng. → AC-4, AC-5, AC-10.
- **BR-12 (một lần check-in, tối đa một mục).** Tính duy nhất gắn với lần
  check-in, không gắn với nội dung: hai lần check-in khác nhau ghi cùng một sở
  thích thì là hai mục hợp lệ. → AC-8, AC-12.

## Assumptions

- A-1..A-4: như `../../requirements/requirements.md` `### Giả định của PO`, đã
  viết thành AC-4, AC-8, AC-9 và Out of Scope.
- A-5 (user xác nhận 2026-09-27, `req_master.md` `## User Decisions`): check-in
  chỉ xin một ý + một loại; ngày và chi tiết của mục "sự kiện/dịp" để người dùng
  bổ sung ở màn Sổ tay (AC-17). Lý do: STORY-004 BR-2 cấm hỏi hai trường trong
  cùng một lần cần.

## System Integration And Discoverability

- UI-facing story: YES.
- Existing user-visible surface: YES.
  - Màn check-in modal 23h (REQ-016 STORY-012 AC-16). Chỉ tới được từ nhắc 23h;
    không phải đích điều hướng. Lời hỏi mới là một khối trên màn này.
  - Màn Sổ tay người yêu — màn (2) (REQ-016 STORY-004), vào qua đường sẵn có
    (nhóm KHO / tab Sổ tay). Nhãn xuất xứ hiện trên mục trong danh sách này.
- Điểm vào mới: không. Route mới: không. Direct URL: N/A.
- Discoverability: người dùng gặp lời hỏi ở đúng lúc họ mở check-in từ nhắc 23h;
  họ gặp mục đã ghi ở màn Sổ tay, nơi nó mang nhãn xuất xứ để họ nhận ra nó.
  Không có hướng dẫn, badge hay thông báo nào báo "đã lưu vào sổ tay" ngoài màn
  check-in (BR-7, STORY-004 AC-1 không toast "đã lưu vào hồ sơ").
- Người đọc dữ liệu sổ tay chịu ảnh hưởng: gợi ý quà, mồi chuyện, kịch bản buổi
  hẹn (REQ-016 STORY-004/008/009/010). Họ phải tiếp tục chạy với mục có hoặc
  không có xuất xứ (AC-10, BR-11).
- Bề mặt công cộng phải giữ nguyên: widget và thông báo STORY-012 (AC-13).
- Ghi chú cho Tech Lead: sổ tay hiện có một trường nguồn nội bộ mà STORY-004
  giữ **không hiển thị**. Nhãn xuất xứ của story này **được hiển thị**, nên đây là
  một nhu cầu hiển thị mới; cách mô hình hoá thuộc Tech Lead, miễn giữ BR-11.
- Implementation Lane: mobile-only. Cả hai bề mặt và kho sổ tay đều nằm trong
  app Flutter (`mobile/`); không có backend hay hạ tầng nào đọc/ghi sổ tay.

## Dependencies

- Trong REQ-017: NONE.
- Ngoài REQ-017: REQ-016 STORY-003 (nhật ký), STORY-004 (sổ tay + hỏi-tại-chỗ +
  cổng nhập), STORY-012 (màn check-in), STORY-013 (đóng ngăn, chỉ cho AC-9). Tất
  cả DONE.
- Không đòi story tương lai nào để quan sát được outcome.

## Open Question Impact

### Scope Items BLOCKED in this story

- Không có. Không phạm vi nào của story này bị chặn bởi câu hỏi mở.

### Scope Items NOT BLOCKED in this story

- Toàn bộ AC-1..AC-17 và BR-1..BR-12, kể cả câu chữ và vị trí khối hỏi của AC-1
  (phần vị trí của BR-8).
- **OQ-1** (lời hỏi O-1b về người kia so với REQ-016 STORY-012 AC-19 "không hỏi
  về người kia"): RESOLVED 2026-09-27. User chấp nhận diễn giải BR-8/AC-1 như
  viết (nguồn: `req_master.md` `## User Decisions`).
- **OQ-2** (ưu tiên): RESOLVED 2026-09-27. Giữ MEDIUM, chạy sau REQ-016 (nguồn:
  `req_master.md` `## User Decisions`).
- **A-5**: CONFIRMED 2026-09-27 (nguồn: `req_master.md` `## User Decisions`) →
  AC-17 giữ nguyên.
- Giả định A-1..A-4: không chặn; user ghi đè được, khi đó sửa AC tương ứng
  (A-1 → AC-8, A-2 → AC-9, A-3 → AC-4, A-4 → BR-11).
- Ghi chú theo dõi ngoài REQ-017 (không chặn): REQ-016 STORY-012 AC-19 cần một
  bản vá truy vết `ac-patch` ghi nhận diễn giải BR-8. Helen-SC phụ trách; PO
  không vá REQ-016.
