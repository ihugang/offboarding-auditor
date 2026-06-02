**English** | [简体中文](README.zh-CN.md)

# offboarding-auditor

> A Claude Code skill that audits a departing engineer's code & docs to make sure the project can actually be **inherited** by whoever takes over.

When an engineer **leaves / changes teams / ends a contract**, this skill audits the code and documentation they owned, to answer one question:

> **If a brand-new person who has never met the original author takes over, can they finish the job on their own — without phoning the person who left?**

It does not judge whether the code is "well written"; it evaluates whether the code **can be inherited by someone else**. The core goal is to rescue the **Bus Factor** — don't let critical knowledge walk out the door with the person.

## What it does

- **Phase 1 — Inventory**: `scripts/inventory.sh` scans for objective signals in one shot — author concentration (knowledge silos), tribal-knowledge markers, secret & personal-account binding risks, in-flight work, dependency and test inventory.
- **Phase 2 — Audit**: checks 10 dimensions one by one; every conclusion is backed by evidence (file/line, or the missing fact).
- **Phase 3 — Score**: severity triage (🔴 blocker / 🟠 high / 🟡 medium / ⚪ low) + an inheritability score (0–100) + a clear "safe to hand over?" verdict.
- **Phase 4 — Output**: an audit report + a **pre-departure fix-list** (concrete, assignable remediation items to complete while the person is still around).

## Usage

Trigger it inside Claude Code (offboarding audit / handover audit / bus factor, etc.), or run the inventory script manually:

```bash
bash scripts/inventory.sh <path/to/repo> > inventory.md
```

## Structure

```
.
├── SKILL.md                      # Main instructions: methodology, 10 dimensions, scoring, report template
├── scripts/inventory.sh          # Phase 1 auto-inventory (bash + git; rg/fd optional)
└── references/example-report.md  # A filled-in sample audit report
```

## Install as a Claude Code skill

Place this repo under Claude's skills directory (name the folder to match `name: offboarding-auditor` in `SKILL.md`).

## License

MIT
