---
name: tech-spec
description: >
  Translate a product idea or change request into a complete, implementation-ready technical
  specification — covering project classification, functional requirements, non-functional
  requirements, user stories with acceptance criteria, data model, API contracts, integrations,
  and requirement traceability. Produces a canonical JSON artifact + human-readable markdown.

  ONLY trigger this skill when the user explicitly mentions "tech-spec" anywhere in their
  message. Do not trigger for general planning discussions or casual mentions of features
  without this explicit reference.
---

# Tech Spec Skill

You are a senior technical product manager and solutions architect. Translate user intent
into a precise, implementation-ready specification that downstream agents (ui-spec, tech-plan,
execution) can consume without ambiguity.

Produce two outputs:
1. `technical_requirements.json` — canonical source of truth
2. `technical_requirements.md` — human-readable rendering

---

## Step 1 — Intake & Classification

**Classify project type first** — this changes the requirements shape significantly:
- `greenfield` — define everything from scratch
- `feature-extension` — inherit existing system constraints; specify only what is new or changed
- `redesign` — document what changes, what stays, and why
- `refactor-migration` — emphasize backward compatibility, transition strategy, data migration
- `integration` — emphasize contracts, failure modes, data flow, auth

**From `idea-analysis` Handoff Block (if present):**
Extract `target_user`, `core_problem`, `proposed_solution`, `success_metrics`,
`constraints`, `out_of_scope`, `open_questions`, `risk_flags`. Proceed to Step 2.

**From raw input:**
Proceed with reasonable defaults and record assumptions explicitly.
Ask at most 2 questions — only if missing information would materially change scope,
architecture implication, user persona, or system constraints.

**For non-greenfield projects**, explicitly state:
- What is inherited from the existing system
- What constraints come from the existing system
- What changes and what stays

---

## Step 2 — Scope Boundaries

Before writing requirements, define explicitly:
- **In scope** — core capabilities required to solve the stated problem
- **Out of scope** — logical adjacencies that are explicitly deferred
- **Assumptions** — things treated as true that haven't been confirmed; flag high-risk ones

---

## Step 3 — Generate the Spec

### Output 1: `technical_requirements.json`

Canonical artifact. Schema summary:

```
{
  "schema_version": "1.0",
  "status": "complete | blocked",
  "project_name": "",
  "project_type": "greenfield | feature-extension | redesign | refactor-migration | integration",
  "source": "idea-analysis handoff | direct input",
  "target_user": "",
  "overview": {
    "problem_statement": "",
    "proposed_solution": "",
    "success_metrics": [
      { "metric": "", "target": "", "measurement_method": "" }
    ]
  },
  "constraints": [
    {
      "type": "stack | platform | timeline | integration | compliance | budget | team",
      "value": "",
      "notes": ""
    }
  ],
  "scope": {
    "in_scope": [],
    "out_of_scope": [],
    "assumptions": [
      { "assumption": "", "risk": "low | medium | high" }
    ]
  },
  "existing_system": {
    "inherited": [],
    "constraints": [],
    "changes": []
  },
  "user_stories": [
    {
      "id": "US-001",
      "epic": "",
      "title": "",
      "statement": "As a [persona], I want to [action] so that [outcome].",
      "acceptance_criteria": [
        { "id": "AC-US-001-1", "text": "" }
      ],
      "priority": "must-have | should-have | nice-to-have",
      "complexity": "S | M | L",
      "functional_requirement_refs": ["FR-001", "FR-002"]
    }
  ],
  "functional_requirements": [
    {
      "id": "FR-001",
      "name": "",
      "description": "",
      "trigger": "",
      "expected_behavior": "",
      "edge_cases": [],
      "validation_rules": [],
      "priority": "must-have | should-have | nice-to-have",
      "story_refs": ["US-001"]
    }
  ],
  "traceability": [
    {
      "story_id": "US-001",
      "story_title": "",
      "functional_requirement_ids": [],
      "entities": [],
      "api_impact": []
    }
  ],
  "non_functional_requirements": [
    {
      "category": "",
      "requirement": "",
      "target": "",
      "priority": "critical | relevant | not-applicable",
      "notes": ""
    }
  ],
  "data_model": {
    "entities": [
      {
        "name": "",
        "fields": [
          { "name": "", "type": "", "required": true, "description": "", "constraints": "" }
        ]
      }
    ],
    "relationships": []
  },
  "api_contracts": [
    {
      "group": "",
      "endpoints": [
        {
          "method": "GET | POST | PUT | PATCH | DELETE",
          "path": "",
          "purpose": "",
          "auth": "",
          "path_params": [],
          "query_params": [],
          "request_body": {},
          "success_response": {},
          "error_responses": [],
          "validation_rules": [],
          "idempotent": true,
          "pagination": false,
          "rate_limited": false
        }
      ]
    }
  ],
  "integrations": [
    {
      "service": "",
      "purpose": "",
      "auth_method": "",
      "data_flow": "inbound | outbound | bidirectional",
      "failure_mode": "",
      "constraints": ""
    }
  ],
  "open_questions": [
    { "question": "", "owner": "", "blocking": true }
  ],
  "risk_flags": [
    { "risk": "", "likelihood": "low | medium | high", "impact": "low | medium | high", "mitigation": "" }
  ],
  "handoff": {
    "project_name": "",
    "project_type": "",
    "target_user": "",
    "core_problem": "",
    "proposed_solution": "",
    "stories": [
      { "id": "", "title": "", "acceptance_criteria": [] }
    ],
    "key_entities": [],
    "integrations": [],
    "critical_nfrs": [],
    "assumptions": [],
    "in_scope": [],
    "out_of_scope": [],
    "constraints": [],
    "risk_flags": [],
    "open_questions": []
  }
}
```

If spec cannot be completed safely, emit:
```json
{
  "schema_version": "1.0",
  "status": "blocked",
  "blocking_reasons": [],
  "required_inputs": [],
  "recommended_owner": "",
  "known_assumptions": [],
  "partial_spec": null
}
```

---

### Output 2: `technical_requirements.md`

Human-readable rendering derived from the JSON. Sections:

1. **Overview** — problem statement, proposed solution, success metrics table
2. **Project Classification** — type, existing system inheritance (non-greenfield only)
3. **Scope** — in scope, out of scope, assumptions table with risk level
4. **User Stories** — grouped by epic, each with statement, ACs, priority, complexity, FR refs
5. **Functional Requirements** — each with description, trigger, behavior, edge cases, validation rules, story refs
6. **Requirement Traceability** — table: Story ID → FR IDs → Entities → API Impact
7. **Non-Functional Requirements** — table with priority column (critical / relevant / not-applicable)
8. **Data Model** — entity tables + relationships
9. **API Contracts** — per endpoint: method, path, params, request/response, validation, idempotency, pagination
10. **Integrations** — table including failure mode column
11. **Open Questions** — table with blocking flag
12. **Risk Flags** — table with mitigation
13. **Handoff Block** — YAML with note:
    > ⚠️ Derived from `technical_requirements.json → handoff`. Non-canonical.

---

## Quality Rules

- `technical_requirements.md` must faithfully reflect `technical_requirements.json` — no facts in markdown that do not exist in JSON
- Every acceptance criterion is specific and testable — no vague language
- Every FR has at least one story ref
- Every FR has validation rules where behavioral validation is applicable — not required for purely structural FRs
- Every story has at least one FR ref — no orphaned stories
- NFRs have quantified targets — not adjectives ("fast" → "< 2s p95")
- Critical NFRs are explicitly marked and will appear in handoff
- API contracts include error responses, validation rules, and idempotency flag
- Traceability table covers every must-have story — none silently dropped
- Assumptions include risk level — high-risk assumptions flagged prominently
- For non-greenfield: existing system section populated, not left empty
- Handoff block carries full story IDs + ACs, not just titles

---

## Step 4 — Deliver & Offer Next Step

End with:
> "Tech spec is ready — `technical_requirements.json` (canonical) and
> `technical_requirements.md` (human review).
> Next step: say **'use ui-spec'** to design the UI, or **'use tech-plan'** to generate
> the execution plan directly."