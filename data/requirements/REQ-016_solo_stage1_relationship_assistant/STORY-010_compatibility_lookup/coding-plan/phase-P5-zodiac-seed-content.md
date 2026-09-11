# Phase P5 – Bộ seed 144 ô hoàng đạo

## 1. Phase Metadata

- Phase Id: P5
- Owner: Mobile Developer
- Lane: Mobile
- Depends On: P1
- Parallelizable: YES (chạy song song P3, P4, P6)
- Status: NOT_STARTED
- Runtime Registry Id: `mobile-app`
- Build Command Source: runtime registry `mobile-app.buildCommand`
- Startup Smoke: NOT_APPLICABLE

## 2. Goal

Mở trục hoàng đạo từ bộ tối thiểu của P1 lên đủ 12 giá trị và soạn đủ 144 ô có
hướng, mỗi ô đủ bộ bốn `fit` / `friction` / `activity` / `question`, tất cả qua
được cổng nhập của P1 mà **không** nới bất kỳ luật nào.

Phase này tách khỏi P1 vì **khối lượng nội dung**, không vì ranh giới file. Đây
là phase soạn văn bản tiếng Việt, không phải phase lập trình.

## 3. Primary Inputs

- P1: `mobile/lib/features/compatibility_lookup/domain/compat_content_gate.dart`
  — tập luật phải thoả
- `mobile/assets/data/req016/compat_bands.v1.json` — từ vựng DẢI đóng
- `../requirements/requirements.md` — AC-32, AC-34, AC-35, AC-37, AC-38
- `mobile/lib/core/content/invariant_terms.dart` — từ ngữ bị cấm
- `../coding-plan/coding-agent-guide.md` section 4

## 4. Write Scope

- `mobile/assets/data/req016/compat_zodiac.v1.json`
- `mobile/test/features/compatibility_lookup/compat_zodiac_seed_test.dart`
- `mobile/assets/data/req016/compat_bands.v1.json` (sửa, **chỉ khi** bộ 144 ô
  cần một DẢI chưa có trong từ vựng)

## 5. Planned Outputs

- 12 item `kind: axis_value` và 144 item `kind: cell`.
- Test ghim con số 12 và 144 — nằm trong `mobile/test/`, **không bao giờ** trong
  `mobile/lib/`.
- Ghi vết đã chuẩn bị cho kiểm duyệt lớp 2.

## 6. Implementation Steps

1. Mở trục lên 12 giá trị, giữ nguyên id của các giá trị P1 đã đặt. Đổi id cũ
   sẽ làm hỏng ô cũ và mọi tham chiếu.
2. Soạn 144 ô. Cặp **có hướng**: ô `aries__pisces` nói về việc *là Bạch Dương
   nhìn sang Song Ngư*, khác ô `pisces__aries`. Hai ô này phải khác nội dung
   thật sự, không phải đảo chủ ngữ của cùng một câu. 12 ô tự-soi (`aries__aries`
   …) cũng phải viết nghiêm túc, không bỏ qua.
3. Viết nội dung theo bốn luật của
   `../coding-plan/coding-agent-guide.md` section 4. Cụ thể cho phase này:
   - `friction` **không được** là lời khen trá hình ("hơi quá chu đáo"). Phải là
     một điểm va thật, nói được, không quy lỗi.
   - `question` là câu hỏi mở gửi cho **chính người dùng**, kết thúc bằng `?`,
     không phải câu dò hành vi của đối phương.
   - `activity` là việc làm được trong một buổi, cụ thể.
   - Không câu nào chỉ dẫn người dùng **theo dõi, đếm, hay đánh giá** hành vi
     đối phương — `recipientBehaviour` và `frequencyProbe` sẽ bắt, và đó là ranh
     giới đạo đức của sản phẩm chứ không phải hình thức.
4. Không viết 144 ô bằng cách sinh máy móc từ khuôn mẫu. Cổng nhập không bắt
   được nội dung rập khuôn, nhưng kiểm duyệt lớp 2 sẽ bắt, và người dùng còn
   bắt nhanh hơn.
5. Chạy cổng nhập của P1 sau **mỗi** đợt soạn (ví dụ mỗi hệ 12 ô), đừng để dồn
   144 ô rồi mới chạy lần đầu.
6. Viết test seed ghim: đúng 12 `axis_value`, đúng 144 `cell`, mọi cặp có hướng
   đều có mặt đúng một lần (AC-38).
7. Ghi vết đã sẵn sàng cho kiểm duyệt lớp 2 trong ghi chú bàn giao. Bộ seed chưa
   duyệt lớp 2 chỉ dùng cho bản dựng nội bộ (AC-35/D-15). Phase này **không**
   tự phê duyệt nội dung của chính nó.

## 7. Test Scope

- `mobile/test/features/compatibility_lookup/compat_zodiac_seed_test.dart`
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

- 12 giá trị trục, 144 ô, đủ mọi cặp có hướng.
- Cổng nhập P1 xanh **không sửa một luật nào**.
- Test ghim 12/144 xanh, và con số chỉ nằm trong `mobile/test/`.
- Build gate xanh.

## 11. Stop Rule

Dừng với `DATA_GATE_BLOCKED` nếu nội dung hợp lệ liên tục bị một luật bắn nhầm.
Báo đúng ô, đúng luật, đúng từ. **Không** nới luật, **không** viết vòng vo để né
từ cấm trong khi vẫn giữ nguyên ý bị cấm — đó là né cổng, không phải qua cổng.
