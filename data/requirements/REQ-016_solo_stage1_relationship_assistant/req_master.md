# Requirement Master: REQ-016 Solo Stage-1 relationship assistant
Status: IN_PROGRESS
Ready-For-Delivery: YES

Breakdown: `requirements/requirements.md` (Product Owner, 2026-09-06)

Source: `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/idea.md`
Handover: `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/development.md` → `### ★★ BẢN BÀN GIAO CUỐI (v8)`
Structure spec: `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/idea.md` → `## Đặc tả sản phẩm (vòng 9-10)`

Supersedes cancelled REQ-013. No backward compatibility with its deleted stories.

Design-Surface: cupid-ch-ng-1
<!-- Chặng 1 has its own canvas (`Cupid Chặng 1.dc.html`, 29 labelled screens).
     Anchored at the requirement so no story re-answers it: STORY-003 picked
     `s1:diary` by meaning on 2026-09-07, a valid id belonging to the PAIRED
     app's canvas, and rendered five references plus a PASS against it. -->

Design-Source: UPDATED 2026-09-07T10:24:23Z (applied) — Operator đã xoá `Cupid Chặng 1 Screens.dc.html` khỏi bundle để chỉ còn một canvas Chặng 1 duy nhất, nên story không phải khai `Design-Surface:` để chọn giữa hai bản. Re-detect để bỏ nguồn `cupid-ch-ng-1-screens` đã chết.

Design-Source: UPDATED 2026-09-07T10:19:31Z (applied) — Lần re-detect trước loại hẳn canvas Chặng 1 vì detector chỉ nhận canvas khai `data-screen-btn`. `Cupid Chặng 1.dc.html` bày 29 khung màn cạnh nhau, mỗi khung có tiêu đề, nên vẫn là design surface đầy đủ. Detector đã được vá để nhận kiểu bố cục này; re-detect để REQ-016 có lại design source đúng.

Design-Source: UPDATED 2026-09-07T09:48:56Z (applied) — `cupid-solo` trỏ `Cupid Một Mình.dc.html`, file đã bị xoá ở commit 7f4d3ca và đổi tên thành `Cupid Chặng 1.dc.html`. Entry chết khiến renderer rơi về canvas khác, nên design-reference của STORY-001 là ảnh màn hình sai (hai ảnh Android cho hai screen khác nhau trùng byte). Re-detect để chọn lại entry từ file thật trên đĩa.

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated: 2026-09-06

## Business Outcome

Chặng 1 (chế độ 1 người) hiện "mờ nhạt". Người dùng **đã có một "mối" cụ thể**
nhưng đối phương chưa cài app. Requirement này biến chặng 1 thành một **trợ lý
hoạt động / chăm sóc nhau** dùng được trọn vẹn kể cả khi người kia không bao giờ
tham gia.

Kiến trúc: **nhiều cửa vào (mỗi tính năng một trang) → một kho chung (danh sách
việc-cần-làm) → dữ liệu phụ trợ (sổ tay, hồ sơ kỹ năng) không có cửa riêng, chỉ
lộ ra khi một cửa vào khác cần.**

Tần suất thật: ý định cao / tần suất thấp (1-2 lời mời một tuần). Tối ưu **"được
nhớ tới đúng lúc cần"**, KHÔNG tối ưu DAU.

## Invariant Design Rules

Bắt buộc. Không đem ra brainstorm lại. Không story nào được vi phạm.

1. **R-1 — mở ở NẤC 3.** MỞ (a) suy luận tính cách *chỉ trên dữ liệu người dùng
   tự nhập* + (d) chỉ số ăn khớp. CẤM nguyên vẹn: (b) đọc tin nhắn / theo dõi
   MXH · (c) so sánh và báo cáo hành vi · (d-sai) chấm điểm người kia bằng dữ
   liệu app tự thu · (e) kịch bản thao túng và A/B test lời nhắn · (f) streak và
   bảng xếp hạng. **Nấc 4 không bao giờ.**
2. **R-1b — cấm đo lường hành vi người kia.** Không "đã xem", không giờ mở,
   không đếm lần mở. Chỉ *đã trả lời / chưa trả lời*. Ranh giới với R-1(a): ghi
   **sở thích + sự kiện** ✅; ghi **tần suất + hành vi** ❌ ("hay trả lời chậm"
   là cấm).
3. **R-1c / R-1d — cửa từ chối sạch.** Lời mời luôn có đường từ chối một chạm,
   không né, không trêu; app không kịch tính hoá lời từ chối. Nội dung preset
   chỉ được đùa về **người gửi**.
4. **R-1e — luật ba tầng.** User **GHI** ✅ · user **ĐOÁN**, app không xác nhận
   ✅ · app **SUY LUẬN / CHẤM ĐIỂM** về người kia ❌. Tầng 3 chỉ mở trên dữ liệu
   user tự nhập.
5. **R-1f — sổ tay** chỉ ghi sở thích và sự kiện, không ghi đánh giá con người,
   không có chức năng xuất/chia sẻ.
6. **R-1g — không kết luận.** Mọi nội dung nói về người kia phải kết thúc bằng
   **một câu để hỏi người thật**, không bằng một kết luận. Bài kiểm tra: *"đọc
   xong, người dùng muốn hỏi người kia nhiều hơn hay ít hơn?"*
7. **Không AI ở runtime.** Nội dung đi đường PRESET + MAD-LIBS + KHUNG NHẠI. AI
   chỉ được dùng **ngoài hệ thống, ở khâu SOẠN nội dung**. Chỉ số ăn khớp làm
   bằng **bảng tra tay** (144 ô hoàng đạo / 256 ô MBTI), ship như gói dữ liệu,
   runtime tất định. Mỗi ô **bắt buộc có ít nhất một điểm cọ xát**, không chỉ
   lời khen.
8. **Chỉ số ăn khớp hiển thị DẢI, không hiển thị %.**
9. **Đối tượng cố định:** người dùng đã có một "mối" cụ thể, đối phương chưa cài
   app. KHÔNG phục vụ nhóm "chưa có ai".
10. **Định vị:** "trợ lý hoạt động / chăm sóc nhau", KHÔNG phải "app tán tỉnh",
    KHÔNG phải "app bói toán".
11. **Quà chỉ là Ý TƯỞNG.** Không thương mại, không affiliate. Chỉ mục theo
    thang **CÔNG SỨC (số giờ)**, không theo VNĐ.
12. **Nhật ký riêng-tư-mặc-định, xoá được.**
13. **SB-208 / SC-6 — khoá vị trí.** Chân dung và bảng tra ăn khớp không bao giờ
    xuất hiện trong menu chính hay tab bar; chỉ tới được từ một luồng đang chạy.
14. **Không paywall lõi.**
15. **R-15 — nội dung là DỮ LIỆU có cổng nhập, không phải chuỗi trong code**
    (D-15, đóng OQ-3 ngày 2026-09-06). Ba ràng buộc, cả ba nghiệm thu được:
    - **(a) Schema + id ổn định.** Mọi nội dung preset ship như **gói dữ liệu có
      lược đồ và định danh bền**; cấm chuỗi cứng trong widget/code. Nguồn nội
      dung sẽ đổi chủ sang CMS ngoài repo — cú đổi chủ đó **không được kéo theo
      một lần sửa code**.
    - **(b) N là thuộc tính DỮ LIỆU, không phải hằng số biên dịch.** Bộ seed bản
      đầu là **10 mục cho mỗi gói nội dung XOAY VÒNG**, nhưng hành vi phải đúng
      với **mọi N**, kể cả khi CMS nâng lên vài trăm. **Cấm** mọi AC/BR/bố cục
      dựa vào "vì có đúng 10 mục nên…" — gồm hành vi khi hết tập, chỉ báo tiến
      độ, và mọi số lượng cố định. Gói **TRA CỨU PHỦ TOÀN PHẦN** (bảng ăn khớp,
      STORY-010) không phải gói xoay vòng: nó phải phủ đủ mọi ô, "10 mục" không
      áp cho nó.
    - **(c) Luật bất biến cưỡng chế ở tầng SCHEMA/VALIDATION, không ở khâu biên
      tập.** R-1b (cấm đo hành vi người kia), ràng buộc chống tâng bốc, cấm hiển
      thị %, và cấm streak phải là **cổng nhập chạy được**: nội dung vi phạm bị
      **từ chối tại cổng nhập và làm hỏng bản dựng**, không phải bị phát hiện
      lúc người dùng đọc. Lý do: nội dung tương lai do CMS ngoài repo cấp và
      **không đi qua review của repo này**.

    R-15 **không nới** R-7: AI vẫn chỉ được dùng **ngoài sản phẩm, ở khâu SOẠN**,
    không bao giờ ở runtime.

### Cổng cứng (hard gate)

Mọi story phải trả lời được: **"chặng 1 có dùng được trọn vẹn kể cả khi người
kia không bao giờ tham gia không?"** Nếu KHÔNG → story sai phạm vi.

### Thứ tự không thương lượng (SB-174)

Sổ tay → làm cho quà / mồi chuyện / kịch bản hết chung chung → **rồi mới** phủ
vỏ hoàng đạo và trắc nghiệm. Làm ngược lại sẽ ra một app bói toán có kèm to-do
list.

## Story Seeds

Seed = gợi ý recon, KHÔNG phải story list. Product Owner gộp/tách theo outcome.

| Seed | Source Idea | Serves Which User Outcome | Notes |
|------|-------------|---------------------------|-------|
| Danh sách việc-cần-làm (màn 1, kho trung tâm) | IDEA-20260829-001 | "Tôi có chỗ duy nhất chứa mọi ý tưởng hẹn hò, không rơi rụng" | Màn "về nhà". 4 trạng thái: Mới nghĩ ra / Đã hẹn ngày / Đã đi rồi / Đã thành kỷ niệm. Nhận thẻ từ MỌI cửa vào. SC-1', SC-4, SC-5 |
| Sổ tay người yêu (màn 2) + Hồ sơ kỹ năng (màn 3) | IDEA-20260829-001 | "App biết đủ về mối quan hệ CỤ THỂ này để hết gợi ý chung chung" | Chỉ điền qua hỏi-tại-chỗ, KHÔNG có luồng điền-trước (SC-3). R-1f. Hạ tầng cho quà/mồi chuyện/kịch bản |
| Nhật ký riêng (màn 4) | IDEA-20260829-001 | "Tôi ghi lại được cảm xúc riêng tư mà không ai đọc được" | Độc lập, riêng-tư-mặc-định, xoá được |
| Gợi ý quà (màn 5) | IDEA-20260829-001 | "Tôi nghĩ ra quà có ý nghĩa mà không cần giàu" | Dịp Việt × giai đoạn × sổ tay. Nhánh quà-không-tốn-tiền + handmade theo kỹ năng. Lọc theo SỐ GIỜ. Rủi ro: hỏi kỹ năng kiểu CV → 80% trả lời "không có" |
| Mồi chuyện (màn 6) | IDEA-20260829-001 | "Tôi hết bí chuyện để nhắn" | Bản A kho câu thường xanh (dùng tại chỗ) + bản A+ "sự kiện có lịch" (thành thẻ). Bản B feed tin thật = NGOÀI phạm vi |
| Vỏ hoàng đạo / trắc nghiệm (màn 7) | IDEA-20260829-001 | "Tôi có cớ nhẹ nhàng để bắt chuyện" | Kết quả LUÔN kết thúc bằng 3 thẻ hoạt động, không bằng nhận định đứng một mình. Làm SAU sổ tay (SB-174) |
| Chân dung "theo cách BẠN nhìn" (màn 8) | IDEA-20260829-001 | "Tôi hiểu người kia rõ hơn qua chính quan sát của mình" | KHOÁ VỊ TRÍ. Ghi rõ xuất xứ "dựa trên những gì BẠN nhập". R-1(a) + R-1e + R-1g |
| Kịch bản buổi hẹn 3 phần (màn 9) | IDEA-20260829-001 | "Tôi tự tin trước/trong/sau buổi hẹn" | KHOÁ VỊ TRÍ. Vào từ thẻ "Đã hẹn ngày". 3 cửa ra: lời mời / thẻ mới / nhật ký |
| Bảng tra ăn khớp (màn 10) | IDEA-20260829-001 | "Tôi biết chỗ dễ hợp và chỗ dễ va để chuẩn bị" | KHOÁ VỊ TRÍ. Đầu ra bắt buộc bộ bốn: chỗ dễ hợp · chỗ dễ va · 1 hoạt động nên thử · 1 câu để hỏi. DẢI không %. Bảng tra tay |
| Xuất lời mời (hành động 11) | IDEA-20260829-001 | "Tôi rủ được người kia mà không sượng" | Bottom sheet, khung nhại + mad-libs. CÙNG renderer phục vụ cả "lời mời" và "lời cảm ơn sau hẹn". Móc SB-125: payload render được |
| SB-211 "Trước giờ đi" (phủ J6) | IDEA-20260829-001 | "Tôi không quên thứ cần mang trước khi đi" | MỞ RỘNG của màn (1), không phải màn thứ 12. Checklist TẤT ĐỊNH bằng bảng tra tay, không AI, không API ngoài |
| SB-212 "Cảm ơn + chốt việc kế tiếp" (phủ J9) | IDEA-20260829-001 | "Tôi giữ được đà sau một buổi hẹn vui" | MỞ RỘNG của màn (1). Hướng RA NGOÀI, đối lập J8. Kích hoạt MỘT LẦN, bỏ qua thì thôi hẳn |
| Trạng thái & widget theo pha (SB-83/84/85/86/87/99) | IDEA-20260829-001 | "App nhắc tôi đúng lúc mà không làm phiền" | "Đừng đoán — chuẩn bị", "về tới nhà chưa?", đếm ngược, "món quà đang lớn", nhỏ giọt |
| Lối ra & lối quay lại (SB-64/65/100, J11/J13) | IDEA-20260829-001 | "Bị từ chối hoặc bỏ lâu không biến app thành nơi tôi sợ mở" | Đóng ngăn gọn gàng, tắt hồi tưởng, màn không trách móc, xoá sạch một thao tác. Sổ tay/kỹ năng KHÔNG gắn người cụ thể vẫn giữ |
| Nhận diện cột mốc J12 (chỉ giữ payload) | IDEA-20260829-001 | — (móc cho chặng 1.5) | REQ này DỪNG ở chỗ **nhận ra** cột mốc và giữ payload SB-125. KHÔNG tự thực hiện lời mời cài app |

## Design Ruling Log

Ghi lại các phán quyết đã đóng khi bản vẽ thiết kế (design canvas) mâu thuẫn
với AC/UX spec đã viết. Không mở lại các mục dưới đây ở vòng sau.

| Ngày | Story | Xung đột | Phán quyết | Hệ quả |
|---|---|---|---|---|
| 2026-09-07 | STORY-001 | D-1: canvas có 5 ngăn lọc (ngăn đầu "Tất cả · 14"), AC-10 + UX §3 bắt buộc đúng 4 ngăn | **Design canvas thắng.** Sửa AC-10 và UX §3 thành 5 ngăn, thêm ngăn "Tất cả" dẫn đầu | AC/spec được vá, canvas giữ nguyên. "Tất cả" là một *view*, không phải trạng thái thứ 5 — vòng đời vẫn 4 trạng thái (AC-14 không đổi) |
| 2026-09-07 | STORY-001 | D-2: canvas có CTA **và** hành động tràn "…" trên hero card, AC-11/SC-4 bắt buộc đúng một hành động chính | **Design canvas thắng.** Sửa AC-11/SC-4 thành 1 CTA chính + tối đa 1 hành động tràn "…" | AC/spec được vá, canvas giữ nguyên. 4 nhãn CTA của bảng SC-4 KHÔNG đổi; ô tràn chỉ chứa lựa chọn phụ, không chứa CTA chính thứ hai |
| 2026-09-07 | STORY-001 | D-3: canvas có thanh tab 4 mục (Muốn làm / Ý tưởng / Sổ tay / Nhật ký) thay thanh shell, AC-22 + UX §1 cấm tab/route mới | **Design canvas thắng.** Sửa AC-22 và UX §1 để cho phép và yêu cầu thanh tab 4 mục cùng route của nó cho bề mặt solo chặng 1 | AC/spec được vá, canvas giữ nguyên. Giữ nguyên ý định định vị của AC-22 (nổi bật là kho của người dùng, bộ đếm thuộc STORY-012) |
| 2026-09-08 | STORY-001 | D-4 (round 1-3, `visual-fidelity-report.md` mục `## 3. In-region deltas`): canvas không có delete affordance cấp-thẻ trên tile; implementation vẽ thêm một dấu gạch xoá trên MỌI tile, lý do ghi là "AC-13 yêu cầu thẻ xoá được" | **Design canvas thắng — KHÔNG cần vá AC-13.** Đọc lại nguyên văn AC-13 (`STORY-001.../requirements/requirements.md` dòng 139-142): điều kiện là "ít nhất một đường đi tiếp (hành động chính HOẶC chuyển trạng thái) HOẶC đường xoá" — hai nhánh nối bằng HOẶC, không phải bắt buộc cả hai. AC-11 (đúng 1 CTA mỗi thẻ) và AC-14 (đổi trạng thái hai chiều) đã đảm bảo nhánh "đường đi tiếp" cho MỌI thẻ ở MỌI trạng thái, nên AC-13 đã thoả mãn mà không cần thêm affordance xoá cấp-tile. Đường xoá vẫn tồn tại qua ô tràn "…" → "Xoá" (đã xác lập ở D-2) | Không đổi AC-13/spec. Implementation bỏ dấu gạch xoá cấp-tile khỏi mọi thẻ để khớp canvas; xoá thẻ tiếp tục đi qua overflow "…" → "Xoá" duy nhất |

Nguồn bằng chứng: `STORY-001_activity_card_hub/visual-fidelity/visual-fidelity-report.md`
mục `## 2. In-region deltas` (D-1/D-2/D-3) và mục `## 3. In-region deltas`
(D-4/D-5), đối chiếu `design-reference-man-goc-muon-lam-ios.png` và
`design-reference-phut-1-kho-trong-ios.png`. Người dùng đã chọn "anchor on
design" cho D-1/D-2/D-3; D-4 đóng trực tiếp bởi Scrum Master từ nguyên văn
AC-13 (không mâu thuẫn AC, không cần quyết định sản phẩm mới). D-5 (biểu
tượng loại hoạt động ở dòng 2 mỗi thẻ cần `ActivityCard.activityType` là enum
thay vì `String?` tự do) còn MỞ — đã giao Tech Lead vá coding-plan
(`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-tech-lead`) vì đây
là thay đổi hợp đồng miền dữ liệu ngoài phạm vi ghi của P4, không phải xung
đột thiết kế-vs-AC.

## Out of Scope

- **Chặng 1.5** — link hai chiều để người kia trả lời mà không cần cài app.
  Requirement riêng, tạo sau. REQ-016 chỉ để lại móc SB-125.
- **Feed tin thật** (mồi chuyện bản B) — cần hạ tầng, đánh giá lại ở chặng 1.5.
- **Zalo Mini App** (OQ-7) — điều kiện/chi phí/xác thực cho sản phẩm C2C.
- **Thương mại / affiliate quà.**
- **J7 "trong buổi hẹn"** — cố ý để trống. App rời khỏi tay lúc đang hẹn, theo
  triết lý "trợ lý trước/sau". Đây là quyết định, không phải thiếu sót.
- **CMS nội dung, màn quản trị nội dung, và luồng fetch/đồng bộ nội dung**
  (D-15) — CMS nằm **NGOÀI repo hiện tại**. REQ-016 ship nội dung bản đầu **kèm
  app** dưới dạng gói dữ liệu có schema (R-15a). Việc đổi nguồn sang CMS là
  requirement sau, và theo R-15a phải làm được **mà không sửa code**.

## Open Questions

| ID | Question | Owner | Blocking? | Triage (PO, 2026-09-06) |
|----|----------|-------|-----------|--------------------------|
| L45 | "Chặng 1 là trang trí cho phòng chờ" nếu chặng 1.5 nằm ngoài phạm vi — mâu thuẫn tự bác từ vòng 2. Định vị có đứng vững không khi N7 bị cắt? | Product Owner | ~~⚠️ Phải trả lời khi khoá story list~~ → **KHÔNG chặn** | **ĐÓNG.** L45 = OQ-18, và user đã chốt OQ-18 ngày 2026-09-03 (`development.md` → `D5 · User chốt OQ-18`): **chặng 1 là KHO TÀI SẢN, không phải phòng chờ**; trần giữ chân RS-D6 được chấp nhận có ý thức. Không chặn story nào. Ba story chịu tải định vị: STORY-001, STORY-012, STORY-013. Chi tiết: `requirements/requirements.md` → `## Open Question Triage` |
| OQ-3 | Ai biên tập và duyệt kho nội dung preset? Rủi ro #1 của cả sản phẩm là **sượng**, nút thắt là gu người duyệt (cần kiểm duyệt hai lớp, SB-123) | User (nguồn lực) | Không chặn breakdown | **ĐÃ ĐÓNG 2026-09-06 (user) — D-15.** Đội AI soạn **offline, trong lúc delivery**; **user duyệt bộ seed** bản đầu; duyệt lâu dài chuyển sang **CMS nằm ngoài repo hiện tại**. Khối lượng bản đầu: **10 mục / mỗi gói nội dung XOAY VÒNG**; **không áp** cho gói tra cứu phủ toàn phần của STORY-010 (user chốt lối (a): soạn đủ 400 ô trong phạm vi REQ-016). Nội dung bản đầu **ship kèm app**. Hệ quả thành luật bất biến: **R-15**. Không nới R-7 (không AI ở runtime). Ảnh hưởng STORY-002/004/005/007/009/010/011 |
| OQ-2 | Một "ngăn" hay nhiều "ngăn" — trả lời một phần: mỗi trạng thái trong màn (1) là một ngăn lọc. Chi tiết UI còn mở | Product Owner / UI-UX | Không chặn | **ĐÓNG ở tầng sản phẩm.** 4 trạng thái = 4 ngăn lọc. Chi tiết trình bày UI giao UI/UX Designer trong phạm vi STORY-001 |
| SB-144/145/146 | Trò chơi "đoán" không thắng thua — chưa gán màn cố định | Product Owner | Không chặn | **HOÃN.** Không gán vào story nào của REQ-016 — không có màn chủ và không có outcome riêng. Mở lại ở một requirement sau |
| D-8 | STORY-001 round-4 visual-fidelity (`STORY-001_activity_card_hub/visual-fidelity/visual-fidelity-report.md` §3/§6): canvas `man-goc-muon-lam` (`cupid-app-design-system/Cupid Chặng 1.dc.html`, màn A2) carries 4 context words on card body text with no field in `architecture/contract-summary.md` §3 — `ngoài trời đang mưa` (design source line 156), `chiều` (172), `tối nay được` (183), `Theo lịch âm` (191). Số dòng ở bản ghi đầu (125/141/152/160) SAI — các dòng đó là thanh tab, phụ đề header và div container. Sót thêm `2 tiếng` (171, thời lượng) cũng không có field. Read together they looked like a free-text availability/condition note (time of day, weather, offered slot, calendar system), not one field. Phase-P7 §6's own measurement warning required reporting this rather than self-resolving it (no new column, no widening the `ActivityType` enum to absorb the words) | Product Owner | ~~Chỉ chặn đóng round-4 visual-fidelity thành PASS~~ → **KHÔNG chặn** | **ĐÓNG 2026-09-08 (brainstormer). KHÔNG thêm field, KHÔNG thêm cột, KHÔNG nới enum `ActivityType`, KHÔNG cần phase vá.** Đọc lại canvas gốc: 4 cụm KHÔNG phải một field chung. `ngoài trời` (156) = field AC-8 **trong nhà/ngoài trời** đã có, đi cùng `Vé có rồi`=**cần đặt trước** và `cách 4,2 km`=**khoảng cách** trên cùng meta line; `Theo lịch âm` (191) nằm ở ô mô tả thẻ = field AC-8 **ghi chú** (văn tự do) đã có, cùng ô chứa văn tự do ở dòng 168 và 180. `đang mưa` = thời tiết runtime → **BÁC**, cần API ngoài, trái R-7 và Seed SB-211 ("không AI, không API ngoài"). Chỉ `chiều` (172) / `tối nay được` (183) là hở thật: nhãn **buổi trong ngày** thô (sáng/chiều/tối), không suy ra được từ **ngày hẹn** vì thẻ "Làm bánh flan" ở trạng thái *Mới nghĩ ra* chưa có ngày → **HOÃN sang requirement sau**, vì REQ-016 không có cơ chế nào tiêu thụ nó (field sẽ write-only, ghi-và-hiện không ai đọc), trong khi chi phí là cột Drift mới + migration + nâng `schemaVersion` (khác D-5 vốn tái dùng `activity_type TEXT NULL` qua TypeConverter) + vá hợp đồng khoá `ux/uiux-spec.md` §8 mà STORY-002/004/006/007/008 đã đọc. Nơi đúng: requirement dựng STORY-012 ("App nhắc tôi đúng lúc mà không làm phiền"). Nguyên tắc: **chữ trong thân thẻ trên canvas là nội dung mẫu, không phải hợp đồng field** — cùng thẻ đó còn mang "Cún", "Đêm núm sen", "CGV Vincom", "Hào Nam"; tiền lệ "anchor on design" (D-1/D-2/D-3) áp cho **cấu trúc/bố cục**, không áp cho chữ mẫu. `2 giờ công` (182) là thang CÔNG SỨC của R-11, thuộc STORY-004, không phải STORY-001 |

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Danh sách việc-cần-làm — kho chung và vòng đời thẻ | complex | TODO | `STORY-001_activity_card_hub/story_master.md` |
| STORY-002 | Xuất lời mời — khung nhại + mad-libs | complex | TODO | `STORY-002_invite_message_composer/story_master.md` |
| STORY-003 | Nhật ký riêng | standard | TODO | `STORY-003_private_journal/story_master.md` |
| STORY-004 | Gợi ý quà, và sổ tay / hồ sơ kỹ năng thu thập tại chỗ | complex | TODO | `STORY-004_relationship_notebook_and_gift_ideas/story_master.md` |
| STORY-005 | Mồi chuyện — kho câu thường xanh và sự kiện có lịch | standard | TODO | `STORY-005_conversation_starters/story_master.md` |
| STORY-006 | "Trước giờ đi" — checklist tất định (SB-211) | standard | TODO | `STORY-006_before_you_go_checklist/story_master.md` |
| STORY-007 | "Cảm ơn + chốt việc kế tiếp" (SB-212) | standard | TODO | `STORY-007_thank_you_and_next_plan/story_master.md` |
| STORY-008 | Kịch bản buổi hẹn 3 phần | standard | TODO | `STORY-008_date_script_three_parts/story_master.md` |
| STORY-009 | Chân dung "theo cách BẠN nhìn" | standard | TODO | `STORY-009_your_view_portrait/story_master.md` |
| STORY-010 | Bảng tra ăn khớp | complex | TODO | `STORY-010_compatibility_lookup/story_master.md` |
| STORY-011 | Vỏ hoàng đạo / trắc nghiệm | standard | TODO | `STORY-011_zodiac_quiz_shell/story_master.md` |
| STORY-012 | Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn" | complex | TODO | `STORY-012_phase_status_and_widget/story_master.md` |
| STORY-013 | Lối ra khi im lặng/bị từ chối, và lối quay lại sau vắng | standard | TODO | `STORY-013_graceful_exit_and_return/story_master.md` |

Thứ tự phụ thuộc và bản đồ seed → story: `requirements/requirements.md` →
`## Seed To Story Mapping` và `## Story Order And Dependencies`.
