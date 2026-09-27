# Requirement Breakdown: REQ-017 Ghi vào sổ tay từ màn check-in 23h

## Source Artifacts

- Requirement master:
  `data/requirements/REQ-017_checkin_notebook_capture/req_master.md`
  (`## Story Seeds`, `## Brainstorm Handoff Context`).
- Ý tưởng gốc:
  `data/brainstorms/IDEA-20260925-001_checkin-to-notebook-capture/development.md`
  → `## Current Snapshot`, `## Convergence Notes`.
- Luật kế thừa: `data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md`
  → R-1f (mục 5), R-7 (mục 7 "Không AI ở runtime"), R-15 (mục 15); SC-3 (seed
  "Sổ tay người yêu" và STORY-004 BR-1).
- Màn check-in: REQ-016 `STORY-012_phase_status_and_widget/requirements/requirements.md`
  → AC-16 (bản vá D-6 ngày 2026-09-17 và ghi chú 2026-09-25), AC-17, AC-18, AC-19,
  BR-11, BR-12.
- Sổ tay + hỏi-tại-chỗ: REQ-016 `STORY-004_relationship_notebook_and_gift_ideas/requirements/requirements.md`
  → AC-1..AC-9, AC-36, BR-1..BR-4, BR-15..BR-18; `ux/uiux-spec.md` Phần B.
- Ranh giới riêng tư nhật ký: REQ-016 `STORY-003_private_journal/story_master.md`
  → In Scope 2-3, AC-3..AC-5.
- `data/intake/bootstrap/conflicts_open_questions.md`: không có mục nào liên quan
  tới REQ-017, sổ tay hay check-in.

## Context Summary

- Người dùng: người dùng solo chặng 1 (đã có một "mối" cụ thể, người kia chưa
  cài app), ngay sau một buổi hẹn.
- Vấn đề: khoảnh khắc vừa về sau buổi hẹn là lúc người dùng biết thêm nhiều nhất
  về người ấy, nhưng sổ tay (REQ-016 STORY-004) không có cửa vào ở đó. Màn
  check-in 23h (STORY-012 AC-16) hiện chỉ lưu ảnh và một câu nhật ký; chip
  canvas "+ ghi vào sổ tay" đã bị loại khỏi STORY-012 để chờ requirement này.
- Kết quả kinh doanh: sổ tay đầy lên từ trải nghiệm thật, nên gợi ý quà / mồi
  chuyện / kịch bản buổi hẹn (vốn đọc sổ tay) bớt chung chung.
- Phụ thuộc giao hàng: REQ-016 STORY-003, STORY-004, STORY-012 đều đã DONE
  (REQ-016 `Status: DONE`). Phụ thuộc đã thoả.

## User Decisions (binding)

| ID | Quyết định | Nguồn |
|---|---|---|
| O-1b | Chọn. Trên màn check-in 23h thêm một lời hỏi-tại-chỗ **tuỳ chọn** "Hôm nay biết thêm gì về người ấy?", ghi thành **một mục sổ tay có cấu trúc** thuộc đúng một trong hai loại: **sở thích** hoặc **sự kiện/dịp** | User, 2026-09-25 |
| O-2 | Mục ghi mang xuất xứ "từ buổi hẹn <thẻ>" | User, 2026-09-25 |
| O-3 | Sửa/xoá mục trong màn Sổ tay STORY-004 sẵn có, **không thêm màn mới** | User, 2026-09-25 |
| O-1a | **Loại.** Câu nhật ký không bao giờ được sao chép sang sổ tay (vi phạm R-1f, phá riêng tư STORY-003) | User, 2026-09-25 |
| O-1c | **Hoãn.** App không tự đề xuất mục sổ tay từ chữ trong câu nhật ký (nguy cơ trái R-7) | User, 2026-09-25 |
| OQ-1 | **Đã giải quyết.** Chấp nhận diễn giải BR-8/AC-1 như đã viết | User, 2026-09-27 (`req_master.md` `## User Decisions`) |
| A-5 | **Xác nhận.** Check-in chỉ ghi một ý + loại; ngày/chi tiết của "sự kiện/dịp" bổ sung ở màn Sổ tay | User, 2026-09-27 (`req_master.md` `## User Decisions`) |
| OQ-2 | **Đã giải quyết.** Ưu tiên giữ MEDIUM, chạy sau REQ-016 | User, 2026-09-27 (`req_master.md` `## User Decisions`) |

## Open Question Triage

### OQ-1 — lời hỏi O-1b nói về người kia, trong khi STORY-012 AC-19 nói nội dung nhắc 23h "không hỏi về người kia"

- Mâu thuẫn: STORY-012 AC-19 (J8 hướng vào trong): nội dung nhắc hỏi **về người
  dùng** ("về tới nhà chưa?"), **không** hỏi về người kia, không bắt đánh giá buổi
  hẹn hay đánh giá người kia. Lời hỏi O-1b "Hôm nay biết thêm gì về người ấy?"
  hỏi về người kia, và nằm trên chính màn check-in mà AC-19 đang chi phối.
- Diễn giải của PO (user chấp nhận 2026-09-27): user đã chọn O-1b kèm đúng câu chữ, nên
  đây là ngoại lệ có chủ ý, được giới hạn như sau:
  1. Nội dung **thông báo** 23h và **câu hỏi chính** của màn check-in giữ nguyên
     hướng vào trong theo AC-19. REQ-017 không đổi hai phần này.
  2. Lời hỏi O-1b là khối **phụ, tuỳ chọn**, đứng sau phần ảnh + câu nhật ký,
     không được là thứ đầu tiên người dùng thấy.
  3. Lời hỏi chỉ xin **một điều đã biết** (sở thích hoặc sự kiện/dịp); không bao
     giờ xin đánh giá buổi hẹn, đánh giá người kia, hay chấm điểm (vẫn giữ vế
     "không yêu cầu đánh giá" của AC-19 và R-1e).
- Trạng thái: **ĐÃ GIẢI QUYẾT** ngày 2026-09-27. User chấp nhận diễn giải BR-8/AC-1
  như viết ở trên (nguồn: `req_master.md` `## User Decisions`). OQ-1 không còn
  chặn gì trong REQ-017, kể cả `Ready-For-Delivery` và câu chữ/vị trí khối hỏi.
- Ghi chú theo dõi (ngoài REQ-017, không chặn): REQ-016 STORY-012 AC-19 cần một
  bản vá truy vết (`ac-patch`) ghi nhận diễn giải này, để Reviewer của REQ-017
  không bắt lỗi AC-19 trên một story đã DONE. Việc này thuộc Helen-SC.

### OQ-2 — ưu tiên MEDIUM

- Trạng thái: **ĐÃ GIẢI QUYẾT** ngày 2026-09-27. User giữ MEDIUM, chạy sau
  REQ-016 (nguồn: `req_master.md` `## User Decisions`). Không chặn gì.

### Giả định của PO (không chặn, user ghi đè được)

- A-1 — **một mục mỗi lần check-in.** Lời hỏi tạo tối đa một mục sổ tay cho một
  lần check-in, theo STORY-004 BR-2 (một câu một lần). Muốn ghi thêm thì dùng
  "+ tự thêm" ở màn Sổ tay.
- A-2 — **tên trong xuất xứ.** Xuất xứ hiện tên buổi hẹn như thẻ đang mang lúc
  xem. Khi thẻ không còn đọc được (bị xoá, bị đóng ngăn theo STORY-013, hoặc lỗi
  đọc theo BR-12), xuất xứ suy biến thành "từ một buổi hẹn"; mục sổ tay không
  bao giờ mất theo thẻ.
- A-3 — **"sự kiện/dịp" là nhóm "Sự kiện" có sẵn.** Không thêm loại thứ ba vào
  sổ tay; chữ "dịp" chỉ là nhãn cho người dùng, ánh xạ vào nhóm "Sự kiện" của
  STORY-004.
- A-4 — **mục từ check-in là mục sổ tay bình thường.** Nó chịu mọi luật của
  STORY-004 và STORY-013 (lối ra/đóng ngăn) như mục thêm qua "+ tự thêm"; xuất
  xứ là thuộc tính thêm, không phải loại mục riêng.

## Scope Decision

### In Scope

1. Lời hỏi-tại-chỗ tuỳ chọn trên màn check-in 23h (O-1b), bỏ qua được, không
   chặn phần ảnh và câu nhật ký.
2. Người dùng tự chọn loại mục: sở thích hoặc sự kiện/dịp.
3. Mục ghi vào sổ tay STORY-004 với xuất xứ "từ buổi hẹn <thẻ>" (O-2).
4. Xem/sửa/xoá mục đó trong màn Sổ tay sẵn có (O-3), kèm nhãn xuất xứ.
5. Mục từ check-in được các bên đọc sổ tay (gợi ý quà, mồi chuyện, kịch bản)
   dùng như mọi mục khác.
6. Ranh giới nhật ký ↔ sổ tay: hai dữ liệu tách biệt hoàn toàn.
7. Lời hỏi và nhãn xuất xứ là nội dung dữ liệu có id bền, qua cổng nhập R-15c.

### Out of Scope

- O-1a: sao chép, trích, hay điền sẵn câu nhật ký sang sổ tay (loại).
- O-1c: tự đề xuất mục sổ tay hay tự đoán loại mục từ chữ người dùng gõ (hoãn).
- Màn mới, route mới, hay đích điều hướng mới. Màn check-in vẫn chỉ tới được từ
  nhắc 23h (STORY-012 AC-16).
- Ghi vào **hồ sơ kỹ năng** từ check-in. Chỉ sổ tay.
- Nhiều mục sổ tay trong một lần check-in (A-1).
- Mở lại màn check-in sau khi đóng, hoặc sửa mục ngay trên màn check-in sau khi
  đã lưu. Sửa/xoá chỉ ở màn Sổ tay.
- Lọc, sắp xếp, hay nhóm sổ tay theo xuất xứ; gắn xuất xứ cho mục không đến từ
  check-in.
- Đổi nội dung thông báo 23h, đổi luật không-nhắc-lại (AC-17), đổi thẻ (BR-12).
- Ảnh check-in gắn vào mục sổ tay.
- Xuất/chia sẻ sổ tay (R-1f cấm).
- Đánh giá buổi hẹn, đánh giá hay chấm điểm người kia.

### Business Rules And Guardrails

- **BR-1 (R-1f).** Mục chỉ là sở thích hoặc sự kiện/dịp. Không trường đánh giá
  con người, không nhận xét, không xuất/chia sẻ.
- **BR-2 (SC-3 / STORY-004 BR-1..BR-3).** Lời hỏi là hỏi-tại-chỗ, tuỳ chọn,
  một mục một lần. Bỏ qua không chặn gì, không hỏi lại, không trách móc.
- **BR-3 (O-1a, riêng tư nhật ký).** Câu nhật ký không bao giờ đi vào sổ tay dưới
  bất kỳ hình thức nào: không sao chép, không điền sẵn ô hỏi, không trích đoạn.
  Xoá nhật ký không đụng sổ tay và ngược lại.
- **BR-4 (R-7, O-1c).** Tất định, không AI, không API ngoài. App không suy ra loại
  mục hay nội dung mục từ chữ người dùng gõ; người dùng tự chọn loại.
- **BR-5 (R-15).** Câu hỏi và nhãn xuất xứ là dữ liệu có id bền trong gói nội
  dung hỏi-tại-chỗ; đi qua cổng nhập STORY-004 AC-36 (vi phạm R-1f ở tầng đầu vào
  làm hỏng bản dựng). Không chuỗi cứng trong code.
- **BR-6 (STORY-012 BR-12).** Thẻ chỉ đọc. Check-in chỉ đọc tên thẻ để làm xuất
  xứ; không thêm trường thẻ, không đổi trạng thái thẻ. Đọc không được thì suy
  biến, không chặn.
- **BR-7 (STORY-012 BR-11).** Widget và thông báo không bao giờ hiện nội dung sổ
  tay, kể cả mục vừa ghi từ check-in.
- **BR-8 (STORY-012 AC-19, OQ-1).** Thông báo 23h và câu hỏi chính của màn giữ
  hướng vào trong. Lời hỏi O-1b là khối phụ, tuỳ chọn, chỉ xin sở thích/sự kiện.
- **BR-9 (O-3).** Không màn mới. Sửa/xoá dùng đúng thao tác sẵn có của màn Sổ tay.

## Seed To Story Mapping

`## Story Seeds` trong `req_master.md` là bằng chứng recon, không phải danh sách
story. Outcome liệt kê độc lập với bảng seed:

- Outcome U-1: "Vừa về sau buổi hẹn, tôi ghi lại điều mới biết về người ấy mà
  không phải mở màn khác, và thấy nó nằm trong sổ tay, sửa/xoá được, rồi thấy
  gợi ý bớt chung chung."

Không có outcome thứ hai. Phần "xem xuất xứ + sửa/xoá ở màn Sổ tay" (O-2, O-3)
không đứng riêng được: nếu giao một mình thì chưa có mục nào mang xuất xứ, nên
không quan sát được gì. Phần "lời hỏi trên check-in" nếu thiếu O-2/O-3 thì mục
ghi xong không truy được về buổi hẹn và không có lối sửa đã được user duyệt.
Cả hai là các bước của cùng một workflow, nên gộp.

| Seed | Đi đâu | Ghi chú |
|---|---|---|
| SEED-1 (IDEA-20260925-001, O-1b + O-2 + O-3) | STORY-001 | Một seed, một outcome. Phần check-in (STORY-012) và phần sổ tay (STORY-004) là hai bề mặt của cùng một story, không phải hai story; thứ tự làm giữa hai bề mặt thuộc coding plan |

**Kết quả:** 1 seed → 1 story.

## Coverage Map

| Hạng mục phạm vi | Story | Disposition |
|---|---|---|
| Lời hỏi-tại-chỗ tuỳ chọn trên check-in 23h (O-1b) | STORY-001 | Story |
| Chọn loại sở thích / sự kiện-dịp | STORY-001 | Story |
| Xuất xứ "từ buổi hẹn <thẻ>" (O-2) + suy biến | STORY-001 | Story |
| Sửa/xoá trong màn Sổ tay sẵn có (O-3) | STORY-001 | Story |
| Mục dùng được cho quà/mồi chuyện/kịch bản | STORY-001 | Story |
| Ranh giới nhật ký ↔ sổ tay (O-1a loại) | STORY-001 | Guardrail |
| Nội dung là dữ liệu + cổng nhập (R-15) | STORY-001 | Guardrail |
| Hoà giải STORY-012 AC-19 | STORY-001 + OQ-1 | Guardrail, user xác nhận 2026-09-27 |
| O-1c đề xuất mục từ chữ nhật ký | — | Hoãn |
| Ghi hồ sơ kỹ năng từ check-in | — | Out of scope |

## Story Order And Dependencies

| Story | Depends On | Lý do phụ thuộc |
|---|---|---|
| STORY-001 | NONE trong REQ-017 | Phụ thuộc ngoài: REQ-016 STORY-003, STORY-004, STORY-012 (đều DONE) — màn check-in, sổ tay + cơ chế hỏi-tại-chỗ, và ranh giới nhật ký đã được giao |

INTEGRATION_VERIFICATION_REQUIRED: NO — một story duy nhất, không có tương tác
runtime giữa các story của REQ-017.

## Open Questions

Không còn câu hỏi mở nào chặn REQ-017.

| ID | Nội dung | Trạng thái | Chặn |
|---|---|---|---|
| OQ-1 | Xác nhận diễn giải BR-8 cho STORY-012 AC-19 | RESOLVED 2026-09-27 (user, `req_master.md` `## User Decisions`): chấp nhận BR-8/AC-1 như viết | Không |
| OQ-2 | Ưu tiên MEDIUM | RESOLVED 2026-09-27 (user, `req_master.md` `## User Decisions`): giữ MEDIUM, sau REQ-016 | Không |

Ghi chú theo dõi ngoài REQ-017 (không chặn): bản vá truy vết `ac-patch` cho
REQ-016 STORY-012 AC-19, do Helen-SC phụ trách.
