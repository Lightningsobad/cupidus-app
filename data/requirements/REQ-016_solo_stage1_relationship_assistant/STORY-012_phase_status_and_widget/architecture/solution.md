# STORY-012_phase_status_and_widget-solution.md

## 0. Metadata

- Complexity: complex
- Date: 2026-09-11

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC-4 (nguồn dữ liệu đóng), AC-34/BR-13 (tất định, không
  AI, không API ngoài), AC-37/BR-15 (nội dung là dữ liệu, cấm chuỗi trong mã
  widget), BR-5/BR-6/BR-7 (bộ đếm là lực lượng tập, không phải hàm thời gian),
  AC-30 (tắt thông báo không làm hỏng gì), BR-2 (suy giảm êm là hành vi đúng).
- Architectural invariants / non-goals: không thêm cột/trường thẻ, không đổi
  hợp đồng `ActivityCardRepository`, không bump `schemaVersion`, không tiến
  trình nền, không lời gọi mạng, không chuỗi nội dung trong mã native.
- Proposed technical direction: **một lane mobile duy nhất**. Một module
  `mobile/lib/features/phase_status/` chứa một resolver pha thuần hàm, một
  nguồn nội dung preset dùng `ContentPackage` sẵn có, một bộ lịch thông báo
  **cục bộ**, và một cầu Dart → native đẩy payload preset đã dựng sang
  WidgetKit/AppWidgetProvider. Không có mã backend nào.
- Why this fits: STORY-001 đã chốt kho thẻ là Drift cục bộ, và `core/content/`
  đã có sẵn `ContentPackage` + `invariant_terms.dart` — story này lắp vào hai
  khớp đó chứ không dựng hạ tầng mới, trừ hai năng lực nền tảng mới (thông báo
  cục bộ, widget hệ điều hành).

### Key Discovery

Handoff ghi `Implementation Lane: shared (backend + mobile)`. **Không có lane
backend trong story này**, và ba nguồn độc lập đều nói cùng một điều:

1. `../../STORY-001_activity_card_hub/architecture/contract-summary.md` §1 —
   hợp đồng thẻ "không có endpoint, không có payload mạng, **không có backend
   counterpart**". Mọi dữ liệu pha và bộ đếm suy từ Drift cục bộ.
2. AC-34/BR-13 cấm mọi lời gọi API ngoài trên đường sinh nội dung.
3. `data/architecture/system/system_architecture_memory.md` §8 (R9) —
   **không có** server-side FCM send và **không có** kho device-token ở bất kỳ
   đâu; cả ba điểm gửi push đều là `console.log` stub. Một nhắc 23h dựa vào
   push backend sẽ **không bao giờ nổ**.

Hệ quả thiết kế, không phải ghi chú: nhắc 23h (AC-16) **bắt buộc** là thông báo
**lên lịch cục bộ trên máy**. Điều này lại làm AC-30 và AC-17 dễ hơn chứ không
khó hơn — tắt thông báo hệ điều hành là chặn tại nguồn, và "bỏ qua thì thôi
hẳn" chỉ là một lịch một-lần không lặp.

Phát hiện thứ hai: `ux/uiux-spec.md` §6 viết ngưỡng cột mốc J12 là "**do backend
định nghĩa**". Theo (1)+(3) thì không có backend để định nghĩa nó. Quyết định:
ngưỡng nằm trong gói dữ liệu `nudges.v1.json` khoá `thresholds`
(`contract-summary.md` §4). Đây là cách đọc **chặt hơn** R-15a chứ không nới
spec, và giữ AC-28 chạy được offline.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (ranh giới Dart ↔
  native + lược đồ ba gói nội dung).

## 3. Scope And Assumptions

- In Scope: module `phase_status` (resolver pha, nguồn nội dung, chính sách nhỏ
  giọt, bộ đếm), ba gói asset nội dung + cổng nhập, lịch thông báo cục bộ, hai
  hàng toggle cài đặt, extension WidgetKit (iOS) + AppWidgetProvider (Android),
  dòng trạng thái/đếm ngược/bộ đếm trên màn (1) và chi tiết thẻ.
- Out Of Scope: mọi mã backend; mọi thay đổi trong
  `features/activity_cards/domain/`; mọi cột Drift mới; mọi tiến trình nền.
- Assumptions affecting design:
  - **A-1.** "Gói xoay vòng 10 mục" (BR-16) là gói **biến thể nội dung pha** —
    pha luôn cần một nhãn nên nó xoay vòng vô hạn. Gói **nhỏ giọt** thì tiêu-thụ-
    một-lần rồi im lặng (AC-38/AC-21). Hai gói, hai luật; đây là cách đọc duy
    nhất thoả đồng thời BR-16 và AC-38.
  - **A-2.** STORY-006 đã merge vào nhánh integration, nên `BeforeYouGoPhase`
    có thật. Resolver vẫn nhận `BeforeYouGoPhase?` và **phải** có test nhánh
    `null` (AC-2), vì AC-3 cấm story này trở thành phụ thuộc ngược.
  - **A-3.** `flutter_local_notifications` 22.3.0 yêu cầu Flutter SDK ≥ 3.38.1
    và `compileSdk` ≥ 35. Lane mobile **phải xác minh** `flutter --version` và
    `compileSdk` hiện tại trước khi ghim phiên bản; nếu thấp hơn thì ghim bản
    22.x/21.x cao nhất tương thích chứ không nâng SDK trong story này.

### UI Delivery Anchor

- Design Scope Description: trạng thái bổ sung của màn (1) — cụ thể là
  `ActivityCardHubView` (tab `muonLam` của `_SoloStageOneShell` trong
  `mobile/lib/features/home/presentation/home_screen.dart`): một dòng bộ đếm
  tĩnh dưới tiêu đề và trên dải lối-vào-nhanh, một dòng trạng thái pha gắn trên
  thẻ gần nhất, và khối "Món quà đang lớn" chỉ ở pha `quiet`. Cộng dòng đếm
  ngược trong `activity_card_tile.dart` + `activity_card_detail_screen.dart`, và
  một bề mặt widget hệ điều hành 1 khối. Không có màn hình mới.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/phase_status/` (Dart) cộng hai
  thư mục native mới được đặt tên ở `contract-summary.md` §2.
- New or changed boundaries: **một** ranh giới mới, Dart → native qua kho
  khoá-giá trị `home_widget`. Native là **bề mặt vẽ câm**: không logic ngày,
  không chọn nội dung, không chuỗi.
- Shared patterns reused or introduced: tái dùng `ContentPackage` +
  `ContentPackageLoader` (`core/content/content_package.dart`), tái dùng
  `invariantHitsIn` (`core/content/invariant_terms.dart`) cho cổng nhập, tái
  dùng khuôn `SharedPreferences` khoá-theo-thẻ của
  `before_you_go_dismissal_store.dart`, tái dùng khuôn chính sách nhịp của
  `features/context_notebook/domain/ask_cadence_policy.dart`. Mới: hai package
  nền tảng `flutter_local_notifications` + `timezone`, và `home_widget`.

### Affected Modules

- Mobile: `features/phase_status/` (mới), `features/home/presentation/` và
  `features/activity_cards/presentation/` (chỉ lắp widget vào, không sửa
  `domain/`), `features/account/presentation/screens/me_screen.dart`,
  `assets/data/req016/`, `mobile/ios/`, `mobile/android/app/src/main/`.

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract:
  - **Rỗng là đúng, không phải lỗi.** Không thẻ → pha `quiet`; không ý tưởng
    quà → khối không hiện (AC-21); kho nhỏ giọt cạn → im lặng (AC-38). Không
    trạng thái lỗi nào được vẽ ở ba chỗ này.
  - **Lên lịch thông báo là best-effort.** `zonedSchedule` ném
    `PlatformException` (quyền bị thu hồi, Android 14 special-access) thì nuốt
    và bỏ qua — **không** UI lỗi, **không** retry, **không** chặn tính năng nào
    (AC-30, BR-2).
  - **Một lần là một lần.** Mỗi thẻ có đúng một lịch 23h. Đã bắn hoặc đã bỏ qua
    thì ghi `reminded_on` và **không bao giờ** đặt lại cho buổi hẹn đó (AC-17,
    BR-10). Đổi `scheduled_on` thì huỷ lịch cũ trước khi đặt lịch mới.
  - **Gói nội dung hỏng là lỗi to tiếng lúc nạp**, không suy biến thành gói
    rỗng — `ContentPackageFormatException` đã định sẵn hành vi này.
- Compatibility or versioning posture: tập khoá native append-only
  (`contract-summary.md` §5). `schemaVersion` không đổi.
- External or trust-boundary implications: widget là **bề mặt công cộng đọc
  được trên màn khoá**. Ranh giới tin cậy nằm ở chỗ dựng payload phía Dart —
  đó là nơi duy nhất chặn được văn bản người dùng lọt ra widget, nên nó phải là
  **một** hàm dựng payload duy nhất, có test, không phải nhiều chỗ gọi
  `saveWidgetData` rải rác.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| `WIDGET-LEAK` — văn bản người dùng lọt lên widget | AC-11/AC-12/BR-11 | đúng một hàm `buildWidgetPayload` dựng payload; mọi trường là preset đã dựng hoặc số app tính | unit test đưa thẻ có `title`/`note`/`note_keywords` là chuỗi mồi và khẳng định không chuỗi nào xuất hiện trong payload | `ARCH_BLOCKER: WIDGET_LEAK_UNVERIFIED` |
| `CONTENT-GATE` — nội dung vi phạm luật bất biến lọt qua | AC-39/BR-17 | `phase_status/domain/phase_content_gate.dart` dùng lại `invariantHitsIn`, **không** sao chép danh sách từ | test nạp ba asset thật + fixture vi phạm, khẳng định gate từ chối và test đỏ | `ARCH_BLOCKER: CONTENT_GATE_UNVERIFIED` |
| `HARDCODED-COPY` — chuỗi nội dung trong mã native | AC-37/BR-15 | native chỉ vẽ `primary_line`/`secondary_line`; trạng thái chưa-có-payload là khung không chữ | test quét `mobile/ios/CupidPhaseWidget/` + `res/layout/` + provider Kotlin, khẳng định không có literal chữ hiển thị nào | `ARCH_BLOCKER: NATIVE_COPY_SCAN_MISSING` |
| `COUNTER-STREAK` — bộ đếm trượt thành streak trá hình | BR-5/BR-6/AC-25/AC-26 | bộ đếm là `countsByStatus()[memory]` thuần; chữ ký hàm **không nhận** tham số thời gian nào | unit test: cùng tập thẻ + hai `DateTime.now()` cách nhau 60 ngày → cùng giá trị, không sinh nội dung nào | `ARCH_BLOCKER: COUNTER_PURITY_UNVERIFIED` |
| `DRIP-CADENCE` — nhỏ giọt vượt trần BR-9 | AC-22/BR-9/AC-38 | chính sách cầm `last_shown_on`; kho cạn → im lặng, **không** nới trần | unit test mô phỏng 8 tuần với kho 1 mục và kho rỗng; khẳng định ≤1 lần/tuần và im lặng sau khi cạn | `ARCH_BLOCKER: DRIP_CADENCE_UNVERIFIED` |
| `REMIND-REPEAT` — nhắc 23h lặp hoặc bắn lại | AC-16/AC-17/BR-10 | `reminded_on` theo thẻ trong `SharedPreferences`; huỷ trước khi đặt lại | unit test với lịch giả: hai lần chạy vòng lên lịch cho cùng thẻ → đúng một lịch | `ARCH_BLOCKER: REMINDER_ONESHOT_UNVERIFIED` |
| `IOS-WIDGET-TARGET` — extension WidgetKit đòi sửa `project.pbxproj` | `contract-summary.md` §2 | một target duy nhất, một App Group duy nhất (không có `applicationIdSuffix` nên không nhân theo flavor) | `flutter build ios --config-only` (hoặc build `local`) thành công sau khi thêm target, và extension xuất hiện trong `Runner.xcodeproj` | `ARCH_BLOCKER: IOS_WIDGET_TARGET_FAILED` |
| `WIDGET-STALE` — payload cũ tới lần mở app gần nhất | AC-9/AC-10 | chấp nhận có chủ đích: làm mới khi app resume, khi thẻ đổi, và khi chạm thông báo 23h. **Không** thêm tiến trình nền | widget test khẳng định vòng làm mới chạy trên `AppLifecycleState.resumed` và sau mỗi mutation thẻ | `ARCH_BLOCKER: WIDGET_REFRESH_UNVERIFIED` |
| `VISUAL-FIDELITY` — hai bề mặt UI mới trên màn (1) | `ux/uiux-spec.md` §1/§5/§6 | dòng bộ đếm, dòng trạng thái pha, và khối "món quà đang lớn" bám token có sẵn | ảnh chụp per-story cho `ActivityCardHubView` ở cả bốn pha (dùng `RepaintBoundary` trong widget test của chính story nếu màn không tới được) | `ARCH_BLOCKER: VISUAL_CAPTURE_UNAVAILABLE` |

### Lane Handoff

#### Mobile Lane

- Responsibilities: toàn bộ story — Dart, asset nội dung, cổng nhập, mã native
  iOS/Android, và cấu hình manifest/entitlements đi kèm.
- Authoritative inputs: `architecture/contract-summary.md`;
  `../../STORY-001_activity_card_hub/architecture/contract-summary.md` §2/§3 cho
  định danh và trường thẻ; `mobile/lib/features/before_you_go/domain/
  before_you_go_resolver.dart` cho `BeforeYouGoPhase`; `ux/uiux-spec.md` §1-§7.
- Guardrails:
  - **Không sửa** `features/activity_cards/domain/`. Bộ đếm dùng
    `countsByStatus()` đang có, đọc lại khi màn (1) mount/resume — **không**
    thêm `watchCountsByStatus` vào interface (BR-12/AC-4). AC-24 chỉ yêu cầu
    đúng giá trị "khi họ mở màn (1)".
  - **Không** thêm cột Drift, **không** bump `schemaVersion`. Mọi trạng thái
    riêng của story (`reminded_on`, cờ toggle, con trỏ nhỏ giọt) nằm trong
    `SharedPreferences`.
  - **Một** resolver pha duy nhất phục vụ cả dòng trên màn (1) lẫn payload
    widget. Hai chỗ suy pha độc lập là lỗi thiết kế: chúng sẽ lệch nhau.
    "Thẻ gần nhất" phải là quy tắc tất định viết thành hàm — ưu tiên thẻ
    `scheduled` có `scheduled_on` gần nhất từ hôm nay trở đi, rồi thẻ
    `invited && not_answered` có `updated_at` mới nhất, còn lại là `quiet`.
  - `AndroidScheduleMode.inexactAllowWhileIdle` là **bắt buộc**. Không khai
    `SCHEDULE_EXACT_ALARM`, không dùng `exactAllowWhileIdle`: D-1 nói rõ đây
    không phải báo thức, và từ Android 14 quyền exact không xin được qua
    manifest nữa.
  - `POST_NOTIFICATIONS` (Android 13+) xin **không chặn**; bị từ chối thì mọi
    thứ còn lại vẫn chạy (AC-30). Dùng `permission_handler` đã có sẵn.
  - **Không** sao chép `invariantDeniedTerms` sang module này — chú thích thư
    viện trong `invariant_terms.dart` cấm bản sao thứ hai một cách tường minh.
  - Không thêm `workmanager` hay bất kỳ cơ chế chạy nền nào.
  - Cài đặt: thêm đúng hai hàng toggle vào màn cài đặt thông báo sẵn có trong
    `mobile/lib/features/account/presentation/screens/me_screen.dart`, tái dùng
    component hàng toggle đang có; không tạo màn cài đặt mới (`ux/uiux-spec.md`
    §7).

## 5. Non-Functional Impact

- Ba package mới (`home_widget`, `flutter_local_notifications`, `timezone`) là
  thay đổi phụ thuộc cấp package — cần lock `package-dependencies` nếu story
  này chạy song song với story khác chạm `pubspec.yaml`.
- Widget đọc được trên màn khoá là bề mặt lộ dữ liệu **mới** của sản phẩm; rủi
  ro `WIDGET-LEAK` ở §4 là hàng rào bảo mật/riêng tư, không phải hàng rào UI.
- Extension WidgetKit thêm một target vào `Runner.xcodeproj`; mọi tài liệu cấu
  hình bản dựng iOS trong `deployment/configuration-guide.md` cần một mục cho
  App Group và target mới.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Dart dựng chuỗi hiển thị rồi đẩy chuỗi đã xong sang native | Cách duy nhất giữ mã native **không** chứa chuỗi nội dung nào | ACCEPTED | Thoả AC-37/BR-15 tuyệt đối; đổi sang CMS ngoài repo chỉ đổi asset |
| Native giữ bảng chuỗi và chọn theo `phase_id` | Ít dữ liệu qua ranh giới hơn, widget tự lo bản địa hoá | REJECTED | Đặt chuỗi nội dung đúng vào mã widget — vi phạm trực tiếp AC-37, chỗ BR-15 nói là "cắn mạnh nhất" |
