# UX Spec: STORY-004 Gợi ý quà, và sổ tay / hồ sơ kỹ năng thu thập tại chỗ

Requirement: REQ-016 · Story-Class: shared-foundation · Depends On: STORY-001
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md`. `DESIGN_SOURCE_NOT_DETECTED` bình thường —
spec dùng luật đo được. Giữ nguyên thứ tự pha SB-174 (sổ tay → quà → handmade)
làm thứ tự trình bày dưới đây, khớp thứ tự Tech Lead phải giữ trong
`coding-plan/master-plan.md`.

## 0. Ba màn, hai kiểu lối vào

- Màn (5) "Gợi ý quà" — nhóm CỬA VÀO, lối vào từ **ô 1 của dải lối-vào-nhanh**
  trên tab Nhà (định nghĩa ở `STORY-001/ux/uiux-spec.md` mục 6).
- Màn (2) "Sổ tay người yêu" và màn (3) "Hồ sơ kỹ năng" — nhóm KHO, lối vào từ
  tab **"Tôi"** → khối "Kho riêng của tôi" (cùng khối chứa hàng "Nhật ký riêng"
  của STORY-003) — thêm **hai** hàng `_MenuRow` mới ở đây.

## Phần A — Cơ chế hỏi-tại-chỗ (bề mặt dùng chung, SC-3)

Đây là component quan trọng nhất của story vì STORY-005/008/009/010 tái dùng
nguyên nó. Không được vẽ khác ở các story sau.

**Hình thức:** một thẻ hỏi inline chèn **ngay trong luồng đang chạy** (ví dụ
giữa danh sách gợi ý quà), KHÔNG phải dialog che màn, KHÔNG phải điều hướng
sang màn khác. Bố cục:
- Một câu hỏi ngắn, `body 17pt`, tối đa 1 câu.
- Bộ lựa chọn mồi dạng chip chạm-để-chọn (không phải ô nhập tự do làm lựa
  chọn mặc định — xem Phần C cho lý do với hồ sơ kỹ năng); có thể có ô nhập
  tự do "khác..." ở cuối dải chip cho ai muốn tự gõ.
- Một liên kết văn bản nhỏ "Bỏ qua" — bấm vào để tiếp tục luồng với kết quả
  rộng hơn, không hỏi lại câu này ngay lập tức (AC-3).
- **Không có nút "Lưu vào hồ sơ"** và không có toast/snackbar "Đã lưu vào hồ
  sơ" sau khi trả lời (AC-1) — câu trả lời biến mất khỏi vị trí hỏi và kết
  quả cập nhật ngay tại chỗ, coi như một bước lọc bình thường của luồng, không
  phải một hành động "ghi dữ liệu" tách biệt.
- **Đúng một câu hỏi tại một thời điểm** (AC-2, BR-2): không bao giờ xếp hai
  thẻ hỏi liên tiếp trong cùng một lượt xem; câu tiếp theo (nếu còn thiếu
  trường khác) chỉ xuất hiện ở lần cần kế tiếp (lần mở màn sau, hoặc bước
  tiếp theo của luồng khác), không nối đuôi ngay.

## Phần B — Sổ tay người yêu, màn (2)

- Header: "Sổ tay người yêu". Không phụ đề kiểu "hãy điền để app hiểu người
  ấy hơn" (tránh ngụ ý cần hoàn thành).
- Danh sách mục dạng nhóm theo loại: "Sở thích" và "Sự kiện" là hai nhóm cố
  định (2 group header, mỗi group là danh sách hàng đơn giản: nội dung +
  nút sửa/xoá dạng menu "...").
- **Chỉ hai loại trường tồn tại trên màn: sở thích và sự kiện.** Không có
  trường "nhận xét", không có ô văn bản tự do gắn nhãn "ghi chú về người ấy"
  ở ngoài hai nhóm này (AC-6) — nếu cần một ô ghi chú tự do, nó phải nằm
  *bên trong* một mục sự kiện/sở thích cụ thể (mô tả thêm cho chính mục đó),
  không phải một nhóm thứ ba độc lập.
- Nút "+ tự thêm" cố định ở cuối danh sách mỗi nhóm — mở một hàng nhập inline
  (không mở dialog riêng), chọn nhóm (sở thích/sự kiện) bằng segmented nhỏ 2
  lựa chọn ngay trong hàng nhập đó.
- **Không có icon/menu chia sẻ hay xuất ở bất kỳ đâu trên màn** (AC-7) — như
  Nhật ký, đây là vắng mặt bắt buộc, kể cả trong menu "..." của từng mục (chỉ
  được chứa Sửa/Xoá).
- Trạng thái rỗng: trung tính, danh sách trống + nút "+ tự thêm" luôn hiện,
  không câu mời gọi, không banner "hãy điền ngay" (AC-8).

## Phần C — Hồ sơ kỹ năng, màn (3) — chống rủi ro #2 (SB-199)

- Header: "Những gì bạn giỏi" (tránh chữ "hồ sơ"/"CV" trong copy chính, dù
  tên nội bộ vẫn là "hồ sơ kỹ năng").
- **Không mở bằng ô nhập tự do trống.** Khi trống, cơ chế hỏi-tại-chỗ (Phần A)
  hiển thị trước tiên một **dải chip mồi kỹ năng đời thường**, tối thiểu 4
  chip luôn có mặt trước khi người dùng gõ bất cứ gì: "Nhớ dai", "Biết chỗ ăn
  ngon", "Gói quà đẹp", "Chọn nhạc hợp cảnh" (AC-11) — các chip này được thiết
  kế thị giác **bình đẳng** với mọi chip mồi khác, không tách riêng thành
  "nhóm phụ" nhỏ hơn hay mờ hơn.
- Danh sách kỹ năng đã có: mỗi hàng chỉ có tên kỹ năng — **không sao, không
  điểm, không thanh mức độ thành thạo, không huy hiệu cấp độ** (AC-12). Đây
  là điểm khác biệt rõ với bất kỳ pattern "kỹ năng game hoá" nào có thể có
  sẵn trong design system — cấm dùng ở màn này.
- Trạng thái rỗng của **nhánh handmade** khi hồ sơ trống (AC-13): không hiện
  màn rỗng riêng, tự động hiện gợi ý pha 2 (quà không cần kỹ năng) kèm một
  dòng nhỏ, trung tính, mời thêm kỹ năng — không đổ lỗi ("bạn chưa có kỹ năng
  nào" là cách nói bị cấm; dùng "Thêm điều bạn giỏi để có gợi ý riêng hơn").

## Phần D — Gợi ý quà, màn (5), pha 2 và 3

**Bố cục màn:**
1. Header + bộ lọc ngang trên đầu: 2 nhánh dạng tab/segmented — "Theo dịp" và
   "Không tốn tiền" (AC-18) — cộng một chip lọc nhanh "2 tiếng tối nay"
   (AC-17, luôn hiện cạnh 2 nhánh, không lồng trong menu phụ).
2. **Bộ lọc công sức**: thanh chọn theo **số giờ** (ví dụ slider hoặc nhóm
   chip "≤1 giờ / ≤2 giờ / cả ngày+") — không có bất kỳ chữ số VNĐ, ký hiệu
   "₫", hay nhãn rẻ/đắt ở bất cứ đâu trên màn (AC-16, AC-19). Đây là ràng
   buộc thị giác cứng: nếu component chọn khoảng có sẵn trong design system
   là loại "price range slider", KHÔNG dùng nguyên nó — phải là biến thể chỉ
   có đơn vị giờ.
2b. **Dải "dựa trên"** ngay dưới hai hàng lọc: một dòng `caption` nhắc cả tập
   gợi ý đang dựa trên cái gì — kỹ năng người dùng tự khai và số dòng họ đã
   viết trong sổ tay ("Dựa trên việc bạn làm được (…) × sổ tay (N dòng)").
   Chỉ nói lại thứ người dùng đã nhập: không phải đại lượng về người kia
   (AC-25), không phải thanh tiến độ/điểm hoàn thiện (AC-33). Người chưa viết
   gì thì không hiện dải này.
3. Danh sách gợi ý dạng thẻ (tái dùng bo góc `--r-card`, khác nội dung thẻ
   hoạt động của STORY-001): tên ý tưởng, ước lượng giờ, và **một dòng nhỏ nêu
   căn cứ do chính người dùng nhập** cho *mọi* gợi ý riêng-hoá, không riêng
   nhánh handmade: "từ kỹ năng: <tên kỹ năng>" ở nhánh tự làm (AC-20), "từ sổ
   tay: <sở thích>" khi khớp sở thích, "từ dịp bạn đã ghi: <dịp>" khi khớp
   dịp. Đây là yêu cầu của AC-14 vế 2 và của Phần E dưới đây: một gợi ý
   riêng-hoá mà không nói căn cứ thì không đọc được là "câu trần thuật dựa
   trên dữ liệu đã nhập". Gợi ý không khớp gì thì không có dòng này (không bịa
   căn cứ).
3b. **Hai hình dạng thẻ.** Thẻ dẫn đầu là thẻ đầy đủ (hàng meta + tiêu đề + mô
   tả + dòng căn cứ + hành động chính). Các thẻ sau là thẻ gọn: huy hiệu số
   phút, tiêu đề, dòng căn cứ, và một nút tròn thêm-vào — không mô tả, không
   pill gradient thứ hai. Bỏ qua thẻ dẫn đầu sẽ đẩy thẻ kế tiếp lên hình dạng
   đầy đủ, nên không gợi ý nào bị kẹt mãi ở dạng gọn.
4. Mỗi thẻ gợi ý có đúng **một hành động chính**: pill "+ Thêm vào Muốn làm"
   (AC-21) — bấm tạo thẻ hoạt động mới ở STORY-001, ngăn *Mới nghĩ ra*. Nhãn
   gọi thẳng tên tab "Muốn làm" của thanh tab pha 1 (quyết định D-3) để người
   dùng biết thẻ sẽ nằm ở đâu; nó **không** là kho thứ hai — vẫn đúng một kho
   chung (SC-1'/AC-22). Không có hành động phụ "lưu để xem sau" cạnh đó — nếu
   người dùng muốn giữ lại, hành động **là** việc thêm vào kho chung
   (SC-1'/SC-2, AC-22): không có trạng thái "đã lưu" trung gian nào khác.
4b. **Bỏ qua một gợi ý**: một nút tròn `×` nhỏ, đặt cạnh pill của thẻ dẫn đầu.
   Nó chỉ ẩn gợi ý trong phiên xem màn này và **không ghi gì xuống** — không
   có bảng "đã bỏ qua", rời màn rồi quay lại là gợi ý trở lại. Một danh sách
   từ chối được nhớ vừa là kho thứ hai (AC-22) vừa là hồ sơ gu của người dùng
   mà không ai yêu cầu giữ.
5. Không hiển thị trường `giá` ở bất kỳ đâu trên các thẻ gợi ý (AC-23) — kể cả
   khi thẻ hoạt động ở STORY-001 có ô giá, luồng này không bao giờ điền hay
   hiện nó.
6. Không có link, tên cửa hàng, hay mã giảm giá trên bất kỳ thẻ gợi ý nào
   (AC-19).

**Liên kết khoá vị trí (STORY-009/010):** đặt ở cuối màn (dưới danh sách gợi
ý, không phải đầu màn), dạng **một hàng bấm được kiểu thẻ**: đĩa tròn `?` ở
đầu, câu "Bí quá thì thử đoán xem người ấy thích kiểu quà nào", chevron `›` ở
cuối. Đây là hình dạng bản thiết kế màn (5) vẽ, và với màn này bản thiết kế là
mốc neo (tiền lệ STORY-001, D-1/D-2/D-3) — nó thay cho mô tả "liên kết văn bản
nhỏ" trước đây. Hình dạng đổi nhưng thứ hạng không đổi: nền phẳng, viền mảnh,
không gradient, không styling chính, nằm dưới mọi gợi ý — vẫn là lối đi phụ,
không phải điểm đến chính của màn Gợi ý quà.

Bấm vào hàng này phải **trả lời** chứ không được im lặng: khi STORY-009/010
chưa dựng, nó hiện thông báo ngắn nói hai bề mặt đó sẽ có ở bước sau (cùng
cách thanh nhập nhanh của màn (1) trả lời cho ô chưa mở). Một hàng trông bấm
được mà bấm không ra gì là ngõ cụt, thứ AC-24/SC-5 cấm.

## Phần E — Ranh giới đạo đức thể hiện trong UI (xuyên suốt cả 3 màn)

- Không nơi nào trong 3 màn hiển thị đại lượng hành vi người kia (AC-25).
- Bất kỳ dòng mô tả nào nhắc tới người kia (ví dụ dòng riêng-hoá "vì [Tên]
  thích..." trong thẻ gợi ý) phải là câu trần thuật dựa trên dữ liệu đã nhập,
  không phải kết luận đóng — nếu cần một câu hỏi kèm theo, đặt nó ở cuối dòng
  mô tả, `caption`, ví dụ: "...— thử hỏi xem có đúng không?" (AC-26).
- Không đóng khung gợi ý như chiến thuật đảm bảo phản ứng ("tặng cái này thì
  chắc chắn đổ") — đây là ràng buộc nội dung/copy, ghi lại để đội nội dung
  (R-15) và Reviewer đối chiếu (AC-27).
- Không paywall, không huy hiệu/streak ở bất kỳ đâu trong 3 màn (AC-29).

## Phần F — Kiểm duyệt nội dung (R-15 — cổng nhập nội dung, không chặn phần UI)

Giống STORY-002 mục 7: khi kho nội dung quà/bộ mồi kỹ năng chưa qua kiểm
duyệt hai lớp, toàn bộ 3 màn vẫn xây và verify bằng nội dung placeholder nội
bộ; không cần thiết kế trạng thái "đang chờ duyệt" cho người dùng cuối.

## Completion
AC-31 (ship nội dung quà thật) có điều kiện ship là R-15: qua cổng nhập nội
dung chạy được (R-15c) và có truy vết duyệt qua id bền — không còn chờ user
chỉ định người duyệt lớp 2. Mọi quyết định bố cục/tương tác ở trên không bị
chặn. Spec đầy đủ cho cả 3 pha và 3 màn.
