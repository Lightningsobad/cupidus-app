# Story Brief: STORY-021 Design Fidelity — Synced Reminder

- Actor: any paired user setting/receiving a shared synced-reminder time.
- Capability: the screen matches the locked design source's visual pattern
  exactly AND uses correct "nhắc nhở đồng bộ" wording, never "báo thức"/
  "alarm"/"Synced Alarm".
- Business value: visual/brand consistency plus compliance with the D1
  product rule (v1 ships sync reminders only, not real device alarms); user
  directive is 100% match, not best-effort.
- Key business rules: copy-only rename per UX Memory §6 — interaction
  pattern is correct as designed, not redesigned. Backend/transport naming
  (`alarms`, `TRIGGER_ALARM`) may keep its name; only UI copy changes.
- Key edge/failure case: must not introduce full-screen system-alarm visual
  treatment or DND-bypass implication while fixing wording.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — copy-only rename plus existing-pattern
  visual fidelity, no new UX/architecture decision. Lane: mobile.
- Dependencies: NONE. Related wording rule also applies to STORY-031
  Notifications (mentions Synced Reminder), but no delivery dependency.
