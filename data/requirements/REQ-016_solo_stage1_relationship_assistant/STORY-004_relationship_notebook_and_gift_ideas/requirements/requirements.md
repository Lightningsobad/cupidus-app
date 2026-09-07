# Story Requirements: STORY-004 Gợi ý quà, và sổ tay / hồ sơ kỹ năng thu thập tại chỗ

- Requirement: REQ-016
- Story: STORY-004
- Complexity: complex
- Story-Class: shared-foundation
- Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
- Depends On: STORY-001
- Nguồn: `../story_brief.md`, `../story_master.md`,
  `../../req_master.md` → `## Invariant Design Rules`, `## Out of Scope`,
  `## Open Questions`; `../../requirements/requirements.md` →
  `## Story Index`, `## Open Question Triage`;
  `../../STORY-001_activity_card_hub/requirements/requirements.md` →
  hợp đồng mô hình thẻ và trạng thái

## Business Outcome

Người dùng nghĩ ra được **món quà có ý nghĩa cho đúng người này**, mà không cần
giàu và không cần điền hồ sơ trước. App hỏi đúng một câu nó còn thiếu, ngay lúc
người dùng đang cần, rồi dùng luôn câu trả lời đó.

Story cũng giao **kho ngữ cảnh dùng chung của cả requirement**: sổ tay người yêu
(sở thích + sự kiện) và hồ sơ kỹ năng "phiên bản tôi", cộng **cơ chế hỏi-tại-chỗ**
tái dùng được cho mọi cửa vào sau. Đây là hạ tầng STORY-005/008/009/010 đọc lại
để hết "gợi ý chung chung" — và là lý do SB-174 đặt sổ tay **trước** vỏ hoàng đạo.

### Cổng cứng

"Chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham gia
không?" → **CÓ.** Toàn bộ dữ liệu trong story này do chính người dùng nhập; đầu
ra là ý tưởng quà và thẻ trong kho của người dùng. Không AC nào cần người kia
trả lời, cài app, hay tồn tại trong hệ thống.

## Scope

### In Scope

Ba pha theo đúng thứ tự SB-174. Đây là **thứ tự pha bên trong một story**, không
phải ba story — giao riêng pha 1 thì sau merge không có gì quan sát được.

**Pha 1 — kho ngữ cảnh (SB-129 sổ tay + SB-197 hồ sơ kỹ năng):**

1. Kho dữ liệu sổ tay người yêu: **chỉ sở thích và sự kiện** (R-1f).
2. Kho dữ liệu hồ sơ kỹ năng "phiên bản tôi": những gì người dùng tự làm được.
3. **Cơ chế hỏi-tại-chỗ (SC-3)** — bề mặt dùng chung: một cửa vào cần một
   trường chưa có → hỏi **đúng một câu**, dùng luôn câu trả lời, âm thầm lưu.
4. Màn (2) Sổ tay và màn (3) Hồ sơ kỹ năng: chỉ **xem/sửa/xoá** cộng một nút
   "+ tự thêm". Không luồng điền-trước, không onboarding.

**Pha 2 — gợi ý quà (3a):**

5. Chỉ mục quà theo **dịp Việt × giai đoạn quen nhau × sổ tay**.
6. Nhánh **"quà không tốn tiền"**.
7. Lọc theo **thang CÔNG SỨC (số giờ)**, cộng bộ lọc nhanh "làm được trong 2
   tiếng tối nay".

**Pha 3 — quà handmade theo kỹ năng (3b / SB-206):**

8. Nhánh handmade sinh từ hồ sơ kỹ năng: kỹ năng → quà/hoạt động làm được.
9. **Chống rủi ro #2 (SB-199)**: cách hỏi kỹ năng không được kiểu CV.

**Xuyên suốt:**

10. **SC-2** — mỗi gợi ý đẩy được thành một thẻ vào kho chung của STORY-001.
11. Kiểm duyệt nội dung hai lớp (SB-123) cho kho quà.

### Out of Scope

- **Thương mại, affiliate, giá tiền, tên shop, link mua** — R-11 cấm tuyệt đối.
- Một "danh sách quà đã lưu" riêng cạnh tranh với màn (1) — vi phạm SC-1'.
- Xuất/chia sẻ sổ tay dưới mọi hình thức — R-1f cấm.
- Trường đánh giá con người trong sổ tay ("hay trả lời chậm", "hơi vô tâm") —
  R-1f và R-1b cấm.
- Bất kỳ luồng onboarding nào bắt điền sổ tay/kỹ năng trước khi dùng — SC-3.
- Mồi chuyện (STORY-005), chân dung (STORY-009), bảng tra ăn khớp (STORY-010).
- **Chặng 1.5, link hai chiều, feed tin thật, Zalo Mini App, J7** — binding out
  of scope của REQ-016.

## Acceptance Criteria

### Nhóm A — Cơ chế hỏi-tại-chỗ (SC-3, bề mặt dùng chung)

**AC-1.** Given người dùng mở "Gợi ý quà" lần đầu và sổ tay còn trống, when họ
xem gợi ý, then app hỏi **đúng một câu** nó còn thiếu, dùng luôn câu trả lời để
ra gợi ý ngay trong cùng luồng, và **không** hiển thị màn/toast "đã lưu vào hồ
sơ".

**AC-2.** Given app còn thiếu nhiều hơn một trường, when người dùng đang ở một
cửa vào, then app hỏi **một câu tại một thời điểm** và không bao giờ gộp thành
biểu mẫu nhiều trường; câu tiếp theo chỉ xuất hiện ở **lần cần tiếp theo**, không
nối đuôi ngay sau câu vừa trả lời.

**AC-3.** Given app đang hỏi một câu tại chỗ, when người dùng bỏ qua, then họ
vẫn nhận được gợi ý (rộng hơn, kém riêng hơn) và luồng **không** bị chặn; app
không hỏi lại câu đó ngay lập tức và không trách móc.

**AC-4.** Given người dùng đã trả lời một câu hỏi tại chỗ, when họ mở màn Sổ tay
hoặc Hồ sơ kỹ năng, then trường đó đã có mặt, sửa được và xoá được.

**AC-5.** Given bất kỳ cửa vào nào của story này, when người dùng vào lần đầu,
then **không tồn tại** luồng điền-trước/onboarding cho sổ tay hay hồ sơ kỹ năng
ở bất cứ đâu (SC-3).

### Nhóm B — Sổ tay người yêu, màn (2) (R-1f)

**AC-6.** Given người dùng nhập hoặc xem một mục sổ tay, when họ xem các trường
có thể ghi, then chỉ có **sở thích và sự kiện**; app **không cung cấp** trường
đánh giá con người, không có ô "nhận xét về người ấy", không có nhãn tính cách
do app gán.

**AC-7.** Given người dùng đang ở màn Sổ tay, when họ tìm cách đưa nội dung ra
ngoài, then app **không có** bất kỳ chức năng xuất/chia sẻ nào — không nút chia
sẻ, không copy toàn bộ, không xuất file, không Share Sheet (R-1f).

**AC-8.** Given người dùng mở màn Sổ tay hoặc Hồ sơ kỹ năng lần đầu, when màn
hiện ra, then màn chỉ gồm danh sách đã thu thập (có thể **rỗng**) và một nút
"+ tự thêm"; trạng thái rỗng là bình thường, không phải lỗi và không hối thúc
điền.

**AC-9.** Given một mục bất kỳ trong sổ tay hoặc hồ sơ kỹ năng, when người dùng
sửa hoặc xoá, then thay đổi có hiệu lực ngay và app không kịch tính hoá hành
động xoá (R-12, R-1c/R-1d).

### Nhóm C — Hồ sơ kỹ năng, màn (3) (rủi ro #2 / SB-199)

**AC-10.** Given hồ sơ kỹ năng còn trống, when app hỏi về kỹ năng, then câu hỏi
**không** ở dạng biểu mẫu CV và **không** là một ô trống "kỹ năng của bạn là
gì?"; nó là một câu cụ thể kèm bộ lựa chọn mồi chạm-để-chọn.

**AC-11.** Given app hiển thị bộ lựa chọn mồi kỹ năng, when người dùng nhìn bộ
đó, then bộ **bắt buộc chứa** kỹ năng "mềm" đời thường — tối thiểu "nhớ dai",
"biết chỗ ăn ngon", "gói quà đẹp", "chọn nhạc hợp cảnh" — và chúng hiển thị
**trước khi** người dùng phải gõ bất cứ gì.

**AC-12.** Given một kỹ năng đã có trong hồ sơ, when nó hiển thị, then app
**không** gắn mức độ, sao, điểm, hay xếp hạng thành thạo cho kỹ năng đó.

**AC-13.** Given hồ sơ kỹ năng rỗng, when người dùng mở nhánh quà handmade, then
app vẫn trả về gợi ý dùng được (rơi về nhánh pha 2), **không** hiện màn rỗng và
**không** đổ lỗi cho người dùng vì "chưa có kỹ năng nào".

### Nhóm D — Gợi ý quà và thang công sức (R-11)

**AC-14.** Given sổ tay có dữ liệu, when người dùng xem gợi ý quà, then bộ gợi ý
được lọc theo **dịp Việt × giai đoạn quen nhau × nội dung sổ tay**, và mỗi gợi ý
riêng-hoá nêu rõ nó dựa trên điều **người dùng đã tự nhập**.

**AC-15.** Given sổ tay còn trống, when người dùng xem gợi ý quà, then bộ kết
quả **vẫn không rỗng** và dùng được; app không biến sổ tay rỗng thành điều kiện
chặn.

**AC-16.** Given người dùng đang xem gợi ý quà, when họ dùng bộ lọc công sức,
then lựa chọn là **số giờ**, và **không có bất kỳ mức giá VNĐ, khoảng giá, hay
nhãn rẻ/đắt nào** ở bất cứ đâu trên màn (R-11).

**AC-17.** Given người dùng bấm bộ lọc "làm được trong 2 tiếng tối nay", when
kết quả hiện ra, then **mọi** gợi ý trong kết quả đều nằm trong ngưỡng công sức
đó.

**AC-18.** Given người dùng chọn nhánh "quà không tốn tiền", when kết quả hiện
ra, then nhánh này tồn tại như một nhánh/bộ lọc riêng và trả về kết quả không
rỗng.

**AC-19.** Given bất kỳ gợi ý quà nào, when nó hiển thị, then **không** có link
mua, tên cửa hàng, mã giảm giá, hay bất kỳ đường đi thương mại/affiliate nào
(R-11).

**AC-20.** Given hồ sơ kỹ năng có ít nhất một kỹ năng, when người dùng mở nhánh
handmade, then mỗi gợi ý handmade **nêu rõ nó sinh từ kỹ năng nào** của người
dùng, kèm ước lượng công sức theo giờ.

### Nhóm E — Kho duy nhất và không phải điểm dừng chân (SC-1', SC-2)

**AC-21.** Given người dùng chọn một gợi ý quà, when họ bấm hành động chính,
then một thẻ mới xuất hiện trong màn (1) ở trạng thái *Mới nghĩ ra*, theo đúng
mô hình thẻ của STORY-001, và mang **nguồn sinh** "gợi ý quà".

**AC-22.** Given người dùng đã đẩy nhiều gợi ý thành thẻ, when họ quay lại màn
Gợi ý quà, then màn này **không giữ** một danh sách "quà đã lưu" riêng; nơi duy
nhất chứa thứ đã chọn là kho chung của màn (1) (SC-1').

**AC-23.** Given một thẻ được tạo từ gợi ý quà, when thẻ được lưu, then trường
`giá` của mô hình thẻ **để trống** và luồng quà không bao giờ ghi hay hiển thị
nó — mô hình thẻ STORY-001 có trường đó, nhưng R-11 cấm luồng này dùng nó.

**AC-24.** Given người dùng đang xem một gợi ý quà bất kỳ, when họ xem gợi ý
đó, then luôn có ít nhất một đường đi tiếp — đẩy thành thẻ, hoặc quay lại bộ lọc
— không gợi ý nào là ngõ cụt (SC-5).

### Nhóm F — Ranh giới đạo đức (R-1, R-1b, R-1e, R-1g, R-7)

**AC-25.** Given bất kỳ màn nào của story này, when màn hiển thị, then app
**không** lưu và **không** hiển thị bất kỳ đại lượng hành vi nào của người kia:
không "đã xem", không giờ mở, không tần suất, không nhận định kiểu "hay trả lời
chậm" (R-1b).

**AC-26.** Given một nội dung trên màn này nói về người kia, when nội dung hiển
thị, then nó **kết thúc bằng một câu để hỏi người thật**, không bằng một kết
luận về người kia, và mọi phần đoán vẫn ở tầng "user ghi" hoặc "user đoán"
(R-1e, R-1g).

**AC-27.** Given bất kỳ gợi ý quà nào, when nội dung gợi ý hiển thị, then nó
**không** đóng khung như chiến thuật hay kịch bản thao túng ("tặng cái này thì
chắc chắn đổ"), và không hứa hẹn phản ứng của người kia (R-1 nấc 3, cấm (e)).

**AC-28.** Given cùng một bộ đầu vào (dịp, giai đoạn, sổ tay, kỹ năng, bộ lọc),
when người dùng xem gợi ý ở hai lần khác nhau, then kết quả **tất định như
nhau**; không gọi mô hình AI, không gọi API nội dung bên ngoài ở bất kỳ đường đi
nào (R-7).

**AC-29.** Given bất kỳ phần nào của sổ tay, hồ sơ kỹ năng, hay gợi ý quà, when
người dùng dùng nó, then **không** phần nào nằm sau paywall (R-14), và **không**
có streak, huy hiệu, hay bảng xếp hạng (R-1, cấm (f)).

### Nhóm G — Cổng cứng và kiểm duyệt nội dung

**AC-30.** Given người dùng chưa từng có, và sẽ không bao giờ có, phản hồi từ
người kia, when họ dùng story này, then **mọi** AC ở trên vẫn đạt được.

**AC-31.** Given kho nội dung quà và bộ mồi kỹ năng chuẩn bị ra bản build người
dùng thật, when nội dung được đưa vào, then điều kiện ship là **(a)** mọi mục đã
qua **cổng nhập chạy được** ở AC-35 (R-15c), và **(b)** trạng thái duyệt ghi lại
truy vết được **theo id bền của từng mục** (AC-32). Kiểm duyệt hai lớp (SB-123)
vẫn giữ cho **chất lượng biên tập** — giọng, độ sượng, tính dùng được — nhưng
**không** còn là cổng chặn ship và **không** là cơ chế cưỡng chế luật bất biến.
AC này **không còn bị chặn**: OQ-3 đã đóng 2026-09-06 bằng D-15.

### Nhóm H — Nội dung là dữ liệu có cổng nhập (R-15 / D-15)

**AC-32.** Given kho ý tưởng quà, bộ mồi kỹ năng, và **bảng tra chỉ mục quà**
(ánh xạ ngữ cảnh sổ tay → mục quà), when chúng được ship, then chúng là **gói dữ
liệu có lược đồ và định danh bền cho từng mục** — gồm cả thang công sức và các
nhãn nhánh — không phải chuỗi cứng trong widget/code; đổi nguồn nội dung sang
CMS ngoài repo **không kéo theo một lần sửa code** (R-15a).

**AC-33.** Given kho ý tưởng quà có **N mục bất kỳ** (N ≥ 1), when người dùng
liên tục yêu cầu gợi ý tiếp theo cho tới khi duyệt hết các mục khớp, then hành
vi hết-tập là **trạng thái êm đã định** — suy giảm sang bộ gợi ý rộng hơn theo
BR-3 hoặc quay vòng tất định — **không** thông báo "đã hết ý tưởng", **không**
màn ngõ cụt, và **không** chỉ báo tiến độ, phần trăm, hay số mục còn lại dưới
bất kỳ dạng nào. Luật này đúng với mọi N — 3, 10, hay vài trăm — và **không** AC
nào của story này được suy ra từ việc kho seed có 10 mục (R-15b).

**AC-34.** Given bộ lọc "2 tiếng tối nay", nhánh không-tốn-tiền, và nhánh
handmade, when kho có N nhỏ tới mức một nhánh **không còn mục nào khớp**, then
màn rơi vào trạng thái rỗng đã định của nhánh đó mà không báo lỗi và không ô
trống giữ chỗ; when kho có N rất lớn, then hành vi lọc/chỉ mục **không đổi** và
không có bước tải/đợi mới. Số bậc của thang công sức và số nhánh là **thuộc tính
dữ liệu**, không đặt ràng buộc nào lên N (R-15a/R-15b).

**AC-35.** Given một mục nội dung vi phạm luật bất biến — đo hành vi người kia
(R-1b), tâng bốc, hiển thị %, streak, chỉ mục quà theo **VNĐ** thay vì theo
thang công sức (R-11), hoặc câu nói về người kia không kết bằng câu hỏi (R-1g) —
when mục đó được nạp qua cổng nhập nội dung, then cổng **từ chối mục đó và làm
hỏng bản dựng**; vi phạm **không** được phép lọt tới lúc người dùng đọc. Cổng
chạy được kể cả với nội dung do CMS ngoài repo cấp, tức nội dung **không** đi
qua review của repo này (R-15c).

**AC-36.** Given một mục của **bộ câu hỏi hỏi-tại-chỗ** vi phạm R-1f ở tầng ĐẦU
VÀO — hỏi về **tần suất, hành vi, hoặc đánh giá con người** thay vì sở thích/sự
kiện (BR-4) — when mục đó được nạp qua cổng nhập, then cổng **từ chối mục đó và
làm hỏng bản dựng**. Ranh giới sổ tay phải là quy tắc validation chạy được, vì
một câu **hỏi** sai làm bẩn sổ tay ngay từ đầu vào và không sửa được ở đầu ra
(R-15c).

## Business Rules

- **BR-1 (SC-3 — không điền trước).** Dữ liệu sổ tay và kỹ năng chỉ vào hệ thống
  bằng **hỏi-tại-chỗ** hoặc **"+ tự thêm"** do người dùng chủ động. Mọi luồng
  bắt điền trước khi dùng là vi phạm, kể cả khi gọi tên là "thiết lập nhanh".
- **BR-2 (một câu một lần).** Cơ chế hỏi-tại-chỗ hỏi tối đa **một** trường cho
  một lần cần. Gộp hai câu liên tiếp trong cùng một luồng là biểu mẫu trá hình.
- **BR-3 (hỏi được là tuỳ chọn).** Bỏ qua câu hỏi không bao giờ chặn kết quả.
  Kết quả suy giảm êm sang bộ gợi ý rộng hơn.
- **BR-4 (R-1f — ranh giới sổ tay).** Sổ tay ghi **sở thích + sự kiện** ✅ · ghi
  **tần suất + hành vi + đánh giá con người** ❌. Không có chức năng xuất/chia sẻ,
  và không được thêm sau này mà không sửa invariant.
- **BR-5 (rủi ro #2 / SB-199 — guardrail cứng).** Hồ sơ kỹ năng không bao giờ
  trình bày kiểu CV. Cách hỏi mặc định là **nhận diện từ bộ mồi**, không phải
  **tự khai vào ô trống**. Bộ mồi phải chứa kỹ năng mềm đời thường; hỏi kiểu CV
  làm ~80% trả lời "không có" và làm sập cả nhánh handmade.
- **BR-6 (R-11 — thang công sức).** Chỉ mục quà đánh chỉ số theo **số giờ**.
  VNĐ, khoảng giá, nhãn rẻ/đắt, link mua, affiliate bị cấm ở mọi bề mặt của
  story này. Quà chỉ là **Ý TƯỞNG**.
- **BR-7 (SC-1' — một kho).** Story này ghi **vào** kho thẻ của STORY-001. Không
  tạo danh sách quà riêng, kể cả dưới tên "yêu thích" hay "để dành".
- **BR-8 (SC-2 — không phải điểm dừng chân).** Mỗi gợi ý phải có hành động đẩy
  thành thẻ. Một màn gợi ý chỉ để đọc là vi phạm.
- **BR-9 (hợp đồng thẻ STORY-001).** Thẻ sinh từ luồng quà dùng nguyên mô hình
  thẻ và bốn trạng thái của STORY-001, vào ở *Mới nghĩ ra*, mang **nguồn sinh**
  theo AC-9 của STORY-001. Story này **không** thêm trạng thái, không đổi hợp
  đồng thẻ, và để trống trường `giá` (BR-6).
- **BR-10 (R-7 — không AI ở runtime).** Chỉ mục quà và bộ mồi kỹ năng là **bảng
  tra tay** ship như gói dữ liệu; runtime tất định. AI chỉ dùng ngoài hệ thống ở
  khâu soạn nội dung.
- **BR-11 (SB-174 — thứ tự pha bắt buộc).** Sổ tay/kỹ năng (pha 1) → quà (pha 2)
  → handmade (pha 3). Tech Lead phải giữ nguyên thứ tự này trong
  `coding-plan/master-plan.md`; làm ngược lại cho ra gợi ý chung chung.
- **BR-12 (R-1e / R-1g).** Ba tầng: user ghi ✅ · user đoán, app không xác nhận ✅
  · app suy luận/chấm điểm người kia ❌. Mọi nội dung nói về người kia kết thúc
  bằng một câu để hỏi.
- **BR-13 (R-13 — khoá vị trí, đối chiếu).** Story này **không** thuộc nhóm khoá
  vị trí. "Gợi ý quà" có đường vào riêng từ menu chính (nhóm CỬA VÀO); Sổ tay và
  Hồ sơ kỹ năng có đường vào từ menu (nhóm KHO) nhưng chỉ để **xem/sửa**. R-13
  chỉ áp cho STORY-009 và STORY-010.
- **BR-14 (SB-123 — kiểm duyệt hai lớp, cho CHẤT LƯỢNG BIÊN TẬP).** Kho nội dung
  quà đi qua kiểm duyệt hai lớp cho giọng, độ sượng, và tính dùng được; rủi ro
  triển khai #1 là **sượng**. Sau D-15, kiểm duyệt hai lớp **không** còn là cổng
  chặn ship và **không** là cơ chế cưỡng chế luật bất biến — việc đó thuộc cổng
  nhập chạy được (BR-18).
- **BR-15 (kho ngữ cảnh là bề mặt dùng chung).** Hình dạng dữ liệu sổ tay + hồ
  sơ kỹ năng và API của cơ chế hỏi-tại-chỗ là hợp đồng cho STORY-005/008/009/010.
  Đổi hình dạng sau story này là thay đổi phá vỡ hợp đồng.
- **BR-16 (R-15a — nội dung là dữ liệu, không phải chuỗi trong code).** Kho ý
  tưởng quà, bộ mồi kỹ năng, bộ câu hỏi hỏi-tại-chỗ, và bảng tra chỉ mục quà là
  gói dữ liệu có lược đồ, mỗi mục có **id bền** dùng làm khoá tham chiếu và khoá
  truy vết duyệt. Cấm chuỗi nội dung nằm trong widget/code. Tiêu chí nghiệm thu:
  đổi nguồn sang CMS ngoài repo mà **không sửa một dòng code nào**. Ràng buộc
  này **cộng thêm** vào BR-15: hợp đồng dùng chung là hình dạng dữ liệu, nên nó
  cũng phải là **lược đồ** chứ không phải cấu trúc code.
- **BR-17 (R-15b — N là thuộc tính dữ liệu).** Số mục quà, số bậc thang công
  sức, số nhánh, và số câu hỏi hỏi-tại-chỗ là dữ liệu bản đầu, **không** phải
  hằng số của story; bộ seed 10 mục cho gói **xoay vòng** là giá trị bản đầu.
  Cấm mọi AC, BR, hay bố cục dựa vào "vì có đúng 10 mục nên…" — đặc biệt hành vi
  hết-tập (AC-33), trạng thái rỗng của từng nhánh (AC-34), và chỉ báo tiến độ.
- **BR-18 (R-15c — luật bất biến là CỔNG NHẬP, không phải quy ước biên tập).**
  R-1b, R-1f (ranh giới sổ tay, cả tầng đầu vào của bộ câu hỏi — xem BR-4),
  R-1g, R-11 (chỉ mục theo công sức, **không** theo VNĐ), chống tâng bốc, cấm
  hiển thị %, và cấm streak được cưỡng chế ở **tầng lược đồ/validation của cổng
  nhập nội dung**, chạy được trong bản dựng. Nội dung vi phạm bị từ chối tại
  cổng và làm hỏng bản dựng (AC-35, AC-36).

## System Integration And Discoverability

- **UI-facing story:** YES.
- **Existing user-visible surface:** YES — kho thẻ ở màn (1) do STORY-001 giao.
  Đầu ra của gợi ý quà gắn lên bề mặt đã có đó.
- **Điểm vào "Gợi ý quà":** đường vào riêng từ menu chính, **nhóm CỬA VÀO** —
  màn (5).
- **Điểm vào Sổ tay (màn 2) và Hồ sơ kỹ năng (màn 3):** đường vào từ menu, **nhóm
  KHO**, và chỉ để xem/sửa/xoá. Chúng **không phải** cửa vào để điền trước; vào
  từ menu và thấy danh sách rỗng là hành vi đúng.
- **Hợp đồng cho story sau (shared-foundation):** kho ngữ cảnh (sổ tay + kỹ
  năng) và cơ chế hỏi-tại-chỗ là hạ tầng dùng chung. STORY-005 (mồi chuyện),
  STORY-008 (kịch bản), STORY-009 (chân dung), STORY-010 (bảng tra) **đọc thêm**
  kho này; không story nào trong số đó cần story này thay đổi để chạy được.
- **Tích hợp bên ngoài:** KHÔNG. Không API nội dung, không dịch vụ AI, không
  backend sinh nội dung, không Share Sheet (R-1f cấm chia sẻ sổ tay).

## Open Question Impact

### Scope Items BLOCKED in this story

- **Không còn scope item nào của story này bị chặn bởi câu hỏi mở.** OQ-3 — mục
  duy nhất từng chặn (AC-31) — đã đóng 2026-09-06 bằng D-15.

### Scope Items NOT BLOCKED in this story

- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Câu trả lời không phải "chỉ định người duyệt lớp 2" mà là đổi bản
  chất nội dung: dữ liệu có schema + id bền, N là thuộc tính dữ liệu, luật bất
  biến cưỡng chế ở cổng nhập chạy được.
  - **Hết chặn:** ship kho nội dung quà và bộ mồi kỹ năng vào bản build người
    dùng thật (AC-31) không còn chờ user chỉ định người duyệt lớp 2. Điều kiện
    ship nay là qua cổng nhập chạy được cộng truy vết duyệt theo id bền.
  - **Thành ràng buộc mới của story:** AC-32..AC-36 và BR-16/BR-17/BR-18.
  - **Điểm riêng của story này:** bộ câu hỏi **hỏi-tại-chỗ** chịu cổng nhập ở
    tầng ĐẦU VÀO (AC-36) — ranh giới sổ tay R-1f (sở thích + sự kiện ✅ · tần
    suất + hành vi + đánh giá ❌) phải là quy tắc validation chạy được, không
    phải quy ước biên tập, vì một câu **hỏi** sai làm bẩn sổ tay ngay từ đầu vào.
  - **Ràng buộc R-11 vào cổng:** chỉ mục quà theo **thang công sức**, cấm chỉ mục
    theo VNĐ, cũng cưỡng chế ở cổng nhập (AC-35), không chỉ ở khâu biên tập.
  - **Còn lại của SB-123:** kiểm duyệt hai lớp giữ nguyên cho chất lượng biên
    tập (BR-14), nhưng hạ từ **chặn ship** xuống **rủi ro chất lượng nội dung**,
    sửa được bằng đổi dữ liệu mà không sửa code.
  - **OQ-3 chưa bao giờ chặn:** engine chỉ mục quà, thang công sức, bộ lọc "2
    tiếng tối nay", nhánh không-tốn-tiền, nhánh handmade, kho ngữ cảnh sổ tay +
    kỹ năng, cơ chế hỏi-tại-chỗ, hai màn xem/sửa, và toàn bộ AC nhóm A/B/C/E/F/G.

- **L45 / OQ-18 — ĐÓNG** (user chốt 2026-09-03: chặng 1 là **kho tài sản**,
  không phải phòng chờ). Không relitigate. Story này không chịu tải định vị; ba
  story chịu tải là STORY-001, STORY-012, STORY-013.
- **Rủi ro #2 (SB-199) — KHÔNG phải câu hỏi mở.** Đã chuyển thành guardrail cứng
  BR-5 và AC-10/AC-11/AC-12/AC-13. Không cần user quyết.
- **SB-174 — ĐÓNG, đã hấp thụ.** Sống trong story này dưới dạng **thứ tự pha**
  (BR-11), không phải ranh giới story.
- **OQ-2 (một ngăn hay nhiều ngăn) — ĐÓNG ở tầng sản phẩm**, và thuộc phạm vi
  STORY-001. Story này chỉ đẩy thẻ vào ngăn *Mới nghĩ ra*.
- **Chặng 1.5 / link hai chiều / feed tin thật / Zalo Mini App / thương mại quà
  / J7 — ĐÓNG, binding out of scope** của REQ-016. Không mở lại ở story này.
- **Sổ tay/kỹ năng không gắn người cụ thể sống sót qua lối ra J11** — thuộc
  STORY-013, không phải câu hỏi mở của story này.
- **Chi tiết trình bày** (cách bố trí bộ lọc công sức, hình thức bộ mồi kỹ năng,
  vị trí câu hỏi tại chỗ trong luồng, trạng thái rỗng của màn (2)/(3)) — giao
  **UI/UX Designer trong phạm vi story này**. Là quyết định UX, không phải câu
  hỏi sản phẩm còn mở.
- **SB-144/145/146 (trò chơi "đoán") — HOÃN**, không gán vào story này.

## Traceability

| AC | Nguồn ràng buộc |
|----|-----------------|
| AC-1..AC-5 | SC-3 không điền trước, cơ chế hỏi-tại-chỗ, SB-129/SB-197 |
| AC-6..AC-9 | R-1f, R-12, R-1c/R-1d |
| AC-10..AC-13 | Rủi ro #2 / SB-199, R-1e |
| AC-14..AC-20 | R-11 thang công sức, 3a/3b, SB-206 |
| AC-21..AC-24 | SC-1', SC-2, SC-5, hợp đồng thẻ STORY-001 |
| AC-25..AC-29 | R-1 nấc 3, R-1b, R-1e, R-1g, R-7, R-14 |
| AC-30 | Cổng cứng REQ-016 |
| AC-31 | SB-123 kiểm duyệt hai lớp (chất lượng biên tập); OQ-3 ĐÃ ĐÓNG bằng D-15 |
| AC-32 | R-15a — schema + id bền, đổi nguồn sang CMS không sửa code |
| AC-33, AC-34 | R-15b — N là thuộc tính dữ liệu; hết-tập và trạng thái rỗng đúng với mọi N |
| AC-35, AC-36 | R-15c — cổng nhập chạy được; R-1b, R-1f (đầu vào), R-1g, R-11 công sức không VNĐ |
| BR-16..BR-18 | D-15 / R-15 (`req_master.md` mục 15) |
