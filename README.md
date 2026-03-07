# Claude Agents & Skills Pipeline

A complete AI-powered app development pipeline designed specifically for use with the **Claude Code CLI**. Takes a raw product idea from concept to deployed application through a series of coordinated skills and subagents — each producing structured artifacts consumed by the next stage.

Whether you're building a mobile app, web product, or backend service, this pipeline guides Claude through every phase: ideation, specification, UI design, technical planning, implementation, QA, testing, and deployment.

---

## Quick Start

Once installed, run each stage in sequence by mentioning its name:

1. `use idea-analysis` — evaluate your idea
2. `use tech-spec` — generate requirements
3. `use ui-spec` — design the UI *(skip for backend-only projects)*
4. `use tech-plan` — generate the execution plan
5. `use execution` — implement the code
6. `use qa skill` — validate implementation against requirements
7. `use test` — run real environment tests
8. `use deploy` — deploy to target platform(s)

---

## Pipeline Overview

```
idea-analysis → tech-spec → ui-spec → tech-plan → execution → qa → test → deploy
```

| Stage | Type | Trigger | Input | Output |
|---|---|---|---|---|
| `idea-analysis` | Skill | `"use idea-analysis"` | Raw idea | Go/No-Go recommendation + handoff YAML |
| `tech-spec` | Skill | `"use tech-spec"` | idea-analysis handoff | `technical_requirements.json` + `.md` + handoff block |
| `ui-spec` | Agent | `"use ui-spec"` | tech-spec handoff block | UI specification document |
| `tech-plan` | Skill | `"use tech-plan"` | `technical_requirements.json` | `technical_plan.json` + `.md` |
| `execution` | Agent | `"use execution"` | `technical_plan.json` | `execution_report.json` + `.md` |
| `qa` | Skill | `"use qa skill"` | `technical_requirements.json` + `execution_report.json` | `qa_report.json` + `.md` |
| `test` | Agent | `"use test"` | `qa_report.json` + codebase | `test_report.json` + `.md` |
| `deploy` | Skill | `"use deploy"` | `test_report.json` + codebase | `deployment_report.json` + `.md` |

> **Note:** `idea-analysis` emits a handoff YAML and `ui-spec` emits a structured design document — neither produces canonical JSON. All other stages produce canonical JSON artifacts consumed by the next stage.

---

## When to Skip a Stage

- **Skip `ui-spec`** for backend-only projects, APIs, or CLI tools — go directly from `tech-spec` to `tech-plan`
- **Skip `idea-analysis`** if you already have clear requirements — start with `tech-spec` directly
- **`test` and `deploy`** require platform tooling (Xcode, Android Studio, deployment CLIs) — if unavailable, the agent will report blocked coverage rather than fail silently

---

## How This Differs from Default Claude Code

By default, Claude Code is a powerful general-purpose coding assistant — you describe what you want, and it writes code. That works well for small tasks, but breaks down on larger projects where consistency, traceability, and multi-stage validation matter.

This pipeline changes that by introducing **structure, contracts, and specialization** at every stage.

| | Default Claude Code | This Pipeline |
|---|---|---|
| **How you work** | Describe what you want in natural language | Each stage has a defined role, inputs, and outputs |
| **Output format** | Freeform code and text | Structured artifacts consumed by the next stage |
| **Requirements** | Implicit — Claude infers intent | Explicit — `technical_requirements.json` defines every user story, acceptance criteria, and constraint |
| **Implementation** | Claude decides scope and approach | Execution agent follows an approved plan exactly — no scope creep |
| **Validation** | You review the code manually | QA agent independently inspects files, runs tests, and validates against requirements |
| **Testing** | Manual or ad hoc | Test agent runs real-environment tests where tooling is available, and reports blocked or partial coverage when the environment cannot fully validate a story |
| **Deployment** | You run deploy commands yourself | Deploy skill detects targets, presents a plan with rollback paths, and requires explicit confirmation |
| **Traceability** | None — hard to know what was built and why | Every requirement traces to a deliverable, every deliverable traces to test results |
| **Multi-machine** | Custom setup is often local unless you version it in Git | Everything versioned in Git — pull on any machine and continue |

### The core difference

Default Claude Code is **conversational** — each message is relatively independent. This pipeline is **contractual** — each stage produces a structured artifact that the next stage reads, validates, and builds on. Nothing is lost between stages, and nothing is assumed.

The result is a workflow that behaves more like a small engineering team than a single AI assistant:

- `idea-analysis` acts like a **product strategist**
- `tech-spec` acts like a **technical product manager**
- `ui-spec` acts like a **UX designer**
- `tech-plan` acts like a **solutions architect**
- `execution` acts like a **senior engineer**
- `qa` acts like a **QA engineer**
- `test` acts like a **QA automation engineer**
- `deploy` acts like a **DevOps engineer**

Each role has a clear mandate, defined inputs, and structured outputs — and hands off cleanly to the next.

---

## Project Structure

```
claude-agents/
├── README.md                         # This file
│
├── skills/                           # Context-injected instructions
│   ├── idea-analysis/
│   │   └── SKILL.md
│   ├── tech-spec/
│   │   └── SKILL.md
│   ├── tech-plan/
│   │   ├── SKILL.md
│   │   └── schema.json               # JSON Schema for technical_plan.json
│   ├── qa/
│   │   └── SKILL.md
│   └── deploy/
│       └── SKILL.md
│
└── agents/                           # Autonomous Claude Code subagents
    ├── ui-spec.md
    ├── execution.md
    └── test.md
```

---

## Canonical Artifact Chain

`idea-analysis` and `ui-spec` produce structured handoff and design artifacts rather than canonical JSON, so they are not shown in this chain. All other stages produce canonical JSON read by the next stage.

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
- **Output:** `technical_requirements.json` (canonical) + `technical_requirements.md` + handoff block for `ui-spec` and `tech-plan`
- **Covers:** project classification, user stories with acceptance criteria IDs, functional requirements with validation rules, NFRs with priority levels, data model, API contracts, integrations, traceability matrix, constraints, assumptions
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
- **Covers:** story coverage, acceptance criteria validation by stable ID, requirements drift, API contract drift, data model drift, scope creep, constraint violations
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
- **Behavior:** deterministic implementation only — no scope expansion, no opportunistic refactors; pauses on material ambiguity; detects already-satisfied deliverables; verifies each acceptance criterion after implementation; produces structured pause reports when blocked
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
- **Behavior:** runs existing test suites first; then story-level verification for uncovered acceptance criteria; collects screenshots and logs as evidence; marks criteria as `partial` when UI tooling is insufficient; guaranteed teardown via cumulative trap
- **Preflight:** checks for missing `.env`, credentials, feature flags before starting

---

## Prerequisites

- **Claude Code CLI** — [install here](https://claude.ai/code)
- **Git** — for cloning and keeping skills/agents up to date
- **Xcode** — required for iOS testing and deployment (macOS only)
- **Android Studio** — required for Android testing and deployment
- **Node.js** — required for web and backend projects

---

## Installation

### Fresh install on a new machine

```bash
# Clone directly into ~/.claude
git clone https://github.com/alexzakv/claude-agents.git ~/.claude
```

Claude Code will automatically pick up all skills and agents on next launch.

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

To auto-sync every time you open a new terminal session, add this shell function to your `~/.zshrc` or `~/.bashrc`:

```bash
claude() {
  (cd ~/.claude && git pull --quiet >/dev/null 2>&1)
  command claude "$@"
}
```

---

## How Skills and Agents Differ

| | Skills | Agents |
|---|---|---|
| **Location** | `~/.claude/skills/<n>/SKILL.md` | `~/.claude/agents/<n>.md` |
| **How activated** | Injected as context when name is mentioned | Run as autonomous subagent |
| **Model** | Inherits from conversation | Configurable per agent |
| **Tools** | Inherits from conversation | Configurable per agent |
| **Memory** | No persistent memory | Optional persistent memory |
| **Best for** | Structured output, spec generation, reporting | Multi-step implementation, testing, deployment |

---

## Trigger Reference

All skills and agents are **only triggered when explicitly named** — they never activate automatically on general requests.

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

---

## Examples

### Skill example — `tech-spec`

```
You: I want to build a habit tracking app for iOS. Use tech-spec.

Claude: [runs tech-spec]
        → Classified as: greenfield
        → Generated technical_requirements.json with:
          - 6 must-have user stories
          - 14 functional requirements
          - Data model: User, Habit, HabitLog
          - API contracts for 8 endpoints
          - NFRs: < 2s load, 99.9% uptime, WCAG 2.1 AA
        → Next step: say "use ui-spec" or "use tech-plan"
```

### Agent example — `execution`

```
You: Use execution.

Claude: [runs execution agent]
        → Loaded technical_plan.json — 3 phases, 12 deliverables
        → Scanned codebase — Swift, SwiftUI, confirmed stack match
        → Scope confirmed: Phase 1 targets src/models, src/api
        → Executing phase 1...
          ✅ D-001: User authentication — all 3 criteria verified
          ✅ D-002: Habit data model — all 2 criteria verified
          ✅ D-003: Core API endpoints — 4/4 criteria verified
        → Phase 1 complete. Proceeding to phase 2...
        → execution_report.json ready. Next step: use qa skill.
```
