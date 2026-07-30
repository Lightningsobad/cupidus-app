# UX Spec: STORY-003 Auth (Firebase sign-in + refresh-token interceptor UX)

Scope: REQ-001 / STORY-003_auth
Source of truth: `cupid-mobile-design/Cupid Screens.dc.html` (screen ids
`splash`, `welcome`, `login`, `register`, `otp`, `forgot`, `permissions` —
the `NO_CHROME`/`NO_TABS` onboarding group, per system UX memory §4).
Tokens/components reused verbatim from STORY-001
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/ux/uiux-spec.md`)
— no new tokens introduced.

This spec covers only what the design source does not already show: the
*states* the refresh-token interceptor (STORY-002 `auth` slot) and session
persistence (AC2, AC3, AC4) surface to the user. The screens themselves
(layout/copy/visuals) are the existing design-source screens; only new
states, transitions, and a small number of new strings are specified below.

## 1. Screen Inventory (existing design source, reused as-is)

| Screen id | Purpose | Chrome |
|---|---|---|
| `splash` | App entry — repurposed as the **session/auth-check gate** (§3) | none |
| `welcome` | Unauthenticated landing; social + email entry points | none |
| `login` | Email/password sign-in + Google/Apple(iOS)/Facebook(MD) + biometric quick-unlock | none |
| `register` | Email/password + display name account creation | none |
| `otp` | 6-digit email verification code entry | none |
| `forgot` | Password reset via emailed link | none |
| `permissions` | Post-verification handoff (out of this story's scope beyond being the `goPermissions` target) | none |

No new screens are added. `NO_CHROME`/`NO_TABS` continues to apply to this
whole group per system UX memory §4 — none of the new states below add a
header or tab bar.

## 2. Flow Map (cold start through authenticated area)

```
Cold start
  -> splash (auth-check, §3)
       - stored session valid or silently refreshed -> Home (authenticated area, AC1)
       - no stored session -> welcome
       - stored session present but refresh fails -> login (§4, session-expired variant)
  -> welcome -> login | register (existing goLogin/goRegister taps)
  -> login -> Home (AC1) | goForgot -> forgot | goRegister -> register
  -> register -> otp -> permissions (existing goOtp/goPermissions taps; downstream of this story)
  -> forgot -> login (existing goLogin tap, after "Send reset link")

Authenticated area, any screen
  -> access token expires mid-session -> interceptor refreshes transparently (§4, invisible case)
  -> refresh fails (refresh token itself invalid/revoked) -> forced re-auth (§4, session-expired variant)
  -> user signs out (§5) -> welcome
```

## 3. Splash as Auth-Check Gate (AC3 — session persistence)

The `splash` screen already exists as a branded loading moment
(`isSplash`, nebula gradient, bobbing dots, "Đang mở khoá kỷ niệm của hai
bạn…" / "Unlocking your memories…"). This story repurposes its dwell time
to perform the auth-check without adding a new screen:

- On cold start, `splash` is shown immediately (no network dependency to
  paint it — matches the existing design, which never blocks first paint on
  a call).
- In parallel, the app attempts to read the persisted session
  (`CupidAuthTokenProvider.readAccessToken()` per STORY-002 §2) and, if
  the access token is stale, one silent `refreshAccessToken()` call.
- Outcome branches (existing `goWelcome` tap-to-continue affordance stays
  as a fallback, not the primary path):
  - **Valid session (token present, or refresh succeeds):** navigate
    directly to Home. Do not show `welcome`/`login` at all — this is the
    "stay signed in" promise in the story's User Story statement.
  - **No session (first run / signed out):** navigate to `welcome`
    (existing behavior, existing copy, unchanged).
  - **Session present but refresh fails** (refresh token expired/revoked —
    distinct from "no session"): route to `login`, not `welcome`, using the
    session-expired variant in §4. This preserves the user's place in the
    sign-in funnel (they had an account) rather than re-selling them the
    marketing welcome screen.
- Minimum splash dwell: keep the existing "tap to continue" affordance
  visible only if the auth-check has not resolved within a short window
  (recommend 2s, Tech Lead/mobile-dev to confirm against real refresh
  latency) so the screen never feels frozen on a slow network. This does
  not change any visual — it only governs when the tap affordance becomes
  interactive vs. auto-navigating.
- No spinner is added to `splash` beyond its existing bobbing-dots
  animation — that animation now doubles as the auth-check loading
  indicator. Do not add a second competing loading indicator.

## 4. Refresh-Token Interceptor UX States (AC2)

The interceptor itself (STORY-002 `auth` slot, replacing
`PassthroughInterceptor`) is invisible infrastructure. Two and only two
user-visible states result from it:

### 4a. Invisible case (the common path, AC2's "transparently")

When an access token has expired and the refresh token is valid, the
401 -> refresh -> retry cycle must produce **zero UI change**: no spinner
flash, no toast, no screen transition. The in-flight screen's own normal
loading state (if any, e.g. a pull-to-refresh spinner already on that
screen) is the only indicator the user sees, and it should look identical
whether or not a silent refresh happened underneath. Mobile Developer:
do not surface interceptor-level retries as a distinct loading affordance.

### 4b. Session-expired / forced re-auth case

Triggered when the refresh token itself is invalid, expired, or revoked
(refresh call itself fails with 401, not just the original request).

- Do not show a raw error screen or crash to `welcome`. Route to `login`
  with a **session-expired variant**:
  - Reuse the existing `login` screen layout/tokens exactly.
  - Replace the existing heading only:
    - Existing: "Mừng bạn quay lại 🎀" / "Welcome back 🎀"
    - Session-expired variant: **"Đăng nhập lại để tiếp tục"** /
      **"Sign in again to continue"** (new strings — vi/en pair, same
      Nunito 900/27px heading style, same subtext slot below it).
  - Pre-fill the email field with the last-known signed-in email if the
    app has it locally (do not pre-fill password). This is a courtesy
    autofill, not a stored credential — if the mechanism to retain the
    last email is not trivial, omit it; it is not a hard requirement.
  - Do not add a modal/dialog interruption if the user is mid-action in
    the authenticated area (e.g. mid-typing a message) — the forced
    navigation to `login` on the next failed request is itself the
    interruption; no additional "your session expired" toast is needed
    on top of the heading change, to avoid double-signaling the same
    event. If Mobile Developer/Tech Lead prefer an explicit toast for
    discoverability (e.g. the navigation happens on a background
    request the user didn't directly trigger), a single non-blocking
    snackbar reading **"Phiên đăng nhập đã hết hạn"** / **"Your session
    has expired"** is acceptable as an addition, not a replacement, for
    the heading change above.
  - After a successful sign-in from this variant, resume to Home (not to
    whatever screen the user was on before expiry) — resuming to a
    stale in-memory screen state after a forced re-auth is out of scope
    for this story's UX (that is state-restoration, a Tech Lead/mobile
    concern if desired later).

## 5. Sign-Out (AC4)

Design source has no explicit sign-out screen/control in
`cupid-mobile-design/` (it is presumably inside the `Me`/profile screen,
epic-6, out of this story's screen scope). This story specifies only the
*behavior*, for wherever Mobile Developer/Tech Lead place the sign-out
action (e.g. Me screen menu item):

- Sign-out is a **destructive-pattern confirmation**, consistent with the
  design system's existing dual-confirmation/hold-to-confirm vocabulary
  for consequential actions (system UX memory §1 "dual-confirmation"; here
  single-user destructive, not dual-partner, since it only affects the
  signed-in device's local state) — a standard confirm dialog (not a
  hold-gesture; hold-gestures in the source are reserved for
  partner-facing rituals like the Love Contract sign, not solo account
  actions) with:
  - Title: "Đăng xuất?" / "Log out?"
  - Body: "Ảnh và dữ liệu riêng tư trên máy này sẽ bị xoá." / "Photos and
    private data on this device will be cleared." — this line is
    important: AC4 requires clearing cached authenticated data, and
    Level-1 device-only data (Typing Ghost, Private Gallery — system UX
    memory §8) is exactly what a user could lose access framing for, so
    the confirm copy must say so plainly rather than a generic "are you
    sure."
  - Confirm button: destructive-styled (use `--red` token, not
    `--grad-hot`) "Đăng xuất" / "Log out". Cancel: text button.
- On confirm: clear local session + cached authenticated data, then
  navigate to `welcome` (not `login` — signing out is a deliberate user
  choice, so the full marketing welcome screen is appropriate, unlike the
  involuntary session-expired case in §4b which skips straight to
  `login`).

## 6. Loading / Disabled States on Existing CTAs

Existing design source shows sign-in/register/verify buttons as static
(no loading state authored). Add the following standard rule uniformly to
`login`'s "Đăng nhập"/"Log in", `register`'s "Tạo tài khoản"/"Create
account", and `otp`'s "Xác nhận"/"Verify" primary buttons:

- On tap, disable the button and replace its label with an inline spinner
  (same button size/shape/gradient, no layout shift) until the call
  resolves. Prevent double-submit.
- On failure, restore the label, re-enable the button, and show an inline
  error message using `--red` text beneath the relevant field (not a
  full-screen error state) — e.g. "Email hoặc mật khẩu không đúng" /
  "Incorrect email or password" for login; "Mã xác thực không đúng" /
  "Incorrect code" for OTP. Do not expose raw `CupidApiFailure` types
  (`NetworkUnavailableFailure`, `TimeoutFailure`, etc. per STORY-002 §2) —
  map each to one short user-facing line; a `NetworkUnavailableFailure`
  specifically should read "Không có kết nối mạng" / "No internet
  connection" so it's distinguishable from a wrong-credential error.

## 7. Accessibility Notes

- All new/changed interactive elements (sign-out confirm buttons, retry
  states) must meet the existing `--tap` minimum (44pt iOS / 48dp
  Material) already established in STORY-001 tokens — no new exemption.
- Session-expired heading change (§4b) must be announced to screen
  readers as a live region update if the app is already open when the
  forced navigation happens (i.e., it should not silently swap text under
  an unfocused screen without a screen-reader announcement of the
  navigation itself).
- Destructive sign-out confirm dialog (§5) must trap focus within the
  dialog and return focus to the triggering control on cancel, per
  standard modal a11y practice.
- Inline field errors (§6) must be associated with their input via
  accessible description (e.g. `errorText`/semantic hint), not color
  alone — existing STORY-001 contrast rule already flags that
  `colorAccentPink`/`colorRed` on light theme needs the text-size
  exception check; use `--red` at normal error-message text size, which
  the light-theme contrast note in STORY-001 §5 did not clear, so Tech
  Lead/mobile-dev should verify `--red` (not `--pink`) contrast
  specifically for light-theme error text before relying on this spec's
  color choice — flagged, not blocking (dark theme is the only
  user-facing v1 theme per OQ5, so this is a forward-compat check only).

## 8. Platform Adaptation

No new fork points. Existing adaptive rules apply unchanged:
- Primary CTA buttons (login/register/otp/sign-out-confirm) follow the
  existing adaptive Primary CTA pattern (full-width pill iOS / filled
  button + ripple Material) already in STORY-001 §6.
- Social sign-in buttons already conditionally render Apple only on iOS
  (`isIOS`) and Facebook only on Material (`isMD`) in the existing design
  source — unchanged, this story does not add or remove a provider.

## 9. Open Items For Downstream Roles

- **Tech Lead — OTP mechanism mismatch (flag, not a stop):** the design
  source's `otp` screen is a manually-typed 6-digit code UI. Firebase
  Auth's standard email-verification flow (`sendEmailVerification`) is
  link-based (user taps a link in their inbox), not a 6-digit code the
  app can verify directly — a manual-code flow requires either (a) a
  custom backend-issued code (contradicts A1 "backend contract frozen" —
  no new endpoint may exist for this) or (b) reinterpreting the `otp`
  screen as a "check your inbox, tap the link, then return here" waiting
  state with a polling/deep-link resume instead of digit entry. This spec
  does not resolve which; recommend Tech Lead's ADR confirm one of: (a)
  keep the 6-digit visual but repurpose it as a deep-link resume screen
  (poll `currentUser.reload()` / `emailVerified` while showing the same
  visual, digits become decorative until confirmed — cheapest, keeps the
  screen), or (b) drop manual entry and change copy to "tap the link we
  sent, then come back" (more accurate, changes copy). Does not block the
  rest of this spec (splash/refresh/session-expired/sign-out are
  independent of how OTP entry resolves).
- **Tech Lead — biometric quick-unlock scope:** `login`'s existing
  `bioLabel` fingerprint row should be understood as a **local app-lock
  gate on an already-persisted session** (fast re-entry without retyping
  a password), not a second Firebase auth method — i.e. it only ever
  appears when §3's auth-check already found a valid/refreshable session
  and is offering a faster unlock than falling through to the full
  email/password form. If Tech Lead's ADR treats it differently (e.g. as
  a true alternate sign-in credential), this spec's §3 flow map should be
  revisited.
- **System UX memory update recommended, out of this story's write
  scope:** the splash-as-auth-check-gate pattern (§3) and the
  session-expired-routes-to-login-not-welcome rule (§4b) are reusable
  patterns future stories (e.g. any screen behind auth) should not
  reinvent. This story's `WriteScope` only covers
  `STORY-003_auth/ux/**`, so `data/ux/system/ui_ux_system_memory.md` is
  not edited here — recommend Scrum Master apply a short new "§12 Auth
  Session UX Patterns" section there sourced from this spec's §3/§4/§5
  once this story is reviewed.

## Completion

UX_COMPLETE: YES

All four ACs have a corresponding UX specification: AC1 (existing
welcome/login/register flow, reused as-is), AC2 (§4, invisible +
session-expired states for the refresh interceptor), AC3 (§3, splash as
auth-check gate), AC4 (§5, sign-out confirmation + destructive copy). No
blocker found; one flagged mismatch (§9 OTP mechanism) is a Tech Lead ADR
input, not a blocker to starting this spec's non-OTP portions.
