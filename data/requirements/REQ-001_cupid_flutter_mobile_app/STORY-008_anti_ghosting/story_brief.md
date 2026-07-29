# Story Brief: STORY-008 Anti-Ghosting

Business intent: explicitly called out in req_master's realtime channel
scope alongside chat and reminders — a distinct backend module
(`ghost-config`) from chat itself.

Primary persona: paired couple, both partners.

Backend contract: `ghost-config` module, frozen (A1).

Success signal: couples can configure and see anti-ghosting signals without
it being conflated with the typing-ghost chat feature.
