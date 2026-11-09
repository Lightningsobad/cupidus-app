import json
from pathlib import Path

folder = Path('.archify/architecture-flutter-20261103-120000')
def source(path, line, end):
    return {'path': 'mobile/lib/'+path, 'line':line, 'end_line':end}
def node(id, type, label, sub, x, y, sources):
    return dict(id=id,type=type,label=label,sublabel=sub,pos=[x,y],size=[240,76],sources=sources)
nodes = [
node('boot','backend','Khởi tạo & DI','main → Firebase → GetIt',40,40,[source('main.dart',17,26),source('core/di/service_locator.dart',135,182)]),
node('ui','frontend','App & điều hướng','Splash / pair gate / tab shell',40,235,[source('app/cupid_app.dart',50,107),source('core/navigation/pair_gate_shell.dart',130,146),source('core/navigation/app_shell.dart',115,175)]),
node('state','frontend','State theo feature','Cubit / Bloc / stream',440,235,[source('features/chat/presentation/chat_cubit.dart',70,106),source('features/reminders/presentation/reminder_schedule_bloc.dart',121,140)]),
node('repos','backend','Repository & nghiệp vụ','Chat / Gallery / Journal / Expenses',840,235,[source('features/chat/data/chat_repository.dart',19,33),source('features/gallery/data/gallery_repository.dart',31,64),source('features/journal/data/journal_repository.dart',65,123)]),
node('session','security','Phiên đăng nhập','JWT + Firebase; xóa store theo phiên',440,40,[source('core/auth/cupid_session.dart',59,119),source('features/auth/data/auth_repository.dart',37,65),source('features/auth/data/auth_repository.dart',228,252)]),
node('realtime','messagebus','RealtimeCoordinator','Socket / FCM / dedup / resync',840,40,[source('core/di/service_locator.dart',264,283),source('core/realtime/realtime_coordinator.dart',275,290),source('core/realtime/realtime_coordinator.dart',325,364)]),
node('local','database','Dữ liệu trên thiết bị','Drift + media + cache gallery',840,440,[source('features/chat/data/chat_repository.dart',64,72),source('features/journal/data/journal_repository.dart',90,123),source('features/gallery/data/gallery_repository.dart',31,48)]),
node('http','backend','HTTP adapter','CupidApi / Dio + interceptor',440,440,[source('core/network/cupid_api_client.dart',10,25),source('features/expenses/data/expenses_repository.dart',18,55),source('features/chat/data/chat_repository.dart',188,197)]),
node('server','external','API cấu hình ngoài app','Đích gọi REST; nội bộ ngoài phạm vi',40,440,[source('core/network/cupid_api_client.dart',13,25)])
]
edges=[('boot','ui','runApp'),('boot','session','đăng ký'),('ui','state','tạo / render'),('state','repos','gọi'),('repos','realtime','emit / events'),('repos','local','đọc / ghi'),('repos','http','REST'),('http','server','request')]
cards=[
dict(dot='cyan',title='XÁC NHẬN • Các tầng',items=['Presentation gọi repository cụ thể; ChatCubit còn nghe coordinator.status.', 'GetIt là composition root; singleton và factory có vòng đời khác nhau.', 'Mũi tên thể hiện lời gọi/phụ thuộc; stream phát ngược về UI.']),
dict(dot='emerald',title='XÁC NHẬN • Luồng chính',items=['Splash: chưa đăng nhập → Welcome; phiên hết hạn → Login; đã đăng nhập → return gate → pair gate.', 'Pair gate: paired → AppShell; unpaired → Home solo; lỗi mạng → retry.', 'Chat: socket ACK → upsert Drift → watchThread → emit UI; ACK thiếu → REST resync.', 'Gallery: upload file rồi tạo item; đọc lỗi mạng → cache có isStale.']),
dict(dot='violet',title='Module theo thư mục • nhóm do người phân tích đặt',items=['Truy cập: auth, onboarding, pairing, account, love_contracts, vow.', 'Tương tác: chat, emojis, anti_ghosting, vibes, reminders, in_app_notifications.', 'Đời sống chung: home, pet, timeline, gallery, dream_jar, expenses, themes.', 'Nội dung/cá nhân: activity_cards, journal, context_notebook, invite_composer, conversation_starters, date_script, gift_ideas, compatibility_lookup, your_view_portrait, zodiac, zodiac_shell, phase_status, before_you_go, chapter_closure.']),
dict(dot='amber',title='SUY LUẬN & giới hạn',items=['Có thể gọi đây là kiến trúc feature-first nhiều tầng; không đủ cơ sở gọi Clean Architecture thuần.', 'Các nhóm module là phân loại phân tích, không phải boundary runtime được code khai báo.', 'Không suy diễn nội bộ backend, độ bền server hay đảm bảo giao nhận từ client.', 'Bản đồ ở mức subsystem; báo cáo kèm theo giải thích state và dẫn chứng chi tiết.', 'Nội dung tiếng Việt; Viewer dùng giao diện English fallback.'])]
data=dict(schema_version=1,diagram_type='architecture',meta=dict(title='Cupid Flutter — tầng, module và phụ thuộc',locale='vi',output=folder.as_posix()+'/flutter-architecture.html',quality_profile='showcase',repository=dict(url='https://github.com/snapsofts/cupidus',revision='f0b7b03c3a57cdb9974840d267d8c63a1928af7e')),components=nodes,connections=[dict(id='edge'+str(i),**{'from':a,'to':b},label=l) for i,(a,b,l) in enumerate(edges)],cards=cards)
(folder/'candidate.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')

