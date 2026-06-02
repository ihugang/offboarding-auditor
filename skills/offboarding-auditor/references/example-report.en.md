# Inheritance Audit Report: billing-service (subscription billing)

> This is a **filled-in sample** for Claude to mirror when producing an English report.
> Content is fictional — it demonstrates the expected granularity: evidence-driven, successor's-eye-view, and a concrete pre-departure fix-list.

- Scope: `git@github.com:acme/billing-service` (~18k lines of Go)
- Departing owner: Li Wei (sole maintainer for 14 months, last working day +5)
- Successor profile: Wang Fang, mid-level backend, **brand new, no billing-domain context**
- Audit date: 2026-06-02

## Verdict

- **Inheritability score: 54 / 100**
- **Handover verdict: ❌ Not ready — 2 blockers present**
- One-liner: Code quality is decent, but the **production deploy key and Stripe ownership are bound to Li Wei's personal accounts**, and the core reconciliation logic has zero docs — once he leaves, the successor can neither ship nor understand how money is calculated.

## Blockers 🔴 (handover impossible until resolved)

- [ ] **Production deploy key bound to a personal account** — Evidence: `.github/workflows/deploy.yml:23` uses secret `LIWEI_GCP_SA`, a GCP service account under Li Wei's personal Google account. Once the account is disabled at offboarding, the pipeline breaks and **no one can deploy**. Fix: migrate to a team service account, update the CI secret.
- [ ] **Stripe master key origin unknown** — Evidence: the production `STRIPE_SECRET_KEY` is not in `.env.example`, has no record in the repo, and only Li Wei knows which Stripe account it was generated under. Fix: confirm Stripe account ownership, transfer owner rights, document the key-rotation procedure.

## High 🟠

- [ ] **Reconciliation logic has no "why"** — Evidence: the proration/refund algorithm in `internal/recon/proration.go:88-140` contains 3 magic numbers (`0.97`, `30`, `86400`) with no comments and no docs. The successor won't dare touch it; a wrong change miscalculates money. Fix: Li Wei writes an ADR explaining where the billing rules come from.
- [ ] **Core module is a knowledge silo** — Evidence: `inventory.sh` shows all 9 files under `internal/recon/` have Li Wei as their sole author, with no code-review trail.
- [ ] **Manual ops step undocumented** — Evidence: `rg "manual"` hits `cmd/migrate/README` mentioning "run the monthly reconciliation compensation script manually on the 1st", but the script's location, args, and failure handling are all missing. Fix: write a runbook.

## Dimension scores

| Dimension | Score | Key finding |
|-----------|-------|-------------|
| 1 Runnability | 6/10 | Boots locally, but lacks real keys (blocker 2); `.env.example` missing 4 vars |
| 2 Understandability | 4/10 | README has an architecture diagram, but core billing rules are unexplained |
| 3 Maintainability | 6/10 | Code is clean and well-named; but the recon module is a black box |
| 4 Testability | 7/10 | 68% unit coverage, `make test` works; recon module lacks integration tests |
| 5 Tribal knowledge ⚠️ | 3/10 | Magic numbers, manual compensation step, Stripe webhook retry gotcha all undocumented |
| 6 Dependency/access ownership ⚠️ | 2/10 | Deploy key + Stripe owner both on personal accounts (the two blockers) |
| 7 Ops & deployment | 4/10 | CI exists, but rollback procedure and alerting entry points are unwritten |
| 8 In-flight work | 5/10 | `feat/usage-based-billing` is 12 commits ahead of main, half-done, no notes |
| 9 Business context | 6/10 | Requirements live in Notion, but links are scattered across PR descriptions |
| 10 Bus factor | 2/10 | Only Li Wei deeply understands the project; no second knowledgeable person |

## Pre-departure fix-list (by priority)

| Priority | Item | Risk addressed | Owner | Est. effort |
|----------|------|----------------|-------|-------------|
| 🔴 | Migrate deploy SA to a team account, update CI secret | Blocker 1 | Li Wei + Ops | 3h |
| 🔴 | Transfer Stripe owner, document key origin & rotation | Blocker 2 | Li Wei | 2h |
| 🟠 | Write reconciliation-rules ADR (explain the 3 magic numbers) | Tribal knowledge | Li Wei | 3h |
| 🟠 | Write runbook for the monthly compensation script | Ops | Li Wei | 2h |
| 🟠 | Add a status note to `feat/usage-based-billing` (continue/drop/blocker) | In-flight work | Li Wei | 1h |
| 🟡 | Fill the 4 missing vars in `.env.example` | Runnability | Li Wei | 0.5h |
| 🟡 | Document rollback procedure + alerting entry in README | Ops | Wang Fang can do later | 1h |

> Priority rationale: all 🔴🟠 items point to knowledge that **only Li Wei has and that becomes unrecoverable once he leaves** — fix while he's still around; some 🟡 items (e.g. rollback procedure) are publicly discoverable and can be left for Wang Fang to complete during onboarding.

## "First 30 minutes" entry point for the successor

Current docs are insufficient for a 30-minute ramp-up — **this section is itself the biggest gap**. After the fix-list is done, the ideal entry point would be:
1. `docs/architecture.md` — understand how the three services cooperate
2. `docs/billing-rules.adr.md` (to be written) — understand why money is calculated this way
3. `docs/runbook.md` (to be written) — learn to deploy, roll back, and run monthly reconciliation
4. Locally `make dev` to start the service, then run one subscription end-to-end with a Stripe test key
