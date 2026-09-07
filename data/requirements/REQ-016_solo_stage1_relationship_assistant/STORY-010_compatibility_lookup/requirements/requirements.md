# Story Requirements: STORY-010 Bảng tra ăn khớp — màn (10)

- Requirement: REQ-016
- Story: STORY-010
- Complexity: complex
- Story-Class: standard
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-004
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules` (R-1/R-1a, R-1b, R-1e,
  R-1f, R-1g, R-7, R-8, R-10, R-13, R-14), `## Out of Scope`,
  `## Open Questions`;
  `../../requirements/requirements.md` → `## Story Index`,
  `## Open Question Triage`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` →
  hợp đồng thẻ (AC-8), nguồn sinh thẻ (AC-9), một hành động chính cấp thẻ
  (AC-11);
  `../../STORY-006_before_you_go_checklist/requirements/requirements.md` →
  tiền lệ hai tầng hành động (BR-1) và tiền lệ nhãn chức năng không bị OQ-3
  chặn (BR-14);
  `../../STORY-009_your_view_portrait/requirements/requirements.md` →
  story anh em cùng nhóm khoá vị trí; ranh giới "story này không hiển thị chỉ
  số ăn khớp" (BR-13) là mặt đối của story hiện tại

## Business Outcome

Người dùng **biết trước chỗ dễ hợp và chỗ dễ va** giữa mình và "mối" của mình,
để **chuẩn bị** thay vì bất ngờ. Giá trị không nằm ở việc biết "hợp bao nhiêu"
— giá trị nằm ở chỗ mỗi lần tra đều đẻ ra **một việc làm được** và **một câu để
hỏi người thật**.

Story này phủ **J10**. Nó là bề mặt nội dung **rủi ro "sượng" cao nhất của cả
requirement**: 144 ô hoàng đạo + 256 ô MBTI = **400 ô nội dung nói về người
kia**. Một ô sai giọng không chỉ gây sượng — nó kéo app từ "trợ lý chăm sóc
nhau" sang "app bói toán" (R-10) hoặc sang việc chấm điểm người kia (R-1e tầng
3, cấm).

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Toàn bộ đầu vào là nhãn **do chính người dùng ghi hoặc
đoán**. Người kia không cần xác nhận dấu hoàng đạo/MBTI của mình, không cần cài
app, không cần biết chuyện này đang diễn ra. Nếu một AC chỉ đúng khi người kia
xác nhận, AC đó sai phạm vi.

### Rủi ro chính: trượt từ "chuẩn bị" sang "phán quyết"

Có **hai** cú trượt story này tồn tại để chặn, và cả hai đều là tiêu chí nghiệm
thu chứ không phải lời khuyên biên tập:

1. **Trượt định lượng** — thêm một con số, một thanh tỉ lệ, hay một xếp hạng
   vào màn. R-8 cấm. Nhóm D chặn cú này.
2. **Trượt tâng bốc** — viết 400 ô toàn lời khen cho "an toàn". Đó chính là cú
   trượt biến màn này thành lá số tử vi: đọc xong thấy vui, không chuẩn bị được
   gì, và không có lý do nào để hỏi người kia. R-7 bắt buộc **mỗi ô có ít nhất
   một điểm cọ xát**. Nhóm C chặn cú này ở tầng dữ liệu, không phải ở tầng biên
   tập.

## Scope

### In Scope

1. Màn (10) "Bảng tra ăn khớp", **nhóm KHOÁ VỊ TRÍ** (R-13/SC-6): chỉ tới được
   bằng một liên kết trong luồng (5) gợi ý quà (STORY-004) hoặc luồng (9) kịch
   bản buổi hẹn (STORY-008) **đang chạy**.
2. **Gói dữ liệu tra cứu soạn tay**, ship kèm app: **144 ô hoàng đạo**
   (12 × 12) và **256 ô MBTI** (16 × 16). Runtime **tất định**, không AI
   (R-7). **Việc SOẠN đủ cả 400 ô nằm TRONG phạm vi REQ-016** — user chốt
   2026-09-06 (lối (a)): giữ **cả hai** trục, không cắt trục MBTI. Trục MBTI hợp
   D-12' vì MBTI là **nhãn do người dùng tự nhập**, không phải suy đoán của app
   về người kia.
3. **Bộ bốn bắt buộc** trên mọi kết quả, đủ cả bốn, không thiếu mục nào:
   *chỗ dễ hợp · chỗ dễ va · 1 hoạt động nên thử · 1 câu để hỏi*.
4. **Ràng buộc dữ liệu chống tâng bốc**: mỗi ô trong cả 400 ô bắt buộc chứa ít
   nhất một điểm cọ xát, và ràng buộc này được **kiểm tự động ở khâu dựng gói
   dữ liệu**, không phụ thuộc trí nhớ người biên tập.
5. **Hiển thị DẢI, không hiển thị %** (R-8): không điểm số, không phần trăm,
   không thanh tỉ lệ, không sao, không xếp hạng ô này so với ô khác.
6. **Đầu vào tự khai** (R-1a, R-1e): dấu hoàng đạo và/hoặc MBTI của **mình** và
   của **người kia**, do chính người dùng **GHI** hoặc **ĐOÁN**, lấy từ sổ tay
   (STORY-004) hoặc hỏi tại chỗ.
7. **Nhãn tầng dữ liệu**: nhãn người dùng *đoán* được hiển thị đúng như một
   phỏng đoán của người dùng, không bao giờ như một sự thật app xác nhận
   (R-1e).
8. Mục "1 hoạt động nên thử" có **hành động đẩy thành một thẻ** vào màn (1),
   trạng thái *Mới nghĩ ra* (SC-2), theo hợp đồng thẻ STORY-001.
9. **Kiểm duyệt nội dung hai lớp** (SB-123) cho **toàn bộ 400 ô** trước khi nội
   dung ra bản build người dùng thật. Lớp 2 của bộ seed là **user** (D-15).
10. Hoạt động **đầy đủ khi không có mạng**.
11. **Gói dữ liệu tuân R-15** (D-15): có **lược đồ + id ô ổn định**, không chuỗi
    cứng trong code; **kích thước hai trục và tập nhãn DẢI đọc từ dữ liệu**,
    không phải hằng số biên dịch; và các luật bất biến được cưỡng chế ở **cổng
    nhập** (mục 4 mở rộng, xem Nhóm J). Lý do: nguồn nội dung sẽ đổi chủ sang
    **CMS ngoài repo**, và cú đổi chủ đó không được kéo theo một lần sửa code.

### Out of Scope

- **Mọi con số, điểm số, phần trăm, thanh tỉ lệ, hay xếp hạng ăn khớp** — R-8
  cấm.
- **Suy ra dấu hoàng đạo / MBTI của người kia** từ dữ liệu app tự thu, từ hành
  vi, từ nội dung nhắn tin, hay từ bất kỳ nguồn nào không phải người dùng gõ ra
  — R-1(d-sai), R-1b cấm.
- **Sinh nội dung ăn khớp bằng AI ở runtime**, hoặc gọi API nội dung ngoài —
  R-7 cấm.
- **Định vị "app bói toán"** (R-10): không tử vi hằng ngày, không vận mệnh, không
  nội dung ăn khớp đổi theo ngày để tạo thói quen mở app.
- **Đường vào từ menu chính, tab bar, deep link, hay route trực tiếp** — vi phạm
  R-13/SC-6.
- **Chân dung "theo cách BẠN nhìn"** — STORY-009. Story này không hỏi bộ câu hỏi
  chân dung và không hiển thị chân dung.
- **Màn trắc nghiệm / vỏ hoàng đạo có cửa vào riêng** — STORY-011. Đó là một màn
  khác, KHÔNG khoá vị trí.
- **Vẽ widget hay trạng thái theo pha** — STORY-012.
- **Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, thương mại quà, J7**
  — binding out of scope của REQ-016.
- **CMS nội dung, màn quản trị nội dung, và luồng fetch/đồng bộ gói 400 ô**
  (D-15) — CMS nằm ngoài repo hiện tại. Story này ship gói **kèm app**. Điều
  story này **phải** làm là để lại một gói **thay được bằng dữ liệu** (R-15a,
  AC-36) và một **cổng nhập chạy được** (R-15c, AC-37) để nội dung CMS sau này
  bị chặn ngay cả khi không có ai review nó trong repo này.

## Acceptance Criteria

### Nhóm A — Khoá vị trí (R-13 / SC-6)

**AC-1.** Given người dùng đang ở trong luồng (5) gợi ý quà hoặc luồng (9) kịch
bản buổi hẹn, when họ chạm liên kết tới bảng tra ăn khớp, then màn (10) mở ra
trong ngữ cảnh luồng đó.

**AC-2.** Given người dùng duyệt **toàn bộ** menu chính và tab bar, when họ tìm
bảng tra ăn khớp, then **không** có mục nào, mục con nào, hay ô tìm kiếm nào dẫn
tới nó (R-13).

**AC-3.** Given một route, deep link, hay URL trỏ thẳng tới màn (10) mà không đi
qua một luồng (5)/(9) đang chạy, when nó được mở, then app **không** hiển thị
màn (10). Điều hướng trực tiếp là vi phạm luật khoá vị trí, không phải một lối
tắt tiện lợi.

**AC-4.** Given người dùng đang ở màn (10), when họ thoát, then họ quay về đúng
luồng đã mở nó, và luồng đó vẫn ở trạng thái trước đó — không mất ngữ cảnh, không
ngõ cụt (SC-5).

**AC-5.** Given luồng (9) kịch bản buổi hẹn (STORY-008) chưa được giao, when
người dùng dùng story này, then cửa vào từ luồng (5) vẫn đủ để mọi AC còn lại đạt
được. Đây là **phụ thuộc một chiều**: story này không yêu cầu STORY-008 phải đổi.

### Nhóm B — Đầu vào tự khai và luật ba tầng (R-1a, R-1e)

**AC-6.** Given người dùng mở màn (10) mà sổ tay chưa có nhãn hoàng đạo/MBTI của
người kia, when màn mở, then app **hỏi tại chỗ** để người dùng tự nhập, và
**không** hiển thị bất kỳ giá trị đoán sẵn, giá trị mặc định, hay gợi ý suy ra
nào (SC-3, R-1(d-sai)).

**AC-7.** Given bất kỳ đường đi nào của story này, when app cần một nhãn hoàng
đạo hoặc MBTI, then nguồn duy nhất hợp lệ là **người dùng gõ ra** (trực tiếp
hoặc đã lưu ở sổ tay). App **không** suy ra nhãn từ hành vi, nội dung nhắn tin,
danh bạ, mạng xã hội, hay bất kỳ dữ liệu nào app tự thu (R-1b, R-1(d-sai)).

**AC-8.** Given người dùng nhập nhãn của người kia ở chế độ **ĐOÁN**, when nhãn
đó xuất hiện ở bất kỳ bề mặt nào của story này, then nó hiển thị kèm dấu hiệu
đây là phỏng đoán **của người dùng**, và app **không bao giờ** trình bày nó như
một sự thật app xác nhận (R-1e tầng 2).

**AC-9.** Given người dùng đã nhập một nhãn, when họ muốn sửa hoặc xoá nó, then
họ làm được ngay trong luồng, và kết quả tra cứu cập nhật theo nhãn mới.

**AC-10.** Given người dùng từ chối nhập nhãn của người kia, when họ đóng lời
hỏi, then app chấp nhận không nội dung trách móc, không hỏi lại trong cùng
phiên, và luồng (5)/(9) gốc tiếp tục dùng được bình thường (R-1c/R-1d).

**AC-11.** Given người dùng chỉ nhập đủ **một** hệ nhãn (chỉ hoàng đạo hoặc chỉ
MBTI), when kết quả hiện ra, then story này cho ra bộ bốn đầy đủ từ hệ đó, và
**không** đòi hệ còn lại như điều kiện bắt buộc.

### Nhóm C — Bộ bốn bắt buộc và điểm cọ xát (R-7)

**AC-12.** Given đủ nhãn hai bên, when kết quả hiện ra, then nó chứa **đủ cả
bốn** mục: *chỗ dễ hợp*, *chỗ dễ va*, *1 hoạt động nên thử*, *1 câu để hỏi*.
Một kết quả thiếu bất kỳ mục nào trong bốn mục là **lỗi**, không phải một biến
thể hợp lệ.

**AC-13.** Given bất kỳ ô nào trong 144 ô hoàng đạo và 256 ô MBTI, when ô đó
được hiển thị, then nó chứa **ít nhất một điểm cọ xát**. **Không ô nào** chỉ
toàn lời khen (R-7).

**AC-14.** Given khâu dựng gói dữ liệu, when gói được dựng, then một **kiểm tra
tự động** chạy trên toàn bộ 400 ô và **làm hỏng bản dựng** nếu bất kỳ ô nào
thiếu mục "chỗ dễ va", thiếu bất kỳ mục nào trong bộ bốn, hoặc trống. Ràng buộc
chống tâng bốc là **cổng dữ liệu**, không phải quy ước biên tập.

**AC-15.** Given gói dữ liệu đã dựng, when app tra bất kỳ cặp nhãn hợp lệ nào,
then luôn có đúng một ô tương ứng — **không có ô trống, không có nội dung dự
phòng chung chung**, và không có đường đi nào rơi vào thông báo "chưa có dữ
liệu".

### Nhóm D — DẢI, không phần trăm (R-8)

**AC-16.** Given kết quả hiện ra, when người dùng đọc **toàn màn**, then không
có bất kỳ con số phần trăm, điểm số, thanh tỉ lệ, số sao, hay biểu đồ mức độ
nào (R-8).

**AC-17.** Given kết quả hiện ra, when chỉ số ăn khớp được thể hiện, then nó
xuất hiện dưới dạng **một DẢI định tính** lấy từ một tập nhãn đóng, ship kèm
gói dữ liệu.

**AC-18.** Given người dùng tra nhiều cặp nhãn khác nhau, when họ xem lại, then
app **không** xếp hạng các kết quả với nhau, không có "cặp hợp nhất", và không
có lịch sử so sánh nào tạo ra thứ tự.

**AC-19.** Given bất kỳ bề mặt nào của story này, when nó hiển thị, then DẢI
**không** phải là phần tử cuối cùng người dùng đọc — mục "1 câu để hỏi" luôn
đứng sau nó (xem AC-21).

### Nhóm E — Không kết luận, kết bằng một câu để hỏi (R-1g)

**AC-20.** Given kết quả hiện ra, when người dùng đọc hết, then nội dung **kết
thúc bằng một câu để hỏi người thật**, không kết thúc bằng một kết luận về người
kia (R-1g).

**AC-21.** Given mục "1 câu để hỏi", when nó hiển thị, then nó là một câu người
dùng **hỏi được người kia trong đời thật**, không phải một câu tự vấn, không
phải một mẹo gây ấn tượng, và không phải một lời dẫn dắt để moi thông tin
(R-1e, R-1g).

**AC-22.** Given toàn bộ nội dung của một ô, when người dùng đọc, then bài kiểm
tra R-1g đạt: *đọc xong, người dùng muốn hỏi người kia **nhiều hơn**, không phải
ít hơn*. Nội dung đóng lại sự tò mò bằng một phán quyết là nội dung **không
đạt**, kể cả khi nó có đủ bộ bốn.

### Nhóm F — Đẩy thẻ vào kho chung (SC-2, hợp đồng STORY-001)

**AC-23.** Given mục "1 hoạt động nên thử", when người dùng chạm hành động của
mục đó, then **một thẻ mới** xuất hiện ở màn (1), trạng thái *Mới nghĩ ra*, theo
hợp đồng thẻ STORY-001 AC-8 với **tiêu đề là trường bắt buộc duy nhất**.

**AC-24.** Given thẻ vừa tạo ở AC-23, when nó được lưu, then nó mang **nguồn
sinh** đọc được (STORY-001 AC-9), và nguồn sinh đó **không bao giờ** hiển thị
như một chỉ số đánh giá người dùng hay người kia.

**AC-25.** Given người dùng đang ở màn (10) mở từ một thẻ trong luồng (5)/(9),
when hành động "đẩy thành thẻ" hiển thị, then nó nằm **bên trong** luồng đang
chạy và **không** thay thế hay tranh chấp hành động chính cấp thẻ mà STORY-001
AC-11 đã khoá.

**AC-26.** Given người dùng không đẩy thẻ nào, when họ rời màn (10), then không
có hệ quả, không nhắc lại, và không nội dung trách móc (R-1c/R-1d, SC-5).

### Nhóm G — Tất định, ngoại tuyến, không AI (R-7)

**AC-27.** Given cùng một cặp nhãn đầu vào, when người dùng tra lại ở bất kỳ
thời điểm nào, then kết quả **giống hệt** lần trước. Nội dung **không** đổi theo
ngày, theo giờ, theo số lần mở, hay theo bất kỳ yếu tố ngẫu nhiên nào (R-7,
R-10).

**AC-28.** Given bất kỳ đường đi nào của story này, when kết quả được sinh,
then app **không** gọi mô hình AI và **không** gọi API ngoài nào (R-7).

**AC-29.** Given thiết bị hoàn toàn không có mạng, when người dùng dùng màn
(10), then nội dung vẫn **đúng và đầy đủ bộ bốn**, vì gói tra cứu là dữ liệu
tĩnh ship kèm app.

### Nhóm H — Ranh giới đạo đức và cổng cứng

**AC-30.** Given bất kỳ bề mặt nào của story này, when nó hiển thị, then app
**không** hiển thị và **không** lưu bất kỳ chỉ báo hành vi nào của người kia —
không "đã xem", không giờ mở, không đếm lần, không xác nhận từ người kia (R-1b).

**AC-31.** Given kết quả tra cứu, when nó được lưu, then app **không** ghi DẢI,
kết quả ăn khớp, hay bất kỳ nhận định nào về người kia vào sổ tay (STORY-004).
Sổ tay chỉ chứa **sở thích và sự kiện**, cộng nhãn tự khai của người dùng
(R-1f, xem BR-5).

**AC-32.** Given toàn bộ nội dung của story này, when người dùng đọc, then
không có ngôn ngữ tiên tri, vận mệnh, hay "số phận" — mọi câu đều đóng khung
màn này là **công cụ chuẩn bị** (R-10).

**AC-33.** Given người dùng dùng story này, when họ tìm chỉ số gắn kết, then
**không** có streak, chuỗi ngày, huy hiệu, hay đếm số lần tra (R-1 cấm (f)), và
**không** phần nào của story nằm sau paywall (R-14).

**AC-34.** Given người kia **chưa từng và sẽ không bao giờ** tham gia, when
người dùng dùng story này, then **mọi** AC ở trên vẫn đạt được (cổng cứng).

### Nhóm I — Kiểm duyệt hai lớp (SB-123, OQ-3)

**AC-35.** Given gói dữ liệu 400 ô, when nó được đưa vào **bản build người dùng
thật**, then toàn bộ 400 ô đã đi qua **kiểm duyệt hai lớp** (SB-123) với người
duyệt lớp 2 do user chỉ định. Nội dung chưa qua lớp 2 chỉ được dùng trong bản
build nội bộ. **D-15 (2026-09-06): người duyệt lớp 2 của bộ seed là user.**

### Nhóm J — Cổng nhập nội dung (R-15, D-15)

Ba AC này tồn tại vì nội dung **tương lai đến từ CMS ngoài repo** và **không đi
qua review của repo này**. Luật bất biến vì thế phải sống trong schema, không
trong đầu người viết nội dung.

**AC-36.** Given gói 400 ô, when nội dung của bất kỳ ô nào (hoặc toàn bộ nguồn
nội dung) được thay, then **chỉ dữ liệu đổi** — không cần sửa code, không cần
đổi widget, không cần build lại logic tra cứu. Mỗi ô có **id ổn định**, kích
thước hai trục (12, 16) và tập nhãn DẢI **đọc từ dữ liệu**, không phải hằng số
biên dịch. Không có nội dung ăn khớp nào là chuỗi cứng trong code (R-15a/b).

**AC-37.** Given một ô nội dung được nạp vào gói, when nó vi phạm bất kỳ luật
bất biến nào dưới đây, then **cổng nhập từ chối ô đó và làm hỏng bản dựng**,
kèm id ô vi phạm — nó **không** được phép lọt tới bước người dùng đọc:
(a) mô tả **hành vi hoặc tần suất** của người kia (R-1b: "hay trả lời chậm",
"ít nhắn tin") · (b) **không có điểm cọ xát** — chỉ toàn lời khen (R-7, chống
tâng bốc) · (c) chứa **con số phần trăm, điểm số, thang đo, thứ hạng, hay số
sao** ở tầng dữ liệu (R-8) · (d) chứa hoặc gợi ra **streak / chuỗi ngày / bảng
xếp hạng** (R-1 cấm (f)) · (e) kết thúc bằng một **kết luận** thay vì một câu để
hỏi (R-1g, cưỡng chế bằng trường bắt buộc *1 câu để hỏi*).

**AC-38.** Given gói tra cứu là gói **PHỦ TOÀN PHẦN** (không phải gói xoay
vòng), when bản dựng chạy, then cổng nhập kiểm **độ phủ 100%**: đủ 144 ô hoàng
đạo và đủ 256 ô MBTI, **không ô trống, không ô dự phòng chung chung**. Quy ước
"10 mục / gói xoay vòng" của D-15 **không áp** cho story này — gói xoay vòng
thiếu nội dung thì suy giảm êm (lặp sớm hơn), bảng tra thiếu ô thì **vỡ tại
chỗ** đúng cặp người dùng vừa chọn.

## Business Rules

- **BR-1 (R-13 — khoá vị trí vì lý do ĐẠO ĐỨC).** Màn (10) bị khoá vị trí cùng
  nhóm với STORY-009 và vì **cùng một lý do**: nó nói **về người kia**. Một màn
  nói về người kia mà đứng sẵn trong menu chính là một lời mời đi chấm điểm
  người khác. Ranh giới này khác lý do khoá của màn (9) kịch bản (bị buộc theo
  ngữ cảnh một thẻ *Đã hẹn ngày*) và khác lý do của khối "Trước giờ đi"
  (STORY-006 BR-12: mở rộng của màn (1)). Ba lý do khác nhau, không được gộp
  thành một quy ước điều hướng chung.
- **BR-2 (400 ô là ô CÓ HƯỚNG, không phải cặp không thứ tự).** 12 × 12 = 144 và
  16 × 16 = 256 vì nội dung viết từ **góc nhìn người dùng**: ô (mình = A, người
  kia = B) và ô (mình = B, người kia = A) là **hai ô khác nhau**, kể cả khi
  "độ hợp" như nhau. Rút gọn về cặp không thứ tự (78 / 136 ô) là **vi phạm phạm
  vi**, vì nó buộc nội dung phải nói trung lập về "hai người" thay vì nói với
  người dùng.
- **BR-3 (bảng tra tay, hàm thuần).** Kết quả là hàm thuần của (nhãn của mình,
  nhãn của người kia, hệ nhãn) qua gói dữ liệu ship kèm app. Cùng đầu vào →
  cùng đầu ra, vĩnh viễn. Không ngẫu nhiên hoá, không xoay vòng nội dung, không
  cá nhân hoá theo thời gian.
- **BR-4 (hai hệ nhãn độc lập, cấm trộn).** Hoàng đạo và MBTI là hai gói tra cứu
  **độc lập**. App **không** gộp hai kết quả thành một chỉ số tổng hợp và không
  bắc cầu suy diễn giữa hai hệ — làm vậy là tạo ra một điểm số trá hình, ngược
  R-8.
- **BR-5 (ranh giới R-1f cho nhãn tự khai).** Dấu hoàng đạo và MBTI **do người
  dùng ghi hoặc đoán** là dữ liệu R-1e tầng 1/tầng 2, được phép lưu ở sổ tay
  như một nhãn tự khai. **Không** được phép: ghi kết quả ăn khớp, DẢI, hay bất
  kỳ nhận định tính cách nào do app sinh ra vào sổ tay. Ranh giới: **người dùng
  ghi nhãn ✅ · app ghi phán quyết ❌.**
- **BR-6 (hai tầng hành động, tiền lệ STORY-001/STORY-006).** Hành động chính
  cấp thẻ vẫn là của STORY-001 AC-11. "Đẩy thành thẻ" của mục *1 hoạt động nên
  thử* là hành động **của khối**, nằm thấp hơn và **bên trong** luồng đang chạy.
  Đây đúng tiền lệ STORY-006 BR-1 đã đặt cho "Xong hết rồi, đi thôi".
- **BR-7 (DẢI là nhãn định tính, không phải khoảng số).** DẢI lấy từ một **tập
  nhãn đóng** ship kèm gói dữ liệu. Nó **không** được phép có giá trị số nào
  đứng sau nó ở tầng dữ liệu mà UI làm tròn thành nhãn — vì một khi con số tồn
  tại, nó sẽ rò ra màn hình ở lần sửa sau. Tập nhãn là kiểu dữ liệu, không phải
  cách trình bày.
- **BR-8 (cấm xuất / chia sẻ kết quả ăn khớp).** Kết quả tra cứu là một nhận
  định về người kia. Nó **không** có chức năng xuất, chia sẻ, chụp thành ảnh có
  thương hiệu app, hay đóng gói thành payload gửi đi — khác hẳn "xuất lời mời"
  (STORY-002), thứ được thiết kế để gửi. Cùng tinh thần R-1f (sổ tay không
  xuất/chia sẻ).
- **BR-9 (điểm cọ xát ≠ lời chê người kia).** "Chỗ dễ va" phải mô tả **một
  tình huống hai người dễ lệch nhau** và một việc người dùng tự chuẩn bị được.
  Nó **không** được viết thành khuyết điểm của người kia. Bài kiểm tra biên tập:
  câu đó có đứng vững nếu người kia đọc được không? Nếu không, ô đó trượt.
- **BR-10 (phụ thuộc một chiều với cửa vào).** Story này **đọc** cửa vào từ
  STORY-004 và STORY-008 và **đọc** hợp đồng thẻ STORY-001. Nó không thêm
  trường vào thẻ, không đổi hợp đồng thẻ, và không yêu cầu story nào phải đổi
  để nó chạy được.
- **BR-11 (SB-174 — thứ tự không thương lượng).** Story này thuộc lớp "vỏ" và
  chỉ được phủ lên **sau khi** sổ tay, quà, mồi chuyện, và kịch bản đã hết
  chung chung (STORY-004/005/008). Đây là **ràng buộc sản phẩm**: làm ngược lại
  cho ra một app bói toán có kèm to-do list.
- **BR-12 (ranh giới với STORY-009 và STORY-011).** Chỉ số ăn khớp và gói 400 ô
  thuộc **duy nhất** story này (đối chiếu STORY-009 BR-13). Story này **không**
  có bộ câu hỏi chân dung (STORY-009) và **không** có cửa vào riêng từ menu
  chính (STORY-011).
- **BR-13 (R-10 — không tử vi hằng ngày).** Không có nội dung ăn khớp "của hôm
  nay", không thông báo đẩy nội dung ăn khớp, không cơ chế nào biến màn này
  thành lý do mở app hằng ngày. Điều này khớp ràng buộc "không tối ưu DAU" của
  REQ-016.
- **BR-14 (R-15 — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  Mọi ràng buộc nội dung của story này phải chạy được trên **toàn bộ 400 ô** ở
  khâu dựng (AC-37/AC-38). Một AC chỉ đúng khi "người biên tập nhớ luật" là AC
  sai — vì nội dung tương lai do **CMS ngoài repo** cấp và không đi qua review
  của repo này. Đây là mở rộng của AC-14, không phải thay thế nó.
- **BR-15 (soạn 400 ô KHÔNG tách thành story riêng).** Gói nội dung không có
  outcome đứng riêng: sau khi chỉ mình nó merge, người dùng **không quan sát
  được gì**. Màn không có gói thì vỡ; gói không có màn thì vô hình. Đây là split
  theo **tầng** (dữ liệu / UI), tầng không phải ranh giới story. Việc soạn nội
  dung, cổng nhập, và màn tra cứu là **các pha có thứ tự trong coding plan** của
  story này: (1) schema + cổng nhập + nội dung placeholder nội bộ → (2) màn tiêu
  thụ gói → (3) soạn và kiểm duyệt hai lớp đủ 400 ô. Hợp đồng giữa pha (3) và
  các pha còn lại là **schema có validation** (AC-36/AC-37), không phải một
  ranh giới story.

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — luồng (5) gợi ý quà (STORY-004) và,
  khi đã giao, luồng (9) kịch bản buổi hẹn (STORY-008). Story này gắn lên bề
  mặt đã có, **không** tạo destination mới trong cấu trúc điều hướng.
- **Điểm vào:** **duy nhất** một liên kết trong luồng (5) hoặc (9) **đang
  chạy**. Direct URL only acceptable: **NO** — điều hướng trực tiếp bằng route
  hoặc deep link là vi phạm luật khoá vị trí (AC-3).
- **Lối ra:** quay về đúng luồng gốc (AC-4), cộng một lối ra tuỳ chọn sang màn
  (1) khi người dùng đẩy thẻ (AC-23). Không ngõ cụt (SC-5).
- **Hợp đồng story này TIÊU THỤ (chỉ đọc):** STORY-001 (hợp đồng thẻ AC-8,
  nguồn sinh AC-9, hành động chính AC-11), STORY-004 (cửa vào chính, sổ tay,
  cơ chế hỏi-tại-chỗ SC-3), STORY-008 (cửa vào thứ hai, tuỳ chọn).
- **Hợp đồng story này KHÔNG tiêu thụ:** STORY-009 (chân dung), STORY-011 (vỏ
  hoàng đạo có cửa vào riêng), STORY-012 (pha/widget). Story này không phát
  trạng thái pha và không vẽ widget.
- **Tích hợp bên ngoài:** **không có, và đó là ràng buộc, không phải hiện
  trạng** (BR-3, AC-28). Không AI runtime, không dịch vụ nội dung, không nguồn
  dữ liệu ngoài, không đồng bộ.

## Open Question Impact

### Scope Items BLOCKED in this story

**Không còn mục nào bị chặn.** OQ-3 đã đóng ngày 2026-09-06 (xem dưới); mọi
phạm vi của story này, gồm cả việc soạn nội dung, đã mở.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), D-15.** Đội AI soạn **offline, trong lúc
  delivery**; **user duyệt bộ seed** (lớp 2 của SB-123, AC-35); duyệt lâu dài
  chuyển sang **CMS ngoài repo hiện tại**; nội dung bản đầu **ship kèm app**.
  Việc soạn **đủ 400 ô** vì thế nằm **trong phạm vi** story này và không còn
  chặn bước ship nội dung.
- **Khối lượng "10 mục / gói" của D-15 KHÔNG áp cho story này.** D-15 định khối
  lượng cho **gói nội dung xoay vòng**. Bảng tra là gói **phủ toàn phần**: một
  gói xoay vòng thiếu nội dung thì suy giảm êm (lặp lại sớm hơn), còn bảng tra
  thiếu ô thì **vỡ tại chỗ** đúng ô người dùng vừa chọn. Ràng buộc đúng cho
  story này là **độ phủ 100%** (AC-38), không phải một con số mục.
- **User chốt lối (a) 2026-09-06:** giữ **cả hai** trục — 144 ô hoàng đạo
  (12 × 12) **và** 256 ô MBTI (16 × 16). Kiểm duyệt hai lớp (SB-123) áp lên
  **toàn bộ 400 ô**. Trục MBTI **không** vi phạm D-12'/nấc 4 vì MBTI là **nhãn
  do người dùng tự nhập**, không phải suy đoán của app về người kia (R-1a,
  R-1e tầng 1/2).
- **Tập nhãn DẢI — MỞ.** Chữ trong nhãn là nội dung có giọng điệu (một nhãn sai
  giọng như "không hợp" biến màn thành phán quyết, vi phạm R-10), nên nó đi
  cùng đường kiểm duyệt hai lớp của 400 ô và cùng cổng nhập AC-37(c). **Cấu
  trúc** tập nhãn đóng (BR-7) như trước, không đổi.
- **Ràng buộc chống tâng bốc, cấm %, và R-1b KHÔNG còn là lời hứa biên tập.**
  Sau D-15 chúng là **validation ở tầng schema, chạy được trên cả 400 ô**
  (AC-37, BR-14). Lý do: nội dung CMS tương lai không đi qua review của repo
  này, nên một luật chỉ sống trong hướng dẫn biên tập sẽ mất hiệu lực đúng lúc
  nó cần nhất.
- **OQ-3 không chặn màn, điều hướng, cơ chế, hay cấu trúc dữ liệu.** Khoá vị
  trí (AC-1..AC-5), đầu vào tự khai và luật ba tầng (AC-6..AC-11), **cơ chế
  cưỡng chế bộ bốn** (AC-12, AC-15), **cổng kiểm tra tự động chống tâng bốc**
  (AC-14), luật hiển thị DẢI (AC-16..AC-19), đẩy thẻ (AC-23..AC-26), tính tất
  định/ngoại tuyến (AC-27..AC-29), và các ràng buộc đạo đức (AC-30..AC-34)
  **xây và verify được ngay** bằng nội dung placeholder nội bộ.
- **Nhãn chức năng không bị OQ-3 chặn** — tiền lệ STORY-006 BR-14. Bốn tiêu đề
  mục (*chỗ dễ hợp · chỗ dễ va · 1 hoạt động nên thử · 1 câu để hỏi*) và dấu
  hiệu "đây là phỏng đoán của bạn" (AC-8) là **nhãn chức năng bắt buộc**, phải
  có mặt ngay từ bản build nội bộ đầu tiên.
- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là kho tài sản). Story
  này không chịu tải định vị; ba story chịu tải là STORY-001, STORY-012,
  STORY-013.
- **R-1 mở ở nấc 3 — ĐÓNG, luật bất biến.** Chỉ số ăn khớp (R-1 mục (d)) là
  **quyết định đã khoá**, không phải câu hỏi mở của story này — với điều kiện
  đầu vào do người dùng tự nhập. Nấc 4 không bao giờ.
- **R-8 hiển thị DẢI, không % — ĐÓNG, luật bất biến.** Không mở lại dưới dạng
  "chỉ một thanh nhỏ" hay "phần trăm ẩn trong cài đặt nâng cao".
- **OQ-2 — ĐÓNG ở tầng sản phẩm**, thuộc STORY-001.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này.
- **Chặng 1.5 / link hai chiều / feed tin thật / Zalo Mini App / thương mại /
  J7 — ĐÓNG, binding out of scope** của REQ-016.
- **Định dạng gói dữ liệu, cách đánh chỉ mục 400 ô, cơ chế chạy kiểm tra AC-14
  ở khâu dựng, và ranh giới backend/mobile** — giao **Tech Lead**. Ràng buộc sản
  phẩm: tất định, ship kèm app, không AI, kiểm tra làm hỏng bản dựng khi ô
  thiếu điểm cọ xát.
- **Chi tiết trình bày** (thứ tự thị giác bốn mục, cách hiện DẢI mà không gợi
  ra thang đo, vị trí liên kết trong luồng (5)/(9), bố cục lời hỏi-tại-chỗ,
  cách thể hiện dấu "phỏng đoán") — giao **UI/UX Designer trong phạm vi story
  này**. AC-19 và AC-8 là **ràng buộc sản phẩm** UI/UX phải thoả, không phải
  gợi ý.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-5 | R-13 / SC-6 khoá vị trí, cửa vào (5)/(9), SC-5 không ngõ cụt, BR-1 |
| AC-6..AC-11 | R-1a, R-1e ba tầng, R-1(d-sai), R-1b, SC-3 hỏi-tại-chỗ, R-1c/R-1d |
| AC-12..AC-15 | R-7 bộ bốn bắt buộc + mỗi ô có ít nhất một điểm cọ xát, BR-2, BR-9 |
| AC-16..AC-19 | R-8 DẢI không %, BR-7 tập nhãn đóng |
| AC-20..AC-22 | R-1g và bài kiểm tra nghiệm thu của nó |
| AC-23..AC-26 | SC-2, hợp đồng thẻ STORY-001 AC-8/AC-9/AC-11, BR-6 hai tầng hành động |
| AC-27..AC-29 | R-7 không AI runtime, không API ngoài, BR-3 hàm thuần, R-10 |
| AC-30..AC-34 | R-1b, R-1f + BR-5, R-10, R-1 cấm (f), R-14, cổng cứng REQ-016 |
| AC-35 | SB-123 kiểm duyệt hai lớp, OQ-3 (đóng 2026-09-06, D-15), tiền lệ STORY-002 và STORY-009 |
| AC-36 | R-15a/b — schema + id ổn định, N là thuộc tính dữ liệu, đổi nguồn không sửa code |
| AC-37 | R-15c — cổng nhập cưỡng chế R-1b, chống tâng bốc (R-7), cấm % (R-8), cấm streak (R-1 (f)), R-1g; BR-14 |
| AC-38 | R-15b — gói phủ toàn phần, "10 mục" không áp; BR-2 400 ô có hướng; BR-15 |
