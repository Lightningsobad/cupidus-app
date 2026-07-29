# Story Brief: STORY-003 Auth

Business intent: frictionless, persistent sign-in is table stakes before any
paired-couple feature can be used at all.

Primary persona: any Cupid app user, both partners independently.

Backend contract: `auth` module, Firebase Auth-backed; contract frozen (A1).

Success signal: user signs in once, stays signed in across restarts, and
never sees an unexpected forced logout due to token expiry alone.
