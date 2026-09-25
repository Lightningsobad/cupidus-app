# Scope Gate — STORY-012 (lượt S8, tái review sau rework P9–P12)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `full-story-review` (tái review sau `PATCH_REQUIRED` của lượt S7)
Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/review/review-report.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
BaseHead (handoff): `b58afbe073eff4e1ebb9151735221532a9cf5a82`

## Quyết định phạm vi: dùng mốc rework, không dựng lại toàn diff P1–P12

Handoff đề nghị đọc toàn bộ diff `b58afbe0..HEAD`. Diff đó là **107 tệp /
18 671 dòng thêm**, vượt xa ngưỡng 12 tệp của `full-story-review` (SKILL rule
1c). Nhưng lượt này **không** phải review lần đầu: hồ sơ đã có 7 lát cắt đã
duyệt (`slice-S1.md`…`slice-S6b.md`) và một tổng hợp S7 với
`Outcome: PATCH_REQUIRED`, đã commit ở `322c4276`.

Vì vậy phạm vi lượt này = **delta kể từ mốc tổng hợp S7**, tức
`git -C <Worktree> diff 322c4276..HEAD`: 51 tệp, trong đó **20 tệp
source/test/config**. Ba finding chặn của S7 (C-1, C-2, C-3) được kiểm lại
trực tiếp trên delta này; những gì S1–S6b đã phủ và rework không chạm tới thì
kế thừa kết luận cũ, không đọc lại.

Không dùng `Reviewer: final-synthesis` vì rework đã sinh mã sản phẩm mới
(P9/P10/P11/P12) mà chưa lát cắt nào chấm.

## Source/Test Files In Scope

(20 tệp source/test/config)

Native/widget:
1. `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt` (+87)
2. `mobile/android/app/src/main/res/drawable/dot_today_bolt.xml` (+18, mới)
3. `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml` (+48/-)
4. `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift` (+197)
5. `mobile/ios/Runner/Info.plist` (+13) — kiểm C-3

Dart/nội dung:
6. `mobile/lib/features/phase_status/data/home_widget_bridge.dart` (+17)
7. `mobile/lib/features/phase_status/domain/phase_content.dart` (+10)
8. `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart` (+479)
9. `mobile/lib/features/phase_status/presentation/phase_status_line.dart` (+15)
10. `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart` (+75)
11. `mobile/lib/features/activity_cards/presentation/widgets/activity_card_tile.dart` (+334)
12. `mobile/assets/data/req016/phase_content.v1.json` (+9)
13. `mobile/lib/l10n/arb/app_vi.arb` (+20), 14. `app_en.arb` (+7)

Test:
15. `test/features/phase_status/native_copy_scan_test.dart` (+256)
16. `test/features/phase_status/evening_check_in_sheet_test.dart` (+159)
17. `test/features/phase_status/home_widget_bridge_test.dart` (+50)
18. `test/features/phase_status/phase_content_gate_test.dart` (+50)
19. `test/features/phase_status/phase_status_line_test.dart` (+59)
20. `test/features/activity_cards/activity_type_test.dart` (+7/-)

## Evidence Files In Scope

- `coding-plan/test-results.md` — chỉ các mục: `## Entry Point Reachability`,
  `## Story Runtime Startup Smoke`, `## P9`, `## P10`, `## P11`,
  `## P12` (cả hai lượt). Tệp 133 KB → chỉ đọc theo dải.
- `visual-fidelity/visual-fidelity-report.md` — chỉ: dòng 1–3 verdict, mục
  "Đặt cặp ảnh", "Tổng kết delta", "Tồn dư đã ghi", "Lượt patch #3 — D-10",
  "Lượt P12". Tệp 47 KB → chỉ đọc theo dải.
- `visual-fidelity/*.png` — **phải mở ra soi bằng mắt** (rule 12e3), tối thiểu
  cặp ô 7 (`implemented-widget-date-day.png` ↔
  `design-reference-sb-84-widget-bon-pha-ios.png`) và cặp ô 1
  (`implemented-hub-waiting.png` ↔
  `design-reference-ngan-da-hen-ngay-dang-doi-ios.png`).
- `review/review-report.md` (bản S7) — chỉ mục "Cổng quyết định" và
  "Danh sách finding hợp nhất".
- `story_master.md` (8,6 KB) — đọc đủ: AC1–AC9, Lane, Complexity,
  Design-Surface/Design-Screen.
- `coding-plan/master-plan.md` — chỉ bảng Phases Overview.
- `deployment/configuration-guide.md` (+29) — kiểm rule 12a.

Hai artifact lớn > 20 KB đã dùng (đúng hạn mức 2 của `full-story-review`):
`coding-plan/test-results.md` và `visual-fidelity/visual-fidelity-report.md`.

## Bề mặt rủi ro đã chạm và cổng tối thiểu

| Bề mặt rủi ro | Cổng tối thiểu | Nguồn bằng chứng |
|---|---|---|
| mobile interaction / navigation & discoverability | Entry point có thật trong mã + `Reachable: YES` | `test-results.md` §Entry Point, `AndroidManifest.xml` receiver, chạm widget → MainActivity (P12 §4) |
| app lifecycle + build native Android | `flutter build apk --flavor local` xanh, cài + khởi chạy | P12 lượt khắc phục §2/§3 |
| permissions / device API (local notification) | test đơn vị guard + thu hẹp import | P6 §7/§8, `reminder_copy_guard_test.dart` |
| local storage (SharedPreferences payload widget) | round-trip 6 khoá đọc lại trên thiết bị | P12 §3 |
| typed/generated contract (payload 5→6 khoá) | test hợp đồng + đối chiếu native | P9, `home_widget_bridge_test.dart` |
| deep link (`cupidapp://`) | scheme đăng ký + chạm widget mở app | `Info.plist`, P12 §4 |
| **design fidelity (rule 12e2/12e3)** | ảnh implemented + reference, verdict `VISUAL_FIDELITY` | `visual-fidelity/` |
| operational command (registry buildCommand) | lệnh registry chạy được | lệch đã ghi, chủ DevOps |

## Query Keys

(query key cho Phase 2)

`AC9`, `AC-37`, `BR-15`, `VISUAL_FIDELITY`, `R-1`, `R-3`, `R-4`, `R-6`, `R-7`,
`R-8`, `D-13`, `C-1`, `C-2`, `C-3`, `CFBundleURLTypes`, `cupidapp`,
`eyebrow_line`, `dot_today_bolt`, `ContextCompat`, `ANDROID_RESOURCE_PARSE_FAILED`,
`Entry Point Reachability`, `Story Runtime Startup Smoke`.

## Phase 2 được tiếp tục?

CÓ. Không có input thượng nguồn nào thiếu. Phạm vi đã thu về mốc rework và nằm
trong hạn mức `full-story-review`.
