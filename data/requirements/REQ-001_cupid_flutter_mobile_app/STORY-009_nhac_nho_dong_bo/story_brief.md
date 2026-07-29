# Story Brief: STORY-009 Nhắc Nhở Đồng Bộ

Business intent: keeps the daily-engagement reminder feature while
explicitly de-scoping the Critical Alerts/DND-override promise that D1
deliberately dropped from v1 (avoids over-promising to users).

Primary persona: paired couple, both partners.

Backend contract: `alarms` module, frozen (A1); transport name unchanged,
only user-facing copy renamed to "nhắc nhở đồng bộ" (D1, ADR-002).

Success signal: both partners receive a synced reminder, and no in-app copy
implies a system-alarm/DND-breaking guarantee that v1 doesn't provide.
