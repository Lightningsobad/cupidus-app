# Idea Master: IDEA-20260729-001 Cupid Flutter Mobile Architecture
Lifecycle: ACTIVE
Development Status: EXPANDED
Source: user
Created: 2026-07-29
Last Updated: 2026-07-29
Linked Requirement: REQ-001

## Seed

Original idea:

Ứng dụng Cupid đã brainstorm sơ khai tại `_bmad-output/`, API đã thiết kế và hiện
thực tại `backend/` (docs tại `docs/backend/`). Quyết định trước đây là **mobile
app iOS Native (Swift/SwiftUI)** — nay **đổi sang Flutter**. Cần brainstorm tiếp
về **kiến trúc Flutter** sẽ sử dụng. UI đã thiết kế xong và lưu tại
`cupid-mobile-design/`, cần bổ sung vào đặc tả của idea.

## Current Business Framing

- Problem: Quyết định client cũ (iOS Native SwiftUI, ghi trong
  `_bmad-output/planning-artifacts/architecture.md`) khoá sản phẩm vào 1 platform,
  gấp đôi chi phí khi ra Android, và không khớp với bộ design đã vẽ sẵn cả 2
  platform (iOS + Material). Cần một hướng client thay thế trước khi vào backlog.
- Target actor: Cặp đôi đang yêu (couple-only app, 1:1 pairing) trên cả iOS và
  Android; nội bộ: team delivery cần 1 codebase.
- Value hypothesis: Flutter cho phép ship đồng thời iOS + Android từ 1 codebase,
  tái dùng 100% backend NestJS đã có, và render được ngôn ngữ thiết kế
  "cute-dark" tuỳ biến cao (Bun pet, mood face, zodiac, jar) mà không phụ thuộc
  widget hệ thống — đổi lại phải xử lý rủi ro native ở báo thức đồng bộ, mã hoá
  E2E và background realtime.
- Why this might matter now: Backend đã xong (~59 REST endpoints + 2 Socket.IO
  gateway), UI đã xong (~31 màn). Điểm chưa chốt duy nhất chặn delivery là kiến
  trúc client. Chốt sớm = mở khoá toàn bộ backlog mobile.
- Notes: Đây là **không gian lựa chọn kiến trúc ở mức khám phá**. Bản đặc tả
  kiến trúc ràng buộc (ADR, module boundary, contract) vẫn thuộc `tech-lead` qua
  `scrum-master`.

## Quyết Định Đã Chốt (2026-07-29)

| # | Quyết định | Nội dung | Hệ quả chính |
|---|-----------|----------|--------------|
| D0 | Client | **Flutter**, thay iOS Native (SwiftUI) | `_bmad-output/planning-artifacts/architecture.md` phần client = SUPERSEDED |
| D1 | Báo thức | v1 **chỉ cần thông báo nhắc đủ mạnh**, không cần báo thức thật | Không xin Critical Alerts, không viết module alarm native. Rủi ro alarm CAO → THẤP–TRUNG. **Epic-3 nên đổi từ ngữ "báo thức" → "nhắc nhở đồng bộ"** |
| D2 | State management | **Bloc** (khuyến nghị: Cubit cho màn CRUD, Bloc đầy đủ cho nghi thức + realtime) | Kèm `freezed` + `get_it`/`injectable`; `bloc_test`, cân nhắc `hydrated_bloc` |
| D3 | Adaptive UI | **Bám design**, giữ 2 bản iOS / Material | Không fork màn hình: 1 cây widget + `ThemeExtension` theo (platform × theme) + 4 widget adaptive có tên |
| D4 | Archetype | **Pragmatic Feature-First, 1 package** (hội tụ bằng PMI) | Hoãn melos monorepo và Pigeon tới khi thực sự cần |
| D5 | API client | **Sinh từ OpenAPI** — Swagger đã bật ở `backend/src/main.ts` (`/api-docs`) | Xoá phần lớn data layer viết tay; khoá contract client–server |

Rủi ro số 1 sau khi chốt: **không phải báo thức nữa, mà là Socket.IO lifecycle
nền + hợp nhất luồng socket/FCM** (chi tiết ở `development.md` → `## Convergence
Notes`).

## Bối Cảnh Đã Có (Đặc Tả Nguồn)

### 1. Quyết định cũ cần thay (`_bmad-output/planning-artifacts/architecture.md`)

- Client cũ: iOS Native — Swift 6 + SwiftUI + Combine, SPM, feature-based.
- Offline cũ: SwiftData/Realm. Crypto cũ: Sodium (Swift) ↔ sodium-native (Node).
- Cây nguồn cũ dự kiến: `source-code/ios/`.
- **Trạng thái mới: SUPERSEDED bởi Flutter.** Backend/hạ tầng trong tài liệu đó
  vẫn giữ nguyên hiệu lực (NestJS + PostgreSQL + Redis + Docker/VPS).

### 2. Backend đã hiện thực (`backend/`, docs `docs/backend/backend/`)

- NestJS 11 + platform-express + platform-socket.io.
- 16 module: `admin`, `alarms`, `auth`, `data-export`, `dream-jar`, `expenses`,
  `gallery`, `ghost-config`, `invitations`, `love-contracts`, `messages`,
  `pets`, `timeline`, `uploads`, `users`, `vibes`.
- ~59 REST endpoint (27 GET / 19 POST / 9 PATCH / 4 DELETE).
- 2 realtime gateway: `messages/chat.gateway.ts`, `alarms/alarms.gateway.ts`
  (Socket.IO — client Flutter phải dùng `socket_io_client`, không phải raw WS).
- Auth: `firebase-auth.strategy.ts` + `firebase-admin` → client gửi Firebase ID
  token; Flutter dùng `firebase_auth` + interceptor refresh token.
- **Swagger/OpenAPI ĐÃ BẬT** ✅ — `src/main.ts` (`DocumentBuilder` +
  `SwaggerModule.setup('api-docs', ...)`, `@nestjs/swagger@^11.2.6`), 15 file có
  `@ApiTags`/`@ApiOperation` → sinh được API client Dart tự động.
- Media: `uploads/` (multipart) + nginx; Docker Compose sẵn.
- Epic docs: `epic-1-core-connection`, `epic-2-communication`,
  `epic-3-daily-engagement`, `epic-4-intimacy-memories`, `epic-5-finance`,
  `epic-6-admin-privacy`.

### 3. UI đã thiết kế (`cupid-mobile-design/`) — BỔ SUNG MỚI

Dạng artifact: bản xuất **design-canvas HTML** (`*.dc.html`) chạy bằng
`support.js`, có template binding `{{ }}`, `<sc-if>`, `<sc-for>`, `<dc-import>`
— tức là **prototype có state, không phải ảnh tĩnh**. Rất hữu ích: đọc được
trực tiếp state model và điều kiện hiển thị của từng màn.

Tệp:

| Tệp | Vai trò |
|-----|---------|
| `Cupid Screens.dc.html` | Toàn bộ màn hình + state binding (nguồn chính) |
| `Cupid App.dc.html` | Vỏ prototype, picker cung hoàng đạo, preview 2 khung song song |
| `Bun Sprite.dc.html`, `Bun Pet Art.dc.html` | Art thú cưng "Bun" theo trạng thái |
| `Mood Face.dc.html` | 6 mặt cảm xúc (vibe check) |
| `Zodiac Icon.dc.html` | 12 icon cung hoàng đạo |
| `ios-frame.jsx` | Khung thiết bị iOS 26 (Liquid Glass) |
| `android-frame.jsx` | Khung thiết bị Material |

Khoảng **31 màn hình** (từ cờ `is*` trong prototype):

- Onboarding/Auth: `splash`, `welcome`, `login`, `register`, `forgot`, `otp`,
  `permissions`, `profile`, `zodiac`
- Ghép đôi: `invite`, `joinCode`, `waiting`, `paired`, `contract` (love
  contract, ký 2 phía), `vow` (fingerprint vow)
- Lõi hằng ngày: `home`, `chat`, `alarm`, `vibe`, `anti` (anti-ghosting),
  `ghostSet`
- Thân mật/kỷ niệm: `pet`, `gallery` (khoá/mở khoá), `timeline`
- Tài chính: `jar` (dream jar), `expense`
- Hệ thống: `notifs`, `privacy`, `me`, `index` (overlay chỉ mục màn hình)

Design system rút ra (đã soi lại ở cycle 2 — **hệ token có cấu trúc**, không phải
bảng màu rời):

- Token được cấp qua thuộc tính `data-plat` (`ios` | `md`) + `data-theme`
  (`dark` | `light`) + `data-lang` (`vi` | `en`).
- **Token ngữ nghĩa theo THEME** (giống nhau ở cả 2 platform):
  - Dark: `--bg:#171129`, `--surf:#241B42`, `--surf2:#2E2456`, `--tx:#F7EEFB`,
    `--tx2:#B4A6CE`, `--line:rgba(247,238,251,.11)`
  - Light: `--bg:#FFF6FB`, `--surf:#FFFFFF`, `--surf2:#FFEEF7`, `--tx:#3E2645`,
    `--tx2:#8A6D97`, `--line:#F7DFEC`
  - Màu thương hiệu đổi theo theme: pink `#FF7FB6`(dark) → `#E8558F`(light),
    purple `#B78CF5` → `#9A63E8`, mint `#79E2CD` → `#22B398`, amber `#FFD79E` →
    `#DE9A31`
  - Gradient: `--grad` `120deg,#FF9CC4,#C79BF0 52%,#8FE6D3`; `--grad-hot`
    `120deg,#FF7FB6,#B78CF5`; `--sky` (3 lớp radial-gradient nền)
- **Token theo PLATFORM** (chỉ 8 biến, đây là toàn bộ khác biệt về hình khối):
  | Token | iOS | Material |
  |-------|-----|----------|
  | `--safe-top` / `--safe-bot` | 54px / 24px | 6px / 6px |
  | `--r-card` | 26px | 24px |
  | `--fs-ui` | SF Pro Text / -apple-system | Roboto |
  | `--tap` | 44px | 48px |
  | `--shadow` | `0 10px 30px rgba(80,30,110,.18)` | `0 6px 18px rgba(80,30,110,.16)` |
  | `--r-btn` / `--r-sheet` / `--r-sm` | 999 / 28 / 16 | giống hệt |
- **⚠️ Đa ngôn ngữ là yêu cầu bậc nhất**: mọi chuỗi có cặp `<span data-vi>` /
  `<span data-en>` + 2 bảng chuỗi `VI` / `EN` trong runtime. Mặc định `vi`.
- **⚠️ Light theme đã được thiết kế**, không chỉ dark. Mặc định `dark`.
- Nunito 900 dùng cho tiêu đề/brand; `#121016` ghi ở cycle 1 là nền canvas của
  công cụ design, **không phải** nền app (nền app thật là `--bg`).
- Font: **Nunito** (brand/display, 400–900) + **Roboto** (UI) + **Roboto Mono**
  (mã mời, đồng hồ, số tiền).
- Icon: **Material Symbols Rounded** (có biến thể `line` / `soft` theo
  font-variation-settings).
- Art: SVG dựng tay có gradient + clip-path (jar `jarClip`/`jarLiq`, bun fur
  `bsFurA..F`, mood `mfA..F`) → Flutter cần chiến lược render vector/animation.

Tín hiệu tương tác đã có sẵn trong prototype (ảnh hưởng trực tiếp tới kiến trúc
state của Flutter):

- **Hold-to-confirm**: `startHold` / `endHold` / `holdPct` / `holdInvPct`.
- **Typing ghost**: `iAmTyping`, `partnerDraftText`, `showGhostBubble`,
  `typingWarn`, `iCanStop`, `iAlreadyStopped` → realtime draft streaming 2 chiều.
- **Đồng thuận 2 phía**: `bothSigned`, `bothVowed`, `bothConfirmed`,
  `mySigned`/`partnerSignStatus`, `needMyConfirm` → state máy chủ, không cục bộ.
- **Alarm**: `alarmRinging`, `doRing`, `doConfirmAlarm`, `waitingPartnerAlarm`,
  `stopAColor`/`stopBColor` → báo thức đồng bộ, dừng 2 phía.
- **Anti-ghosting**: `ghostAlert`, `stormReady`, `stormOnMe`, `doStorm`,
  `ghostToastText`, `pickThreshold`.
- **Gallery khoá**: `galleryLocked` / `doUnlock` → sinh trắc học + nội dung mã hoá.
- **Pet**: `petState` (`inlove` / `sulk` / `sick`), `petXpPct`, `doFeed`,
  `doNaughty`.
- **Jar**: `jarPct`, `liquidY`, `jarAmount`, `jarTargetAmount` → animation liên tục.

**Phát hiện quan trọng cho kiến trúc (đã xác minh ở cycle 2)**: 2 bản iOS/Material
**KHÔNG phải 2 cây màn hình song song**. Prototype dùng **một cây màn hình chung**
+ đổi bộ token qua `data-plat`, và chỉ có **4 điểm rẽ nhánh cấu trúc** trong toàn
bộ ~31 màn:

| # | Vị trí | iOS | Material |
|---|--------|-----|----------|
| 1 | Welcome / đăng nhập xã hội | Có nút **Sign in with Apple** (nền đen) | Không có |
| 2 | Màn danh sách (expense/jar) | CTA gradient full-width dưới đáy | **FAB** 60×60, radius 20, sticky góc phải |
| 3 | Login — nút sinh trắc học | "Đăng nhập bằng **Face ID**" | "**Vân tay** / Fingerprint" |
| 4 | Thanh tab dưới | Nền trong suốt + `backdrop-filter: blur(26px)` | Nền `--surf` + viền trên + **pill chỉ báo tab đang chọn** (Material 3) |

Ngoài 4 điểm này, khác biệt chỉ là token (bảng trên) + icon back
(`arrow_back_ios_new` ↔ `arrow_back`) + nhãn sinh trắc học.

→ Hệ quả: "bám vào design" **không có nghĩa là code 2 lần**. Nó dịch sang Flutter
thành: 1 cây widget + `ThemeExtension` token theo (platform × theme) + 4 widget
adaptive có tên + bảng icon/nhãn adaptive.

### 4. Khoảng trống đã nhận diện

- Không có màn design cho `admin` và `data-export` → 2 module này ngoài phạm vi
  mobile (web admin / API-only).
- Design có `me`, `privacy`, `notifs` nhưng cần soi lại endpoint tương ứng khi
  vào tech-lead.

## Handoff Package → scrum-master (2026-07-29)

Trạng thái: **HANDOFF_RECOMMENDED**. Brainstormer dừng tại đây; không tạo
`data/requirements/`. Backlog hiện **trống** (`data/requirements/` chưa tồn tại,
chưa có active scope) → đây sẽ là requirement đầu tiên của repo.

### Seed yêu cầu đề xuất

> Xây dựng ứng dụng mobile Cupid bằng **Flutter** cho cả iOS và Android, tiêu thụ
> backend NestJS đã hoàn thiện, hiện thực đúng bộ design đã chốt tại
> `cupid-mobile-design/` (~31 màn, 2 bản iOS/Material, dark + light, VI + EN).

### Trong phạm vi

- ~31 màn theo prototype, nhóm theo 6 epic backend hiện có.
- Nền tảng client: design system + token (platform × theme), i18n, API client
  sinh từ OpenAPI, auth Firebase, tầng realtime Socket.IO.
- Kênh realtime: chat, typing-ghost, anti-ghosting, nhắc nhở đồng bộ.

### Ngoài phạm vi

- Module `admin` và `data-export` (không có màn design cho mobile).
- Báo thức cấp hệ thống / Critical Alerts entitlement (D1 hoãn khỏi v1).
- Thay đổi contract backend (A1: backend đóng băng).

### Ràng buộc kiến trúc đã chốt cho tech-lead

Xem `## Quyết Định Đã Chốt (2026-07-29)` bên trên: **D0–D5**. Tech Lead viết ADR
từ đây, không khám phá lại option space.

### Thứ tự nền tảng đề xuất (mức khám phá, không ràng buộc)

1. `design_system` + token (platform × theme) + i18n ARB — **shared-foundation,
   phải làm trước mọi feature** (rủi ro R7).
2. `api_client` sinh từ OpenAPI `/api-docs`.
3. Auth Firebase + interceptor refresh token.
4. **Spike `RealtimeCoordinator`** (hợp nhất Socket.IO + FCM) — rủi ro R2, cao nhất.
5. Feature theo epic-1 → epic-6.

### Rủi ro bàn giao kèm

R2 socket/FCM (cao) · R7 design_system làm sau (cao, effort thấp) · R6 kỷ luật
Bloc/Cubit · R3 libsodium FFI · R4 perf Android low-end · R1 alarm (đã hạ) ·
R5 trôi UI. Bảng Impact/Effort đầy đủ ở `development.md` → `## Convergence Notes`.

### Việc product-owner cần xử lý

- **Đổi từ ngữ epic-3**: "báo thức đồng bộ" → "**nhắc nhở đồng bộ**" (hệ quả của
  D1), để không hứa quá với người dùng.
- Quyết OQ5: light theme + tiếng Anh có nằm trong v1 không.

## Artifacts

- Development: `development.md`
- Checkpoint: `brainstormer-checkpoint.md`
- Design source: `cupid-mobile-design/`
- Backend source: `backend/src/modules/`
- Backend docs: `docs/backend/backend/`
- Kiến trúc cũ (superseded): `_bmad-output/planning-artifacts/architecture.md`

## Routing Notes

- Current owner: **đang chuyển giao → scrum-master**
- Next action: **HANDOFF_RECOMMENDED** (user đã duyệt 2026-07-29). Gói bàn giao
  ở `## Handoff Package → scrum-master`. Brainstormer không tạo requirement.
- Delivery handoff: user chạy `scrum-master` / `PM` với seed trong gói bàn giao;
  ADR ràng buộc do `tech-lead` viết, không viết ở đây.
- Linked Requirement: REQ-001 (`data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`).
