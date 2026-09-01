# Brainstormer Checkpoint

Scope:

- Idea ID: IDEA-20260829-001_solo-stage1-breadth-expansion
- Workflow: develop-idea
- Lifecycle: ACTIVE
- Development Status: EXPANDED

Current State:

- Last Session: 2026-08-29 (vòng 7 — đóng gói bàn giao)
- Latest Focus: (vòng 7) user chốt *"theo đề xuất của bạn"* → **D-12 nấc 3**,
  **D-13 bản A + A+**, **D-14 hiển thị dải**. Việc chính của vòng 7 là **gộp**
  ba khối nháp rời (vòng 4/5/6) thành **một bản bàn giao duy nhất**, vì chúng
  mâu thuẫn nội bộ (vòng 5 cấm cái vòng 6 mở). Việc gộp làm lộ ra **ba nền móng
  dữ liệu song song**: thẻ có cấu trúc (tả *việc*) · sổ tay (tả *người kia*) ·
  hồ sơ kỹ năng (tả *người dùng*). **Brainstorm kết thúc.**
- Facilitation Stance: Creative Partner
- Active / Next Technique: đã chạy L1-L42. Vòng 5 dùng Constraint Ladder
  ("cấm suy đoán về người kia") + Reframing ba tầng + Trend Survey + phản biện.
  Mỗi hạng mục vòng 5 đã có phán quyết hợp lệ/không hợp lệ tại chỗ.
- Approximate Raw Idea Count: 210 (SB-01..SB-210) + 13 journey (J1..J13) + 7 neo
  mở lại (N1..N7) + 5 nguyên thuỷ link (L-a..L-e) + 12 khung nhại + 8 chế độ
  thất bại (F1..F8)
- Convergence State: **✅ ĐÃ HỘI TỤ VÀ ĐÓNG GÓI.** Không còn câu hỏi chặn. Bản có hiệu lực: `### ★ BẢN BÀN GIAO CUỐI (v7)` trong `development.md ## Convergence Notes`.
- (lịch sử) **ĐÃ HỘI TỤ (vòng 5).** Vòng 4: 125 → 10 cụm → 4
  đợt. Vòng 5: thêm 49 ứng viên, hội tụ tại chỗ theo luật ba tầng, cộng thứ tự
  bắt buộc ở SB-174, cộng phần bổ sung cho bản nháp REQ-013.
- Research Needed: KHÔNG. Vòng 5 đã chạy RS-D1..RS-D6 (app chiêm tinh, trào lưu
  "how well do you know me", tâm lý lan truyền của trắc nghiệm, trào lưu cặp đôi
  2026, nghiên cứu "hết chuyện để nói", nghiên cứu app Paired/JMIR). CÓ nếu sau này mở
  nhánh OQ-7 (điều kiện/chi phí/xác thực Zalo Mini App cho sản phẩm C2C) —
  nhưng đó là việc của REQ-014.

Files Updated:

- idea.md
- development.md
- brainstormer-checkpoint.md

Quyết định đã chốt (KHÔNG mở lại):

- D-1: chặng 1 chỉ phục vụ người ĐÃ CÓ "mối"; đối phương chưa cài app.
  SB-09 loại, SB-53 PARKED.
- D-2: nhập vào `REQ-013` (đang PENDING, chưa breakdown), không tách REQ mới.
- D-3: OQ-2 (một "ngăn" hay nhiều "ngăn") vẫn chưa chốt.
- **D-4: đường PRESET + MAD-LIBS + KHUNG NHẠI.** AI được dùng NGOÀI sản phẩm ở
  khâu soạn nội dung, không bao giờ ở khâu chạy. Luật 5 của REQ-013 giữ nguyên.
- **D-5: lời mời là TÍNH NĂNG.** Định vị chặng 1 vẫn là "trợ lý hoạt động".
  SB-120 loại với tư cách định vị.
- **D-6: R-1b được duyệt** — cấm đo lường hành vi người kia.
- **D-7: R-1c + R-1d được duyệt** — cửa từ chối sạch; nội dung chỉ tự trào.
- **D-8: chặng 1.5 → REQ-014**, REQ-013 giữ móc SB-125.
- 🔴 **D-9: user quyết định MỞ R-1.** ⚠️ CHỈ THỊ, **chưa có hiệu lực** — R-1 nằm
  trong `REQ-013 ## Invariant Design Rules`, chỉ Product Owner (qua
  `scrum-master`) sửa được. Không đem D-9 đi làm story trước khi luật được sửa.
- **D-10: `R-1e` (luật ba tầng) + `R-1f` (sổ tay) được duyệt.**
- **D-11: quà chỉ là Ý TƯỞNG, không thương mại; mở nhánh handmade theo chuyên
  môn của người dùng.**
- **D-12: mở R-1 ở NẤC 3** — mở (a) + (d); giữ cấm (b), (c), (e), (f). Nấc 4 không bao giờ.
- **D-13: mồi chuyện = bản A + bản A+ ("sự kiện có lịch")**; bản B → REQ-014.
- **D-14: chỉ số ăn khớp hiển thị DẢI, không hiển thị %.**

Xung đột phải xử trước khi làm story:

1. **D-9/D-12 chưa có hiệu lực** — artifact và `req_master.md` đang nói ngược
   nhau cho tới khi PO sửa `Invariant Design Rules` (PHẦN 1 của bản bàn giao).
2. **D-9 vs D-10** — `R-1e` cấm tầng 3, D-9 mở tầng 3. Hoà giải: mở **chỉ trên
   dữ liệu người dùng tự nhập**.
3. **D-9 vs `R-1b` (D-6)** — ranh giới: ghi **sở thích + sự kiện** ✅, ghi
   **tần suất + hành vi** ❌ ("hay trả lời chậm" là cấm).
4. **D-9 vs định vị D-5** — chân dung/chỉ số nằm **sau một hành động**, không ở
   màn hình chính (SB-208).

Next Valid Step:

- Action: **brainstorm đã xong.** User chuyển
  `### ★ BẢN BÀN GIAO CUỐI (v7)` (trong `development.md ## Convergence Notes`)
  cho `scrum-master`. Brainstormer KHÔNG ghi vào `data/requirements/`.
- ⚠️ **Product Owner xử lý PHẦN 1 (sửa `Invariant Design Rules`) TRƯỚC PHẦN 2.**
- Nếu quay lại brainstorm: chỉ còn OQ-2 (thiết kế, PO/UX chốt) và OQ-3 (nguồn
  lực, user chốt). Cả hai **không chặn bàn giao**; OQ-3 chặn **thực thi**.
- Output Paths:
  - `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/idea.md`
  - `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/development.md`
  - `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/brainstormer-checkpoint.md`

Do Not Re-read (đã tiêu hoá vào artifact):

- broad prior chat narrative
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/development.md`
  (181 KB — chỉ grep theo từ khoá nếu thật sự cần)
- `.claude/skills/brainstormer/**` (đã nạp đủ trong phiên này)
- `development.md` toàn file (107 KB — dùng Large File Query Keys bên dưới)
- `data/requirements/REQ-013.../req_master.md` toàn file — chỉ grep
  `## Invariant Design Rules` hoặc `## Out of Scope`
- `IDEA-20260828-002/candidate-review.md` toàn file — chỉ grep `## Phần E`

Large File Query Keys (`development.md`, dùng grep/ranged read, KHÔNG đọc cả file):

- `## BMAD Session State`
- `### 2026-08-29 · L0` (chẩn đoán F1-F8)
- `### 2026-08-29 (vòng 2) · L12` (bản đồ 13 journey)
- `### 2026-08-29 (vòng 2) · L13` (7 neo mở lại N1-N7)
- `### 2026-08-29 (vòng 2) · L14` (chặng 1.5 + luật R-1b)
- `### 2026-08-29 (vòng 3) · L19` (12 khung nhại)
- `### 2026-08-29 (vòng 3) · L21` (7 khoảnh khắc + lịch âm × khung)
- `### 2026-08-29 (vòng 3) · L22` (R-1c, tự trào, chặn giọng)
- `### 2026-08-29 (vòng 4) · D2` (quyết định D-4, D-5)
- `### 2026-08-29 (vòng 4) · L24` (hệ quả kiến trúc, SB-121..SB-125)
- `### Affinity Clustering` (bảng 10 cụm)
- `### Impact / Effort trên cụm` (bảng 4 đợt)
- `### 2026-08-29 (vòng 5) · L25` (**va chạm: cái gì đã bị loại rồi** + trích dẫn)
- `### 2026-08-29 (vòng 5) · L26` (luật ba tầng GHI/ĐOÁN/SUY-CHẤM)
- `### 2026-08-29 (vòng 5) · L27` (sổ tay mối quan hệ)
- `### 2026-08-29 (vòng 5) · L28` (hoàng đạo/MBTI làm lớp vỏ)
- `### 2026-08-29 (vòng 5) · L30` (quà tặng + ranh giới thương mại)
- `### 2026-08-29 (vòng 5) · L31` (mồi chuyện + chuyện dở dang)
- `### 2026-08-29 (vòng 5) · L32` (kịch bản buổi hẹn 3 phần)
- `### 2026-08-29 (vòng 5) · L33` (**bảng chuyển hoá trào lưu**)
- `### 2026-08-29 (vòng 5) · L34` (phản biện: app tạp hoá, thứ tự bắt buộc)
- `### Đề xuất bổ sung cho REQ-013` (**bản nháp bàn giao**)
- `### Bổ sung vòng 5 cho bản nháp đề xuất REQ-013`
- `## Current Snapshot`
- `## Research Notes` (RS-A1..RS-A8, RS-B1..RS-B4, RS-C1..RS-C3)

Inherited Constraints (KHÔNG brainstorm lại — nguồn: REQ-013 `## Invariant Design Rules`):

- `data/requirements/REQ-013_solo_dating_assistant_stage1/req_master.md`
  mục `## Invariant Design Rules` — 6 luật: (1) trợ lý làm việc trên HOẠT ĐỘNG
  chứ không trên NGƯỜI KIA, cấm chấm điểm/xếp hạng/streak/bảng xếp hạng;
  (2) lưu được thì phải xoá được; (3) khung "chăm sóc nhau", đừng hứa kết quả
  cảm xúc rồi giao một cái lịch; (4) không paywall trên bộ tính năng lõi;
  (5) không AI ở bất kỳ đâu trong REQ-013 — **đã làm rõ ở D-4: đây là ràng buộc
  RUNTIME; AI được dùng ngoài sản phẩm ở khâu soạn nội dung**; (6) nhật ký riêng
  tư mặc định và xoá được.
- Cổng cứng của REQ-013: *"chặng 1 có dùng được trọn vẹn kể cả khi người kia
  không bao giờ tham gia không?"* — D-5 tồn tại để bảo vệ cổng này.

Open Threads (không còn cái nào chặn bàn giao):

- ⏳ **OQ-3 — nút thắt số 1 khi THỰC THI**: ai biên tập và **duyệt** kho nội dung
  (144 + 256 ô bảng tra + 150-250 thẻ mồi + mồi chuyện + sự kiện có lịch + chỉ
  mục quà + công thức handmade). Câu hỏi **nguồn lực**, chỉ user trả lời được.
- ⏳ **OQ-2** — một hộp / nhiều hộp. Đề nghị PO/UX chốt khi làm M2.
- ⏳ **OQ-7** — đường đi chặng 1.5 → REQ-014 theo D-8.
- ✅ Đã đóng: OQ-5, OQ-6 (D-6), OQ-8 (D-8), OQ-9 (D-4), OQ-10 (D-5), OQ-11 (D-7),
  OQ-12 (D-9), OQ-13 (D-10), OQ-14 (D-13), OQ-15 (D-11), OQ-16 (D-12), OQ-17 (D-14).

New Large File Query Keys (vòng 6):

- `development.md`: `L35 · Giới hạn quyền` · `L36 · R-1 không phải một luật` ·
  `L37 · Cơ chế hại thật sự` · `L38 · Xây "chỉ số ăn khớp"` · `L39 · Bài toán
  một phía` · `L40 · OQ-14 giải thích` · `L41 · Quà handmade` · `L42 · Phản biện`
- 🔑 **Bản bàn giao có hiệu lực: `### ★ BẢN BÀN GIAO CUỐI (v7)`** trong
  `development.md ## Convergence Notes`. Ba khối "Bổ sung vòng 4/5/6" là **lịch
  sử suy luận**, KHÔNG dùng làm đầu vào cho Product Owner.
- Nghiên cứu vòng 6: `RS-E1` (sycophancy, Stanford/*Science*), `RS-E2`
  (effort heuristic — quà handmade).
