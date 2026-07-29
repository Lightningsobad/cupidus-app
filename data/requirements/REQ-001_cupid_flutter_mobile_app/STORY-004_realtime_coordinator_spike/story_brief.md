# Story Brief: STORY-004 Spike — RealtimeCoordinator

Business intent: R2 is the highest-impact unresolved risk after architecture
was chosen — proving the socket/FCM reconciliation approach before building
chat/reminders avoids costly rework across two epics.

Primary persona: internal (engineering foundation) — output is an ADR-ready
prototype, not shipped user-facing functionality.

Backend contract: consumes existing Socket.IO gateway and FCM as-is; no
backend change requested. Note the known backend auth gap (R8) is out of
this spike's fix scope.

Success signal: epic-2 and epic-3 stories can build realtime features
against one documented coordinator API instead of each solving
foreground/background delivery independently.
