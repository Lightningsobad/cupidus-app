# Phân tích kiến trúc Cupid Flutter

Phạm vi: `mobile/lib`, manifest Flutter và client API; phân tích tĩnh, không chạy app hay xác minh backend. Commit dẫn chứng: `f0b7b03c3a57cdb9974840d267d8c63a1928af7e`. Các liên kết dưới đây mở file trong checkout; nguồn trên sơ đồ gắn với commit.

**Kết luận phân tích:** ứng dụng tổ chức theo feature, với presentation, nghiệp vụ và data; dùng GetIt làm composition root, Cubit/Bloc cho state giao diện, stream cho cập nhật dữ liệu và phiên. Đây là cách gọi kiến trúc do người phân tích suy ra từ code, không phải bảo đảm mọi module tuân thủ cùng một mẫu.

## Tầng và phụ thuộc đã xác nhận

| Tầng | Vai trò và bằng chứng |
|---|---|
| Bootstrap | [main.dart](D:/App/cupidus/mobile/lib/main.dart:17) kiểm tra config, khởi tạo Firebase, gọi setupServiceLocator rồi runApp. |
| Composition | [service_locator.dart](D:/App/cupidus/mobile/lib/core/di/service_locator.dart:135) đăng ký GetIt; HTTP/auth ở dòng 153–182, gallery ở 196–205, realtime ở 264–283. Singleton chia sẻ dịch vụ; reminder Bloc là factory ở 315–321. |
| App/UI | [cupid_app.dart](D:/App/cupidus/mobile/lib/app/cupid_app.dart:50) ghép MaterialApp, theme, locale, Splash. [app_shell.dart](D:/App/cupidus/mobile/lib/core/navigation/app_shell.dart:139) tạo các tab; Chat phụ thuộc điều kiện unlock. |
| Presentation state | [chat_cubit.dart](D:/App/cupidus/mobile/lib/features/chat/presentation/chat_cubit.dart:70) nhận repository, coordinator và user ID. State bất biến, copyWith, emit; subscription được hủy trong close. |
| Nghiệp vụ/domain | Có domain riêng theo feature, không đồng nhất toàn app. [date_script_cubit.dart](D:/App/cupidus/mobile/lib/features/date_script/presentation/cubit/date_script_cubit.dart:4) phụ thuộc cả domain date_script và activity_cards; [context_notebook_entry_point.dart](D:/App/cupidus/mobile/lib/features/context_notebook/context_notebook_entry_point.dart:65) tạo adapter và lấy repository từ GetIt. |
| Data | [chat_repository.dart](D:/App/cupidus/mobile/lib/features/chat/data/chat_repository.dart:19) phối hợp socket, REST và DAO; [gallery_repository.dart](D:/App/cupidus/mobile/lib/features/gallery/data/gallery_repository.dart:22) sở hữu API/cache; [journal_repository.dart](D:/App/cupidus/mobile/lib/features/journal/data/journal_repository.dart:20) sở hữu database/media. |
| Hạ tầng | [cupid_api_client.dart](D:/App/cupidus/mobile/lib/core/network/cupid_api_client.dart:10) tạo Dio và generated CupidApi; [cupid_database.dart](D:/App/cupidus/mobile/lib/core/database/cupid_database.dart:48) khai báo bảng/DAO, schema v11. |

Không nên đọc sơ đồ như một chuỗi phụ thuộc cứng UI → domain interface → implementation. ChatCubit import repository cụ thể và coordinator; một số entry point lấy thẳng repository. **Suy luận:** kiến trúc feature-first thực dụng, chưa có cơ sở gọi là Clean Architecture thuần.

## Bản đồ module

Các tên sau xác nhận từ thư mục `mobile/lib/features`; việc gom thành nhóm là **phân loại của người phân tích**, không phải module runtime hay dependency graph đã được chứng minh cho từng cặp.

| Nhóm phân tích | Feature |
|---|---|
| Truy cập và quan hệ | auth, onboarding, pairing, account, love_contracts, vow |
| Tương tác và đồng bộ | chat, emojis, anti_ghosting, vibes, reminders, in_app_notifications |
| Không gian chung | home, pet, timeline, gallery, dream_jar, expenses, themes |
| Nội dung và hoạt động | activity_cards, invite_composer, conversation_starters, date_script, gift_ideas, compatibility_lookup |
| Cá nhân và vòng đời | journal, context_notebook, your_view_portrait, phase_status, before_you_go, chapter_closure, zodiac, zodiac_shell |

Ngoài feature: `core` chứa auth/config/content/couple/database/di/journal/navigation/network/realtime/util; `design_system` chứa thành phần giao diện chung; `l10n` chứa bản địa hóa. `preview` và `main_preview.dart` là nhánh cần phân biệt với entry production `main.dart`; báo cáo không dùng wiring preview để khẳng định hành vi production.

Các phụ thuộc có call site rõ: app shell → ChatRepository/RealtimeCoordinator; ChatRepository → MessageDao/RealtimeCoordinator/Dio; GalleryRepository → GalleryApi/GalleryLocalCache; JournalRepository → CupidDatabase/JournalMediaStore/BackendUserIdStore. GetIt nối các đối tượng này tại composition root. Closure `resyncFetcher` trong [service_locator.dart](D:/App/cupidus/mobile/lib/core/di/service_locator.dart:264) gọi ChatRepository lúc thực thi, tránh resolve vòng ở thời điểm đăng ký.

## State được quản lý như thế nào

- **State màn hình:** ChatCubit nghe watchThread và realtime status rồi emit ChatState; có messages, initial-fetch-completed, connectionDegraded và lỗi gửi. [Nguồn](D:/App/cupidus/mobile/lib/features/chat/presentation/chat_cubit.dart:10).
- **State theo event:** ReminderScheduleBloc xử lý Started/Refresh/CRUD/Confirm/Reject và realtime event. Hydrate phát loading, gọi loadAll, phát dữ liệu hoặc failure. Thứ trong tuần được lưu qua local prefs. [Khai báo](D:/App/cupidus/mobile/lib/features/reminders/presentation/reminder_schedule_bloc.dart:121), [hydrate](D:/App/cupidus/mobile/lib/features/reminders/presentation/reminder_schedule_bloc.dart:190).
- **State dùng chung:** ThemeCubit lấy từ GetIt, BlocBuilder ở gốc app dựng lại Theme/background. VibeCubit được đăng ký singleton và session-scoped. [Theme](D:/App/cupidus/mobile/lib/app/cupid_app.dart:73), [Vibe](D:/App/cupidus/mobile/lib/core/di/service_locator.dart:288).
- **State phiên:** CupidSession giữ current state và broadcast stream; setSession lưu JWT rồi phát signed-in/token. signOut xóa token, gọi Firebase signOut, phát signed-out rồi clear từng scoped store. Đây không phải thao tác xóa toàn bộ database. [Nguồn](D:/App/cupidus/mobile/lib/core/auth/cupid_session.dart:59).
- **State bền vững:** Chat đọc stream từ Drift; journal lọc ownerUserId, từ chối đọc/ghi khi thiếu owner. Journal không dùng cùng chính sách xóa cache theo phiên: DI ghi nhận cách ly qua owner_key. [Journal](D:/App/cupidus/mobile/lib/features/journal/data/journal_repository.dart:35), [DI](D:/App/cupidus/mobile/lib/core/di/service_locator.dart:348).
- **JWT:** hiện lưu SharedPreferences; `refreshAccessToken()` chỉ gọi lại `readAccessToken()`. Không có bằng chứng refresh token qua mạng tại implementation này, dù comment ở gate dùng chữ “refresh”. [Nguồn](D:/App/cupidus/mobile/lib/core/auth/jwt_token_provider.dart:13).

**Suy luận:** state được phân quyền theo màn hình, phiên và nơi lưu dữ liệu; không có một global application state duy nhất trong các luồng đã truy vết. Cần đọc implementation và nơi đăng ký để hiểu vòng đời, không chỉ nhìn tên Cubit/Store.

## Luồng chức năng đã truy vết

1. **Khởi động và điều hướng:** main → CupidApp → Splash → SessionGateCubit. Signed-out không có lịch sử → Welcome; có lịch sử → Login phiên hết hạn. Signed-in đọc token với timeout 3 giây; timeout vẫn được coi là authenticated. Splash chờ tối thiểu 2 giây, hỏi ReturnGateResolver, rồi mở ReturnScreen hoặc PairGateShell. [Session gate](D:/App/cupidus/mobile/lib/features/auth/presentation/session_gate_cubit.dart:71), [Splash](D:/App/cupidus/mobile/lib/features/auth/presentation/screens/splash_screen.dart:116).
2. **Ghép đôi:** PairGateCubit gọi getPartnerLink một lần. Paired → AppShell; unpaired → Home solo; network/timeout → màn retry; lỗi khác → unpaired. Điểm này căn cứ switch đang chạy, không theo comment cũ nói luôn mở pairing stack. [Cubit](D:/App/cupidus/mobile/lib/features/pairing/presentation/pair_gate_cubit.dart:58), [shell](D:/App/cupidus/mobile/lib/core/navigation/pair_gate_shell.dart:130).
3. **Đăng nhập:** email/password → POST `/auth/login` → đọc accessToken/user → CupidSession.setSession → BackendUserIdStore. Nhánh Firebase gọi `/auth/firebase-login` đổi ID token sang session backend. Không thể mô tả toàn bộ auth chỉ là FirebaseAuth. [Email](D:/App/cupidus/mobile/lib/features/auth/data/auth_repository.dart:37), [Firebase](D:/App/cupidus/mobile/lib/features/auth/data/auth_repository.dart:228).
4. **Chat:** AppShell refresh partner → start coordinator → REST resync. ChatCubit nghe Drift. Gửi text → coordinator.emit(sendMessage) → ACK map → upsert DAO; thiếu ACK → resync page 1 qua GET `/messages`. Inbound newMessage cũng upsert DAO → watchThread → emit state → UI. RealtimeNotLiveFailure giữ draft và báo lỗi; không có hàng đợi gửi text offline trong nhánh này. [Shell](D:/App/cupidus/mobile/lib/core/navigation/app_shell.dart:115), [gửi](D:/App/cupidus/mobile/lib/features/chat/data/chat_repository.dart:110), [nhận/resync](D:/App/cupidus/mobile/lib/features/chat/data/chat_repository.dart:188), [Cubit](D:/App/cupidus/mobile/lib/features/chat/presentation/chat_cubit.dart:115).
5. **Realtime và lifecycle:** foreground start socket, drain pending queue và resync khi quay lại; background dùng grace timer rồi stop socket. Khi foreground, bỏ FCM để socket là nguồn chính; durable event dedup theo ID; ephemeral chỉ phát ở foreground. DI truyền socket và FCM cho coordinator. Những điều này là hành vi client, không chứng minh đảm bảo giao nhận của server. [Nguồn](D:/App/cupidus/mobile/lib/core/realtime/realtime_coordinator.dart:275).
6. **Gallery:** fetch API thành công ghi cache trang đầu; DioException trả cache với isStale=true. Upload gọi uploadFile trước, sau đó createItem; bước đầu lỗi thì không tạo item. Cache dùng SharedPreferences và không có offline write queue. [Repository](D:/App/cupidus/mobile/lib/features/gallery/data/gallery_repository.dart:28), [cache](D:/App/cupidus/mobile/lib/features/gallery/data/gallery_local_cache.dart:7).
7. **Journal:** lấy owner → import ảnh qua media store → transaction ghi entry và photo metadata; lỗi transaction thì xóa ảnh vừa import. Read trả stream theo owner. Đây là dữ liệu trên thiết bị, không được suy ra có đồng bộ server. [Nguồn](D:/App/cupidus/mobile/lib/features/journal/data/journal_repository.dart:65).
8. **Expenses:** repository gọi trực tiếp CupidApi.dio GET/POST `/expenses`, parse JSON, chặn ngày tương lai trước request và map 404 thành not-paired. Có bảng Expenses trong database không chứng minh repository này dùng cache đó. [Nguồn](D:/App/cupidus/mobile/lib/features/expenses/data/expenses_repository.dart:18).

## Điều đã biết và phần còn chưa xác minh

**Xác nhận:** các lời gọi, branch, nơi ghi dữ liệu và vòng đời nêu trên có bằng chứng code. Sơ đồ là bản đồ subsystem; phần nhóm module không tuyên bố mọi dependency giữa 34 feature đã được truy vết. Những luồng trình bày chi tiết là các luồng đại diện đã đọc implementation.

**Suy luận:** feature-first nhiều tầng; repository thường là nơi phối hợp I/O; việc phân tách nguồn authoritative theo loại dữ liệu là yếu tố kiến trúc quan trọng. Không áp dụng một chính sách offline chung cho toàn app: chat, gallery và journal có cơ chế khác nhau.

**Chưa xác minh:** hành vi runtime trên thiết bị, tích hợp backend thực tế, đầy đủ mọi tuyến onboarding và nhánh phụ của từng feature. Không khẳng định backend dùng database hay service nào từ tên package/API client.

Checkout đã có thay đổi ngoài phạm vi: `mobile/.metadata`, `mobile/pubspec.lock`, ảnh `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-032_design_system_app_shell_follow_up/visual-fidelity/ac3-vibe-header-dark-vi.png`, cùng `package-lock.json` và `skills-lock.json` chưa track. Các file đó không được dùng làm nguồn cho sơ đồ và không bị sửa bởi công việc này.

Sơ đồ đã qua validate, deliver, provenance check và browser-check tự động; chưa duyệt bằng mắt. Nội dung tiếng Việt; giao diện điều khiển Viewer dùng English fallback.
