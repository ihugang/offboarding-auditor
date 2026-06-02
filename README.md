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
├── SKILL.md                         # Main instructions: methodology, 10 dimensions, scoring, report templates (zh/en)
├── scripts/inventory.sh             # Phase 1 auto-inventory (bash + git; rg/fd optional)
└── references/
    ├── example-report.zh.md         # Filled-in sample report (Chinese)
    └── example-report.en.md         # Filled-in sample report (English)
```

## Install as a Claude Code skill

A skill is just a folder containing a `SKILL.md`. The folder name must match `name: offboarding-auditor` in the frontmatter. You can install it **globally** (available in every project) or **per-project**.

### Option A — Global (all projects)

```bash
git clone https://github.com/ihugang/offboarding-auditor.git \
  ~/.claude/skills/offboarding-auditor
```

Or if you already have the repo locally, copy/symlink it:

```bash
# copy
cp -R ./offboarding-auditor ~/.claude/skills/offboarding-auditor

# or symlink (edits to the source apply instantly; needs the source path to stay mounted)
ln -s "$(pwd)/offboarding-auditor" ~/.claude/skills/offboarding-auditor
```

### Option B — Per-project (this repo only)

```bash
git clone https://github.com/ihugang/offboarding-auditor.git \
  .claude/skills/offboarding-auditor
```

### Verify & use

```bash
# the folder should contain SKILL.md at its top level
ls ~/.claude/skills/offboarding-auditor/SKILL.md
```

Then **start a new Claude Code session** (skills are loaded at session start, not hot-reloaded) and trigger it in natural language — e.g. "run an offboarding/handover audit on this project", "check this repo's bus factor", or `/offboarding-auditor`.

> The skill is self-contained: no build step, no dependencies. `scripts/inventory.sh` needs `bash` + `git`; `rg`/`fd` are optional (it falls back to `grep`/`find`).

## License

MIT
