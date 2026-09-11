# P10 — Nạp lại khoá chủ `owner_key` khi khởi động nguội

Spec nguồn: `coding-plan/master-plan.md` §9 (§9.1-§9.9), commit `ca33ba7`.

## Vấn đề (§9.1)

Startup smoke R-2 sau P9 bắt được defect thật: `BackendUserIdStore` chỉ giữ
`_backendUserId` trong RAM, nạp duy nhất qua ba đường đăng nhập
(`AuthRepository.signInWithEmail`/`verifyOtp`/`_syncBackendProfile`) và
`chat_partner_store.dart:57`. Không có đường nào chạy khi người dùng chỉ mở
lại app với phiên đã lưu sẵn, nên `ActivityCardRepositoryImpl._requireOwnerKey()`
ném `StateError` cho mọi người dùng quay lại — hub kẹt Minute-1, `createCard`
ném unhandled exception, và vì DAO không bao giờ được gọi nên migration
v2→v3 không đo được.

## Phương án đã chọn (§9.3)

Nạp lười, đọc lại `cupid_user_id` đã có sẵn trong SharedPreferences (ghi bởi
`CupidSession.setSession` → `JwtTokenProvider.saveSession`) ngay trong
`BackendUserIdStore.resolve()`, qua một tham số constructor tuỳ chọn dây với
`JwtTokenProvider.getSavedUserId` ở DI. Không persist thêm state mới, không
gọi mạng, không đổi thứ tự khởi động; teardown đăng xuất đã đúng sẵn
(`CupidSession.signOut()` xoá `cupid_user_id` trước khi chạy
`clearOnSignOut()` của các scoped store).

Hai phương án khác bị loại (§9.3): gọi `GET /users/me` lúc khởi động (biến
kho cục bộ offline-first thành phụ thuộc mạng), và persist riêng
`backendUserId` bằng khoá mới (tạo nguồn sự thật thứ hai, sống sót qua đăng
xuất vì `clearSession()` không biết khoá mới — vi phạm AC-22/D-012-5).

## Thay đổi

1. `mobile/lib/core/realtime/backend_user_id_store.dart` — tham số
   constructor tuỳ chọn `readPersistedUserId` (mặc định `null`), và
   `resolve()` đọc lại giá trị persist khi RAM rỗng, cache lại, ưu tiên RAM
   khi đã có. Mặc định `null` là bắt buộc (§9.5): mọi call site preview/test
   hiện có dựng `BackendUserIdStore()` trần, và nếu mặc định tự đọc prefs thì
   chúng sẽ ném `MissingPluginException` khi thiếu
   `SharedPreferences.setMockInitialValues`.
2. `mobile/lib/core/di/service_locator.dart` dòng 174 — dây
   `readPersistedUserId: getIt<JwtTokenProvider>().getSavedUserId`.
   `JwtTokenProvider` đã đăng ký ở dòng 107, trước 174.
3. `mobile/test/core/realtime/backend_user_id_store_test.dart` — nhóm test
   mới `BackendUserIdStore cold-start rehydration (P10)` phủ §9.6 rule 1-3.
4. `mobile/test/features/activity_cards/activity_card_repository_test.dart` —
   một test khởi động nguội mới phủ §9.6 rule 4.

## Cấm đã tuân thủ (§9.7)

Không chạm `home_screen.dart`, `pair_gate_shell.dart`,
`CupidDatabase.schemaVersion`/migration, `cupid_session.dart`,
`jwt_token_provider.dart` (chỉ gọi `getSavedUserId` sẵn có, không sửa), getter
đồng bộ `couple_pairing_store.dart:99`, không thêm khoá SharedPreferences
mới, không đổi `updateFromLoginResponse`/`updateUserId`/`clearOnSignOut`,
không chạm `main_preview.dart`/`preview_reminder_fixture.dart`.

## Xác minh

- `flutter analyze` trên 4 file thay đổi: 0 error, 1 info
  (`prefer_initializing_formals`, không chặn gate).
- `flutter test` trên 2 file test thay đổi: 22/22 xanh.
- Chi tiết đầy đủ ở `coding-plan/test-results.md` mục "P10 — nạp lại khoá chủ
  `owner_key` khi khởi động nguội (mobile-dev)".

## Còn lại, ngoài phạm vi P10

- Chạy lại startup smoke R-2 trên thiết bị thật theo kịch bản
  `test-results.md` dòng 1123-1141 (Scrum-Master-owned).
- `couple_pairing_store.dart`'s getter `backendUserId` đồng bộ vẫn nguội khi
  khởi động (§9.7) — ghi nhận thành việc tiếp theo cấp requirement, ngoài
  phạm vi P10.
