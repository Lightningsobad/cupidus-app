# Idea Development: IDEA-20260729-001 Cupid Flutter Mobile Architecture

## BMAD Session State

- Stance: Creative Partner
- Topic: Không gian lựa chọn kiến trúc Flutter cho Cupid mobile, thay thế quyết
  định iOS Native (SwiftUI) trước đây.
- Goal: Sinh đủ rộng các phương án kiến trúc + đánh đổi + rủi ro, để khi user
  chốt hướng thì `tech-lead` có thể viết ADR ràng buộc mà không phải khám phá lại.
- Constraints:
  - Backend NestJS đã đóng băng: ~59 REST + 2 Socket.IO gateway + Firebase Auth.
  - Design đã đóng băng: ~31 màn, dark theme tuỳ biến cao, render 2 nhánh iOS/MD.
  - Không viết ADR/implementation plan tại đây (ranh giới brainstormer).
- Active technique batch: cycle 1 — (1) Assumption Reversal, (2) Constraint-First,
  (3) Forced Archetypes, (4) Contrarian/Adjacent. cycle 2 — (5) Design-source
  evidence probe, (6) **PMI** (hội tụ chính), (7) Impact/Effort trên rủi ro.
- Approximate raw idea count: ~46
- Domain shifts explored: layering → state → realtime/offline → native-risk →
  render/animation → DX/CI → contrarian → design-token/adaptive → hội tụ
- Convergence state: **CONVERGED (sơ bộ)** — archetype đã chốt qua PMI; còn 2
  open question mức chi tiết, không chặn hướng.
- Next technique or move: xác minh A4 (Swagger) + quyết OQ4/OQ5 → handoff
  `scrum-master` → `tech-lead` viết ADR.

## Idea Inventory

### 2026-07-29 — Cycle 1

**Kỹ thuật A — Assumption Reversal (đảo giả định)**

1. Đảo "Flutter = 1 codebase phủ hết": phần khó nhất (báo thức đồng bộ, sinh
   trắc học, mã hoá) vẫn là native. Flutter là **UI + orchestration layer**, còn
   ~10–15% là platform channel. Kiến trúc phải có **native capability layer**
   ngay từ đầu, không bolt-on sau.
2. Đảo "phải Clean Architecture 3 lớp cho mọi feature": app couple-only, 1:1, ít
   biến thể nghiệp vụ → 3 lớp đầy đủ cho `chat`/`alarm`/`gallery`, nhưng
   `zodiac`/`notifs`/`privacy` chỉ cần 2 lớp (repo + view model). **Layering phân
   tầng theo độ rủi ro**, không đồng nhất.
3. Đảo "backend đã xong nên client chỉ việc gọi": 2 gateway Socket.IO nghĩa là
   một phần state là **push-driven**, không request-driven. Repository phải phơi
   `Stream`, không phải `Future`, cho chat/alarm/typing-ghost/anti-ghosting.
4. Đảo "design đẹp = code UI khó": prototype đã có state binding sẵn
   (`holdPct`, `bothSigned`, `petState`...) → có thể **trích state model trực tiếp
   từ design** làm khung view-model, tiết kiệm 1 vòng đặc tả.
5. Đảo "Flutter tệ cho animation phức tạp": jar liquid + bun sprite + mood face
   đều là SVG/vector đơn giản → `CustomPainter`/`flutter_svg` thừa sức; rủi ro
   thật nằm ở **thiết bị Android low-end**, không ở Flutter.

**Kỹ thuật B — Constraint-First: "cái gì gãy trước khi lên Flutter"**

6. **Báo thức đồng bộ (rủi ro #1)**: iOS không cho app đặt alarm thật. Lựa chọn:
   (a) local notification + custom sound, (b) Critical Alerts entitlement (phải
   xin Apple, dễ bị từ chối), (c) VoIP/CallKit push (rủi ro policy cao),
   (d) chấp nhận "nhắc nhở" thay vì "báo thức". Android:
   `AlarmManager` exact alarm + `SCHEDULE_EXACT_ALARM` (Android 12+ cần xin quyền).
   → **Đây là quyết định sản phẩm, không phải kỹ thuật.**
7. **Fingerprint vow + gallery lock**: `local_auth` phủ được (FaceID/TouchID/
   BiometricPrompt). Nhưng "vow bằng vân tay" mang tính nghi thức — cần rõ là
   xác thực hay chỉ là hiệu ứng.
8. **Mã hoá E2E (libsodium)**: quyết định cũ dùng Sodium(Swift)↔sodium-native
   (Node). Flutter: `sodium_libs` (FFI, binary cả 2 platform) hoặc
   `cryptography_flutter`. Khả thi, nhưng tăng app size + rủi ro build.
9. **Socket.IO khi app nền/kill**: socket chết. Anti-ghosting & typing-ghost phải
   có **đường đôi**: socket khi foreground, FCM/APNs khi background. Kiến trúc
   cần một `RealtimeCoordinator` hợp nhất 2 nguồn, tránh double-render.
10. **Offline**: cũ định SwiftData/Realm. Flutter: `Drift` (SQLite, reactive
    query, migration tốt) / `Isar v4` / `ObjectBox` / `Hive` (nhẹ, yếu query).
    → Chat history + timeline + expenses cần query thật → nghiêng **Drift**.
11. **Upload media**: `uploads/` multipart + nginx → cần queue upload có resume,
    nén ảnh client-side, progress UI cho gallery.
12. **Token refresh**: Firebase ID token hết hạn 1h → interceptor refresh + retry,
    và socket phải re-auth khi token đổi (dễ bị bỏ sót).

**Kỹ thuật C — Forced Archetypes (3 biến thể ép buộc)**

13. **Archetype 1 — "Pragmatic Feature-First"** (1 package, feature folder,
    Riverpod + go_router + dio, Drift, native channel mỏng).
    Nhanh nhất ra bản chạy được. Rủi ro: ranh giới mờ khi team lớn dần.
14. **Archetype 2 — "Modular Monorepo"** (melos: `core`, `design_system`,
    `api_client`, `native_bridge`, `feature_*`). Ranh giới cứng, test song song,
    ép design-system tách khỏi feature. Chi phí setup + ma sát build_runner.
15. **Archetype 3 — "Hybrid Native-Critical"**: Flutter cho ~28 màn; giữ module
    native riêng cho alarm + biometric vow + crypto, phơi qua Pigeon-typed
    channel. Bảo toàn độ tin cậy phần khó, giữ tốc độ phần dễ.
16. Biến thể lai 1+3 = có lẽ là điểm ngọt: đơn package + `native_bridge` được
    generate bằng **Pigeon** (type-safe, không MethodChannel chuỗi ma thuật).

**Kỹ thuật D — Trục lựa chọn (option space chi tiết)**

17. State: **Riverpod v3** (codegen, testable, scoped, hợp app nhiều stream) vs
    **Bloc/Cubit** (event trace tốt cho flow nghi thức: ký hợp đồng, vow, alarm)
    vs Signals (mới, ít người) vs GetX (loại).
18. Navigation: **go_router** — bắt buộc nếu deep link lời mời (`invite`/
    `joinCode`) và notification tap routing; auto_route là lựa chọn 2.
19. Networking: **dio + interceptor** (auth, retry, error envelope) +
    **Retrofit/codegen**. Cú hích lớn: backend NestJS có Swagger → **sinh API
    client tự động từ OpenAPI**, khoá contract client-server, xoá lớp DTO viết tay.
20. Model: `freezed` + `json_serializable` (union state cho `petState`,
    `ghostAlert`, `alarmRinging` rất hợp).
21. Realtime: bọc `socket_io_client` thành repository phơi `Stream<DomainEvent>`,
    có backoff + heartbeat + lifecycle-aware (`AppLifecycleListener`).
22. Design system: package `design_system` với `CupidTheme` (token màu/typo lấy
    thẳng từ prototype), atom widget (`HoldButton`, `MoodFace`, `BunSprite`,
    `ZodiacIcon`, `JarGauge`) → 5 widget này tái dùng ở >10 màn.
23. Vector art: `flutter_svg` cho zodiac/mood (tĩnh), `CustomPainter` cho jar
    liquid (animate liên tục), `rive` nếu muốn Bun có animation thật sự sống.
24. Adaptive: `Theme.of` + `Platform.isIOS` switch ở **shell level** (nav bar,
    dialog, scroll physics, haptics) chứ không nhân đôi màn hình.
25. Testing: `mocktail` + widget test + **golden test** (app này nặng thị giác,
    golden bảo vệ được design) + `integration_test` cho pairing flow.
26. Flavors: `--dart-define-from-file` cho dev/staging/prod, khớp docker compose.
27. CI/CD: GitHub Actions (backend đã có `.github`) + fastlane; cân nhắc
    **Shorebird code push** để vá nhanh Dart-side mà không chờ store review.
28. Observability: Crashlytics + Sentry; log realtime event có redaction (app
    riêng tư, không log nội dung chat).

**Kỹ thuật E — Contrarian / Adjacent**

29. Contrarian: "Đừng dùng Flutter, dùng **Compose Multiplatform**" — Android
    ngon nhưng iOS còn non và team đang không có Kotlin ngữ cảnh → loại, nhưng
    ghi lại để không phải cãi lại sau.
30. Contrarian: "Ship Android trước bằng Flutter, iOS sau" — vì rào cản alarm
    của iOS. Cho phép validate vòng lặp nghi thức trước khi đấu với Apple.
31. Adjacent: **add-to-app** — không liên quan, không có app cũ để nhúng → loại.
32. Adjacent: cùng codebase Flutter xuất **web build** cho trang admin nhẹ (module
    `admin` không có màn mobile) → tiết kiệm, nhưng lệch trọng tâm.
33. Black-swan: nếu Apple từ chối Critical Alerts, toàn bộ epic-3 (alarm đồng bộ)
    tụt giá trị → cần **plan B sản phẩm** trước khi code, không phải sau.
34. Adjacent: prototype `.dc.html` có thể trở thành **nguồn golden test** — so
    screenshot Flutter với khung design để phát hiện trôi UI.

### 2026-07-29 — Cycle 2 (user chốt OQ1–OQ3)

**Quyết định user**

- **D1 / OQ1**: Chưa cần báo thức thật. Chỉ cần **thông báo nhắc đủ mạnh**.
- **D2 / OQ2**: **Bloc**.
- **D3 / OQ3**: **Bám vào design**, design đã chia 2 bản android/ios rõ ràng.

**Kỹ thuật E — Design-source evidence probe (đọc thẳng prototype)**

35. D3 được xác minh lại và **rẻ hơn tưởng tượng**: 2 bản không phải 2 cây màn
    hình. Là 1 cây chung + `data-plat` đổi **8 token** + đúng **4 điểm rẽ nhánh
    cấu trúc** (Sign in with Apple / FAB vs CTA full-width / nhãn Face ID vs Vân
    tay / tab bar blur vs pill Material 3). Chi tiết bảng trong `idea.md`.
36. → Dịch sang Flutter: `CupidTokens extends ThemeExtension` khoá theo
    (platform × theme), **không** fork màn hình. Chi phí adaptive ≈ 4 widget +
    1 bảng token, không phải ×2 khối lượng UI.
37. **Phát hiện ngoài dự kiến #1 — i18n là bậc nhất**: mọi chuỗi có cặp
    `data-vi`/`data-en` + 2 bảng chuỗi VI/EN. Trước đây chưa ai ghi vào scope.
    → cần `flutter_localizations` + ARB ngay từ story đầu, không nhét sau.
38. **Phát hiện ngoài dự kiến #2 — light theme đã được thiết kế** (`--bg:#FFF6FB`
    + bộ màu thương hiệu đậm hơn cho nền sáng). Không phải chỉ dark.
    → `ThemeExtension` phải là (platform × theme) = 4 tổ hợp, chứ không phải 2.
39. Hệ quả kiểm thử: 4 tổ hợp × 2 ngôn ngữ = 8 biến thể golden. Không golden test
    hết mọi màn — chỉ golden **design_system atoms** + ~6 màn tiêu biểu.
40. `--tap` 44 (iOS) vs 48 (MD) là **token accessibility**, nên đưa vào token set
    thay vì hardcode — dễ bị bỏ sót nhất khi code.

**Kỹ thuật F — PMI trên archetype dẫn đầu** *(phương pháp hội tụ chính)*

Ứng viên: **Archetype 1 (Pragmatic Feature-First, 1 package) + cầu native mỏng
sinh bằng Pigeon** — vì D1 làm teo phần native, và D3 hoá ra rẻ.

*Plus*

41. D1 xoá gần hết rủi ro native lớn nhất: không xin Critical Alerts, không viết
    module alarm native → chỉ còn `flutter_local_notifications` + FCM. R1 tụt từ
    CAO xuống THẤP–TRUNG.
42. Bề mặt native còn lại chỉ 2: `local_auth` (vow + gallery lock) và crypto
    libsodium — cả 2 đều có package pub trưởng thành, gần như không cần
    platform channel tự viết → **Pigeon có thể chưa cần ở v1**.
43. D3 rẻ → không cần melos để cô lập design system; 1 package + thư mục
    `design_system/` là đủ cho quy mô 31 màn.
44. Bloc + `freezed` khớp rất tốt với các flow nghi thức có trạng thái đồng thuận
    (`bothSigned` / `bothVowed` / `bothConfirmed` / `alarmRinging`): mỗi nghi
    thức = 1 Bloc, event trace tường minh, dễ tái hiện lỗi.
45. Bloc có `bloc_test` + `hydrated_bloc` sẵn → hydrated_bloc lo phần khôi phục
    state khi app bị kill, giảm áp lực lên tầng offline.

*Minus*

46. 1 package = ranh giới do quy ước, không do compiler. Khi 31 màn cùng chạm
    `design_system/` dễ trôi. Giảm nhẹ bằng lint rule import boundary.
47. Bloc dài dòng hơn Riverpod cho màn CRUD đơn giản (`notifs`, `privacy`,
    `zodiac`) → dùng **Cubit** cho nhóm này, chỉ dùng Bloc đầy đủ cho nghi thức
    và realtime. Đây là điểm dễ bị làm sai nhất.
48. Bloc không tự lo dependency injection → cần `get_it` + `injectable`, thêm 1
    lớp codegen nữa cạnh `freezed`/`json_serializable` → `build_runner` chậm dần.
49. D1 hạ rủi ro kỹ thuật nhưng **hạ cả giá trị sản phẩm của epic-3**: "báo thức
    đồng bộ" tụt thành "nhắc nhở đồng bộ". Cần ghi rõ để PO không hứa quá.

*Interesting*

50. Vì phần khó native đã bị D1 gỡ bỏ, **đường tới hạn không còn là alarm mà là
    Socket.IO lifecycle** (R2). Đây là thay đổi thứ tự ưu tiên đáng chú ý nhất
    của cycle này.
51. `hydrated_bloc` + Drift chồng vai trò nhau. Có thể chỉ cần Drift cho
    chat/timeline/expenses, còn state phù du (draft, mood đang chọn) để
    hydrated_bloc → tránh 2 nguồn sự thật.
52. Nếu bật Swagger ở NestJS, kết hợp `openapi-generator` + `freezed` có thể sinh
    luôn cả model lẫn client → phần "data layer" gần như biến mất khỏi backlog.
53. Prototype `.dc.html` chạy được → có thể dùng làm **đối chứng golden trực
    tiếp** (render prototype ở 4 tổ hợp token, so với screenshot Flutter).
54. Vì đã có light theme + i18n, app này thực chất có **8 bề mặt trình bày**.
    Nên coi `design_system` là story nền tảng (shared-foundation) làm TRƯỚC mọi
    feature, nếu không sẽ phải sửa lại 31 màn.

## Current Snapshot

- Problem framing: Chốt kiến trúc client Flutter thay iOS Native, sao cho tái
  dùng trọn vẹn backend đã xong và render đúng bộ design đã xong, đồng thời cô
  lập được 3 rủi ro native (alarm, sinh trắc học, mã hoá).
- Target actors: cặp đôi trên iOS + Android; team delivery 1 codebase.
- JTBD / use moment: các nghi thức hằng ngày (báo thức chung, vibe check, chat
  có typing-ghost, chăm pet, hũ ước mơ) — phần lớn là **realtime, 2 chiều, có
  trạng thái đồng thuận**, chứ không phải CRUD.
- Value proposition: 1 codebase → phủ 2 platform; backend + design đã đóng băng
  nên rủi ro còn lại tập trung hoàn toàn ở client.
- Option space: xem `## Idea Inventory` mục 13–28 (phân kỳ) và 41–54 (hội tụ).
- Differentiators: kiến trúc phải coi **realtime-first** là bậc nhất (không phải
  CRUD), và **8 bề mặt trình bày** (2 platform × 2 theme × 2 ngôn ngữ) là ràng
  buộc nền tảng, không phải việc trang trí cuối dự án.
- Risks and constraints *(đã xếp lại sau D1)*:
  - **R2 (nay là #1, TRUNG–CAO)**: Socket.IO lifecycle nền + đường đôi
    socket/FCM gây trùng/nhân đôi state ở chat, typing-ghost, anti-ghosting.
  - **R6 (mới, TRUNG)**: kỷ luật Bloc vs Cubit không nhất quán giữa 31 màn →
    phình code ở màn CRUD, hoặc thiếu event trace ở màn nghi thức.
  - **R7 (mới, TRUNG)**: `design_system` (4 tổ hợp token + i18n) nếu làm sau
    feature sẽ phải sửa lại toàn bộ 31 màn.
  - R3 (TRUNG): libsodium FFI 2 platform — app size + build fragility.
  - R4 (THẤP–TRUNG): perf animation (jar liquid, bun sprite) trên Android low-end.
  - R1 (**hạ từ CAO xuống THẤP–TRUNG** nhờ D1): chỉ còn notification + FCM; rủi
    ro còn lại là kỳ vọng sản phẩm của epic-3, không phải kỹ thuật.
  - R5 (THẤP): trôi UI so với design nếu không golden test atoms.
- Assumptions:
  - A1: Backend giữ nguyên, không đổi contract vì client.
  - A2: Android + iOS ra cùng lúc.
  - A3: `admin`, `data-export` ngoài phạm vi mobile.
  - A4 (**ĐÃ XÁC MINH ✅**): `backend/src/main.ts` có `DocumentBuilder` +
    `SwaggerModule.setup('api-docs', ...)`, `@nestjs/swagger@11`, 15 file có
    `@ApiTags`/`@ApiOperation` → **sinh được API client Dart từ OpenAPI**, xoá
    phần lớn data layer viết tay. Chuyển từ giả định thành sự kiện.
  - A5 (mới): mặc định khởi động là `theme=dark`, `lang=vi` (theo prototype).
- Open questions: xem `## Open Questions`.
- Recommended next move: xác minh A4, quyết OQ4–OQ5, rồi handoff `scrum-master`
  để `tech-lead` viết ADR ràng buộc.

## Open Questions

**Đã đóng ở cycle 2**

- ~~OQ1~~ → **D1**: chỉ cần thông báo nhắc đủ mạnh. Không xin Critical Alerts ở
  v1. *Kèm hệ quả sản phẩm*: epic-3 nên gọi là "nhắc nhở đồng bộ", không phải
  "báo thức" — cần PO xác nhận lại từ ngữ với user.
- ~~OQ2~~ → **D2**: Bloc (khuyến nghị kèm: Cubit cho màn CRUD, Bloc đầy đủ cho
  nghi thức + realtime).
- ~~OQ3~~ → **D3**: bám design. Đã xác minh = 1 cây widget + token
  (platform × theme) + 4 điểm rẽ nhánh có tên, **không fork màn hình**.

**Còn mở (không chặn hướng)**

- **OQ4 — Offline**: dùng **Drift** (SQLite, query thật) cho chat/timeline/
  expenses, hay chỉ dựa vào `hydrated_bloc` cho v1? Hai thứ này chồng vai trò.
  *Giả định tạm*: Drift cho 3 miền có lịch sử dài; hydrated_bloc cho state phù du.
- **OQ5 — Light theme & i18n EN trong phạm vi v1?** Design đã vẽ cả 2, nhưng có
  thể hoãn để rút ngắn v1.
  *Giả định tạm*: hạ tầng token + ARB làm ngay từ đầu (rẻ khi làm sớm, đắt khi
  làm sau), nhưng chỉ **bật** dark + vi ở v1.

## Convergence Notes

**Cycle 2 — phương pháp: PMI** (trên Archetype 1 + cầu native mỏng), có
Impact/Effort triage rủi ro kèm theo.

Kết luận hội tụ:

- **Archetype được chọn: "Pragmatic Feature-First, 1 package"** — bỏ melos, bỏ
  module native tự viết. Lý do: D1 gỡ bỏ phần native khó nhất, D3 hoá ra rẻ hơn
  giả định, quy mô 31 màn chưa đủ lớn để trả giá cho monorepo.
- Bề mặt native còn lại chỉ 2 (`local_auth`, crypto) và đều có package trưởng
  thành → **Pigeon hoãn tới khi thực sự cần**.
- **Đường tới hạn đã đổi**: không còn là báo thức (R1), mà là **Socket.IO
  lifecycle + hợp nhất socket/FCM (R2)**.

Impact/Effort trên rủi ro (sau khi xếp lại):

| Rủi ro | Impact | Effort giảm thiểu | Hành động |
|--------|--------|-------------------|-----------|
| R2 socket/FCM | Cao | Trung | **Làm spike trước tiên**; 1 `RealtimeCoordinator` hợp nhất, khử trùng theo event id |
| R7 design_system | Cao | Thấp | Làm **story nền tảng đầu tiên**, trước mọi feature |
| R6 kỷ luật Bloc/Cubit | Trung | Thấp | Chốt quy ước + lint ngay trong ADR |
| R3 libsodium | Trung | Trung | Spike build 2 platform sớm, trước khi vào epic-4 |
| R4 perf animation | Trung | Thấp | Đo trên 1 máy Android low-end mốc |
| R1 alarm | Thấp | Thấp | Chỉ cần PO chỉnh lại từ ngữ epic-3 |
| R5 trôi UI | Thấp | Thấp | Golden test atoms + ~6 màn tiêu biểu |

Thứ tự nền tảng đề xuất (mức khám phá, không phải plan ràng buộc):
`design_system + token/i18n` → `api_client (từ Swagger)` → `auth/Firebase` →
`RealtimeCoordinator spike` → feature theo epic.

## Research Notes

- Chưa dùng web research trong cycle này. Toàn bộ căn cứ lấy từ artifact nội bộ:
  `_bmad-output/planning-artifacts/architecture.md`, `backend/src/modules/`,
  `backend/package.json`, `cupid-mobile-design/*.dc.html`.
- Cycle 2: **không cần** research Critical Alerts nữa (D1 đã loại khỏi v1).
- Cycle 2 dùng **design-source probe** (đọc trực tiếp `Cupid Screens.dc.html`:
  khối CSS `[data-plat]`, 4 vùng `sc-if` phân nhánh, hàm `renderVals()`) thay cho
  web research. Bằng chứng đã chưng cất vào `idea.md`; không lưu raw.
- Chưa dùng live-site browser probing (không cần — nguồn là file cục bộ).
- **A4 đã xác minh trong cycle 2**: `backend/src/main.ts:4,20,37,38` —
  `DocumentBuilder` + `SwaggerModule.setup('api-docs', app, document)`;
  `@nestjs/swagger@^11.2.6`; 15 file controller/DTO có `@ApiTags`/`@ApiOperation`.
  → OpenAPI spec sẵn sàng cho codegen client Dart.

## Session Log

- 2026-07-29: Idea được tạo từ quyết định đổi iOS Native → Flutter. Cycle 1
  (Creative Partner): 4 kỹ thuật, ~34 ý tưởng thô, 3 archetype, 12 trục lựa chọn,
  5 rủi ro, 3 open question. Bổ sung đặc tả UI từ `cupid-mobile-design/` (31 màn,
  design token, tín hiệu tương tác, phát hiện render 2 nhánh iOS/MD) và đặc tả
  backend đã hiện thực (16 module, ~59 endpoint, 2 gateway, Firebase Auth).
  Chưa hội tụ.
- 2026-07-29: Cycle 2. User chốt D1 (chỉ cần thông báo nhắc, không cần báo thức
  thật), D2 (Bloc), D3 (bám design 2 bản). Probe design-source làm rõ D3 = 1 cây
  widget + 8 token platform + 4 điểm rẽ nhánh, không fork màn hình; phát hiện
  thêm **i18n VI/EN** và **light theme** là yêu cầu bậc nhất chưa từng nằm trong
  scope. Chạy **PMI** → chốt archetype "Pragmatic Feature-First, 1 package",
  hoãn melos và Pigeon. Impact/Effort xếp lại rủi ro: đường tới hạn chuyển từ
  alarm (R1) sang **Socket.IO lifecycle (R2)**; thêm R6 (kỷ luật Bloc/Cubit) và
  R7 (design_system phải làm trước). Xác minh **A4 = TRUE** (Swagger đã bật).
  Trạng thái: CONVERGED sơ bộ, còn OQ4/OQ5 không chặn hướng.
- 2026-07-29: User duyệt handoff. Đóng gói bàn giao vào `idea.md` →
  `## Handoff Package → scrum-master` (seed yêu cầu, in/out of scope, ràng buộc
  D0–D5, thứ tự nền tảng, rủi ro kèm, việc cho product-owner). Ghi nhận backlog
  đang trống → đây là requirement đầu tiên. Brainstormer DỪNG tại ranh giới;
  không tạo `data/requirements/`.
