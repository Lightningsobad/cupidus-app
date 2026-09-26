# Phase P6 – Bộ seed 256 ô MBTI

## 1. Phase Metadata

- Phase Id: P6
- Owner: Mobile Developer
- Lane: Mobile
- Depends On: P1
- Parallelizable: YES (chạy song song P3, P4, P5)
- Status: DONE
- Runtime Registry Id: `mobile-app`
- Build Command Source: runtime registry `mobile-app.buildCommand`
- Startup Smoke: NOT_APPLICABLE

## 2. Goal

Mở trục MBTI từ bộ tối thiểu của P1 lên đủ 16 giá trị và soạn đủ 256 ô có hướng,
mỗi ô đủ bộ bốn, tất cả qua cổng nhập của P1 mà không nới luật nào.

P6 tách khỏi P5 vì hai phase ghi hai file asset khác nhau, không chạm dữ liệu
của nhau, và mỗi phase đã là một khối lượng soạn thảo đủ lớn cho một vòng đời
chuyên gia. Chúng chạy song song được.

## 3. Primary Inputs

- P1: `mobile/lib/features/compatibility_lookup/domain/compat_content_gate.dart`
- `mobile/assets/data/req016/compat_bands.v1.json`
- `../requirements/requirements.md` — AC-32, AC-34, AC-35, AC-37, AC-38
- `mobile/lib/core/content/invariant_terms.dart`
- `../coding-plan/coding-agent-guide.md` section 4

## 4. Write Scope

- `mobile/assets/data/req016/compat_mbti.v1.json`
- `mobile/test/features/compatibility_lookup/compat_mbti_seed_test.dart`

Nếu bộ 256 ô cần một DẢI chưa có trong từ vựng, **đừng tự thêm vào
`compat_bands.v1.json`**: P5 cũng có thể đang sửa đúng file đó. Báo về Scrum
Master để xếp thứ tự. Đây là điểm chạm duy nhất giữa P5 và P6.

## 5. Planned Outputs

- 16 item `kind: axis_value` và 256 item `kind: cell`.
- Test ghim con số 16 và 256, đặt trong `mobile/test/`.
- Ghi vết đã chuẩn bị cho kiểm duyệt lớp 2.

## 6. Implementation Steps

1. Mở trục lên 16 loại, giữ nguyên id P1 đã đặt (dạng chữ thường bốn ký tự:
   `intj`, `enfp`, …).
2. Soạn 256 ô có hướng. `intj__enfp` khác `enfp__intj`; 16 ô tự-soi phải viết
   nghiêm túc.
3. Rủi ro riêng của MBTI, khác với hoàng đạo: từ vựng MBTI vốn đã mang giọng
   **phân loại tính cách và xếp hạng năng lực**. Nội dung phải nói về *cách hai
   người gặp nhau*, không phải *người kia là loại gì*. Tránh mọi câu ngụ ý một
   loại giỏi hơn loại khác — đó chính là thang đo trá hình mà AC-32 cấm, chỉ
   khác là bằng chữ thay vì bằng số, nên cổng nhập **không** bắt được và trách
   nhiệm nằm ở người soạn.
4. Áp bốn luật của `../coding-plan/coding-agent-guide.md` section 4 và các yêu
   cầu về `friction` / `question` / `activity` như P5 section 6 bước 3.
5. Chạy cổng nhập P1 sau mỗi đợt (mỗi 16 ô), đừng dồn 256 ô.
6. Viết test seed ghim: đúng 16 `axis_value`, đúng 256 `cell`, mọi cặp có hướng
   có mặt đúng một lần (AC-38).
7. Ghi vết sẵn sàng kiểm duyệt lớp 2; phase không tự phê duyệt.

## 7. Test Scope

- `mobile/test/features/compatibility_lookup/compat_mbti_seed_test.dart`
- Chạy lại `mobile/test/features/compatibility_lookup/compat_content_gate_test.dart`
  của P1 với dữ liệu đầy đủ.

Ngoài phạm vi: e2e, chạy trên thiết bị, script gate ở gốc repo, runtime startup
smoke.

## 8. Build Gate

`flutter build apk --debug` (nguồn: runtime registry `mobile-app.buildCommand`).
Không nối ống.

## 9. Runtime Startup Gate

NOT_APPLICABLE.

## 10. Completion Criteria

- 16 giá trị trục, 256 ô, đủ mọi cặp có hướng.
- Cổng nhập P1 xanh không sửa luật nào.
- Test ghim 16/256 xanh, con số chỉ nằm trong `mobile/test/`.
- Build gate xanh.

## 11. Stop Rule

Dừng với `DATA_GATE_BLOCKED` nếu nội dung hợp lệ bị luật bắn nhầm, hoặc nếu bộ
256 ô cần một DẢI mới mà P5 đang sửa cùng file từ vựng. Báo rõ trường hợp nào
trong hai; cách xử lý khác hẳn nhau.
