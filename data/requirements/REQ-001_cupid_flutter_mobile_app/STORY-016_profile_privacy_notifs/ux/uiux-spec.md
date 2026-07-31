# UX Spec: STORY-016 Epic-6 — Profile / Privacy / Notifications (mobile-only)

Scope: REQ-001 / STORY-016_profile_privacy_notifs
Source of truth: `cupid-mobile-design/Cupid Screens.dc.html` screen ids `me`,
`privacy`, `notifs` (epic-6 "Tài khoản" group, per system UX memory §4/§9).
Tokens/components reused verbatim from STORY-001
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/ux/uiux-spec.md`).
Sign-out behavior is already fully specified in STORY-003's UX spec §5 and
system UX memory §11 — this spec references its placement only, it does not
redefine sign-out.

## 1. Screen Inventory

| Screen id | Purpose | Chrome |
|---|---|---|
| `me` | Account hub: profile summary card + settings menu | header (title "Tôi"/"Me"), tab bar (account tab active) |
| `me` (edit sub-state) | Profile view/edit (AC1) — new sub-screen, not separately id'd in the design source | header (back + "Lưu"/"Save" action), no tabs (drill-in) |
| `privacy` | "Dữ liệu của tôi"/"My data" — 3-tier privacy model + controls (AC2) | header (back + title), no tabs (drill-in) |
| `notifs` | "Thông báo"/"Notifications" — grouped toggle list (AC3) | header (back + title), no tabs (drill-in) |

These are drill-in screens off the "me" tab inside the main 5-tab app shell
(distinct from the onboarding `NO_CHROME`/`NO_TABS` group per system UX memory
§4) — header (back chevron iOS / back arrow Material + title) is always
present; tab bar hides only while drilled into `privacy`/`notifs`/profile-edit,
matching the existing drill-in precedent used elsewhere in the design source
(e.g. `expense`, `ghostset`).

## 2. Flow Map

```
me (hub)
  -> tap avatar / edit pencil on profile card -> profile edit sub-screen (§3)
       -> Save -> back to me (hub), values updated
       -> back (no save) -> me (hub), unchanged
  -> tap "Dữ liệu của tôi" row -> privacy screen (§4) -> back -> me
  -> tap "Thông báo" row -> notifs screen (§5) -> back -> me
  -> "Typing Ghost" row -> ghostset (owned by another story, §6)
  -> "Love Contract" row -> contract (owned by another story, §6)
  -> "Ngôn ngữ"/Language row -> language picker (open item, §7.4)
  -> sign-out control -> per STORY-003 §5 (not redefined here)
```

## 3. Profile View/Edit (AC1)

Base: the `me` hub's existing profile summary card (design source lines
865-871) — circular avatar with camera badge, display name (Nunito 900/21px),
zodiac icon + label + DOB caption row, trailing edit pencil icon. Keep this
card exactly as designed for the hub's *view* state.

New: tapping the edit pencil (or the card itself) opens a profile-edit
sub-screen. Reuse the field-card visual pattern from the onboarding `isProfile`
screen (design source lines 93-116) but convert it from display-only to
editable, wrapped in this story's header chrome (back arrow, title "Chỉnh sửa
hồ sơ"/"Edit profile", "Lưu"/"Save" as a header action):

- **Avatar**: same circular image-slot + camera badge; tap opens the photo
  picker/crop flow (reuse the onboarding avatar-upload interaction as-is).
- **Display name**: convert the existing read-only value card into an
  editable text field, keeping the exact card style (`surf` background,
  `r-card` radius, uppercase 11px label above a 17px/600 value) — becomes a
  real text input, not a static label.
- **Date of birth**: convert to an editable date-picker control (tap opens a
  native/date-wheel picker), keeping the existing card layout including the
  inline auto-derived zodiac chip (chip updates live as DOB changes — zodiac
  itself is never directly editable; keep the existing helper caption "Zodiac
  is auto-derived — powers Zodiac Red Flag").
- **Save**: header "Save" action, disabled until at least one field changes;
  inline validation (e.g. name non-empty, DOB required) with inline error text
  under the relevant field — reuse the exact inline-field-error pattern from
  STORY-003 §6, do not invent a new error style.
- **Language row**: the onboarding `isProfile` screen shows an identical
  "Ngôn ngữ"/Language chevron row (lines 112-115) alongside name/DOB. Do not
  assume this is a `users`-module profile field — see open item §7.4.

## 4. Privacy Settings (AC2)

The existing design (`isPrivacy`, lines 889-925) is a 3-tier informational
explainer:
- **Level 1** (device-only, AES-256/Secure Enclave): Typing Ghost, Private
  Gallery, Messages.
- **Level 2** (server, end-to-end encrypted): Dream Jar, Love Timeline, Vibe
  Check.
- **Level 3** (standard server, TLS 1.3): Profile, Love Pet stats, "Alarm
  settings" (renamed per system UX memory §6).

Keep these three cards verbatim as informational content — this satisfies the
*view* half of AC2 with no visual changes needed.

**Gap flagged, not silently resolved (view-vs-change gap):** the existing mock
has no editable privacy toggle anywhere on this screen — it is read-only info
plus a data-export button. AC2 requires the user can "view and change privacy
settings exposed by the backend contract," and story_master itself flags the
`users` endpoint mapping as unverified, so this spec cannot invent specific
fields (e.g. "hide profile from partner's contacts") without a confirmed
contract. Recommended structure once Tech Lead confirms which fields exist:
add a 4th card below the tier cards, titled "Kiểm soát"/"Controls", reusing
the toggle-row visual already established on the `notifs` screen (leading
label + sublabel, trailing pill toggle — `--grad-hot` fill when on,
`--surf2`/`--line` track when off) — one row per backend-exposed privacy
field. If the contract exposes zero user-editable privacy fields, escalate to
Product Owner: AC2 as written would be unsatisfiable and should be revised to
view-only, rather than this spec inventing a field that doesn't exist.

**Data-export conflict — explicit escalation, not resolved here:** the design
source's `privacy` screen includes an "Xuất toàn bộ dữ liệu"/"Export all my
data" button plus a PDPA-compliance caption (lines 923-924). System UX memory
§8 previously read this as "relevant to epic-6 mobile-visible scope, not the
out-of-scope admin/data-export backend modules" — but STORY-016's own Out of
Scope section and AC4 explicitly exclude "any data-export... module entirely"
and "no admin- or data-export-specific screen/action... in this story's
scope." These two statements conflict. **This spec excludes the export button
from the v1 build of this screen** to satisfy AC4 literally, and flags this
for Product Owner/Tech Lead (see §7.3): confirm whether "export all my data"
is genuinely out of v1 scope (in which case system UX memory §8 needs
correcting) or was wrongly bundled into this story's exclusion list (in which
case AC4 needs an explicit carve-out and the button should ship). Do not
silently add or silently drop this button without that decision being
recorded.

## 5. Notification Settings (AC3)

The existing design (`isNotifs`, lines 928-955) is a complete, implementable
grouped toggle list:
- Top banner (amber/pink gradient card): usage-cap copy.
- **CRITICAL** group (peach dot label): 2 toggle rows (`notifCritical`).
- **ENGAGEMENT** group (pink dot label): 3 toggle rows (`notifEngage`).
- **INFO** group (muted/ghost dot label): 2 toggle rows (Dream Jar milestone,
  Love Timeline "on this day").

Keep this structure and visuals verbatim — each row already has the full
pattern (leading icon, title, sublabel, trailing pill toggle at
`--tap`-compliant size).

**Compliance flag, already known — do not silently implement:** the banner
copy "Chỉ Synced Alarm được phép phá Do Not Disturb"/"Only Synced Alarm may
break Do Not Disturb" is the exact DND/Critical-Alerts conflict already
recorded in system UX memory §7 (conflicts with D1's "no Critical Alerts
entitlement" decision). That conflict is explicitly this story's own
Out-of-Scope note: it belongs to STORY-009 (the Notifications *feature*
copy/behavior), not this settings surface. **Action for this spec**: keep the
banner's numeric cap copy ("Max 15 pushes/day") since that is a
settings-surface fact, but do not hard-code the "Only Synced Alarm may break
DND" clause into this build — Mobile Dev should treat that clause as pending
copy sourced from STORY-009's resolution, not something to ship verbatim here.

## 6. Explicit Exclusions (AC4)

The `me`/`privacy`/`notifs` screens built for this story must NOT include, for
v1:
- The "Digital Divorce" menu row shown in the existing `me` mock (lines
  882-884) — confirmed out of scope, Phase 1.5, per system UX memory §10.
  Omit this row entirely (don't ship it disabled/greyed — omit it, so no
  admin-adjacent surface exists anywhere in this story's scope).
- Any admin-module screen or action (none exist in the design source for this
  story's scope, consistent with req_master).
- The "Export all my data" action — see §4's flagged conflict; excluded
  pending an explicit PO/Tech Lead decision.

Two existing `me`-screen menu rows are **navigation entries only, not this
story's screens to design**: "Typing Ghost" (→ `ghostset`, owned by the
epic-2 consent/settings story) and "Love Contract" (→ `contract`, owned by
the epic-1 pairing stories). Keep both rows as forward links in the `me` hub
menu; this spec does not redesign either target screen.

## 7. Open Items For Downstream Roles

1. Tech Lead: confirm the exact `users` module endpoint mapping for profile
   view/edit, privacy settings, and notification settings (per
   story_master's own flag) — escalate to Scrum Master if any screen above
   implies an endpoint the contract doesn't have.
2. Tech Lead/PO: resolve the AC2 "view and change privacy settings" gap in
   §4 — identify the actual backend-exposed editable privacy field(s), or
   formally revise AC2 to view-only if none exist.
3. PO/Tech Lead: resolve the data-export conflict in §4 (system UX memory §8
   vs. this story's explicit AC4 exclusion) — confirm whether the export
   button ships in this story or is genuinely deferred, and correct whichever
   source (system UX memory §8 or this story's scope) is wrong.
4. Tech Lead: confirm whether "Ngôn ngữ"/Language (design source lines
   112-115, appearing identically in onboarding `isProfile` and in the `me`
   hub menu) is a `users`-module persisted field or a client-only locale
   preference (relates to open OQ5 i18n scope) — determines whether §3's
   profile-edit screen should include it as a form field, or whether it
   belongs on a separate app-preferences surface outside this story's field
   set.
5. Mobile Dev/Tech Lead: the notifications banner's DND-bypass clause (§5)
   must stay unimplemented until STORY-009 resolves the Critical Alerts
   conflict (system UX memory §7) — treat as pending copy only, not a v1
   behavior.

## Completion

UX_COMPLETE: YES

All four ACs have a corresponding UX specification: AC1 (§3, profile
view/edit built from the onboarding field-card pattern, converted to
editable inputs), AC2 (§4, existing 3-tier info kept verbatim as the view
half; an editable "Controls" section is specified as a pattern but flagged
pending Tech Lead's endpoint confirmation before implementation), AC3 (§5,
existing toggle-list design reused as-is; DND-bypass clause flagged pending
STORY-009), AC4 (§6, explicit exclusion list: Digital Divorce, admin,
data-export). Two conflicts are escalated rather than silently resolved:
AC2's "change" requirement against an info-only mock, and the data-export
button's presence in the design source against this story's explicit
exclusion. Neither blocks Tech Lead from starting solutioning on the
non-conflicting parts of this spec (profile edit, notification toggle list,
3-tier info display).
