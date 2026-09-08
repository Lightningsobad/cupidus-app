# Story Requirements: STORY-001 Danh sách việc-cần-làm — kho chung và vòng đời thẻ

- Requirement: REQ-016
- Story: STORY-001
- Complexity: complex
- Story-Class: shared-foundation
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: NONE
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules`, `## Out of Scope`,
  `## Open Questions`; `../../requirements/requirements.md` →
  `## Open Question Triage`, `## Coverage Map`, `## Story Order And Dependencies`

## Business Outcome

Người dùng chặng 1 (đã có một "mối" cụ thể, đối phương chưa cài app) có **một
chỗ duy nhất** chứa mọi ý tưởng hẹn hò và theo được chúng từ lúc mới nghĩ ra
tới lúc thành kỷ niệm — không ý tưởng nào rơi rụng, và người dùng nhìn thấy
"của cải" của mình đang lớn dần.

Đây là màn "về nhà" (màn 1 trong bản đồ 11 màn hình) và là **kho chung duy
nhất** (SC-1') mà mọi cửa vào sau này đổ thẻ vào. Story cũng là câu trả lời cụ
thể cho định vị "kho tài sản, không phải phòng chờ" (OQ-18/L45 — đã đóng).

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Kho thẻ có toàn bộ giá trị của nó mà không cần người kia
phản hồi, không cần người kia cài app, và không cần bất kỳ story tương lai nào.
Các cửa vào sau chỉ **thêm nguồn sinh thẻ**, không thêm điều kiện để kho hoạt
động.

## Scope

### In Scope

1. Màn danh sách việc-cần-làm là kho chung duy nhất của chặng 1.
2. Mô hình thẻ có cấu trúc (SB-76), đủ trường để các story sau đọc được.
3. Vòng đời 4 trạng thái, hiển thị thành 5 ngăn lọc: ngăn view *Tất cả* dẫn đầu
   + 4 ngăn trạng thái *Mới nghĩ ra · Đã hẹn ngày · Đã đi rồi · Đã thành kỷ
   niệm* (AC-10, D-1).
4. Bắt ý tưởng trong 5 giây: nhập nhanh và dán link.
5. Đúng một hành động chính mỗi trạng thái, cộng tối đa một ô tràn "…" chứa
   lựa chọn phụ (SC-4 sau D-2).
6. Chuyển trạng thái thủ công hai chiều, và xoá thẻ.
7. Trạng thái rỗng của Phút 1 với đúng hai lời mời một chạm.
8. Đánh dấu *đã trả lời / chưa trả lời* do user tự bấm, cho thẻ mang ý niệm
   "đã rủ".
9. Thanh tab 4 mục của bề mặt solo chặng 1 (*Muốn làm · Ý tưởng · Sổ tay · Nhật
   ký*) và route của nó — khung điều hướng, nội dung 3 mục sau thuộc story khác
   (AC-22, D-3).

### Out of Scope

- Xuất lời mời / bottom sheet mad-libs — STORY-002. Ở story này hành động chính
  của *Đã hẹn ngày* là "chuẩn bị", **chưa** phải "xuất lời mời".
- Khối "Trước giờ đi" (SB-211) — STORY-006.
- Khối "Cảm ơn + chốt việc kế tiếp" (SB-212) — STORY-007.
- Widget, đếm ngược, pha theo thời gian, bộ đếm "của cải đang lớn" — STORY-012.
- Đóng ngăn gọn gàng (J11) và màn không trách móc khi quay lại (J13) —
  STORY-013.
- Mọi cửa vào sinh nội dung (quà, mồi chuyện, hoàng đạo, kịch bản, chân dung,
  bảng tra) — story riêng.
- Bất kỳ danh sách thứ hai nào cạnh tranh với màn này (vi phạm SC-1').
- Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, thương mại quà, và
  J7 "trong buổi hẹn" — ngoài phạm vi ở tầng requirement, binding.

## Acceptance Criteria

### Nhóm A — Phút 1 và trạng thái rỗng (rủi ro chính L46)

**AC-1.** Given người dùng mở app lần đầu và kho chưa có thẻ nào, when màn danh
sách hiện ra, then màn hiển thị trạng thái rỗng chứa **đúng hai** lời mời một
chạm — "dán 1 link em vừa thấy" và "để app gợi ý 1 việc theo dịp gần nhất" — và
**không** hiển thị bất kỳ biểu mẫu onboarding, wizard nhiều bước, hay yêu cầu
điền hồ sơ nào (SC-3).

**AC-2.** Given người dùng ở trạng thái rỗng, when họ chọn "dán 1 link", then
app nhận link, tạo **ít nhất 1 thẻ** ở trạng thái *Mới nghĩ ra*, và **không**
bắt điền thêm bất kỳ trường nào trước khi thẻ tồn tại.

**AC-3.** Given người dùng ở trạng thái rỗng, when họ chọn "để app gợi ý 1 việc
theo dịp gần nhất", then app hiển thị **1–2 gợi ý tất định** lấy từ gói dữ liệu
ship sẵn (dịp Việt gần nhất theo lịch thiết bị), và chọn một gợi ý tạo ngay một
thẻ *Mới nghĩ ra*.

**AC-4.** Given người dùng bắt đầu từ trạng thái rỗng, when họ hoàn tất một
trong hai lời mời ở AC-2/AC-3, then kho có **1–2 thẻ trong vòng 60 giây** kể từ
lúc chạm lời mời, đo trên đường đi hạnh phúc không lỗi mạng.

**AC-5.** Given app đang gợi ý theo dịp ở AC-3, when tạo gợi ý, then toàn bộ nội
dung đến từ **bảng tra / preset ship sẵn**, không có lời gọi mô hình AI nào ở
runtime và không có lời gọi API nội dung bên ngoài nào (R-7).

### Nhóm B — Bắt ý tưởng và mô hình thẻ

**AC-6.** Given người dùng đang ở màn danh sách (kho đã có thẻ), when họ chạm
nút "+", then họ tạo được một thẻ mới chỉ bằng **một trường bắt buộc duy nhất**
là tiêu đề, và thẻ được lưu ngay ở trạng thái *Mới nghĩ ra*.

**AC-7.** Given người dùng dán một link vào ô nhập nhanh, when lưu, then link
được giữ nguyên trên thẻ và thẻ vẫn tạo được **kể cả khi** app không lấy được
tiêu đề/ảnh từ link đó (không có link preview là suy giảm êm, không phải lỗi
chặn).

**AC-8.** Given một thẻ đã tồn tại, when người dùng mở chi tiết thẻ, then thẻ hỗ
trợ đầy đủ các trường có cấu trúc sau, tất cả **tuỳ chọn** trừ tiêu đề: tiêu đề,
loại hoạt động, ngày hẹn, giá, khoảng cách, cần đặt trước (có/không), trong
nhà/ngoài trời, ghi chú, ảnh/ký ức, link nguồn.

**AC-9.** Given bất kỳ thẻ nào, when thẻ được lưu, then thẻ mang một **nguồn
sinh** (ví dụ: nhập tay, dán link, gợi ý theo dịp) để story sau đọc được, và
nguồn sinh này không bao giờ được hiển thị như một chỉ số đánh giá người dùng
hay người kia.

### Nhóm C — Bốn ngăn và vòng đời (SC-4, SC-5, OQ-2)

**AC-10.** Given kho có thẻ ở nhiều trạng thái, when người dùng chuyển ngăn,
then màn hiển thị **đúng 5 ngăn lọc**: một ngăn **"Tất cả" dẫn đầu** (liệt kê
thẻ ở mọi trạng thái) cộng 4 ngăn trạng thái — *Mới nghĩ ra · Đã hẹn ngày · Đã
đi rồi · Đã thành kỷ niệm* — và mỗi ngăn trạng thái chỉ liệt kê thẻ đúng trạng
thái đó. "Tất cả" là **một view, không phải trạng thái thứ 5**: vòng đời vẫn
đúng 4 trạng thái, không thẻ nào được lưu với trạng thái "Tất cả", và AC-14
không đổi (D-1 — `../../req_master.md` → `## Design Ruling Log`).

**AC-11.** Given người dùng xem một thẻ bất kỳ trong danh sách, when thẻ hiển
thị, then **đúng một** hành động chính (CTA) xuất hiện và nó khớp trạng thái
hiện tại theo SC-4: *Mới nghĩ ra* → "hẹn ngày" · *Đã hẹn ngày* → "chuẩn bị" ·
*Đã đi rồi* → "ghi lại" · *Đã thành kỷ niệm* → "xem lại"; và thẻ được phép mang
thêm **tối đa một** ô tràn "…" đặt cạnh CTA. Ô tràn chỉ chứa lựa chọn phụ (đổi
trạng thái, sửa, xoá); nó không được chứa, không được trở thành, và không được
cạnh tranh vị trí với một hành động chính thứ hai. Bốn nhãn CTA ở trên **không
đổi** (D-2 — `../../req_master.md` → `## Design Ruling Log`).

**Ngoại lệ phạm vi màn A4 (D-19 — `../../req_master.md` →
`## Design Ruling Log`):** riêng màn chi tiết thẻ A4 ("Chi tiết thẻ mới nghĩ
ra") được phép hiện **thêm đúng một** dòng hành động phụ đặt **dưới** CTA
chính (ví dụ theo canvas: "hoặc soạn lời rủ cho ngọt · để dành hôm khác").
Dòng này **không phải** hành động chính thứ hai: nó không được dùng dạng pill
nền `--grad`, không được đặt ngang hàng hoặc cạnh tranh vị trí với CTA, và
không được tính là CTA khi kiểm tra bất biến "đúng một hành động chính". Bất
biến "đúng một CTA" ở trên vẫn áp **nguyên vẹn** cho thẻ rút gọn (P4) và cho
**mọi** bề mặt khác ngoài A4.

**AC-12.** Given một thẻ *Mới nghĩ ra*, when người dùng bấm hành động chính và
đặt một ngày hẹn, then thẻ chuyển sang *Đã hẹn ngày* và xuất hiện trong đúng
ngăn lọc đó.

**AC-13.** Given người dùng đang ở bất kỳ ngăn nào trong 4 ngăn, when họ duyệt
ngăn đó, then ngăn có **ít nhất một đường đi tiếp** (hành động chính hoặc chuyển
trạng thái) hoặc đường xoá — không ngăn nào và không trạng thái nào là ngõ cụt
(SC-5). Điều này áp cả cho *Đã thành kỷ niệm*, trạng thái cuối của vòng đời.
Điều kiện "có đường xoá" ở trên **không đổi**.

**Ngoại lệ phạm vi màn A4 (D-18 — `../../req_master.md` →
`## Design Ruling Log`):** trên màn chi tiết thẻ A4, chữ của hành động chính
được phép là **văn bản CTA theo ngữ cảnh riêng của màn** thay vì đúng chữ
trong bảng SC-4 (ví dụ theo canvas: "Chốt ngày đi thôi" cho *Mới nghĩ ra*,
"Đọc lại · rủ đi lần nữa" cho *Đã thành kỷ niệm*). Ngoại lệ này chỉ nới **chữ
hiển thị** trên màn A4; **hành vi** khi bấm và **kết quả chuyển trạng thái**
vẫn phải khớp đúng dòng tương ứng trong bảng SC-4. Thẻ rút gọn (P4) và mọi bề
mặt khác vẫn dùng đúng nhãn cố định SC-4, không đổi.

**AC-14.** Given một thẻ ở bất kỳ trạng thái nào, when người dùng chọn đổi trạng
thái thủ công, then thẻ chuyển được sang bất kỳ trạng thái nào trong 4 trạng
thái theo **cả hai chiều** (tiến và lùi), không có chuyển tiếp một chiều bị
khoá.

**AC-15.** Given một thẻ đã chuyển sang *Đã hẹn ngày* rồi bị lùi về *Mới nghĩ
ra*, when người dùng lùi trạng thái, then dữ liệu đã nhập (ngày hẹn, ghi chú,
ảnh) **không bị xoá âm thầm**; app giữ dữ liệu hoặc hỏi rõ trước khi bỏ.

**AC-16.** Given một thẻ bất kỳ, when người dùng xoá và xác nhận, then thẻ biến
mất khỏi kho, và app **không kịch tính hoá** hành động đó — không câu trách móc,
không hỏi lý do, không thông điệp cảm xúc (R-1c/R-1d).

### Nhóm D — Ranh giới đạo đức (R-1b, R-1e, R-1g)

**AC-17.** Given một thẻ mang ý niệm "đã rủ", when người dùng xem thẻ, then app
**chỉ** cho đánh dấu *đã trả lời / chưa trả lời*, và cờ này chỉ đổi khi **chính
người dùng bấm**.

**AC-18.** Given bất kỳ thẻ nào, when thẻ hiển thị ở danh sách hoặc chi tiết,
then app **không** hiển thị và **không** lưu bất kỳ chỉ báo hành vi người kia
nào: không "đã xem", không giờ mở, không đếm lần mở, không tần suất trả lời,
không nhận định kiểu "hay trả lời chậm" (R-1b).

**AC-19.** Given bất kỳ nội dung nào trên màn này nhắc tới người kia, when nội
dung hiển thị, then nội dung **không kết luận** về người kia và không chấm điểm
người kia; mọi phần đoán vẫn nằm ở tầng "user ghi" hoặc "user đoán" (R-1e).

**AC-20.** Given màn danh sách ở bất kỳ trạng thái nào, when người dùng dùng
màn, then app **không** hiển thị streak, chuỗi ngày, huy hiệu, bảng xếp hạng,
hay bất kỳ cơ chế ép quay lại nào (R-1 nấc 3, cấm (f)).

### Nhóm E — Kho duy nhất và định vị

**AC-21.** Given chặng 1 đang chạy, when người dùng tìm ý tưởng hẹn hò của
mình, then tồn tại **đúng một** kho thẻ; story này không tạo và không cho phép
một danh sách thứ hai song song (SC-1').

**AC-22.** Given màn danh sách có thẻ, when người dùng nhìn màn, then màn trả
lời được câu hỏi "tài sản của tôi đang ở đâu, đã lớn tới đâu" — thứ nổi bật là
**kho của người dùng**, không phải "có gì mới từ người kia không" (định vị
OQ-18/L45). Bộ đếm "của cải đang lớn" thuộc STORY-012, không thuộc story này.
Bề mặt solo chặng 1 **dùng thanh tab 4 mục riêng** — *Muốn làm · Ý tưởng · Sổ
tay · Nhật ký* — thay cho thanh shell hiện có; story này **được phép và phải**
tạo thanh tab đó cùng route của nó, với "Muốn làm" là mục mặc định và là màn
danh sách của story này. Ba mục còn lại là **vỏ điều hướng giữ chỗ** trong phạm
vi story này; nội dung của chúng thuộc story khác và vẫn phải tôn trọng AC-21
(kho thẻ duy nhất). Thanh tab là điều hướng, không phải kho dữ liệu thứ hai, nên
không vi phạm SC-1' (D-3 — `../../req_master.md` → `## Design Ruling Log`).

**AC-23.** Given người dùng chưa từng có, và sẽ không bao giờ có, phản hồi từ
người kia, when họ dùng màn này, then **mọi** AC ở trên vẫn đạt được và không AC
nào cần người kia tham gia.

## Business Rules

- **BR-1 (SC-1' — một kho).** Màn (1) là kho thẻ duy nhất của chặng 1. Mọi cửa
  vào tương lai ghi **vào** kho này. Tạo danh sách riêng cho quà, mồi chuyện,
  hay hoạt động là vi phạm.
- **BR-2 (SC-4 — một hành động chính).** Mỗi thẻ, ở mỗi trạng thái, có đúng một
  hành động chính. Hành động phụ được phép nhưng phải nằm ở mức thị giác thấp
  hơn rõ rệt và không cạnh tranh vị trí với hành động chính. Sau D-2, dạng trình
  bày chuẩn của hành động phụ trên thẻ là **một** ô tràn "…" cạnh CTA; nhiều ô
  tràn, hoặc một nút phụ nổi bật ngang CTA, vẫn là vi phạm.
- **BR-3 (SC-5 — không ngõ cụt).** Không trạng thái nào là ngõ cụt. Trạng thái
  cuối *Đã thành kỷ niệm* vẫn phải có "xem lại" và đường xoá.
- **BR-4 (SC-3 — không điền trước).** Story này không được thêm luồng onboarding
  điền sổ tay, hồ sơ kỹ năng, hay hồ sơ người kia. Mọi dữ liệu bổ sung chỉ được
  hỏi **tại chỗ**, khi người dùng đã đang làm một việc cụ thể.
- **BR-5 (R-1b).** Chỉ trạng thái *đã trả lời / chưa trả lời*, do user tự đánh
  dấu. Cấm lưu, tính, suy ra, hoặc hiển thị bất kỳ đại lượng hành vi nào của
  người kia.
- **BR-6 (R-1c/R-1d).** Cửa từ chối và cửa xoá phải sạch: một chạm, không né,
  không trêu, không kịch tính hoá.
- **BR-7 (R-1e).** Ba tầng: user ghi ✅ · user đoán, app không xác nhận ✅ · app
  suy luận/chấm điểm về người kia ❌.
- **BR-8 (R-7 — không AI ở runtime).** Gợi ý theo dịp ở AC-3 là **bảng tra tay**
  ship như gói dữ liệu, runtime tất định. Không gọi mô hình AI, không gọi API nội
  dung bên ngoài, ở bất kỳ đường đi nào của story này.
- **BR-9 (R-10 — định vị).** Ngôn ngữ trên màn là "trợ lý hoạt động / chăm sóc
  nhau". Không dùng giọng "app tán tỉnh", không dùng giọng bói toán.
- **BR-10 (R-13 — khoá vị trí, đối chiếu).** Story này **không** thuộc nhóm khoá
  vị trí: nó phải có đường vào trực tiếp từ menu chính. Ràng buộc khoá vị trí chỉ
  áp cho STORY-009 và STORY-010.
- **BR-11 (R-14 — không paywall lõi).** Không phần nào của kho thẻ nằm sau
  paywall.
- **BR-12 (R-12 — dữ liệu người dùng xoá được).** Thẻ do người dùng tạo phải xoá
  được bằng thao tác của chính họ.
- **BR-13 (SB-76 — thẻ có cấu trúc).** Mô hình thẻ phải đủ trường ở AC-8 ngay từ
  story này, kể cả khi UI của story này chưa dùng hết, vì 12 story sau đọc và
  ghi trên chính mô hình đó.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** NO — chặng 1 chưa có màn hình gốc nào. Đây
  là màn hình đầu tiên của chế độ 1 người.
- **Điểm vào:** mục **"Muốn làm"** — mục đầu và mặc định của thanh tab 4 mục
  chặng 1 do story này tạo (AC-22, D-3). Đây là màn "về nhà" của chặng 1 và là
  màn mặc định khi mở app ở chế độ 1 người.
- **Không phải màn khoá vị trí.** R-13 không áp cho story này (xem BR-10).
- **Hợp đồng cho story sau (shared-foundation):** mô hình thẻ + 4 trạng thái +
  API tạo thẻ là bề mặt dùng chung. STORY-002, 004, 005, 006, 007, 008, 011,
  012, 013 phụ thuộc trực tiếp vào nó (`../../requirements/requirements.md` →
  `## Story Order And Dependencies`). Đổi hình dạng thẻ sau story này là thay đổi
  phá vỡ hợp đồng.
- **Không có tích hợp bên ngoài.** Không API nội dung, không dịch vụ AI, không
  nguồn tin tức. Dữ liệu dịp Việt là gói ship sẵn.

## Open Question Impact

### Scope Items BLOCKED in this story

- **KHÔNG CÓ.** Không hạng mục nào trong phạm vi STORY-001 bị chặn bởi một câu
  hỏi mở. Story này có thể vào delivery ngay.
  - OQ-3 (ai biên tập/duyệt kho nội dung preset) **không** chặn story này: kho
    nội dung preset của REQ-016 bắt đầu ở STORY-002. Nội dung duy nhất mà
    STORY-001 chạm tới là 1–2 gợi ý theo dịp ở AC-3, và đó là dữ liệu lịch dịp
    Việt tất định, không phải nội dung nhắn tin cần duyệt gu.

### Scope Items NOT BLOCKED in this story

- **OQ-2 (một "ngăn" hay nhiều "ngăn") — ĐÓNG ở tầng sản phẩm.** 4 trạng thái =
  4 ngăn lọc, cộng ngăn view *Tất cả* dẫn đầu sau D-1 → 5 ngăn (AC-10). Phần
  còn lại là **chi tiết trình bày UI** (tab, chip,
  segmented, hay cuộn ngang) và được giao cho UI/UX Designer **trong phạm vi
  story này**. Đây là quyết định UX, không phải câu hỏi sản phẩm còn mở.
- **L45 / OQ-18 — ĐÓNG.** User đã chốt ngày 2026-09-03: chặng 1 là **kho tài
  sản**, không phải phòng chờ; trần giữ chân RS-D6 được chấp nhận có ý thức.
  STORY-001 là một trong ba story chịu tải định vị này (cùng STORY-012 và
  STORY-013) và thi hành nó qua AC-22. **Không mở lại.** Nếu L45 có bao giờ bị
  lật, story này đổi *khung trình bày*, không đổi *ranh giới phạm vi*.
- **OQ-3 (biên tập/duyệt preset) — ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật
  R-15** (`req_master.md` mục 15). **Vẫn không chạm story này**: kho nội dung
  preset của REQ-016 bắt đầu ở STORY-002, và ràng buộc R-15 (schema + id bền, N
  là thuộc tính dữ liệu, cổng nhập chạy được) áp cho các story tiêu thụ nội
  dung preset, không thêm phạm vi cho STORY-001. Ghi nhận để truy vết.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN.** Không gán vào STORY-001. Không có
  màn chủ, không có outcome riêng.
- **Rủi ro tồn dư đã chấp nhận:** trần giữ chân RS-D6. Cấm chữa bằng
  streak/bảng xếp hạng (AC-20) và cấm chữa bằng vòng lặp xã hội (chặng 1.5,
  ngoài phạm vi).

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-5 | Phút 1 (L46), SC-3, R-7 |
| AC-6..AC-9 | J1 bắt ý tưởng 5 giây, SB-76 thẻ có cấu trúc |
| AC-10..AC-16 | OQ-2 (đã đóng), SC-4, SC-5, R-1c, R-12 |
| AC-17..AC-20 | R-1b, R-1e, R-1g, R-1 nấc 3 |
| AC-21..AC-23 | SC-1', định vị OQ-18/L45, cổng cứng |
