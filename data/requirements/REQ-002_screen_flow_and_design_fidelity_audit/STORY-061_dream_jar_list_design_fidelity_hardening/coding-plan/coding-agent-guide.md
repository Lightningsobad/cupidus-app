# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
No OQ registry applies to this story.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Both phases are Mobile lane. P2 must not start before P1 is `DONE`.
3. Update status immediately when it changes.
4. Do not expand a phase's Write Scope. In particular, do not touch
   `cupid_tab_bar.dart`, `cupid_header.dart`, `DreamJarDetailScreen`, or any
   backend file.
5. Do not implement report row 8 (the progress amount/percent format change).
   It is explicitly out of scope per `../requirements/requirements.md`'s
   reconciliation note.

## 4. Story-Specific Traps

- **AC10 is documentation-only and its original wording is factually wrong.**
  Use the corrected disposition in `../architecture/solution.md` §3. Write no
  code for AC10.
- **Changing `app_shell.dart` alone does not satisfy AC8's evidence.** The
  `implemented-jarlist-*` capture runs `PreviewAppShellChrome`, not `AppShell`.
  P2's Write Scope includes the preview mirror for that reason.
- **Do not delete the Gallery tab before its `HomeScreen` entry card exists.**
  `app_shell.dart` is `GalleryScreen`'s only production reference.
- **Do not use `DreamJarIllustration` for the AC2 card thumbnail.** It holds two
  `AnimationController`s per instance.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Record all test and capture evidence in `coding-plan/test-results.md`.
- Escalate to Scrum Master if the plan is materially wrong.
