**English** | [简体中文](README.zh-CN.md)

<p align="center">
  <img src="icon.png" alt="offboarding-auditor" width="160">
</p>

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
bash skills/offboarding-auditor/scripts/inventory.sh <path/to/repo> > inventory.md
```

## Install

This repo is both a **Claude Code plugin** and a **standalone skill**. Pick whichever fits.

### Option A — Plugin (recommended, native install)

Inside Claude Code:

```text
/plugin marketplace add ihugang/offboarding-auditor
/plugin install offboarding-auditor@ihugang-skills
```

Gives you managed updates (`/plugin marketplace update`) and uninstall. The skill is model-invoked; you can also call it explicitly as `/offboarding-auditor:offboarding-auditor`.

### Option B — One-line terminal install

Installs the skill into `~/.claude/skills/` (global). Needs `git`.

```bash
curl -fsSL https://raw.githubusercontent.com/ihugang/offboarding-auditor/main/install.sh | bash
```

Project-scoped install (into `./.claude/skills/`):

```bash
SCOPE=project bash -c "$(curl -fsSL https://raw.githubusercontent.com/ihugang/offboarding-auditor/main/install.sh)"
```

### Option C — Manual

A skill is just a folder containing a `SKILL.md`. Copy the skill folder into your skills directory:

```bash
git clone https://github.com/ihugang/offboarding-auditor.git
cp -R offboarding-auditor/skills/offboarding-auditor ~/.claude/skills/offboarding-auditor   # global
# or: cp -R offboarding-auditor/skills/offboarding-auditor .claude/skills/offboarding-auditor  # per-project
```

### Then

**Start a new Claude Code session** (skills/plugins load at session start, not hot-reloaded) and trigger it in natural language — e.g. "run an offboarding/handover audit on this project", "check this repo's bus factor".

> Self-contained: no build step, no dependencies. `scripts/inventory.sh` needs `bash` + `git`; `rg`/`fd` are optional (falls back to `grep`/`find`).

## Structure

```text
.
├── .claude-plugin/
│   ├── plugin.json                          # Plugin manifest
│   └── marketplace.json                     # Marketplace catalog (this repo = a 1-plugin marketplace)
├── install.sh                               # Terminal one-line installer
└── skills/offboarding-auditor/
    ├── SKILL.md                             # Main instructions: methodology, 10 dimensions, scoring, report templates (zh/en)
    ├── scripts/inventory.sh                 # Phase 1 auto-inventory (bash + git; rg/fd optional)
    └── references/
        ├── example-report.zh.md             # Filled-in sample report (Chinese)
        └── example-report.en.md             # Filled-in sample report (English)
```

## License

MIT
