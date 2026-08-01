# Master Bugs List

| Bug ID | Short Description | Status | Linked Requirement |
| --- | --- | --- | --- |
| BUG-20260801-001_app_shell_chat_gate_l10n_null | `flutter test` on the REQ-001 integration branch fails 10/882 widget tests — including the root boot smoke test — with a null-check crash in `ChatEntryGate` building inside `AppShell` (`AppL10n.of` null) | FIX_APPLIED — awaiting review | REQ-001_cupid_flutter_mobile_app |
| BUG-20260801-002_test_harness_getit_registration_gaps | Test-harness GetIt registration gaps (`CouplePairingStore`, `ChatPartnerStore` not registered) crash `widget_test.dart` (readiness gate), `feature_flags_test.dart`, `app_shell_test.dart`, `gallery_cubit_test.dart`, `reminder_entry_point_test.dart` | PENDING | REQ-001_cupid_flutter_mobile_app |
| BUG-20260801-003_anti_ghost_entry_card_l10n_null | Same `AppL10n.of` null-check crash pattern as BUG-20260801-001, in `_AntiGhostEntryCardChrome`; crashes `vibe_screen_test.dart`, `pet_entry_point_test.dart` | PENDING | REQ-001_cupid_flutter_mobile_app |
