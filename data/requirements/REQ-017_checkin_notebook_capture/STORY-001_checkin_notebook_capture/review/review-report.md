# Story Review — STORY-001 Ghi điều mới biết về người ấy vào sổ tay trên màn check-in 23h

Outcome: DEFERRED_ONLY

- Review type: `final-synthesis` (Tier 3, pass 5 of 5 — sau 4 slice `scoped-slice`)
- Story: `STORY-001_checkin_notebook_capture` (REQ-017), Complexity `standard`, Lane `shared` (mobile-only trên thực tế)
- Worktree: `story-REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`
- BaseHead: `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1`
- Đây là verdict duy nhất ở cấp story. Bốn slice trước đều `PARTIAL_SLICE_ONLY`, không slice nào quyết định đóng story.

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: `final-synthesis`; report path: `review/review-report.md` (đúng `WriteScope`/`OutputPath`).
- Đầu vào đã đọc: `review/slice-p1-schema.md`, `review/slice-p2-content-pack.md`,
  `review/slice-p3-capture-ui.md` (đọc theo range, tệp 25.7 KB), `review/slice-p4-origin-label.md`
  (đọc theo range, 24.3 KB), `scrum-master-checkpoint.md` §Phase Status/§Resolved Blockers/§Story Review,
  `story_master.md` (toàn bộ, 10 KB — cần AC-5 nguyên văn + `## Out of Scope` + `## Open Question Impact`).
- Không đọc lại source implementation, không chạy lại verification của slice nào: mỗi slice đã dẫn số dòng
  chính xác và Scrum Master đã tự đối chiếu trực tiếp với source (checkpoint §Story Review).
- Ba truy vấn bổ sung ngoài slice report, đều vì slice tự khai là chưa ai chốt:
  cả bốn slice ghi "story-level mobile launch smoke ... owned by final synthesis". Đã truy vấn
  `coding-plan/test-results.md` và `coding-plan/master-plan.md` cho `smoke|reachab|entry point`,
  và `coding-plan/test-results.md` của REQ-016 STORY-012 để lấy tiền lệ hai gate đó.
- Touched risk surfaces tổng hợp: persistence/schema/migration (P1), typed/generated contract (P1/P2),
  local storage-offline content (P2), mobile interaction (P3/P4), mobile navigation/discoverability (P3/P4),
  app lifecycle (nâng `schemaVersion` chạy khi app khởi động).
- Phase 2 được phép tiếp tục; review kết luận `PATCH_REQUIRED`, không `BLOCKED`.

## Outcome và lý do

Toàn bộ phần code của story lành: 51/51 verdict row qua 4 slice đều PASS, không slice nào để lại
finding chặn, và hai hạng mục mà handoff yêu cầu cân nhắc (R-1, F-7) đều **không** đủ nặng để chặn.
Story vẫn `PATCH_REQUIRED` vì **hai gate cấp story bắt buộc chưa có bằng chứng nào cả** — không slice
nào nhận, và mỗi slice đều ghi rõ là đẩy sang pass này (B-1, B-2 dưới đây). Cả hai đều bù được bằng
bằng chứng, không cần sửa code, và repo này đã có tiền lệ đầy đủ ở story liền trước.

## Blocking findings

### B-1 — Thiếu `## Story Runtime Startup Smoke` (rule 12g) — chặn

`coding-plan/test-results.md` không có section này (truy vấn `smoke` trả về đúng một dòng, dòng 733,
nói về "entry point" của một tệp import, không liên quan). `story_master.md` **không** ghi
`Runtime-Smoke: WAIVED — <reason>`, tức không có miễn trừ hợp lệ. `master-plan.md:37` ghi
`startup smoke NOT_APPLICABLE` cho `mobile-app`, nhưng đó là ghi chú kế hoạch của Tech Lead ở §4
Lane Summary, không phải chỗ rule 12g nhận miễn trừ; `master-plan.md:66` còn nói thêm rằng test scope
của từng phase *không* chứa startup smoke — nghĩa là cả 4 phase đều đúng khi bỏ qua, và nghĩa vụ này
rơi về cấp story, không biến mất.

Đây không phải hình thức. Story nâng `schemaVersion` 10 → 11 và thêm ba cột bằng `m.addColumn`; đường
migration đó **chỉ chạy thật khi app mở trên một máy đang giữ database phiên bản cũ**. Bằng chứng P1
là test migration trên file v10 dựng trong test (Gate 1, `+106`, exit 0) — đúng và cần, nhưng nó không
chứng minh app khởi động được sau khi nâng schema. Rule 12g tồn tại chính cho cái khoảng trống này.

Tiền lệ chứng minh gate này chạy được trong repo, không phải đòi hỏi bất khả thi: REQ-016 STORY-012
`coding-plan/test-results.md:1319-1348` có `## Story Runtime Startup Smoke` với `Result: PASS`, đủ chuỗi
build → cài → khởi chạy nguội → tới màn đầu, ảnh màn đầu đã mở ra nhìn, quét crash log — và section đó
được mở ra chính vì một review trước đó ghi nó là gap `G-3` theo rule 12g.

### B-2 — Thiếu `## Entry Point Reachability` (rule 12e1) — chặn

Story là UI-facing (`story_master.md:115` `UI-facing story: YES`) nên section này bắt buộc và không
miễn trừ được. `coding-plan/test-results.md` không có nó, và không có dòng `Reachable:` nào.
So sánh: REQ-016 STORY-012 có `## Entry Point Reachability` ở dòng 1218 với `Reachable: YES` cho từng
bề mặt (kể cả dòng 1313 trỏ `evening_check_in_sheet.dart:257-284`).

Phần **nội dung** của 12e1 thì đã đạt và đã được kiểm trong code, nên đây là gap bằng chứng chứ không
phải gap chức năng: `master-plan.md:70-73` khai không thêm route/điểm vào nào; P3-A1 xác nhận khối hỏi
mount trong màn check-in 23h sẵn có (đến được từ nhắc 23h) và P3-A3 xác nhận điều kiện hiện khối là
nội dung đã ship, không phải seam test; P4-A1 xác nhận nhãn xuất xứ nằm trong nhóm sẵn có của màn Sổ tay
(vào qua nhóm KHO / tab Sổ tay). Vì vậy việc bù là ghi lại đường đi cụ thể + `Reachable: YES`, không
phải làm thêm điểm vào.

## Hai hạng mục được yêu cầu cân nhắc

### R-1 (AC-8(i) "tối đa một mục") — DEFERRED, không chặn

Kết luận: giữ nguyên như Slice 3 đã cân, và tôi đồng ý.

- AC-8(ii) "thao tác lưu lặp lại hay chạm hai lần không tạo mục trùng" — **đạt và có test**:
  `onPressed: _busy ? null : _save`, `_busy` set đồng bộ trong `setState` trước `await` đầu tiên;
  hai cú chạm người thật cách nhau ≥ 6 frame nên cú thứ hai không tới được handler (P3-A13).
- AC-8(i) "lần check-in đó tạo tối đa một mục" — với đường tuần tự (lưu lại, thử lại sau lỗi) thì
  `recordFromCheckIn` select-then-update trả về đúng một hàng, có unit chứng minh (P1-A2). Chỉ còn hở
  ở cửa sổ sub-frame/concurrent: `recordFromCheckIn` không bọc `transaction` và không có unique index
  trên `(owner_key, origin_check_in_ref)`.
- Cân nặng: đường duy nhất vào là một `FilledButton` trên một modal; không có job nền, không có
  đường thứ hai gọi cửa ghi này. Hậu quả tệ nhất là một mục sổ tay trùng, người dùng thấy và xoá được
  bằng đúng thao tác có sẵn — không mất dữ liệu, không sai trạng thái thẻ, không rò rỉ.
  Điều kiện tự động `PATCH_REQUIRED` mà handoff của Slice 3 đặt ra ("nếu không có guard nào trong cả
  call path") không thoả: guard có, chỉ chưa phải dedup theo id check-in.
- Xử lý: DEFERRED. Nếu pass rework cho B-1/B-2 có lý do mở `evening_check_in_sheet.dart` thì cách đóng
  rẻ nhất là chốt latch giống hệt cái mà nửa journal đã có (`_journalHandedOff`): một
  `String? _captureWrittenForRef` set trước `await`, hoặc `if (_busy) return;` ở đầu `_save`.
  **Không bắt buộc** — đừng mở file chỉ vì việc này.

### F-7 (AC-5 "đổi loại") — AC-5 PARTIAL, DEFERRED về code, nhưng cần một quyết định phạm vi

Stop rule của handoff hỏi trước: `## Out of Scope` có loại trừ hành vi "đổi loại" một cách tường minh
không? **Không.** Dòng gần nhất, `story_master.md:45` "sửa mục trên màn check-in", loại trừ việc sửa
trên *màn check-in*, không phải trên màn Sổ tay — nơi F-7 xảy ra. Nên không thể xử F-7 bằng đường
"đã out-of-scope tường minh".

Nhưng nó cũng không tới ngưỡng `PATCH_REQUIRED`, vì ba lý do đo được:

1. **Phạm vi hiệu lực của AC-5 bị chính story bó lại.** `## In Scope` mục 4 (`story_master.md:36-37`)
   hứa "sửa/xoá **bằng đúng thao tác của mọi mục khác**", và `ux/uiux-spec.md` Phần C:137-139 cấm thêm
   lựa chọn thứ ba / khác biệt so với mục thường. Trên bề mặt đã ship thì **không mục sổ tay nào**
   đổi được loại khi sửa — `updateEntry` không có tham số `kind`, và `ContextInlineAddRow` chế độ sửa
   không nhận `options`/`selectedOptionId`. Tức là ngang bằng (parity) — điều story thực sự hứa — vẫn
   đạt. Muốn có "đổi loại" thì phải sửa UI sửa-mục của REQ-016 STORY-004 cho *mọi* mục, việc nằm ngoài
   story này và cần PO/UX chốt riêng.
2. **Story không làm nó tệ hơn** (rule 7): đây là hành vi thừa hưởng từ REQ-016 STORY-004, P4 không
   gây ra, và Slice 4 đã dẫn số dòng cho cả ba mắt của chuỗi thiếu.
3. **Nửa còn lại của AC-5 đạt và có test**: sửa nội dung có hiệu lực ngay và nhãn xuất xứ giữ nguyên
   (P4-A4 ở tầng widget, P1-A3 ở tầng dữ liệu — companion của `updateEntry` không mang ba cột origin
   nên không đường ghi nào dịch được chúng); xoá thì mục biến mất, không thêm dialog nào.

Một lưu ý trung thực về workaround: xoá rồi thêm lại là đường ra có sẵn cho người dùng, nhưng mục thêm
lại **mất nhãn xuất xứ** — nên tổ hợp "đổi loại mà nhãn giữ nguyên" đúng là không đạt được hôm nay.
Ảnh hưởng có giới hạn (chọn sai nhóm lúc ghi, mất một dòng caption khi tự sửa), không phải mất dữ liệu.

Vì vậy: AC-5 chấm **PARTIAL**, phần "đổi loại" DEFERRED như hở tiền tồn của bề mặt chủ. Nhưng có một
defect *thuộc story này* cần đóng, và nó là artifact chứ không phải code: `phase-P4-notebook-origin-label.md`
§4:86 **khai** mục acceptance "đổi loại" là đạt, trong khi `test-results.md` `## P4` không ghi deviation
nào. Một claim acceptance không có gì đỡ là chính thứ làm review sau đọc sai trạng thái story
(xem A-3). Tôi khuyến nghị Option A (vá câu chữ AC-5 + khai deviation) hơn Option B (chấm story
incomplete), vì Option B sẽ đòi một pass sửa UI sửa-mục của REQ-016 mà story này không được phép mở.

## Action items

| Id | Owner | Việc | Chặn? |
|----|-------|------|-------|
| A-1 | mobile-dev (hoặc devops nếu Scrum Master route vậy) | Bù `## Story Runtime Startup Smoke` vào `coding-plan/test-results.md` với `Result: PASS`: đủ chuỗi build → cài → khởi chạy nguội → tới màn đầu trên thiết bị/simulator đã có sẵn, ảnh màn đầu **mở ra nhìn** (không màn đỏ, không màn trắng, không tofu), quét crash log. Theo đúng khuôn mẫu REQ-016 STORY-012 `coding-plan/test-results.md:1319-1348`. Vì story nâng `schemaVersion` 10 → 11, ưu tiên khởi chạy trên máy đang giữ database phiên bản cũ để migration chạy thật; nếu không dựng được trạng thái đó thì ghi rõ đã khởi chạy trên database mới và điều đó là giới hạn của bằng chứng. | YES |
| A-2 | mobile-dev | Bù `## Entry Point Reachability` vào `coding-plan/test-results.md` với `Reachable: YES` + đường đi cụ thể cho cả hai bề mặt: khối hỏi trên màn check-in 23h (đến từ nhắc 23h, mount trong `evening_check_in_sheet.dart`) và nhãn xuất xứ trên màn Sổ tay (nhóm KHO / tab Sổ tay). Không thêm điểm vào mới — `master-plan.md:70-73` đã khai không có route mới. | YES |
| A-3 | Scrum Master (+ product-owner cho câu chữ AC) | Đóng F-7 bằng một trong hai: (A, khuyến nghị) vá `story_master.md` AC-5 để "đổi loại" trỏ về lựa chọn lúc thêm (AC-3), đồng thời khai deviation trong `test-results.md` `## P4` và sửa claim ở `phase-P4-notebook-origin-label.md` §4:86; hoặc (B) mở story tiếp theo cho "đổi loại khi sửa" trên bề mặt REQ-016 STORY-004 và ghi AC-5 là chưa đạt. Reviewer không tự sửa artifact nào trong hai hướng này. | YES (chỉ ở mức artifact/quyết định, không phải code) |
| A-4 | mobile-dev | Tuỳ chọn, chỉ làm nếu A-1/A-2 đã mở `evening_check_in_sheet.dart` vì lý do khác: latch dedup cho nửa notebook (`String? _captureWrittenForRef` hoặc `if (_busy) return;`) để đóng R-1. | NO |

## Traceability — AC → slice chốt → verdict

| AC | Slice chốt | Verdict |
|----|-----------|---------|
| AC-1 | P3-A1 | PASS |
| AC-2 | P3-A7 | PASS |
| AC-3 | P3-A4, P3-A5 (hành vi) + P2-A3/P2-INV2 (nội dung) | PASS |
| AC-4 | P4-A1 | PASS |
| AC-5 | P4-A4 + P1-A3 (sửa/xoá, nhãn giữ nguyên) | PARTIAL — nửa "đổi loại" không đạt, F-7, deferred |
| AC-6 | P3-A6 | PASS |
| AC-7 | P3-A1 | PASS |
| AC-8 | P3-A13 (ii), P1-A2 (i, tuần tự) | PASS với residual R-1 ở cửa sổ sub-frame |
| AC-9 | P1-A4, P1-INV4, P3-A12, P4-A2, P4-A3 | PASS |
| AC-10 | P4-A6 | PASS |
| AC-11 | P1-INV4, P4-A11 | PASS (nửa xoá-nhật-ký đạt rỗng, O-5) |
| AC-12 | P3-A10 | PASS |
| AC-13 | P4-A7 | PASS (chốt hẳn, không slice nào còn nợ) |
| AC-14 | P2-A1, P2-A2, P3-A2, P4-A9, F-4 closed | PASS |
| AC-15 | P2-A5, P4-A8 | PASS |
| AC-16 | P3-A8, P3-A9 | PASS |
| AC-17 | P3-A5, P3-A7 | PASS |

- Architecture: `architecture/solution.md` §1 KD-1..KD-5 và §4 — kiểm ở P1-INV1..INV9 (một cửa ghi),
  P3-INV1 (cửa vào entry-point mở rộng đúng tiền lệ `recordAnsweredQuestion` thay vì sửa guard test),
  P4-A2/A3 (degrade là đường duy nhất, lỗi đọc không tới UI).
- UX: `ux/uiux-spec.md` Phần A/B (P3), Phần C/E (P4), Phần D (P2/P4). Hai `DESIGN_SPEC_CONFLICT` đều
  được **khai** chứ không ẩn, và precedence đúng: hai canvas REQ-016 (`23h-vua-ve-j8`,
  `2-so-tay-nguoi-yeu`) vẽ trạng thái REQ-016 nên phần tử mới của story này được chấm theo UX, phần tử
  cũ chấm theo canvas. Chấp nhận, không escalate: đây không phải câu hỏi anchor còn mở mà là các delta
  đã merge của REQ-016, và hai reviewer độc lập đã chấp nhận cùng một precedence.
- OQ discipline: `story_master.md` `## Open Question Impact` không ghi phạm vi nào bị chặn; OQ-1, OQ-2,
  A-5 đều RESOLVED 2026-09-27 trong `req_master.md` `## User Decisions`. Không có phạm vi bị chặn nào
  được làm, không có phạm vi không-bị-chặn nào bị bỏ. Không có lỗi OQ (rule 12).
- Configuration guide: NOT_APPLICABLE. Thay đổi cấu hình duy nhất của story là dòng asset dir
  `assets/data/req017/` trong `pubspec.yaml` (P2-INV5); không env var, không secret, không third-party.

## Risk surfaces và critical gates

| Risk surface | Critical gate | Kết quả |
|---|---|---|
| persistence/schema/migration | migration cộng thêm chứng minh trên file v10 thật + ripple `schemaVersion` xanh cùng lần chạy | PASS (P1-A1, P1-INV2) |
| typed/generated contract | codegen chỉ cộng thêm + compile-proof qua named args | PASS (P1-INV7) |
| local storage/offline content | parser từ chối mọi shape sai + gate nội dung quét pack từ đĩa | PASS (P2-A4, P2-INV4) |
| mobile interaction | widget/unit suite mục tiêu, xanh | PASS (P3 Gate 1/2, P4 Gate 5) |
| mobile navigation/discoverability | `## Entry Point Reachability` | **MISSING — B-2** |
| app lifecycle (khởi động sau nâng schema) | `## Story Runtime Startup Smoke` | **MISSING — B-1** |
| mobile static analysis | analyze theo tệp đã đổi (baseline repo không bao giờ exit 0) | PASS (P1-INV9, P2-INV8, P3/P4 Gate 4) |
| visual fidelity per story (12e2/12e3, lane mobile) | 2 màn có cặp ảnh thật + `VISUAL_FIDELITY: PASS` + gate chạy live | PASS — Slice 3 và Slice 4 mỗi bên tự chạy lại `visual_fidelity.py --stage review --stack mobile` (exit 0) **kèm negative control** đổi tên tệp làm gate exit 1, và đã mở ảnh ra nhìn (không tofu, dấu tiếng Việt đủ, đúng màn, cả hai nhánh nhãn trên một ảnh) |
| evidence hygiene | `git status --porcelain` không bẩn PNG của story khác | PASS (P2 Gate 5, P3 :624-625, P4 O-9) |

## Xử lý toàn bộ carry-forward

| Id | Xử lý |
|----|-------|
| R-1 (AC-8(i) sub-frame) | DEFERRED, chấp nhận residual. Cách đóng rẻ nêu ở A-4, không bắt buộc. |
| F-7 (AC-5 "đổi loại") | DEFERRED về code (hở tiền tồn REQ-016 STORY-004), nhưng cần quyết định + sửa artifact: A-3. |
| F-1 (Slice 1) | CLOSED — Slice 3 phân giải thành PARTIAL, nội dung còn lại chính là R-1. |
| F-2 (migration `else if` maintainability) | DEFERRED, accepted-as-is. Đúng ở v11; cột notebook kế tiếp thêm dạng `else if (from < 12)` sẽ bỏ qua ba cột v11 cho máy v6-v10. Ghi lại cho lần thêm cột sau, không phải việc của story này. |
| F-3 (`question_id` null) | CLOSED — Slice 3 chứng minh không cadence nào đọc `notebook_entries.question_id`. Không mở lại. |
| F-4 (4 id từ vựng chung không có gate) | CLOSED bởi Slice 4 — hai chip loại đọc pack tại `checkin_capture_block.dart:119,123`. |
| F-5 (gate asymmetry: required-id chỉ enforce trong test) | DEFERRED, accepted-as-is. Bảo vệ tương đương hôm nay vì pack ship trong repo và test đọc từ đĩa; chỉ thành thật nếu pack thôi là asset in-repo. |
| F-6 (`validateContextPacks` required param) | CLOSED bởi Slice 4 — 8 dòng tổng, 0 call site production; thiếu named arg là compile error nên suite xanh đã chứng minh. |
| P3-U1 (thiếu affordance busy nhìn thấy được) | DEFERRED, cosmetic. UX Phần B:107-109 muốn label mờ hoặc spinner; nửa disable đã làm và có test, nửa nhìn-thấy-được thì không. Không rủi ro dữ liệu; gộp vào lần chạm UI kế tiếp của màn check-in. |
| P3-U2 (retry sau partial success) | ACCEPTED-AS-IS. Không chứng minh được ở tầng seam widget theo cấu tạo; phòng tuyến thật là P1-A2 (select-then-update tuần tự). Không đọc test:460 như bằng chứng cho partial-success. |
| O-3 (`story_master.md` `Status: TODO`) | Không phải defect code. Với outcome này, status đúng phải là `IN_PROGRESS`; Scrum Master sở hữu việc cập nhật (rule 17). |
| O-4 (fidelity report dẫn sai AC-5 cho AC-4) | DEFERRED, sửa prose khi thuận tiện. Ảnh đúng là bằng chứng của AC-4/AC-9 như đã khai; không ảnh hưởng verdict fidelity. |
| O-5 (nửa xoá-nhật-ký của AC-11 đạt rỗng) | ACCEPTED-AS-IS, ghi lại. Không có API xoá nhật ký nào trong `mobile/lib` nên không gì phá được mục sổ tay. Tính năng xoá nhật ký tương lai thừa hưởng một lời hứa cross-feature chưa được test. |
| O-1/O-2 của Slice 3 (đường dẫn handoff sai, AC-13 thuộc P4) | CLOSED, đã tự sửa trong slice. AC-13 chốt PASS ở P4-A7. |
| O-2/O-6..O-9 của Slice 4 | Không cần hành động (nit artifact + ghi chú kiểm ảnh bằng mắt). |

## Completion/Resume Closure

Pass hẹp, sau khi A-1/A-2 (mobile-dev) và A-3 (Scrum Master, quyết định user) đã đóng. Không chạy lại
4 slice, không đụng AC-1..AC-17/R-1/F-1..F-6, không đụng `mobile/lib/**`.

- **B-1 (Story Runtime Startup Smoke) — ĐÓNG.** `coding-plan/test-results.md:858-914` là chuỗi build →
  cài đè (giữ data, `uninstall -k` + `install -r`, đúng kịch bản nâng cấp — không phải cài sạch) →
  khởi chạy nguội hai lượt → ảnh màn mở ra nhìn → quét crash log 972 dòng logcat. Đã đối chiếu trực
  tiếp với code: chuỗi callback thông báo → `_openFromPayload` → `EveningCheckInSheet.show` →
  `CheckinCaptureBlock` khớp đúng `evening_check_in_sheet.dart:714, 720-767, 141-156, 369-380` (đọc
  trực tiếp, không phải suy luận từ prose). Ảnh #2 sau khi bắc cầu cổng cho thấy Home thật với đủ 4
  tab, xác nhận DB đã qua migration `schemaVersion` 10 → 11 từ bản cài cũ mà không crash — đúng rủi ro
  mà rule 12g nhắm tới, không phải cài sạch che giấu lỗi migration. Phương pháp quét crash (logcat -c
  trước lượt #1, -d -v brief sau ảnh #2, đối chiếu 4 mẫu FATAL/AndroidRuntime/ANR/E-flutter và quét tên
  gói trong toàn bộ dòng E/W) là thật, không phải liệt kê hình thức. Bảng nhất quán nội tại: pid khác
  nhau giữa hai lượt (`28218` → `28324`, không lượt nào chết giữa), ảnh #1 là lỗi bắc cầu cổng đã biết
  (đúng tiền lệ REQ-016 STORY-012), không phải crash.
- **B-2 (Entry Point Reachability) — ĐÓNG.** `coding-plan/test-results.md:788-856` khai `Reachable: YES`
  cho cả hai bề mặt. Đã đối chiếu trực tiếp với code, không chỉ tin theo prose:
  - Bề mặt 1 (khối hỏi màn check-in 23h): `evening_check_in_sheet.dart:714` (`onSelected`), `:720-767`
    (`_openFromPayload`, `loadCheckInCaptureCopy()` ở dòng 753 — báo cáo ghi 750, lệch 3 dòng, không
    ảnh hưởng chuỗi), `:141-156` (`EveningCheckInSheet.show`), `:369-380` (mount `CheckinCaptureBlock`)
    — cả bốn mắt xích đọc khớp nguyên văn.
  - Bề mặt 2 (nhãn xuất xứ màn Sổ tay): `home_screen.dart:380-389` (tab Sổ tay),
    `context_notebook_entry_point.dart:85-90` (`openNotebookScreen`), `notebook_screen.dart:110-129`
    (`_originLabels`), `:394` (`label = originLabel`), `:421-428` (`Text` với
    `Key('notebook-entry-origin-${entry.id}')`) — tất cả khớp nguyên văn.
  - Không thêm route/điểm vào nào, đúng khai báo `master-plan.md:70-73`. Gap bằng chứng đã bù đúng
    như A-2 yêu cầu.
- **A-3 (AC-5 "đổi loại") — ĐÓNG theo Option B của user.** `coding-plan/test-results.md:916-931` khai
  deviation, giữ `AC-5` ở `PARTIAL` — khớp đúng dòng Traceability trong báo cáo này ("PARTIAL — nửa
  'đổi loại' không đạt, F-7, deferred"), không sửa câu chữ AC-5, không tự ý nâng lên PASS. Section ghi
  rõ quyết định là của user qua Scrum Master (2026-09-28) và một backlog item riêng sẽ mở qua luồng
  ý tưởng/PO chuẩn, ngoài phạm vi story này — không mâu thuẫn với F-7 hay Traceability.
  - Ghi chú không chặn: `phase-P4-notebook-origin-label.md` §4:86 (claim "đổi loại: đạt") mà F-7 nêu
    vẫn chưa được sửa — section deviation mới nằm ở `test-results.md`, không đụng tới claim đó trong
    phase file. Đây là nợ prose thuộc Option A cũ, không phải điều kiện đóng của Option B; không dùng
    để chặn pass này, nhưng nên dọn khi thuận tiện (kế `O-4`).

## Khuyến nghị trạng thái

- `Implementation (Development)`: có thể tick — A-1/A-2 đã bù bằng chứng, A-3 đã đóng theo quyết định
  user.
- `Review (Reviewer)`: `DEFERRED_ONLY` — merge-eligible.
- Story status: `IN_PROGRESS` → có thể chuyển tiếp theo lane kế tiếp của Scrum Master (không phải
  `TODO`, O-3 vẫn đúng như đã ghi).
- Nhánh story merge-eligible vào `codex/REQ-017_checkin_notebook_capture-integration`.
- Carry-forward còn lại (R-1, F-2, F-5, P3-U1, P3-U2, O-4, O-5, ghi chú `phase-P4-notebook-origin-label.md`
  §4:86 ở trên) đều DEFERRED/ACCEPTED-AS-IS, không chặn merge.

REVIEW_COMPLETE
