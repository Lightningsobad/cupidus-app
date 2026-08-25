# Review Report — REQ-012 / STORY-002 Create-Code (Couple Types) Screen QR Display

Outcome: PATCH_REQUIRED

Reviewer: Iris-QC (compact-story-review, pass 2)
Date: 2026-08-26
Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-002_create_code_couple_types_screen_qr_display`
Pass-1 base: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b` → pass-1 verdict PATCH_REQUIRED (B1–B4)
Pass-2 BaseHead: `8a10f04f3cf6db75643aa31f199c89488d6f972c`
Rework delta reviewed: `89860c9..8a10f04` (`fbbf1ef` mobile-dev evidence, `8a10f04` Scrum-Master `Design-Screen` field)

**Three of four findings are closed. One remains, and it is the only reason this
is not CLEAN.** No production, test, or design-system source changed in the
rework — the delta is 6 files, all evidence artifacts plus two `.png` captures.

## Scope Gate

- Review type: `compact-story-review`, pass 2 (no separate `scope-gate.md`, skill rule 5a).
- Files in scope (evidence only — source re-read was neither needed nor permitted by the handoff):
  `visual-fidelity/visual-fidelity-report.md`, `visual-fidelity/design-reference-invite-android.png`,
  `visual-fidelity/implemented-invite-emulator-5554.png`, `coding-plan/test-results.md` (new sections only),
  `story_master.md` (header + Artifacts diff).
- Query keys: `VISUAL_FIDELITY`, `Design-Screen`, `Entry Point Reachability`, `Story Runtime Startup Smoke`, `Implementation Lane`, `moduleInk`.
- Retro gate (rule 1a): re-checked at pass 1 — all 29 `RWB-*` rows `RESOLVED`/`DONE`, nothing blocks.

## Pass-1 Findings — Disposition

| Id | Verdict | Basis |
| --- | --- | --- |
| B1 rendered design-fidelity evidence | **CLOSED** | See below — verified by opening both images, not by counting files. |
| B2 `## Story Runtime Startup Smoke` | **STILL OPEN** | See "Remaining Blocking Finding". |
| B3 `## Entry Point Reachability` | **CLOSED** | Section present in `coding-plan/test-results.md` with `Reachable: YES`. I re-verified the claim in code at pass 1 independently (`pairing_choice_screen.dart:39` pushes `InviteScreen`); the record now also names the CTA wiring at `:102` and the exercising test. It correctly excludes the `cupidpreview://screen/invite` deep link from the reachability claim — that distinction is the part a weaker record would have blurred. |
| B4 `Design-Screen: TBD` | **CLOSED** | `story_master.md` now records `Design-Screen: invite`, resolved via `--list-screens` + rendered-reference match. The reference I opened does depict that screen. |
| D3 lane mislabel (deferred) | **APPLIED** | `Implementation Lane: shared` → `mobile`. Confirmed in the diff. |

## B1 — Verified, Including The Part Only The Images Can Prove

`visual-fidelity/visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS` with
a real comparison behind it: named screen, named device, named state, a 22-row
per-element table, a 5-row pixel-measured geometry table, and seven enumerated
deltas with ownership. Both PNGs exist and open as real images.

I opened both. What I see does not contradict the `PASS`:

- `design-reference-invite-android.png` **is the `invite` screen** of the locked
  canvas — header "Ghép đôi", placeholder QR art, "Đang đợi Linh quét…" pill,
  `CPD-8F2K`, "Gửi link mời" + copy, "Giả lập: Linh vừa vào", then the
  "Tụi mình thuộc kiểu nào?" grid with "Cùng thành phố" selected. Right screen,
  not a neighbour, not a placeholder.
- `implemented-invite-emulator-5554.png` shows **this story's screen in the built
  app**: a real scannable QR with the gradient heart badge centred on it, the
  same `CPD-8F2K` in gradient mono below, the share/copy row, and the 4-card
  picker with "Cùng thành phố" selected. Not an error screen, not a spinner, not
  a blank or wrong frame. Same loaded state as the reference.

The strongest part of this evidence is that it is machine-checked rather than
asserted: `CIDetectorTypeQRCode` over the *delivered downscaled screenshot*
returns `DECODED: CPD-8F2K`, byte-identical to the text code in the same frame —
AC1 and AC2 now confirmed at render level, on device, **through the badge
occlusion**, which no widget test could reach. The same detector over the design
reference returns `NO_QR_FOUND`, which is the proof (not the excuse) that the
canvas art is a non-encoding placeholder. Paper box measured 182x177 px in both
images independently.

The discarded first capture (deep link raced a cold `am start` and landed on the
preview index) was disclosed and excluded rather than quietly reshot. That
disclosure is worth more than the frame it replaced.

AC5: **PASS**.

## Remaining Blocking Finding

### B2 — `## Story Runtime Startup Smoke` is still absent
Owner: `devops` (not `mobile-dev`)

`coding-plan/test-results.md` has no `## Story Runtime Startup Smoke` section,
and `story_master.md` records no `Runtime-Smoke: WAIVED — <reason>`. Reviewer
rule 12g makes this a mandatory story-level gate for a non-trivial `mobile`-lane
story; for this lane it is that the app LAUNCHES on the provided device and
reaches its first screen without a crash or error screen.

I am recording this as blocking rather than deferred, and the reason is
mechanical, not procedural stubbornness:

1. **`DEFERRED_ONLY` asserts "story can close."** It cannot. `validate-done-gate.sh`
   enforces the runtime-smoke gate independently of this report, so a
   `DEFERRED_ONLY` here would hand Scrum Master a green light that the DONE gate
   rejects seconds later — a wasted cycle plus a false signal in the artifact
   record. `PATCH_REQUIRED` is the outcome that describes the actual state.
2. **Rule 12g's own branch points here.** It is `PATCH_REQUIRED` "when DevOps can
   still supply it", `BLOCKED` only when environment/credentials/dependencies
   prevent it. `guard-broad-handoff.sh` blocked routing emulator work through
   *`mobile-dev`* — correctly, that is not mobile-dev's lane. It did not block
   `devops`, and the emulator is already booted and provided. Nothing prevents
   the gate; it simply has not been routed to the role that owns it.
3. **Rule 12c** forbids recording `DEFERRED_ONLY` for a gate that is primary
   proof of changed behaviour. This story adds a first-party runtime dependency
   (`qr_flutter`) and an `AnimationController` that repeats indefinitely on a hot
   path. "Does it still boot" is a real question here.

The implementer handled this honestly and should not be asked to redo anything:
`test-results.md` §7 explicitly labels the preview-APK launch as "supporting
context only, not as that gate". That labelling is correct and matters — this
repository has direct precedent that a `main_preview.dart` capture does not
satisfy the gate on the shipped entrypoint (`RWB-20260816-027` / STORY-059 took
a round-1 `PATCH_REQUIRED` on exactly this substitution).

**Action:** route one `devops` handoff for a registry-backed runtime startup
smoke on the **shipped** entrypoint (`lib/main.dart`, not `main_preview.dart`),
recorded as `## Story Runtime Startup Smoke` in `coding-plan/test-results.md` —
or have Scrum Master record `Runtime-Smoke: WAIVED — <reason>` in
`story_master.md` if that is the deliberate call. Either closes the story; this
is the last item.

## Deferred Findings

| Id | Finding | Disposition |
| --- | --- | --- |
| D5 | `QrPalette.moduleInk` `#000000` vs the canvas placeholder's `#2A1E4A` dots | **DEFERRED — confirmed non-blocking, agreeing with the implementer's own framing.** The canvas `{{ qrArt }}` is procedural PRNG art (`Cupid Screens.dc.html:1999-2025`, `seed = 58291`) that encodes nothing — independently confirmed by `NO_QR_FOUND` on the reference. A non-encoding decorative placeholder does not carry a valid module-colour spec for a real QR, so AC5's colour clause has nothing here to fail against, and rule 14's "no substitutes" bar is not engaged. Max contrast is a legitimate functional reason for a code meant to be scanned. It changes no layout, no spacing, and no `CupidColorTokens` entry. Correctly left untouched inside an evidence-only rework scope; available as a follow-up if the canvas hex is later preferred. |
| D6 | Couple-type card *hint* copy also differs (`Bật cảm giác hiện diện` / `Ưu tiên gamification` vs `Tụi mình đang ở hai nơi khác nhau` / `Tụi mình ở cùng một thành phố`), which taller cards follow from | DEFERRED (doc precision) — same REQ-009 "Out of Scope" card-content class as delta 6, which says "with their hints" but spells out only the two labels. Visible in both frames I opened. Not a new defect and not this story's to change; noting it so a later reader is not surprised by an undocumented-looking difference. |
| D1 | `no_fork_guard_test.dart` RED (`pet_preview_card.dart:229-230`) | DEFERRED — unchanged, pre-existing at BaseHead, tracked as `BUG-20260825-002`, outside write scope. |
| D2 | `gallery_cubit_test.dart:276` off-screen nav destination on the 800x600 test surface | DEFERRED — unchanged, pre-existing, unrelated. Still not filed as a bug. |
| D4 | Two documented deviations from phase P1 §6 "must still pass unmodified" | DEFERRED — accepted at pass 1, unchanged. |

## Traceability

- AC1–AC4: PASS at pass 1 (independently re-run then: 31/31). AC1/AC2 now additionally proven at render level by the on-device QR decode. Rework re-ran the same three suites: `+31: All tests passed!`, plus `flutter analyze` clean on the 4 story files + `main_preview.dart` and a successful debug APK build.
- AC5: PASS — `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`, both images opened and confirmed by this reviewer.
- Design source: `Design-Screen: invite`, `Design-Surface: cupid-app`, `design_source.locked: true` — correct surface for a `mobile` lane, verified against `data/devops/system/design-fidelity-config.json`.
- Configuration guide: not applicable — no env var, external integration, or manual setup step introduced.

## Risk Surfaces And Critical Gates

| Surface | Gate | Status |
| --- | --- | --- |
| Mobile interaction (QR widget, animation clock) | targeted widget tests | PASS |
| Mobile navigation / discoverability | entry point in code + evidence section | PASS (was B3) |
| UI-bearing screen / design fidelity | rendered pair + `VISUAL_FIDELITY` verdict | PASS (was B1) |
| Design-system token addition | static analysis, no-fork guard on story files | PASS |
| Package dependency (`qr_flutter`) | resolution + lockfile + debug APK build | PASS |
| App lifecycle / runtime | `## Story Runtime Startup Smoke` on the shipped entrypoint | **MISSING — B2** |

## State Recommendation

- Leave `Implementation (Development)` and `Review (Reviewer)` unchecked.
- Story status: `IN_PROGRESS`.
- Route B2 to `devops` (one narrow handoff), or record `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`. Nothing goes back to `mobile-dev`.
- Blocking findings: 1. Deferred findings: 5.

The rework is good work: it closed three findings without touching a line of
production code, proved the QR at render level rather than asserting it, and
disclosed both a discarded capture and an in-scope colour choice it chose not to
change. One mandatory gate is outstanding, owned by a different role than the one
that just ran.
