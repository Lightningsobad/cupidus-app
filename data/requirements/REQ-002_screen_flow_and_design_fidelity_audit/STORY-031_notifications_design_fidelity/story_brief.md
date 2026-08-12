# Story Brief: STORY-031 Design Fidelity — Notifications

- Actor: any paired user configuring notification preferences.
- Capability: the Notifications screen matches the locked design source
  exactly AND no longer claims a Do Not Disturb bypass that does not exist
  in v1.
- Business value: visual/brand consistency plus accurate user expectations
  about alert behavior, avoiding a false DND-bypass promise; user directive
  is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Resolves UX memory §7's flagged DND/
  Critical-Alerts copy conflict for v1 (PO scope decision: remove the
  bypass claim, consistent with D1 — v1 ships synced reminders only, not
  real alarms). Also applies epic-3 wording rule (§6) to any synced-
  reminder references on this screen.
- Key edge/failure case: must remove/replace the "Chỉ Synced Alarm được
  phép phá Do Not Disturb" claim without implementing an actual DND-bypass
  mechanism.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; resolves UX memory §7
  conflict per PO scope decision, does not block delivery.
- Complexity and why: trivial — copy fix plus existing-pattern visual
  fidelity, no new UX/architecture decision. Lane: mobile.
- Dependencies: NONE. Shares wording rule with STORY-021 but no delivery
  dependency.
