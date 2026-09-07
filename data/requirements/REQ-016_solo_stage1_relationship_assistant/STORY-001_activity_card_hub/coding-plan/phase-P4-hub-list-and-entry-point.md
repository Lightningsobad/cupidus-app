# Phase P4 – Màn kho thẻ, segmented filter, và điểm vào

## 1. Objective

Dựng màn kho thẻ ở nhánh solo của tab "Nhà" và làm nó **tới được**: segmented
filter 4 ngăn, danh sách thẻ rút gọn với đúng một hành động chính mỗi thẻ.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-hub-list-and-entry-point.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/activity_cards/presentation/activity_card_list_cubit.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
  - `mobile/lib/features/activity_cards/presentation/widgets/activity_status_filter.dart`
  - `mobile/lib/features/activity_cards/presentation/widgets/activity_card_tile.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/test/features/activity_cards/activity_card_hub_view_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - Bố cục nhánh solo của tab "Nhà" mà STORY-012 gắn header đếm vào sau
- Shared Interfaces Consumed:
  - `primaryActionFor`, repository thẻ từ P2
- Risk Surfaces:
  - Điểm vào không tới được
  - SC-4/SC-5 — đúng một hành động chính, không ngõ cụt
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §1, §2, §3, §4b
  - consumer contract: STORY-012 (header), STORY-004/005/011 (dải 3 ô ở P5)
- Primary Inputs Summary:
  - requirements: AC-10, AC-11, AC-13, AC-22, BR-2, BR-3, BR-10
  - architecture: `../architecture/solution.md` §3 UI Delivery Anchor, §5
  - upstream phase outputs: P2
  - UX constraints: `../ux/uiux-spec.md` §1, §2, §3, §4b
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — bề mặt danh sách + wiring điểm vào.
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §1, §2, §3, §4b
- `../architecture/solution.md` §3, §4, §5
- `../requirements/requirements.md` Nhóm C, Nhóm E

## 3. Tasks

- `ActivityCardListCubit`: giữ ngăn đang chọn, phân trang danh sách từ DAO theo
  `(owner_key, status)`, và số đếm mỗi ngăn. Không nạp toàn bộ kho vào state.
- Segmented control cố định 4 ô, sticky khi cuộn, 4 nhãn đầy đủ không rút gọn,
  cuộn ngang khi hẹp, ô chạm tối thiểu 44pt/48dp, số đếm nhỏ cạnh nhãn (không
  badge đỏ).
- `ActivityCardTile`: tiêu đề 2 dòng ellipsis; dòng 2 tuỳ chọn; giá chỉ hiện khi
  `> 0`; footer đúng **một** nút hành động chính lấy nhãn từ `primaryActionFor`.
- Chip "đã rủ": chỉ hiện khi thẻ ở `scheduled` và `invited == true`; hai giá trị
  "Chưa trả lời"/"Đã trả lời", đổi khi người dùng bấm. Không nhãn thời gian.
- Nhánh solo của `home_screen.dart` (`isPaired == false`) render dải lối-vào-
  nhanh (khung rỗng do P5 điền), filter, và danh sách. Không route mới, không
  tab mới, không đụng nhánh đã-ghép-đôi.
- Ngăn rỗng khi kho đã có thẻ: một dòng trung tính + liên kết văn bản về ngăn
  "Mới nghĩ ra" (UX §4b). Không lặp hai lời mời Phút-1.

## 4. Acceptance Criteria

- Với `isPaired == false`, tab "Nhà" render kho thẻ (AC-22, điểm vào).
- Đúng 4 ngăn; mỗi ngăn chỉ liệt kê thẻ đúng trạng thái (AC-10).
- Mỗi thẻ có đúng một nút hành động chính, nhãn khớp bảng SC-4 (AC-11).
- Mọi ngăn có ít nhất một đường đi tiếp hoặc đường xoá, kể cả *Đã thành kỷ niệm* (AC-13).
- Không hiển thị streak, chuỗi ngày, huy hiệu, hay chỉ báo hành vi người kia (AC-18, AC-20).

## 5. Planned Outputs

- Code: cubit, màn hub, filter, tile, nhánh solo của home.
- Notes: bằng chứng test và ảnh chụp màn ghi vào `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng presentation
- Required levels:
  - unit: cubit đổi ngăn, phân trang, số đếm
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: ảnh chụp màn kho thẻ ở ngăn có dữ liệu
- Required checks:
  - Widget test 4 trạng thái: đúng 1 nút hành động chính và nhãn khớp bảng SC-4.
  - Widget test: chip "đã rủ" chỉ có 2 giá trị và không kèm nhãn thời gian.
  - Widget test: không widget nào hiển thị streak/huy hiệu/chỉ số người kia.
- Mobile discoverability / navigation integration: widget test dựng `home_screen`
  với `isPaired == false` và khẳng định kho thẻ hiện ra — đây là gate điểm vào.
- Minimum gates by risk surface: hai risk surface ở §1B đều có gate ở trên.
- Evidence format: output `flutter test` + ảnh chụp màn, ghi vào `coding-plan/test-results.md`.
- Per-story visual fidelity: REQUIRED
  - Design screen id + cách render: implementer tự phát hiện và khoá id theo
    `contracts/design-fidelity-spec.md` "Design source detection and locking",
    render bằng `capture-mobile-screen.sh --mode=design`.
  - Cách chụp màn đã hiện thực: `capture-mobile-screen.sh`.
  - NOTE: đây là gate của chính story này, không được hoãn sang audit cấp
    requirement. Nếu không tới được runtime thì block bằng `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: `flutter test test/features/activity_cards/ test/features/home/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + kết quả pass, kèm ảnh chụp so sánh.

## 7. Status

- Status: COMPLETE
- Last updated: 2026-09-07
- Evidence: `coding-plan/test-results.md` § "Phase P4",
  `visual-fidelity/visual-fidelity-report.md`
- Open for product decision: `VISUAL_FIDELITY: FAIL` vì design canvas mâu thuẫn
  với UX §3 / AC-10 (ô filter "Tất cả"), SC-4 / AC-11 (nút tràn trên thẻ hero),
  và AC-22 / UX §1 (thanh tab riêng của Chặng 1). Không phải lỗi hiện thực.
