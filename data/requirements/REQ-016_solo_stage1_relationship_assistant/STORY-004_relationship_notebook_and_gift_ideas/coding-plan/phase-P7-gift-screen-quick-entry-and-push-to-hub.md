# Phase P7 – Màn (5) Gợi ý quà, lối vào quick-entry, và đẩy về hub

## 1. Objective

Màn gợi ý quà tới được từ ô "Gợi ý quà" trên hub, hiển thị ý tưởng không kèm giá
tiền, và mọi ý tưởng đều có đường đẩy ngược về hub thay vì kết thúc tại chỗ.

## 1A. Ownership

- Phase ID: P7
- Canonical Phase File: `phase-P7-gift-screen-quick-entry-and-push-to-hub.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3, P6
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
  - `mobile/lib/features/gift_ideas/presentation/cubit/gift_ideas_cubit.dart`
  - `mobile/lib/features/gift_ideas/presentation/widgets/gift_idea_card.dart`
  - `mobile/lib/features/gift_ideas/gift_ideas_entry_point.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`, `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/gift_ideas/gift_ideas_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `openGiftIdeasScreen` (mặt tiền một chiều của feature quà)
- Shared Interfaces Consumed:
  - `GiftSelector` / `GiftRepository` (P6), `AskOnTheSpotSlot` (P3),
    `createCard(NewActivityCard)` của STORY-001
- Risk Surfaces:
  - Giá tiền rò vào luồng quà
  - Kho thứ hai mọc ra ngoài hub
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` Phần D
  - consumer contract: STORY-001 `architecture/contract-summary.md` — hợp đồng
    `createCard`, `origin: gift_suggestion`, `duration_minutes`, `price_vnd`
- Primary Inputs Summary:
  - requirements: AC-6 (SC-2), AC-13, AC-14, AC-15, AC-20, AC-22, AC-23, AC-24,
    AC-26, AC-30, AC-31
  - architecture: `../architecture/contract-summary.md` §2, §3, §6
  - OQ constraints: R-15b (không giả định kích cỡ gói ở tầng UI)
  - upstream phase outputs: P3 slot hỏi, P6 selector
  - UX constraints: `../ux/uiux-spec.md` Phần D và Phần E
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một màn + lối vào của nó + đường đẩy ra hub
  - Source/Test File Count: 8
  - Split Required: NO
  - Split Rationale: bộ lọc, thẻ quà, và nút đẩy-về-hub là một cụm hành vi trên
    cùng một màn; tách ra sẽ buộc nhiều phase cùng sửa `gift_ideas_screen.dart`.

## 2. Required Reads

- `../ux/uiux-spec.md` Phần D, Phần E
- `../architecture/contract-summary.md` §2, §3, §6
- STORY-001 `architecture/contract-summary.md` — chỉ tra hợp đồng `createCard`
- `../requirements/requirements.md` (AC-13..AC-15, AC-20, AC-22..AC-24, AC-26, AC-30, AC-31)

## 3. Tasks

- Nối `QuickEntryCell.giftIdeas` trên hub với `openGiftIdeasScreen`: chỉ truyền
  callback `onSelected`, **không** đổi hình dạng hay nhãn của dải quick-entry, và
  **không** đổi hành vi hai ô còn lại (chúng vẫn rơi về snackbar "Sắp có").
- Màn (5): bộ lọc nhánh + bộ lọc mức công sức dựng **từ** `gift_taxonomy` (số
  lượng chip = `length`, không hardcode), danh sách thẻ quà, và ở cuối là dòng
  liên kết văn bản nhỏ về khoá vị trí (R-13) — dòng này là chữ, không phải banner
  hay thẻ nổi bật.
- Thẻ quà hiển thị tiêu đề, mô tả, nhãn nhánh, nhãn mức công sức. **Không** ô
  giá, **không** khoảng giá, **không** nhãn rẻ/đắt, **không** nút mua/liên kết
  ngoài (AC-14, AC-15, AC-26).
- Mỗi thẻ có hành động chính đẩy về hub, gọi
  `createCard(NewActivityCard(..., origin: 'gift_suggestion',
  durationMinutes: <giờ công của mức đã chọn, tính theo phút>, priceVnd: null))`.
  `priceVnd` để `null` vĩnh viễn; không thêm cột mới vào `activity_cards`.
- Sau khi đẩy, phản hồi ngắn tại chỗ rồi ở lại màn — không tự động điều hướng đi
  nơi khác, không màn "đã lưu" riêng (SC-2, AC-30).
- Dựng **một** `AskOnTheSpotSlot` giữa bộ lọc và danh sách gợi ý, với
  `entryPointId: 'gift_ideas'`; `onContextChanged` chạy lại selector tại chỗ.
- Không nút "lưu ý tưởng này", không danh sách yêu thích, không tab thứ hai —
  hub là nơi duy nhất giữ thứ người dùng chọn (AC-22, AC-23).

## 4. Acceptance Criteria

- Ô "Gợi ý quà" trên hub mở màn (5) trong ứng dụng đang chạy; hai ô còn lại giữ
  nguyên hành vi cũ (AC-13).
- Không widget nào trên màn hiển thị ký hiệu tiền tệ, khoảng giá, nhãn rẻ/đắt,
  hay liên kết mua hàng (AC-14, AC-15, AC-26).
- Mọi thẻ quà đều có hành động đẩy về hub; không thẻ nào là ngõ cụt (SC-2, AC-6,
  AC-30).
- Thẻ tạo ra có `origin = gift_suggestion` và `price_vnd = null` (AC-24).
- Số chip bộ lọc bằng số mục tương ứng trong `gift_taxonomy`; đổi gói làm số chip
  đổi theo mà không sửa Dart (AC-34, R-15b).
- Đúng một thẻ hỏi tại chỗ trên màn, và nó có thể vắng mặt hoàn toàn (AC-2, AC-31).
- Không nút lưu/yêu thích/chia sẻ ý tưởng ở bất kỳ đâu trên màn (AC-22, AC-23).
- Dòng khoá vị trí là liên kết văn bản nhỏ ở cuối màn, không phải banner (AC-20).

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`
- Contracts or schemas: không đổi schema; dùng hợp đồng `createCard` của STORY-001
- Notes or evidence: `test-results.md`, ảnh chụp visual-fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, widget + điều hướng
- Required levels:
  - unit: ánh xạ mức công sức → phút; trạng thái Cubit khi đổi bộ lọc
  - integration: widget test màn (5) với repository thật in-memory, gồm luồng
    đẩy-về-hub kiểm tra thẻ được tạo đúng trường
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: có (xem dòng visual-fidelity dưới)
- Required checks: test khẳng định **vắng mặt** ký hiệu tiền tệ và nút lưu/chia
  sẻ trong cây widget đã render
- Mobile discoverability / navigation integration: widget test khẳng định chạm ô
  "Gợi ý quà" trên hub đẩy đúng màn (5), và hai ô còn lại vẫn ra snackbar cũ
- Minimum gates by risk surface: test vắng-mặt-tiền-tệ (thiếu → `PRICE_LEAK`);
  test đẩy-về-hub trên mọi thẻ (thiếu → `SECOND_HUB`)
- Required regression or contract coverage: test hiện có của
  `test/features/activity_cards/` giữ nguyên xanh, gồm cả test dải quick-entry
- Evidence format: lệnh + kết quả trong `test-results.md`; ảnh chụp trong
  `visual-fidelity/`
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: màn gợi ý quà trên design canvas Cupid
    Chặng 1. Người cài đặt tự phân giải và ghi lại `Design-Screen: <id>` **sau
    khi render** theo `contracts/design-fidelity-spec.md` "Design source
    detection and locking"; đừng đoán id từ tài liệu này.
  - How the implemented screen is captured: `capture-mobile-screen.sh` cho bản
    dựng, điều hướng hub → ô "Gợi ý quà"; nếu lần chụp không tới được màn, chụp
    bằng `RepaintBoundary` trong chính widget test của story thay vì hoãn.
  - NOTE: đây là gate riêng của story, kiểm ở review của story này; không bao giờ
    được thoả mãn bởi, hay hoãn sang, audit cấp requirement. Nếu không tới được
    thiết bị/runtime nào, phase chặn với `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/gift_ideas test/features/activity_cards`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: log test đẩy-về-hub với trường thẻ đã khẳng
    định, log test vắng-mặt-tiền-tệ, và ảnh chụp cặp design/bản dựng

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-10
