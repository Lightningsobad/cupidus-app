# Story Brief: STORY-016 Profile / Privacy / Notifications

Business intent: the only epic-6 slice with mobile screens — `admin` and
`data-export` are explicitly out of scope for the mobile app (web
admin/API-only per req_master).

Primary persona: any individual user managing their own account.

Backend contract: `users` module (exact scope unverified — flagged for Tech
Lead), frozen (A1).

Success signal: users can self-manage profile, privacy, and notification
preferences without any admin/export capability leaking into the mobile app.
