# Brainstormer Checkpoint

Scope:

- Idea ID: IDEA-20260829-001_solo-stage1-breadth-expansion
- Workflow: develop-idea
- Lifecycle: ACTIVE
- Development Status: IN_PROGRESS (mở lại ở vòng 8)

Current State:

- Last Session: 2026-09-03 (vòng 10 — phủ lỗ hổng, viết lại idea.md)
- Latest Focus: **vòng 10 — J6/J9 ĐÃ PHỦ, idea.md ĐÃ TỰ-ĐỦ.** SB-211 "Trước giờ
  đi" (checklist tất định) phủ J6; SB-212 "Cảm ơn + chốt việc kế tiếp" (hướng
  ra ngoài, đối lập J8) phủ J9. Cả hai là mở rộng của màn (1), tổng vẫn 11 màn
  hình. **13/13 journey xử lý có chủ ý.** `idea.md` được viết lại: mục
  `## Đặc tả sản phẩm (vòng 9-10)` nay chứa đầy đủ journey + vòng đời + bản đồ
  màn hình + mô tả chi tiết tính năng + bảng gán ngược, không còn cần đọc
  `development.md` để hiểu sản phẩm.
- Facilitation Stance: Creative Partner
- Active / Next Technique: đã chạy L1-L42. Vòng 5 dùng Constraint Ladder
  ("cấm suy đoán về người kia") + Reframing ba tầng + Trend Survey + phản biện.
  Mỗi hạng mục vòng 5 đã có phán quyết hợp lệ/không hợp lệ tại chỗ.
- Approximate Raw Idea Count: 210 (SB-01..SB-210) + 13 journey (J1..J13) + 7 neo
  mở lại (N1..N7) + 5 nguyên thuỷ link (L-a..L-e) + 12 khung nhại + 8 chế độ
  thất bại (F1..F8)
- Convergence State: **🟡 CẤU TRÚC + LUẬT ĐỀU ĐÃ ĐỦ, CHỜ USER XÁC NHẬN CUỐI.**
  Chưa tự đặt `EXPANDED` — cần xác nhận rõ ràng trước khi đổi trạng thái và
  trước khi soạn bản bàn giao v8 gộp.
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

- Action: **trình `idea.md` § "Đặc tả sản phẩm (vòng 9-10)" cho user xác nhận
  cuối.** Nếu chấp nhận → set `Development Status: EXPANDED` trong `idea.md` +
  registry, rồi soạn **bản bàn giao v8 gộp** trong `development.md`
  `## Convergence Notes` (PHẦN 1 luật từ v7 + phần cấu trúc từ `idea.md` §
  Đặc tả sản phẩm) trước khi user chuyển cho `scrum-master`. Nếu user muốn sửa
  bản đồ màn hình hoặc mở nhánh khác → vòng 11.
- Inputs: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` (bản tự-đủ, đọc file
  này là đủ, không cần mở `development.md`), `development.md` → `S5` (chi tiết
  thiết kế SB-211/SB-212 nếu cần lý do sâu hơn)
- Output Paths: `idea.md`, `development.md`, `brainstormer-checkpoint.md`,
  registry (`data/brainstorms/master_ideas_list.md`, khi set EXPANDED)

Do Not Re-read:

- broad prior chat narrative
- các thư mục idea khác (đã trích đủ ngữ cảnh giao thoa vào idea.md)
- `.claude/skills/brainstormer/**` (đã nạp đủ trong phiên này)
- `development.md` toàn file (159 KB — dùng Large File Query Keys bên dưới)
- `### ★ BẢN BÀN GIAO CUỐI (v7)` — vẫn đúng về LUẬT, không còn nguồn chính cho
  CẤU TRÚC sản phẩm (nguồn chính nay là `idea.md` § Đặc tả sản phẩm)
- mục "Kiểm tra độ phủ bằng lưới journey" cũ trong `## Convergence Notes` — đã
  xác nhận SAI ở L44, giữ lại chỉ làm bằng chứng, không dùng làm căn cứ

Large File Query Keys:

- `idea.md`: `## Đặc tả sản phẩm (vòng 9-10)` — **bản tự-đủ, đọc mục này là đủ**
  để hiểu toàn bộ journey/vòng đời/màn hình/tính năng, không cần mở
  `development.md` cho việc này nữa.
- `development.md`: `### 2026-09-03 (vòng 10) · S5` — lý do thiết kế chi tiết
  của SB-211/SB-212 nếu cần đào sâu hơn bản tóm tắt trong `idea.md`.
- `development.md`: `### 2026-09-03 (vòng 8) · L43`..`· L48` — chẩn đoán gốc
  (vì sao idea bị mở lại)
- `development.md`: `### 2026-09-03 (vòng 9) · S1`..`· S4` — lưới journey
  chuẩn, vòng đời, bản đồ màn hình, bảng gán ngược (bản gốc trước khi vào idea.md)
- `development.md`: `### ★ BẢN BÀN GIAO CUỐI (v7)` — PHẦN 1 (đề xuất sửa luật)
  vẫn có hiệu lực, cần khi soạn bản bàn giao v8 gộp

Open Threads (vòng 10 — J6/J9 đóng, chỉ còn xác nhận cuối):

- ✅ **J6 và J9 ĐÃ PHỦ** bởi SB-211 và SB-212 (vòng 10). Không còn journey nào
  trống ngoài chủ đích.
- ⏳ **Chờ user xác nhận cuối trên `idea.md` § Đặc tả sản phẩm** trước khi đặt
  `EXPANDED` — không phải câu hỏi mở kiểu OQ, là bước duyệt trước khi đổi
  trạng thái và soạn bản bàn giao v8 gộp.
- ⏳ **OQ-3** — ai biên tập và duyệt kho nội dung. Vẫn treo, câu hỏi nguồn lực.
- ✅ OQ-2 coi như trả lời một phần (mỗi trạng thái trong màn (1) là một "ngăn");
  chi tiết UI để PO/UX chốt.
- ⏳ **OQ-7** — đường đi chặng 1.5 → REQ-014 (D-8). Không đổi.
- **Trò chơi "đoán" (SB-144/145/146)** — chưa gán màn cố định, không chặn.
- ✅ Đã đóng: OQ-5, OQ-6, OQ-8..OQ-20 (toàn bộ chuỗi OQ-18/19/19b/20 vòng 8-9).
