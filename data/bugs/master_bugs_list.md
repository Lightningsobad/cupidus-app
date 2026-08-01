# Master Bugs List

| Bug ID | Short Description | Status | Linked Requirement |
| --- | --- | --- | --- |
| BUG-20260801-001_app_shell_chat_gate_l10n_null | `flutter test` on the REQ-001 integration branch fails 10/882 widget tests — including the root boot smoke test — with a null-check crash in `ChatEntryGate` building inside `AppShell` (`AppL10n.of` null) | IN_PROGRESS | REQ-001_cupid_flutter_mobile_app |
