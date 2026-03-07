# Claude Agents & Skills Pipeline

A complete AI-powered app development pipeline built for [Claude Code](https://claude.ai/code). Takes a raw product idea from concept to deployed application through a series of coordinated skills and subagents — each producing structured JSON artifacts consumed by the next stage.

---

## Pipeline Overview

```
idea-analysis → tech-spec → ui-spec → tech-plan → execution → qa → test → deploy
```

| Stage | Type | Trigger | Input | Output |
|---|---|---|---|---|
| `idea-analysis` | Skill | `"use idea-analysis"` | Raw idea | Go/No-Go + handoff YAML |
| `tech-spec` | Skill | `"use tech-spec"` | idea-analysis handoff | `technical_requirements.json` + `.md` |
| `ui-spec` | Agent | `"use ui-spec"` | tech-spec handoff | UI specification document |
| `tech-plan` | Skill | `"use tech-plan"` | `technical_requirements.json` | `technical_plan.json` + `.md` |
| `execution` | Agent | `"use execution"` | `technical_plan.json` | `execution_report.json` + `.md` |
| `qa` | Skill | `"use qa skill"` | `technical_requirements.json` + `execution_report.json` | `qa_report.json` + `.md` |
| `test` | Agent | `"use test"` | `qa_report.json` + codebase | `test_report.json` + `.md` |
| `deploy` | Skill | `"use deploy"` | `test_report.json` + codebase | `deployment_report.json` + `.md` |

---

## Canonical Artifact Chain

Every stage reads the previous stage's JSON as input and produces its own. The pipeline is fully contract-driven.

```
technical_requirements.json
  → technical_plan.json
    → execution_report.json
      → qa_report.json
        → test_report.json
          → deployment_report.json
```

---

## Skills

Skills are context-injected instructions that activate when their name is mentioned. Stored in `~/.claude/skills/`.

### `idea-analysis`
Evaluates a product idea and produces a structured Go/No-Go/Pivot recommendation.

- **Trigger:** mention `"idea-analysis"` in your message
- **Input:** raw product idea or change request
- **Output:** structured analysis with customer value, business impact, feasibility, recommendation, and a YAML handoff block for `tech-spec`
- **Sections:** Idea Summary → Customer Value → Business Impact → Market & Competitors → Feasibility → Recommendation → Handoff Block

---

### `tech-spec`
Translates a product idea into a complete, implementation-ready technical specification.

- **Trigger:** mention `"tech-spec"` in your message
- **Input:** `idea-analysis` handoff block OR raw description
- **Output:** `technical_requirements.json` (canonical) + `technical_requirements.md`
- **Covers:** project classification, user stories with AC IDs, functional requirements with validation rules, NFRs with priority levels, data model, API contracts, integrations, traceability matrix, constraints, assumptions
- **Project types:** `greenfield` / `feature-extension` / `redesign` / `refactor-migration` / `integration`

---

### `tech-plan`
Generates a dependency-aware, phased technical execution plan from requirements.

- **Trigger:** mention `"tech-plan"` in your message
- **Input:** `technical_requirements.json`
- **Output:** `technical_plan.json` (canonical) + `technical_plan.md`
- **Covers:** architecture decisions, parallel workstreams, deliverables with acceptance criteria, cross-cutting checklist (auth, observability, CI/CD, etc.), requirement traceability, risk flags, external dependencies, execution handoff block
- **Schema:** defined in `skills/tech-plan/schema.json`

---

### `qa`
Validates a completed implementation against the original requirements.

- **Trigger:** mention `"use qa skill"` in your message
- **Input:** `technical_requirements.json` + `execution_report.json` + codebase
- **Output:** `qa_report.json` (canonical) + `qa_report.md`
- **QA model:** real implementation validation — independently inspects changed files, runs tests/build/lint, compares against execution claims
- **Covers:** story coverage, AC validation by stable ID, requirements drift, API contract drift, data model drift, scope creep, constraint violations
- **Severity:** Critical / Major / Minor / Advisory
- **Auto-routes:** implementation errors → `execution`; plan gaps → `tech-plan`; spec errors → `tech-spec`; all clear → `test`

---

### `deploy`
Deploys a tested implementation to its target platform(s).

- **Trigger:** mention `"use deploy"` in your message
- **Input:** `test_report.json` + codebase
- **Output:** `deployment_report.json` (canonical) + `deployment_report.md`
- **Platforms:** iOS (App Store / TestFlight), Android (Play Store), Web (Vercel / Netlify / GitHub Pages / AWS / GCP), Backend (Railway / Render / Fly.io / Heroku / Docker), React Native, Flutter
- **Safety:** never deploys without explicit human confirmation; presents full deployment plan with rollback paths before any action; never handles credentials directly
- **Covers:** target detection, environment classification, preflight checks (uncommitted changes, migrations, missing credentials), rollback planning, post-deploy verification, partial redeploy resume

---

## Agents

Agents are autonomous subagents in Claude Code with their own model, tools, and memory. Stored in `~/.claude/agents/`.

### `ui-spec`
Produces a complete UI specification from technical requirements.

- **Trigger:** mention `"use ui-spec"` in your message
- **Model:** Opus
- **Input:** `tech-spec` handoff block
- **Output:** UI specification with screen inventory, component hierarchy, interaction flows, responsive wireframes, accessibility requirements, design tokens, requirement traceability
- **Project types:** `greenfield` / `feature-extension` / `redesign` / `design-system-extension`

---

### `execution`
Implements an approved technical plan phase by phase.

- **Trigger:** mention `"use execution"` in your message
- **Model:** Sonnet
- **Input:** `technical_plan.json`
- **Output:** `execution_report.json` (canonical) + `execution_report.md`
- **Behavior:** deterministic implementation only — no scope expansion, no opportunistic refactors; pauses on material ambiguity; detects already-satisfied deliverables; verifies each AC after implementation; produces structured pause reports when blocked
- **Verification ladder:** targeted tests → build/typecheck/lint → static verification
- **Resume:** detects prior `execution_report.json` and resumes from first incomplete deliverable

---

### `test`
Runs real environment tests against a completed implementation.

- **Trigger:** mention `"use test"` in your message
- **Model:** Sonnet
- **Input:** `qa_report.json` + `technical_requirements.json` + `execution_report.json` + codebase
- **Output:** `test_report.json` (canonical) + `test_report.md`
- **Platforms:** iOS (Xcode Simulator + XCTest), Android (Emulator + Espresso), Web (Playwright / Cypress / curl), Backend (HTTP client), React Native, Flutter
- **Behavior:** runs existing test suites first; then story-level verification for uncovered ACs; collects screenshots and logs as evidence; marks ACs as `partial` when UI tooling is insufficient; guaranteed teardown via cumulative trap
- **Preflight:** checks for missing `.env`, credentials, feature flags before starting

---

## Installation

### Requirements
- [Claude Code](https://claude.ai/code) installed
- Git

### Fresh install on a new machine

```bash
# Clone directly into ~/.claude
git clone https://github.com/alexzakv/claude-agents.git ~/.claude
```

That's it. Claude Code will automatically pick up all skills and agents on next launch.

### If ~/.claude already exists

```bash
# Copy skills and agents into existing ~/.claude
git clone https://github.com/alexzakv/claude-agents.git /tmp/claude-agents
cp -r /tmp/claude-agents/skills ~/.claude/
cp -r /tmp/claude-agents/agents ~/.claude/
rm -rf /tmp/claude-agents
```

---

## Keeping Up to Date

```bash
# Pull latest skills and agents
cd ~/.claude && git pull
```

Add a shell alias to auto-sync on every Claude Code launch:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias claude='cd ~/.claude && git pull --quiet && cd - > /dev/null && claude'
```

---

## Making Changes

After editing any skill or agent locally:

```bash
cd ~/.claude
git add skills/ agents/
git commit -m "describe what you changed"
git push
```

---

## Repo Structure

```
claude-agents/
├── README.md
├── .gitignore
├── settings.json
│
├── skills/
│   ├── idea-analysis/
│   │   └── SKILL.md
│   ├── tech-spec/
│   │   └── SKILL.md
│   ├── tech-plan/
│   │   ├── SKILL.md
│   │   └── schema.json          ← JSON Schema for technical_plan.json
│   ├── qa/
│   │   └── SKILL.md
│   └── deploy/
│       └── SKILL.md
│
└── agents/
    ├── ui-spec.md
    ├── execution.md
    └── test.md
```

---

## How Skills and Agents Differ

| | Skills | Agents |
|---|---|---|
| **Location** | `~/.claude/skills/<name>/SKILL.md` | `~/.claude/agents/<name>.md` |
| **How activated** | Injected as context when name is mentioned | Run as autonomous subagent |
| **Model** | Inherits from conversation | Configurable per agent |
| **Tools** | Inherits from conversation | Configurable per agent |
| **Memory** | No persistent memory | Optional persistent memory |
| **Best for** | Structured output, spec generation, reporting | Multi-step implementation, testing, deployment |

---

## Trigger Reference

| Say this | Activates |
|---|---|
| `"use idea-analysis"` | idea-analysis skill |
| `"use tech-spec"` | tech-spec skill |
| `"use ui-spec"` | ui-spec agent |
| `"use tech-plan"` | tech-plan skill |
| `"use execution"` | execution agent |
| `"use qa skill"` | qa skill |
| `"use test"` | test agent |
| `"use deploy"` | deploy skill |

All skills and agents are **only triggered when explicitly named** — they never activate automatically on general requests.

---

## Example Full Pipeline Run

```
You: I want to build a habit tracking app for iOS. Use idea-analysis.

Claude: [runs idea-analysis] → Go. Here's the handoff block...

You: Use tech-spec.

Claude: [runs tech-spec] → technical_requirements.json generated.

You: Use ui-spec.

Claude: [runs ui-spec agent] → UI specification complete.

You: Use tech-plan.

Claude: [runs tech-plan] → technical_plan.json generated. 3 phases, 12 deliverables.

You: Use execution.

Claude: [runs execution agent] → Implemented phases 1-3. execution_report.json ready.

You: Use qa skill.

Claude: [runs qa] → 2 minor warnings. qa_report.json → next step: use test.

You: Use test.

Claude: [runs test agent] → Booted iPhone 15 simulator. All 8 stories passed. test_report.json ready.

You: Use deploy.

Claude: [runs deploy] → Deployment plan presented. Awaiting confirmation...

You: confirmed

Claude: [deploys to TestFlight] → deployment_report.json. Build 1 live in TestFlight.
```
