# Story Brief: STORY-002 API Client

Business intent: eliminate hand-written data-layer drift from the backend
contract (D5) — generated client keeps client and server locked together.

Primary persona: internal (engineering foundation).

Backend contract: consumes `/api-docs` as-is; frozen (A1), no changes
requested.

Success signal: every later feature story imports typed client code instead
of writing its own HTTP/model layer.
