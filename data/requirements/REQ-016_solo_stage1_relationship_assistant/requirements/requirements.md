# Requirement Breakdown: REQ-016 Trợ lý chăm sóc nhau chặng 1 (chế độ 1 người)

## Source Artifacts

- Requirement master:
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md`
- Đặc tả cấu trúc (nguồn chính, tự đủ):
  `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/idea.md`
  → `## Đặc tả sản phẩm (vòng 9-10)` — A. lưới 13 journey · B. vòng đời user ·
  C. bản đồ 11 màn hình · D. luật màn hình SC-1'..SC-6 · E. SB-211/SB-212 ·
  F. bảng gán ngược 20 hạng mục nghiên cứu.
- Bàn giao luật + ranh giới phạm vi:
  `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/development.md`
  → `### ★★ BẢN BÀN GIAO CUỐI (v8)` (PHẦN 1 luật · PHẦN 3 ranh giới ·
  PHẦN 4 câu hỏi mở).
- Bằng chứng hoà giải L45: cùng file → `### 2026-09-03 (vòng 8) · D5 · User
  chốt OQ-18` và `### 2026-09-06 (vòng 11) · R1`.
- Supersedes REQ-013 (`CANCELLED`, artifacts đã xoá). Không có ràng buộc
  tương thích ngược với story cũ của REQ-013.

## Context Summary

- Người dùng mục tiêu (cố định, R-9): người **đã có một "mối" cụ thể**, đối
  phương **chưa cài app**. Không phục vụ nhóm "chưa có ai".
- Vấn đề: chặng 1 hiện "mờ nhạt" — nhiều nghiên cứu, không có màn hình gốc,
  không có vòng đời user.
- Kết quả kinh doanh: biến chặng 1 thành **trợ lý hoạt động / chăm sóc nhau**
  dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia.
- Hình kiến trúc bắt buộc: **nhiều cửa vào (mỗi tính năng một trang) → một kho
  chung (danh sách việc-cần-làm) → dữ liệu phụ trợ (sổ tay, hồ sơ kỹ năng)
  không có cửa riêng, chỉ lộ ra khi một cửa vào khác cần.**
- Tần suất thật: ý định cao / tần suất thấp (1-2 lời mời một tuần). Tối ưu
  "được nhớ tới đúng lúc cần", KHÔNG tối ưu DAU. Không story nào được lấy DAU,
  streak, hay retention hằng ngày làm tiêu chí thành công.
- Tín hiệu thành công: một người dùng đơn lẻ, không cần ai trả lời, vẫn tích
  luỹ được ý tưởng → hẹn thật ngoài đời → ghi lại kỷ niệm, và thấy "của cải"
  của mình lớn dần.

## Open Question Triage

### L45 — "chặng 1 là trang trí cho phòng chờ" (⚠️ BLOCKING cho việc khoá story list)

**Phán quyết: KHÔNG chặn. Mâu thuẫn đã được user hoà giải, chỉ chưa được chép
sang artifact requirement.**

Bằng chứng, không phải suy đoán: L45 chính là OQ-18, và OQ-18 **đã được user
chốt** ngày 2026-09-03 (`development.md` → `D5 · User chốt OQ-18`):

> **OQ-18 CHỐT: chặng 1 là KHO TÀI SẢN**, không phải phòng chờ. […] Chặng 1
> **không cần** một vòng lặp xã hội tối thiểu nào để tự đứng vững. […] Trần
> giữ chân RS-D6 được **chấp nhận có ý thức**, không phải bug.

Vòng 11 giữ L45 lại trong danh sách bàn giao vì nó là "câu hỏi định vị, độc
lập với việc id REQ nào còn sống" — đúng, nhưng đó là lý do **chép sang REQ
mới**, không phải bằng chứng nó chưa được trả lời. D5 đã trả lời nó, và toàn
bộ đặc tả vòng 9-10 (11 màn hình, SC-1'..SC-6) được dựng **trên** câu trả lời
đó. Nếu D5 bị lật, đặc tả cấu trúc sụp theo — nhưng D5 chưa bị lật.

**Định vị được khoá lại cho REQ-016:** chặng 1 cạnh tranh kiểu "kho lưu trữ cá
nhân" (sổ tay, Notion, Pinterest), quay lại vì **của cải đang lớn dần** (N3),
không vì có người đang chờ trả lời (N7). Đây chính là nội dung cổng cứng đã có
trong `req_master.md`.

- **Không chặn story nào.** Mọi story trong bảng dưới đều qua được cổng cứng
  bằng chính nó, không story nào cần người kia trả lời để có giá trị.
- **Chịu tải trực tiếp cho định vị "kho tài sản"** (nếu L45 bị mở lại và đổi
  câu trả lời, ba story này phải đổi khung, KHÔNG phải đổi ranh giới):
  STORY-001 (kho chung), STORY-012 (bộ đếm "của cải đang lớn"), STORY-013
  (tài sản không gắn người kia sống sót qua lối ra J11).
- **Rủi ro tồn dư được chấp nhận có ý thức:** trần giữ chân RS-D6. Không được
  chữa bằng streak/bảng xếp hạng (R-1(f) cấm), không được chữa bằng vòng lặp
  xã hội (chặng 1.5, ngoài phạm vi).

### OQ-3 — ai biên tập và duyệt kho nội dung preset

**ĐÃ ĐÓNG 2026-09-06 (user) — D-15.** Xem luật **R-15** trong `req_master.md`
mục 15. Câu trả lời không phải là "chỉ định một người duyệt", mà là **đổi bản
chất của nội dung**: nội dung là **dữ liệu có schema + id ổn định, đi qua một
cổng nhập chạy được**, không phải chuỗi trong code do một người gác cổng bằng
mắt.

- Story chịu ảnh hưởng: STORY-002, 004, 005, 007, 009, 010, 011 (mọi story có
  kho nội dung preset / mad-libs / khung nhại / bảng tra tay).
- **R-15a** — mỗi story trên ship nội dung như gói dữ liệu có lược đồ và định
  danh bền; đổi nguồn sang CMS ngoài repo không được kéo theo một lần sửa code.
- **R-15b** — N là thuộc tính dữ liệu. Seed 10 mục cho mỗi gói **xoay vòng**,
  nhưng không AC/BR/bố cục nào được dựa vào "vì có đúng 10 mục nên…". Gói
  **tra cứu phủ toàn phần** (STORY-010) không phải gói xoay vòng.
- **R-15c** — R-1b, chống tâng bốc, cấm hiển thị %, cấm streak là **cổng nhập
  chạy được**: nội dung vi phạm bị từ chối tại cổng nhập và làm hỏng bản dựng.
  Đây là cái thay thế cho "gu người duyệt lớp 2" như guardrail thật.
- Kiểm duyệt hai lớp (SB-123) vẫn giữ cho **chất lượng biên tập** (giọng, độ
  sượng), nhưng **không còn là cơ chế cưỡng chế luật bất biến** và **không còn
  chặn STORY-002 vào delivery**. Nội dung CMS tương lai không đi qua review của
  repo này, nên chỉ cổng nhập mới đáng tin.
- Rủi ro tồn dư: "sượng" về giọng văn vẫn là rủi ro triển khai, nhưng đã hạ từ
  **chặn ship** xuống **rủi ro chất lượng nội dung**, sửa được bằng đổi dữ liệu
  mà không sửa code (R-15a).

### OQ-2 — một "ngăn" hay nhiều "ngăn"

**Đã trả lời một phần, không chặn.** Mỗi trạng thái trong màn (1) là một
"ngăn" lọc (4 ngăn: *Mới nghĩ ra / Đã hẹn ngày / Đã đi rồi / Đã thành kỷ
niệm*). Phần còn mở là **chi tiết UI** (tab, chip, segmented, hay cuộn ngang)
— giao cho UI/UX Designer trong phạm vi STORY-001, không phải câu hỏi sản
phẩm còn mở.

### SB-144/145/146 — trò chơi "đoán" không thắng thua

**Không chặn. Không gán vào story nào trong breakdown này.** Brainstorm ghi rõ
"chưa gán màn cố định", và đặc tả 11 màn hình không dành chỗ cho nó. Ép nó vào
STORY-005 hoặc STORY-011 sẽ tạo một hạng mục không có outcome riêng và không
có màn hình. **Hoãn sang một requirement sau**, mở lại khi có màn hình chủ.

### Rủi ro #2 — hỏi kỹ năng kiểu CV → 80% trả lời "không có"

Không phải câu hỏi mở, là ràng buộc thiết kế đã có lời giải trong brainstorm.
Chép thành guardrail cứng của STORY-004: "nhớ dai", "biết chỗ ăn ngon", "gói
quà đẹp" **phải** được tính là kỹ năng; cấm trình bày hồ sơ kỹ năng dưới dạng
biểu mẫu CV.

## Scope Decision

### In Scope

Toàn bộ chặng 1: 11 màn hình (4 KHO · 3 CỬA VÀO · 3 KHOÁ VỊ TRÍ · 1 HÀNH
ĐỘNG) cộng hai khối mở rộng SB-211 / SB-212 của màn (1), chia thành 13 story
theo outcome ở `## Coverage Map`.

### Out of Scope (binding, chép từ `req_master.md`)

- **Chặng 1.5** — link hai chiều để người kia trả lời mà không cần cài app.
  Requirement riêng, tạo sau. REQ-016 **chỉ để lại móc SB-125** (vật phẩm lời
  mời phải là payload render được) — móc này là guardrail của STORY-002,
  không phải một story.
- **Feed tin thật** (mồi chuyện bản B) — đánh giá lại ở chặng 1.5.
- **Zalo Mini App** (OQ-7).
- **Thương mại / affiliate quà.** Quà chỉ là Ý TƯỞNG.
- **J7 "trong buổi hẹn"** — cố ý để trống. Quyết định triết lý, không phải
  thiếu sót. Không story nào được lấp J7.
- **J12 tự thực hiện lời mời cài app** — REQ-016 dừng ở chỗ *nhận ra* cột mốc
  (bộ đếm "của cải đang lớn" trong STORY-012) và giữ payload SB-125.
- **Trò chơi "đoán"** (SB-144/145/146) — xem OQ triage.
- **Paywall trên bất kỳ phần lõi nào** (R-14).

### Business Rules And Guardrails (áp cho MỌI story)

Toàn bộ `## Invariant Design Rules` R-1..R-1g và luật 7..14 trong
`req_master.md` là ràng buộc cứng. Ba luật dễ bị vi phạm nhất khi implement,
nhắc lại tại đây:

1. **Không AI ở runtime.** Nội dung đi đường PRESET + MAD-LIBS + KHUNG NHẠI;
   bảng tra ăn khớp là **bảng tra tay** ship như gói dữ liệu, runtime tất
   định. AI chỉ dùng ngoài hệ thống ở khâu SOẠN nội dung.
2. **R-1b — cấm đo lường hành vi người kia.** Không "đã xem", không giờ mở,
   không đếm lần mở. Trạng thái duy nhất được phép là *đã trả lời / chưa trả
   lời*, và phải do **user tự đánh dấu**. Ghi sở thích + sự kiện ✅; ghi tần
   suất + hành vi ❌.
3. **R-1g — không kết luận.** Mọi màn hình nói về người kia (STORY-009,
   STORY-010, và mọi nội dung preset nhắc tới người kia) phải kết thúc bằng
   **một câu để hỏi người thật**.

Guardrail bổ sung ở tầng requirement:

- **SC-6 / R-13 (khoá vị trí):** STORY-009 và STORY-010 **không bao giờ** xuất
  hiện trong menu chính hay tab bar. Đây là ràng buộc điều hướng, không phải
  gợi ý UX.
- **SC-1' (một kho):** không story nào được tạo một danh sách thứ hai cạnh
  tranh với màn (1). "Danh sách quà riêng", "danh sách mồi chuyện riêng" là vi
  phạm.
- **SC-2 (không điểm dừng chân):** mỗi cửa vào (5),(6),(7),(8),(9),(10) phải
  có một hành động rõ ràng đẩy kết quả sang (1), (4), hoặc (11).
- **SC-3 (không điền trước):** không story nào được thêm luồng onboarding điền
  sổ tay hoặc hồ sơ kỹ năng.
- **SC-5 (không ngõ cụt):** không trạng thái nào của thẻ là ngõ cụt.
- **Thang CÔNG SỨC:** quà lọc theo **số giờ**, không theo VNĐ.
- **Chỉ số ăn khớp hiển thị DẢI, không %.**
- **Mỗi ô bảng tra bắt buộc có ít nhất một điểm cọ xát**, không chỉ lời khen.

### Thứ tự không thương lượng (SB-174) — đã thi hành trong thứ tự story

Sổ tay → làm cho quà / mồi chuyện / kịch bản hết chung chung → **rồi mới** phủ
vỏ hoàng đạo và trắc nghiệm.

- Sổ tay + hồ sơ kỹ năng nằm **trong** STORY-004 (pha đầu), trước nhánh quà.
- De-genericize: STORY-004 (quà), STORY-005 (mồi chuyện), STORY-008 (kịch bản).
- Vỏ hoàng đạo / bảng tra: STORY-010, STORY-011 — cả hai **sau** 004/005/008.

## Seed To Story Mapping

`## Story Seeds` trong `req_master.md` là recon pre-split theo **màn hình**.
Bảng dưới ghi rõ chỗ gộp và chỗ hấp thụ.

| Seed | Đi đâu | Ghi chú |
|---|---|---|
| Danh sách việc-cần-làm (màn 1) | STORY-001 | Giữ nguyên như một story. Hành động chính của trạng thái *Đã hẹn ngày* trong story này là "chuẩn bị"; "xuất lời mời" đến ở STORY-002 |
| Sổ tay người yêu (màn 2) + Hồ sơ kỹ năng (màn 3) | **Hấp thụ vào STORY-004** | **Không phải story.** Brainstorm nói rõ đây là "kho ngữ cảnh, không phải tính năng" (SC-3), không có luồng điền trước. Một kho dữ liệu chưa có bên tiêu thụ thì sau khi merge **không có gì quan sát được** → trượt cổng standalone-value. SB-174 sống sót dưới dạng **thứ tự pha trong STORY-004**, không dưới dạng ranh giới story |
| Nhật ký riêng (màn 4) | STORY-003 | Giữ nguyên. Độc lập hoàn toàn |
| Gợi ý quà (màn 5) | STORY-004 | Gộp với sổ tay + hồ sơ kỹ năng + cơ chế hỏi-tại-chỗ |
| Mồi chuyện (màn 6) | STORY-005 | Giữ nguyên. Bản B (feed tin thật) ngoài phạm vi |
| Vỏ hoàng đạo / trắc nghiệm (màn 7) | STORY-011 | Giữ nguyên, đẩy xuống cuối theo SB-174 |
| Chân dung (màn 8) | STORY-009 | Giữ nguyên |
| Kịch bản buổi hẹn 3 phần (màn 9) | STORY-008 | Giữ nguyên |
| Bảng tra ăn khớp (màn 10) | STORY-010 | Giữ nguyên |
| Xuất lời mời (hành động 11) | STORY-002 | Giữ nguyên. **Hấp thụ móc SB-125** (payload render được) làm guardrail, không tách thành story |
| SB-211 "Trước giờ đi" | STORY-006 | Tách khỏi STORY-001. Là mở rộng của màn (1) về mặt UI, nhưng là **outcome riêng** (J6) với bảng tra tất định riêng |
| SB-212 "Cảm ơn + chốt việc kế tiếp" | STORY-007 | Tách khỏi STORY-001, cùng lý do (J9). Tái dùng renderer của STORY-002 |
| Trạng thái & widget theo pha (SB-83/84/85/86/87/99) | STORY-012 | Gộp cả 6 hạng mục vào một story: cùng một outcome "được nhắc đúng lúc, không bị làm phiền" |
| Lối ra & lối quay lại (SB-64/65/100, J11/J13) | STORY-013 | Gộp J11 + J13 vào một story: cùng một outcome "app không thành nơi tôi sợ mở" |
| Nhận diện cột mốc J12 (chỉ giữ payload) | **Hấp thụ, không thành story** | Payload SB-125 → guardrail STORY-002. Phần "nhận ra cột mốc" có mặt user-visible duy nhất là bộ đếm "của cải đang lớn" → STORY-012. Bản thân seed không có outcome quan sát được |

**Kết quả:** 15 seed → 13 story. 2 seed bị hấp thụ (sổ tay/kỹ năng, cột mốc
J12), 1 seed tách đôi về mặt trách nhiệm (màn 1 → STORY-001 + 006 + 007), 6
hạng mục SB gộp thành STORY-012, 3 hạng mục SB gộp thành STORY-013.

## Coverage Map

| Hạng mục phạm vi | Story | Journey phủ | Disposition |
|---|---|---|---|
| Màn (1) danh sách việc-cần-làm, vòng đời thẻ 4 trạng thái, bắt ý tưởng 5 giây | STORY-001 | J1, J2 | Story |
| Hành động (11) xuất lời mời + cửa từ chối sạch + payload SB-125 | STORY-002 | J3 | Story |
| Màn (4) nhật ký riêng | STORY-003 | J8 | Story |
| Sổ tay (2) + hồ sơ kỹ năng (3) + hỏi tại chỗ + màn (5) gợi ý quà | STORY-004 | J1, J10 | Story |
| Màn (6) mồi chuyện bản A + A+ | STORY-005 | J1, J3, J10 | Story |
| SB-211 "Trước giờ đi" | STORY-006 | J6 | Story |
| SB-212 "Cảm ơn + chốt việc kế tiếp" | STORY-007 | J9 | Story |
| Màn (9) kịch bản buổi hẹn 3 phần | STORY-008 | J5 | Story |
| Màn (8) chân dung "theo cách BẠN nhìn" | STORY-009 | J10 | Story |
| Màn (10) bảng tra ăn khớp | STORY-010 | J10 | Story |
| Màn (7) vỏ hoàng đạo / trắc nghiệm | STORY-011 | J1 | Story |
| Trạng thái & widget theo pha, đếm ngược, "món quà đang lớn", nhỏ giọt, bộ đếm của cải | STORY-012 | J4, J5, J10, J12 (nhận diện) | Story |
| Lối ra J11 + lối quay lại J13 | STORY-013 | J11, J13 | Story |
| J7 "trong buổi hẹn" | — | J7 | **Cố ý để trống** (quyết định triết lý) |
| Chặng 1.5 / feed tin thật / Zalo Mini App / thương mại quà | — | — | **Out of scope** |
| Trò chơi "đoán" SB-144/145/146 | — | — | **Hoãn** — chưa có màn chủ |

13/13 journey xử lý có chủ ý: 11 phủ bằng story · J7 cố ý trống · J12 cắt biên
(chỉ giữ nhận diện + payload).

## Story Order And Dependencies

| Story | Depends On | Lý do phụ thuộc (hành vi đã giao, không phải file dùng chung) |
|---|---|---|
| STORY-001 | NONE | — |
| STORY-002 | STORY-001 | Bottom sheet gắn trên một thẻ đang tồn tại |
| STORY-003 | NONE | Độc lập hoàn toàn |
| STORY-004 | STORY-001 | Đầu ra của quà là một thẻ đẩy vào kho chung (SC-1'/SC-2) |
| STORY-005 | STORY-001, STORY-004 | A+ đổi thành thẻ; nội dung cần sổ tay để hết chung chung (SB-174) |
| STORY-006 | STORY-001 | Khối mở rộng trên chi tiết thẻ trạng thái *Đã hẹn ngày* |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | Tái dùng renderer lời mời; đính ảnh từ nhật ký; "chốt việc kế tiếp" lấy từ kho mồi |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | Ba cửa ra là lời mời / thẻ mới / nhật ký; nội dung cần sổ tay |
| STORY-009 | STORY-004 | Khoá vị trí — chỉ tới được từ luồng (5) đang chạy |
| STORY-010 | STORY-004 | Khoá vị trí — chỉ tới được từ luồng (5) hoặc (9) |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | Kết quả ra 3 thẻ hoạt động; SB-174 bắt buộc đứng sau de-genericize |
| STORY-012 | STORY-001 | Pha của widget đọc từ trạng thái thẻ |
| STORY-013 | STORY-001, STORY-004 | Đóng ngăn tác động lên thẻ; phải giữ lại sổ tay/kỹ năng không gắn người kia |

Không story nào phụ thuộc vào story sau nó. Không phụ thuộc nào được biện minh
bằng "tránh xung đột merge" hay "để contract có trước".

## Open Questions

Còn mở, cần **user** trả lời, **không chặn** việc khoá story list:

| ID | Nội dung | Cần trước khi |
|---|---|---|
| — | Không còn open question nào ở mức requirement | — |

Đã đóng ở breakdown này: L45 (bằng D5/OQ-18), OQ-2 (chi tiết UI → UX,
STORY-001), SB-144/145/146 (hoãn sang requirement sau), Rủi ro #2 (thành
guardrail STORY-004), **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15, thành luật
R-15 (`req_master.md` mục 15): nội dung là dữ liệu có schema + id ổn định, N là
thuộc tính dữ liệu, luật bất biến cưỡng chế ở cổng nhập chạy được.**
