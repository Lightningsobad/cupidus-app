# Master Coding Plan – Frontend App Foundation & Home Landing Page

## 1. Planning Metadata

- Story ID: REQ-006 / STORY-001
- Complexity: standard (shared-foundation, Implementation Lane `shared`)
- OQ Constraints Source: `../req_master.md` `## Open Questions`
  (OQ-REQ006-1 resolved by `../architecture/solution.md` section 1;
  OQ-REQ006-2 resolved by Product Owner)
- Requirement Configuration Guide impact: REQUIRED — a new deploy target
  (`cupidus.app`), a new runtime id, and new GitHub Actions secrets are
  introduced; P6 owns the update.

## 2. Planning Goal

- Shared contract owner: Frontend Developer (P2 produces the shell contract
  documented in `../architecture/contract-summary.md`).
- Contract-first phase required: YES — the consumers of the shell contract are
  STORY-002…STORY-008, i.e. different stories in different branches, not
  in-lane consumers of this story. P2 is that phase.
- Parallel execution possible: YES
- Critical path: P1 → P2 → P3 → P5
- Parallelism notes: P4 (sprites) needs only P1's tokens and can run alongside
  P2/P3. P6 (DevOps) needs only P1's build command and can run alongside P2–P5;
  its end-to-end deploy run is meaningful only after P5 lands, but the workflow,
  registry, and guide are authored independently.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| Shell layout + `page` prop union | Frontend Developer | P2 | P3, P5, and STORY-002…008 | `../architecture/contract-summary.md` section 1 |
| Route keys + storage keys + body attributes | Frontend Developer | P2, P3 | P5, and STORY-002…008 | `../architecture/contract-summary.md` section 2 |
| Bilingual `data-vi`/`data-en` mechanism | Frontend Developer | P1 (CSS), P2 (usage) | P5, and STORY-002…008 | `../architecture/contract-summary.md` section 3 |
| Design tokens (`tokens.css`) | Frontend Developer | P1 | P2–P5, and STORY-002…008 | `../architecture/contract-summary.md` section 4 |
| `web-frontend` runtime registry entry | DevOps Engineer | P6 | P1–P5 build/dev commands | `data/devops/system/runtime-command-registry.json` |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Design token parity | P1 |
| Inline-style fidelity | P2 (shell), P5 (Home body) |
| Hover-state fidelity | P2, P5 |
| Nav breakpoint hard swap | P1 (media queries) + P2 (header) |
| Theme/lang boot before first paint | P2 + P3 (needs ≥2 routes to cross) |
| Language persistence across document loads | P2 + P3 |
| Web font + icon-font parity | P2 |
| Route reachability | P3 |
| Deploy parity with REQ-005 | P6, verified end-to-end after P5 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `web-frontend`: `frontend`, startup smoke `OPTIONAL`, command/source
    runtime registry `devCommand` — the entry is **created by P6**; until then
    P1–P5 name `web-frontend` as the planned id. Startup smoke is a DevOps /
    runnable-foundation gate and is deliberately excluded from every phase test
    scope below.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|-------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P1 | Frontend Developer | Frontend | None | NO | `web/package.json`, `web/astro.config.mjs`, `web/tsconfig.json`, `web/.gitignore`, `web/src/styles/tokens.css`, `web/src/styles/global.css` | `Cupid Web.dc.html:16-27`; solution.md §1, §4 | runnable Astro static scaffold; verbatim dark+light token blocks; verbatim global rules and the two nav media queries | `npm run build`, `astro check`, token-parity diff vs source lines 16–17 | DONE |
| P2 | Frontend Developer | Frontend | P1 | NO | `web/src/layouts/SiteLayout.astro`, `web/src/components/shell/NebulaBackdrop.astro`, `web/src/components/shell/SiteHeader.astro`, `web/src/components/shell/SiteFooter.astro`, `web/src/data/site-nav.ts`, `web/src/scripts/theme-lang-boot.ts` | `Cupid Web.dc.html:11-14, 31-77, 655-676, 683-732, 831-848`; uiux-spec §6.1, §6.4; contract-summary.md §1–§3 | shell contract implemented; theme+lang boot; header/footer at Fidelity Baseline | `npm run build`, `astro check`, shell capture pair (dark/vi + light/en), hover-rule count | DONE |
| P3 | Frontend Developer | Frontend | P2 | NO | `web/src/pages/index.astro`, `pets.astro`, `zodiac.astro`, `share.astro`, `blog.astro`, `about.astro`, `support.astro`, `legal.astro` | uiux-spec §6.3; contract-summary.md §2 | 8 pre-rendered routes mounted in the shell; header 7 items + footer `legal` all resolve | `npm run build` emits 8 HTML files, `astro check`, link-resolution check, cross-route theme/lang persistence check | DONE |
| P4 | Frontend Developer | Frontend | P1 | YES | `web/src/components/sprites/BoSprite.astro`, `BunSprite.astro`, `KemSprite.astro`, `MochiSprite.astro`, `SuaSprite.astro`, `XoaiSprite.astro` | `{Bo,Bun,Kem,Mochi,Sua,Xoai} Sprite.dc.html` default `sc-if` state only | 6 inline-SVG components with namespaced gradient ids and their own keyframes | `npm run build`, `astro check`, per-sprite render capture | DONE |
| P5 | Frontend Developer | Frontend | P3, P4 | NO | `web/src/components/home/Hero.astro`, `FeatureGrid.astro`, `PetCast.astro`, `HowItWorks.astro`, `web/src/data/home-content.ts`, `web/src/pages/index.astro` | `Cupid Web.dc.html:79-211, 734-754`; uiux-spec §6.2, §6.8 | complete Home body: hero + phone mockup, features grid, pet-cast teaser, how-it-works | `npm run build`, `astro check`, Home capture pair at Fidelity Baseline plus 375/768/1024/1025/1440, copy-fidelity diff | DONE |
| P6 | DevOps Engineer | DevOps | P1 | YES | `data/devops/system/runtime-command-registry.json`, `.github/workflows/deploy-web.yml`, `.github/workflows/scripts/vps-deploy-web.sh`, `scripts/build.sh`, `scripts/start-dev.sh`, `../deployment/configuration-guide.md` | `.github/workflows/deploy-backend.yml`, `.github/workflows/scripts/vps-deploy.sh`, shared-local-infrastructure reference | `web-frontend` registry entry with a devstack-claimed port (21021); GitHub Actions deploy to `cupidus.app`; configuration guide; exact new-secret list for the user (`VPS_WEB_DEPLOY_PATH`) | `bash -n` on both scripts, shellcheck when available, workflow YAML validation, registry schema validation | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-app-scaffold-and-design-tokens.md` |
| P2 | `phase-P2-global-shell.md` |
| P3 | `phase-P3-route-map-and-entry-point.md` |
| P4 | `phase-P4-pet-sprite-components.md` |
| P5 | `phase-P5-home-page-body.md` |
| P6 | `phase-P6-runtime-registry-and-deploy.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- No duplicate files exist for any phase id.
- Frontend implementation phases fit one specialist lifecycle (roughly six
  source/test files max) or are split. P3's 8 route files and P4's 6 sprite
  files are each one pattern applied to N variants of the same behavior
  cluster — one phase each, not N.
- P3 and P5 both write `web/src/pages/index.astro` (P3 creates the route in the
  shell, P5 fills its body). That shared file is **not** the reason they are
  separate: merging them would be 13 files, well over one lifecycle.
- No two phases are separated only because they would write the same file.
- The standalone contract phase (P2) is justified: its consumers are
  STORY-002…STORY-008, which sit in other stories and other branches.
- No trailing verification/testing phase exists; each phase owns its own
  targeted checks and build/type-check.
- No phase test scope includes backend e2e, Playwright/browser e2e, traces,
  scenario reruns, repository-root local script gates, or runtime startup
  smoke. Design-fidelity captures are visual audits, which are permitted.

## 6. Notes

- Schema deviation, deliberate: this Phase Overview carries the 10-column
  schema (`Write Scope`, `Primary Inputs`, `Planned Outputs`, `Test Scope`
  included) required by the `tech-lead` SKILL.md rule 14 and by the Scrum
  Master handoff. The bundled `master_plan_template.md` instructs the opposite
  ("Do not add `Write Scope`, `Primary Inputs`, `Planned Outputs`, or `Test
  Scope` columns"). Two of the three governing sources require the wide schema,
  so it is used here; the conflict is reported to Scrum Master rather than
  silently resolved. Each phase file remains authoritative for its own
  `## 1B` and `## 6` content.
- The design-fidelity lock re-point to `Cupid Web.dc.html` is in flight with
  Product Owner / Scrum Master and gates only the Reviewer visual gate. No
  phase below depends on it.
