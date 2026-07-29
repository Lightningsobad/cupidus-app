# Story Brief: STORY-007 Chat

Business intent: real-time chat with a "typing ghost" is a core
differentiator called out explicitly in req_master's in-scope realtime
channel list.

Primary persona: paired couple, both partners.

Backend contract: `messages` module (+ `uploads` for attachments if
supported), frozen (A1). Known gap: gateway has no auth check (R8) — client
sends Firebase token as forward-compat, real fix is a backend decision.

Success signal: paired users can hold a real-time conversation with working
typing indicators and persisted history, without any offline-queue promises
the backend can't safely support.
