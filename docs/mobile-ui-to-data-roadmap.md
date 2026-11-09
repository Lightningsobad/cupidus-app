# Lộ trình khảo sát mobile: từ UI vào Data

Ngày lập: 07/11/2026. Phạm vi: app Flutter trong `mobile/`. Đây là kế hoạch khảo sát, không phải kết luận rằng toàn bộ luồng dưới đây đã được kiểm chứng runtime.

## Cách thực hiện mỗi màn

Đi theo chiều: điểm vào → Screen/Widget → callback người dùng → Cubit/Bloc hoặc state cục bộ → domain/service (nếu có) → repository → API/DAO/store → kết quả quay về state → UI.

1. Mở màn từ luồng production; ghi điều kiện đăng nhập, ghép đôi, quyền và feature flag. Nếu chưa chạy được app, ghi rõ chỉ đọc code.
2. Liệt kê vùng UI, thao tác và state: khởi tạo, loading, có dữ liệu, rỗng, lỗi, offline, chưa đủ quyền. Chỉ đánh dấu trạng thái tồn tại khi có code hoặc bằng chứng runtime.
3. Lần từng callback tới handler. Ghi state trước/sau, validation, subscription, timer và side effect điều hướng.
4. Theo dependency thực tế tới repository; có thể không có domain/use case riêng. Không ép mọi màn vào cùng một mẫu.
5. Theo repository tới request hoặc thao tác lưu trữ: endpoint/method/payload, parse DTO, bảng/key/file, scope user/couple, cache và nguồn dữ liệu gốc.
6. Theo đường kết quả trở lại UI: emit, stream, notify/setState, mapping lỗi, retry, rollback, stale flag.
7. Đọc nơi đăng ký tại GetIt và test liên quan để hiểu vòng đời và hành vi mong đợi. Test không thay thế implementation hay kết quả chạy thực tế.
8. Ghi dẫn chứng file:dòng cho từng kết luận; đánh dấu XÁC NHẬN TỪ CODE, QUAN SÁT RUNTIME, SUY LUẬN hoặc CHƯA RÕ.

Hoàn thành một màn khi giải thích được: vào từ đâu, thao tác gì, state do ai giữ, dữ liệu từ đâu, ghi ở đâu, thất bại ra sao, rời màn có hủy tác vụ không.

## Chặng 0 — Lập bản đồ và chuẩn bị

Đọc `mobile/lib/main.dart`, `app/cupid_app.dart`, `core/navigation/app_shell.dart`; chỉ đọc phần liên quan của `core/di/service_locator.dart` khi cần resolve một dependency.

Lập danh mục Screen, route, entry point, dialog, bottom sheet và overlay. Tìm nơi gọi mỗi điểm vào; tên file chưa chứng minh màn đó reachable. Tách `main_preview.dart`/preview khỏi luồng production. Ghi commit và trạng thái working tree ở đầu đợt khảo sát.

Đầu ra: danh mục màn, sơ đồ điều hướng sơ bộ, tài khoản/dữ liệu cần cho từng nhánh; các màn chưa truy cập được có lý do cụ thể.

## Chặng 1 — Khởi động và xác thực

Màn: Splash, Welcome, Login, Register, OTP, Forgot.

Điểm đọc: `features/auth/presentation/screens/`, SessionGateCubit, AuthRepository, CupidSession, JwtTokenProvider, auth interceptor và session termination listener.

Lần riêng đăng nhập email và đăng nhập qua nhà cung cấp; kiểm tra API thực tế, lưu token/user ID, lịch sử phiên và route sau thành công. Với Splash, lần timeout, phiên cũ, expired và return gate. Đối chiếu refreshAccessToken implementation thay vì suy từ tên hàm.

Đầu ra: bảng chuyển trạng thái phiên, bảng API auth, nơi lưu/xóa token và stack sau login/logout.

## Chặng 2 — Onboarding và ghép đôi

Màn: Permissions, Profile Setup, Pairing Choice, Invite, Scan Code, Join Code, Waiting, Paired, Love Contract, Vow.

Điểm đọc: `core/navigation/onboarding_chain.dart`, `onboarding_router.dart`, `onboarding_progress_resolver.dart`, `pair_gate_shell.dart`; các feature onboarding/pairing/love_contracts/vow.

Khảo sát hai nhánh invite và join riêng. Kiểm tra quyền camera, validation mã, polling và điểm dừng, confirm/reject nếu có, back stack và phục hồi khi mở lại app. Đối chiếu PairGateCubit với widget switch: comment có thể khác code thực thi.

Đầu ra: graph onboarding có điều kiện trên cạnh; mô tả ai sở hữu trạng thái ghép đôi, ID user/couple được lấy từ đâu.

## Chặng 3 — Home, shell và tài khoản

Màn: Home solo, Home couple, Me, Profile Edit, Notification Settings, Privacy.

Điểm đọc: `features/home/presentation/home_screen.dart`, `core/navigation/app_shell.dart`, `features/account/`.

Liệt kê mọi card/nút/tab và đích đến; kiểm tra tab nào chỉ tồn tại khi đủ điều kiện, badge unread lấy từ đâu. Theo profile edit tới request và cập nhật UI; theo notification settings tới local/server preference. Kiểm tra vòng đời khi đổi tab, không mặc định rằng state được giữ bằng IndexedStack.

Đầu ra: bản đồ điểm vào các feature còn lại; bảng state toàn app, theo phiên và theo màn.

## Chặng 4 — Một lát cắt REST đơn giản

Màn: Vibe, Expense History và sheet thêm expense.

Điểm đọc: `features/vibes/`, `features/expenses/`, `core/network/`.

Với mỗi thao tác tải/tạo: UI → Cubit → repository → Dio → parse response → state. Kiểm tra loading, empty, lỗi, retry, validation ngày/tiền và pairing gate. Ghi rõ nơi dùng generated client và nơi dùng Dio trực tiếp. Không suy có cache chỉ vì database có bảng cùng tên.

Đầu ra: một trace REST hoàn chỉnh và bảng endpoint/payload/error mapping để làm mẫu cho các chặng sau.

## Chặng 5 — Dữ liệu local và stream

Màn: Journal, Journal Composer, Notebook, Skill Profile, Activity Card Detail; cả sheet/form tạo và sửa được mở từ những màn này.

Điểm đọc: các feature journal/context_notebook/activity_cards, `core/database/`, `core/journal/`.

Theo thao tác lưu tới owner filtering, transaction, DAO và media file. Kiểm tra sửa/xóa, ảnh không đọc được, rollback và cleanup. Phân biệt dữ liệu chỉ tồn tại trên thiết bị với bản cache có thể tải lại; kiểm tra hành vi đổi tài khoản.

Đầu ra: bảng UI field → domain/model → column/file; danh sách dữ liệu gốc local và chính sách cách ly theo user.

## Chặng 6 — REST kết hợp cache và media

Màn: Timeline, Gallery, Gallery Viewer và upload sheet.

Điểm đọc: `features/timeline/`, `features/gallery/`, DAO timeline, GalleryLocalCache, widget CachedNetworkImage.

Lần đọc đầu tiên, refresh, phân trang và offline. Phân biệt cache metadata với cache bytes ảnh. Theo upload file rồi tạo record; kiểm tra lỗi ở mỗi bước, stale UI và cập nhật danh sách. Xác định cache key, phạm vi user/couple và thời điểm xóa.

Đầu ra: ma trận online/offline/cold start/cache rỗng; nguồn dữ liệu ưu tiên và cách UI biết dữ liệu cũ.

## Chặng 7 — Chat và realtime

Màn: Chat, Ghost Settings, Anti-Ghost, emoji picker/store; các overlay thông báo liên quan.

Điểm đọc: `features/chat/`, `anti_ghosting/`, `emojis/`, `core/realtime/`, MessageDao và InAppNotificationManager.

Tách các trace: tải lịch sử, gửi text, gửi ảnh, emoji, nhận tin, seen, badge unread và ghost consent/typing. Theo ACK tới DAO và stream về Cubit; kiểm tra timeout, socket không live, REST resync, dedup ID, chuyển background/foreground và đăng xuất. Phân biệt pending inbound event với offline outgoing queue.

Đầu ra: sequence cho send/receive/reconnect; bảng event → producer → consumer → state/storage; quy tắc consent và trạng thái kết nối.

## Chặng 8 — Nhắc nhở và chức năng chung

Màn: Reminder Schedule, Pet, Dream Jar List/Create/Detail, Contribution History; dialog xác nhận và overlay báo thức.

Điểm đọc: `features/reminders/`, `pet/`, `dream_jar/`, `in_app_notifications/`.

Với reminder, lần event Bloc, prefs local, server state, realtime reload, đồng thuận và firing overlay. Với Dream Jar, lần tạo/cập nhật/đóng góp/lịch sử và approval nếu có. Với Pet, lần load/action tới repository và nguồn dữ liệu thực tế. Kiểm tra tác vụ nào do server quyết định và tác vụ nào app thực thi.

Đầu ra: state machine nghiệp vụ theo feature, bảng REST/realtime/local ownership và các nhánh lỗi.

## Chặng 9 — Nội dung và cá nhân hóa

Màn/điểm vào: Theme Store/Detail, Zodiac Red Flag, Zodiac Shell, Compatibility Lookup, Gift Ideas, Conversation Starters, Date Script, Your View Portrait, Invite Composer.

Điểm đọc: presentation của từng feature → content gate/selector/renderer/repository → `core/content/` và `mobile/assets/data/` khi implementation dùng chúng.

Xác định nội dung đến từ asset, API, dữ liệu nhập hay tính toán; theo locale, phase/pairing/content gate, lựa chọn preset và việc lưu kết quả sang activity card/notebook/journal nếu có. Liệt kê dependency chéo feature từ import và call site.

Đầu ra: graph nguồn nội dung → chọn/lọc → render → hành động → đích lưu; phân biệt nội dung tĩnh và dữ liệu người dùng.

## Chặng 10 — Vòng đời, trở lại app và hoàn tất độ phủ

Màn/luồng: Return Screen, chapter closure, before_you_go, phase_status và hành vi liên quan đăng xuất/xóa dữ liệu. Một số module không có Screen độc lập: tìm consumer widget/service của chúng.

Theo return gate và thao tác closure tới dữ liệu đọc/ghi/xóa thực tế. Kiểm tra scoped store teardown, local archive, timer/subscription, app restart và đổi tài khoản. Với xóa dữ liệu, chỉ thực hành trên fixture/tài khoản thử nghiệm.

Đối chiếu danh mục chặng 0 với các route, entry point, dialog/sheet/overlay và test. Đánh dấu: đã đọc đủ đường dữ liệu, đã chạy, chưa chạy hoặc chưa reachable; mọi màn còn sót phải có trạng thái. Khảo sát backend tiếp từ endpoint nếu repository có source backend và cần hiểu cả hệ thống.

Đầu ra: ma trận độ phủ, dependency map tổng hợp và danh sách câu hỏi còn mở có file/call site liên quan.

## Phiếu khảo sát dùng cho từng màn

```text
Màn / route / commit:
Điểm vào và điều kiện mở:
File UI + dòng:
Vùng giao diện và thao tác:
Callback → handler:
State owner / vòng đời / initial state:
Loading / success / empty / error / offline:
Domain/service (nếu có):
Repository và đăng ký DI:
API: method + path + payload + parse + failure:
Local: table/key/file + owner scope:
Nguồn dữ liệu gốc / chính sách cache:
Kết quả → state → UI:
Side effect: navigation / notification / timer / subscription:
Rời màn / logout / account switch:
Test liên quan và kết quả đã chạy:
Xác nhận từ code (file:dòng):
Quan sát runtime:
Suy luận:
Chưa rõ / bước kiểm chứng tiếp:
```

## Nhịp học gợi ý

Mỗi phiên tập trung một thao tác xuyên suốt; chỉ mở rộng sang thao tác tiếp theo sau khi lần được cả đường dữ liệu đi và đường kết quả về. Dành một phiên tổng hợp sau mỗi 2–3 chặng. Tách thời gian đọc hiểu khỏi thời gian sửa bug; ghi phát hiện vào backlog để giữ mạch khảo sát.

Tiêu chí kết thúc toàn dự án: mỗi bề mặt UI có phiếu hoặc trỏ tới phiếu chung; mỗi thao tác chính có trace tới I/O hay phép tính cuối cùng; mỗi dependency chéo feature có call site; mỗi state lưu bền có owner và chính sách cleanup; các phần chưa kiểm chứng được ghi rõ.
