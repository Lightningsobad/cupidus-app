# Review Slice S7 — Visual fidelity images + entry-point/runtime evidence

Slice: S7 of 8 (`review/scope-gate.md` → `## Prescribed Slice Plan`)
Mode: `scoped-slice` · Subject: artifacts/evidence only, no source diff
Date: 2026-09-08
Diff baseline: `9207f7296a64cd37ca60e432939469ca96860762` (not used — no code slice)

AC source of truth used throughout: `requirements/requirements.md`.
`story_master.md` was not used for AC text.

---

## 1. Authoritative capture map (resolved before any comparison)

Required by scope-gate's "Note for S7". Nine `implemented-*` files, four design
references. Provenance was established by opening every capture, not by file name.

| Design-Screen | Design reference | Authoritative implemented capture | Superseded / secondary |
|---|---|---|---|
| `man-goc-muon-lam` | `design-reference-man-goc-muon-lam-ios.png` (415x900) | `implemented-man-goc-muon-lam-round4-emulator-5554.png` (405x900) | `-emulator-5554.png` (r1), `-round2.png` (r2), `-round3.png` (r3) — all stale |
| `phut-1-kho-trong` | `design-reference-phut-1-kho-trong-ios.png` | `implemented-phut-1-kho-trong-ios.png` (landing state) | `-suggestions.png` — second state of same screen, not a retry |
| `chi-tiet-the-moi-nghi-ra` | `design-reference-chi-tiet-the-moi-nghi-ra-ios.png` | `implemented-chi-tiet-the-moi-nghi-ra-ios.png` | `-ghi-lai.png` — third mode, **no design counterpart** |
| `the-da-thanh-ky-niem` | `design-reference-the-da-thanh-ky-niem-ios.png` | `implemented-the-da-thanh-ky-niem-ios.png` | — |

Provenance chain verified visually and is internally coherent:

- r1 (`7:31`): 4 panes starting at *Mới nghĩ ra*, no `…` overflow, delete dash on
  every tile, legacy 5-tab shell bar only → D-1/D-2/D-3 all open. Correct for r1.
- r2 (`11:42`): 5 panes with `Tất cả · 14` leading, `…` present, **two** bottom
  bars → D-1/D-2 closed, D-7 open. Correct for r2.
- r3 (`9:18`): one bottom bar, delete dash still present, meta lines still carry
  the type/context words → D-7 closed, D-4/D-5 open. Correct for r3.
- r4 (`10:34`): no delete dash, glyph replaces the word on line 2 → D-4/D-5
  closed. Correct for r4.

No stale frame was compared against a reference. The four design references were
each opened and each does depict the screen its `Design-Screen:` id names.

---

## 2. Verdict table

| # | Check | Verdict | Basis |
|---|---|---|---|
| 1 | All four `Design-Screen: <id>` values recorded at report head | PASS | `visual-fidelity-report.md` lines 2–5 |
| 2 | Each design reference depicts the screen its id names | PASS | all 4 opened |
| 3 | Authoritative implemented capture resolvable per screen | PASS | §1 above |
| 4 | Rule 12e3 — captures show this story's screen, not a splash/spinner/error/wrong screen | PASS | all 9 opened; none is a splash frame, spinner, red error screen, or a foreign screen |
| 5 | Rule 12e3 — capture is of the **actually-built app** | **PARTIAL** | only `man-goc-muon-lam` is a device capture of a running build; the other 3 screens use the in-test `RepaintBoundary` fallback (S7-F-2) |
| 6 | Round-4 frame is this lane's build (not a neighbouring install) | PASS | device pid checked before and after capture, 27940 both times (`visual-fidelity-report.md` §6) |
| 7 | Rule 12g — mobile runtime startup smoke for this story's app | **UNVERIFIED** | S7-F-3 |
| 8 | `## Entry Point Reachability` artifact section present | **FAIL (absent)** | S7-F-4 |
| 9 | Head token `VISUAL_FIDELITY: FAIL` correctly stated | PASS — **must stay FAIL** | S7-F-1 is an independent ground; see §3 |
| 10 | Handoff premise "D-8 closed 2026-09-08, no code change required" | **FAIL (premise unsupported)** | S7-F-5 |
| 11 | All 14 deltas D-14..D-27 typed | PASS (with 5 re-typings) | §4 |
| 12 | Delta labels supported by a quotable AC clause | **PARTIAL** | 4 of the labelled deltas cite an AC that does not carry the quoted clause; see §4 |
| 13 | Rendering deltas in the round-4 in-region surface fully recorded | **FAIL** | S7-F-1 — an in-region delta is visible in all four device captures and is not in the report |

---

## 3. Head-token re-assessment (handoff question 5)

**`VISUAL_FIDELITY: FAIL` must stay FAIL, on an independent ground.**

The handoff asked whether the token can flip to PASS now that D-8 is closed.
Two separate reasons say no, and either alone is sufficient:

1. **The premise does not hold** — see S7-F-5. `D-8` does not appear anywhere in
   `req_master.md`; the Design Ruling Log's last row is D-4.
2. **An independent, previously unrecorded in-region delta is visible** — S7-F-1.
   Per `.agent-contract/design-fidelity-spec.md` as quoted in the report itself
   (§1: the token is only ever PASS or FAIL, PASS requires no visible deviation,
   no prose waiver), one visible in-region deviation holds the token at FAIL
   regardless of D-8's disposition.

So the answer to question 5 is: stays FAIL, and it would stay FAIL even if D-8
were formally closed tomorrow.

---

## 4. Delta typing — D-14..D-27 (the 14)

Typing rule applied as instructed: `DESIGN_SPEC_CONFLICT` only where the AC
clause and the design element can be quoted side by side. An unquoted or
misquoted claim is an ordinary implementation delta and stays `PATCH_REQUIRED`.

| id | Report's label | **S7 typing** | Why |
|---|---|---|---|
| D-14 | `DESIGN_SPEC_CONFLICT` | **PATCH_REQUIRED** | Label unsupported. The report quotes AC-16 as asking for "một hộp thoại thẳng"; AC-16 (req line 153–155) contains no such phrase — it says only that delete removes the card and is not dramatised. Worse, **AC-11 explicitly permits** what the design draws: "thẻ được phép mang thêm **tối đa một** ô tràn '…' … Ô tràn chỉ chứa lựa chọn phụ (đổi trạng thái, sửa, xoá)". The AC sanctions the overflow the implementation dropped, so this is a divergence *from* the spec, not a conflict *with* it. |
| D-15 | `CONTRACT_GAP` | **CONTRACT_GAP** ✔ | Sound. AC-8's field list is exhaustive — "tiêu đề, loại hoạt động, ngày hẹn, giá, khoảng cách, cần đặt trước, trong nhà/ngoài trời, ghi chú, ảnh/ký ức, link nguồn" — and carries neither THỜI LƯỢNG nor KHUNG GIỜ. Design draws both. Product/Tech decision. |
| D-16 | unlabelled, "cosmetic" | **PATCH_REQUIRED** (deferrable) | Cites AC-6 for in-place editability; AC-6 is the one-required-field *creation* rule (req 97–99). The editability AC is AC-8. Substance stands but is cosmetic-visible: capture shows `120000 đ` / `3.5 km` against the design's `~70.000đ` / `1,8 km`. |
| D-17 | `CONTRACT_GAP` | **CONTRACT_GAP** ✔ | AC-8 carries exactly one "ghi chú"; no keyword-chip list exists in the contract. |
| D-18 | `DESIGN_SPEC_CONFLICT` (cites AC-13) | **DESIGN_SPEC_CONFLICT** ✔ — **re-cite to AC-11** | AC-13 (req 139–142) is the no-dead-end-pane rule and says nothing about labels. The correct clause is AC-11: "*Mới nghĩ ra* → 'hẹn ngày' · *Đã hẹn ngày* → 'chuẩn bị' · *Đã đi rồi* → 'ghi lại' · *Đã thành kỷ niệm* → 'xem lại' … Bốn nhãn CTA ở trên **không đổi**" against the canvas' "Chốt ngày đi thôi" / "Đọc lại · rủ đi lần nữa". Quotable side by side, so the label survives with the id corrected. |
| D-19 | `DESIGN_SPEC_CONFLICT` | **DESIGN_SPEC_CONFLICT** ✔ | AC-11: "**đúng một** hành động chính (CTA) xuất hiện" against the canvas' sub-CTA line "hoặc soạn lời rủ cho ngọt · để dành hôm khác" (visible in the A4 reference). Quotable. |
| D-20 | icon substitution | **glyph-swap** ✔ | Four tokens absent from the bundled cmap; no codepoint invented. Note the delete row's `remove` substitution renders as a bare "—" beside "Xoá thẻ" in both detail captures, which reads as a minus rather than a delete affordance. Cosmetic, but the swap is not visually neutral. |
| D-21 | unlabelled, structural | **PATCH_REQUIRED** (deferrable) | No AC quoted for the reorder. The added rows are separately justified under D-27; the note-above-stats lift is an unquoted implementation choice. |
| D-22 | `CONTRACT_GAP` | **CONTRACT_GAP** ✔ (id correction) | Sound for the provenance line — AC-8 carries "link nguồn" only, no paste date. The editability half again cites AC-6 where AC-8 is meant. |
| D-23 | unlabelled, cosmetic | **split: `DESIGN_SPEC_CONFLICT` (label) + PATCH_REQUIRED (placement)** | The label half is quotable: AC-10 freezes the four status names verbatim — "*Mới nghĩ ra · Đã hẹn ngày · Đã đi rồi · Đã thành kỷ niệm*" — against the canvas' "★ KỶ NIỆM", so keeping the long form is correct and is a genuine spec conflict. The right-vs-left pill placement has no AC behind it and is an ordinary delta. |
| D-24 | `CONTRACT_GAP` | **PATCH_REQUIRED** — misclassified | The report states photo upload "has no acceptance criterion in this story and no column in `activity_cards`". Both halves are wrong: **AC-8 lists "ảnh/ký ức" among the required structured fields**, and scope-gate §Query Keys records an `activity_card_photos` table in the P1 schema. An unimplemented AC-8 field is not a contract gap. The canvas' two-line annotation caption is genuinely out of scope; the photo capability is not. |
| D-25 | `CONTRACT_GAP` | **CONTRACT_GAP** ✔ | Cross-card aggregates; the P2 contract exposes `countsByStatus` only. The report's aside that these are not AC-18/AC-19 violations is correct — AC-18 forbids behaviour indicators about *the other person*; "4 lần đi chung" counts shared outings. |
| D-26 | unlabelled, structural | **CONTRACT_GAP (meta line) + PATCH_REQUIRED (title placement)** | Duration and weather share D-15's root cause. Title-above-photo is an unquoted layout choice. |
| D-27 | recorded as deliberate additions | **no action — citations verified** | AC-14 (two-way status change), AC-16 (delete), AC-17 (đã rủ / đã trả lời flags) all verified verbatim against `requirements.md`. These three are the only AC citations in §8 that are correct as written. |

Round-5 deltas D-9..D-13 are outside the 14 but were checked in passing: **D-9's
`DESIGN_SPEC_CONFLICT` label is unsupported** — it cites AC-2, which is the
paste-link invitation (req 78–81) and says nothing about a persistent three-cell
strip. D-10/D-11 quote `ux/uiux-spec.md` §4a only, never an AC clause. D-12 is the
strongest of the five: it quotes invariant R-15a, which is quotable and holds.

---

## 5. Findings

### S7-F-1 — in-region delta visible in all four device captures, absent from the report — `PATCH_REQUIRED`

The hub's quick-entry strip renders as **three empty grey boxes** with no glyph
and no label, in r1, r2, r3 and r4 alike. It is not a capture artifact and not a
one-round regression.

`visual-fidelity-report.md` §0 lists "Quick-entry strip (3 cells)" as **in region
(P4 owns these)**, and §5 reports it as "The quick-entry strip renders its three
cells" — technically true and materially misleading: three frames render, with
nothing in them.

Confirmed against source (one targeted read, not a code review):
`activity_card_hub_view.dart:156–195`, `_QuickEntryStrip`, builds three
`DecoratedBox` frames one tap target tall with no child, commented "The empty
frame is exactly one tap target tall; P5 sets the final height from the icon +
one-line label it drops in." P5's real `QuickEntryStrip` — which renders
`Gợi ý quà · Mồi chuyện · Vô hoàng đạo` correctly in
`implemented-phut-1-kho-trong-ios.png` — was never mounted here. Same root cause
as FLAG-2. The adjacent `activity_card_hub_minute1_slot` is likewise an empty
`SizedBox` (line 208).

This is an in-region visible deviation on the one screen that *was* captured from
the built app, and it is why the head token cannot read PASS. Owner: the
integration phase that owns `activity_card_hub_view.dart`.

### S7-F-2 — 3 of 4 screens have no built-app capture — `DEFERRED` (fallback accepted)

Only `man-goc-muon-lam` was captured from a running build on `emulator-5554`.
`phut-1-kho-trong`, `chi-tiet-the-moi-nghi-ra` and `the-da-thanh-ky-niem` were
captured with the in-test `RepaintBoundary` fallback (report §7.5, §8.5) because
those screens **exist on no route at all** — `test-results.md:913–915` records
"Màn chi tiết chưa có route" and the same for the three P5 widgets.

The fallback itself is the accepted method for an unreachable screen and is not a
blocker at this gate. What it means for 12e3 is recorded honestly: for three of
four screens the evidence shows the widget renders correctly, not that a user can
reach it. The unreachability is FLAG-2 and belongs to S4's verdict, not this one.

### S7-F-3 — rule 12g runtime startup smoke not run for the real app — `UNVERIFIED`

`test-results.md:391`: "Runtime startup smoke ở dạng khởi động app thật với DI
đầy đủ: **không chạy**." All seven phase files and `master-plan.md:49` declare
`Startup Smoke: NOT_APPLICABLE`.

What exists instead: `flutter run -d emulator-5554 -t lib/main_preview.dart`
with `--dart-define=PREVIEW_SOLO_HUB_FIXTURE=true`, i.e. the preview harness
backed by `_PreviewActivityCardRepository`, whose **write methods throw**
(report §6). That evidence does establish that the app compiles, installs and
launches on device without crashing, and it is the correct method for a fidelity
capture. It does not establish 12g's actual gate — real entrypoint, full DI,
first screen, no crash — because the real entrypoint was never launched.

Scope-gate lists 12g as a critical gate for S7 while master-plan declares it
`NOT_APPLICABLE`; that contradiction is unresolved in the artifacts and this
slice does not resolve it. Recorded as UNVERIFIED with the conflict named, for
S8 to route.

### S7-F-4 — required evidence sections absent — `PATCH_REQUIRED` (artifact)

Neither `## Entry Point Reachability` nor `## Story Runtime Startup Smoke`
exists in any story artifact. Both strings occur only inside
`review/scope-gate.md`'s own Query Keys (lines 200, 207), i.e. the gate asks for
sections that were never written. The `Reachable: YES` token scope-gate warns S4
not to trust does not exist to be trusted or distrusted. The code-level
reachability verdict is S4's; the missing artifact is recorded here.

### S7-F-5 — handoff premise unsupported: D-8 is not closed — `BLOCKER for the head token`

The handoff states D-8 "closed on 2026-09-08 with no code change required".
Verified against `req_master.md`:

- `grep -c 'D-8' req_master.md` → **0**. The id appears nowhere in the file.
- `## Design Ruling Log` (line 140) has four rows: D-1, D-2, D-3 (2026-09-07) and
  D-4 (2026-09-08). D-4 is the ruling dated 2026-09-08, and it is about the
  tile-level delete dash, not the four context words.
- The log's closing prose (lines 157–162) records **D-5 as still open**, assigned
  to Tech Lead — even though `visual-fidelity-report.md` §3c declares D-5 closed
  by round 4. The log and the report disagree about D-5 as well.
- D-14..D-27 have no ruling-log entries at all.

Note a live id collision for S8: `D-15` in `req_master.md` (lines 85/174/183) is
the closed **OQ-3 content/CMS decision**, an entirely different namespace from
`D-15` the visual delta. The two must not be conflated.

The token stays FAIL on S7-F-1 in any case, so this finding does not change the
verdict — but no reviewer or Scrum Master should record D-8 as adjudicated.

### S7-F-6 — evidence-quality note on the occasion capture — `DEFERRED`

`implemented-phut-1-kho-trong-ios-suggestions.png` renders `Dịp thử nghiệm`,
`Gợi ý thứ nhất`, `Gợi ý thứ hai` — widget-test stub strings. D-12's claim that
the occasion name is "read from the package" is demonstrated with a stub, not
with real `occasions.v1.json` content. The mechanism is shown; the shipped
content is not. R-15a conformance itself is S3's finding, not this one.

---

## 6. Explicitly excluded from this slice

- **S4-F-6** (preview fixture `countsByStatus` reporting 14 against 4 rendered
  rows in the `man-goc-muon-lam` capture) — treated as a fixture bug per handoff
  instruction, **not** counted as a visual-fidelity finding. The report itself
  documents the fixture as seeded to `{idea: 8, scheduled: 2, done: 3, memory: 1}`
  precisely so the `Tất cả` count matches the design (§6).
- No S1–S6 code or contract surface was re-reviewed. The single source read in
  this slice (`activity_card_hub_view.dart:156–195`) was a targeted confirmation
  of an image observation, not a review of P4.
- No final synthesis. S8 owns the outcome line.

---

## 7. Slice summary

| Outcome dimension | Result |
|---|---|
| Blocking findings | S7-F-1 (in-region delta, unrecorded) |
| Unverified gates | S7-F-3 (12g startup smoke), 12e3 partial for 3 of 4 screens |
| Artifact defects | S7-F-4 (2 required sections absent), S7-F-5 (D-8 not adjudicated, D-5 log/report disagreement) |
| Delta re-typings | D-14 → PATCH_REQUIRED · D-24 → PATCH_REQUIRED · D-18 re-cited AC-13 → AC-11 · D-23, D-26 split · D-9 label unsupported |
| Head token | `VISUAL_FIDELITY: FAIL` — correct, stays FAIL |

REVIEW_SLICE_COMPLETE: YES
