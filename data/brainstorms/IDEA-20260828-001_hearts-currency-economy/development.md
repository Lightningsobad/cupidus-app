# Idea Development: IDEA-20260828-001 Hearts Currency Economy

## BMAD Session State

- Stance: `Ideate For Me` (user có thể đổi sang `Creative Partner` bất cứ lúc nào)
- Topic: Phát triển hệ tiền tệ `hearts` từ mức cấp phát ban đầu thành một nền
  kinh tế quan hệ có faucet, sink, và ý nghĩa cảm xúc.
- Goal: Sau khi user chốt nhánh **"tấm gương phản chiếu quan hệ"**, khai thác hết
  hệ quả của lựa chọn đó — cả những thứ nó giết chết lẫn những thứ nó mở ra.
- Constraints:
  - Đơn vị kinh tế là **cặp đôi**, không phải cá nhân (ví chung theo `coupleId`).
  - Không có live-ops team → tỉ giá phải tĩnh, ít tham số.
  - Sản phẩm tình cảm → mọi cơ chế trừng phạt đều là rủi ro thương hiệu.
  - **[CHỐT 2026-08-28]** Hearts là *tấm gương phản chiếu quan hệ*, không phải
    tiền tệ trò chơi. Hearts **không bao giờ mua được bằng tiền thật**.
  - Business level only. Không viết UX spec, schema, hay implementation plan.
- Active technique batch (cycle 2): JTBD Extremes → Anti-Commodity Differentiation
  → Channel-First Ideation → Assumption Smash vòng 2 (đập giả định của chính
  phép ẩn dụ "tấm gương")
- Approximate raw idea count: ~102 (cycle 1: ~57, cycle 2: ~45)
- Domain shifts explored: 10 (game economy → fintech/banking → tâm lý học quan hệ
  → creator/social → thương mại & pháp lý → thiết bị đo sức khoẻ đeo tay → lưu trữ
  ký ức và nhật ký → nghi lễ và tôn giáo → lãi kép và quỹ hiến tặng → tang chế
  và chia ly)
- Convergence state: **chưa bắt đầu** (vẫn cố ý divergent — cycle 2 vừa mở ra một
  nghịch lý lớn hơn những gì nó đóng lại)
- Next technique or move: giải nghịch lý "tiêu một tấm gương" (xem Open Questions),
  rồi Affinity Clustering → NUF để chốt hướng.

## Idea Inventory

### 2026-08-28 — Cycle 1 mở màn: đọc hiện trạng

- Xác lập 6 sự thật nền (xem `idea.md` § Seed). Sự thật quan trọng nhất và bị bỏ
  qua nhiều nhất: **hearts là ví CHUNG của cặp, không phải ví cá nhân**. Hầu hết
  currency trong app đều là single-player. Ví chung là điểm khác biệt bẩm sinh và
  nên là trục thiết kế chính, không phải chi tiết kỹ thuật.
- Sự thật số 2: luồng theme đã có **mutual consent** (request → approve/reject).
  Nghĩa là app đã vô tình xây một cơ chế "đồng thuận chi tiêu" giống tài khoản
  ngân hàng chung. Chưa ai gọi tên nó như vậy.
- Sự thật số 3: `1240` là magic number không có mô hình đằng sau.

### 2026-08-28 — Technique 1: Assumption Smash (đập giả định ngầm)

- A1. Giả định "hearts phải được phát, không thể kiếm" → bỏ: hearts được **đúc ra
  từ hành vi quan hệ**. Đây là thay đổi gốc rễ, mọi nhánh sau đều phụ thuộc.
- A2. Giả định "hearts chỉ có một pool chung" → bỏ: **hai tầng ví** — hearts cá
  nhân kiếm riêng, chỉ trở nên hữu ích khi góp vào ngân khố chung của cặp.
- A3. Giả định "hearts chỉ mua đồ trang trí" → bỏ: hearts mua **hành động và cam
  kết** (một buổi hẹn, một lời hứa được ghi vào love contract), không chỉ mua skin.
- A4. Giả định "cặp đôi tiêu hearts cho chính họ" → bỏ: **chỉ được tiêu hearts cho
  người kia, không bao giờ cho mình**. Rất khác biệt, và rất đúng tinh thần sản phẩm.
- A5. Giả định "số dư là một con số" → bỏ: mỗi heart **mang lai lịch**. Số dư hiển
  thị kèm nguồn gốc: "320 hearts từ 47 buổi sáng nhắn tin trước 8h".
- A6. Giả định "hearts không bao giờ mất giá" → bỏ: hearts hao mòn khi quan hệ
  nguội. (Cảnh báo: đây là nhánh nguy hiểm, xem D2.)
- A7. Giả định "hai người đối xứng" → bỏ: người đầu tư ít hơn kiếm ít hơn, tạo ra
  chênh lệch nhìn thấy được. Nguy hiểm nhưng đáng giữ lại như một tín hiệu yếu.
- A8. Giả định "1240 là số dư khởi tạo hợp lý" → bỏ: nó là hằng số tuỳ tiện. Cần
  neo giá trị của một heart trước rồi mới nói được số dư khởi tạo là bao nhiêu.
- A9. Giả định "hearts kiếm được một mình" → bỏ: **dual-signature minting** —
  hearts CHỈ được đúc khi cả hai người cùng làm gì đó. Không hành động đơn phương
  nào tạo ra tiền. Cực mạnh: tự động chống cày, tự động thưởng sự tương hỗ.
- A10. Giả định "hearts đồng nhất" → bỏ: hearts **có loại** (Kindness / Time /
  Adventure hearts) và các sink khác nhau đòi loại khác nhau. Ép cặp đôi phải
  đa dạng hoá hành vi thay vì lặp một hành vi rẻ nhất.

### 2026-08-28 — Technique 2: Analogy Transfer (domain shift → game, fintech, social)

- B1. **Duolingo streak freeze** → mua "Ngày Ân Xá" bằng hearts để giữ streak khi
  một người đi công tác/ốm. Sink mang tính bao dung, không trừng phạt.
- B2. **Tamagotchi / Love Pet đã có sẵn** → hearts nuôi pet; pet vui thì sinh ra
  hearts trở lại. Vòng kinh tế khép kín với một feature đã tồn tại, chi phí thấp nhất.
- B3. **Animal Crossing (Bells + Nook Miles)** → hai đồng tiền: hearts (kiếm hằng
  ngày, tiêu vặt) và một đồng hiếm "Moments/Stars" chỉ đến từ cột mốc (kỷ niệm,
  chuyến đi đầu tiên) dùng cho vật phẩm vĩnh viễn không thể mua lại.
- B4. **Tài khoản ngân hàng chung / Splitwise** → màn hình hearts trông như sao kê:
  Deposits và Withdrawals. Nối thẳng vào module `expenses` đã có: chia tiền sòng
  phẳng và tất toán đúng hạn thì đúc hearts.
- B5. **Kickstarter / quỹ mục tiêu** → cặp đôi đặt mục tiêu chung ("chuyến đi cuối
  tuần", "mở khoá theme thiên hà") và cả hai cùng góp hearts vào một thanh tiến
  trình nhìn thấy được. Biến chi tiêu thành sự chờ đợi chung.
- B6. **Discord Nitro boost** → hearts "boost" tạm thời một feature cho cặp (một
  tuần upload gallery không giới hạn, thêm slot dream jar). Sink lặp lại được,
  không gây lạm phát vật phẩm vĩnh viễn.
- B7. **Gacha / hộp bí ẩn** → tiêu hearts mở "Thẻ Hẹn Hò Bí Ẩn" hoặc pack ngẫu nhiên.
  ⚠️ Giữ lại như nhánh lạ nhưng gắn cờ đỏ: cơ chế đánh bạc trong app tình cảm là
  rủi ro danh tiếng và pháp lý (xem D10).
- B8. **Danh sách quà cưới (wedding registry)** → A thả một món vào wishlist, B
  âm thầm gom hearts và tặng bất ngờ. **Trường `wishlist` đã tồn tại trong hệ
  thống — đây là phiên bản dựng dở của chính ý tưởng này.** Chi phí bổ sung rất thấp.
- B9. **Dặm bay / hạng thành viên** → tổng hearts tích luỹ trọn đời quyết định
  "hạng quan hệ" (Spark → Ember → Flame → Beacon); hạng chỉ tăng, không bao giờ
  giảm. Tách biệt hoàn toàn với số dư tiêu được → có tiến trình mà không có trừng phạt.
- B10. **Pokémon Go gifts** → hearts chỉ gửi được, người kia phải mở. Hành vi tặng
  quan trọng hơn vật phẩm.
- B11. **Habitica (thói quen xấu trừ điểm)** → ghosting, bỏ lỡ reminder thì mất
  hearts. ⚠️ Nhánh trừng phạt, gắn cờ đỏ, xem D2/D9.
- B12. **Patreon tipping** → "boa" hearts cho người kia kèm một lời nhắn ngay trong
  chat. Đơn vị tiền tệ của sự trân trọng vi mô.
- B13. **Ngân hàng trung ương** → gọi tên đúng bản chất: app đang làm chính sách
  tiền tệ. Cần faucet, sink, trần lạm phát, và một câu trả lời cho "một heart
  đáng giá bao nhiêu". Hiện tại chưa có cái nào.
- B14. **Thẻ thành viên IKEA Family** → hearts đổi được ưu đãi đời thực (giảm giá
  hoa, vé xem phim). Mở đường doanh thu B2B.
- B15. **Module `zodiac` đã có sẵn** → "thưởng vũ trụ": hệ số nhân hearts vào ngày
  hợp mệnh. Biến một feature trang trí thành một tham số kinh tế.

### 2026-08-28 — Technique 3: Revenue-First Ideation (domain shift → kiếm tiền)

- C1. **Hearts KHÔNG BAO GIỜ mua được bằng tiền mặt.** Tiền mặt chỉ mua thời gian
  và tiện lợi (subscription), không bao giờ mua hearts. Định vị rất sắc:
  *"Không mua được tình yêu."* Bảo vệ tính xác thực của tín hiệu.
- C2. Ngược lại: hearts **bán được** như IAP free-to-play kinh điển. Doanh thu
  nhanh, nhưng làm rẻ hoá tín hiệu. Giữ lại như một mâu thuẫn cần user phân xử.
- C3. **Cupid Plus = tốc độ kiếm cao hơn + sink độc quyền**, không bán hearts.
  Subscription tăng tốc chứ không đi đường tắt. Đường giữa của C1 và C2.
- C4. **Người thứ ba mua hearts tặng cặp đôi** — bạn bè/gia đình mua bundle tặng
  dịp kỷ niệm. Về mặt cảm xúc, được tặng thì chấp nhận được, tự mua thì không.
- C5. **Faucet được tài trợ** — nhãn hàng tài trợ "Thử thách Date Night" và trả
  hearts. Kiếm tiền ở phía faucet, không đụng vào phía sink.
- C6. **Chợ đổi thưởng đời thực** — hearts + tiền mặt đổi trải nghiệm hẹn hò giảm
  giá (nhà hàng, rạp phim, khách sạn). Hearts trở thành cỗ máy giảm giá; doanh thu
  affiliate.
- C7. **Sink vật lý** — hearts + tiền mặt để in photobook, tạp chí timeline, hay
  đĩa than từ đoạn chat. Hearts mở mức giảm giá, tiền mặt trả giá vốn.
- C8. **Thưởng kỷ niệm** — không trực tiếp ra tiền, nhưng với app cặp đôi thì
  **giữ chân chính là đòn bẩy kiếm tiền thật sự**.
- C9. Câu hỏi đơn vị định giá: một heart đáng giá bao nhiêu? Hôm nay toàn bộ thang
  đo đang trôi nổi (1240 phát không, theme có giá tuỳ ý). Phải neo giá trị heart
  trước khi bàn bất cứ chuyện kiếm tiền nào.
- C10. **Hai phía (two-sided)** — cặp đôi kiếm hearts, nhà cung cấp chấp nhận
  hearts ở một tỉ giá cố định và tự trả phần đó như chi phí thu hút khách. Lúc đó
  hearts mới là tiền tệ thật, không còn là token nội bộ.

### 2026-08-28 — Technique 4: Problem Reversal — thiết kế thất bại (domain shift → tâm lý học quan hệ)

Bài tập: cố tình thiết kế phiên bản hearts phá hoại mối quan hệ, rồi lật ngược
thành luật thiết kế.

- D1. Thất bại: **hearts biến tình yêu thành bảng điểm.** A thấy mình đóng góp 80%
  và sinh oán giận. → **Luật: không bao giờ hiển thị tỉ lệ đóng góp theo từng người
  dưới dạng bảng xếp hạng.**
- D2. Thất bại: **cỗ máy tội lỗi.** Hao mòn/mất streak khiến một ngày bỏ lỡ trở
  thành cảm giác thất bại trong tình cảm, đúng lúc cặp đôi đang có tuần khó khăn.
  → **Luật: không hao mòn mang tính trừng phạt; cơ chế ân xá/tha thứ phải nằm sẵn
  trong thiết kế, không phải mua thêm.** (Xung đột trực tiếp với A6 và B11.)
- D3. Thất bại: **công cụ kiểm soát cưỡng ép.** Một người bạo hành dùng số liệu
  hearts để giám sát và trách móc sự chú ý của người kia. → **Luật: không có chỉ
  số giám sát theo cá nhân; mọi chỉ số đều là chỉ số chung của cặp.** Cần một vòng
  rà soát an toàn riêng trước khi ship bất cứ thứ gì lộ dữ liệu theo từng người.
- D4. Thất bại: **động lực ngoại lai giết động lực nội tại** (overjustification
  effect). Được thưởng vì nói "anh yêu em" khiến câu đó thành giao dịch. →
  **Luật: chỉ thưởng cho sự hiện diện và nghi thức (ritual), không bao giờ thưởng
  cho chính lời bày tỏ tình cảm.** Đây có lẽ là luật quan trọng nhất của cả hệ.
- D5. Thất bại: **cày tiền.** Cặp đôi spam vibes để farm hearts. → **Luật: trần
  ngày, lợi ích giảm dần, và dual-signature minting (A9) như tuyến phòng thủ chính.**
- D6. Thất bại: **kế toán khi chia tay.** Cặp tan vỡ — ví chung thuộc về ai? Hiện
  tại ví khoá theo `coupleId` nên sẽ thành mồ côi. Và nếu ghép đôi với người mới
  thì số dư có mang theo không? (Trả lời gần như chắc chắn: **không** — nhưng
  chưa ai quyết định.) **Đây là một khoảng trống chính sách có thật, chưa có lời giải.**
- D7. Thất bại: **kinh tế chết** — hearts chất đống mà không có gì để mua. Đây
  chính xác là rủi ro hiện tại: phát 1240, chỉ có theme để tiêu.
- D8. Thất bại: **bất đối xứng thiết bị** — một người hỏng điện thoại một tuần,
  cả nền kinh tế đứng hình vì cần chữ ký kép. Lại cần cơ chế ân xá.
- D9. Thất bại: **sổ nợ nghĩa vụ** — "anh tặng em 200 hearts mà em chỉ tặng anh 50".
  → **Luật: không bao giờ hiển thị cán cân quà tặng giữa hai người.**
- D10. Black swan: nếu có hộp bí ẩn (B7) **và** hearts mua được bằng tiền (C2),
  app store và luật EU/Bỉ/Hà Lan có thể xếp vào loại loot box. Rủi ro pháp lý thật.
  Lưu ý: **chỉ cần bỏ MỘT trong hai là rủi ro biến mất.**
- D11. Black swan: văn hoá chụp màn hình khoe số hearts lan truyền. Có thể là kênh
  tăng trưởng (tốt) hoặc là nguồn xấu hổ và so sánh giữa các cặp (xấu). Hai mặt.

### 2026-08-28 — Technique 5: 10x / 10% Version

- E1. **Phiên bản 10% (lát cắt nhỏ nhất có thật):** chỉ thêm ĐÚNG một faucet
  (điểm danh chung hằng ngày cần cả hai) và nối ĐÚNG một sink đã dựng dở (emoji
  pack — giá đã có sẵn trong catalog, chỉ chưa trừ tiền). Cộng thêm biến `1240`
  thành cấu hình. Vòng kinh tế khép kín với bề mặt mới gần như bằng không.
- E2. **Phiên bản 10x (biến đổi hoàn toàn):** hearts trở thành **vốn liếng chung
  có ký ức** của mối quan hệ. Mỗi heart truy vết được về một khoảnh khắc thật, số
  dư là **bằng chứng đầu tư**, và app kết xuất thành bản "Relationship Wrapped"
  hằng năm — một bản sao kê tình cảm. Tiền tệ như một câu chuyện, không phải như
  credit trong cửa hàng. Ở phiên bản này việc "mua được gì" gần như không còn quan trọng.

### 2026-08-28 — Technique 6: Constraint Ladder (domain shift → ràng buộc vận hành & pháp lý)

- F1. Ràng buộc "không đổi backend": hearts chỉ là ảo giác phía client → **loại**,
  phá vỡ tính nhất quán của ví chung giữa hai thiết bị.
- F2. Ràng buộc "vận hành một người, không live-ops": không có sự kiện theo mùa,
  không tinh chỉnh tỉ giá liên tục. Mọi tỉ lệ phải tĩnh và ít tham số. Điều này
  **loại bỏ phần lớn thiết kế kinh tế kiểu game** ngay từ đầu.
- F3. Ràng buộc "offline-first": hai thiết bị có thể tiêu cùng một số dư chung
  đồng thời → **rủi ro double-spend có thật với ví chung**. Đây là ràng buộc kỹ
  thuật hiếm hoi đủ lớn để ảnh hưởng tới lựa chọn kinh doanh: nó khiến các sink
  "tiêu nhanh, tiêu nhiều lần" rủi ro hơn các sink "tiêu chậm, có đồng thuận".
  Thú vị là luồng mutual-consent sẵn có lại vô tình giảm nhẹ đúng rủi ro này.
- F4. Ràng buộc "ra mắt trong 24 giờ": ship màn hình **Sổ Cái Hearts** chỉ hiển thị
  lịch sử. Minh bạch trước, cơ chế sau. Rẻ và tạo niềm tin.

### 2026-08-28 — Nhận định nổi lên trong lúc bung ý tưởng

- Ba luật D1/D3/D4/D9 hội tụ về **một luật gốc duy nhất**: hearts phải đo *"chúng
  ta"*, không bao giờ đo *"anh so với em"*. Ràng buộc này loại bỏ khoảng một nửa
  không gian thiết kế kiểu game — và đó là tin tốt, vì nó thu hẹp bài toán.
- A9 (dual-signature minting) giải quyết đồng thời D5 (cày tiền), D1 (bảng điểm)
  và D3 (kiểm soát) chỉ bằng một cơ chế. Đây là ứng viên mạnh nhất hiện tại về
  mặt "một mũi tên trúng nhiều đích" — nhưng nó lại làm D8 (bất đối xứng thiết bị)
  tệ hơn.
- B8 (wishlist → quà bất ngờ) và E1 (nối sink emoji) là hai thứ **đã dựng dở sẵn
  trong hệ thống**. Rẻ nhất, và không cần quyết định triết lý nào trước.
- Mâu thuẫn lớn nhất chưa giải: A6/B11 (hao mòn, trừng phạt) đối đầu trực diện
  với D2 (không trừng phạt). Không thể có cả hai.
- Mâu thuẫn lớn thứ hai chưa giải: C1 (không bán hearts) đối đầu C2 (bán hearts).
  Câu trả lời quyết định toàn bộ phần còn lại của nền kinh tế.

### 2026-08-28 — QUYẾT ĐỊNH CỦA USER: hearts là *tấm gương phản chiếu quan hệ*

User chốt fork. Hearts KHÔNG phải tiền tệ trò chơi. Hearts là bằng chứng đầu tư
vào mối quan hệ. Quyết định này không chỉ chọn một nhánh — nó **giết chết một
loạt nhánh khác theo dây chuyền**, và điều đó phải được ghi lại rõ ràng.

Bị giết bởi quyết định này (không phải bởi ý kiến của agent, mà bởi logic của
chính phép ẩn dụ — *một tấm gương nói dối thì không còn là gương*):

- **C2 (bán hearts bằng tiền) — CHẾT.** Hiển nhiên, đây chính là mặt kia của fork.
- **C4 (người thứ ba mua hearts tặng cặp đôi) — CHẾT.** Không hiển nhiên. Một
  heart được mua là một chỉ số giả. Dù người tặng có thiện chí, nó vẫn làm sai
  số đọc.
- **C5 (faucet được nhãn hàng tài trợ) — CHẾT.** Nhãn hàng trả hearts = nhãn hàng
  can thiệp vào phép đo.
- **C3 (Cupid Plus tăng tốc độ kiếm hearts) — CHẾT.** Đây là cái chết bất ngờ và
  đắt giá nhất. Nếu người trả tiền kiếm hearts nhanh hơn, thì hai cặp đôi có hành
  vi y hệt nhau sẽ hiện hai con số khác nhau → tấm gương nói dối. **Mô hình
  "trả tiền để tăng tốc" — mô hình subscription phổ biến nhất — vừa bị loại bỏ.**
- **B15 (hệ số nhân theo cung hoàng đạo) — CHẾT.** Cùng một lý do, ở quy mô nhỏ hơn.
- **→ LUẬT RÚT RA: một tấm gương không có hệ số nhân.** Bất cứ thứ gì nhân số đọc
  lên — trả tiền, sự kiện, may mắn, streak bonus — đều làm hỏng phép đo. Luật này
  quét sạch phần lớn bộ công cụ live-ops kinh điển. Trùng hợp là nó cũng khớp với
  ràng buộc F2 (không có đội live-ops).
- **D10 (rủi ro pháp lý loot box) — TỰ TIÊU BIẾN.** Cần cả hai nguyên liệu (hộp
  bí ẩn + tiền thật mua currency); một nguyên liệu vừa bị gỡ bỏ.

Sống sót và mạnh lên:

- **A9 dual-signature minting** — bây giờ không chỉ là chống cày, mà là *định
  nghĩa của phép đo*: gương đo cái "chúng ta", nên chỉ hành động chung mới ghi số.
- **B9 hạng quan hệ chỉ tăng** — chính là một số đọc của gương.
- **A5 hearts có lai lịch / E2 Wrapped** — trở thành sản phẩm chính, không còn là
  tính năng phụ.
- **C6/C7 (đổi thưởng đời thực, sink vật lý)** — sống, nhưng mang theo một cái
  bẫy, xem G8 bên dưới.

### 2026-08-28 — Technique 7: Assumption Smash vòng 2 — đập giả định của chính phép ẩn dụ "tấm gương"

- G1. **NGHỊCH LÝ TRUNG TÂM: giả định "gương thì tiêu được".** Bạn không tiêu cái
  bóng của mình trong gương. Nếu số dư hearts là bằng chứng đầu tư, thì việc mua
  một cái theme làm **giảm bằng chứng đầu tư của bạn** — bạn bị phạt vì đã tự
  thưởng cho mình. Về mặt logic, đây là mâu thuẫn nội tại lớn nhất của nhánh vừa
  chọn, và nó chưa có lời giải. Năm hướng giải (G2–G6):
- G2. **Tiêu dòng chảy, giữ lại kho** — tách "tổng tích luỹ trọn đời" (tấm gương,
  không bao giờ giảm) khỏi "số dư tiêu được" (dòng phái sinh). Cùng một sự kiện
  đúc ra cả hai; tiêu chỉ chạm vào cái thứ hai. An toàn, quen thuộc, hơi nhàm.
- G3. **Không mua — chỉ mở khoá theo ngưỡng.** Không thứ gì *có giá*. Mọi thứ
  *mở ra ở một cột mốc*: "heart thứ 500 của hai bạn vừa mở khoá theme thiên hà."
  Không giao dịch, không hao hụt, ngữ nghĩa gương hoàn toàn sạch. Giết luôn phép
  ẩn dụ cửa hàng — và biến luồng mutual-consent sẵn có từ một cái *quầy thanh
  toán* thành một **khoảnh khắc ăn mừng chung**. Rẻ về mặt cảm xúc, đắt về mặt
  từ bỏ: không còn tính chủ động lựa chọn.
- G4. **Chính việc tiêu MỚI là tấm gương.** Lật ngược: cái phản chiếu mối quan hệ
  không phải số dư, mà là **bạn đã chọn tiêu vào cái gì**. Sổ cái quà tặng là
  hiện vật. Số dư vô nghĩa; lịch sử là tất cả.
- G5. **Hearts đo tốc độ luân chuyển, không đo tồn kho.** Số đọc là "hai người đã
  chuyển bao nhiêu cho nhau", tức vận tốc chứ không phải trữ lượng. Tích trữ
  hearts trở thành tín hiệu *xấu*. Rất mới lạ; cũng rất khó giải thích.
- G6. **Hearts hết hạn thành ký ức.** Hearts không tiêu hết sẽ chuyển hoá cuối kỳ
  thành một trang timeline / một trang ký ức tháng. Không mất gì cả, chỉ đổi hình
  thái. Giải quyết lạm phát mà không cần trừng phạt — có lẽ là lời giải thanh
  lịch nhất cho D7 (kinh tế chết vì hearts chất đống).
- G7. **Giả định "gương hiện một con số"** → bỏ: gương có thể hiện một *hình dạng*,
  một màu, một khu vườn, một chòm sao, một kiểu thời tiết. **Gương phi số học
  gần như miễn nhiễm với so sánh** — vừa chống bảng điểm (D1) vừa chống commodity
  cùng lúc. Và sản phẩm **đã có sẵn `dream_jar`**: một cái lọ đầy dần lên là tấm
  gương phi số học có sẵn trong nhà.
- G8. **Giả định "đổi thưởng đời thực là vô hại"** → bỏ: nếu hearts đổi được thành
  giảm giá thật, hearts có giá trị tiền mặt, và người ta sẽ muốn mua hearts →
  **mọi tỉ giá quy đổi ra đời thực đều kéo hearts quay lại thành tiền tệ.** Cái
  bẫy nằm ở chỗ C6/C7 trông rất vô hại. Lối thoát: hearts chỉ *mở khoá quyền được
  mua*, không bao giờ *giảm giá theo số lượng hearts*.
- G9. **Giả định "gương luôn hiển thị"** → bỏ: gương có thể chỉ soi khi được yêu
  cầu, hoặc mỗi tháng một lần. Sự hiếm làm tăng ý nghĩa và giết chết lo âu hằng ngày.
- G10. **Giả định "gương phải chính xác"** → bỏ: một tấm gương cố tình mờ và định
  tính thì an toàn hơn. Oura cho điểm số; một khu vườn chỉ cho cảm giác. Sản phẩm
  tình cảm nên chọn khu vườn.
- G11. **Giả định "gương đo tần suất"** → bỏ: nó có thể đo **sự đa dạng**, **tính
  tương hỗ**, hoặc **sự hàn gắn** thay vì đo số lần.

### 2026-08-28 — Technique 8: JTBD Extremes (domain shift → thiết bị đo sức khoẻ, tang chế)

Thử tấm gương với những cặp đôi cực đoan. Đây là nơi phép ẩn dụ gãy.

- H1. **Cặp yêu xa:** mọi faucet dựa trên hiện diện vật lý đều bất khả thi. Gương
  sẽ đọc thấp một cách hệ thống với cả một phân khúc. **Một tấm gương thiên vị
  chống lại một phân khúc là một tấm gương hỏng.** Ràng buộc thiết kế cứng.
- H2. **Cặp đang cãi nhau / đang lạnh nhạt:** gương đọc thấp đúng vào lúc họ mong
  manh nhất. Hiển thị một con số đang rơi có thể chính là thứ kết liễu mối quan hệ.
- H3. → Lời giải cho H2, và là ý tưởng mạnh nhất của cycle 2: **thưởng cho sự hàn
  gắn nhiều hơn thưởng cho sự êm đềm.** Hành vi làm lành sau xung đột nên đúc ra
  nhiều hearts nhất trong toàn hệ. Gương lúc đó không đo "hai bạn có vui không"
  mà đo "hai bạn có quay lại với nhau không" — đó mới là chỉ báo thật của một mối
  quan hệ bền. Đảo ngược hoàn toàn logic gamification thông thường.
- H4. **Cặp mới ghép được một tuần:** không có lịch sử, gương đọc gần bằng 0, gây
  nản. Giai đoạn đầu gương nên đọc *nhịp độ* chứ không đọc *tổng*.
- H5. **Cặp yêu nhau 5 năm, dùng app ít nhưng gắn bó sâu:** gương đọc thấp trong
  khi quan hệ rất mạnh. → **ĐÂY LÀ MỐI ĐE DOẠ TÍNH HIỆU LỰC CỦA CẢ NHÁNH: gương
  đang đo mức độ dùng app, không đo mối quan hệ.** Ba cách giảm nhẹ: (a) đo cả
  những việc xảy ra ngoài app rồi được ghi lại (một buổi hẹn, một chuyến đi),
  (b) cho sự kiện thưa nhưng nặng ký giá trị cao, (c) trung thực đổi tên: đây là
  *cuốn sổ chung của chúng ta trong app này*, không phải *điểm số mối quan hệ*.
  Cách (c) rẻ nhất và thành thật nhất.
- H6. **Cặp đang khủng hoảng thật (bệnh, tang, mất việc):** app im lặng một tháng.
  Gương cần khái niệm **mùa** và **tạm nghỉ**, không phải khái niệm thất bại.
- H7. **Cặp đã chia tay nhưng dữ liệu còn đó:** tấm gương trở thành một vật phẩm
  tang chế. Có thể quý giá, cũng có thể tàn nhẫn. → Lời giải cho khoảng trống D6:
  **giải thể mối quan hệ nên là một nghi thức KẾT XUẤT, không phải một lệnh xoá.**
  Repo đã có sẵn module `data-export` — hạ tầng cho nghi thức này đã tồn tại.
  Số dư dứt khoát không mang sang mối quan hệ mới; nó được đóng gói và trao lại.
- H8. **Cặp lệch pha dùng điện thoại:** một người online cả ngày, một người không.
  Với dual-signature minting (A9), người dùng ít quyết định toàn bộ tốc độ đúc.
  Có thể là tính năng (buộc phải tôn trọng nhịp của người kia) chứ không phải lỗi.

### 2026-08-28 — Technique 9: Anti-Commodity Differentiation (domain shift → nghi lễ, lưu trữ ký ức)

- I1. Một con số thì so sánh được, và đối thủ copy trong một sprint. Một **kho lưu
  trữ chung có lai lịch** thì không copy được, vì nó là dữ liệu tích luỹ của
  chính cặp đôi đó. **Chi phí chuyển đổi chính là cái kho.** Tấm gương là con hào
  bảo vệ vì nó không thể mang sang app khác.
- I2. **Danh sách những thứ hệ thống TỪ CHỐI làm chính là thương hiệu**: không bán
  hearts, không hệ số nhân, không bảng xếp hạng, không so sánh giữa các cặp. Đây
  là thứ marketing mà đối thủ free-to-play không thể nói theo, vì nói theo là phải
  từ bỏ doanh thu.
- I3. **Đổi tên ra khỏi ngôn ngữ tiền tệ.** Một khi còn gọi là ví / số dư / cửa
  hàng, người dùng sẽ đối chiếu với currency của game và nó thua. Gọi là cuốn sổ,
  cái lọ, chòm sao, kho lưu trữ, mùa. Ngôn ngữ ở đây là quyết định sản phẩm, không
  phải chuyện copywriting.
- I4. **Hiện vật thường niên** (Wrapped, photobook, bản sao kê in ra) là vật phẩm
  chống-commodity: vật lý, độc bản, không thay thế được, và chia sẻ được.
- I5. **Nghi thức chỉ diễn ra một lần mỗi năm** — một buổi "soi gương" ngày kỷ
  niệm. Không copy được bằng tính năng, chỉ copy được bằng thời gian.
- I6. Ẩn dụ chuỗi hạt cầu nguyện / lịch mùa vọng: giá trị nằm ở **việc lặp lại
  đều đặn một hành vi nhỏ**, không nằm ở phần thưởng. Hearts như một chuỗi hạt
  hai người cùng lần.

### 2026-08-28 — Technique 10: Channel-First Ideation (domain shift → phân phối & niềm tin)

- J1. Tấm gương sinh ra **hiện vật chia sẻ được** → kênh tăng trưởng tự nhiên.
  Nhưng D11 cảnh báo về sự xấu hổ và so sánh. → **Luật: chia sẻ câu chuyện, không
  bao giờ chia sẻ con số.** Con số mời gọi so sánh; câu chuyện thì không.
- J2. Người độc thân không dùng được sản phẩm này → kênh tăng trưởng bắt buộc phải
  đi qua khoảnh khắc "mời người kia". Gương nên bắt đầu đọc **ngay từ ngày đầu**
  để khoảnh khắc mời có sức nặng.
- J3. Kênh niềm tin: vì không mua được hearts, app nói được một câu mà đối thủ
  không nói được. *"Không mua được tình yêu"* là định vị, không phải slogan.
- J4. Nghi thức kết xuất khi chia tay (H7) là một sự kiện rời bỏ — nhưng là một
  sự rời bỏ tử tế. Rời bỏ tử tế tạo thiện chí và người dùng quay lại ở mối quan
  hệ tiếp theo. Hiếm app nào thiết kế cho việc này.

### 2026-08-28 — Nhận định nổi lên ở cycle 2

- Quyết định "tấm gương" **thu hẹp bài toán mạnh hơn nó mở rộng** — nó giết 5
  nhánh kiếm tiền và toàn bộ bộ công cụ hệ-số-nhân. Đó là tin tốt cho một đội
  không có live-ops.
- Nhưng nó **mở ra một nghịch lý lớn hơn mọi thứ nó đóng lại**: một tấm gương thì
  không tiêu được (G1). Đây giờ là câu hỏi chặn chính.
- **Mâu thuẫn A6/B11 (hao mòn) vs D2 (không trừng phạt) đã được giải nhờ fork:**
  tách *số đọc* khỏi *số dư*. Số đọc có thể rơi một cách trung thực — đó là bổn
  phận của một tấm gương. Số dư thì không bao giờ bị tịch thu. Rơi mà không mất gì.
- Hai ý tưởng mạnh nhất cycle 2 đều đi ngược trực giác gamification: **thưởng cho
  hàn gắn hơn êm đềm (H3)** và **gương phi số học kiểu cái lọ (G7)**.
- H5 là mối đe doạ nghiêm túc nhất với toàn bộ nhánh và chưa được giải quyết:
  gương đang đo mức dùng app chứ không đo mối quan hệ.

## Current Snapshot

- Problem framing: Hearts là nền kinh tế chết — có kho tiền, không faucet, gần như
  không sink. Sau khi chốt nhánh "tấm gương", bài toán chuyển hình: không còn là
  *"thêm gì để mua"* mà là **"gương đo cái gì, và một tấm gương thì tiêu kiểu nào"**.
- Target actors: Cặp đôi như một đơn vị kinh tế duy nhất. Bốn ca biên bắt buộc
  phải chịu được: yêu xa, đang xung đột, mới ghép một tuần, và gắn bó lâu nhưng
  ít dùng app.
- JTBD hoặc thời điểm sử dụng: "Cho tôi thấy được rằng chúng tôi đã thực sự có
  mặt vì nhau" và "cho tôi cách làm người kia bất ngờ mà không tiêu tiền thật".
- Value proposition: Hearts là **bằng chứng đầu tư vào mối quan hệ** — đúc ra từ
  hành vi có thật của cả hai, không bao giờ mua được bằng tiền, và kết tinh thành
  một kho lưu trữ chung mà không app nào khác có được.
- Đã chốt (không mở lại trừ khi user đổi ý):
  - Hearts = tấm gương phản chiếu quan hệ, KHÔNG phải tiền tệ trò chơi.
  - Hearts không bao giờ bán bằng tiền thật (C1 thắng C2).
  - Không hệ số nhân dưới mọi hình thức — kể cả subscription và zodiac.
  - Hearts chỉ đo "chúng ta", không bao giờ đo "anh so với em".
  - Không thưởng cho chính lời bày tỏ tình cảm; chỉ thưởng hiện diện và nghi thức.
  - Số dư không bao giờ bị tịch thu; số *đọc* thì được phép rơi trung thực.
- Option space còn mở (chưa xếp hạng):
  - **Trục nghịch lý tiêu-gương (đang chặn):** tiêu dòng giữ kho (G2) · không mua
    chỉ mở khoá theo ngưỡng (G3) · lịch sử tiêu mới là gương (G4) · đo luân chuyển
    thay vì tồn kho (G5) · hearts hết hạn thành ký ức (G6).
  - Trục hình thái gương: con số → hạng chỉ tăng (B9) → phi số học kiểu cái lọ /
    khu vườn / chòm sao (G7, và `dream_jar` đã có sẵn).
  - Trục cái được đo: tần suất → đa dạng → tương hỗ → **hàn gắn (H3)**.
  - Trục nhịp hiển thị: luôn hiện → theo yêu cầu → mỗi tháng → nghi thức thường
    niên (G9, I5).
  - Trục kiếm tiền còn sống: subscription mua *chỗ để tiêu và chất lượng lưu trữ*
    (không bao giờ mua tốc độ kiếm) · hiện vật in ra (C7) · mở khoá quyền được mua
    chứ không giảm giá theo hearts (G8).
- Differentiators: Ví chung + đồng thuận chi tiêu sẵn có, cộng "chỉ tiêu cho người
  kia" (A4) và "chỉ đúc khi cả hai cùng làm" (A9) → một đồng tiền **về mặt cấu
  trúc không thể chơi một mình**. Con hào thật là **kho lưu trữ tích luỹ (I1)**,
  và **danh sách những thứ hệ thống từ chối làm (I2)** chính là thương hiệu.
- Risks and constraints:
  - **H5 — gương đang đo mức dùng app, không đo mối quan hệ.** Đe doạ hiệu lực
    lớn nhất, chưa giải.
  - **H1 — gương thiên vị chống lại cặp yêu xa.** Ràng buộc cứng.
  - **G8 — mọi tỉ giá quy đổi ra đời thực đều kéo hearts về lại thành tiền tệ.**
  - **G1 — tiêu một tấm gương là mâu thuẫn logic.** Câu hỏi chặn chính.
  - Rủi ro đạo đức sản phẩm vẫn đứng số một (D1–D4, D9).
  - Ví chung + hai thiết bị → rủi ro double-spend (F3).
  - Không live-ops → thiết kế phải tĩnh (F2) — nay tự động thoả mãn nhờ luật
    "không hệ số nhân".
- Assumptions (chưa kiểm chứng):
  - Cặp đôi coi trọng bằng chứng đầu tư hơn là mở khoá đồ.
  - Kiếm hearts cùng nhau tạo gắn kết chứ không tạo áp lực.
  - Người dùng chấp nhận rằng hearts không mua được bằng tiền.
  - Một tấm gương trung thực có giá trị giữ chân cao hơn một vòng lặp phần thưởng.
- Open questions:
  - **[CHẶN CHÍNH]** Giải nghịch lý G1 thế nào — hệ thống còn "cửa hàng" (tiêu
    hearts) hay chuyển sang mở khoá theo ngưỡng (không tiêu gì cả)?
  - Gương đo gì là chính: tần suất, đa dạng, tương hỗ, hay hàn gắn (H3)?
  - Gương hiện dưới dạng số hay dạng phi số học kiểu cái lọ (G7)?
  - Làm sao giảm nhẹ H5 (đo app ≠ đo quan hệ) và H1 (thiên vị yêu xa)?
  - Nếu không bán hearts và không bán tốc độ, thì doanh thu đến từ đâu?
- Recommended next move: Trả lời câu hỏi chặn G1. Sau đó Affinity Clustering trên
  ~102 ứng viên, rồi NUF trên các cụm sống sót.

## Convergence Notes

- Chưa converge. Vẫn cố ý divergent: chưa xếp hạng, chưa chấm điểm, chưa cắt
  scope, chưa đề xuất handoff.
- Lưu ý: quyết định fork ở cycle 2 **không phải** convergence. Nó là một ràng
  buộc do user đặt ra, và nó loại nhánh bằng logic chứ không bằng chấm điểm.
  Cycle 2 mở ra nhiều câu hỏi hơn số câu hỏi nó đóng lại.
- Khi user yêu cầu chốt hướng: **Affinity Clustering** trước (gom ~102 ứng viên
  thành cụm), rồi **NUF** (New / Useful / Feasible) trên các cụm sống sót.

## Research Notes

- Chưa dùng web research trong cycle này. Toàn bộ grounding lấy từ mã nguồn trong
  repo (hiện trạng hearts, theme, emoji, pet) — đây là dữ kiện nội bộ, không phải
  nguồn ngoài.
- Nghiên cứu ngoài sẽ có giá trị nếu đi vào hai nhánh: (a) quy định loot box và
  tiền tệ ảo trên App Store/Google Play và EU (liên quan D10, C2), (b) bằng chứng
  học thuật về overjustification effect trong ứng dụng quan hệ (liên quan D4).
  Chưa chạy vì chưa chọn nhánh.
- Chưa dùng live-site browser probing. Chưa cần.
- Cập nhật sau cycle 2: nhánh (a) — quy định loot box — **không còn cần thiết**,
  vì quyết định "không bán hearts" đã gỡ bỏ rủi ro đó. Nhánh (b) —
  overjustification effect và các hệ đo lường quan hệ — **tăng giá trị**, vì H5
  (gương đo app chứ không đo quan hệ) giờ là rủi ro hiệu lực số một. Nên chạy
  web research trước khi converge, không phải sau.

## Session Log

- 2026-08-28: Tạo idea. Chạy cycle 1 ở stance `Ideate For Me` với 6 kỹ thuật và 5
  lần đổi domain, thu ~57 ứng viên thô. Ghi nhận 5 luật thiết kế rút ra từ bài tập
  thiết-kế-thất-bại, 2 mâu thuẫn chưa giải, và 1 khoảng trống chính sách (chia tay).
  Giữ nguyên trạng thái divergent, chưa converge. Cập nhật `idea.md`,
  `development.md`, checkpoint, registry. Bước tiếp theo: user trả lời câu hỏi fork
  "tiền tệ trò chơi vs tấm gương quan hệ".
- 2026-08-28: Cycle 2 ở stance `Ideate For Me` sau khi user chốt nhánh "tấm gương
  phản chiếu quan hệ". Chạy 4 kỹ thuật mới (Assumption Smash vòng 2, JTBD Extremes,
  Anti-Commodity Differentiation, Channel-First) và 5 lần đổi domain, thu thêm ~45
  ứng viên (tổng ~102). Ghi nhận 5 nhánh bị quyết định fork giết chết theo dây
  chuyền (C2, C3, C4, C5, B15) và luật "một tấm gương không có hệ số nhân". Giải
  được mâu thuẫn hao-mòn-vs-trừng-phạt bằng cách tách *số đọc* khỏi *số dư*, và
  giải được khoảng trống chia tay (D6) bằng nghi thức kết xuất. Mở ra nghịch lý
  trung tâm mới G1 ("không tiêu được một tấm gương") và rủi ro hiệu lực H5 ("gương
  đo mức dùng app"). Vẫn giữ divergent. Bước tiếp theo: user trả lời câu hỏi G1.
