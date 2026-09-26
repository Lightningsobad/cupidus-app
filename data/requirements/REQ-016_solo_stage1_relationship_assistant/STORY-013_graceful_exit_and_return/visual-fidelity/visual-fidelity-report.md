VISUAL_FIDELITY: PASS

# STORY-013 — Graceful exit (J11) and return (J13), visual fidelity rollup

Consolidates the three per-phase "Per-story visual fidelity" sections already
recorded in `coding-plan/test-results.md` (P4 §7, P5 §9, P6 §10). No new visual
judgment performed here — this file only aggregates the three phase-level PASS
verdicts that were already eyeballed ("Đã nhìn tận mắt cả hai ảnh") during
implementation, so the story-level rollup file exists alongside the per-screen
PNG pairs already captured under `visual-fidelity/`.

## Screens under audit

| Design-Screen | Phase | Design reference | Implemented | Result |
| --- | --- | --- | --- | --- |
| `j11-dong-ngan-gon-gang` | P4 | `design-reference-j11-dong-ngan-gon-gang-ios.png` (415x900) | `implemented-j11-dong-ngan-gon-gang-ios.png` (415x900) | PASS — 1 lệch có chủ ý (test-results.md P4 §7) |
| `ngan-da-hen-ngay-dang-doi` (neo cho "kho đã đóng", canvas không có khung riêng) | P5 | `design-reference-ngan-da-hen-ngay-dang-doi-ios.png` (415x900, đổi tên từ `design-reference-kho-da-dong-ios.png` để khớp id chuẩn trên canvas `cupid-ch-ng-1`) | `implemented-ngan-da-hen-ngay-dang-doi-ios.png` (415x900, đổi tên từ `implemented-kho-da-dong-ios.png`) | PASS — 2 lệch có chủ ý (test-results.md P5 §9) |
| `j13-quay-lai-sau-3-thang` | P6 | `design-reference-j13-quay-lai-sau-3-thang-ios.png` (415x900) | `implemented-j13-quay-lai-sau-3-thang-ios.png` (390x844, tên đã chuẩn hoá theo slug design-reference; nội dung giống hệt bản chụp gốc `implemented-j13-man-quay-lai-ios.png`) | PASS — 5 lệch có chủ ý (test-results.md P6 §10) |

Surface `cupid-ch-ng-1`, platform `ios`. All three implemented captures were
produced via `RepaintBoundary.toImage` inside the story's own widget tests
(`--dart-define=CAPTURE_VISUALS=true`), following the same REQ-016 precedent
used by STORY-004/STORY-021, because each state is only reachable after a
runtime precondition (absence threshold, a closed chapter) that a static
device screenshot cannot reach directly. Packaged fonts (Nunito, Roboto,
Roboto Mono, Material Symbols Rounded) were loaded from disk via `FontLoader`
in every capture, so no glyph renders as tofu.

## Deliberate deviations (all AC-forced, not implementation error)

See `coding-plan/test-results.md` for full detail per screen:
- P4 §7 (`j11-dong-ngan-gon-gang`): 1 deviation — dialog structure (`AlertDialog`,
  two equal actions) replaces the canvas's full-screen frame, forced by
  `uiux-spec.md` §2 and AC-16.
- P5 §9 (`ngan-da-hen-ngay-dang-doi`, ảnh trước đây đặt tên `kho-da-dong-ios`): 2 deviations — no app bar/tab bar (AC-22/D-3
  already removed it in STORY-006), and the filter strip is horizontally
  scrolled per the design's own scrolling behavior.
- P6 §10 (`j13-quay-lai-sau-3-thang`): 5 deviations — greeting copy, per-cell
  subcopy, wipe action styling, close (X) affordance, and icon chip color —
  each traced to a specific AC (AC-20/21/22 and `uiux-spec.md` §6).

## Verdict

PASS for all three screens. No blocking visual-fidelity finding open for
STORY-013.
