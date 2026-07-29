# Story Brief: STORY-001 Design System

Business intent: avoid rebuilding all ~31 screens later by locking the
platform x theme x locale foundation first (R7, high impact / low effort if
done now).

Primary persona: internal (engineering foundation), not a direct end-user
story.

Key design reference: `cupid-mobile-design/` (read-only), both iOS and
Material variants, dark + light.

Backend contract: none — pure client-side foundation, no endpoints involved.

Success signal: any later epic story can build a screen using only tokens +
ARB strings, with zero platform- or theme-specific screen forks.

Related OQ: OQ5 (light theme / EN v1 scope) — resolved in `story_master.md`.
